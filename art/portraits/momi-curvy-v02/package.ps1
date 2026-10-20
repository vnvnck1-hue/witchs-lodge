param([string]$ProjectRoot=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$records=@()
foreach($pose in @('base','shy')) {
  $source=Join-Path $PSScriptRoot "sources/momi-$pose-generated.png"
  $sourceImage=[System.Drawing.Bitmap]::new($source)
  $image=[System.Drawing.Bitmap]::new(1122,1402,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $graphics=[System.Drawing.Graphics]::FromImage($image)
  try {
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.CompositingMode=[System.Drawing.Drawing2D.CompositingMode]::SourceCopy
    $graphics.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    # Uniformly fit the ENTIRE generated canvas, preserving alpha, anatomy and props.
    $scale=[Math]::Min(984.0/$sourceImage.Width,1230.0/$sourceImage.Height)
    $width=[int][Math]::Floor($sourceImage.Width*$scale); $height=[int][Math]::Floor($sourceImage.Height*$scale)
    $left=[int][Math]::Floor((1122-$width)/2);$top=[int][Math]::Floor((1402-$height)/2)
    $graphics.DrawImage($sourceImage,[System.Drawing.Rectangle]::new($left,$top,$width,$height),0,0,$sourceImage.Width,$sourceImage.Height,[System.Drawing.GraphicsUnit]::Pixel)
    $path=Join-Path $PSScriptRoot "momi-$pose.png"
    $image.Save($path,[System.Drawing.Imaging.ImageFormat]::Png)
  } finally {$graphics.Dispose();$sourceImage.Dispose();$image.Dispose()}
  $header=[IO.File]::ReadAllBytes($path)
  if($header[25] -ne 6) {throw 'Portrait must be RGBA PNG'}
  $records += [ordered]@{pose=$pose;path="art/portraits/momi-curvy-v02/momi-$pose.png";width=1122;height=1402;mode='RGBA';sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash;sourceSha256=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash}
}
& (Join-Path $ProjectRoot 'art/portraits/card-style-v01/verify-assets.ps1') -Directory $PSScriptRoot
$alpha=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'alpha-verification.json') -Raw | ConvertFrom-Json
if($alpha.Count -ne 2) {throw 'Expected exactly two portrait PNG files'}
foreach($result in $alpha) {
  if($result.width -ne 1122 -or $result.height -ne 1402 -or $result.margins[0] -lt 68 -or $result.margins[2] -lt 68 -or $result.margins[1] -lt 85 -or $result.margins[3] -lt 85 -or $result.edge_alpha_max -gt 8 -or $result.clear_fraction -lt 0.1 -or $result.opaque_fraction -le 0) {throw "Portrait alpha/margin check failed: $($result.file)"}
}
$runtime=Join-Path $ProjectRoot 'godot/assets/portraits/guest_momi_cutout.png'
$backup=Join-Path $PSScriptRoot 'before/guest_momi_cutout.png'
if(-not (Test-Path -LiteralPath $backup)) {Copy-Item -LiteralPath $runtime -Destination $backup}
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'momi-base.png') -Destination $runtime -Force
$runtimeHash=(Get-FileHash -LiteralPath $runtime -Algorithm SHA256).Hash
if($runtimeHash -ne $records[0].sha256) {throw 'Runtime copy does not match base portrait'}
[ordered]@{created='2026-10-21';method='built-in image_gen edits; entire source canvas uniformly resized and padded, alpha preserved';prompt='docs/prompts/momi-portrait-curvy-v02.md';files=$records;alphaVerification=$alpha;runtime='godot/assets/portraits/guest_momi_cutout.png';runtimeSha256=$runtimeHash;runtimePose='base';shyPose='separate alternative, no automatic switching';passed=$true} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') -Encoding utf8
Write-Output 'PASS both portraits packaged and verified; default runtime portrait updated'
