param([int[]]$Cuts=@(1,2,4))
$ErrorActionPreference='Stop'
if(3 -in $Cuts){throw 'Cut 3 is approved and read-only. Allowed cuts: 1, 2, 4.'}
Add-Type -Path "$PSScriptRoot/ImagePipeline.cs" -ReferencedAssemblies System.Drawing
$taskRoot=(Resolve-Path "$PSScriptRoot/../..").Path
$assetDir=Join-Path $taskRoot 'godot/assets/ui/ftue/motion'
$previewDir=Join-Path $taskRoot 'godot/screenshots/ftue/motion'
New-Item -ItemType Directory -Force $assetDir,$previewDir | Out-Null
$index=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/generation-index-v02.json" | ConvertFrom-Json
$layout=@()
foreach($job in $index){
  if($job.cut -eq 3 -or ($job.cut -ne 0 -and $job.cut -notin $Cuts)){continue}
  if($job.kind -in @('master-v02','repair-v02','draft')){continue}
  if($null -eq $job.box){continue}
  $src=Join-Path $taskRoot $job.dest
  if(-not (Test-Path -LiteralPath $src)){continue}
  if($job.opacity){$faded=Join-Path $PSScriptRoot "normalized-cut$($job.cut)-$($job.id).png";[MotionImage]::Fade($src,$faded,[double]$job.opacity);$src=$faded}
  if($job.cut -eq 0){[MotionImage]::Frame($src,(Join-Path $assetDir 'panel_frame.png'));continue}
  $name="cut$($job.cut)_$($job.id).png"
  $dst=Join-Path $assetDir $name
  $solid=$job.id -notin @('window_glow','lantern_glow','shafts','runes','smoke','eyes_1','eyes_2','eyes_3','fog')
  if($job.aligned_lodge){$lj=$index|Where-Object {$_.cut -eq $job.cut -and $_.id -eq 'lodge'}|Select-Object -Last 1;$lb=$lj.box;$box=[MotionImage]::AlignLight($src,(Join-Path $taskRoot $lj.dest),$dst,$lb[0],$lb[1],$lb[2],$lb[3],0.7,$job.cut)}elseif(-not $job.transparent){[MotionImage]::Normalize($src,$dst,2304,1296,$true);$box=@(0,0,2304,1296)}elseif($job.full_canvas){$box=[MotionImage]::CanvasTrim($src,$dst,$solid)}elseif($job.id -eq 'fog'){[MotionImage]::Normalize($src,$dst,2304,1296,$false);$box=@(0,0,2304,1296)}elseif($null -ne $job.parts){$box=[MotionImage]::Parts($src,$dst,[int[]]$job.parts)}else{$box=[MotionImage]::Prepare($src,$dst,$job.box[0],$job.box[1],$job.box[2],$job.box[3],$solid)}
  $blend=if($job.id -in @('window_glow','lantern_glow','runes','shafts')){'add'}else{'normal'}
  if($job.aligned_lodge){$box=[MotionImage]::LightAccents($dst,(Join-Path $taskRoot 'art/concepts/ftue-motion-v01/cut2_lantern_glow-v02-generated.png'),$job.cut,$box[0],$box[1])}
  $layout+=@{cut=[int]$job.cut;id=$job.id;file=$name;pos=@([int]$box[0],[int]$box[1]);size=@([int]$box[2],[int]$box[3]);depth=[double]$job.depth;blend=$blend}
}
# Approved cut 3 uses the existing clean plate unchanged except size/channel normalization.
# Cut 3 is complete and strictly read-only during this continuation.
# Reuse a single eye-pair illustration; all instances remain separately addressable sprites.
foreach($spec in (,@(4,'eyes_2',2140,752,58,32))){
 if($spec[0] -notin $Cuts){continue}
 $src=Join-Path $assetDir "cut$($spec[0])_eyes_1.png"
 if(Test-Path -LiteralPath $src){$name="cut$($spec[0])_$($spec[1]).png";$box=[MotionImage]::Prepare($src,(Join-Path $assetDir $name),$spec[2],$spec[3],$spec[4],$spec[5],$false);$layout+=@{cut=[int]$spec[0];id=$spec[1];file=$name;pos=@([int]$box[0],[int]$box[1]);size=@([int]$box[2],[int]$box[3]);depth=0.4;blend='normal'}}
}
if((4 -in $Cuts) -and (Test-Path (Join-Path $assetDir 'cut4_sky_night.png')) -and (Test-Path (Join-Path $taskRoot 'art/concepts/ftue-motion-v01/cut4_sky_dusk_palette-v02-generated.png'))){
 [MotionImage]::DuskGrade((Join-Path $assetDir 'cut4_sky_night.png'),(Join-Path $taskRoot 'art/concepts/ftue-motion-v01/cut4_sky_dusk_palette-v02-generated.png'),(Join-Path $assetDir 'cut4_sky_dusk.png'))
 $layout+=@{cut=4;id='sky_dusk';file='cut4_sky_dusk.png';pos=@(0,0);size=@(2304,1296);depth=0.0;blend='normal'}
}
$orders=@{
 1=@('sky','village','smoke','cliff','witch_3','witch_2','witch_1','fore','witch_fore')
 2=@('sky','trees_left','trees_right','lodge','window_glow','smoke','witch','lantern_glow','fore','trunk_left','trunk_right','fog')
 3=@('wall','beams','shafts','stone','runes','eyes_1','eyes_2','eyes_3','fore')
 4=@('sky_dusk','sky_night','forest','lodge','window_glow','traveler_1','traveler_2','eyes_1','eyes_2','spider_legs','spider','fore','traveler_fore')
}
foreach($n in $Cuts){
 $layers=@(foreach($id in $orders[$n]){$l=$layout|Where-Object { $_.cut -eq $n -and $_.id -eq $id }|Select-Object -Last 1;if($null -ne $l){@{id=$l.id;file=$l.file;pos=$l.pos;size=$l.size;depth=$l.depth;blend=$l.blend}}})
 [IO.File]::WriteAllText((Join-Path $assetDir "cut$n.json"),(@{cut=$n;canvas=@(2304,1296);layers=$layers}|ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
 if($layers.Count -eq $orders[$n].Count){
  $visible=@($layers|Where-Object { $_.id -notin @('sky_dusk','fog') -and -not($n -eq 2 -and $_.id -in @('window_glow','smoke')) })
  $paths=[string[]]@($visible|ForEach-Object {Join-Path $assetDir $_.file})
  $positions=[int[]]@($visible|ForEach-Object {$_.pos[0];$_.pos[1]})
  $adds=[bool[]]@($visible|ForEach-Object {$_.blend -eq 'add'})
  [MotionImage]::Composite($paths,$positions,$adds,(Join-Path $previewDir "cut${n}_preview.png"),$true)
  [MotionImage]::Composite($paths,$positions,$adds,(Join-Path $taskRoot "art/concepts/ftue-motion-v01/cut${n}_master.png"),$false)
  if($n -eq 2){
   $v=@($layers|Where-Object {$_.id -ne 'fog'})
   [MotionImage]::Composite([string[]]@($v|ForEach-Object {Join-Path $assetDir $_.file}),[int[]]@($v|ForEach-Object {$_.pos[0];$_.pos[1]}),[bool[]]@($v|ForEach-Object {$_.blend -eq 'add'}),(Join-Path $previewDir 'cut2_lit_preview.png'),$true)
  }
  if($n -eq 4){
   $v=@($layers|Where-Object {$_.id -notin @('sky_night','spider','spider_legs','eyes_1','eyes_2')})
   [MotionImage]::Composite([string[]]@($v|ForEach-Object {Join-Path $assetDir $_.file}),[int[]]@($v|ForEach-Object {$_.pos[0];$_.pos[1]}),[bool[]]@($v|ForEach-Object {$_.blend -eq 'add'}),(Join-Path $previewDir 'cut4_dusk_preview.png'),$true)
  }
 }
}
$completeLayout=@(foreach($n in 1..4){$m=Get-Content -Encoding UTF8 -Raw (Join-Path $assetDir "cut$n.json")|ConvertFrom-Json;foreach($l in $m.layers){@{cut=$n;id=$l.id;file=$l.file;pos=$l.pos;size=$l.size;depth=$l.depth;blend=$l.blend}}})
ConvertTo-Json -InputObject $completeLayout -Depth 8|Set-Content -Encoding UTF8 "$PSScriptRoot/layout.json"
Write-Output "Built $($layout.Count) layers."
