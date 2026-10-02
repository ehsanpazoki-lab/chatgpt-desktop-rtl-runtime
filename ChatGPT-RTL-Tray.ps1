param(
    [int]$Port = 9230
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$Root = $PSScriptRoot
$RunScript = Join-Path $Root 'ChatGPT-RTL-Run.ps1'
$DisableScript = Join-Path $Root 'Disable-ChatGPT-RTL.ps1'
$PidFile = Join-Path $Root 'chatgpt-rtl-tray.pid'
$ActiveIconPath = Join-Path $Root 'assets\icons\ChatGPT-RTL.ico'
$InactiveIconPath = Join-Path $Root 'assets\icons\ChatGPT-RTL-Inactive.ico'

function Import-TrayIcon {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return [System.Drawing.SystemIcons]::Application
    }

    $stream = [System.IO.File]::Open(
        $Path,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::ReadWrite
    )

    try {
        $sourceIcon = New-Object System.Drawing.Icon($stream)
        try {
            return [System.Drawing.Icon]$sourceIcon.Clone()
        }
        finally {
            $sourceIcon.Dispose()
        }
    }
    finally {
        $stream.Dispose()
    }
}


$createdNew = $false
$mutex = New-Object System.Threading.Mutex(
    $true,
    'Local\ChatGPTDesktopRTLRuntimeTray_v021',
    [ref]$createdNew
)

if (-not $createdNew) {
    exit 0
}

try {
    [System.IO.File]::WriteAllText(
        $PidFile,
        [string]$PID,
        (New-Object System.Text.UTF8Encoding($false))
    )
}
catch {}

