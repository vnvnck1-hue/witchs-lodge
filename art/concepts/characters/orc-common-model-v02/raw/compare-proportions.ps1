Add-Type -AssemblyName System.Drawing
$folder = Split-Path -Parent $PSScriptRoot
$nibPath = Join-Path (Split-Path -Parent $folder) 'goblin-nib-model-v03/nib-3q-v03.png'
$nib = [System.Drawing.Bitmap]::FromFile($nibPath)
$orc = [System.Drawing.Bitmap]::FromFile((Join-Path $folder 'orc-common-3q-v02.png'))
$proof = New-Object System.Drawing.Bitmap 3072,1536
$g = [System.Drawing.Graphics]::FromImage($proof)
$g.Clear([System.Drawing.Color]::FromArgb(235,235,235))
$g.DrawImageUnscaled($nib,0,0)
$g.DrawImageUnscaled($orc,1536,0)
$font = New-Object System.Drawing.Font 'Arial',27
$small = New-Object System.Drawing.Font 'Arial',20
$pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(135,30,100,155)),2
$pen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$g.DrawString('NIB V03 | head approx. 46.5%', $font, [System.Drawing.Brushes]::Black, 80,75)
$g.DrawString('ORC V02 | head approx. 46.1%', $font, [System.Drawing.Brushes]::Black, 1616,75)
foreach ($offset in 0,1536) {
 $chin = if ($offset -eq 0) {734} else {729}
 foreach ($y in 217,$chin,1330) { $g.DrawLine($pen,$offset+130,$y,$offset+1390,$y) }
 $g.DrawString('top 217', $small, [System.Drawing.Brushes]::Black, $offset+35,175)
 $g.DrawString(('chin approx. '+$chin), $small, [System.Drawing.Brushes]::Black, $offset+35,$chin+8)
 $g.DrawString('sole 1330', $small, [System.Drawing.Brushes]::Black, $offset+35,1340)
}
$g.DrawString('Ear extent excluded. Hair/topknot included. Chin landmarks are visual estimates (+/- 4px).',$small,[System.Drawing.Brushes]::Black,400,1450)
$proof.Save((Join-Path $PSScriptRoot 'nib-orc-proportion-proof.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$pen.Dispose(); $font.Dispose(); $small.Dispose(); $g.Dispose(); $proof.Dispose(); $nib.Dispose(); $orc.Dispose()
