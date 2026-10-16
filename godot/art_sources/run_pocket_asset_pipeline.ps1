$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskOut=Join-Path $taskRoot 'output/pocket-cards-v01'
$taskExe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
New-Item -ItemType Directory -Force "$taskOut/runtime-appdata/roaming","$taskOut/runtime-appdata/local" | Out-Null
$env:APPDATA="$taskOut/runtime-appdata/roaming"
$env:LOCALAPPDATA="$taskOut/runtime-appdata/local"
$steps=@(
    @{name='packaging';args=@('--headless','--script','res://tools/package_card_assets.gd','--','poison_mushroom','old_spellbook')},
    @{name='icon-packaging';args=@('--headless','--script','res://tools/record_pocket_assets.gd','--','prepare')},
    @{name='import';args=@('--headless','--editor','--import')},
    @{name='card-verify';args=@('--headless','--script','res://tools/verify_card_assets.gd')},
    @{name='record';args=@('--headless','--script','res://tools/record_pocket_assets.gd')},
    @{name='gallery';args=@('--script','res://tools/preview_pocket_card_assets.gd','--rendering-method','gl_compatibility')}
)
foreach($step in $steps){
    $taskLog=Join-Path $taskOut ($step.name+'.log')
    $taskArgs=@('--path',('"'+(Join-Path $taskRoot 'godot')+'"'),'--log-file',('"'+$taskLog+'"'))+$step.args
    $taskProcess=Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
    Write-Output ($step.name+': '+$taskProcess.ExitCode)
    if($taskProcess.ExitCode -ne 0){throw "Asset pipeline failed: $($step.name). See $taskLog"}
}
