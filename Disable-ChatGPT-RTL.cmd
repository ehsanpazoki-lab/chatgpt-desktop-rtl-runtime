@echo off
setlocal
title Disable ChatGPT RTL
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Disable-ChatGPT-RTL.ps1"
echo.
pause
