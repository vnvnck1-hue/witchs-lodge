$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class DragonScaleChecks {
    public static long[] Compare(string beforePath, string afterPath, string maskPath) {
        using(var before=new Bitmap(beforePath)) using(var after=new Bitmap(afterPath)) using(var mask=new Bitmap(maskPath)) {
            var rect=new Rectangle(0,0,1024,1536);
            var b=before.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
            var a=after.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
            var m=mask.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
            var bp=new byte[1024*1536*4];var ap=new byte[bp.Length];var mp=new byte[bp.Length];
            Marshal.Copy(b.Scan0,bp,0,bp.Length);Marshal.Copy(a.Scan0,ap,0,ap.Length);Marshal.Copy(m.Scan0,mp,0,mp.Length);
            before.UnlockBits(b);after.UnlockBits(a);mask.UnlockBits(m);
            long changed=0,outside=0,title=0,category=0,rules=0,alpha=0,nonOpaqueInterior=0;
            for(int y=0;y<1536;y++) for(int x=0;x<1024;x++) {
                int i=(y*1024+x)*4;
                bool different=bp[i]!=ap[i]||bp[i+1]!=ap[i+1]||bp[i+2]!=ap[i+2]||bp[i+3]!=ap[i+3];
                if(different) {
                    changed++;
                    if(mp[i+3]==0) outside++;
                    if(x>=110&&x<914&&y>=72&&y<236) title++;
                    if(x>=220&&x<804&&y>=267&&y<307) category++;
                    if(x>=110&&x<914&&y>=1185&&y<1445) rules++;
                }
                if(bp[i+3]!=ap[i+3]) alpha++;
                if(x>=32&&x<992&&y>=32&&y<1504&&ap[i+3]!=255) nonOpaqueInterior++;
            }
            return new long[]{changed,outside,title,category,rules,alpha,nonOpaqueInterior};
        }
    }
}
'@
function Get-PngRecord([string]$path, [int]$expectedWidth, [int]$expectedHeight) {
    $absolute=(Join-Path (Get-Location).Path $path)
    $bytes=[System.IO.File]::ReadAllBytes($absolute)
    $image=[System.Drawing.Bitmap]::new($absolute)
    try {
        $corners=@($image.GetPixel(0,0).A,$image.GetPixel(($image.Width-1),0).A,$image.GetPixel(0,($image.Height-1)).A,$image.GetPixel(($image.Width-1),($image.Height-1)).A)
        $nearCorners=@($image.GetPixel(1,1).A,$image.GetPixel(($image.Width-2),1).A,$image.GetPixel(1,($image.Height-2)).A,$image.GetPixel(($image.Width-2),($image.Height-2)).A)
        [ordered]@{
            path=$path;width=$image.Width;height=$image.Height;mode='RGBA';channels=4;
            png_bit_depth=[int]$bytes[24];png_color_type=[int]$bytes[25];pixel_format=$image.PixelFormat.ToString();
            corner_alpha=$corners;inset_1px_corner_alpha=$nearCorners;
            sha256=(Get-FileHash -LiteralPath $absolute -Algorithm SHA256).Hash.ToLowerInvariant();
            passed=($image.Width -eq $expectedWidth -and $image.Height -eq $expectedHeight -and $bytes[24] -eq 8 -and $bytes[25] -eq 6 -and @($corners | Where-Object {$_ -ne 0}).Count -eq 0 -and @($nearCorners | Where-Object {$_ -ne 0}).Count -eq 0)
        }
    } finally { $image.Dispose() }
}
$root=(Get-Location).Path
$measure=[DragonScaleChecks]::Compare((Join-Path $root 'godot/assets/cards/rowan_charm.png'),(Join-Path $root 'godot/assets/cards/dragon_scale.png'),(Join-Path $root 'output/dragon-scale-v01/art-mask.png'))
$files=@(
    (Get-PngRecord 'art/cards/dragon-scale-v01/dragon_scale.png' 1024 1536),
    (Get-PngRecord 'godot/assets/cards/dragon_scale.png' 1024 1536),
    (Get-PngRecord 'godot/assets/cards/hand/dragon_scale.png' 256 384)
)
$baseline=Get-Content -Raw -Encoding UTF8 -LiteralPath 'output/dragon-scale-v01/protected-before.json' | ConvertFrom-Json
$differences=@(foreach($entry in $baseline) {
    if(-not (Test-Path -LiteralPath $entry.path)) { [ordered]@{path=$entry.path;reason='missing'};continue }
    $current=(Get-FileHash -LiteralPath $entry.path -Algorithm SHA256).Hash.ToLowerInvariant()
    if($current -ne $entry.sha256) { [ordered]@{path=$entry.path;before=$entry.sha256;after=$current} }
})
$frameChecks=[ordered]@{
    reference='godot/assets/cards/rowan_charm.png';mask='output/dragon-scale-v01/art-mask.png';
    artwork_changed_pixels=$measure[0];changed_pixels_outside_art_mask=$measure[1];
    title_safe_area=[ordered]@{rect=@(110,72,914,236);changed_pixels=$measure[2]};
    classification_plate_center=[ordered]@{rect=@(220,267,804,307);changed_pixels=$measure[3]};
    rules_safe_area=[ordered]@{rect=@(110,1185,914,1445);changed_pixels=$measure[4]};
    alpha_changed_pixels=$measure[5];nonopaque_pixels_in_32px_inset=$measure[6];
    passed=($measure[0] -gt 100000 -and @($measure[1..6] | Where-Object {$_ -ne 0}).Count -eq 0);
    note='The existing blank runtime plate contours are preserved. These checks detect new artwork/ornament intrusion by exact pixel comparison, not by treating curved plates as rectangular cream fills.'
}
$visual=[ordered]@{
    reviewed='2026-10-24';single_red_scale=$true;flattened_shield_teardrop_silhouette=$true;
    centered_in_relic_window=$true;approximate_subject_width_ratio_to_window=0.62;
    subtle_inner_heat_and_snow_steam=$true;medieval_fantasy_watercolor_ink=$true;
    no_full_dragon_people_animals_buildings=$true;no_baked_text_numbers_or_glyphs=$true;
    original_blank_title_classification_rules_preserved=$true;readable_at_actual_256x384=$true;
    comparison_sheet='godot/screenshots/dragon-scale/card-sheet.png';
    method='Visual review of generated images, final top crop, and comparison sheet including actual-size hand cards. Semantic checks are manual, not OCR or gameplay testing.';
    passed=$true
}
$identical=$files[0].sha256 -eq $files[1].sha256
$protectedAssetDifferences=@($differences | Where-Object { $_.path -like 'godot/assets/cards/*' -or $_.path -eq 'godot/project.godot' })
$passed=(@($files | Where-Object {-not $_.passed}).Count -eq 0 -and $frameChecks.passed -and $identical -and $protectedAssetDifferences.Count -eq 0 -and $visual.passed)
$report=[ordered]@{
    asset='dragon_scale';version='v01';date='2026-10-24';timezone='Asia/Seoul';passed=$passed;
    generation=[ordered]@{tool='built-in image_gen';calls=3;rejected_drafts=2;prompt_record='docs/prompts/cards/dragon-scale-v01-prompts.md';generated_original='art/cards/dragon-scale-v01/dragon_scale-generated.png'};
    files=$files;canonical_and_runtime_byte_identical=$identical;
    downscale=[ordered]@{source='godot/assets/cards/dragon_scale.png';target='godot/assets/cards/hand/dragon_scale.png';scale=0.25;method='System.Drawing HighQualityBicubic, TileFlipXY edge handling';aspect_ratio='2:3'};
    frame_and_safe_areas=$frameChecks;visual_review=$visual;
    protected_paths=[ordered]@{
        baseline='output/dragon-scale-v01/protected-before.json';checked_files=@($baseline).Count;
        whole_workspace_unchanged=($differences.Count -eq 0);
        concurrent_changes_observed=$differences;
        unchanged_protected_card_metadata_and_pngs=($protectedAssetDifferences.Count -eq 0);
        modified_by_this_task=@();
        note='Another session is actively editing this shared workspace. The observed script/tool/EXE changes were not made by this task and were not reverted. Overall asset pass does not assert that the entire shared workspace is unchanged.'
    };
    restrictions=[ordered]@{committed=$false;stash_checkout_reset_used=$false;godot_import_run=$false;executable_exported=$false;executable_export_owner='Claude, per handoff';other_card_pngs_modified=$false};
    limitations=@('The handoff link docs/dragon-scale.md was absent; requirements were taken from the complete handoff body.','Runtime text rendering and EXE export are assigned to Claude and were not run.');
    remaining_artwork_issues=@()
}
$report | ConvertTo-Json -Depth 12 | Set-Content -Encoding UTF8 -LiteralPath 'output/dragon-scale-v01/verification.json'
[pscustomobject]@{passed=$passed;frame=$frameChecks;protected_file_count=@($baseline).Count;protected_differences=$differences;files=$files} | ConvertTo-Json -Depth 8
if(-not $passed) { throw 'Asset verification failed; inspect verification.json.' }
