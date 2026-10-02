@echo off
setlocal EnableExtensions
title ChatGPT RTL Status
chcp 65001 >nul

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Status-ChatGPT-RTL.ps1"
set "RC=%ERRORLEVEL%"

echo.
pause
exit /b %RC%
