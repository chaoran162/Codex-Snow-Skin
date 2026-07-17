[CmdletBinding()]
param(
  [int]$Port = 9335,
  [switch]$NoShortcuts
)

$ErrorActionPreference = 'Stop'
$PortExplicit = $PSBoundParameters.ContainsKey('Port')
$SkillRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'common-windows.ps1')

$operationLock = Enter-DreamSkinOperationLock
try {
  Assert-DreamSkinPort -Port $Port
  $null = Get-DreamSkinNodeRuntime
  $registeredInstalls = @(Get-DreamSkinRegisteredCodexInstalls)
  if ($registeredInstalls.Count -eq 0) {
    throw 'The official OpenAI.Codex Store package is not installed or its identity cannot be validated.'
  }
  foreach ($registeredCodex in $registeredInstalls) {
    if ((Get-DreamSkinCodexProcesses -Codex $registeredCodex).Count -gt 0) {
      throw 'Close Codex before installing Snow Skin so config.toml cannot change during the transaction.'
    }
  }

  $StateRoot = Join-Path $env:LOCALAPPDATA 'CodexSnowSkin'
  $StatePath = Join-Path $StateRoot 'state.json'
  $existingState = Read-DreamSkinState -Path $StatePath
  $savedPathCandidate = Get-DreamSkinCodexStatePathCandidate -State $existingState
  $savedCodex = Resolve-DreamSkinCodexInstallFromState -State $existingState -RegisteredInstalls $registeredInstalls
  if ($null -ne $savedPathCandidate -and $null -eq $savedCodex -and
    (Get-DreamSkinCodexProcesses -Codex $savedPathCandidate).Count -gt 0) {
    throw 'The saved Codex path is still running but no longer matches a registered Store package. Close it manually before installing.'
  }
  New-Item -ItemType Directory -Force -Path $StateRoot | Out-Null
  $ConfigPath = Join-Path $HOME '.codex\config.toml'
  $BackupPath = Join-Path $StateRoot 'config.before-snow-skin.toml'
  Install-DreamSkinBaseTheme -ConfigPath $ConfigPath -BackupPath $BackupPath

  if (-not $NoShortcuts) {
    $shell = New-Object -ComObject WScript.Shell
    $desktop = [Environment]::GetFolderPath('Desktop')
    $startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
    $powershell = (Get-Command powershell.exe -ErrorAction Stop).Source
    $startScript = Join-Path $PSScriptRoot 'start-snow-skin.ps1'
    $customizeScript = Join-Path $PSScriptRoot 'customize-snow-skin.ps1'
    $restoreScript = Join-Path $PSScriptRoot 'restore-snow-skin.ps1'
    $iconPath = $registeredInstalls[0].Executable
    $portArgument = if ($PortExplicit) { " -Port $Port" } else { '' }

    foreach ($folder in @($desktop, $startMenu)) {
      $shortcut = $shell.CreateShortcut((Join-Path $folder 'Codex Snow Skin.lnk'))
      $shortcut.TargetPath = $powershell
      $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$startScript`"$portArgument -PromptRestart"
      $shortcut.WorkingDirectory = $SkillRoot
      $shortcut.Description = 'Launch the official Codex app with Codex Snow Skin'
      $shortcut.IconLocation = "$iconPath,0"
      $shortcut.Save()

      $customize = $shell.CreateShortcut((Join-Path $folder 'Codex Snow Skin - Customize.lnk'))
      $customize.TargetPath = $powershell
      $customize.Arguments = "-NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$customizeScript`"$portArgument"
      $customize.WorkingDirectory = $SkillRoot
      $customize.Description = 'Choose a private local background for Codex Snow Skin'
      $customize.IconLocation = "$iconPath,0"
      $customize.Save()
    }

    $restore = $shell.CreateShortcut((Join-Path $desktop 'Codex Snow Skin - Restore.lnk'))
    $restore.TargetPath = $powershell
    $restore.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$restoreScript`"$portArgument -RestoreBaseTheme -PromptRestart"
    $restore.WorkingDirectory = $SkillRoot
    $restore.Description = 'Restore the official Codex appearance and close the CDP session'
    $restore.IconLocation = "$iconPath,0"
    $restore.Save()
  }

  if ($NoShortcuts) {
    Write-Host 'Codex Snow Skin base theme installed. Run start-snow-skin.ps1 to launch it.'
  } else {
    Write-Host 'Codex Snow Skin installed with launch, customize, and restore shortcuts.'
  }
} finally {
  Exit-DreamSkinOperationLock -Mutex $operationLock
}
