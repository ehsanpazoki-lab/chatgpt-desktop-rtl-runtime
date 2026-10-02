@echo off
setlocal EnableExtensions
title ChatGPT RTL + Vazirmatn
chcp 65001 >nul

set "ROOT=%~dp0"
set "RUNNER=%ROOT%ChatGPT-RTL-Run.ps1"

if not exist "%RUNNER%" (
  echo.
  echo ERROR: Launcher not found:
  echo   %RUNNER%
  echo.
  pause
  exit /b 10
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%RUNNER%"
set "RC=%ERRORLEVEL%"

echo.
if "%RC%"=="0" (
  echo ChatGPT RTL finished successfully.
  timeout /t 3 /nobreak >nul
) else (
  echo Launcher exited with code %RC%.
  pause
)

exit /b %RC%
