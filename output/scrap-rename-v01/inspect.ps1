$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
. (Join-Path $PSScriptRoot 'image-utils.ps1')
foreach($taskPart in @('before','generated')) {
  foreach($taskId in @('scrap','junk_sack')) {
    $taskPath=Join-Path $PSScriptRoot ($taskPart+'/'+$taskId+'.png')
    if(-not (Test-Path -LiteralPath $taskPath)) {continue}
    $taskImage=[CardImages]::Read($taskPath)
    Write-Output ($taskPart+'/'+$taskId+' '+$taskImage.Width+'x'+$taskImage.Height+' '+$taskImage.PixelFormat+' rows '+([CardImages]::TextRows($taskImage) -join ', '))
    $taskImage.Dispose()
  }
}
