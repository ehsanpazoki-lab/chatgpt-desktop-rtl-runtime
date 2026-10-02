param(
    [int]$Port = 9230,
    [switch]$ForceRestart
)

$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot
$Injector = Join-Path $Root 'Inject-ChatGPT-RTL.ps1'

function Info($m) { Write-Host "[ChatGPT RTL] $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[ChatGPT RTL] $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[ChatGPT RTL] $m" -ForegroundColor Yellow }

if (-not (Test-Path -LiteralPath $Injector)) {
    throw "Injector not found: $Injector"
}

function Test-Cdp {
    param([int]$P)
    try {
        $v = Invoke-RestMethod -Uri "http://127.0.0.1:$P/json/version" -TimeoutSec 2
        return [bool]$v
    } catch {
        return $false
    }
}

if (-not (Test-Cdp -P $Port)) {
    $running = Get-Process ChatGPT -ErrorAction SilentlyContinue

    if ($running) {
        if (-not $ForceRestart) {
            Write-Host ""
            Warn "ChatGPT is running normally, without the RTL debugging port."
            $answer = Read-Host "Close and restart ChatGPT now? [Y/N]"
            if ($answer -notmatch '^(?i)y(es)?$') {
                Write-Host "Cancelled."
                exit 1
            }
        }

        Info "Closing current ChatGPT session..."
        $main = $running | Where-Object { $_.MainWindowHandle -ne 0 }

        foreach ($p in $main) {
            try { $null = $p.CloseMainWindow() } catch {}
        }

        Start-Sleep -Seconds 4

        $still = Get-Process ChatGPT -ErrorAction SilentlyContinue
        if ($still) {
            Warn "Terminating remaining ChatGPT processes."
            $still | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
    }

    Info "Locating unified OpenAI.Codex package..."
    $pkg = Get-AppxPackage OpenAI.Codex |
        Sort-Object Version -Descending |
        Select-Object -First 1

    if (-not $pkg) { throw "OpenAI.Codex package was not found." }

    $manifest = Get-AppxPackageManifest $pkg
    $appId = ($manifest.Package.Applications.Application | Select-Object -First 1).Id
    $aumid = "$($pkg.PackageFamilyName)!$appId"

    if (-not ('PackagedAppLauncher.Launcher' -as [type])) {
        Add-Type @"
using System;
using System.Runtime.InteropServices;

namespace PackagedAppLauncher
{
    [Flags]
    public enum ActivateOptions { None = 0 }

    [ComImport]
    [Guid("2e941141-7f97-4756-ba1d-9decde894a3d")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    interface IApplicationActivationManager
    {
        Int32 ActivateApplication(
            [MarshalAs(UnmanagedType.LPWStr)] string appUserModelId,
            [MarshalAs(UnmanagedType.LPWStr)] string arguments,
            ActivateOptions options,
            out UInt32 processId);

        Int32 ActivateForFile(
            [MarshalAs(UnmanagedType.LPWStr)] string appUserModelId,
            IntPtr itemArray,
            [MarshalAs(UnmanagedType.LPWStr)] string verb,
            out UInt32 processId);

        Int32 ActivateForProtocol(
            [MarshalAs(UnmanagedType.LPWStr)] string appUserModelId,
            IntPtr itemArray,
            out UInt32 processId);
    }

    [ComImport]
    [Guid("45BA127D-10A8-46EA-8AB7-56EA9078943C")]
    class ApplicationActivationManager {}

    public static class Launcher
    {
        public static UInt32 Activate(string aumid, string arguments)
        {
            var manager =
                (IApplicationActivationManager)new ApplicationActivationManager();
            try {
                UInt32 processId;
                int hr = manager.ActivateApplication(
                    aumid, arguments, ActivateOptions.None, out processId);
                if (hr < 0) Marshal.ThrowExceptionForHR(hr);
                return processId;
            }
            finally {
                Marshal.ReleaseComObject(manager);
            }
        }
    }
}
"@
    }

    $debugArgs = "--remote-debugging-address=127.0.0.1 --remote-debugging-port=$Port"

    Info "Starting ChatGPT with local CDP on port $Port..."
    $startedProcessId = [PackagedAppLauncher.Launcher]::Activate(
        $aumid, $debugArgs
    )
    Info "Activation returned process ID $startedProcessId."
}
else {
    Ok "Existing ChatGPT CDP session found on 127.0.0.1:$Port."
}

Info "Applying ChatGPT RTL Final v3.1..."
& powershell.exe -NoProfile -ExecutionPolicy Bypass `
    -File $Injector `
    -Port $Port `
    -TargetWaitSeconds 60

if ($LASTEXITCODE -ne 0) {
    throw "RTL injector exited with code $LASTEXITCODE."
}

Write-Host ""
Ok "ChatGPT RTL + Vazirmatn Final v3.1 is active."
