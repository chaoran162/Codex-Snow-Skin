[CmdletBinding()]
param([int]$Port = 9335)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common-windows.ps1')

Assert-DreamSkinPort -Port $Port
$null = Get-DreamSkinNodeRuntime
$null = Get-DreamSkinCodexInstall

$desktop = [Environment]::GetFolderPath('Desktop')
if (-not $desktop) { throw 'The Windows Desktop folder could not be resolved.' }
$powershell = (Get-Command powershell.exe -ErrorAction Stop).Source
$setupScript = Join-Path $PSScriptRoot 'setup-snow-skin.ps1'
$shortcutPath = Join-Path $desktop 'Install or Update Codex Snow Skin.lnk'
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $powershell
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$setupScript`" -Port $Port"
$shortcut.WorkingDirectory = Split-Path -Parent $PSScriptRoot
$shortcut.Description = 'Install or update Codex Snow Skin safely'
$shortcut.Save()

Write-Host "Created: $shortcutPath"
Write-Host 'Finish the current Codex task, then double-click that shortcut.'
