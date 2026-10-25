$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$paths=@('art/cards/legendary-v01/drunken_erin_legendary_blank.png','godot/assets/cards/timber.png')
foreach($rel in $paths){
  $b=[System.Drawing.Bitmap]::new((Join-Path $root $rel))
  Write-Output "$rel $($b.PixelFormat) corner=$($b.GetPixel(0,0).A),$($b.GetPixel(1023,1535).A)"
  $out=[System.Drawing.Bitmap]::new(1024,1024)
  $g=[System.Drawing.Graphics]::FromImage($out)
  $g.Clear([System.Drawing.Color]::DimGray)
  $rects=@(@(0,210,256,256),@(768,210,256,256),@(0,840,256,350),@(768,840,256,350),@(344,975,336,240))
  $dests=@(@(0,0),@(512,0),@(0,512),@(768,512),@(300,512))
  for($i=0;$i -lt $rects.Count;$i++){
    $r=$rects[$i]; $d=$dests[$i]
    $g.DrawImage($b,[System.Drawing.Rectangle]::new($d[0],$d[1],$r[2],$r[3]),[System.Drawing.Rectangle]::new($r[0],$r[1],$r[2],$r[3]),[System.Drawing.GraphicsUnit]::Pixel)
  }
  $name=if($rel -like '*legendary*'){'legend-frame-detail.png'}else{'resource-frame-detail.png'}
  $out.Save((Join-Path $PSScriptRoot $name),[System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose();$out.Dispose();$b.Dispose()
}
