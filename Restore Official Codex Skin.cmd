@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0skills\codex-snow-skin\scripts\restore-snow-skin.ps1" -RestoreBaseTheme -PromptRestart -Uninstall
if errorlevel 1 pause
exit /b %errorlevel%
