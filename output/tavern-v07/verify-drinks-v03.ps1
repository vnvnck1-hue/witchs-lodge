$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$rootPath=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.IO;
using System.Drawing;
public class DrinkFactsV03 {
 public int width,height,png_color_type;
 public string channels="RGBA";
 public int[] corner_alpha;
 public int transparent_pixels,partial_alpha_pixels;
 public int outside_edit_mask_rgba_differences,title_safe_rgba_differences,rules_safe_rgba_differences,alpha_differences;
 public bool frame_test_performed;
}
public static class DrinkVerifyV03 {
 public static DrinkFactsV03 Measure(string path,string source,string mask){var f=new DrinkFactsV03();f.png_color_type=File.ReadAllBytes(path)[25];using(var b=new Bitmap(path)){
  f.width=b.Width;f.height=b.Height;f.corner_alpha=new int[]{b.GetPixel(0,0).A,b.GetPixel(b.Width-1,0).A,b.GetPixel(0,b.Height-1).A,b.GetPixel(b.Width-1,b.Height-1).A};
  for(int y=0;y<b.Height;y++)for(int x=0;x<b.Width;x++){int a=b.GetPixel(x,y).A;if(a==0)f.transparent_pixels++;else if(a<255)f.partial_alpha_pixels++;}
  if(!String.IsNullOrEmpty(source)){f.frame_test_performed=true;using(var a=new Bitmap(source))using(var m=new Bitmap(mask))for(int y=0;y<1536;y++)for(int x=0;x<1024;x++){Color c=a.GetPixel(x,y),d=b.GetPixel(x,y);if(c.A!=d.A)f.alpha_differences++;if(c.ToArgb()==d.ToArgb())continue;if(m.GetPixel(x,y).A==0)f.outside_edit_mask_rgba_differences++;if(x>=110&&x<=914&&y>=72&&y<=236)f.title_safe_rgba_differences++;if(x>=110&&x<=914&&y>=1185&&y<=1445)f.rules_safe_rgba_differences++;}}
 }return f;}
}
'@
$records=@();$passed=$true
foreach($id in @('dragon_breath','frost_giant_spirit')){
 foreach($kind in @('art','game','hand')){
  $rel=if($kind -eq 'art'){'art/cards/tavern-v07/'+$id+'.png'}elseif($kind -eq 'game'){'godot/assets/cards/'+$id+'.png'}else{'godot/assets/cards/hand/'+$id+'.png'}
  $abs=Join-Path $rootPath $rel
  $source=if($kind -eq 'hand'){$null}else{Join-Path $rootPath 'godot/assets/cards/wisp_spirit.png'}
  $facts=[DrinkVerifyV03]::Measure($abs,$source,(Join-Path $rootPath 'output/tavern-v07/drink-edit-mask-v03.png'))
  $w=if($kind -eq 'hand'){256}else{1024};$h=if($kind -eq 'hand'){384}else{1536}
  $ok=$facts.width -eq $w -and $facts.height -eq $h -and $facts.png_color_type -eq 6 -and ($facts.corner_alpha | Measure-Object -Maximum).Maximum -eq 0 -and $facts.outside_edit_mask_rgba_differences -eq 0 -and $facts.title_safe_rgba_differences -eq 0 -and $facts.rules_safe_rgba_differences -eq 0 -and $facts.alpha_differences -eq 0
  $records+=[ordered]@{id=$id;kind=$kind;path=$rel;facts=$facts;sha256=(Get-FileHash -LiteralPath $abs -Algorithm SHA256).Hash.ToLowerInvariant();passed=$ok};$passed=$passed -and $ok
 }
}
$preservation=@();foreach($id in @('dragon_breath','frost_giant_spirit')){
 $rel='art/cards/tavern-v07/drafts/'+$id+'_skill-format-rejected.png'
 $old=Get-Content -LiteralPath (Join-Path $rootPath 'output/tavern-v07/verification.json') -Raw -Encoding UTF8 | ConvertFrom-Json
 $previous=@($old.records | Where-Object {$_.path -eq ('art/cards/tavern-v07/'+$id+'.png')})[0].sha256
 $actual=(Get-FileHash -LiteralPath (Join-Path $rootPath $rel) -Algorithm SHA256).Hash.ToLowerInvariant()
 $ok=$actual -eq $previous;$passed=$passed -and $ok
 $preservation+=[ordered]@{path=$rel;sha256=$actual;matches_v02_verification=$ok}
 $pair=@($records | Where-Object {$_.id -eq $id -and $_.kind -ne 'hand'});if($pair[0].sha256 -ne $pair[1].sha256){$passed=$false}
}
$before=Get-Content -LiteralPath (Join-Path $rootPath 'output/tavern-v07/protected-before-v03.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$changed=@();foreach($entry in $before){$p=Join-Path $rootPath $entry.path;if(!(Test-Path -LiteralPath $p)){$changed+=[ordered]@{path=$entry.path;reason='missing'}}else{$hash=(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant();if($hash -ne $entry.sha256){$changed+=[ordered]@{path=$entry.path;before=$entry.sha256;after=$hash}}}}
$protected=[ordered]@{baseline='output/tavern-v07/protected-before-v03.json';files_checked=$before.Count;changed=$changed;passed=($changed.Count -eq 0)}
$passed=$passed -and $protected.passed
$sourceRel='godot/assets/cards/wisp_spirit.png';$maskRel='output/tavern-v07/drink-edit-mask-v03.png'
$report=[ordered]@{
 date='2026-10-27';passed=[bool]$passed;generation_tool='built-in image_gen';records=$records
 frame_reference=[ordered]@{path=$sourceRel;sha256=(Get-FileHash -LiteralPath (Join-Path $rootPath $sourceRel) -Algorithm SHA256).Hash.ToLowerInvariant();mask=$maskRel;mask_sha256=(Get-FileHash -LiteralPath (Join-Path $rootPath $maskRel) -Algorithm SHA256).Hash.ToLowerInvariant();comparison='Exact RGBA comparison of every pixel outside illustration and badge interior mask against unmodified wisp_spirit. Also checks entire alpha channel and inclusive title/rules safe areas.'}
 rejected_v02_preservation=$preservation;protected_files=$protected
 preview_sheet='godot/screenshots/tavern-v07/drink-format-sheet.png'
 visual_review=[ordered]@{rounded_rectangular_drink_window=$true;matching_mini_bottle_badges=$true;liquor_bottles_are_heroes=$true;fire_and_ice_readable_at_256x384=$true;no_people_landscape_or_monsters=$true;no_baked_letters_numbers_or_labels=$true;medieval_fantasy=$true;reference_four_drinks_reviewed=$true;dragon_bottle_width_fraction_of_window=0.67;frost_bottle_width_fraction_of_window=0.56}
 limitations=@('Subject, text absence, style and size readability are visual judgments, not OCR or automated semantic measurements.','No runtime testing, import regeneration, text profile changes, executable export or commit; these belong to Claude in the handoff.')
}
[IO.File]::WriteAllText((Join-Path $rootPath 'output/tavern-v07/verification-v03.json'),($report | ConvertTo-Json -Depth 16),[Text.UTF8Encoding]::new($false))
Write-Output ('passed='+$passed+'; assets='+$records.Count+'; protected files='+$before.Count+'; changed='+$changed.Count)
if(!$passed){$records | Where-Object {!$_.passed} | ConvertTo-Json -Depth 8;$changed | ConvertTo-Json -Depth 4;exit 1}
