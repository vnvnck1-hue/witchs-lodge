$ErrorActionPreference = 'Stop'
$taskPython = 'C:\Users\vnvnc\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$taskReviewUrl = 'http://127.0.0.1:8614/'
$taskServerReady = $false
try { $taskResponse = Invoke-WebRequest -Uri ($taskReviewUrl + 'api/state') -UseBasicParsing -TimeoutSec 2; $taskServerReady = ($taskResponse.StatusCode -eq 200) } catch { }
if (-not $taskServerReady) {
    $taskServerScript = Join-Path $PSScriptRoot 'server.py'
    Start-Process -FilePath $taskPython -ArgumentList ('"{0}"' -f $taskServerScript) -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -RedirectStandardOutput (Join-Path $PSScriptRoot 'server-output.log') -RedirectStandardError (Join-Path $PSScriptRoot 'server-error.log')
    Start-Sleep -Milliseconds 800
}
Start-Process $taskReviewUrl