function Invoke-CdpExpression {
    param(
        [Parameter(Mandatory=$true)]
        [string]$WebSocketUrl,

        [Parameter(Mandatory=$true)]
        [string]$Expression
    )

    $ws = New-Object System.Net.WebSockets.ClientWebSocket
    $cts = New-Object System.Threading.CancellationTokenSource
    $cts.CancelAfter(4000)

    try {
        $wsUri = New-Object System.Uri ([string]$WebSocketUrl)
        $null = $ws.ConnectAsync($wsUri, $cts.Token).GetAwaiter().GetResult()

        $msg = @{
            id = 1
            method = 'Runtime.evaluate'
            params = @{
                expression = $Expression
                returnByValue = $true
            }
        } | ConvertTo-Json -Depth 10 -Compress

        $bytes = [System.Text.Encoding]::UTF8.GetBytes($msg)
        $seg = New-Object System.ArraySegment[byte] -ArgumentList @(,$bytes)

        $null = $ws.SendAsync(
            $seg,
            [System.Net.WebSockets.WebSocketMessageType]::Text,
            $true,
            $cts.Token
        ).GetAwaiter().GetResult()

        while ($true) {
            $sb = New-Object System.Text.StringBuilder

            do {
                $buf = New-Object byte[] 65536
                $rseg = New-Object System.ArraySegment[byte] -ArgumentList @(,$buf)
                $res = $ws.ReceiveAsync($rseg, $cts.Token).GetAwaiter().GetResult()
                [void]$sb.Append(
                    [System.Text.Encoding]::UTF8.GetString($buf, 0, $res.Count)
                )
            } while (-not $res.EndOfMessage)

            $obj = $sb.ToString() | ConvertFrom-Json
            if ($obj.id -eq 1) {
                return $obj.result.result.value
            }
        }
    }
    finally {
        try {
            if ($ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
                $closeCts = New-Object System.Threading.CancellationTokenSource
                $closeCts.CancelAfter(1000)
                try {
                    $null = $ws.CloseAsync(
                        [System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure,
                        'done',
                        $closeCts.Token
                    ).GetAwaiter().GetResult()
                }
                finally {
                    $closeCts.Dispose()
                }
            }
        }
        catch {}

        $ws.Dispose()
        $cts.Dispose()
    }
}

function Get-RtlStatus {
    try {
        $rawTargets = Invoke-RestMethod `
            -Uri "http://127.0.0.1:$Port/json/list" `
            -TimeoutSec 2

        $targets = @($rawTargets | ForEach-Object { $_ })
    }
    catch {
        return [pscustomobject]@{
            Debugger = $false
            Active = $false
            FontLoaded = $false
            RootFound = $false
            Detail = 'ChatGPT is not running with the local RTL CDP session.'
        }
    }

    $target = $targets |
        Where-Object {
            $_.type -eq 'page' -and $_.url -eq 'app://-/index.html'
        } |
        Select-Object -First 1

    if (-not $target) {
        return [pscustomobject]@{
            Debugger = $true
            Active = $false
            FontLoaded = $false
            RootFound = $false
            Detail = 'CDP is active, but the main ChatGPT renderer was not found.'
        }
    }

    $wsUrl = @($target.webSocketDebuggerUrl) |
        Where-Object { $_ } |
        Select-Object -First 1

    if (-not $wsUrl) {
        return [pscustomobject]@{
            Debugger = $true
            Active = $false
            FontLoaded = $false
            RootFound = $false
            Detail = 'The main renderer has no WebSocket debugger URL.'
        }
    }

    try {
        $expr = @"
(() => JSON.stringify({
  active: !!window.__chatgptRtlFinal,
  fontLoaded: Array.from(document.fonts || []).some(
    f => f.family === 'ChatGPT Vazirmatn'
  ),
  rootFound: !!window.__chatgptRtlFinal?.findConversationRoot?.()
}))()
"@

        $value = Invoke-CdpExpression `
            -WebSocketUrl ([string]$wsUrl) `
            -Expression $expr

        $state = $value | ConvertFrom-Json

        return [pscustomobject]@{
            Debugger = $true
            Active = [bool]$state.active
            FontLoaded = [bool]$state.fontLoaded
            RootFound = [bool]$state.rootFound
            Detail = 'Runtime status read successfully.'
        }
    }
    catch {
        return [pscustomobject]@{
            Debugger = $true
            Active = $false
            FontLoaded = $false
            RootFound = $false
            Detail = "Could not query the renderer: $($_.Exception.Message)"
        }
    }
}

function Start-HiddenPowerShell {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,

        [string]$ExtraArguments = ''
    )

    if (-not (Test-Path -LiteralPath $ScriptPath)) {
        throw "Required script not found: $ScriptPath"
    }

    $quoted = '"' + $ScriptPath.Replace('"', '\"') + '"'
    $argLine = "-NoProfile -ExecutionPolicy Bypass -File $quoted"

    if ($ExtraArguments) {
        $argLine += " $ExtraArguments"
    }

    Start-Process `
        -FilePath 'powershell.exe' `
        -ArgumentList $argLine `
        -WindowStyle Hidden | Out-Null
}

$notify = New-Object System.Windows.Forms.NotifyIcon
$notify.Icon = Import-TrayIcon -Path $InactiveIconPath
$notify.Text = 'ChatGPT RTL: checking...'
$notify.Visible = $true

$menu = New-Object System.Windows.Forms.ContextMenuStrip
$headerItem = New-Object System.Windows.Forms.ToolStripMenuItem
$headerItem.Text = 'ChatGPT RTL Runtime'
$headerItem.Enabled = $false

$enableItem = New-Object System.Windows.Forms.ToolStripMenuItem
$enableItem.Text = 'Enable RTL'

$disableItem = New-Object System.Windows.Forms.ToolStripMenuItem
$disableItem.Text = 'Disable RTL'

$statusItem = New-Object System.Windows.Forms.ToolStripMenuItem
$statusItem.Text = 'Status'

$separator = New-Object System.Windows.Forms.ToolStripSeparator

$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem
$exitItem.Text = 'Exit Tray Controller'

[void]$menu.Items.Add($headerItem)
[void]$menu.Items.Add($enableItem)
[void]$menu.Items.Add($disableItem)
[void]$menu.Items.Add($statusItem)
[void]$menu.Items.Add($separator)
[void]$menu.Items.Add($exitItem)

$notify.ContextMenuStrip = $menu

$script:LastActive = $null
$script:RefreshInProgress = $false

function Refresh-TrayStatus {
    if ($script:RefreshInProgress) {
        return
    }

    $script:RefreshInProgress = $true

    try {
        $s = Get-RtlStatus

        if ($s.Active) {
            $notify.Icon = Import-TrayIcon -Path $ActiveIconPath
            $notify.Text = 'ChatGPT RTL: Active'
            $enableItem.Enabled = $false
            $disableItem.Enabled = $true
        }
        else {
            $notify.Icon = Import-TrayIcon -Path $InactiveIconPath
            $notify.Text = 'ChatGPT RTL: Inactive'
            $enableItem.Enabled = $true
            $disableItem.Enabled = $s.Debugger
        }

        if ($null -ne $script:LastActive -and $script:LastActive -ne $s.Active) {
            if ($s.Active) {
                $notify.BalloonTipTitle = 'ChatGPT RTL'
                $notify.BalloonTipText = 'RTL + Vazirmatn is active.'
            }
            else {
                $notify.BalloonTipTitle = 'ChatGPT RTL'
                $notify.BalloonTipText = 'RTL is inactive.'
            }

            $notify.ShowBalloonTip(1800)
        }

        $script:LastActive = $s.Active
    }
    catch {
        $notify.Text = 'ChatGPT RTL: status error'
        $enableItem.Enabled = $true
        $disableItem.Enabled = $true
    }
    finally {
        $script:RefreshInProgress = $false
    }
}

$enableAction = {
    try {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Enable ChatGPT RTL?`r`n`r`nIf ChatGPT is already running without the local RTL debugging port, it will be restarted.",
            'ChatGPT RTL Runtime',
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }

        Start-HiddenPowerShell `
            -ScriptPath $RunScript `
            -ExtraArguments "-Port $Port -ForceRestart"

        $notify.BalloonTipTitle = 'ChatGPT RTL'
        $notify.BalloonTipText = 'Enabling RTL...'
        $notify.ShowBalloonTip(1500)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'ChatGPT RTL Error',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}

$enableItem.Add_Click($enableAction)
$notify.Add_DoubleClick($enableAction)

$disableItem.Add_Click({
    try {
        Start-HiddenPowerShell `
            -ScriptPath $DisableScript `
            -ExtraArguments "-Port $Port"

        $notify.BalloonTipTitle = 'ChatGPT RTL'
        $notify.BalloonTipText = 'Disabling RTL...'
        $notify.ShowBalloonTip(1500)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            'ChatGPT RTL Error',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

$statusItem.Add_Click({
    $s = Get-RtlStatus

    $message = @"
CDP session:       $($s.Debugger)
RTL active:        $($s.Active)
Vazirmatn loaded:  $($s.FontLoaded)
Conversation root: $($s.RootFound)

$($s.Detail)
"@

    [System.Windows.Forms.MessageBox]::Show(
        $message,
        'ChatGPT RTL Status',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
})

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 8000
$timer.Add_Tick({ Refresh-TrayStatus })
$timer.Start()

$exitItem.Add_Click({
    $timer.Stop()
    $notify.Visible = $false
    [System.Windows.Forms.Application]::Exit()
})

try {
    Refresh-TrayStatus
    [System.Windows.Forms.Application]::Run()
}
finally {
    try { $timer.Stop() } catch {}
    try { $notify.Visible = $false } catch {}
    try { $notify.Dispose() } catch {}
    try { $menu.Dispose() } catch {}
    try { Remove-Item -LiteralPath $PidFile -Force -ErrorAction SilentlyContinue } catch {}
    try { $mutex.ReleaseMutex() } catch {}
    try { $mutex.Dispose() } catch {}
}
