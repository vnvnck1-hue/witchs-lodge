$ErrorActionPreference='Stop'
$utf8=New-Object Text.UTF8Encoding $false
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$ids=@('war_drum','feast_table','blood_oath','bone_throw','victory_roar','ancestor_path','ash_sigil','spit_roast','battle_ration')
$promptPath=Join-Path $taskRoot 'docs/prompts/cards/race-cards-v01-prompts-A.md'
$records=@(Get-ChildItem -LiteralPath $PSScriptRoot -Filter 'generation-A-*-v*.json'|ForEach-Object {$r=Get-Content -Raw -Encoding UTF8 $_.FullName|ConvertFrom-Json;if($r.id -in $ids){$r}})
foreach($r in $records){
 if(-not $r.selected){
  $header='## '+$r.id+' · '+$r.attempt+' · 2026-10-20 (미채택/미생성 시도)'
  if(-not([IO.File]::ReadAllText($promptPath).Contains($header))){
   $text="`r`n`r`n"+$header+"`r`n`r`n내장 image_gen · transparent_background=true · 채택=false · 이유: "+$r.reason+"`r`n`r`n"
   foreach($ref in $r.refs){$text+='- '+$ref+"`r`n"}
   $text+="`r`n~~~text`r`n"+$r.prompt+"`r`n~~~`r`n"
   if($r.source){$text+="`r`n가공 전 생성본: art/cards/race-cards-v01/drafts/A-$($r.id)-$($r.attempt).png`r`n"}
   else{$text+="`r`nHTTP 429 usage_limit_reached. 이미지 생성되지 않음. generation-A-battle_ration-v01.json 참고.`r`n"}
   [IO.File]::AppendAllText($promptPath,$text,$utf8)
  }
 }
 if($r.source){$draft=Join-Path $taskRoot ('art/cards/race-cards-v01/drafts/A-'+$r.id+'-'+$r.attempt+'.png');if(-not(Test-Path -LiteralPath $draft)){throw ('Missing preserved draft '+$draft)}}
}
$vPath=Join-Path $PSScriptRoot 'verification-A.json'
$v=Get-Content -Raw -Encoding UTF8 $vPath|ConvertFrom-Json
$changed=@()
foreach($card in $v.cards){foreach($f in $card.files){if((Get-FileHash -LiteralPath (Join-Path $taskRoot $f.path) -Algorithm SHA256).Hash.ToLower() -ne $f.sha256){$changed+=$f.path}}}
if($changed.Count){throw ('Concurrent card changes: '+($changed -join ','))}
$v|Add-Member -Force NoteProperty status 'partial_delivery_usage_limit'
$v|Add-Member -Force NoteProperty passed_scope 'completed 8-card delivery only; complete=false because battle_ration was not generated'
$v|Add-Member -Force NoteProperty full_requested_passed $false
$v|Add-Member -Force NoteProperty generation_success_count @($records|Where-Object {$_.source}).Count
$v|Add-Member -Force NoteProperty generation_usage_limit_count @($records|Where-Object {$_.status -eq 'blocked_usage_limit'}).Count
$v|Add-Member -Force NoteProperty failed_requests @(@{id='battle_ration';reason='usage_limit_reached';record='output/race-cards-v01/generation-A-battle_ration-v01.json';image_created=$false})
$v|Add-Member -Force NoteProperty final_sha256_recheck @{passed=$true;checked_files=24;changed_paths=$changed}
$v|Add-Member -Force NoteProperty final_visual_review @{passed=$true;reviewed_ids=@($v.cards|ForEach-Object {$_.id});text_reference='output/race-cards-v01/catalog_entries.json';method='Original-size generated images and saved 1:1 header/footer crops; hand-size preview comparison';sheet='godot/screenshots/race-cards/sheet-orc.png';no_failed_completed_ids=$true}
[IO.File]::WriteAllText($vPath,($v|ConvertTo-Json -Depth 25),$utf8)
Write-Output ('Records saved: successful='+$v.generation_success_count+'; usage-limit='+$v.generation_usage_limit_count+'; completed='+$v.cards.Count+'; files rechecked=24; imported textures='+$v.imported_textures.textures.Count+'; missing='+($v.missing_ids -join ','))
