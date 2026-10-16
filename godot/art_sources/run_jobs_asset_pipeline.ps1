$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskOut=Join-Path $taskRoot 'output/jobs-update-v01'
$taskExe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
New-Item -ItemType Directory -Force "$taskOut/runtime/roaming","$taskOut/runtime/local" | Out-Null
$env:APPDATA="$taskOut/runtime/roaming"
$env:LOCALAPPDATA="$taskOut/runtime/local"
$steps=@(
    @{name='packaging';args=@('--headless','--script','res://tools/package_card_assets.gd')},
    @{name='import';args=@('--headless','--editor','--import')},
    @{name='card-verify';args=@('--headless','--script','res://tools/verify_card_assets.gd')},
    @{name='asset-verify';args=@('--headless','--script','res://tools/verify_jobs_update_assets.gd')},
    @{name='gallery';args=@('--script','res://tools/preview_jobs_update_assets.gd','--rendering-method','gl_compatibility')},
    @{name='wildlife-preview';args=@('--script','res://tools/preview_jobs_wildlife.gd')}
)
foreach($step in $steps){
    $taskLog=Join-Path $taskOut ($step.name+'.log')
    $taskArgs=@('--path',('"'+(Join-Path $taskRoot 'godot')+'"'),'--log-file',('"'+$taskLog+'"'))+$step.args
    $taskProcess=Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
    Write-Output ($step.name+': '+$taskProcess.ExitCode)
    if($taskProcess.ExitCode -ne 0){throw "Asset pipeline failed: $($step.name). See $taskLog"}
    if($step.name -eq 'gallery'){
        Copy-Item -LiteralPath (Join-Path $taskOut 'asset-gallery.png') -Destination (Join-Path $taskRoot 'godot/screenshots/cards/asset-gallery.png')
    }
}
