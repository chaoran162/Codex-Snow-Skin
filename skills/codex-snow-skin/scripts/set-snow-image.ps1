[CmdletBinding()]
param(
  [string]$ImagePath,
  [switch]$Reset
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common-windows.ps1')

if ($Reset -eq [bool]$ImagePath) {
  throw 'Provide exactly one action: -ImagePath <file> or -Reset.'
}

$stateRoot = Join-Path $env:LOCALAPPDATA 'CodexSnowSkin'
$outputPath = Join-Path $stateRoot 'custom-background.png'
Add-Type -AssemblyName System.Drawing

function Set-DreamSkinImageOrientation {
  param([Parameter(Mandatory = $true)][System.Drawing.Image]$Image)

  $orientation = $null
  try {
    if ($Image.PropertyIdList -contains 0x0112) {
      $property = $Image.GetPropertyItem(0x0112)
      if ($property.Value.Length -ge 2) { $orientation = [BitConverter]::ToUInt16($property.Value, 0) }
    }
  } catch {
    $orientation = $null
  }

  $rotation = switch ($orientation) {
    2 { [System.Drawing.RotateFlipType]::RotateNoneFlipX }
    3 { [System.Drawing.RotateFlipType]::Rotate180FlipNone }
    4 { [System.Drawing.RotateFlipType]::Rotate180FlipX }
    5 { [System.Drawing.RotateFlipType]::Rotate90FlipX }
    6 { [System.Drawing.RotateFlipType]::Rotate90FlipNone }
    7 { [System.Drawing.RotateFlipType]::Rotate270FlipX }
    8 { [System.Drawing.RotateFlipType]::Rotate270FlipNone }
    default { [System.Drawing.RotateFlipType]::RotateNoneFlipNone }
  }
  if ($rotation -ne [System.Drawing.RotateFlipType]::RotateNoneFlipNone) {
    $Image.RotateFlip($rotation)
  }
}

$operationLock = Enter-DreamSkinOperationLock
try {
  if ($Reset) {
    if (Test-Path -LiteralPath $outputPath) {
      Remove-Item -LiteralPath $outputPath -Force -ErrorAction Stop
    }
    Write-Host 'Custom background removed. Reapply or relaunch Snow Skin to use the default art.'
    return
  }

  $sourcePath = [System.IO.Path]::GetFullPath($ImagePath)
  if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) { throw "Image not found: $sourcePath" }
  $sourceInfo = Get-Item -LiteralPath $sourcePath
  if ($sourceInfo.Length -eq 0) { throw 'The selected image is empty.' }
  if ($sourceInfo.Length -gt 50MB) { throw 'The selected image exceeds the 50 MB safety limit.' }

  $fileStream = $null
  $source = $null
  $canvas = $null
  $graphics = $null
  $outputStream = $null
  try {
    $fileStream = [System.IO.File]::Open(
      $sourcePath,
      [System.IO.FileMode]::Open,
      [System.IO.FileAccess]::Read,
      [System.IO.FileShare]::Read
    )
    try {
      $source = [System.Drawing.Image]::FromStream($fileStream, $true, $true)
    } catch {
      throw 'The selected file is not a supported or valid Windows image. Use PNG, JPEG, or BMP.'
    }

    Set-DreamSkinImageOrientation -Image $source
    $pixelCount = [long]$source.Width * [long]$source.Height
    if ($source.Width -lt 320 -or $source.Height -lt 180) {
      throw "The selected image is too small ($($source.Width)x$($source.Height)). Use at least 320x180."
    }
    if ($pixelCount -gt 40000000) {
      throw "The selected image is too large ($($source.Width)x$($source.Height)). Use at most 40 megapixels."
    }

    $targetWidth = 1920
    $targetHeight = 1080
    $scale = [Math]::Max($targetWidth / $source.Width, $targetHeight / $source.Height)
    $drawWidth = [int][Math]::Ceiling($source.Width * $scale)
    $drawHeight = [int][Math]::Ceiling($source.Height * $scale)
    $offsetX = [int][Math]::Floor(($targetWidth - $drawWidth) / 2)
    $offsetY = [int][Math]::Floor(($targetHeight - $drawHeight) / 2)

    $canvas = [System.Drawing.Bitmap]::new(
      $targetWidth,
      $targetHeight,
      [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    $graphics.Clear([System.Drawing.Color]::White)
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.DrawImage($source, $offsetX, $offsetY, $drawWidth, $drawHeight)

    $outputStream = [System.IO.MemoryStream]::new()
    $canvas.Save($outputStream, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-DreamSkinBytesAtomically -Path $outputPath -Bytes $outputStream.ToArray()
  } finally {
    if ($outputStream) { $outputStream.Dispose() }
    if ($graphics) { $graphics.Dispose() }
    if ($canvas) { $canvas.Dispose() }
    if ($source) { $source.Dispose() }
    if ($fileStream) { $fileStream.Dispose() }
  }

  Write-Host "Custom background saved locally: $outputPath"
  Write-Host 'Reapply or relaunch Snow Skin to use it.'
} finally {
  Exit-DreamSkinOperationLock -Mutex $operationLock
}
