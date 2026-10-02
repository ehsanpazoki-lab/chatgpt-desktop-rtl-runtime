param()

$ErrorActionPreference = 'SilentlyContinue'

$Root = $PSScriptRoot
$PidFile = Join-Path $Root 'chatgpt-rtl-tray.pid'

if (-not (Test-Path -LiteralPath $PidFile)) {
    exit 0
}

$rawPid = (Get-Content -LiteralPath $PidFile -Raw).Trim()
$trayPid = 0

if (-not [int]::TryParse($rawPid, [ref]$trayPid)) {
    Remove-Item -LiteralPath $PidFile -Force -ErrorAction SilentlyContinue
    exit 0
}

$proc = Get-CimInstance Win32_Process -Filter "ProcessId=$trayPid" -ErrorAction SilentlyContinue

if ($proc -and $proc.CommandLine -match 'ChatGPT-RTL-Tray\.ps1') {
    Stop-Process -Id $trayPid -Force -ErrorAction SilentlyContinue
}

Remove-Item -LiteralPath $PidFile -Force -ErrorAction SilentlyContinue
