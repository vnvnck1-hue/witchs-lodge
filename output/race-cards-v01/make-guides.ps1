$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force (Join-Path $PSScriptRoot 'layout-guides') | Out-Null
$taskPlan=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'production-plan-v02.json') | ConvertFrom-Json
$taskFmt=New-Object System.Drawing.StringFormat
$taskFmt.Alignment=[System.Drawing.StringAlignment]::Center
$taskFmt.LineAlignment=[System.Drawing.StringAlignment]::Center
$taskTitle=New-Object System.Drawing.Font 'Malgun Gothic',70,([System.Drawing.FontStyle]::Bold),([System.Drawing.GraphicsUnit]::Pixel)
$taskCat=New-Object System.Drawing.Font 'Malgun Gothic',38,([System.Drawing.FontStyle]::Bold),([System.Drawing.GraphicsUnit]::Pixel)
$taskBody=New-Object System.Drawing.Font 'Malgun Gothic',40,([System.Drawing.FontStyle]::Bold),([System.Drawing.GraphicsUnit]::Pixel)
foreach($taskE in $taskPlan){
 $taskIm=New-Object System.Drawing.Bitmap 1024,1536
 $taskG=[System.Drawing.Graphics]::FromImage($taskIm);$taskG.TextRenderingHint=[System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
 $taskG.Clear([System.Drawing.Color]::FromArgb(116,88,140))
 $taskG.FillRectangle([System.Drawing.Brushes]::Cornsilk,65,40,894,290)
 $taskG.FillRectangle([System.Drawing.Brushes]::Cornsilk,55,1120,915,375)
 $taskG.DrawString($taskE.name,$taskTitle,[System.Drawing.Brushes]::Black,(New-Object System.Drawing.RectangleF 110,72,804,164),$taskFmt)
 $taskG.DrawString($taskE.category,$taskCat,[System.Drawing.Brushes]::Black,(New-Object System.Drawing.RectangleF 110,260,804,50),$taskFmt)
 $taskG.DrawString($taskE.printed_rules[0],$taskBody,[System.Drawing.Brushes]::Black,(New-Object System.Drawing.RectangleF 110,1240,804,60),$taskFmt)
 $taskG.DrawString($taskE.printed_rules[1],$taskBody,[System.Drawing.Brushes]::Black,(New-Object System.Drawing.RectangleF 110,1300,804,60),$taskFmt)
 if($taskE.kind -eq 'spell'){
  $taskPoints=[System.Drawing.Point[]]@((New-Object System.Drawing.Point 512,340),(New-Object System.Drawing.Point 892,720),(New-Object System.Drawing.Point 512,1100),(New-Object System.Drawing.Point 132,720))
  $taskPen=New-Object System.Drawing.Pen ([System.Drawing.Color]::Black),20
  $taskG.DrawPolygon($taskPen,$taskPoints);$taskPen.Dispose()
 }
 $taskIm.Save((Join-Path $PSScriptRoot ('layout-guides/'+$taskE.id+'.png')),[System.Drawing.Imaging.ImageFormat]::Png)
 $taskG.Dispose();$taskIm.Dispose()
}
$taskTitle.Dispose();$taskCat.Dispose();$taskBody.Dispose();$taskFmt.Dispose()
Write-Output '43 layout guides made. Guides only, never delivery art.'
