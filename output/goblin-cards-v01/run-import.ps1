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
@{exit_code=$taskProcess.ExitCode;method='image-only isolated project with matching res://assets paths';log='output/goblin-cards-v01/import.log';command='.tools/Godot-4.7.2.exe --headless --path output/goblin-cards-v01/import-project --import'} | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'import-result.json')
if ($taskProcess.ExitCode -ne 0) { throw 'Image import failed' }
$taskArgs = @('--headless','--path',('"'+$taskProject+'"'),'--script','res://verify_textures.gd','--log-file',('"'+(Join-Path $PSScriptRoot 'texture-verify.log')+'"'))
$taskProcess = Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
if ($taskProcess.ExitCode -ne 0) { throw 'Imported texture verification failed' }
$taskIds = (Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'generation-plan.json') | ConvertFrom-Json).id
foreach ($taskId in $taskIds) {
    foreach ($taskPart in @('','hand/')) {
        $taskPath = 'assets/cards/'+$taskPart+$taskId+'.png.import'
        Copy-Item -LiteralPath (Join-Path $taskProject $taskPath) -Destination (Join-Path $taskRoot ('godot/'+$taskPath))
    }
}
$taskCache = Join-Path $taskRoot 'godot/.godot/imported'
New-Item -ItemType Directory -Force $taskCache | Out-Null
foreach ($taskId in $taskIds) {
    Get-ChildItem -LiteralPath (Join-Path $taskProject '.godot/imported') -Filter ($taskId+'.png-*') -File | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $taskCache $_.Name) }
}
Write-Output 'Import exit code 0; 26/26 imported textures passed; new sidecars and texture cache copied.'
