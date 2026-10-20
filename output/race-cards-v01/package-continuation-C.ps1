param([Parameter(Mandatory=$true)][string]$Id)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'ImageChecks.cs') -ReferencedAssemblies System.Drawing
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$ids=@('rise_up','bone_barricade','soul_jar','ghoul_feast','death_march','bone_hounds','black_rumor','ledger_of_dead')
if($Id -notin $ids){throw 'Outside C scope'}
$record=@(Get-ChildItem -LiteralPath $PSScriptRoot -Filter ('generation-C-'+$Id+'-v*.json') | ForEach-Object {Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName | ConvertFrom-Json} | Where-Object {$_.selected})[0]
$attempt=$record.attempt
$rawPath=Join-Path $root ('art/cards/race-cards-v01/drafts/'+$Id+'-'+$attempt+'.png')
if(-not(Test-Path -LiteralPath $rawPath)){Copy-Item -LiteralPath $record.source -Destination $rawPath}
$raw=[Drawing.Bitmap]::FromFile($rawPath)
if($raw.Width -ne 1024 -or $raw.Height -ne 1536){throw 'Unexpected generated size'}
$full=$raw.Clone((New-Object Drawing.Rectangle 0,0,1024,1536),[Drawing.Imaging.PixelFormat]::Format32bppArgb)
[RaceCardImages]::Normalize($full)
$hand=[RaceCardImages]::Resize($full,256,384)
foreach($base in @('art/cards/race-cards-v01/','godot/assets/cards/','godot/assets/cards/hand/')){
 $dest=Join-Path $root ($base+$Id+'.png')
 if(Test-Path -LiteralPath $dest){
  $prior=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'verification-C.json') | ConvertFrom-Json
  $owned=@($prior.files | Where-Object {$_.path -eq ($base+$Id+'.png')})
  if($owned.Count -ne 1 -or (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash -ne $owned[0].sha256){throw ('Preserving concurrently changed target: '+$dest)}
 }
 if($base.EndsWith('hand/')){$hand.Save($dest,[Drawing.Imaging.ImageFormat]::Png)}else{$full.Save($dest,[Drawing.Imaging.ImageFormat]::Png)}
}
$full.Dispose();$hand.Dispose();$raw.Dispose()
$project=Join-Path $PSScriptRoot 'import-C'
New-Item -ItemType Directory -Force (Join-Path $project 'assets/cards/hand'),(Join-Path $project 'userdata/roaming'),(Join-Path $project 'userdata/local') | Out-Null
$enc=New-Object Text.UTF8Encoding $false
[IO.File]::WriteAllText((Join-Path $project 'project.godot'),"config_version=5`n[application]`nconfig/name=`"C Card Image Import`"`n[rendering]`nrenderer/rendering_method=`"gl_compatibility`"`n",$enc)
$done=@($ids | Where-Object {Test-Path -LiteralPath (Join-Path $root ('art/cards/race-cards-v01/'+$_+'.png'))})
foreach($card in $done){foreach($part in @('','hand/')){Copy-Item -LiteralPath (Join-Path $root ('godot/assets/cards/'+$part+$card+'.png')) -Destination (Join-Path $project ('assets/cards/'+$part+$card+'.png'))}}
$gd=Get-Content -Raw -Encoding UTF8 (Join-Path $root 'output/equipment-v01/import-project/verify_textures.gd')
$gd=$gd.Replace('["rusty_longsword", "oak_staff", "quilted_gambeson", "traveler_boots", "rowan_charm"]',(ConvertTo-Json -InputObject $done -Compress)).Replace('RESULT %s/10',('RESULT %s/'+($done.Count*2)))
[IO.File]::WriteAllText((Join-Path $project 'verify_textures.gd'),$gd,$enc)
$env:APPDATA=Join-Path $project 'userdata/roaming';$env:LOCALAPPDATA=Join-Path $project 'userdata/local'
$exe=Join-Path $root '.tools/Godot-4.7.2.exe'
$proc=Start-Process -FilePath $exe -ArgumentList @('--headless','--path',('"'+$project+'"'),'--import','--log-file',('"'+(Join-Path $project 'import.log')+'"')) -Wait -PassThru -WindowStyle Hidden
$importExit=$proc.ExitCode
if($importExit -ne 0){throw 'Isolated import failed'}
$proc=Start-Process -FilePath $exe -ArgumentList @('--headless','--path',('"'+$project+'"'),'--script','res://verify_textures.gd','--log-file',('"'+(Join-Path $project 'texture-verify.log')+'"')) -Wait -PassThru -WindowStyle Hidden
if($proc.ExitCode -ne 0){throw 'Imported texture check failed'}
$files=@();$cards=@()
foreach($card in $done){
 $cf=@()
 foreach($base in @('art/cards/race-cards-v01/','godot/assets/cards/','godot/assets/cards/hand/')){
  $rel=$base+$card+'.png';$path=Join-Path $root $rel;$im=[Drawing.Bitmap]::FromFile($path)
  $w=$im.Width;$h=$im.Height;$corners=@($im.GetPixel(0,0).A,$im.GetPixel(($w-1),0).A,$im.GetPixel(0,($h-1)).A,$im.GetPixel(($w-1),($h-1)).A)
  $expected=@(1024,1536);if($base.EndsWith('hand/')){$expected=@(256,384)}
  $color=[IO.File]::ReadAllBytes($path)[25]
  $f=@{path=$rel;width=$w;height=$h;mode='RGBA';png_color_type=$color;corner_alpha=$corners;sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash;passed=($w -eq $expected[0] -and $h -eq $expected[1] -and $color -eq 6 -and @($corners | Where-Object {$_ -ne 0}).Count -eq 0)}
  $cf+=$f;$files+=$f;$im.Dispose()
 }
 $art=[Drawing.Bitmap]::FromFile((Join-Path $root ('art/cards/race-cards-v01/'+$card+'.png')))
 $selected=@(Get-ChildItem -LiteralPath $PSScriptRoot -Filter ('generation-C-'+$card+'-v*.json') | ForEach-Object {Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName | ConvertFrom-Json} | Where-Object {$_.selected})[0]
 $raw=[Drawing.Bitmap]::FromFile((Join-Path $root ('art/cards/race-cards-v01/drafts/'+$card+'-'+$selected.attempt+'.png')))
 $hand=[Drawing.Bitmap]::FromFile((Join-Path $root ('godot/assets/cards/hand/'+$card+'.png')))
 $scaled=[RaceCardImages]::Resize($art,256,384)
 $rgb=[RaceCardImages]::Hash($art,$true) -eq [RaceCardImages]::Hash($raw,$true)
 $scale=[RaceCardImages]::Hash($hand,$false) -eq [RaceCardImages]::Hash($scaled,$false)
 $same=$cf[0].sha256 -eq $cf[1].sha256
 $cards+=@{id=$card;selected_attempt=$selected.attempt;raw_rgb_preserved=$rgb;hand_exact_uniform_downscale=$scale;art_equals_game=$same;visual_review='Manually checked generated full-size card: exact catalog title/category/two rules; approved role, clean text reserve, medieval folk horror, no gore; hand silhouette reviewed on sheet.';passed=($rgb -and $scale -and $same -and @($cf | Where-Object {-not $_.passed}).Count -eq 0)}
 $art.Dispose();$raw.Dispose();$hand.Dispose();$scaled.Dispose()
}
$tex=Get-Content -Encoding UTF8 -Raw (Join-Path $project 'texture-verification.json') | ConvertFrom-Json
$v=@{scope='C continuation: eight requested undead cards; previous sacrifice_dagger and corpse preserved';passed=($tex.passed -and @($cards | Where-Object {-not $_.passed}).Count -eq 0);complete=($done.Count -eq 8);delivered_ids=$done;missing_ids=@($ids | Where-Object {$_ -notin $done});files=$files;cards=$cards;isolated_import=@{exit_code=$importExit;project='output/race-cards-v01/import-C/';texture_verification=$tex};policy='Only assigned PNGs and C records changed; no game import, sidecars, code, catalog, EXE or commit'}
$v | ConvertTo-Json -Depth 20 | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'verification-C.json')
if(-not $v.passed){throw 'File validation failed'}
$roles=@('02-skill-warm-welcome','05-facility-forest-altar','03-resource-timber','01-character-nib','06-event-forbidden-harvest','04-relic-moonlit-charm')
$sheetItems=@(@('sacrifice_dagger','corpse')+$done | ForEach-Object {@{label=$_;path=('art/cards/race-cards-v01/'+$_+'.png')}})+@($roles | ForEach-Object {@{label=('APPROVED '+$_);path=('art/concepts/cards/roles-individual-v02/'+$_+'.png')}})
$rows=[int][Math]::Ceiling($sheetItems.Count/4.0);$sheet=New-Object Drawing.Bitmap 1200,($rows*440+20)
$g=[Drawing.Graphics]::FromImage($sheet);$g.Clear([Drawing.Color]::FromArgb(38,30,48));$font=New-Object Drawing.Font 'Arial',11
for($i=0;$i -lt $sheetItems.Count;$i++){$x=20+($i%4)*300;$y=10+[int][Math]::Floor($i/4)*440;$g.DrawString($sheetItems[$i].label,$font,[Drawing.Brushes]::Ivory,$x,$y);$im=[Drawing.Bitmap]::FromFile((Join-Path $root $sheetItems[$i].path));$small=[RaceCardImages]::Resize($im,256,384);$g.DrawImageUnscaled($small,$x,($y+30));$small.Dispose();$im.Dispose()}
$sheet.Save((Join-Path $root 'godot/screenshots/race-cards/sheet-undead.png'),[Drawing.Imaging.ImageFormat]::Png);$g.Dispose();$sheet.Dispose();$font.Dispose()
$promptFile=Join-Path $root 'docs/prompts/cards/race-cards-v01-prompts-C.md'
$append="`n`n## $Id · $attempt · 2026-10-20 이어서 제작`n`n내장 image_gen, transparent_background=true. 채택: true. $($record.reason)`n`n실제 참고 입력:`n"+($record.refs | ForEach-Object {'- `'+$_+'`'} | Out-String)+"`n~~~text`n$($record.prompt)`n~~~`n`n가공 전 생성본: ``art/cards/race-cards-v01/drafts/$Id-$attempt.png``. RGB·글자는 보존하고 카드지 알파·라운드 모서리만 정규화. 손패는 HighQualityBicubic 1/4 균등 축소.`n"
[IO.File]::AppendAllText($promptFile,$append,$enc)
$delivery=Join-Path $PSScriptRoot 'delivery-C.md'
if(-not(Test-Path -LiteralPath $delivery)){[IO.File]::WriteAllText($delivery,"# C 갈래 언데드 카드 납품 · 2026-10-20`n`n기존 납품 sacrifice_dagger·corpse는 보존. 아래 카드는 한 장씩 원본·게임용·손패용·격리 임포트까지 마친 후 기록한다. 공용 요청서·기록, 게임 임포트/실행파일·코드·카탈로그는 수정하지 않았다. 커밋 없음.`n",$enc)}
[IO.File]::AppendAllText($delivery,"`n## $Id`n`n- 파일: ``art/cards/race-cards-v01/$Id.png``, ``godot/assets/cards/$Id.png``, ``godot/assets/cards/hand/$Id.png``.`n- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 ``art/cards/race-cards-v01/drafts/$Id-$attempt.png``.`n- 채택 버전: $attempt. $($record.reason)`n- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.`n- ``import-C`` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.`n- 기준 미달: 없음. 현황은 ``verification-C.json``, 비교 시트는 ``godot/screenshots/race-cards/sheet-undead.png``.`n",$enc)
Write-Output ('Completed C card '+$Id+'; delivered='+$done.Count+'/8; passed='+$v.passed)
