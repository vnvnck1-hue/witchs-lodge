$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskOut=Join-Path $taskRoot 'output/role-format-v02'
$taskExe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
New-Item -ItemType Directory -Force "$taskOut/runtime-temp","$taskOut/export-sandbox" | Out-Null
$env:APPDATA="$taskOut/runtime-appdata/roaming"
$env:LOCALAPPDATA="$taskOut/runtime-appdata/local"
$env:TEMP="$taskOut/runtime-temp"
$env:TMP="$taskOut/runtime-temp"
$taskCandidate=Join-Path $taskOut 'WitchsLodge-role-format-v02.pck'
$taskProcess=Start-Process -FilePath $taskExe -ArgumentList @('--headless','--path',('"'+(Join-Path $taskRoot 'godot')+'"'),'--log-file',('"'+$taskOut+'/export.log"'),'--export-pack','"Windows Desktop"',('"'+$taskCandidate+'"')) -Wait -PassThru -WindowStyle Hidden
if($taskProcess.ExitCode -ne 0){throw 'Export failed'}
if(Select-String -LiteralPath "$taskOut/export.log" -Pattern '^ERROR:' -Quiet){throw 'Export reported errors; inspect log'}
Write-Output 'Export: 0'
$taskManifest=Join-Path $taskRoot 'art/cards/role-format-v02/delivery-manifest.json'
$taskReport=Join-Path $taskOut 'export-verification.json'
$taskScript=Join-Path $taskRoot 'godot/tools/verify_role_format_export.gd'
$taskProcess=Start-Process -FilePath $taskExe -WorkingDirectory "$taskOut/export-sandbox" -ArgumentList @('--headless','--main-pack',('"'+$taskCandidate+'"'),'--log-file',('"'+$taskOut+'/export-verify.log"'),'--script',('"'+$taskScript+'"'),'--',('"'+$taskManifest+'"'),('"'+$taskReport+'"')) -Wait -PassThru -WindowStyle Hidden
if($taskProcess.ExitCode -ne 0){throw 'Export texture verification failed'}
$taskEvidence=Get-Content -LiteralPath $taskReport -Raw | ConvertFrom-Json
if(-not $taskEvidence.passed -or $taskEvidence.texture_count -ne 54){throw 'Incomplete exported texture evidence'}
Write-Output 'Export verify: 54/54 matching textures'
$taskLive=Join-Path $taskRoot 'build/WitchsLodge.pck'
$taskBackup=Join-Path $taskOut 'before/WitchsLodge.pck'
if(-not (Test-Path -LiteralPath $taskBackup)){Copy-Item -LiteralPath $taskLive -Destination $taskBackup}
Copy-Item -LiteralPath $taskCandidate -Destination $taskLive
if((Get-FileHash -LiteralPath $taskCandidate).Hash -ne (Get-FileHash -LiteralPath $taskLive).Hash){throw 'Live pack copy differs'}
Write-Output 'build/WitchsLodge.pck updated from verified candidate'
