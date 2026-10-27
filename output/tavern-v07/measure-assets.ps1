$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.IO;
using System.Drawing;
public class ImageFacts {
 public int width,height,png_color_type,alpha_min=255,alpha_max=0,transparent_pixels=0,partial_alpha_pixels=0,outer_edge_alpha_max=0;
 public int[] corner_alpha;
 public int tile_horizontal_max_delta=0,tile_vertical_max_delta=0;
 public double tile_horizontal_mean_delta=0,tile_vertical_mean_delta=0;
}
public class CardFacts {
 public int title_safe_pixel_differences=0,rules_safe_pixel_differences=0;
 public int pixels_changed_outside_art_or_frame_restore_or_alpha_cleanup=0;
 public int restored_diamond_pixels=0;
}
public static class TavernMeasure {
 static bool Band(int x,int y){if(y<265||y>1095)return false;double dy=y-659;double inner=dy<0?139-dy*0.988:139+dy*0.981;double outer=dy<0?79-dy*1.017:79+dy*0.992;int a=(int)Math.Floor(outer)-3,b=(int)Math.Ceiling(inner)+3;return (x>=a&&x<=b)||(x>=1023-b&&x<=1023-a);}
 public static ImageFacts Measure(string p,bool tile){var r=new ImageFacts();r.png_color_type=File.ReadAllBytes(p)[25];using(var b=new Bitmap(p)){r.width=b.Width;r.height=b.Height;r.corner_alpha=new int[]{b.GetPixel(0,0).A,b.GetPixel(b.Width-1,0).A,b.GetPixel(0,b.Height-1).A,b.GetPixel(b.Width-1,b.Height-1).A};for(int y=0;y<b.Height;y++)for(int x=0;x<b.Width;x++){int a=b.GetPixel(x,y).A;r.alpha_min=Math.Min(r.alpha_min,a);r.alpha_max=Math.Max(r.alpha_max,a);if(a==0)r.transparent_pixels++;if(a>0&&a<255)r.partial_alpha_pixels++;if(x==0||y==0||x==b.Width-1||y==b.Height-1)r.outer_edge_alpha_max=Math.Max(r.outer_edge_alpha_max,a);}
 if(tile){long h=0,v=0;for(int y=0;y<b.Height;y++){var a=b.GetPixel(0,y);var c=b.GetPixel(b.Width-1,y);int[] ds={Math.Abs(a.R-c.R),Math.Abs(a.G-c.G),Math.Abs(a.B-c.B),Math.Abs(a.A-c.A)};foreach(int d in ds){h+=d;r.tile_horizontal_max_delta=Math.Max(r.tile_horizontal_max_delta,d);}}for(int x=0;x<b.Width;x++){var a=b.GetPixel(x,0);var c=b.GetPixel(x,b.Height-1);int[] ds={Math.Abs(a.R-c.R),Math.Abs(a.G-c.G),Math.Abs(a.B-c.B),Math.Abs(a.A-c.A)};foreach(int d in ds){v+=d;r.tile_vertical_max_delta=Math.Max(r.tile_vertical_max_delta,d);}}r.tile_horizontal_mean_delta=(double)h/(b.Height*4);r.tile_vertical_mean_delta=(double)v/(b.Width*4);}}
 return r;}
 public static CardFacts Card(string source,string card,string mask,bool skill){var r=new CardFacts();using(var a=new Bitmap(source))using(var b=new Bitmap(card))using(var m=new Bitmap(mask))for(int y=0;y<1536;y++)for(int x=0;x<1024;x++){var c=a.GetPixel(x,y);var d=b.GetPixel(x,y);if(c.ToArgb()==d.ToArgb())continue;if(x>=110&&x<914&&y>=72&&y<236)r.title_safe_pixel_differences++;if(x>=110&&x<914&&y>=1185&&y<1445)r.rules_safe_pixel_differences++;if(m.GetPixel(x,y).A>0)continue;if(skill&&Band(x,y)){r.restored_diamond_pixels++;continue;}if(d.A==0&&c.R==d.R&&c.G==d.G&&c.B==d.B)continue;r.pixels_changed_outside_art_or_frame_restore_or_alpha_cleanup++;}return r;}
}
'@
$records = @()
$ids = @('dragon_breath','frost_giant_spirit','cheers')
$sources = @('resin_torch','frost_rune','drunk_rant')
$passed = $true
for($i=0;$i -lt 3;$i++) {
  $id=$ids[$i]
  foreach($kind in @('art','game','hand')) {
    $rel = if($kind -eq 'art'){'art/cards/tavern-v07/'+$id+'.png'}elseif($kind -eq 'game'){'godot/assets/cards/'+$id+'.png'}else{'godot/assets/cards/hand/'+$id+'.png'}
    $abs=Join-Path $root $rel
    $facts=[TavernMeasure]::Measure($abs,$false)
    $w=if($kind -eq 'hand'){256}else{1024};$h=if($kind -eq 'hand'){384}else{1536}
    $ok=($facts.width -eq $w -and $facts.height -eq $h -and $facts.png_color_type -eq 6 -and ($facts.corner_alpha | Measure-Object -Maximum).Maximum -eq 0)
    $r=[ordered]@{path=$rel;kind=$kind;channels='RGBA';facts=$facts;sha256=(Get-FileHash -LiteralPath $abs -Algorithm SHA256).Hash.ToLowerInvariant();passed=$ok}
    if($kind -eq 'game'){
      $cf=[TavernMeasure]::Card((Join-Path $root ('output/tavern-v07/reference-snapshots/'+$sources[$i]+'.png')),$abs,(Join-Path $root ('output/tavern-v07/'+$id+'-art-mask.png')),($i -lt 2))
      $r['frame_and_safe_areas']=$cf
      $r['art_copy_sha_matches']=((Get-FileHash -LiteralPath (Join-Path $root ('art/cards/tavern-v07/'+$id+'.png')) -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $abs -Algorithm SHA256).Hash)
      $ok=$ok -and $cf.title_safe_pixel_differences -eq 0 -and $cf.rules_safe_pixel_differences -eq 0 -and $cf.pixels_changed_outside_art_or_frame_restore_or_alpha_cleanup -eq 0 -and $r['art_copy_sha_matches']
      $r['passed']=$ok
    }
    if(!$ok){$passed=$false};$records+=$r
  }
}
foreach($id in @('fire_pool','ice_block','vomit_puddle')) {
  $rel='godot/assets/vfx/tavern/'+$id+'.png';$abs=Join-Path $root $rel;$tile=$id -eq 'ice_block';$n=if($id -eq 'vomit_puddle'){256}else{512}
  $facts=[TavernMeasure]::Measure($abs,$tile)
  $ok=$facts.width -eq $n -and $facts.height -eq $n -and $facts.png_color_type -eq 6
  if($tile){$ok=$ok -and $facts.alpha_min -ge 160 -and $facts.alpha_max -le 230 -and $facts.tile_horizontal_max_delta -eq 0 -and $facts.tile_vertical_max_delta -eq 0}else{$ok=$ok -and $facts.outer_edge_alpha_max -eq 0 -and $facts.transparent_pixels -gt 0}
  if(!$ok){$passed=$false}
  $records+=[ordered]@{path=$rel;kind='vfx';channels='RGBA';facts=$facts;sha256=(Get-FileHash -LiteralPath $abs -Algorithm SHA256).Hash.ToLowerInvariant();passed=$ok}
}
$report=[ordered]@{
  date='2026-10-27';passed=$passed;generation_tool='built-in image_gen';records=$records
  preview_sheet='godot/screenshots/tavern-v07/card-sheet.png'
  ice_tile_preview='output/tavern-v07/ice-tile-2x2.png'
  visual_review=[ordered]@{no_baked_card_text=$true;skill_diamond_skeleton=$true;event_scene_skeleton=$true;hand_scale_subjects_readable=$true;erin_identity_matches_both_references=$true;no_extra_faces=$true;medieval_fantasy=$true;vfx_light_and_dark_backgrounds_reviewed=$true;ice_2x2_seams_reviewed=$true}
  limitations=@('Runtime rendering, gameplay, .import regeneration and exe export belong to Claude and were not performed.','Text/identity/style checks are visual judgments, not OCR or facial-recognition measurements.')
}
$json=$report | ConvertTo-Json -Depth 14
[System.IO.File]::WriteAllText((Join-Path $root 'output/tavern-v07/verification.json'),$json,[System.Text.UTF8Encoding]::new($false))
Write-Output ('passed='+$passed+'; PNG records='+$records.Count)
foreach($r in $records){if(!$r.passed){$r | ConvertTo-Json -Depth 8}}
if(!$passed){exit 1}
