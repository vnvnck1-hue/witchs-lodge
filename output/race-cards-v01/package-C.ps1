param([Parameter(Mandatory=$true)][string]$Group)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'ImageChecks.cs') -ReferencedAssemblies System.Drawing
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskPlan=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'plan-C.json') | ConvertFrom-Json
$taskRecords=@(Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'generation-C-*-v*.json' | ForEach-Object {Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName | ConvertFrom-Json})
$taskBefore=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'targets-before.json') | ConvertFrom-Json
$taskOwned=@{}
if(Test-Path (Join-Path $PSScriptRoot 'owned-hashes-C.json')){(Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'owned-hashes-C.json') | ConvertFrom-Json).PSObject.Properties | ForEach-Object {$taskOwned[$_.Name]=$_.Value}}
$taskArt=Join-Path $taskRoot 'art/cards/race-cards-v01'
New-Item -ItemType Directory -Force (Join-Path $taskArt 'drafts'),(Join-Path $PSScriptRoot 'reviews-C'),(Join-Path $taskRoot 'godot/screenshots/race-cards') | Out-Null
function Save-TaskImage($Image,[string]$Path){$Image.Save($Path,[System.Drawing.Imaging.ImageFormat]::Png)}
function Resize-TaskImage($Image,[int]$Width,[int]$Height){
 $taskResult=New-Object System.Drawing.Bitmap $Width,$Height,([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
 $taskG=[System.Drawing.Graphics]::FromImage($taskResult)
 $taskG.CompositingMode=[System.Drawing.Drawing2D.CompositingMode]::SourceCopy
 $taskG.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
 $taskG.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
 $taskAttributes=New-Object System.Drawing.Imaging.ImageAttributes
 $taskAttributes.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
 $taskG.DrawImage($Image,(New-Object System.Drawing.Rectangle 0,0,$Width,$Height),0,0,$Image.Width,$Image.Height,[System.Drawing.GraphicsUnit]::Pixel,$taskAttributes)
 $taskG.Dispose();$taskAttributes.Dispose();return $taskResult
}
foreach($taskRecord in $taskRecords){$taskDraft=Join-Path $taskArt ('drafts/'+$taskRecord.id+'-'+$taskRecord.attempt+'.png');if(-not(Test-Path -LiteralPath $taskDraft)){Copy-Item -LiteralPath $taskRecord.source -Destination $taskDraft}}
$taskItems=@($taskPlan | Where-Object {$_.id -in @($taskRecords | Where-Object {$_.selected} | ForEach-Object {$_.id})})
foreach($taskEntry in $taskItems){
 $taskSelected=@($taskRecords | Where-Object {$_.id -eq $taskEntry.id -and $_.selected})
 if($taskSelected.Count -ne 1){throw ('Expected one selected source: '+$taskEntry.id)}
 $taskRaw=[System.Drawing.Bitmap]::FromFile((Join-Path $taskArt ('drafts/'+$taskEntry.id+'-'+$taskSelected[0].attempt+'.png')))
 if($taskRaw.Width -ne 1024 -or $taskRaw.Height -ne 1536){throw ('Wrong source dimensions '+$taskEntry.id)}
 $taskFull=$taskRaw.Clone((New-Object System.Drawing.Rectangle 0,0,1024,1536),[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
 # Preserve every RGB value; normalize only opaque stock and anti-aliased rounded corner alpha.
 [RaceCardImages]::Normalize($taskFull)
 $taskHand=Resize-TaskImage $taskFull 256 384
 foreach($taskBase in @('art/cards/race-cards-v01/','godot/assets/cards/','godot/assets/cards/hand/')){
  $taskRel=$taskBase+$taskEntry.id+'.png';$taskTarget=Join-Path $taskRoot $taskRel
  if(Test-Path -LiteralPath $taskTarget){if(-not $taskOwned.ContainsKey($taskRel) -or (Get-FileHash -LiteralPath $taskTarget -Algorithm SHA256).Hash -ne $taskOwned[$taskRel]){throw ('Target changed; preserve concurrent file: '+$taskRel)}}
  if($taskBase.EndsWith('hand/')){Save-TaskImage $taskHand $taskTarget}else{Save-TaskImage $taskFull $taskTarget}
  $taskOwned[$taskRel]=(Get-FileHash -LiteralPath $taskTarget -Algorithm SHA256).Hash
 }
 $taskReview=New-Object System.Drawing.Bitmap 1024,816
 $taskG=[System.Drawing.Graphics]::FromImage($taskReview);$taskG.Clear([System.Drawing.Color]::FromArgb(38,30,48))
 $taskG.DrawImage($taskFull,(New-Object System.Drawing.Rectangle 0,0,1024,380),(New-Object System.Drawing.Rectangle 0,0,1024,380),[System.Drawing.GraphicsUnit]::Pixel)
 $taskG.DrawImage($taskFull,(New-Object System.Drawing.Rectangle 0,400,1024,416),(New-Object System.Drawing.Rectangle 0,1120,1024,416),[System.Drawing.GraphicsUnit]::Pixel)
 Save-TaskImage $taskReview (Join-Path $PSScriptRoot ('reviews-C/'+$taskEntry.id+'.png'))
 $taskG.Dispose();$taskReview.Dispose();$taskFull.Dispose();$taskHand.Dispose();$taskRaw.Dispose()
}
$taskRefs=@($taskItems | ForEach-Object {$_.refs[0]} | Select-Object -Unique)
$taskSheetItems=@($taskItems | ForEach-Object {@{label=$_.id;path=('art/cards/race-cards-v01/'+$_.id+'.png')}})+@($taskRefs | ForEach-Object {@{label=('APPROVED '+[IO.Path]::GetFileNameWithoutExtension($_));path=$_}})
$taskRows=[int][Math]::Ceiling($taskSheetItems.Count/4.0)
$taskSheet=New-Object System.Drawing.Bitmap 1200,($taskRows*440+60)
$taskG=[System.Drawing.Graphics]::FromImage($taskSheet);$taskG.Clear([System.Drawing.Color]::FromArgb(38,30,48));$taskFont=New-Object System.Drawing.Font 'Arial',12
for($taskI=0;$taskI -lt $taskSheetItems.Count;$taskI++){
 $taskItem=$taskSheetItems[$taskI];$taskX=20+($taskI%4)*300;$taskY=20+[int][Math]::Floor($taskI/4)*440
 $taskG.DrawString($taskItem.label,$taskFont,[System.Drawing.Brushes]::Ivory,$taskX,$taskY)
 $taskImage=[System.Drawing.Bitmap]::FromFile((Join-Path $taskRoot $taskItem.path));$taskSmall=Resize-TaskImage $taskImage 256 384
 $taskG.DrawImageUnscaled($taskSmall,$taskX,$taskY+30);$taskSmall.Dispose();$taskImage.Dispose()
}
Save-TaskImage $taskSheet (Join-Path $taskRoot ('godot/screenshots/race-cards/sheet-'+$Group+'.png'));$taskG.Dispose();$taskSheet.Dispose();$taskFont.Dispose()
$taskLines=New-Object System.Collections.Generic.List[string]
$taskLines.Add('# 종족·언데드·화합 카드 v01 · 실제 생성 프롬프트')
$taskLines.Add('');$taskLines.Add('내장 image_gen만 사용. 모든 호출 transparent_background=true. 참고 시트는 원본 비율 유지 배열이며 원본 초상은 변경하지 않음.');$taskLines.Add('')
foreach($taskRecord in $taskRecords){$taskLines.Add('## '+$taskRecord.id+' · '+$taskRecord.attempt);$taskLines.Add('');$taskLines.Add('채택: '+$taskRecord.selected+' · 이유: '+$taskRecord.reason);$taskLines.Add('');foreach($taskRef in $taskRecord.refs){$taskLines.Add('- `'+$taskRef+'`')};$taskLines.Add('');$taskLines.Add('```text');$taskLines.Add($taskRecord.prompt);$taskLines.Add('```');$taskLines.Add('');$taskLines.Add('가공 전 원본: `art/cards/race-cards-v01/drafts/'+$taskRecord.id+'-'+$taskRecord.attempt+'.png`');$taskLines.Add('')}
$taskLines.Add('후처리: RGB·그림·글자 변경 없이 카드지 알파와 40px 라운드 모서리만 정규화. 손패는 System.Drawing HighQualityBicubic으로 정확히 1/4 균등 축소. 모든 생성본을 drafts에 보존.');
[IO.File]::WriteAllLines((Join-Path $taskRoot 'docs/prompts/cards/race-cards-v01-prompts-C.md'),$taskLines,(New-Object Text.UTF8Encoding $false))
$taskOwned | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'owned-hashes-C.json')
Write-Output ('Packaged '+$Group+': '+$taskItems.Count+' cards; raw sources, 3 PNGs/card, 1:1 review crops, contact sheet and prompt log.')
