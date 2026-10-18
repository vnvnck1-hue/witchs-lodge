$ErrorActionPreference='Stop'
Add-Type -Path "$PSScriptRoot/ImagePipeline.cs" -ReferencedAssemblies System.Drawing
$taskRoot=(Resolve-Path "$PSScriptRoot/../..").Path
$artDir=Join-Path $taskRoot 'godot/assets/ui/ftue/motion'
$preDir=Join-Path $taskRoot 'godot/screenshots/ftue/motion'
$sheet=[System.Drawing.Bitmap]::new(2560,2240)
$g=[System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::FromArgb(25,22,38))
$font=[System.Drawing.Font]::new('Arial',18)
$small=[System.Drawing.Font]::new('Arial',13)
$brush=[System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(232,224,207))
for($n=1;$n -le 4;$n++){
 $row=($n-1)*550
 $g.DrawString("CUT $n / 2304 x 1296 canvas / screen crop 1920 x 1080",$font,$brush,20,($row+8))
 $p=Join-Path $preDir "cut${n}_preview.png"
 $b=[MotionImage]::Load($p);$g.DrawImage($b,20,($row+48),800,450);$b.Dispose()
 $m=Get-Content -Raw -Encoding UTF8 (Join-Path $artDir "cut$n.json")|ConvertFrom-Json
 $i=0
 foreach($l in $m.layers){
  $x=845+($i%7)*241;$y=$row+48+[Math]::Floor($i/7)*225
  $g.FillRectangle([System.Drawing.Brushes]::DimGray,[int]$x,[int]$y,226,180)
  $b=[MotionImage]::Load((Join-Path $artDir $l.file));$s=[Math]::Min(216.0/$b.Width,170.0/$b.Height)
  $w=[int]($b.Width*$s);$h=[int]($b.Height*$s)
  $g.DrawImage($b,[int]($x+(226-$w)/2),[int]($y+(180-$h)/2),$w,$h);$b.Dispose()
  $g.DrawString($l.file,$small,$brush,[single]$x,[single]($y+183))
  $g.DrawString("$($l.pos -join ',') / depth $($l.depth) / $($l.blend)",$small,$brush,[single]$x,[single]($y+201))
  $i++
 }
}
$g.Dispose();[MotionImage]::Save($sheet,(Join-Path $preDir 'contact-sheet.png'),$true);$sheet.Dispose()
$font.Dispose();$small.Dispose();$brush.Dispose()
Write-Output 'Contact sheet saved.'
