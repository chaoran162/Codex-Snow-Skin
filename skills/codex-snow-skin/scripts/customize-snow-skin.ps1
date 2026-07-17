[CmdletBinding()]
param(
  [string]$ImagePath,
  [switch]$Reset,
  [int]$Port = 9335,
  [switch]$ApplyNow,
  [switch]$NoApply
)

$ErrorActionPreference = 'Stop'
$PortExplicit = $PSBoundParameters.ContainsKey('Port')

if ($ImagePath -and $Reset) { throw 'Choose either -ImagePath or -Reset, not both.' }
if ($ApplyNow -and $NoApply) { throw 'Choose either -ApplyNow or -NoApply, not both.' }

$interactive = -not $ImagePath -and -not $Reset
$stateRoot = Join-Path $env:LOCALAPPDATA 'CodexSnowSkin'
$customImagePath = Join-Path $stateRoot 'custom-background.png'
$installBackupPath = Join-Path $stateRoot 'config.before-snow-skin.toml'
$customizeLog = Join-Path $stateRoot 'customize.log'
$setImageScript = Join-Path $PSScriptRoot 'set-snow-image.ps1'
$startScript = Join-Path $PSScriptRoot 'start-snow-skin.ps1'

function Initialize-SnowSkinForms {
  Add-Type -AssemblyName System.Drawing
  Add-Type -AssemblyName System.Windows.Forms
  [System.Windows.Forms.Application]::EnableVisualStyles()
}

function Show-SnowSkinCustomizer {
  $form = New-Object System.Windows.Forms.Form
  $form.Text = 'Codex Snow Skin'
  $form.ClientSize = New-Object System.Drawing.Size(460, 176)
  $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
  $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
  $form.MaximizeBox = $false
  $form.MinimizeBox = $false
  $form.ShowInTaskbar = $true

  $heading = New-Object System.Windows.Forms.Label
  $heading.Text = 'Customize your Snow Skin background'
  $heading.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 12)
  $heading.AutoSize = $true
  $heading.Location = New-Object System.Drawing.Point(20, 18)
  $form.Controls.Add($heading)

  $status = New-Object System.Windows.Forms.Label
  $status.Text = if (Test-Path -LiteralPath $customImagePath) {
    'Current background: custom local image'
  } else {
    'Current background: bundled snow artwork'
  }
  $status.Font = New-Object System.Drawing.Font('Segoe UI', 9)
  $status.AutoSize = $true
  $status.Location = New-Object System.Drawing.Point(22, 52)
  $form.Controls.Add($status)

  $chooseButton = New-Object System.Windows.Forms.Button
  $chooseButton.Text = 'Choose image...'
  $chooseButton.Size = New-Object System.Drawing.Size(128, 36)
  $chooseButton.Location = New-Object System.Drawing.Point(22, 105)
  $chooseButton.Add_Click({ $form.Tag = 'choose'; $form.Close() })
  $form.Controls.Add($chooseButton)

  $defaultButton = New-Object System.Windows.Forms.Button
  $defaultButton.Text = 'Use default'
  $defaultButton.Size = New-Object System.Drawing.Size(116, 36)
  $defaultButton.Location = New-Object System.Drawing.Point(160, 105)
  $defaultButton.Enabled = Test-Path -LiteralPath $customImagePath
  $defaultButton.Add_Click({ $form.Tag = 'reset'; $form.Close() })
  $form.Controls.Add($defaultButton)

  $cancelButton = New-Object System.Windows.Forms.Button
  $cancelButton.Text = 'Cancel'
  $cancelButton.Size = New-Object System.Drawing.Size(96, 36)
  $cancelButton.Location = New-Object System.Drawing.Point(342, 105)
  $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
  $form.CancelButton = $cancelButton
  $form.Controls.Add($cancelButton)

  $form.AcceptButton = $chooseButton
  [void]$form.ShowDialog()
  $selection = "$($form.Tag)"
  $form.Dispose()
  return $selection
}

