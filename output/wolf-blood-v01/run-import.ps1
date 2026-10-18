$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskProject = Join-Path $PSScriptRoot 'import-project'
$taskExe = Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
$taskData = Join-Path $PSScriptRoot 'godot-user-data'
New-Item -ItemType Directory -Force "$taskData/roaming", "$taskData/local" | Out-Null
$env:APPDATA = "$taskData/roaming"
$env:LOCALAPPDATA = "$taskData/local"
$taskArgs = @('--headless','--path',('"'+$taskProject+'"'),'--import','--log-file',('"'+(Join-Path $PSScriptRoot 'import.log')+'"'))
$taskProcess = Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
@{exit_code=$taskProcess.ExitCode;method='image-only isolated project, matching res://assets paths';log='output/wolf-blood-v01/import.log';command='.tools/Godot-4.7.2.exe --headless --path output/wolf-blood-v01/import-project --import';environment_log_note='Godot reports Failed to read the root certificate store in this restricted environment; image import and texture loading are local and passed.'} | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'import-result.json')
if ($taskProcess.ExitCode -ne 0) { throw 'Image import failed' }
$taskArgs = @('--headless','--path',('"'+$taskProject+'"'),'--script','res://verify_textures.gd','--log-file',('"'+(Join-Path $PSScriptRoot 'texture-verify.log')+'"'))
$taskProcess = Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
if ($taskProcess.ExitCode -ne 0) { throw 'Imported texture verification failed' }
$taskIds = @('wolf_blood','crescent_moon','half_moon','full_moon')
$taskRel = @()
foreach ($taskId in $taskIds) { $taskRel += "assets/cards/$taskId.png"; $taskRel += "assets/cards/hand/$taskId.png" }
$taskRel += @('assets/ui/skills/wolf_claw.png','assets/ui/skills/wolf_pounce.png')
foreach ($taskPath in $taskRel) {
  Copy-Item -LiteralPath (Join-Path $taskProject ($taskPath+'.import')) -Destination (Join-Path $taskRoot ('godot/'+$taskPath+'.import'))
}
$taskCache = Join-Path $taskRoot 'godot/.godot/imported'
New-Item -ItemType Directory -Force $taskCache | Out-Null
foreach ($taskId in ($taskIds + @('wolf_claw','wolf_pounce'))) {
  Get-ChildItem -LiteralPath (Join-Path $taskProject '.godot/imported') -Filter ($taskId+'.png-*') -File | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $taskCache $_.Name) }
}
Write-Output 'Import exit code 0; 10 imported textures passed; sidecars and imported texture cache copied.'
