@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0skills\codex-snow-skin\scripts\restore-snow-skin.ps1" -RestoreBaseTheme -PromptRestart -Uninstall
set "EXIT_CODE=%errorlevel%"
if not "%EXIT_CODE%"=="0" pause
exit /b %EXIT_CODE%
