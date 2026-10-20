$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../..'))
$out = Join-Path $root 'art/ui/spellbook-crafting-concepts-v02'
$fonts = New-Object System.Drawing.Text.PrivateFontCollection
$fonts.AddFontFile((Join-Path $root 'godot/assets/fonts/NotoSansKR-wght.ttf'))
$family = $fonts.Families | Where-Object Name -eq 'Noto Sans KR SemiBold' | Select-Object -First 1
if (-not $family) { $family = $fonts.Families[0] }

function Brush([string]$color) { return New-Object System.Drawing.SolidBrush([Drawing.ColorTranslator]::FromHtml($color)) }
function Text($g, [string]$text, [single]$x, [single]$y, [single]$w, [single]$h, [single]$size, [string]$color) {
    $font = New-Object System.Drawing.Font($family, $size, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
    $b = Brush $color
    $sf = New-Object Drawing.StringFormat
    $sf.Alignment = [Drawing.StringAlignment]::Center
    $sf.LineAlignment = [Drawing.StringAlignment]::Center
    $sf.FormatFlags = [Drawing.StringFormatFlags]::NoWrap
    $g.DrawString($text, $font, $b, [Drawing.RectangleF]::new($x,$y,$w,$h), $sf)
    $font.Dispose(); $b.Dispose(); $sf.Dispose()
}
function Plate($g, [single]$x, [single]$y, [single]$w, [single]$h, [string]$fill, [string]$edge) {
    $b = Brush $fill
    $p = New-Object Drawing.Pen([Drawing.ColorTranslator]::FromHtml($edge), 2)
    $g.FillRectangle($b, $x,$y,$w,$h)
    $g.DrawRectangle($p, $x,$y,$w,$h)
    $b.Dispose(); $p.Dispose()
}
function Graphics($bmp) {
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    return $g
}

foreach ($item in @(
    @{ Source='02-window-generated.png'; Final='02-window.png'; TitleY=136 },
    @{ Source='03-discovery-generated.png'; Final='03-discovery.png'; TitleY=178 },
    @{ Source='04-recipe-reward-generated.png'; Final='04-recipe-reward.png'; TitleY=136 }
)) {
    $im = [Drawing.Bitmap]::new((Join-Path $PSScriptRoot $item.Source))
    $g = Graphics $im
    # Restore the world day label; the generator had put the book title in this HUD.
    Plate $g 771 31 138 36 '#28183e' '#28183e'
    Text $g '1일차 · 낮' 768 30 144 37 22 '#fff0bc'
    # Keep the spellbook title attached to the physical spine, without ornaments.
    if ($item.Final -eq '03-discovery.png') {
        Plate $g 739 $item.TitleY 195 30 '#2d173e' '#876097'
        Text $g '마법책' 742 ($item.TitleY-1) 189 21 19 '#fff0bc'
        Text $g '낮 · 시간 멈춤' 742 ($item.TitleY+18) 189 12 9 '#f1e6cc'
    } else {
        Plate $g 739 $item.TitleY 195 43 '#2d173e' '#876097'
        Text $g '마법책' 742 ($item.TitleY+1) 189 25 22 '#fff0bc'
        Text $g '낮 · 시간 멈춤' 742 ($item.TitleY+25) 189 16 11 '#f1e6cc'
    }
    if ($item.Final -eq '03-discovery.png') {
        # A fading previous-state label makes the unknown-to-known transition explicit.
        Plate $g 601 289 77 27 '#dac8e5' '#7c5394'
        Text $g '??? →' 602 287 75 29 20 '#593c70'
    }
    $g.Dispose()
    $final = [Drawing.Bitmap]::new(1920,1080,[Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = Graphics $final
    $scale = [Math]::Max(1920.0/$im.Width, 1080.0/$im.Height)
    $w = [single]($im.Width*$scale); $h = [single]($im.Height*$scale)
    $dest = [Drawing.RectangleF]::new((1920-$w)/2,(1080-$h)/2,$w,$h)
    $src = [Drawing.RectangleF]::new(0,0,$im.Width,$im.Height)
    $g.DrawImage($im,$dest,$src,[Drawing.GraphicsUnit]::Pixel)
    $g.Dispose(); $im.Dispose()
    $final.Save((Join-Path $out $item.Final),[Drawing.Imaging.ImageFormat]::Png)
    $final.Dispose()
}

# 3200 x 1730: equal-scale large pair on top, three equal-size previews below.
$sheet = [Drawing.Bitmap]::new(3200,1730,[Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = Graphics $sheet
$g.Clear([Drawing.ColorTranslator]::FromHtml('#191524'))
Text $g '마법책 제작 · 책자 방향 v02 / 배치는 유지하고 묘사 밀도 낮추기' 50 10 3100 67 35 '#fff0ce'
Text $g 'v01 02a · 배치 기준 / 촘촘한 질감·넝쿨·소품' 60 82 1520 44 26 '#d6c5eb'
Text $g 'v02 02 · 큰 색면 / 촛불 1 + 주머니 1 / 비운 여백' 1620 82 1520 44 26 '#efe4bb'
$pairs = @(
    @{Path='art/ui/spellbook-crafting-concepts-v01/02a-window-diorama.png';X=60},
    @{Path='art/ui/spellbook-crafting-concepts-v02/02-window.png';X=1620}
)
foreach ($p in $pairs) {
    $im = [Drawing.Image]::FromFile((Join-Path $root $p.Path))
    $g.DrawImage($im,[Drawing.Rectangle]::new($p.X,137,1520,855)); $im.Dispose()
}
Text $g '미세 결·스티치·리벳·넝쿨 테두리·별 흩뿌리기·깃펜·꽃·책 더미 제거 · 슬롯 한 원 / 결과 두 원' 60 1008 3080 48 26 '#cab7db'
$tiles = @(
    @{File='02-window.png';X=60;Label='02  제작 창 · 물약 1 / 4 · 치유 물약'},
    @{File='03-discovery.png';X=1100;Label='03  새 비법 · ??? → 덩굴 올가미'},
    @{File='04-recipe-reward.png';X=2140;Label='04  책장 획득 · ??? → 나그네 장화'}
)
foreach ($t in $tiles) {
    Text $g $t.Label $t.X 1072 1000 42 23 '#eee2cb'
    $im = [Drawing.Image]::FromFile((Join-Path $out $t.File))
    $g.DrawImage($im,[Drawing.RectangleF]::new($t.X,1125,1000,562.5)); $im.Dispose()
}
$g.Dispose()
$sheet.Save((Join-Path $out 'sheet.png'),[Drawing.Imaging.ImageFormat]::Png)
$sheet.Dispose(); $fonts.Dispose()
Write-Output 'Created: three 1920x1080 PNGs and sheet.png (3200x1730).'
