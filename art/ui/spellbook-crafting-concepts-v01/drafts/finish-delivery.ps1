# Run from repository root. Source artwork is generated using built-in image_gen.
# Deterministic finishing only: pixel dimensions, comparison sheet, integrity manifest.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$assetRoot = Join-Path (Get-Location) 'art/ui/spellbook-crafting-concepts-v01'
$draftRoot = Join-Path $assetRoot 'drafts'
$files = @(
    @{Name='01-entry-book-states.png'; Source='01-entry-book-states-raw.png'; Label='01 · 입구 3상태'},
    @{Name='02a-window-diorama.png'; Source='02a-window-diorama-corrected.png'; Label='02a · 실물 책'},
    @{Name='02b-window-ui-frame.png'; Source='02b-window-ui-frame-corrected.png'; Label='02b · 달 룬 UI'},
    @{Name='03-discovery-moment.png'; Source='03-discovery-moment-corrected.png'; Label='03 · 새 비법 발견'},
    @{Name='04-recipe-reward.png'; Source='04-recipe-reward-corrected.png'; Label='04 · 제작법 획득'}
)
function New-Canvas([int]$width, [int]$height) {
    return New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
}
function Set-Quality($graphics) {
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
}
$manifest = @()
foreach ($file in $files) {
    $sourcePath = Join-Path $draftRoot $file.Source
    $sourceImage = [System.Drawing.Image]::FromFile($sourcePath)
    $finalImage = New-Canvas 1920 1080
    $graphics = [System.Drawing.Graphics]::FromImage($finalImage)
    Set-Quality $graphics
    $graphics.Clear([System.Drawing.Color]::FromArgb(255,18,16,33))
    $graphics.DrawImage($sourceImage, [System.Drawing.Rectangle]::new(0,0,1920,1080))
    $destPath = Join-Path $assetRoot $file.Name
    $finalImage.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $manifest += [pscustomobject]@{
        file=$file.Name; width=1920; height=1080
        source=('drafts/' + $file.Source)
        source_width=$sourceImage.Width; source_height=$sourceImage.Height
        bytes=(Get-Item -LiteralPath $destPath).Length
        sha256=(Get-FileHash -LiteralPath $destPath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    $graphics.Dispose()
    $finalImage.Dispose()
    $sourceImage.Dispose()
}
$privateFonts = New-Object System.Drawing.Text.PrivateFontCollection
$privateFonts.AddFontFile((Join-Path $draftRoot 'NotoSansKR-wght.ttf'))
$family = $privateFonts.Families | Where-Object { $_.Name -eq 'Noto Sans KR' } | Select-Object -First 1
$cream = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#F5E7C7'))
$muted = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#C2B7D2'))
$gold = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#AC8A5B'),2)
function Write-SheetText([string]$text,[int]$x,[int]$y,[int]$size,$brush) {
    $font = [System.Drawing.Font]::new($family,[single]$size,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)
    $sheetGraphics.DrawString($text,$font,$brush,[single]$x,[single]$y)
    $font.Dispose()
}
$sheet = New-Canvas 2560 1480
$sheetGraphics = [System.Drawing.Graphics]::FromImage($sheet)
Set-Quality $sheetGraphics
$sheetGraphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#121021'))
Write-SheetText '마법책 제작 화면 · 컨셉 시안 5종' 32 20 46 $cream
Write-SheetText '중세 판타지 · 낮의 산장 · 모든 제작법 공개 / 미지의 비법은 ??? · 2026-10-19' 34 83 25 $muted
for ($i=0; $i -lt $files.Count; $i++) {
    $thumb = [System.Drawing.Image]::FromFile((Join-Path $assetRoot $files[$i].Name))
    $thumbX = 32 + 504 * $i
    $sheetGraphics.DrawImage($thumb,[System.Drawing.Rectangle]::new($thumbX,145,480,270))
    $sheetGraphics.DrawRectangle($gold,$thumbX,145,480,270)
    Write-SheetText $files[$i].Label $thumbX 428 27 $cream
    $thumb.Dispose()
}
$sheetGraphics.DrawLine($gold,32,477,2528,477)
Write-SheetText 'A · 실물 책 — 양피지 / 룬 원 / 밀랍 도장' 32 497 31 $cream
Write-SheetText 'B · 달 룬 UI — 남색 판 / 금테 / 정보 가독성' 1312 497 31 $cream
for ($i=0; $i -lt 2; $i++) {
    $large = [System.Drawing.Image]::FromFile((Join-Path $assetRoot $files[$i+1].Name))
    $largeX = 32 + 1280 * $i
    $sheetGraphics.DrawImage($large,[System.Drawing.Rectangle]::new($largeX,550,1216,684))
    $sheetGraphics.DrawRectangle($gold,$largeX,550,1216,684)
    $large.Dispose()
}
Write-SheetText '책을 펼쳐 직접 실험하는 분위기 · 발견과 책장 흡수 연출에 적합' 32 1252 25 $cream
Write-SheetText '높은 글자 대비와 규칙적인 격자 · UI 배치와 확장에 유리' 1312 1252 25 $cream
Write-SheetText '구현: 책의 곡면·마법진·잉크 연출에 맞춘 레이어와 마스크 필요' 32 1294 24 $muted
Write-SheetText '구현: 패널·격자·슬롯 중심, 작은 책 아이콘으로 소품 연결' 1312 1294 24 $muted
$sheetGraphics.DrawLine($gold,32,1351,2528,1351)
Write-SheetText 'A/B 동일 정보: 물약 1/4 · 장비 1/5 · 마법 1/4 / 치유 물약 / 약초 ×2 + 빈 슬롯 2칸' 32 1371 27 $cream
Write-SheetText '개별 시안은 모두 1920×1080 PNG · 방향 선택용 목업 · 실제 게임에는 적용하지 않음' 32 1415 24 $muted
$sheet.Save((Join-Path $assetRoot 'sheet.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$sheetGraphics.Dispose()
$sheet.Dispose()
$cream.Dispose()
$muted.Dispose()
$gold.Dispose()
$privateFonts.Dispose()
$manifestJson = $manifest | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText((Join-Path $draftRoot 'final-manifest.json'), $manifestJson, [System.Text.UTF8Encoding]::new($false))
$manifest | Format-Table file,width,height,bytes -AutoSize

