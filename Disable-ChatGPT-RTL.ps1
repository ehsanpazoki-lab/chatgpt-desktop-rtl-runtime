param([int]$Port = 9230)

$ErrorActionPreference = 'Stop'

function Info($m) { Write-Host "[ChatGPT RTL Disable] $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[ChatGPT RTL Disable] $m" -ForegroundColor Green }

try {
    $targets = @(Invoke-RestMethod -Uri "http://127.0.0.1:$Port/json/list" -TimeoutSec 4)
} catch {
    Write-Host "No ChatGPT CDP session is active on 127.0.0.1:$Port."
    Write-Host "If ChatGPT was fully closed, RTL is already gone."
    exit 0
}

$target = $targets | Where-Object {
    $_.type -eq 'page' -and $_.url -eq 'app://-/index.html'
} | Select-Object -First 1

if (-not $target) {
    throw "Main ChatGPT renderer was not found."
}

$ws = New-Object System.Net.WebSockets.ClientWebSocket
$cts = New-Object System.Threading.CancellationTokenSource

try {
    $null = $ws.ConnectAsync([Uri]$target.webSocketDebuggerUrl, $cts.Token).GetAwaiter().GetResult()

    $expr = @"
(() => {
  const state = window.__chatgptRtlFinal;
  if (!state || typeof state.remove !== 'function') {
    return 'No active Final RTL engine found';
  }
  return state.remove();
})()
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

    $value = $obj.result.result.value
    Ok $value
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
