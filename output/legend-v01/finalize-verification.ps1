$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$path=Join-Path $PSScriptRoot 'verification.json'
$v=Get-Content -Raw -Encoding UTF8 -LiteralPath $path | ConvertFrom-Json
if($v.files.Count -ne 18 -or @($v.files | Where-Object {-not $_.passed}).Count -ne 0){throw 'Expected 18 passing files'}
$pairs=@()
foreach($id in @('frost_crown','lich_crown','wild_grimoire','fire_brazier','winter_bell','ore')){
  $a=($v.files | Where-Object {$_.path -eq ('art/cards/legend-v01/'+$id+'.png')}).sha256
  $b=($v.files | Where-Object {$_.path -eq ('godot/assets/cards/'+$id+'.png')}).sha256
  if($a -ne $b){throw ('Art/game mismatch '+$id)}
  $pairs+=@{id=$id;art_game_sha256_identical=$true}
}
$v.visual_review_pending=$false
$visual=[ordered]@{reviewed=$true;date='2026-10-25';review_method='Direct visual inspection of full-size cards, final fire_brazier, and final comparison sheet at actual 256x384 hand size';no_text_numbers_runes_or_cover_sigils=$true;blank_title_and_rules_panels=$true;medieval_fantasy_context=$true;subjects_readable_at_hand_size=$true;fire_brazier_three_legs_visible=$true;runtime_import_tested=$false;runtime_reason='Handoff restricts this task to art delivery; implementation session handles import';known_alpha_exception='ore exactly preserves near-transparent timber corner alpha [1,0,2,0], hand [1,0,1,0], rather than forcing alpha zero'}
$v | Add-Member -Force NoteProperty visual_review $visual
$v | Add-Member -Force NoteProperty art_game_copy_checks $pairs
$support=@()
foreach($rel in @('godot/screenshots/legend-cards/sheet-v01.png','output/legend-v01/legend-mask-preview-art-mask.png','output/legend-v01/legend-mask-preview-badge-mask.png','output/legend-v01/resource-mask-preview-art-mask.png','output/legend-v01/resource-mask-preview-badge-mask.png')){
  $p=Join-Path $root $rel;$b=[System.Drawing.Bitmap]::new($p)
  $support+=@{path=$rel;width=$b.Width;height=$b.Height;sha256=(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLower()};$b.Dispose()
}
$v | Add-Member -Force NoteProperty supporting_pngs $support
$v.passed=$true
$v | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $path -Encoding UTF8
Write-Output 'FINAL PASS: 18 files, 6 identical art/game pairs, frame/alpha delta 0, visual review complete'
