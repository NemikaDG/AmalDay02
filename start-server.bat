@echo off
cd /d "%~dp0"
echo Starting local wedding invitation server...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve.ps1" -Port 8080
pause
