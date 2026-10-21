Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$assetDir = Split-Path -Parent $PSScriptRoot
$referenceDir = Join-Path (Split-Path -Parent $assetDir) 'reference-composition-v01'
$names = @('01-story-edge','02-winter-inn-window')

function New-Canvas([int]$width, [int]$height) {
    $bitmap = New-Object System.Drawing.Bitmap($width, $height, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb))
    return ,$bitmap
}
function New-Graphics($bitmap) {
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    return $graphics
}

# Only resize the generated raster. Do not crop, repaint or move any UI element.
foreach ($name in $names) {
    $source = [System.Drawing.Image]::FromFile((Join-Path $PSScriptRoot "$name-generated.png"))
    $canvas = New-Canvas 1920 1080
    $graphics = New-Graphics $canvas
    $graphics.DrawImage($source, [System.Drawing.Rectangle]::new(0,0,1920,1080))
    $canvas.Save((Join-Path $assetDir "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $canvas.Dispose()
    $source.Dispose()
}

# Full-resolution four-up: original 01 / new 01; original 02 / new 02.
$sheet = New-Canvas 3840 2160
$graphics = New-Graphics $sheet
for ($row = 0; $row -lt 2; $row++) {
    $name = $names[$row]
    $original = [System.Drawing.Image]::FromFile((Join-Path $referenceDir "$name.png"))
    $final = [System.Drawing.Image]::FromFile((Join-Path $assetDir "$name.png"))
    $graphics.DrawImage($original, [System.Drawing.Rectangle]::new(0,($row*1080),1920,1080))
    $graphics.DrawImage($final, [System.Drawing.Rectangle]::new(1920,($row*1080),1920,1080))
    $original.Dispose()
    $final.Dispose()
}
$sheet.Save((Join-Path $assetDir 'sheet.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$sheet.Dispose()

$records = foreach ($relative in @('01-story-edge.png','02-winter-inn-window.png','sheet.png','drafts/01-story-edge-generated.png','drafts/02-winter-inn-window-generated.png')) {
    $path = Join-Path $assetDir $relative
    $image = [System.Drawing.Image]::FromFile($path)
    $record = [ordered]@{file=$relative; width=$image.Width; height=$image.Height; bytes=(Get-Item -LiteralPath $path).Length; sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()}
    $image.Dispose()
    $record
}
$sources = foreach ($name in $names) {
    $path = Join-Path $referenceDir "$name.png"
    [ordered]@{file="../reference-composition-v01/$name.png"; sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()}
}
$manifest = [ordered]@{date='2026-10-21'; generator='built-in image_gen'; output_mode='RGB opaque PNG'; postprocess='High-quality bicubic resize to 1920x1080; no crop; no UI re-typesetting'; images=@($records); references=@($sources)}
[System.IO.File]::WriteAllText((Join-Path $assetDir 'manifest.json'), ($manifest | ConvertTo-Json -Depth 6), [System.Text.UTF8Encoding]::new($false))
Write-Output ($records | ConvertTo-Json -Depth 4)
