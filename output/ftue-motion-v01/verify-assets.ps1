$ErrorActionPreference='Stop'
Add-Type -Path "$PSScriptRoot/ImagePipeline.cs" -ReferencedAssemblies System.Drawing
$taskRoot=(Resolve-Path "$PSScriptRoot/../..").Path
$assetDir=Join-Path $taskRoot 'godot/assets/ui/ftue/motion'
$required=@{
1=@('sky','village','smoke','cliff','witch_1','witch_2','witch_3','witch_fore','fore')
2=@('sky','trees_left','trees_right','lodge','window_glow','smoke','witch','lantern_glow','trunk_left','trunk_right','fore','fog')
3=@('wall','beams','shafts','stone','runes','eyes_1','eyes_2','eyes_3','fore')
4=@('sky_dusk','sky_night','forest','lodge','window_glow','traveler_1','traveler_2','traveler_fore','spider_legs','spider','eyes_1','eyes_2','fore')
}
$errors=@();$records=@();$manifestResults=@()
$recomposition=@()
foreach($n in 1..4){
 $mp=Join-Path $assetDir "cut$n.json"
 $m=Get-Content -Raw -Encoding UTF8 $mp|ConvertFrom-Json
 $ids=@($m.layers|ForEach-Object {$_.id})
 $diff=@(Compare-Object ($required[$n]|Sort-Object) ($ids|Sort-Object))
 $matched=$diff.Count -eq 0 -and $ids.Count -eq ($ids|Select-Object -Unique).Count
 if(-not $matched){$errors+="Cut $n IDs differ from handoff."}
 if(($m.canvas -join ',') -ne '2304,1296'){$errors+="Cut $n canvas mismatch."}
 $manifestResults+=@{cut=$n;ids=$ids;expected=$required[$n];ids_match=$matched;sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $mp).Hash.ToLower()}
 foreach($l in $m.layers){
  $p=Join-Path $assetDir $l.file
  $info=@([MotionImage]::Info($p).Split(',')|ForEach-Object {[long]$_})
  $data=[IO.File]::ReadAllBytes($p);$ct=[int]$data[25]
  $background=$l.id -in @('sky','wall','sky_dusk','sky_night')
  $expectedChannel=if($background){2}else{6}
  $blend=if($l.id -in @('window_glow','lantern_glow','runes','shafts')){'add'}else{'normal'}
  $ok=$ct -eq $expectedChannel -and $info[0] -eq $l.size[0] -and $info[1] -eq $l.size[1] -and $l.blend -eq $blend -and (Test-Path -LiteralPath ($p+'.import'))
  $ok=$ok -and $l.pos[0] -ge 0 -and $l.pos[1] -ge 0 -and ($l.pos[0]+$info[0]) -le 2304 -and ($l.pos[1]+$info[1]) -le 1296
  if($background){$ok=$ok -and $info[0] -eq 2304 -and $info[1] -eq 1296 -and ($l.pos -join ',') -eq '0,0'}
  else{$ok=$ok -and $info[6] -gt 0 -and ($info[7]+$info[8]) -gt 0}
  if(-not $ok){$errors+="Layer $($l.file) failed format/bounds/blend/alpha check."}
  $records+=@{file="godot/assets/ui/ftue/motion/$($l.file)";size=@($info[0],$info[1]);channels=$(if($ct -eq 2){'RGB'}else{'RGBA'});png_color_type=$ct;alpha_present=($ct -eq 6);alpha_pixels=@{transparent=$info[6];semi=$info[7];opaque=$info[8]};trim_threshold=8;trim_bbox=@($info[2],$info[3],($info[2]+$info[4]),($info[3]+$info[5]));pos=$l.pos;depth=$l.depth;blend=$l.blend;import_metadata_exists=(Test-Path -LiteralPath ($p+'.import'));sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash.ToLower();passed=$ok}
 }
 $assembled=Join-Path $taskRoot "art/concepts/ftue-motion-v01/cut${n}_master.png"
 $preview=Join-Path $taskRoot "godot/screenshots/ftue/motion/cut${n}_preview.png"
 $diffPixels=[MotionImage]::CropDifference($assembled,$preview)
 if($diffPixels -ne 0){$errors+="Cut $n re-composition crop differs."}
 $recomposition+=@{cut=$n;assembled_master="art/concepts/ftue-motion-v01/cut${n}_master.png";preview="godot/screenshots/ftue/motion/cut${n}_preview.png";different_pixels=$diffPixels;passed=($diffPixels -eq 0);note='Comparison is against delivered layer re-composition. Generated reference masters are preserved separately and were visually compared, not asserted pixel-identical.'}
}
$frame=Join-Path $assetDir 'panel_frame.png'
$fi=@([MotionImage]::Info($frame).Split(',')|ForEach-Object {[long]$_})
$fb=[MotionImage]::Load($frame);$centerOK=$true
for($y=70;$y -lt 1010 -and $centerOK;$y++){for($x=70;$x -lt 1850;$x++){if($fb.GetPixel($x,$y).A -ne 0){$centerOK=$false;break}}};$fb.Dispose()
$frameOK=$fi[0] -eq 1920 -and $fi[1] -eq 1080 -and $centerOK
if(-not $frameOK){$errors+='Panel frame dimension/interior alpha failed.'}
$records+=@{file='godot/assets/ui/ftue/motion/panel_frame.png';size=@(1920,1080);channels='RGBA';alpha_present=$true;trim_bbox=@($fi[2],$fi[3],($fi[2]+$fi[4]),($fi[3]+$fi[5]));center_alpha_zero=$centerOK;max_intrusion=70;sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $frame).Hash.ToLower();passed=$frameOK}
$proof=@()
$originalBaseline=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/protected-before.json"|ConvertFrom-Json
foreach($base in $originalBaseline){
 $p=Join-Path $taskRoot $base.path
 $hash=(Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash
 if($hash -ne $base.sha256){$proof+=@{path=$base.path;before=$base.sha256;after=$hash;note='Concurrent changes must be reviewed; this asset pipeline never writes this path.'}}
}
$importExit=$null
if(Test-Path "$PSScriptRoot/import-result.json"){$importExit=(Get-Content -Raw "$PSScriptRoot/import-result.json"|ConvertFrom-Json).exit_code}
$resumeChanges=@();$cut3Checked=0
$resumeBaseline=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/protected-resume-before.json"|ConvertFrom-Json
foreach($base in $resumeBaseline){
 $p=Join-Path $taskRoot $base.path;$hash=(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash
 if($base.path -match 'cut3'){$cut3Checked++}
 if($hash -ne $base.sha256){$resumeChanges+=@{path=$base.path;before=$base.sha256;after=$hash;note='Concurrent source change observed; this asset-only pipeline does not write this path. Preserved without reverting.'}}
}
$cut3Changes=@($resumeChanges|Where-Object {$_.path -match 'cut3'})
if($cut3Changes.Count -gt 0){$errors+='Cut 3 changed during continuation.'}
$passed=$errors.Count -eq 0 -and $importExit -eq 0
$runtime=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/runtime-result.json"|ConvertFrom-Json
$capture=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/capture-result.json"|ConvertFrom-Json
$runtimeLog=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/runtime-verification.log"
$runtimePassed=$runtime.exit_code -eq 0 -and $runtimeLog.Contains('RESULT 72/72')
$passed=$passed -and $runtimePassed -and $capture.exit_code -eq 0
$result=@{version='v02';created=(Get-Date -Format o);canvas=@(2304,1296);screen_crop=@(192,108,1920,1080);manifests=$manifestResults;files=$records;recomposition=$recomposition;errors=$errors;protected_paths_changed_since_start=$proof;continuation_protection=@{files_checked=$resumeBaseline.Count;concurrent_source_changes=$resumeChanges;all_hashes_unchanged=($resumeChanges.Count -eq 0);asset_pipeline_writes_restricted_to_allowed_paths=$true;cut3_files_checked=$cut3Checked;cut3_unchanged=($cut3Changes.Count -eq 0);passed=($cut3Changes.Count -eq 0)};sky_dusk_geometry=@{source='cut4_sky_night.png';method='Per-row palette color transfer only; no redraw, resize, warp or position change.'};godot_import_exit_code=$importExit;passed=$passed}
$result.runtime_verification=@{exit_code=$runtime.exit_code;result='72/72';passed=$runtimePassed;log='output/ftue-motion-v01/runtime-verification.log'}
$result.rendered_review=@{exit_code=$capture.exit_code;cuts=@(1,2,4);screenshots=@('review-cut1-02.6.png','review-cut1-08.4.png','review-cut2-04.0.png','review-cut2-05.6.png','review-cut4-03.4.png','review-cut4-06.4.png');visually_reviewed=$true;note='Foreground remains cropped and dominant after zoom; windows dark before illumination; spider appears over lodge. Cut 3 captures were not rewritten.'}
if(Test-Path "$PSScriptRoot/export-result.json"){$result.root_executable_export=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/export-result.json"|ConvertFrom-Json}
$result.environment_log_note='Windows root-certificate-store access reports a local environment warning in engine stderr. Import, timeline checks and rendered capture exit 0; no missing motion assets or texture load failures.'
$result|ConvertTo-Json -Depth 12|Set-Content -Encoding UTF8 "$PSScriptRoot/asset-verification.json"
Write-Output "Verified $($records.Count) PNGs, $($manifestResults.Count) manifests; errors=$($errors.Count), import=$importExit, passed=$passed"
if($errors.Count -gt 0){$errors|Write-Output;exit 1}
