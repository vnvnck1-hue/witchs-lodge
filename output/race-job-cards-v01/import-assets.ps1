$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$stage=Join-Path $PSScriptRoot 'import-project'
New-Item -ItemType Directory -Force -Path (Join-Path $stage 'assets/cards/races') | Out-Null
@'
config_version=5

[application]
config/name="Race job cards import isolation"

[rendering]
renderer/rendering_method="gl_compatibility"
'@ | Set-Content -Encoding UTF8 (Join-Path $stage 'project.godot')
$jobs=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'generation-manifest.json') | ConvertFrom-Json
foreach($j in $jobs){foreach($hand in @('','hand/')){
 $rel='assets/cards/races/'+$j.race+'/'+$hand+$j.job+'.png'
 $dest=Join-Path $stage $rel;New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
 Copy-Item -LiteralPath (Join-Path $root ('godot/'+$rel)) -Destination $dest
}}
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'verify-import.gd') -Destination (Join-Path $stage 'verify-import.gd')
$exe=Join-Path $root '.tools/Godot-4.7.2.exe'
$p=Start-Process -FilePath $exe -ArgumentList @('--headless','--path',('"'+$stage+'"'),'--import') -WindowStyle Hidden -PassThru -Wait -RedirectStandardOutput (Join-Path $PSScriptRoot 'godot-import-stdout.log') -RedirectStandardError (Join-Path $PSScriptRoot 'godot-import-stderr.log')
$importCode=$p.ExitCode
if($importCode-ne0){throw ('Import failed: '+$importCode)}
$p=Start-Process -FilePath $exe -ArgumentList @('--headless','--path',('"'+$stage+'"'),'--script','res://verify-import.gd') -WindowStyle Hidden -PassThru -Wait -RedirectStandardOutput (Join-Path $PSScriptRoot 'godot-verify-stdout.log') -RedirectStandardError (Join-Path $PSScriptRoot 'godot-verify-stderr.log')
$verifyCode=$p.ExitCode
if($verifyCode-ne0){throw ('Texture verification failed: '+$verifyCode)}
foreach($j in $jobs){foreach($hand in @('','hand/')){
 $rel='assets/cards/races/'+$j.race+'/'+$hand+$j.job+'.png.import'
 Copy-Item -LiteralPath (Join-Path $stage $rel) -Destination (Join-Path $root ('godot/'+$rel))
}}
New-Item -ItemType Directory -Force -Path (Join-Path $root 'godot/.godot/imported') | Out-Null
Get-ChildItem -LiteralPath (Join-Path $stage '.godot/imported') -File | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $root ('godot/.godot/imported/'+$_.Name))}
[ordered]@{method='Image-only isolated Godot project; same res://assets/cards/races paths, verified import descriptors and imported cache copied to root game.';import_exit_code=$importCode;verify_exit_code=$verifyCode;import_descriptors=40;passed=($importCode-eq0-and$verifyCode-eq0)} | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'godot-import-result.json')
Write-Output ('Import '+$importCode+'; texture verification '+$verifyCode+'; descriptors 40')
