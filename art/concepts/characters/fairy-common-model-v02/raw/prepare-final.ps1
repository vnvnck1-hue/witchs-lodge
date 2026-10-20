param(
 [Parameter(Mandatory=$true)][string]$Source,
 [Parameter(Mandatory=$true)][double]$CrownY,
 [Parameter(Mandatory=$true)][double]$SoleY
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$outputDirectory = Split-Path -Parent $PSScriptRoot
$sourcePath = (Resolve-Path -LiteralPath $Source).Path
if (-not $sourcePath.StartsWith($outputDirectory + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Source must be inside the fairy output directory.' }
$sourceImage = [Drawing.Bitmap]::new($sourcePath)
$scale = 1112.0 / ($SoleY - $CrownY)
$finalImage = [Drawing.Bitmap]::new(1536,1536,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [Drawing.Graphics]::FromImage($finalImage)
$graphics.Clear([Drawing.Color]::Transparent)
$graphics.SetClip([Drawing.Rectangle]::new(16,16,1504,1504))
$graphics.CompositingMode = [Drawing.Drawing2D.CompositingMode]::SourceCopy
$graphics.CompositingQuality = [Drawing.Drawing2D.CompositingQuality]::HighQuality
$graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$drawWidth = $sourceImage.Width * $scale
$drawHeight = $sourceImage.Height * $scale
$offsetX = (1536 - $drawWidth)/2
$offsetY = 218 - $CrownY*$scale
$destination = [Drawing.RectangleF]::new([single]$offsetX,[single]$offsetY,[single]$drawWidth,[single]$drawHeight)
$graphics.DrawImage($sourceImage,$destination)
$graphics.Dispose()
$finalPath = Join-Path $outputDirectory 'fairy-common-3q-v02.png'
$finalImage.Save($finalPath,[Drawing.Imaging.ImageFormat]::Png)
$preview = [Drawing.Bitmap]::new(3072,1600,[Drawing.Imaging.PixelFormat]::Format24bppRgb)
$canvas = [Drawing.Graphics]::FromImage($preview)
$canvas.Clear([Drawing.Color]::FromArgb(231,233,239))
$nibPath = Join-Path (Split-Path -Parent $outputDirectory) 'goblin-nib-model-v03/nib-3q-v03.png'
$nibImage = [Drawing.Bitmap]::new($nibPath)
$canvas.DrawImage($nibImage,0,0,1536,1536)
$canvas.DrawImage($finalImage,1536,0,1536,1536)
$font = [Drawing.Font]::new('Arial',34)
$canvas.DrawString('Nib v03',[Drawing.Font]$font,[Drawing.Brushes]::Black,50,1500)
$canvas.DrawString('Fairy common v02',[Drawing.Font]$font,[Drawing.Brushes]::Black,1586,1500)
$pen=[Drawing.Pen]::new([Drawing.Color]::FromArgb(100,45,70,110),2)
foreach($lineY in @(218,1330)){$canvas.DrawLine($pen,0,$lineY,3072,$lineY)}
$canvas.Dispose()
$preview.Save((Join-Path $PSScriptRoot 'nib-v03-comparison.png'),[Drawing.Imaging.ImageFormat]::Png)
$preview.Dispose(); $nibImage.Dispose(); $font.Dispose(); $pen.Dispose(); $finalImage.Dispose(); $sourceImage.Dispose()
[pscustomobject]@{Source=$Source;Scale=$scale;OffsetX=$offsetX;OffsetY=$offsetY;CrownY=218;SoleY=1330;Output=$finalPath;Operation='Uniform scaling and canvas translation; preserve character alpha; clear empty outer 16px canvas margin of stray pixels. No anatomical deformation.'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'preparation.json') -Encoding UTF8
