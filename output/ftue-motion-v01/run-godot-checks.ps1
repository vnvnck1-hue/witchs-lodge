$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path "$PSScriptRoot/../..").Path
$exe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
Set-Location -LiteralPath $taskRoot
$env:APPDATA=Join-Path $PSScriptRoot 'godot-user-data'
New-Item -ItemType Directory -Force $env:APPDATA|Out-Null
$p=Start-Process -FilePath $exe -ArgumentList @('--headless','--path','godot','--import') -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput "$PSScriptRoot/import.log" -RedirectStandardError "$PSScriptRoot/import-errors.log"
@{exit_code=$p.ExitCode;created=(Get-Date -Format o);command='.tools/Godot-4.7.2.exe --headless --path godot --import'}|ConvertTo-Json|Set-Content -Encoding UTF8 "$PSScriptRoot/import-result.json"
Write-Output "Godot import exit=$($p.ExitCode)"
if($p.ExitCode -ne 0){exit $p.ExitCode}
$p=Start-Process -FilePath $exe -ArgumentList @('--headless','--path','godot','--script','res://tools/verify_prologue_motion.gd') -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput "$PSScriptRoot/runtime-verification.log" -RedirectStandardError "$PSScriptRoot/runtime-verification-errors.log"
@{exit_code=$p.ExitCode;created=(Get-Date -Format o)}|ConvertTo-Json|Set-Content -Encoding UTF8 "$PSScriptRoot/runtime-result.json"
Write-Output "Godot timeline/manifest verification exit=$($p.ExitCode)"
$scriptPath=Join-Path $PSScriptRoot 'capture-review.gd'
$p=Start-Process -FilePath $exe -ArgumentList @('--path','godot','--resolution','1920x1080','--rendering-method','gl_compatibility','--script',('"'+$scriptPath+'"')) -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput "$PSScriptRoot/capture-review.log" -RedirectStandardError "$PSScriptRoot/capture-review-errors.log"
@{exit_code=$p.ExitCode;created=(Get-Date -Format o);cuts=@(1,2,4)}|ConvertTo-Json|Set-Content -Encoding UTF8 "$PSScriptRoot/capture-result.json"
Write-Output "Godot rendered review exit=$($p.ExitCode)"
