$ErrorActionPreference='Stop'
if(Get-Process -Id 64596 -ErrorAction SilentlyContinue){throw 'Concurrent export is still active; do not touch its output.'}
$taskRoot=(Resolve-Path "$PSScriptRoot/../..").Path
$comparison=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/concurrent-export-assets.json"|ConvertFrom-Json
$concurrent=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/concurrent-export-result.json"|ConvertFrom-Json
if($comparison.matched -ne 48 -or $comparison.mismatches.Count -ne 0){throw 'Concurrent project motion assets differ.'}
if($null -ne $concurrent.exit_code -and $concurrent.exit_code -ne 0){throw 'Concurrent export failed.'}
Set-Location -LiteralPath $taskRoot
$env:APPDATA=Join-Path $PSScriptRoot 'godot-user-data'
$engine=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
$target=Join-Path $taskRoot 'WitchsLodge.exe'
$checker=Join-Path $PSScriptRoot 'check-packaged-assets.gd'
$p=Start-Process -FilePath $engine -ArgumentList @('--headless','--path','godot','--main-pack',('"'+$target+'"'),'--script',('"'+$checker+'"'),'--',('"'+$taskRoot+'"')) -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput "$PSScriptRoot/packaged-assets.log" -RedirectStandardError "$PSScriptRoot/packaged-assets-errors.log"
if($p.ExitCode -ne 0){throw "Packaged motion check failed: $($p.ExitCode)"}
$packaged=Get-Content -Raw -Encoding UTF8 "$PSScriptRoot/packaged-assets-verification.json"|ConvertFrom-Json
if(-not $packaged.passed){throw 'Packaged motion assets do not match delivery.'}
Copy-Item -LiteralPath "$PSScriptRoot/export-result.json" -Destination "$PSScriptRoot/export-attempt-result.json" -Force
$file=Get-Item -LiteralPath $target
@{path='WitchsLodge.exe';bytes=$file.Length;sha256=(Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash;exit_code=$concurrent.exit_code;succeeded=$true;own_export_attempt_exit_code=1;completed_by='Concurrent Windows Desktop release export after byte-identical comparison of 44 motion PNGs and 4 JSON manifests.';packaged_motion_verification_exit_code=$p.ExitCode;embed_pck=$true;icon='godot/icon.ico';created=(Get-Date -Format o)}|ConvertTo-Json|Set-Content -Encoding UTF8 "$PSScriptRoot/export-result.json"
& "$env:WINDIR/System32/WindowsPowerShell/v1.0/powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "$PSScriptRoot/finalize-delivery.ps1"
exit $LASTEXITCODE
