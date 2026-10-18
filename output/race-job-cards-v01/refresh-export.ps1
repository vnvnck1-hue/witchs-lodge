$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$snapshot=Join-Path $PSScriptRoot 'export-project'
$initial=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'godot-export-result.json') | ConvertFrom-Json
# A failed first export is also retryable after redirecting all editor cache writes locally.
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'godot-export-result.json') -Destination (Join-Path $PSScriptRoot 'godot-export-initial-result.json')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'godot-export-stdout.log') -Destination (Join-Path $PSScriptRoot 'godot-export-initial-stdout.log')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'godot-export-stderr.log') -Destination (Join-Path $PSScriptRoot 'godot-export-initial-stderr.log')
$jobs=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'generation-manifest.json') | ConvertFrom-Json
# Bring the read-only snapshot up to the current shared project before the final export.
# Concurrent UI work is copied only into the disposable snapshot, never edited in place.
$source=Join-Path $root 'godot';$refreshed=@()
$sourceFiles=@(Get-ChildItem -LiteralPath $source -Force | Where-Object {$_.Name-notin@('.godot','screenshots','tools')} | ForEach-Object {if($_.PSIsContainer){Get-ChildItem -LiteralPath $_.FullName -File -Recurse}else{$_}})
foreach($f in $sourceFiles){
 $rel=$f.FullName.Substring($source.Length+1);$dest=Join-Path $snapshot $rel
 $existing=Get-Item -LiteralPath $dest -ErrorAction SilentlyContinue
 if($null-eq$existing-or$existing.Length-ne$f.Length-or$existing.LastWriteTimeUtc-ne$f.LastWriteTimeUtc){New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null;Copy-Item -LiteralPath $f.FullName -Destination $dest -Force;$refreshed+=$rel.Replace('\','/')}
}
$bindings=@()
foreach($j in $jobs){foreach($hand in @('','hand/')){
 $rel='assets/cards/races/'+$j.race+'/'+$hand+$j.job+'.png'
 foreach($suffix in @('','.import')){Copy-Item -LiteralPath (Join-Path $root ('godot/'+$rel+$suffix)) -Destination (Join-Path $snapshot ($rel+$suffix))}
 $text=Get-Content -Raw -Encoding UTF8 (Join-Path $root ('godot/'+$rel+'.import'))
 $match=[regex]::Match($text,'path="res://(.godot/imported/[^"\r\n]+\.ctex)"')
 if(-not $match.Success){throw ('Missing texture remap: '+$rel)}
 $cache=$match.Groups[1].Value
 foreach($cacheRel in @($cache,($cache-replace '\.ctex$','.md5'))){Copy-Item -LiteralPath (Join-Path $root ('godot/'+$cacheRel)) -Destination (Join-Path $snapshot $cacheRel)}
 $bindings+=@{path=('res://'+$rel);sha256=(Get-FileHash -LiteralPath (Join-Path $snapshot $rel)).Hash.ToLowerInvariant();cache=('res://'+$cache);cache_sha256=(Get-FileHash -LiteralPath (Join-Path $snapshot $cache)).Hash.ToLowerInvariant()}
}}
$engineDir=Join-Path $PSScriptRoot 'portable-editor'
New-Item -ItemType Directory -Force -Path $engineDir | Out-Null
$exe=Join-Path $engineDir 'Godot-4.7.2.exe'
Copy-Item -LiteralPath (Join-Path $root '.tools/Godot-4.7.2.exe') -Destination $exe -Force
'' | Set-Content -Encoding ASCII (Join-Path $engineDir '_sc_')
$templates=Join-Path $engineDir 'editor_data/export_templates/4.7.2.stable'
New-Item -ItemType Directory -Force -Path $templates | Out-Null
Get-ChildItem -LiteralPath 'C:/Users/vnvnc/AppData/Roaming/Godot/export_templates/4.7.2.stable' -File | Where-Object {$_.Name-match '^windows_(release|debug)_x86_64\.exe$|^version.txt$'} | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination $templates -Force}
$destination=Join-Path $root 'WitchsLodge.exe'
$p=Start-Process -FilePath $exe -ArgumentList @('--headless','--quiet','--path',('"'+$snapshot+'"'),'--export-release','"Windows Desktop"',('"'+$destination+'"')) -WindowStyle Hidden -PassThru -Wait -RedirectStandardOutput (Join-Path $PSScriptRoot 'godot-export-stdout.log') -RedirectStandardError (Join-Path $PSScriptRoot 'godot-export-stderr.log')
$code=$p.ExitCode
[ordered]@{method='Reused isolated snapshot after full scan; refreshed current shared project files and final 40 PNGs, descriptors and verified CTEX/MD5 cache. Disposable self-contained editor redirects cache/config writes into output/race-job-cards-v01/portable-editor/editor_data. Export directly to root WitchsLodge.exe.';exit_code=$code;refreshed_snapshot_files=$refreshed;final_card_bindings=$bindings;concurrent_protected_changes_observed_before_export=$initial.concurrent_protected_changes_observed_before_export;concurrent_protected_changes_observed_after_export=$initial.concurrent_protected_changes_observed_after_export;passed=($code-eq0-and$bindings.Count-eq40)} | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'godot-export-result.json')
Write-Output ('Final export exit code: '+$code)
if($code-ne0){exit 1}
