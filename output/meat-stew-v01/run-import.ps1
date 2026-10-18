$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$taskData = Join-Path $PSScriptRoot 'godot-user-data'
New-Item -ItemType Directory -Force "$taskData/roaming", "$taskData/local" | Out-Null
$env:APPDATA = "$taskData/roaming"
$env:LOCALAPPDATA = "$taskData/local"
$taskExe = Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
$taskArgs = @('--headless','--path','godot','--import','--log-file',('"'+(Join-Path $PSScriptRoot 'import.log')+'"'))
$taskProcess = Start-Process -FilePath $taskExe -WorkingDirectory $taskRoot -ArgumentList $taskArgs -Wait -PassThru -WindowStyle Hidden -RedirectStandardOutput (Join-Path $PSScriptRoot 'import-stdout.log') -RedirectStandardError (Join-Path $PSScriptRoot 'import-stderr.log')
@{exit_code=$taskProcess.ExitCode;method='requested real game project import';command='.tools/Godot-4.7.2.exe --headless --path godot --import';log='output/meat-stew-v01/import.log'} | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'import-result.json')
Write-Output ('Godot import exit code: '+$taskProcess.ExitCode)
if ($taskProcess.ExitCode -ne 0) { throw 'Import failed' }
