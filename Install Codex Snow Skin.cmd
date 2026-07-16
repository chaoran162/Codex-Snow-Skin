@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0skills\codex-snow-skin\scripts\setup-snow-skin.ps1"
exit /b %errorlevel%
