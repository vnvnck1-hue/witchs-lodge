$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
. (Join-Path $PSScriptRoot 'image-utils.ps1')
function Read-Json([string]$path) {Get-Content -LiteralPath (Join-Path $PSScriptRoot $path) -Raw -Encoding UTF8 | ConvertFrom-Json}
function Get-Sha([string]$path) {(Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()}
$taskRecords=@()
foreach($taskRelative in (Read-Json 'delivery-files.json')) {
  $taskPath=Join-Path $taskRoot $taskRelative
  $taskBytes=[System.IO.File]::ReadAllBytes($taskPath)
  $taskImage=[CardImages]::Read($taskPath)
  $taskWidth=$taskImage.Width;$taskHeight=$taskImage.Height
  $taskExpected=@(1024,1536)
  if($taskRelative.Contains('/hand/')) {$taskExpected=@(256,384)}
  $taskCorners=@($taskImage.GetPixel(0,0).A,$taskImage.GetPixel($taskWidth-1,0).A,$taskImage.GetPixel(0,$taskHeight-1).A,$taskImage.GetPixel($taskWidth-1,$taskHeight-1).A)
  $taskInside=@($taskImage.GetPixel(12,12).A,$taskImage.GetPixel($taskWidth-13,12).A,$taskImage.GetPixel(12,$taskHeight-13).A,$taskImage.GetPixel($taskWidth-13,$taskHeight-13).A)
  $taskCenter=$taskImage.GetPixel([int]($taskWidth/2),[int]($taskHeight/2)).A
  $taskOk=$taskWidth -eq $taskExpected[0] -and $taskHeight -eq $taskExpected[1] -and $taskBytes[24] -eq 8 -and $taskBytes[25] -eq 6 -and @($taskCorners | Where-Object {$_ -ne 0}).Count -eq 0 -and $taskCenter -eq 255
  $taskRecords += @{path=$taskRelative;width=$taskWidth;height=$taskHeight;mode='RGBA';channels=@('R','G','B','A');png_bit_depth=[int]$taskBytes[24];png_color_type=[int]$taskBytes[25];corner_alpha=$taskCorners;inset_12_alpha=$taskInside;center_alpha=$taskCenter;sha256=(Get-Sha $taskPath);passed=$taskOk}
  $taskImage.Dispose()
}
if($taskRecords.Count -ne 6) {throw 'Expected exactly 6 delivered PNGs'}
$taskConsistency=@()
$taskImportChecks=@()
foreach($taskId in @('scrap','junk_sack')) {
  $taskArt=Join-Path $taskRoot ('art/cards/scrap-rename-v01/'+$taskId+'.png')
  $taskGame=Join-Path $taskRoot ('godot/assets/cards/'+$taskId+'.png')
  $taskHand=Join-Path $taskRoot ('godot/assets/cards/hand/'+$taskId+'.png')
  $taskGameImage=[CardImages]::Read($taskGame)
  $taskHandImage=[CardImages]::Read($taskHand)
  $taskSmall=[CardImages]::Resize($taskGameImage,256,384)
  $taskScaleDiff=[CardImages]::Diff($taskSmall,$taskHandImage,0,0,256,384)
  $taskSame=(Get-Sha $taskArt) -eq (Get-Sha $taskGame)
  $taskConsistency += @{id=$taskId;source_and_game_sha256_match=$taskSame;hand_scale=0.25;resize='uniform HighQualityBicubic with TileFlipXY edge sampling';hand_pixel_difference=$taskScaleDiff[0];passed=($taskSame -and $taskScaleDiff[0] -eq 0)}
  $taskGameImage.Dispose();$taskHandImage.Dispose();$taskSmall.Dispose()
  foreach($taskPath in @($taskGame,$taskHand)) {
    $taskImport=Get-Content -LiteralPath ($taskPath+'.import') -Raw
    $taskCacheRelative=[regex]::Match($taskImport,'path="res://([^"]+)"').Groups[1].Value
    $taskCache=Join-Path $taskRoot ('godot/'+$taskCacheRelative)
    $taskMd5Path=[System.IO.Path]::ChangeExtension($taskCache,'md5')
    $taskMd5=Get-Content -LiteralPath $taskMd5Path -Raw
    $taskExpectedMd5=[regex]::Match($taskMd5,'source_md5="([^"]+)"').Groups[1].Value
    $taskActualMd5=(Get-FileHash -LiteralPath $taskPath -Algorithm MD5).Hash.ToLowerInvariant()
    $taskImportChecks += @{path=$taskPath.Substring($taskRoot.Length+1).Replace('\','/');sidecar_exists=(Test-Path -LiteralPath ($taskPath+'.import'));cache=$taskCacheRelative;cache_exists=(Test-Path -LiteralPath $taskCache);source_md5=$taskActualMd5;imported_source_md5=$taskExpectedMd5;passed=((Test-Path -LiteralPath $taskCache) -and $taskActualMd5 -eq $taskExpectedMd5)}
  }
}
$taskProtected=Read-Json 'protected-before.json'
$taskHandoffOriginal=[System.IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'handoff-before.md'))
$taskHandoffCurrent=[System.IO.File]::ReadAllBytes((Join-Path $taskRoot 'docs/handoff/codex-scrap-rename-v01.md'))
$taskHandoffPreserved=$taskHandoffCurrent.Length -ge $taskHandoffOriginal.Length
if($taskHandoffPreserved) {
  for($taskByte=0;$taskByte -lt $taskHandoffOriginal.Length;$taskByte++) {
    if($taskHandoffCurrent[$taskByte] -ne $taskHandoffOriginal[$taskByte]) {$taskHandoffPreserved=$false;break}
  }
}
$taskChanged=@()
foreach($taskEntry in $taskProtected) {
  $taskPath=Join-Path $taskRoot $taskEntry.path
  if(-not (Test-Path -LiteralPath $taskPath)) {$taskChanged += @{path=$taskEntry.path;kind='missing'};continue}
  $taskAfter=Get-Sha $taskPath
  if($taskAfter -ne $taskEntry.sha256) {$taskChanged += @{path=$taskEntry.path;before_sha256=$taskEntry.sha256;after_sha256=$taskAfter;kind='authorized task append' };if($taskEntry.path -ne 'docs/handoff/codex-scrap-rename-v01.md') {$taskChanged[-1].kind='concurrent change; not edited or reverted by this task'}}
}
$taskConcurrentDocs=@('docs/handoff/codex-goblin-cards-v01.md','docs/prompts/cards/goblin-v01-prompts.md')
$taskUnexpected=@($taskChanged | Where-Object {$_.path -ne 'docs/handoff/codex-scrap-rename-v01.md' -and $_.path -notin $taskConcurrentDocs})
$taskProtectedCheck=@{baseline_file_count=$taskProtected.Count;handoff_original_bytes_preserved=$taskHandoffPreserved;observed_changes=$taskChanged;unexpected_changes=$taskUnexpected;concurrent_change_note='The previous goblin delivery was being finalized in another session: its handoff received the delivery section and its prompt record was updated. Both changes are retained with before/after hashes. This task did not edit either document. No previous goblin PNGs, code, other card PNGs, catalog, project configuration, or executable changed.';passed=($taskUnexpected.Count -eq 0 -and $taskHandoffPreserved)}
$taskImport=Read-Json 'import-result.json'
$taskTexture=Read-Json 'texture-verification.json'
$taskTextureProcess=Read-Json 'texture-process-result.json'
$taskVisual=Read-Json 'visual-review.json'
$taskPixelDiff=Read-Json 'junk-sack-pixel-diff.json'
$taskPassed=@($taskRecords | Where-Object {-not $_.passed}).Count -eq 0 -and @($taskConsistency | Where-Object {-not $_.passed}).Count -eq 0 -and @($taskImportChecks | Where-Object {-not $_.passed}).Count -eq 0 -and $taskImport.exit_code -eq 0 -and $taskTextureProcess.exit_code -eq 0 -and $taskTexture.passed -and $taskVisual.passed -and $taskPixelDiff.passed -and $taskProtectedCheck.passed
$taskResult=@{task='scrap-rename-v01';verified_at=(Get-Date -Format o);files=$taskRecords;consistency=$taskConsistency;junk_sack_pixel_preservation=$taskPixelDiff;godot_import=$taskImport;imported_source_checks=$taskImportChecks;runtime_texture_checks=$taskTexture;visual_review=$taskVisual;protected_paths=$taskProtectedCheck;notes=@('Godot logs include Failed to read the root certificate store; local texture import and all texture checks succeeded.','No executable export and no commit performed.');passed=$taskPassed}
$taskResult | ConvertTo-Json -Depth 12 | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'verification.json')
Write-Output ('Verification passed='+$taskPassed+'; PNGs='+$taskRecords.Count+'; imported textures='+$taskTexture.checks.Count)
if(-not $taskPassed) {throw 'Delivery verification failed; inspect verification.json'}
