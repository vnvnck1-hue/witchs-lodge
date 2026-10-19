$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'ImageChecks.cs') -ReferencedAssemblies System.Drawing
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskPlan=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'production-plan-v02.json') | ConvertFrom-Json
$taskVisual=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'visual-review.json') | ConvertFrom-Json
$taskRecords=@(Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'generation-*-v*.json' | ForEach-Object {Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName | ConvertFrom-Json})
$taskFiles=@();$taskCards=@();$taskMissing=@();$taskGroups=@()
foreach($taskEntry in $taskPlan){
 $taskId=$taskEntry.id;$taskArt=Join-Path $taskRoot ('art/cards/race-cards-v01/'+$taskId+'.png')
 if(-not(Test-Path -LiteralPath $taskArt)){$taskMissing+=$taskId;continue}
 $taskCardFiles=@()
 foreach($taskBase in @('art/cards/race-cards-v01/','godot/assets/cards/','godot/assets/cards/hand/')){
  $taskRel=$taskBase+$taskId+'.png';$taskPath=Join-Path $taskRoot $taskRel
  $taskImage=[System.Drawing.Bitmap]::FromFile($taskPath);$taskW=$taskImage.Width;$taskH=$taskImage.Height
  $taskCorners=@($taskImage.GetPixel(0,0).A,$taskImage.GetPixel(($taskW-1),0).A,$taskImage.GetPixel(0,($taskH-1)).A,$taskImage.GetPixel(($taskW-1),($taskH-1)).A)
  $taskExpected=@(1024,1536);if($taskBase.EndsWith('hand/')){$taskExpected=@(256,384)}
  $taskColorType=[IO.File]::ReadAllBytes($taskPath)[25]
  $taskOk=$taskW -eq $taskExpected[0] -and $taskH -eq $taskExpected[1] -and $taskColorType -eq 6 -and @($taskCorners | Where-Object {$_ -ne 0}).Count -eq 0
  $taskRecord=@{path=$taskRel;width=$taskW;height=$taskH;mode='RGBA';png_color_type=$taskColorType;channels=@('R','G','B','A');corner_alpha=$taskCorners;sha256=(Get-FileHash -LiteralPath $taskPath -Algorithm SHA256).Hash;passed=$taskOk}
  $taskFiles+=$taskRecord;$taskCardFiles+=$taskRecord;$taskImage.Dispose()
 }
 $taskFull=[System.Drawing.Bitmap]::FromFile($taskArt)
 $taskHand=[System.Drawing.Bitmap]::FromFile((Join-Path $taskRoot ('godot/assets/cards/hand/'+$taskId+'.png')))
 $taskScaled=[RaceCardImages]::Resize($taskFull,256,384)
 $taskExact=[RaceCardImages]::Hash($taskHand,$false) -eq [RaceCardImages]::Hash($taskScaled,$false)
 $taskRawRecord=@($taskRecords | Where-Object {$_.id -eq $taskId -and $_.selected})[0]
 $taskRaw=[System.Drawing.Bitmap]::FromFile((Join-Path $taskRoot ('art/cards/race-cards-v01/drafts/'+$taskId+'-'+$taskRawRecord.attempt+'.png')))
 $taskRgb=[RaceCardImages]::Hash($taskFull,$true) -eq [RaceCardImages]::Hash($taskRaw,$true)
 $taskVisualEntry=@($taskVisual.cards | Where-Object {$_.id -eq $taskId})[0]
 $taskEqual=$taskCardFiles[0].sha256 -eq $taskCardFiles[1].sha256
 $taskCards+=@{id=$taskId;group=$taskEntry.group;selected_attempt=$taskRawRecord.attempt;art_equals_game=$taskEqual;raw_rgb_preserved=$taskRgb;hand_exact_uniform_downscale=$taskExact;visual=$taskVisualEntry;passed=($taskExact -and $taskRgb -and $taskEqual -and $taskVisualEntry.passed -and @($taskCardFiles | Where-Object {-not $_.passed}).Count -eq 0)}
 $taskFull.Dispose();$taskHand.Dispose();$taskScaled.Dispose();$taskRaw.Dispose()
}
foreach($taskGroup in @($taskCards.group | Select-Object -Unique)){
 $taskImport=Join-Path $PSScriptRoot ('import-'+$taskGroup)
 $taskResult=Get-Content -Raw -Encoding UTF8 (Join-Path $taskImport 'import-result.json') | ConvertFrom-Json
 $taskTextures=Get-Content -Raw -Encoding UTF8 (Join-Path $taskImport 'texture-verification.json') | ConvertFrom-Json
 $taskGroupCards=@($taskCards | Where-Object {$_.group -eq $taskGroup})
 $taskGroups+=@{group=$taskGroup;count=$taskGroupCards.Count;import_result=$taskResult;imported_textures=$taskTextures;passed=($taskResult.exit_code -eq 0 -and $taskTextures.passed -and @($taskGroupCards | Where-Object {-not $_.passed}).Count -eq 0)}
}
$taskBefore=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'protected-before.json') | ConvertFrom-Json
$taskChanges=@();foreach($taskP in $taskBefore.PSObject.Properties){$taskPath=Join-Path $taskRoot $taskP.Name;$taskHash=$null;if(Test-Path -LiteralPath $taskPath){$taskHash=(Get-FileHash -LiteralPath $taskPath -Algorithm SHA256).Hash};if($taskHash -ne $taskP.Value){$taskChanges+=@{path=$taskP.Name;before=$taskP.Value;after=$taskHash;action='observed only, never reverted'}}}
$taskDeliveredPass=$taskCards.Count -gt 0 -and @($taskGroups | Where-Object {-not $_.passed}).Count -eq 0
@{passed=$taskDeliveredPass;complete=($taskMissing.Count -eq 0);scope='Delivered groups only; missing IDs explicitly listed';delivered_count=$taskCards.Count;missing_ids=$taskMissing;files=$taskFiles;cards=$taskCards;groups=$taskGroups;protected_changes_observed=$taskChanges;policy='No commit, no EXE export, no game code/catalog edits';generation_count=$taskRecords.Count} | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'verification.json')
Write-Output ('Verification: delivered='+$taskCards.Count+' missing='+$taskMissing.Count+' passed='+$taskDeliveredPass)
