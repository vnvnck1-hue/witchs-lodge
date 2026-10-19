$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskExe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
$taskData=Join-Path $PSScriptRoot 'godot-user-data'
New-Item -ItemType Directory -Force "$taskData/roaming","$taskData/local" | Out-Null
$env:APPDATA="$taskData/roaming"
$env:LOCALAPPDATA="$taskData/local"
$taskArgs=@('--headless','--path',('"'+(Join-Path $taskRoot 'godot')+'"'),'--import','--log-file',('"'+(Join-Path $PSScriptRoot 'import.log')+'"'))
$taskProcess=Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
@{exit_code=$taskProcess.ExitCode;command='.tools/Godot-4.7.2.exe --headless --path godot --import';log='output/scrap-rename-v01/import.log';method='requested game project import'} | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'import-result.json')
if($taskProcess.ExitCode -ne 0) {throw 'Godot import failed'}
$taskArgs=@('--headless','--path',('"'+(Join-Path $taskRoot 'godot')+'"'),'--script',('"'+(Join-Path $PSScriptRoot 'verify_textures.gd')+'"'),'--log-file',('"'+(Join-Path $PSScriptRoot 'texture-verify.log')+'"'))
$taskProcess=Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
@{exit_code=$taskProcess.ExitCode;log='output/scrap-rename-v01/texture-verify.log'} | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'texture-process-result.json')
if($taskProcess.ExitCode -ne 0) {throw 'Imported texture verification failed'}
Write-Output 'Godot import exit code 0; four imported game/hand textures passed.'
