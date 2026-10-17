param([string[]]$OnlyIds = @())
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$taskOut = Join-Path $taskRoot 'output/expansion-cards-v01'
$taskExe = Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
New-Item -ItemType Directory -Force "$taskOut/runtime-appdata/roaming", "$taskOut/runtime-appdata/local" | Out-Null
$env:APPDATA = "$taskOut/runtime-appdata/roaming"
$env:LOCALAPPDATA = "$taskOut/runtime-appdata/local"
$taskPlan = Get-Content -Encoding UTF8 (Join-Path $taskOut 'generation-plan.json') -Raw | ConvertFrom-Json
$taskIds = @($taskPlan.entries | ForEach-Object { $_.id })
if ($taskIds.Count -ne 12) { throw 'Expected 12 expansion IDs' }
if ($OnlyIds.Count -gt 0) {
    foreach ($taskId in $OnlyIds) { if ($taskId -notin $taskIds) { throw "Not an expansion ID: $taskId" } }
    $taskIds = $OnlyIds
}
$steps = @(
    @{name='packaging'; args=@('--headless','--script','res://tools/package_card_assets.gd','--') + $taskIds},
    @{name='import'; args=@('--headless','--editor','--import')},
    @{name='card-verify'; args=@('--headless','--script','res://tools/verify_card_assets.gd')},
    # Real renderer is needed for imported alpha blending and hand-size appearance.
    @{name='gallery'; args=@('--script','res://tools/preview_expansion_card_assets.gd','--rendering-method','gl_compatibility')}
)
foreach ($step in $steps) {
    $taskLog = Join-Path $taskOut ($step.name+'.log')
    $taskArgs = @('--path', ('"'+(Join-Path $taskRoot 'godot')+'"'), '--log-file', ('"'+$taskLog+'"')) + $step.args
    $taskProcess = Start-Process -FilePath $taskExe -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden
    Write-Output ($step.name+': '+$taskProcess.ExitCode)
    if ($taskProcess.ExitCode -ne 0) { throw "Asset pipeline failed: $($step.name). See $taskLog" }
}
