param([string]$ProjectRoot = (Get-Location).Path)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$out = Join-Path $ProjectRoot 'art/ui/spellbook-crafting-concepts-v03'
function GraphicsFor($bitmap) {
    $g = [System.Drawing.Graphics]::FromImage($bitmap)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    return $g
}
$entries = @(
    @('02-window-generated.png', '02-window.png'),
    @('03-discovery-generated.png', '03-discovery.png'),
    @('04-recipe-reward-generated-02.png', '04-recipe-reward.png')
)
$records = @()
foreach ($pair in $entries) {
    $source = [System.Drawing.Image]::FromFile((Join-Path $out ('drafts/' + $pair[0])))
    $bitmap = New-Object System.Drawing.Bitmap 1920,1080
    $g = GraphicsFor $bitmap
    # Preserve aspect ratio; only the subpixel excess of the almost-16:9 source is cropped.
    $srcHeight = [single]($source.Width * 1080.0 / 1920.0)
    $srcY = [single](($source.Height - $srcHeight) / 2.0)
    $g.DrawImage($source, [System.Drawing.RectangleF]::new(0,0,1920,1080), [System.Drawing.RectangleF]::new(0,$srcY,$source.Width,$srcHeight), [System.Drawing.GraphicsUnit]::Pixel)
    $destination = Join-Path $out $pair[1]
    $bitmap.Save($destination, [System.Drawing.Imaging.ImageFormat]::Png)
    $records += [pscustomobject]@{File=$pair[1]; Width=1920; Height=1080; Source=('drafts/' + $pair[0]); SourceWidth=$source.Width; SourceHeight=$source.Height; SHA256=(Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash}
    $g.Dispose(); $bitmap.Dispose(); $source.Dispose()
}
$fonts = New-Object System.Drawing.Text.PrivateFontCollection
$fonts.AddFontFile((Join-Path $ProjectRoot 'godot/assets/fonts/NotoSansKR-wght.ttf'))
$heading = [System.Drawing.Font]::new($fonts.Families[0], 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$label = [System.Drawing.Font]::new($fonts.Families[0], 23, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$small = [System.Drawing.Font]::new($fonts.Families[0], 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$sheet = New-Object System.Drawing.Bitmap 2400,1120
$g = GraphicsFor $sheet
$g.Clear([System.Drawing.Color]::FromArgb(24,19,36))
$cream = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(246,232,206))
$muted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(194,179,210))
$accent = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(181,143,223),3)
$g.DrawString('마법책 제작 v03 · v01 책자 질감 유지 / 여백 장식만 정리', $heading, $cream, 24, 10)
$cells = @(
    @('art/ui/spellbook-crafting-concepts-v01/02a-window-diorama.png','v01 · 02a / 화풍·질감 기준',24,96),
    @('art/ui/spellbook-crafting-concepts-v03/02-window.png','v03 · 02 / 이번 결과',816,96),
    @('art/ui/spellbook-crafting-concepts-v02/02-window.png','v02 · 02 / 단순화 비교',1608,96),
    @('art/ui/spellbook-crafting-concepts-v03/02-window.png','v03 · 02 / 물약 제작',24,624),
    @('art/ui/spellbook-crafting-concepts-v03/03-discovery.png','v03 · 03 / 새로운 비법 발견',816,624),
    @('art/ui/spellbook-crafting-concepts-v03/04-recipe-reward.png','v03 · 04 / 나그네 장화 제작법 획득',1608,624)
)
foreach ($cell in $cells) {
    $g.DrawString($cell[1], $label, $cream, $cell[2], ($cell[3]-34))
    $source = [System.Drawing.Image]::FromFile((Join-Path $ProjectRoot $cell[0]))
    $g.DrawImage($source,[System.Drawing.Rectangle]::new($cell[2],$cell[3],768,432))
    $source.Dispose()
}
$g.DrawRectangle($accent, 814,94,772,436)
$g.DrawString('가죽·양피지·금속·나무결·소품·재화 삽화 유지 / 넝쿨·작은 반짝임 정리 (감소율은 정성적 목표)', $small, $muted, 24, 1080)
$sheet.Save((Join-Path $out 'sheet.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $sheet.Dispose(); $heading.Dispose(); $label.Dispose(); $small.Dispose(); $fonts.Dispose(); $cream.Dispose(); $muted.Dispose(); $accent.Dispose()
$records | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $out 'drafts/final-files.json') -Encoding UTF8
$records | Format-Table File,Width,Height,SourceWidth,SourceHeight
