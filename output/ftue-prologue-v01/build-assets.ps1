$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$workspace = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$assetDir = Join-Path $workspace 'godot/assets/ui/ftue'
$sourceDir = Join-Path $workspace 'art/concepts/ftue'
$sheetPath = Join-Path $workspace 'godot/screenshots/ftue/asset-sheet.png'
$names = @('prologue_01','prologue_02','prologue_03','prologue_04','title_bg','witch_portrait','witch_locked')

foreach ($name in $names) {
    $portrait = $name.StartsWith('witch_')
    $width = 1920; $height = 1080
    $format = [Drawing.Imaging.PixelFormat]::Format24bppRgb
    if ($portrait) { $width = 512; $height = 768; $format = [Drawing.Imaging.PixelFormat]::Format32bppArgb }
    $source = [Drawing.Image]::FromFile((Join-Path $sourceDir "$name-source.png"))
    try {
        $target = [Drawing.Bitmap]::new($width, $height, $format)
        $graphics = [Drawing.Graphics]::FromImage($target)
        try {
            $graphics.CompositingMode = [Drawing.Drawing2D.CompositingMode]::SourceCopy
            $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            if ($portrait) {
                $graphics.Clear([Drawing.Color]::Transparent)
                # Contain the whole figure and its generated alpha, without stretching.
                $scale = [Math]::Min($width / $source.Width, $height / $source.Height)
                $drawWidth = [int][Math]::Round($source.Width * $scale)
                $drawHeight = [int][Math]::Round($source.Height * $scale)
                $rectangle = [Drawing.Rectangle]::new([int](($width-$drawWidth)/2), [int](($height-$drawHeight)/2), $drawWidth, $drawHeight)
            } else {
                # Cover 16:9 with a centered crop only if the generated aspect differs.
                $scale = [Math]::Max($width / $source.Width, $height / $source.Height)
                $drawWidth = [int][Math]::Round($source.Width * $scale)
                $drawHeight = [int][Math]::Round($source.Height * $scale)
                $rectangle = [Drawing.Rectangle]::new([int](($width-$drawWidth)/2), [int](($height-$drawHeight)/2), $drawWidth, $drawHeight)
            }
            $graphics.DrawImage($source, $rectangle)
        } finally { $graphics.Dispose() }
        # Quantize the image_gen locked silhouette to the requested single ink.
        # Keep its generated alpha and contour, including anti-aliased edges.
        if ($name -eq 'witch_locked') {
            for ($y=0; $y -lt $height; $y++) {
                for ($x=0; $x -lt $width; $x++) {
                    $alpha = $target.GetPixel($x,$y).A
                    if ($alpha -gt 0) { $target.SetPixel($x,$y,[Drawing.Color]::FromArgb($alpha,42,35,70)) }
                }
            }
        }
        try { $target.Save((Join-Path $assetDir "$name.png"), [Drawing.Imaging.ImageFormat]::Png) }
        finally { $target.Dispose() }
    } finally { $source.Dispose() }
}

$sheet = [Drawing.Bitmap]::new(1800, 1260, [Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [Drawing.Graphics]::FromImage($sheet)
$font = [Drawing.Font]::new('Consolas', 20, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
$muted = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(167,157,190))
try {
    $g.Clear([Drawing.Color]::FromArgb(17,14,29))
    $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawString('FTUE PROLOGUE v01 | 7 REQUIRED ASSETS | 2026-10-17', $font, [Drawing.Brushes]::WhiteSmoke, 30, 20)
    $placements = @(@(30,70,850,478),@(920,70,850,478),@(30,600,850,478),@(920,600,850,478))
    for ($i=0; $i -lt 4; $i++) {
        $image = [Drawing.Image]::FromFile((Join-Path $assetDir ($names[$i]+'.png')))
        try { $p=$placements[$i]; $g.DrawImage($image, [Drawing.Rectangle]::new($p[0],$p[1],$p[2],$p[3])); $g.DrawString(($names[$i]+'.png | RGB 1920x1080'),$font,$muted,$p[0],$p[1]+$p[3]+8) }
        finally { $image.Dispose() }
    }
    # Expand the canvas for the title background and two full-height cutouts.
} finally { $g.Dispose(); $font.Dispose(); $muted.Dispose() }
$finalSheet = [Drawing.Bitmap]::new(1800, 1820, [Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [Drawing.Graphics]::FromImage($finalSheet)
$font = [Drawing.Font]::new('Consolas',20)
try {
    $g.Clear([Drawing.Color]::FromArgb(17,14,29))
    $g.DrawImageUnscaled($sheet,0,0)
    $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $title = [Drawing.Image]::FromFile((Join-Path $assetDir 'title_bg.png'))
    try { $g.DrawImage($title,[Drawing.Rectangle]::new(30,1180,850,478)); $g.DrawString('title_bg.png | RGB 1920x1080',$font,[Drawing.Brushes]::WhiteSmoke,30,1670) } finally { $title.Dispose() }
    foreach ($pair in @(@('witch_portrait',980),@('witch_locked',1390))) {
        $image = [Drawing.Image]::FromFile((Join-Path $assetDir ($pair[0]+'.png')))
        try {
            $rect = [Drawing.Rectangle]::new($pair[1],1180,320,480)
            $g.FillRectangle([Drawing.Brushes]::SlateGray,$rect)
            $g.DrawImage($image,$rect)
            $g.DrawString(($pair[0]+'.png'),$font,[Drawing.Brushes]::WhiteSmoke,$pair[1]-10,1670)
            $g.DrawString('RGBA 512x768',$font,[Drawing.Brushes]::WhiteSmoke,$pair[1]-10,1710)
        } finally { $image.Dispose() }
    }
    $finalSheet.Save($sheetPath,[Drawing.Imaging.ImageFormat]::Png)
} finally { $g.Dispose(); $font.Dispose(); $sheet.Dispose(); $finalSheet.Dispose() }
Write-Output 'Built 7 assets and the preview sheet.'
