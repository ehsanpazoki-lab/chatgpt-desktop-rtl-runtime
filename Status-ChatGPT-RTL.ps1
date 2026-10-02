param([int]$Port = 9230)

$ErrorActionPreference = 'Stop'

try {
    $targets = @(Invoke-RestMethod -Uri "http://127.0.0.1:$Port/json/list" -TimeoutSec 4)
} catch {
    Write-Host "CDP active      : False"
    Write-Host "RTL active      : False"
    Write-Host "Reason          : ChatGPT is not running with CDP on port $Port"
    exit 0
}

$target = $targets | Where-Object {
    $_.type -eq 'page' -and $_.url -eq 'app://-/index.html'
} | Select-Object -First 1

if (-not $target) {
    Write-Host "CDP active      : True"
    Write-Host "RTL active      : Unknown"
    Write-Host "Reason          : Main renderer not found"
    exit 0
}

$ws = New-Object System.Net.WebSockets.ClientWebSocket
$cts = New-Object System.Threading.CancellationTokenSource

try {
    $null = $ws.ConnectAsync([Uri]$target.webSocketDebuggerUrl, $cts.Token).GetAwaiter().GetResult()

    $expr = @"
(() => JSON.stringify({
  active: !!window.__chatgptRtlFinal,
  version: window.__chatgptRtlFinal?.version || null,
  tagged: document.querySelectorAll('[data-chatgpt-rtl-final]').length,
  fontLoaded: Array.from(document.fonts || []).some(f => f.family === 'ChatGPT Vazirmatn'),
  rootFound: !!window.__chatgptRtlFinal?.findConversationRoot?.()
}))()
"@

    $msg = @{
        id = 1
        method = 'Runtime.evaluate'
        params = @{
            expression = $expr
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
            [void]$sb.Append([System.Text.Encoding]::UTF8.GetString($buf,0,$res.Count))
        } while (-not $res.EndOfMessage)

        $obj = $sb.ToString() | ConvertFrom-Json
        if ($obj.id -eq 1) { break }
    }

    $s = $obj.result.result.value | ConvertFrom-Json

    Write-Host "CDP active      : True"
    Write-Host "RTL active      : $($s.active)"
    Write-Host "Version         : $($s.version)"
    Write-Host "Tagged elements : $($s.tagged)"
    Write-Host "Vazirmatn loaded: $($s.fontLoaded)"
    Write-Host "Root found      : $($s.rootFound)"
}
finally {
    try {
        if ($ws.State -eq [System.Net.WebSockets.WebSocketState]::Open) {
            $null = $ws.CloseAsync(
                [System.Net.WebSockets.WebSocketCloseStatus]::NormalClosure,
                'done',
                $cts.Token
            ).GetAwaiter().GetResult()
        }
    } catch {}
    $ws.Dispose()
    $cts.Dispose()
}
