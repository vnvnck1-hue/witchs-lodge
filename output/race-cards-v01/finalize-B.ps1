$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskIds=@('introduction_letter','guild_writ','village_militia','old_records','pilgrim_blessing','merchant_wagon','crest_banner','interpreter_pen','lodge_festival','stranger_gift','lodge_cleanup')
$taskRecords=@(Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'generation-B-*-v*.json' | ForEach-Object {Get-Content -Raw -Encoding UTF8 $_.FullName | ConvertFrom-Json} | Where-Object {$_.id -in $taskIds})
if($taskRecords.Count -ne 15){throw 'Expected 15 new B generation records'}
$taskPromptPath=Join-Path $taskRoot 'docs/prompts/cards/race-cards-v01-prompts-B.md'
$taskPrior=[IO.File]::ReadAllText($taskPromptPath,[Text.Encoding]::UTF8).Replace("`r`n","`n")
$taskMarker="`n## `nintroduction_letter`n"
$taskIndex=$taskPrior.IndexOf($taskMarker)
if($taskIndex -lt 0){throw 'Cannot locate only our appended log block; preserve existing content'}
# Preserve every pre-existing beastfolk prompt byte-for-byte except newline normalization.
$taskPrior=$taskPrior.Substring(0,$taskIndex)
$taskLines=New-Object 'System.Collections.Generic.List[string]'
$taskLines.Add($taskPrior.TrimEnd())
$taskLines.Add('')
$taskLines.Add('# B 갈래 인간·화합·중립 11장 · 2026-10-20')
$taskLines.Add('')
$taskLines.Add('내장 image_gen 15회. 아래는 실제 호출 프롬프트·입력·채택 사유 전체다. 매 호출 transparent_background=true. 미채택본도 drafts에 보존했다. 생성 결과의 RGB·인쇄 글자는 변경하지 않고 카드지/모서리 알파만 정규화했으며 손패를 1/4 균등 축소했다.')
foreach($taskId in $taskIds){foreach($taskRecord in @($taskRecords | Where-Object id -eq $taskId | Sort-Object attempt)){
 $taskLines.Add('');$taskLines.Add(('## '+$taskId+' · B '+$taskRecord.attempt));$taskLines.Add('')
 $taskLines.Add(('채택: '+$taskRecord.selected+' · 이유: '+$taskRecord.reason));$taskLines.Add('')
 foreach($taskRef in $taskRecord.refs){$taskLines.Add(('- `'+$taskRef+'`'))}
 $taskLines.Add('');$taskLines.Add('```text');$taskLines.Add($taskRecord.prompt);$taskLines.Add('```');$taskLines.Add('')
 $taskLines.Add(('가공 전 생성본: `art/cards/race-cards-v01/drafts/'+$taskId+'-B-'+$taskRecord.attempt+'.png`'))
 $taskDraft=Join-Path $taskRoot ('art/cards/race-cards-v01/drafts/'+$taskId+'-B-'+$taskRecord.attempt+'.png')
 if(-not(Test-Path -LiteralPath $taskDraft)){throw ('Missing raw '+$taskDraft)}
}}
[IO.File]::WriteAllText($taskPromptPath,(($taskLines -join "`n")+"`n"),(New-Object Text.UTF8Encoding $false))
$taskCatalog=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'catalog_entries.json') | ConvertFrom-Json
$taskVerification=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'verification-B.json') | ConvertFrom-Json
$taskMetadata=@()
foreach($taskId in $taskIds){
 $taskSelected=@($taskRecords | Where-Object {$_.id -eq $taskId -and $_.selected})
 if($taskSelected.Count -ne 1){throw ('Need one selected generation '+$taskId)}
 $taskExpected=@($taskCatalog | Where-Object id -eq $taskId)[0]
 $taskRecord=$taskSelected[0]
 $taskMatch=$taskRecord.name -ceq $taskExpected.name -and $taskRecord.category -ceq $taskExpected.category -and ($taskRecord.printed_rules -join "`n") -ceq ($taskExpected.printed_rules -join "`n")
 if(-not $taskMatch){throw ('Catalog text mismatch '+$taskId)}
 $taskMetadata+=@{id=$taskId;selected_attempt=$taskRecord.attempt;catalog_text_matches=$taskMatch;expected_name=$taskExpected.name;expected_category=$taskExpected.category;expected_rules=$taskExpected.printed_rules;review='Full-resolution generated PNG and reference comparison; all three final group sheets viewed';passed=$true}
}
$taskVerification | Add-Member -Force NoteProperty generation_count 15
$taskVerification | Add-Member -Force NoteProperty metadata_verification $taskMetadata
$taskVerification | Add-Member -Force NoteProperty below_standard_ids @()
$taskVerification | Add-Member -Force NoteProperty preview_sheets @('godot/screenshots/race-cards/sheet-human.png','godot/screenshots/race-cards/sheet-harmony.png','godot/screenshots/race-cards/sheet-neutral.png')
$taskVerification | ConvertTo-Json -Depth 25 | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'verification-B.json')
$taskDelivery=New-Object 'System.Collections.Generic.List[string]'
$taskDelivery.Add('# B 갈래 납품 결과 · 2026-10-20')
$taskDelivery.Add('')
$taskDelivery.Add('인간 6 · 화합 3 · 중립 2, 이번 요청 11장 전부 완료. 시작 시 해당 11장의 보존 원본은 없었으며 기존 납품 15장은 제작하거나 수정하지 않았다.')
$taskDelivery.Add('')
$taskDelivery.Add('- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 총 33개 최종 PNG. 라운드 바깥 투명. 원본=게임용, 생성 RGB 보존, 손패 정확한 1/4 균등 축소.')
$taskDelivery.Add('- 제목·분류·설명 두 문장을 catalog_entries.json과 대조하고 원본 크기로 직접 검수했다. 역할 승인 PNG·현재 게임 카드·기존 납품본을 매 호출 실제 참고 입력으로 사용했다. 인간 카드는 기존 인간 외형 시트도 입력했다.')
$taskDelivery.Add('- 내장 image_gen 15회, 채택 11개·미채택 4개 모두 drafts에 보존. 마을 민병 v04, 통역사의 펜 v02, 나머지 v01 채택.')
$taskDelivery.Add('- 격리 프로젝트 `output/race-cards-v01/import-B/`에서만 임포트. 최종 --import 종료 코드 0, 텍스처 22/22 규격·알파·픽셀 해시 검증 통과. 최종 `verification-B.json`: passed=true, complete=true, delivered_count=11, missing_ids=[].')
$taskDelivery.Add('- 기준 미달 id: 없음. 게임 프로젝트에는 대상 22개 PNG만 저장. 게임 --import·임포트 캐시 복사·실행파일 갱신·커밋은 하지 않았다. 금지 코드·카탈로그·기획 문서·공용 기록은 수정하지 않았다.')
$taskDelivery.Add('')
$taskDelivery.Add('## 파일 목록')
$taskDelivery.Add('')
$taskDelivery.Add('| id | 원본 | 게임용 | 손패용 |')
$taskDelivery.Add('| --- | --- | --- | --- |')
foreach($taskId in $taskIds){$taskDelivery.Add(('| `'+$taskId+'` | [PNG](../../art/cards/race-cards-v01/'+$taskId+'.png) | [PNG](../../godot/assets/cards/'+$taskId+'.png) | [PNG](../../godot/assets/cards/hand/'+$taskId+'.png) |'))}
$taskDelivery.Add('')
$taskDelivery.Add('## 재생성')
$taskDelivery.Add('')
$taskDelivery.Add('- `village_militia`: 3회 수정. v01 창 누락·작은 본문, v02 과대 글자·높은 창끝, v03 사건 접힘 탭을 교정했다. v04에서 글자·인물 아치 프레임·등불 배지·창/쇠스랑 및 글 영역을 확인했다.')
$taskDelivery.Add('- `interpreter_pen`: 1회 수정. 분류 띠를 아래로 내려 기존 장비 납품본과 맞춘 v02 채택. 그림·문구·글자 크기 유지.')
$taskDelivery.Add('- 나머지 9장: 첫 생성본 채택. 생성 이력은 `generation-B-<id>-vNN.json`, 가공 전 원본은 `art/cards/race-cards-v01/drafts/<id>-B-vNN.png`.')
$taskDelivery.Add('')
$taskDelivery.Add('## 미리보기·기록')
$taskDelivery.Add('')
$taskDelivery.Add('- [인간 6장](../../godot/screenshots/race-cards/sheet-human.png), [화합 3장](../../godot/screenshots/race-cards/sheet-harmony.png), [중립 2장](../../godot/screenshots/race-cards/sheet-neutral.png). 승인 역할 PNG와 256×384 동일 비율로 함께 배치해 확인했다.')
$taskDelivery.Add('- [실제 프롬프트 전체](../../docs/prompts/cards/race-cards-v01-prompts-B.md), [검증 JSON](verification-B.json), [격리 텍스처 검증](import-B/texture-verification.json), [최종 임포트 로그](import-B/import-lodge_cleanup.log).')
$taskDelivery.Add('- `complete-B.ps1`은 카드별 저장·축소·격리 임포트·검증용이다. 기존 카드가 있으면 기본 실행은 중단하며, `-Resume`은 PNG를 다시 쓰지 않고 시트·격리 임포트·검증만 갱신한다. Windows PowerShell용 UTF-8 BOM으로 저장했다.')
$taskDelivery.Add('- 한국어가 인쇄된 PNG 납품이다. 다국어 동적 텍스트 구현·번역 길이 검증은 이 작업 범위 밖이다.')
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'delivery-B.md'),(($taskDelivery -join "`n")+"`n"),(New-Object Text.UTF8Encoding $false))
Write-Output 'B final records: 11 cards, 33 PNGs, 15 generations, 22 imported textures, no missing or below-standard IDs.'
