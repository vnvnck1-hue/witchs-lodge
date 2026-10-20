param([Parameter(Mandatory=$true)][string]$Id,[Parameter(Mandatory=$true)][string]$Attempt)
$ErrorActionPreference='Stop'
$allowed=@('war_drum','feast_table','blood_oath','bone_throw','victory_roar','ancestor_path','ash_sigil','spit_roast','battle_ration')
if($Id -notin $allowed){throw 'Out of A scope'}
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$utf8=New-Object Text.UTF8Encoding $false
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'ImageChecks.cs') -ReferencedAssemblies System.Drawing
function Write-Json($Path,$Value){[IO.File]::WriteAllText($Path,($Value|ConvertTo-Json -Depth 20),$utf8)}
function Save-Png($Im,$Path){$Im.Save($Path,[System.Drawing.Imaging.ImageFormat]::Png)}
$recordPath=Join-Path $PSScriptRoot ('generation-A-'+$Id+'-'+$Attempt+'.json')
$record=Get-Content -Raw -Encoding UTF8 $recordPath|ConvertFrom-Json
$art=Join-Path $taskRoot 'art/cards/race-cards-v01'
$targets=@('art/cards/race-cards-v01/','godot/assets/cards/','godot/assets/cards/hand/')|ForEach-Object {Join-Path $taskRoot ($_+$Id+'.png')}
$draft=Join-Path $art ('drafts/A-'+$Id+'-'+$Attempt+'.png')
if(-not(Test-Path -LiteralPath $draft)){Copy-Item -LiteralPath $record.source -Destination $draft}
$raw=[System.Drawing.Bitmap]::FromFile($draft)
if($raw.Width -ne 1024 -or $raw.Height -ne 1536){throw 'Wrong raw size'}
$full=$raw.Clone((New-Object System.Drawing.Rectangle 0,0,1024,1536),[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
[RaceCardImages]::Normalize($full)
if([RaceCardImages]::Hash($raw,$true) -ne [RaceCardImages]::Hash($full,$true)){throw 'RGB changed'}
$hand=[RaceCardImages]::Resize($full,256,384)
for($i=0;$i -lt 3;$i++){
 $expected=$full;if($i -eq 2){$expected=$hand}
 if(Test-Path -LiteralPath $targets[$i]){$existing=[System.Drawing.Bitmap]::FromFile($targets[$i]);$matches=[RaceCardImages]::Hash($existing,$false) -eq [RaceCardImages]::Hash($expected,$false);$existing.Dispose();if(-not $matches){throw ('Existing target preserved: '+$targets[$i])}}
 else{Save-Png $expected $targets[$i]}
}
$review=New-Object System.Drawing.Bitmap 1024,816
$g=[System.Drawing.Graphics]::FromImage($review);$g.Clear([System.Drawing.Color]::FromArgb(38,30,48))
$g.DrawImage($full,(New-Object System.Drawing.Rectangle 0,0,1024,380),(New-Object System.Drawing.Rectangle 0,0,1024,380),[System.Drawing.GraphicsUnit]::Pixel)
$g.DrawImage($full,(New-Object System.Drawing.Rectangle 0,400,1024,416),(New-Object System.Drawing.Rectangle 0,1120,1024,416),[System.Drawing.GraphicsUnit]::Pixel)
Save-Png $review (Join-Path $PSScriptRoot ('reviews-A/'+$Id+'.png'));$g.Dispose();$review.Dispose()
$fileChecks=@()
for($i=0;$i -lt 3;$i++){
 $im=[System.Drawing.Bitmap]::FromFile($targets[$i]);$w=1024;$h=1536;if($i -eq 2){$w=256;$h=384}
 $corners=@($im.GetPixel(0,0).A,$im.GetPixel(($w-1),0).A,$im.GetPixel(0,($h-1)).A,$im.GetPixel(($w-1),($h-1)).A)
 $ok=$im.Width -eq $w -and $im.Height -eq $h -and $im.PixelFormat -eq [System.Drawing.Imaging.PixelFormat]::Format32bppArgb -and @($corners|Where-Object {$_ -ne 0}).Count -eq 0 -and $im.GetPixel(($w/2),($h/2)).A -eq 255
 if($i -eq 2){$ok=$ok -and [RaceCardImages]::Hash($im,$false) -eq [RaceCardImages]::Hash($hand,$false)}
 $fileChecks+=@{path=$targets[$i].Substring($taskRoot.Length+1).Replace('\','/');width=$im.Width;height=$im.Height;mode='RGBA';corner_alpha=$corners;sha256=(Get-FileHash -LiteralPath $targets[$i] -Algorithm SHA256).Hash.ToLower();passed=$ok};$im.Dispose()
}
$same=(Get-FileHash -LiteralPath $targets[0]).Hash -eq (Get-FileHash -LiteralPath $targets[1]).Hash
$raw.Dispose();$full.Dispose();$hand.Dispose()
$promptPath=Join-Path $taskRoot 'docs/prompts/cards/race-cards-v01-prompts-A.md'
$log="`r`n`r`n## $Id · $Attempt · 2026-10-20 (현재 PC)`r`n`r`n내장 image_gen · 채택: true · $($record.reason)`r`n`r`n"
foreach($ref in $record.refs){$log+='- '+$ref+"`r`n"}
$log+="`r`n~~~text`r`n"+$record.prompt+"`r`n~~~`r`n`r`n가공 전 생성본: art/cards/race-cards-v01/drafts/A-$Id-$Attempt.png. 후처리: RGB·글자 그대로, 40px 라운드 알파만 정규화, 1/4 균등 축소.`r`n"
if(-not([IO.File]::ReadAllText($promptPath).Contains("## $Id · $Attempt · 2026-10-20"))){[IO.File]::AppendAllText($promptPath,$log,$utf8)}
$project=Join-Path $PSScriptRoot 'import-A'
New-Item -ItemType Directory -Force (Join-Path $project 'assets/cards/hand'),(Join-Path $project 'user-data/roaming'),(Join-Path $project 'user-data/local')|Out-Null
[IO.File]::WriteAllText((Join-Path $project 'project.godot'),"config_version=5`n[application]`nconfig/name=`"Race Cards Branch A`"`n[rendering]`nrenderer/rendering_method=`"gl_compatibility`"`n",$utf8)
Copy-Item -LiteralPath $targets[1] -Destination (Join-Path $project ('assets/cards/'+$Id+'.png'))
Copy-Item -LiteralPath $targets[2] -Destination (Join-Path $project ('assets/cards/hand/'+$Id+'.png'))
$done=@($allowed|Where-Object {Test-Path -LiteralPath (Join-Path $project ('assets/cards/'+$_+'.png'))})
$verifier=Get-Content -Raw -Encoding UTF8 (Join-Path $taskRoot 'output/equipment-v01/import-project/verify_textures.gd')
$verifier=$verifier.Replace('["rusty_longsword", "oak_staff", "quilted_gambeson", "traveler_boots", "rowan_charm"]',(ConvertTo-Json -InputObject $done -Compress)).Replace('RESULT %s/10',('RESULT %s/'+($done.Count*2)))
[IO.File]::WriteAllText((Join-Path $project 'verify_textures.gd'),$verifier,$utf8)
$env:APPDATA=Join-Path $project 'user-data/roaming';$env:LOCALAPPDATA=Join-Path $project 'user-data/local'
$exe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
$ErrorActionPreference='Continue'
& $exe --headless --path $project --import --log-file (Join-Path $project ('import-'+$Id+'.log')) 2>&1 | Out-String | Write-Output
$importCode=$LASTEXITCODE
& $exe --headless --path $project --script res://verify_textures.gd --log-file (Join-Path $project ('verify-'+$Id+'.log')) 2>&1 | Out-String | Write-Output
$verifyCode=$LASTEXITCODE
$ErrorActionPreference='Stop'
$texture=Get-Content -Raw -Encoding UTF8 (Join-Path $project 'texture-verification.json')|ConvertFrom-Json
$vPath=Join-Path $PSScriptRoot 'verification-A.json'
$cards=@();if(Test-Path $vPath){$old=Get-Content -Raw -Encoding UTF8 $vPath|ConvertFrom-Json;$cards=@($old.cards|Where-Object {$_.id -ne $Id})}
$entry=@{id=$Id;attempt=$Attempt;files=$fileChecks;raw_rgb_preserved=$true;original_game_identical=$same;hand_uniform_resize=$true;visual_review=$record.visual_review;isolated_import_exit_code=$importCode;texture_verify_exit_code=$verifyCode;passed=($same -and @($fileChecks|Where-Object {-not $_.passed}).Count -eq 0 -and $importCode -eq 0 -and $verifyCode -eq 0 -and $texture.passed -and $record.visual_review.text_exact -and $record.visual_review.safe_areas)}
$cards+= $entry
$missing=@($allowed|Where-Object {$_ -notin @($cards|ForEach-Object {$_.id})})
Write-Json $vPath @{branch='A';requested_ids=$allowed;cards=$cards;missing_ids=$missing;complete=($missing.Count -eq 0);passed=(@($cards|Where-Object {-not $_.passed}).Count -eq 0);import_project='output/race-cards-v01/import-A';imported_textures=$texture;game_sidecars_copied=$false}
$refs=@('art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png','art/concepts/cards/roles-individual-v02/03-resource-timber.png','art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png','art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png')
$items=@($allowed|Where-Object {Test-Path (Join-Path $art ($_+'.png'))}|ForEach-Object {@{label=$_;path=('art/cards/race-cards-v01/'+$_+'.png')}})+@($refs|ForEach-Object {@{label=('APPROVED '+[IO.Path]::GetFileNameWithoutExtension($_));path=$_}})
$sheet=New-Object System.Drawing.Bitmap 1200,([int][Math]::Ceiling($items.Count/4.0)*430+20)
$g=[System.Drawing.Graphics]::FromImage($sheet);$g.Clear([System.Drawing.Color]::FromArgb(38,30,48));$font=New-Object System.Drawing.Font 'Arial',11
for($i=0;$i -lt $items.Count;$i++){$x=20+($i%4)*300;$y=10+[int][Math]::Floor($i/4)*430;$g.DrawString($items[$i].label,$font,[System.Drawing.Brushes]::Ivory,$x,$y);$im=[System.Drawing.Bitmap]::FromFile((Join-Path $taskRoot $items[$i].path));$sm=[RaceCardImages]::Resize($im,256,384);$g.DrawImageUnscaled($sm,$x,($y+25));$sm.Dispose();$im.Dispose()}
Save-Png $sheet (Join-Path $taskRoot 'godot/screenshots/race-cards/sheet-orc.png');$g.Dispose();$sheet.Dispose();$font.Dispose()
$delivery=Join-Path $PSScriptRoot 'delivery-A.md'
if(-not(Test-Path $delivery)){[IO.File]::WriteAllText($delivery,"# 갈래 A 납품 결과 · 2026-10-20`r`n`r`n내장 image_gen 사용. 카드별 원본·게임용·손패용 저장 후 이미지 전용 import-A에서 검증. 게임 임포트·사이드카 반영·EXE 내보내기·커밋은 수행하지 않음. 승인 역할 PNG와 같은 역할 게임 카드 및 종족 초상 시트를 매 호출에 실제 입력. 전체 진행 상태는 verification-A.json 참조. sheet-orc.png에는 이번 갈래의 오크·전투 식량과 승인 역할 예시를 함께 배치.`r`n",$utf8)}
$deliveryText="`r`n## $Id · $Attempt`r`n`r`n- 원본: art/cards/race-cards-v01/$Id.png`r`n- 게임용: godot/assets/cards/$Id.png`r`n- 손패용: godot/assets/cards/hand/$Id.png`r`n- 규격: RGBA 1024×1536 / 손패 RGBA 256×384, 모서리 바깥 투명, 원본·게임용 동일. RGB 보존 및 균등 축소 검증.`r`n- 선정 사유: $($record.reason)`r`n- 검수: $($record.visual_review.notes)`r`n- 격리 임포트 종료 코드: $importCode / 텍스처 검증: $verifyCode. 기준 통과: $($entry.passed).`r`n"
[IO.File]::AppendAllText($delivery,$deliveryText,$utf8)
if(-not $entry.passed){throw 'Card validation failed; see verification-A.json'}
Write-Output ('COMPLETE '+$Id+'; completed='+$cards.Count+'; missing='+($missing -join ','))
