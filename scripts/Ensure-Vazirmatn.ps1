param(
    [string]$AssetDir = (Join-Path $PSScriptRoot '..\\assets')
)

$ErrorActionPreference = 'Stop'

$FontVersion = '33.0.3'
$FontUrl = "https://cdn.jsdelivr.net/npm/vazirmatn@$FontVersion/fonts/webfonts/Vazirmatn%5Bwght%5D.woff2"
$FontPath = Join-Path $AssetDir 'Vazirmatn.woff2'
$TempPath = Join-Path $env:TEMP ("vazirmatn-" + [Guid]::NewGuid().ToString('N') + ".woff2")

New-Item -ItemType Directory -Path $AssetDir -Force | Out-Null

function Test-Woff2([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    try { $bytes = [System.IO.File]::ReadAllBytes($Path) } catch { return $false }
    if ($bytes.Length -lt 100000) { return $false }
    return ($bytes[0] -eq 0x77 -and $bytes[1] -eq 0x4F -and $bytes[2] -eq 0x46 -and $bytes[3] -eq 0x32)
}

if (Test-Woff2 $FontPath) {
    Write-Host "[font] Vazirmatn already present."
    Write-Output ([System.IO.Path]::GetFullPath($FontPath))
    exit 0
}

Write-Host "[font] Downloading Vazirmatn $FontVersion..."

try {
    $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curl) {
        & $curl.Source -fL --retry 2 --connect-timeout 15 -o $TempPath $FontUrl
        if ($LASTEXITCODE -ne 0) { throw "curl.exe failed with exit code $LASTEXITCODE." }
    } else {
        Invoke-WebRequest -UseBasicParsing -Uri $FontUrl -OutFile $TempPath
    }

    if (-not (Test-Woff2 $TempPath)) {
        throw "Downloaded file is not a valid-looking WOFF2 font."
    }

    Move-Item -LiteralPath $TempPath -Destination $FontPath -Force
}
finally {
    Remove-Item -LiteralPath $TempPath -Force -ErrorAction SilentlyContinue
}

Write-Host "[font] Saved: $FontPath"
Write-Output ([System.IO.Path]::GetFullPath($FontPath))
