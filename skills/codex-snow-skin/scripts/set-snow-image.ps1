[CmdletBinding()]
param(
  [string]$ImagePath,
  [switch]$Reset
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'config-utf8.ps1')

if ($Reset -eq [bool]$ImagePath) {
  throw 'Provide exactly one action: -ImagePath <file> or -Reset.'
}

$stateRoot = Join-Path $env:LOCALAPPDATA 'CodexSnowSkin'
$outputPath = Join-Path $stateRoot 'custom-background.png'
if ($Reset) {
  Remove-Item -LiteralPath $outputPath -Force -ErrorAction SilentlyContinue
  Write-Host 'Custom background removed. Relaunch with Codex Snow Skin to use the default art.'
  exit 0
}

$sourcePath = [System.IO.Path]::GetFullPath($ImagePath)
if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Image not found: $sourcePath" }
$sourceInfo = Get-Item -LiteralPath $sourcePath
if ($sourceInfo.Length -gt 50MB) { throw 'The source image exceeds the 50 MB safety limit.' }

Add-Type -AssemblyName System.Drawing
$source = $null
$canvas = $null
$graphics = $null
$stream = $null
try {
  $source = [System.Drawing.Image]::FromFile($sourcePath)
  if ($source.Width -lt 320 -or $source.Height -lt 180 -or
    ([long]$source.Width * [long]$source.Height) -gt 100000000) {
    throw 'Use an image between 320x180 and 100 megapixels.'
  }

  $targetWidth = 1920
  $targetHeight = 1080
  $scale = [Math]::Max($targetWidth / $source.Width, $targetHeight / $source.Height)
  $drawWidth = [int][Math]::Ceiling($source.Width * $scale)
  $drawHeight = [int][Math]::Ceiling($source.Height * $scale)
  $offsetX = [int][Math]::Floor(($targetWidth - $drawWidth) / 2)
  $offsetY = [int][Math]::Floor(($targetHeight - $drawHeight) / 2)

  $canvas = [System.Drawing.Bitmap]::new($targetWidth, $targetHeight)
  $graphics = [System.Drawing.Graphics]::FromImage($canvas)
  $graphics.Clear([System.Drawing.Color]::White)
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $graphics.DrawImage($source, $offsetX, $offsetY, $drawWidth, $drawHeight)

  $stream = [System.IO.MemoryStream]::new()
  $canvas.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
  Write-DreamSkinBytesAtomically -Path $outputPath -Bytes $stream.ToArray()
} finally {
  if ($stream) { $stream.Dispose() }
  if ($graphics) { $graphics.Dispose() }
  if ($canvas) { $canvas.Dispose() }
  if ($source) { $source.Dispose() }
}

Write-Host "Custom background saved locally: $outputPath"
Write-Host 'Relaunch with the Codex Snow Skin shortcut to apply it.'
