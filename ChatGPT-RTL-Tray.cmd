@echo off
setlocal EnableExtensions
start "" powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0ChatGPT-RTL-Tray.ps1"
exit /b 0
