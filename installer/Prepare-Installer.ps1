param()

$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Stage = Join-Path $PSScriptRoot 'staging'
$Assets = Join-Path $Stage 'assets'
$FontHelper = Join-Path $Root 'scripts\Ensure-Vazirmatn.ps1'

if (Test-Path -LiteralPath $Stage) {
    Remove-Item -LiteralPath $Stage -Recurse -Force
}
New-Item -ItemType Directory -Path $Assets -Force | Out-Null

Write-Host "[installer] Preparing pinned Vazirmatn..."
$font = (& $FontHelper -AssetDir $Assets | Select-Object -Last 1)
if (-not $font -or -not (Test-Path -LiteralPath $font)) {
    throw "Could not prepare Vazirmatn for installer."
}

$bytes = [System.IO.File]::ReadAllBytes($font)
if ($bytes.Length -lt 100000 -or
    $bytes[0] -ne 0x77 -or $bytes[1] -ne 0x4F -or
    $bytes[2] -ne 0x46 -or $bytes[3] -ne 0x32) {
    throw "Prepared font is not valid-looking WOFF2."
}

Write-Host "[installer] Staging ready: $Stage" -ForegroundColor Green
