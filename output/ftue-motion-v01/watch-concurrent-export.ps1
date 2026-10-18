$ErrorActionPreference='Stop'
$p=Get-Process -Id 64596 -ErrorAction SilentlyContinue
if($null -ne $p){
 while(-not $p.WaitForExit(30000)){
  Get-Content -LiteralPath "$PSScriptRoot/../race-job-cards-v01/godot-export-stdout.log" -Tail 1
 }
 $code=$p.ExitCode
}else{$code=$null}
@{process=64596;exit_code=$code;finished=(Get-Date -Format o);log='output/race-job-cards-v01/godot-export-stdout.log'}|ConvertTo-Json|Set-Content -Encoding UTF8 "$PSScriptRoot/concurrent-export-result.json"
Write-Output "Concurrent export process finished; exit=$code"
