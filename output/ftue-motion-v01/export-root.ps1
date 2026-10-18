$ErrorActionPreference='Stop'
$taskRoot=(Resolve-Path "$PSScriptRoot/../..").Path
$exe=Join-Path $taskRoot '.tools/Godot-4.7.2.exe'
$destination=Join-Path $taskRoot 'WitchsLodge.exe'
Set-Location -LiteralPath $taskRoot
foreach($game in @(Get-Process -Name WitchsLodge -ErrorAction SilentlyContinue)){
 if($game.Path -eq $destination){[void]$game.CloseMainWindow();if(-not $game.WaitForExit(8000)){Stop-Process -Id $game.Id; $game.WaitForExit()}}
}
$p=Start-Process -FilePath $exe -ArgumentList @('--headless','--path','godot','--export-release','"Windows Desktop"','../WitchsLodge.exe') -WindowStyle Hidden -Wait -PassThru -RedirectStandardOutput "$PSScriptRoot/export.log" -RedirectStandardError "$PSScriptRoot/export-errors.log"
$file=Get-Item -LiteralPath $destination
@{exit_code=$p.ExitCode;path='WitchsLodge.exe';bytes=$file.Length;sha256=(Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash;created=(Get-Date -Format o);embed_pck=$true;icon='godot/icon.ico'}|ConvertTo-Json|Set-Content -Encoding UTF8 "$PSScriptRoot/export-result.json"
Write-Output "Root executable export exit=$($p.ExitCode), bytes=$($file.Length)"
exit $p.ExitCode