function Select-SnowSkinImage {
  $dialog = New-Object System.Windows.Forms.OpenFileDialog
  $dialog.Title = 'Choose a Codex Snow Skin background'
  $dialog.Filter = 'Supported images (*.png;*.jpg;*.jpeg;*.bmp)|*.png;*.jpg;*.jpeg;*.bmp|All files (*.*)|*.*'
  $dialog.CheckFileExists = $true
  $dialog.Multiselect = $false
  $dialog.RestoreDirectory = $true
  $pictures = [Environment]::GetFolderPath('MyPictures')
  if ($pictures) { $dialog.InitialDirectory = $pictures }
  try {
    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { return $null }
    return $dialog.FileName
  } finally {
    $dialog.Dispose()
  }
}

function Show-SnowSkinMessage {
  param(
    [Parameter(Mandatory = $true)][string]$Message,
    [object]$Icon = $null
  )
  if ($null -eq $Icon) { $Icon = [System.Windows.Forms.MessageBoxIcon]::Information }
  [void][System.Windows.Forms.MessageBox]::Show(
    $Message,
    'Codex Snow Skin',
    [System.Windows.Forms.MessageBoxButtons]::OK,
    $Icon
  )
}

try {
  if ($interactive) {
    Initialize-SnowSkinForms
    $selection = Show-SnowSkinCustomizer
    if ($selection -eq 'choose') {
      $ImagePath = Select-SnowSkinImage
      if (-not $ImagePath) { exit 0 }
    } elseif ($selection -eq 'reset') {
      $Reset = $true
    } else {
      exit 0
    }
  }

  if ($Reset) {
    & $setImageScript -Reset
  } else {
    & $setImageScript -ImagePath $ImagePath
  }

  $installed = Test-Path -LiteralPath $installBackupPath -PathType Leaf
  $shouldApply = [bool]$ApplyNow
  if ($interactive -and -not $NoApply -and $installed) {
    $choice = [System.Windows.Forms.MessageBox]::Show(
      'Background saved locally. Apply it now? Codex may need to restart, so save any unfinished input first.',
      'Codex Snow Skin',
      [System.Windows.Forms.MessageBoxButtons]::YesNo,
      [System.Windows.Forms.MessageBoxIcon]::Question
    )
    $shouldApply = $choice -eq [System.Windows.Forms.DialogResult]::Yes
  }

  if ($shouldApply -and -not $installed) {
    throw 'The background was saved, but Snow Skin is not currently installed. Run Install or Update Codex Snow Skin before applying it.'
  }

  if ($shouldApply) {
    if ($PortExplicit) {
      & $startScript -Port $Port -RestartExisting
    } else {
      & $startScript -RestartExisting
    }
  }

  if ($interactive) {
    if ($shouldApply) {
      Show-SnowSkinMessage -Message 'Your background is active.'
    } elseif ($installed) {
      Show-SnowSkinMessage -Message 'Your background was saved locally. It will appear the next time you launch Codex Snow Skin.'
    } else {
      Show-SnowSkinMessage -Message 'Your background was saved locally. Run Install or Update Codex Snow Skin to use it.'
    }
  } else {
    Write-Host 'Snow Skin background customization completed.'
  }
} catch {
  $customizeError = $_
  try {
    New-Item -ItemType Directory -Force -Path $stateRoot | Out-Null
    $logMessage = "[$((Get-Date).ToString('o'))] $($customizeError.Exception.Message)`r`n"
    [System.IO.File]::AppendAllText($customizeLog, $logMessage, [System.Text.UTF8Encoding]::new($false))
  } catch {}
  if ($interactive) {
    if (-not ('System.Windows.Forms.MessageBox' -as [type])) { Initialize-SnowSkinForms }
    Show-SnowSkinMessage -Message "$($customizeError.Exception.Message)`r`n`r`nDetails: $customizeLog" `
      -Icon ([System.Windows.Forms.MessageBoxIcon]::Error)
    exit 1
  }
  throw $customizeError
}
