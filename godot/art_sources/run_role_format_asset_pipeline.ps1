$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskOut=Join-Path $taskRoot 'output/role-format-v02'
$taskExe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
New-Item -ItemType Directory -Force "$taskOut/runtime-appdata/roaming","$taskOut/runtime-appdata/local" | Out-Null
$env:APPDATA="$taskOut/runtime-appdata/roaming"
$env:LOCALAPPDATA="$taskOut/runtime-appdata/local"
$taskPlan=Get-Content (Join-Path $taskRoot 'art/cards/role-format-v02/generation-plan.json') -Raw | ConvertFrom-Json
if($taskPlan.entries.Count -ne 27){throw 'Expected all 27 assets'}
foreach($taskEntry in $taskPlan.entries){
    $taskSource=Join-Path $taskRoot ('art/cards/role-format-v02/'+$taskEntry.id+'.png')
    if(-not (Test-Path -LiteralPath $taskSource)){throw "Missing $taskSource"}
    Copy-Item -LiteralPath $taskSource -Destination (Join-Path $taskRoot ('art/cards/rounded/'+$taskEntry.id+'.png'))
}
$steps=@(
    @{name='packaging';args=@('--headless','--script','res://tools/package_card_assets.gd')},
    @{name='import';args=@('--headless','--editor','--import')},
    @{name='card-verify';args=@('--headless','--script','res://tools/verify_card_assets.gd')},
    # Real renderer is necessary to inspect alpha blending and scaled imported art.
    @{name='gallery';args=@('--script','res://tools/preview_pocket_card_assets.gd','--rendering-method','gl_compatibility')}
)
foreach($step in $steps){
    $taskLog=Join-Path $taskOut ($step.name+'.log')
    $taskArgs=@('--path',('"'+(Join-Path $taskRoot 'godot')+'"'),'--log-file',('"'+$taskLog+'"'))+$step.args
    $taskProcess=Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
    Write-Output ($step.name+': '+$taskProcess.ExitCode)
    if($taskProcess.ExitCode -ne 0){throw "Asset pipeline failed: $($step.name). See $taskLog"}
}
