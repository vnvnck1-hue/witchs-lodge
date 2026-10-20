$ErrorActionPreference='Stop'
[Console]::OutputEncoding=[Text.Encoding]::UTF8
$utf8=New-Object Text.UTF8Encoding $false
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Set-Location -LiteralPath $taskRoot
Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'ImageChecks.cs') -ReferencedAssemblies System.Drawing
$vPath=Join-Path $PSScriptRoot 'verification-A.json'
$v=Get-Content -Raw -Encoding UTF8 $vPath|ConvertFrom-Json
$unchanged=@()
foreach($card in $v.cards){foreach($file in $card.files){
 if((Get-FileHash -LiteralPath $file.path -Algorithm SHA256).Hash.ToLower() -ne $file.sha256){throw ('Previously delivered file changed; preserved: '+$file.path)}
 $unchanged+=$file.path
}}
$paths=@('art/cards/race-cards-v01/battle_ration.png','godot/assets/cards/battle_ration.png','godot/assets/cards/hand/battle_ration.png')
$checks=@()
for($i=0;$i -lt $paths.Count;$i++){
 $im=[Drawing.Bitmap]::FromFile((Join-Path $taskRoot $paths[$i]))
 $w=1024;$h=1536;if($i -eq 2){$w=256;$h=384}
 $corners=@($im.GetPixel(0,0).A,$im.GetPixel(($im.Width-1),0).A,$im.GetPixel(0,($im.Height-1)).A,$im.GetPixel(($im.Width-1),($im.Height-1)).A)
 $checks+=@{path=$paths[$i];width=$im.Width;height=$im.Height;mode='RGBA';pixel_format=$im.PixelFormat.ToString();corner_alpha=$corners;sha256=(Get-FileHash -LiteralPath $paths[$i] -Algorithm SHA256).Hash.ToLower();passed=($im.Width -eq $w -and $im.Height -eq $h -and $im.PixelFormat -eq [Drawing.Imaging.PixelFormat]::Format32bppArgb -and @($corners|Where-Object {$_ -ne 0}).Count -eq 0 -and $im.GetPixel(($w/2),($h/2)).A -eq 255)}
 $im.Dispose()
}
$full=[Drawing.Bitmap]::FromFile((Join-Path $taskRoot $paths[0]))
$raw=[Drawing.Bitmap]::FromFile((Join-Path $taskRoot 'art/cards/race-cards-v01/drafts/A-battle_ration-v04b-api.png'))
$rgbSame=[RaceCardImages]::Hash($full,$true) -eq [RaceCardImages]::Hash($raw,$true)
$raw.Dispose()
$review=New-Object Drawing.Bitmap 1024,876
$g=[Drawing.Graphics]::FromImage($review)
$g.Clear([Drawing.Color]::FromArgb(38,30,48))
$g.DrawImage($full,(New-Object Drawing.Rectangle 0,0,1024,440),(New-Object Drawing.Rectangle 0,0,1024,440),[Drawing.GraphicsUnit]::Pixel)
$g.DrawImage($full,(New-Object Drawing.Rectangle 0,460,1024,416),(New-Object Drawing.Rectangle 0,1120,1024,416),[Drawing.GraphicsUnit]::Pixel)
$review.Save((Join-Path $PSScriptRoot 'reviews-A/battle_ration.png'),[Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$review.Dispose();$full.Dispose()
$project=Join-Path $PSScriptRoot 'import-A'
Copy-Item -LiteralPath $paths[1] -Destination (Join-Path $project 'assets/cards/battle_ration.png')
Copy-Item -LiteralPath $paths[2] -Destination (Join-Path $project 'assets/cards/hand/battle_ration.png')
$verifierPath=Join-Path $project 'verify_textures.gd'
$verifier=[IO.File]::ReadAllText($verifierPath)
if(-not $verifier.Contains('"battle_ration"')){$verifier=$verifier.Replace('"ash_sigil","spit_roast"]','"ash_sigil","spit_roast","battle_ration"]')}
$verifier=$verifier.Replace('RESULT %s/16','RESULT %s/18')
if(-not $verifier.Contains('"battle_ration"')){throw 'Verifier id update failed'}
[IO.File]::WriteAllText($verifierPath,$verifier,$utf8)
$env:APPDATA=Join-Path $project 'user-data/roaming'
$env:LOCALAPPDATA=Join-Path $project 'user-data/local'
$exe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
$ErrorActionPreference='Continue'
& $exe --headless --path $project --import --log-file (Join-Path $project 'import-battle_ration.log') 2>&1 | Out-String | Write-Output
$importCode=$LASTEXITCODE
& $exe --headless --path $project --script res://verify_textures.gd --log-file (Join-Path $project 'verify-battle_ration.log') 2>&1 | Out-String | Write-Output
$verifyCode=$LASTEXITCODE
$ErrorActionPreference='Stop'
$texture=Get-Content -Raw -Encoding UTF8 (Join-Path $project 'texture-verification.json')|ConvertFrom-Json
$same=$checks[0].sha256 -eq $checks[1].sha256
$technicalPass=$same -and $rgbSame -and @($checks|Where-Object {-not $_.passed}).Count -eq 0 -and $importCode -eq 0 -and $verifyCode -eq 0 -and $texture.passed
$entry=[PSCustomObject]@{
 id='battle_ration';attempt='v04b-api';generation_record='output/race-cards-v01/generation-A-battle_ration-api.json';reused_existing=$true;generated_this_run=$false
 files=$checks;raw_rgb_preserved=$rgbSame;original_game_identical=$same;hand_uniform_resize=$true
 hand_resize_verification='256x384 dimensions, same composition visually confirmed; prior producer records LANCZOS 1/4; resize pixels not recomputed in this audit'
 isolated_import_exit_code=$importCode;texture_verify_exit_code=$verifyCode;technical_passed=$technicalPass
 visual_review=@{text_exact=$true;role_frame=$true;safe_areas=$true;medieval_fantasy=$true;no_badge=$true;silhouette_distinct=$true;layout_consistency=$false;passed=$false;notes='Existing Claude-selected v04b retained per skip-existing instruction. Text matches catalog. Cloth bundle, small hammer keg and tusk cord, winter lodge and resource frame correct. Compared with feast_table, title is visibly larger (approximately 76px vs 53px) and category about 40px lower (approximately y320..360 vs y285..325). No text overlap, but header consistency criterion is not fully met.'}
 passed=$false
}
$v.cards=@($v.cards|Where-Object {$_.id -ne 'battle_ration'})+@($entry)
$v.missing_ids=@();$v.complete=$true;$v.passed=$false;$v.full_requested_passed=$false
$v.status='all_assets_present_visual_deviation'
$v.passed_scope='All 9 cards present and technically verified; overall false because existing battle_ration header differs from delivered resource cards. Existing PNGs preserved.'
$v.imported_textures=$texture
$v|Add-Member -Force NoteProperty technical_passed $technicalPass
$v|Add-Member -Force NoteProperty below_standard_ids @('battle_ration')
$v|Add-Member -Force NoteProperty completed_file_count 27
$v|Add-Member -Force NoteProperty generation_this_run_count 0
$v|Add-Member -Force NoteProperty external_generation @{producer='Claude';record='output/race-cards-v01/generation-A-battle_ration-api.json';successful_outputs=6;selected='v04b-api'}
$v|Add-Member -Force NoteProperty updated_at (Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz')
$v.final_visual_review=@{passed=$false;reviewed_this_run=@('battle_ration');previously_reviewed_ids=@($v.cards|Where-Object {$_.id -ne 'battle_ration'}|ForEach-Object {$_.id});text_reference='output/race-cards-v01/catalog_entries.json';method='Full-size existing card, approved resource PNG, feast_table comparison and 1:1 header/footer crop; hand-size contact sheet';sheet='godot/screenshots/race-cards/sheet-orc.png';no_failed_completed_ids=$false;below_standard_ids=@('battle_ration')}
$changed=@()
foreach($card in $v.cards){foreach($file in $card.files){if((Get-FileHash -LiteralPath $file.path -Algorithm SHA256).Hash.ToLower() -ne $file.sha256){$changed+=$file.path}}}
$v.final_sha256_recheck=@{passed=($changed.Count -eq 0);checked_files=27;changed_paths=$changed;previous_24_files_unchanged=($unchanged.Count -eq 24)}
if($changed.Count){throw 'Concurrent changes detected; verification not saved'}
[IO.File]::WriteAllText($vPath,($v|ConvertTo-Json -Depth 25),$utf8)
$refs=@('art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png','art/concepts/cards/roles-individual-v02/03-resource-timber.png','art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png','art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png')
$items=@($v.requested_ids|ForEach-Object {@{label=$_;path=('art/cards/race-cards-v01/'+$_+'.png')}})+@($refs|ForEach-Object {@{label=('APPROVED '+[IO.Path]::GetFileNameWithoutExtension($_));path=$_}})
$sheet=New-Object Drawing.Bitmap 1200,1740
$g=[Drawing.Graphics]::FromImage($sheet);$g.Clear([Drawing.Color]::FromArgb(38,30,48));$font=New-Object Drawing.Font 'Arial',11
for($i=0;$i -lt $items.Count;$i++){
 $x=20+($i%4)*300;$y=10+[int][Math]::Floor($i/4)*430
 $g.DrawString($items[$i].label,$font,[Drawing.Brushes]::Ivory,$x,$y)
 $im=[Drawing.Bitmap]::FromFile((Join-Path $taskRoot $items[$i].path));$sm=[RaceCardImages]::Resize($im,256,384)
 $g.DrawImageUnscaled($sm,$x,($y+25));$sm.Dispose();$im.Dispose()
}
$sheet.Save((Join-Path $taskRoot 'godot/screenshots/race-cards/sheet-orc.png'),[Drawing.Imaging.ImageFormat]::Png)
$g.Dispose();$sheet.Dispose();$font.Dispose()
if(-not $technicalPass){throw 'Technical validation failed'}
Write-Output 'A audit: 9 cards / 27 PNGs present; 18 textures passed. Existing battle_ration retained with header consistency deviation. No card PNG modified.'
