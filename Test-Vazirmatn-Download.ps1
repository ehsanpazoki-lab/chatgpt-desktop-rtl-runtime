param()

$ErrorActionPreference = 'Stop'
$Helper = Join-Path $PSScriptRoot 'scripts\\Ensure-Vazirmatn.ps1'
if (-not (Test-Path -LiteralPath $Helper)) { throw "Font helper not found: $Helper" }
$path = (& $Helper | Select-Object -Last 1)
if (-not $path -or -not (Test-Path -LiteralPath $path)) { throw "Font helper did not return an existing file." }
$bytes = [System.IO.File]::ReadAllBytes($path)
if ($bytes.Length -lt 100000) { throw "Font file is unexpectedly small: $($bytes.Length) bytes." }
if (-not ($bytes[0] -eq 0x77 -and $bytes[1] -eq 0x4F -and $bytes[2] -eq 0x46 -and $bytes[3] -eq 0x32)) { throw "Font file does not have WOFF2 magic bytes." }
Write-Host "PASS" -ForegroundColor Green
Write-Host "Path  : $path"
Write-Host "Bytes : $($bytes.Length)"
