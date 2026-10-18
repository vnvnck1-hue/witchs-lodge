$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$source=Join-Path $root 'godot'
$snapshot=Join-Path $PSScriptRoot 'export-project'
New-Item -ItemType Directory -Force -Path $snapshot | Out-Null
# Copy the current project, never hard-link it: Godot may write import/UID metadata.
Get-ChildItem -LiteralPath $source -Force | Where-Object {$_.Name-notin@('.godot','screenshots','tools')} | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination $snapshot -Recurse -Force}
New-Item -ItemType Directory -Force -Path (Join-Path $snapshot '.godot') | Out-Null
Copy-Item -LiteralPath (Join-Path $source '.godot/imported') -Destination (Join-Path $snapshot '.godot') -Recurse -Force
foreach($name in @('global_script_class_cache.cfg','uid_cache.bin')){if(Test-Path -LiteralPath (Join-Path $source ('.godot/'+$name))){Copy-Item -LiteralPath (Join-Path $source ('.godot/'+$name)) -Destination (Join-Path $snapshot '.godot')}}
$protected=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'protected-before.json') | ConvertFrom-Json
$observed=@();foreach($f in $protected){if(Test-Path -LiteralPath $f.path){$after=(Get-FileHash -LiteralPath $f.path).Hash;if($after-ne$f.sha256){$observed+=@{path=$f.path;before=$f.sha256;observed_before_export=$after}}}}
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
$exportCode=$p.ExitCode
$exportModifications=@();foreach($f in $protected){if(Test-Path -LiteralPath $f.path){$after=(Get-FileHash -LiteralPath $f.path).Hash;if($after-ne$f.sha256){$exportModifications+=@{path=$f.path;before=$f.sha256;after=$after}}}}
[ordered]@{method='Read-only source copy to disposable project snapshot; export directly to root WitchsLodge.exe. No Godot scan/import runs against protected source paths.';command='Godot-4.7.2.exe --headless --path output/race-job-cards-v01/export-project --export-release "Windows Desktop" <project-root>/WitchsLodge.exe';exit_code=$exportCode;concurrent_protected_changes_observed_before_export=$observed;concurrent_protected_changes_observed_after_export=$exportModifications;passed=($exportCode-eq0)} | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'godot-export-result.json')
Write-Output ('Export exit code: '+$exportCode)
if($exportCode-ne0){exit 1}
