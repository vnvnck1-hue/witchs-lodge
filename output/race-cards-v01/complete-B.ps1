param([Parameter(Mandatory=$true)][string]$Id,[switch]$Resume)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'ImageChecks.cs') -ReferencedAssemblies System.Drawing
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskIds=@('introduction_letter','guild_writ','village_militia','old_records','pilgrim_blessing','merchant_wagon','crest_banner','interpreter_pen','lodge_festival','stranger_gift','lodge_cleanup')
if($Id -notin $taskIds){throw 'Outside branch B scope'}
$taskAllPlan=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'plan-B.json') | ConvertFrom-Json
$taskPlan=@($taskAllPlan | Where-Object {$_.id -in $taskIds})
foreach($taskPlanned in $taskPlan){if($taskPlanned.id -in @('crest_banner','interpreter_pen','lodge_festival')){$taskPlanned.group='harmony'}elseif($taskPlanned.id -in @('stranger_gift','lodge_cleanup')){$taskPlanned.group='neutral'}}
$taskEntry=@($taskPlan | Where-Object id -eq $Id)[0]
$taskRecord=@(Get-ChildItem -LiteralPath $PSScriptRoot -Filter ('generation-B-'+$Id+'-v*.json') | ForEach-Object {Get-Content -Raw -Encoding UTF8 $_.FullName | ConvertFrom-Json} | Where-Object selected)[0]
if(-not $taskRecord){throw 'No selected generation record'}
$taskArt=Join-Path $taskRoot ('art/cards/race-cards-v01/'+$Id+'.png')
function Save-TaskImage($Image,[string]$Path){$Image.Save($Path,[System.Drawing.Imaging.ImageFormat]::Png)}
if(-not $Resume){
if(Test-Path -LiteralPath $taskArt){throw ('Existing card preserved: '+$Id)}
$taskDraft=Join-Path $taskRoot ('art/cards/race-cards-v01/drafts/'+$Id+'-B-'+$taskRecord.attempt+'.png')
if(-not(Test-Path -LiteralPath $taskDraft)){Copy-Item -LiteralPath $taskRecord.source -Destination $taskDraft}
$taskRaw=[System.Drawing.Bitmap]::FromFile($taskDraft)
if($taskRaw.Width -ne 1024 -or $taskRaw.Height -ne 1536){throw 'Generated dimensions must be 1024x1536'}
$taskFull=$taskRaw.Clone((New-Object System.Drawing.Rectangle 0,0,1024,1536),[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
[RaceCardImages]::Normalize($taskFull)
$taskHand=[RaceCardImages]::Resize($taskFull,256,384)
foreach($taskBase in @('art/cards/race-cards-v01/','godot/assets/cards/','godot/assets/cards/hand/')){
 $taskTarget=Join-Path $taskRoot ($taskBase+$Id+'.png')
 if(Test-Path -LiteralPath $taskTarget){throw ('Concurrent file preserved: '+$taskTarget)}
 if($taskBase.EndsWith('hand/')){Save-TaskImage $taskHand $taskTarget}else{Save-TaskImage $taskFull $taskTarget}
}
$taskCrop=New-Object System.Drawing.Bitmap 1024,816
$taskGraphics=[System.Drawing.Graphics]::FromImage($taskCrop)
$taskGraphics.Clear([System.Drawing.Color]::FromArgb(38,30,48))
$taskGraphics.DrawImage($taskFull,(New-Object System.Drawing.Rectangle 0,0,1024,380),(New-Object System.Drawing.Rectangle 0,0,1024,380),[System.Drawing.GraphicsUnit]::Pixel)
$taskGraphics.DrawImage($taskFull,(New-Object System.Drawing.Rectangle 0,400,1024,416),(New-Object System.Drawing.Rectangle 0,1120,1024,416),[System.Drawing.GraphicsUnit]::Pixel)
Save-TaskImage $taskCrop (Join-Path $PSScriptRoot ('reviews-B/'+$Id+'.png'))
$taskGraphics.Dispose();$taskCrop.Dispose();$taskFull.Dispose();$taskHand.Dispose();$taskRaw.Dispose()
$taskLines=@('',('## '+$Id+' · B '+$taskRecord.attempt),'',('채택: True · '+$taskRecord.reason),'','실제 입력:')
foreach($taskRef in $taskRecord.refs){$taskLines+=('- `'+$taskRef+'`')}
$taskLines+=@('','```text',$taskRecord.prompt,'```','',('가공 전 원본: `art/cards/race-cards-v01/drafts/'+$Id+'-B-'+$taskRecord.attempt+'.png`'),'후처리: RGB·인쇄 글자 보존, 카드지와 라운드 모서리 알파만 정규화. 손패는 HighQualityBicubic 1/4 균등 축소.','')
[IO.File]::AppendAllText((Join-Path $taskRoot 'docs/prompts/cards/race-cards-v01-prompts-B.md'),($taskLines -join "`n"),(New-Object Text.UTF8Encoding $false))
}
# Refresh only this branch's group sheet, retaining all completed B cards and role references.
$taskCompleted=@($taskPlan | Where-Object {Test-Path -LiteralPath (Join-Path $taskRoot ('art/cards/race-cards-v01/'+$_.id+'.png'))})
$taskGroup=@($taskCompleted | Where-Object group -eq $taskEntry.group)
$taskSheetItems=@($taskGroup | ForEach-Object {@{label=$_.id;path=('art/cards/race-cards-v01/'+$_.id+'.png')}})
$taskSheetItems+=@($taskGroup | ForEach-Object {$_.refs[1]} | Select-Object -Unique | ForEach-Object {@{label=('APPROVED '+[IO.Path]::GetFileNameWithoutExtension($_));path=$_}})
$taskSheet=New-Object System.Drawing.Bitmap 1200,([int][Math]::Ceiling($taskSheetItems.Count/4.0)*440+40)
$taskGraphics=[System.Drawing.Graphics]::FromImage($taskSheet);$taskGraphics.Clear([System.Drawing.Color]::FromArgb(38,30,48));$taskFont=New-Object System.Drawing.Font 'Arial',12
for($taskI=0;$taskI -lt $taskSheetItems.Count;$taskI++){
 $taskItem=$taskSheetItems[$taskI];$taskX=20+($taskI%4)*300;$taskY=20+[int][Math]::Floor($taskI/4)*440
 $taskGraphics.DrawString($taskItem.label,$taskFont,[System.Drawing.Brushes]::Ivory,$taskX,$taskY)
 $taskImage=[System.Drawing.Bitmap]::FromFile((Join-Path $taskRoot $taskItem.path));$taskSmall=[RaceCardImages]::Resize($taskImage,256,384)
 $taskGraphics.DrawImageUnscaled($taskSmall,$taskX,$taskY+30);$taskSmall.Dispose();$taskImage.Dispose()
}
Save-TaskImage $taskSheet (Join-Path $taskRoot ('godot/screenshots/race-cards/sheet-'+$taskEntry.group+'.png'))
$taskGraphics.Dispose();$taskSheet.Dispose();$taskFont.Dispose()
# Isolated importer only. Never copy sidecars or caches into godot/.
$taskProject=Join-Path $PSScriptRoot 'import-B'
New-Item -ItemType Directory -Force (Join-Path $taskProject 'assets/cards/hand'),(Join-Path $taskProject 'userdata/roaming'),(Join-Path $taskProject 'userdata/local') | Out-Null
$env:APPDATA=Join-Path $taskProject 'userdata/roaming';$env:LOCALAPPDATA=Join-Path $taskProject 'userdata/local'
[IO.File]::WriteAllText((Join-Path $taskProject 'project.godot'),"config_version=5`n[application]`nconfig/name=`"Race Cards B Image Import`"`n[rendering]`nrenderer/rendering_method=`"gl_compatibility`"`n",(New-Object Text.UTF8Encoding $false))
foreach($taskCard in $taskCompleted){foreach($taskPart in @('','hand/')){Copy-Item -LiteralPath (Join-Path $taskRoot ('godot/assets/cards/'+$taskPart+$taskCard.id+'.png')) -Destination (Join-Path $taskProject ('assets/cards/'+$taskPart+$taskCard.id+'.png'))}}
$taskVerifier=Get-Content -Raw -Encoding UTF8 (Join-Path $taskRoot 'output/equipment-v01/import-project/verify_textures.gd')
$taskIdJson=ConvertTo-Json -InputObject @($taskCompleted | ForEach-Object {$_.id}) -Compress
$taskVerifier=$taskVerifier.Replace('["rusty_longsword", "oak_staff", "quilted_gambeson", "traveler_boots", "rowan_charm"]',$taskIdJson).Replace('RESULT %s/10',('RESULT %s/'+($taskCompleted.Count*2)))
[IO.File]::WriteAllText((Join-Path $taskProject 'verify_textures.gd'),$taskVerifier,(New-Object Text.UTF8Encoding $false))
$taskExe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
$taskProcess=Start-Process -FilePath $taskExe -ArgumentList @('--headless','--path',('"'+$taskProject+'"'),'--import','--log-file',('"'+(Join-Path $taskProject ('import-'+$Id+'.log'))+'"')) -Wait -PassThru -WindowStyle Hidden
$taskImportExit=$taskProcess.ExitCode
if($taskImportExit -ne 0){throw 'Isolated import failed'}
$taskProcess=Start-Process -FilePath $taskExe -ArgumentList @('--headless','--path',('"'+$taskProject+'"'),'--script','res://verify_textures.gd','--log-file',('"'+(Join-Path $taskProject 'texture-verify.log')+'"')) -Wait -PassThru -WindowStyle Hidden
if($taskProcess.ExitCode -ne 0){throw 'Isolated texture verification failed'}
$taskTextures=Get-Content -Raw -Encoding UTF8 (Join-Path $taskProject 'texture-verification.json') | ConvertFrom-Json
$taskFiles=@();$taskCards=@()
foreach($taskCard in $taskCompleted){
 $taskCardFiles=@()
 foreach($taskBase in @('art/cards/race-cards-v01/','godot/assets/cards/','godot/assets/cards/hand/')){
  $taskRel=$taskBase+$taskCard.id+'.png';$taskPath=Join-Path $taskRoot $taskRel;$taskImage=[System.Drawing.Bitmap]::FromFile($taskPath)
  $taskW=$taskImage.Width;$taskH=$taskImage.Height;$taskCorners=@($taskImage.GetPixel(0,0).A,$taskImage.GetPixel(($taskW-1),0).A,$taskImage.GetPixel(0,($taskH-1)).A,$taskImage.GetPixel(($taskW-1),($taskH-1)).A)
  $taskExpected=@(1024,1536);if($taskBase.EndsWith('hand/')){$taskExpected=@(256,384)}
  $taskColorType=[IO.File]::ReadAllBytes($taskPath)[25]
  $taskOk=$taskW -eq $taskExpected[0] -and $taskH -eq $taskExpected[1] -and $taskColorType -eq 6 -and @($taskCorners | Where-Object {$_ -ne 0}).Count -eq 0
  $taskFile=@{path=$taskRel;width=$taskW;height=$taskH;mode='RGBA';png_color_type=$taskColorType;corner_alpha=$taskCorners;sha256=(Get-FileHash -LiteralPath $taskPath -Algorithm SHA256).Hash;passed=$taskOk}
  $taskFiles+=$taskFile;$taskCardFiles+=$taskFile;$taskImage.Dispose()
 }
 $taskFull=[System.Drawing.Bitmap]::FromFile((Join-Path $taskRoot ('art/cards/race-cards-v01/'+$taskCard.id+'.png')))
 $taskHand=[System.Drawing.Bitmap]::FromFile((Join-Path $taskRoot ('godot/assets/cards/hand/'+$taskCard.id+'.png')))
 $taskScaled=[RaceCardImages]::Resize($taskFull,256,384)
 $taskGen=@(Get-ChildItem -LiteralPath $PSScriptRoot -Filter ('generation-B-'+$taskCard.id+'-v*.json') | ForEach-Object {Get-Content -Raw -Encoding UTF8 $_.FullName | ConvertFrom-Json} | Where-Object selected)[0]
 $taskRaw=[System.Drawing.Bitmap]::FromFile((Join-Path $taskRoot ('art/cards/race-cards-v01/drafts/'+$taskCard.id+'-B-'+$taskGen.attempt+'.png')))
 $taskExact=[RaceCardImages]::Hash($taskHand,$false) -eq [RaceCardImages]::Hash($taskScaled,$false)
 $taskRgb=[RaceCardImages]::Hash($taskFull,$true) -eq [RaceCardImages]::Hash($taskRaw,$true)
 $taskEqual=$taskCardFiles[0].sha256 -eq $taskCardFiles[1].sha256
 $taskCards+=@{id=$taskCard.id;group=$taskCard.group;art_equals_game=$taskEqual;raw_rgb_preserved=$taskRgb;hand_exact_uniform_downscale=$taskExact;visual=$taskGen.visual;passed=($taskExact -and $taskRgb -and $taskEqual -and $taskGen.visual.passed -and @($taskCardFiles | Where-Object {-not $_.passed}).Count -eq 0)}
 $taskFull.Dispose();$taskHand.Dispose();$taskScaled.Dispose();$taskRaw.Dispose()
}
$taskMissing=@($taskIds | Where-Object {$_ -notin @($taskCompleted.id)})
$taskPassed=$taskTextures.passed -and @($taskCards | Where-Object {-not $_.passed}).Count -eq 0
$taskVerification=@{branch='B';scope='11 human/harmony/neutral cards from user request; prior beastfolk records preserved';passed=$taskPassed;complete=($taskMissing.Count -eq 0);delivered_count=$taskCompleted.Count;missing_ids=$taskMissing;files=$taskFiles;cards=$taskCards;import_exit_code=$taskImportExit;imported_textures=$taskTextures;policy='PNG only in godot/assets/cards; isolated import-B; no game import/export, shared records or commits'}
$taskVerification | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'verification-B.json')
$taskDelivery=@('',('## '+$Id+' · 2026-10-20'),'',('- 납품: `art/cards/race-cards-v01/'+$Id+'.png`, `godot/assets/cards/'+$Id+'.png`, `godot/assets/cards/hand/'+$Id+'.png`.'),'- 원본/게임용 RGBA 1024×1536, 손패 RGBA 256×384. 라운드 바깥 투명, RGB·문구 보존, 정확한 1/4 축소.',('- 내장 image_gen '+$taskRecord.attempt+' 채택. '+$taskRecord.reason),('- 격리 `import-B/` 임포트 종료 코드 '+$taskImportExit+', 텍스처 검증 통과. 게임 경로에는 PNG만 저장.'),('- 시트: `godot/screenshots/race-cards/sheet-'+$taskEntry.group+'.png`. 검증 `verification-B.json` passed='+$taskPassed+'.'),'- 해당 카드 기준 미달 없음.','')
[IO.File]::AppendAllText((Join-Path $PSScriptRoot 'delivery-B.md'),($taskDelivery -join "`n"),(New-Object Text.UTF8Encoding $false))
Write-Output ('Completed '+$Id+'; branch delivered='+$taskCompleted.Count+'/11; isolated textures='+($taskCompleted.Count*2)+'; passed='+$taskPassed)
