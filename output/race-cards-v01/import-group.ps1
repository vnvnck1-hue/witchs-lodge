param([Parameter(Mandatory=$true)][string]$Group)
$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskProject=Join-Path $PSScriptRoot ('import-'+$Group)
$taskIds=@((Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'production-plan-v02.json') | ConvertFrom-Json) | Where-Object {$_.group -eq $Group} | ForEach-Object {$_.id})
New-Item -ItemType Directory -Force (Join-Path $taskProject 'assets/cards/hand'),(Join-Path $PSScriptRoot 'godot-user-data/roaming'),(Join-Path $PSScriptRoot 'godot-user-data/local') | Out-Null
$env:APPDATA=Join-Path $PSScriptRoot 'godot-user-data/roaming';$env:LOCALAPPDATA=Join-Path $PSScriptRoot 'godot-user-data/local'
[IO.File]::WriteAllText((Join-Path $taskProject 'project.godot'),"config_version=5`n[application]`nconfig/name=`"Race Cards Image Import`"`n[rendering]`nrenderer/rendering_method=`"gl_compatibility`"`n",(New-Object Text.UTF8Encoding $false))
foreach($taskId in $taskIds){foreach($taskPart in @('','hand/')){Copy-Item -LiteralPath (Join-Path $taskRoot ('godot/assets/cards/'+$taskPart+$taskId+'.png')) -Destination (Join-Path $taskProject ('assets/cards/'+$taskPart+$taskId+'.png'))}}
$taskVerifier=Get-Content -Raw -Encoding UTF8 (Join-Path $taskRoot 'output/equipment-v01/import-project/verify_textures.gd')
$taskIdJson=ConvertTo-Json -InputObject $taskIds -Compress
$taskVerifier=$taskVerifier.Replace('["rusty_longsword", "oak_staff", "quilted_gambeson", "traveler_boots", "rowan_charm"]',$taskIdJson).Replace('RESULT %s/10',('RESULT %s/'+($taskIds.Count*2)))
[IO.File]::WriteAllText((Join-Path $taskProject 'verify_textures.gd'),$taskVerifier,(New-Object Text.UTF8Encoding $false))
$taskExe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
$taskArgs=@('--headless','--path',('"'+$taskProject+'"'),'--import','--log-file',('"'+(Join-Path $taskProject 'import.log')+'"'))
$taskProcess=Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
@{exit_code=$taskProcess.ExitCode;group=$Group;method='image-only isolated project with matching res paths';command=('.tools/Godot-4.7.2.exe --headless --path output/race-cards-v01/import-'+$Group+' --import')} | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $taskProject 'import-result.json')
if($taskProcess.ExitCode -ne 0){throw 'Import failed'}
$taskArgs=@('--headless','--path',('"'+$taskProject+'"'),'--script','res://verify_textures.gd','--log-file',('"'+(Join-Path $taskProject 'texture-verify.log')+'"'))
$taskProcess=Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
if($taskProcess.ExitCode -ne 0){throw 'Texture verification failed'}
foreach($taskId in $taskIds){foreach($taskPart in @('','hand/')){
 $taskRel='assets/cards/'+$taskPart+$taskId+'.png'
 if((Get-FileHash -LiteralPath (Join-Path $taskProject $taskRel)).Hash -ne (Get-FileHash -LiteralPath (Join-Path $taskRoot ('godot/'+$taskRel))).Hash){throw ('Concurrent PNG change, sidecar not copied: '+$taskRel)}
 Copy-Item -LiteralPath (Join-Path $taskProject ($taskRel+'.import')) -Destination (Join-Path $taskRoot ('godot/'+$taskRel+'.import'))
}}
foreach($taskId in $taskIds){Get-ChildItem -LiteralPath (Join-Path $taskProject '.godot/imported') -Filter ($taskId+'.png-*') -File | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $taskRoot ('godot/.godot/imported/'+$_.Name))}}
Write-Output ('Imported and verified '+$Group+': '+($taskIds.Count*2)+' textures. Only matching card sidecars and caches copied.')
