[CmdletBinding()]
param(
  [int]$Port = 9335,
  [switch]$NoPause,
  [switch]$RestartWithoutPrompt
)

$ErrorActionPreference = 'Stop'
$PortExplicit = $PSBoundParameters.ContainsKey('Port')
. (Join-Path $PSScriptRoot 'common-windows.ps1')

function Wait-SnowSkinConsole {
  if (-not $NoPause) { [void](Read-Host 'Press Enter to close') }
}

$stateRoot = Join-Path $env:LOCALAPPDATA 'CodexSnowSkin'
New-Item -ItemType Directory -Force -Path $stateRoot | Out-Null
$setupLog = Join-Path $stateRoot 'setup.log'
$transcriptStarted = $false
try {
  Start-Transcript -LiteralPath $setupLog -Append -Force | Out-Null
  $transcriptStarted = $true
  Write-Host "Snow Skin setup started at $((Get-Date).ToString('o'))."
  Assert-DreamSkinPort -Port $Port
  $legacyState = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin\state.json'
  if (Test-Path -LiteralPath $legacyState) {
    throw 'Codex Dream Skin is still active. Restore it first so the two injectors cannot conflict.'
  }

  $node = Get-DreamSkinNodeRuntime
  $codex = Get-DreamSkinCodexInstall
  $running = (Get-DreamSkinCodexProcesses -Codex $codex).Count -gt 0
  if ($running) {
    $approved = [bool]$RestartWithoutPrompt
    if (-not $approved) {
      $approved = Confirm-DreamSkinRestart -Message 'Snow Skin setup must close Codex once. Unsaved input may be lost. Continue?'
    }
    if (-not $approved) {
      Write-Host 'Setup cancelled. Codex was not changed.'
      Wait-SnowSkinConsole
      exit 0
    }
    Stop-DreamSkinCodex -Codex $codex -AllowForce
  }

  Write-Host "Using Node.js $($node.Version) from $($node.Source)."
  $installArguments = @{}
  $startArguments = @{}
  if ($PortExplicit) {
    $installArguments.Port = $Port
    $startArguments.Port = $Port
  }
  & (Join-Path $PSScriptRoot 'install-snow-skin.ps1') @installArguments
  & (Join-Path $PSScriptRoot 'start-snow-skin.ps1') @startArguments
  Write-Host 'Setup completed. Use the Codex Snow Skin shortcut from now on.' -ForegroundColor Green
  if (-not $NoPause) { Start-Sleep -Seconds 3 }
} catch {
  Write-Host "Setup failed: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "Setup log: $setupLog"
  Wait-SnowSkinConsole
  exit 1
} finally {
  if ($transcriptStarted) { try { Stop-Transcript | Out-Null } catch {} }
}
