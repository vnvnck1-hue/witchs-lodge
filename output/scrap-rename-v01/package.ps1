$taskRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
. (Join-Path $PSScriptRoot 'image-utils.ps1')
$taskDelivery=@()
foreach($taskId in @('scrap','junk_sack')) {
  $taskBefore=[CardImages]::Read((Join-Path $PSScriptRoot ('before/'+$taskId+'.png')))
  $taskGenerated=[CardImages]::Read((Join-Path $PSScriptRoot ('generated/'+$taskId+'.png')))
  if($taskGenerated.Width -ne 1024 -or $taskGenerated.Height -ne 1536) {throw 'Generated size mismatch'}
  if($taskId -eq 'junk_sack') {
    # Keep all existing pixels outside the explicitly requested second-line panel edit.
    $taskFinal=$taskBefore.Clone()
    [CardImages]::Patch($taskFinal,$taskGenerated,180,1306,845,1385,8)
  } else {
    $taskFinal=$taskGenerated.Clone()
    # Retain the exact established rounded card silhouette and opaque card interior.
    [CardImages]::AlphaFrom($taskFinal,$taskBefore)
  }
  foreach($taskPath in @(('art/cards/scrap-rename-v01/'+$taskId+'.png'),('godot/assets/cards/'+$taskId+'.png'))) {
    Save-Png $taskFinal $taskPath
    $taskDelivery += $taskPath
  }
  $taskHand=[CardImages]::Resize($taskFinal,256,384)
  $taskPath='godot/assets/cards/hand/'+$taskId+'.png'
  Save-Png $taskHand $taskPath
  $taskDelivery += $taskPath
  $taskReview=New-Object System.Drawing.Bitmap(1024,816)
  $taskGraphics=[System.Drawing.Graphics]::FromImage($taskReview)
  $taskGraphics.Clear([System.Drawing.Color]::FromArgb(35,29,48))
  $taskGraphics.DrawImageUnscaled($taskFinal.Clone([System.Drawing.Rectangle]::new(0,0,1024,380),$taskFinal.PixelFormat),0,0)
  $taskGraphics.DrawImageUnscaled($taskFinal.Clone([System.Drawing.Rectangle]::new(0,1120,1024,416),$taskFinal.PixelFormat),0,400)
  $taskGraphics.Dispose()
  Save-Png $taskReview ('output/scrap-rename-v01/review-'+$taskId+'.png')
  if($taskId -eq 'junk_sack') {
    $taskDiff=[CardImages]::Diff($taskBefore,$taskFinal,180,1306,845,1385)
    if($taskDiff[1] -ne 0) {throw 'Junk sack changed outside permitted text patch'}
    @{changed_pixels=$taskDiff[0];outside_patch_changed_pixels=$taskDiff[1];changed_bounds=@($taskDiff[2..5]);allowed_patch=@(180,1306,845,1385);feather_pixels=8;passed=($taskDiff[0] -gt 0 -and $taskDiff[1] -eq 0)} | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'junk-sack-pixel-diff.json')
  }
  Write-Output ($taskId+' packaged; text rows: '+([CardImages]::TextRows($taskFinal) -join ', '))
  $taskBefore.Dispose();$taskGenerated.Dispose();$taskFinal.Dispose();$taskHand.Dispose();$taskReview.Dispose()
}
$taskDelivery | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'delivery-files.json')
$taskBoard=New-Object System.Drawing.Bitmap(1496,506)
$taskGraphics=[System.Drawing.Graphics]::FromImage($taskBoard)
$taskGraphics.Clear([System.Drawing.Color]::FromArgb(35,29,48))
$taskFont=New-Object System.Drawing.Font('Segoe UI',14)
$taskBrush=[System.Drawing.Brushes]::AntiqueWhite
$taskGraphics.DrawString('Scrap rename v01 | Actual 256 x 384 hand scale | New / previous / approved resource', $taskFont,$taskBrush,18,12)
$taskItems=@(
  @('NEW scrap','godot/assets/cards/hand/scrap.png'),
  @('NEW junk_sack','godot/assets/cards/hand/junk_sack.png'),
  @('PREVIOUS scrap','art/cards/goblin-v01/scrap.png'),
  @('PREVIOUS junk_sack','art/cards/goblin-v01/junk_sack.png'),
  @('APPROVED resource','art/concepts/cards/roles-individual-v02/03-resource-timber.png')
)
for($taskI=0;$taskI -lt $taskItems.Count;$taskI++) {
  $taskX=20+$taskI*296
  $taskGraphics.DrawString($taskItems[$taskI][0],$taskFont,$taskBrush,$taskX,56)
  $taskImage=[CardImages]::Read((Join-Path $taskRoot $taskItems[$taskI][1]))
  $taskSmall=[CardImages]::Resize($taskImage,256,384)
  $taskGraphics.DrawImageUnscaled($taskSmall,$taskX,88)
  $taskImage.Dispose();$taskSmall.Dispose()
}
$taskGraphics.Dispose();$taskFont.Dispose()
Save-Png $taskBoard 'godot/screenshots/scrap-rename/sheet.png'
$taskBoard.Dispose()
Write-Output 'Delivered 6 PNGs, pixel diff, 1:1 lettering reviews, five-card preview sheet.'
