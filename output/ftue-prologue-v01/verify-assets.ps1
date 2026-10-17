$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$workspace = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$assetDir = Join-Path $workspace 'godot/assets/ui/ftue'
$names = @('prologue_01','prologue_02','prologue_03','prologue_04','title_bg','witch_portrait','witch_locked')
$records = @()
foreach ($name in $names) {
    $path = Join-Path $assetDir "$name.png"
    $bytes = [IO.File]::ReadAllBytes($path)
    $image = [Drawing.Bitmap]::new($path)
    try {
        $portrait = $name.StartsWith('witch_')
        $expectedWidth = 1920; $expectedHeight = 1080; $expectedType = 2; $channels = 'RGB'
        if ($portrait) { $expectedWidth = 512; $expectedHeight = 768; $expectedType = 6; $channels = 'RGBA' }
        $alphaMin = 255; $alphaMax = 255; $transparentPixels = 0; $partialAlphaPixels = 0
        $nonSilhouettePixels = 0
        if ($portrait) {
            $rect = [Drawing.Rectangle]::new(0,0,$image.Width,$image.Height)
            $data = $image.LockBits($rect,[Drawing.Imaging.ImageLockMode]::ReadOnly,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
            try {
                $pixels = [byte[]]::new([Math]::Abs($data.Stride)*$data.Height)
                [Runtime.InteropServices.Marshal]::Copy($data.Scan0,$pixels,0,$pixels.Length)
                for ($y=0; $y -lt $image.Height; $y++) {
                    for ($x=0; $x -lt $image.Width; $x++) {
                        $i=$y*[Math]::Abs($data.Stride)+$x*4; $alpha=[int]$pixels[$i+3]
                        $alphaMin=[Math]::Min($alphaMin,$alpha); $alphaMax=[Math]::Max($alphaMax,$alpha)
                        if ($alpha -eq 0) { $transparentPixels++ }
                        elseif ($alpha -lt 255) { $partialAlphaPixels++ }
                        if ($name -eq 'witch_locked' -and $alpha -gt 0) {
                            # Every visible pixel must use the exact single ink.
                            if ($pixels[$i] -ne 70 -or $pixels[$i+1] -ne 35 -or $pixels[$i+2] -ne 42) { $nonSilhouettePixels++ }
                        }
                    }
                }
            } finally { $image.UnlockBits($data) }
        }
        $cornersTransparent = $true
        if ($portrait) {
            foreach ($point in @(@(0,0),@(($image.Width-1),0),@(0,($image.Height-1)),@(($image.Width-1),($image.Height-1)))) {
                if ($image.GetPixel($point[0],$point[1]).A -ne 0) { $cornersTransparent=$false }
            }
        }
        $passed = $image.Width -eq $expectedWidth -and $image.Height -eq $expectedHeight -and $bytes[24] -eq 8 -and $bytes[25] -eq $expectedType
        if ($portrait) { $passed = $passed -and $alphaMin -eq 0 -and $alphaMax -eq 255 -and $transparentPixels -gt 1000 -and $cornersTransparent }
        if ($name -eq 'witch_locked') { $passed = $passed -and $nonSilhouettePixels -eq 0 }
        $records += [ordered]@{
            path="godot/assets/ui/ftue/$name.png"; width=$image.Width; height=$image.Height
            channels=$channels; png_color_type=[int]$bytes[25]; bit_depth=[int]$bytes[24]
            has_alpha=($bytes[25] -eq 6); alpha_min=$alphaMin; alpha_max=$alphaMax
            transparent_pixels=$transparentPixels; partial_alpha_pixels=$partialAlphaPixels
            transparent_corners=$cornersTransparent; non_silhouette_pixels=$nonSilhouettePixels
            sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
            bytes=$bytes.Length; passed=[bool]$passed
        }
    } finally { $image.Dispose() }
}
$baseline = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'protected-paths-before.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$changed = @($baseline | Where-Object { !(Test-Path -LiteralPath (Join-Path $workspace $_.path)) -or (Get-FileHash -LiteralPath (Join-Path $workspace $_.path) -Algorithm SHA256).Hash.ToLowerInvariant() -ne $_.sha256 } | ForEach-Object { $_.path })
$headBefore = (Get-Content -LiteralPath (Join-Path $PSScriptRoot 'head-before.txt') -Raw -Encoding UTF8).Trim()
$headAfter = (& git -C $workspace rev-parse HEAD).Trim()
$importRecord = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'godot-import-result.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$visualReview = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'visual-review.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$textureReview = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'texture-load-verification.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$result = [ordered]@{
    date='2026-10-18'; required_asset_count=7; request_count_note='The brief says 6, but its explicit list contains 4+1+2=7 required assets.'
    generator='Built-in image_gen'; assets=$records
    preview_sheet='godot/screenshots/ftue/asset-sheet.png'; visual_review=$visualReview
    godot_import=$importRecord
    godot_texture_load=$textureReview
    protected_paths=[ordered]@{
        baseline_file='output/ftue-prologue-v01/protected-paths-before.json'; baseline_count=$baseline.Count
        observed_changed_paths=$changed; baseline_unchanged=($changed.Count -eq 0)
        write_scope_excludes_protected=$true
        note='Concurrent implementation changes are observed only. This asset task writes assets, screenshots, documentation and output; import runs in isolation. No protected files were edited or rolled back by this task.'
    }
    git_head_before=$headBefore; git_head_after=$headAfter; no_commit=($headBefore -eq $headAfter)
    optional_logo=[ordered]@{delivered=$false;reason='Optional; use the game font fallback.'}
    passed=(@($records | Where-Object { !$_.passed }).Count -eq 0 -and $importRecord.exit_code -eq 0 -and $visualReview.passed -and $textureReview.passed -and $headBefore -eq $headAfter)
}
$result | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'asset-verification.json') -Encoding UTF8
[pscustomobject]$result | Select-Object date,required_asset_count,passed | ConvertTo-Json
if (!$result.passed) { exit 1 }
