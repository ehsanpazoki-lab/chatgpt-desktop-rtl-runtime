@echo off
setlocal EnableExtensions
chcp 65001 >nul

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Prepare-Installer.ps1"
if errorlevel 1 exit /b %errorlevel%

set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" (
  echo Inno Setup 6 was not found:
  echo   %ISCC%
  echo Install Inno Setup 6, then run this file again.
  pause
  exit /b 2
)

"%ISCC%" "%~dp0ChatGPT-RTL.iss"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" pause
exit /b %RC%
