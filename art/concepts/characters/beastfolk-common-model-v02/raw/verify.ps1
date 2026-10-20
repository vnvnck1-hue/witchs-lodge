param([switch]$Compare)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class BeastfolkAlphaQA {
  public static long[] Inspect(Bitmap im) {
    var rect=new Rectangle(0,0,im.Width,im.Height);
    var data=im.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
    var bytes=new byte[Math.Abs(data.Stride)*im.Height]; Marshal.Copy(data.Scan0,bytes,0,bytes.Length);
    long minX=im.Width,minY=im.Height,maxX=-1,maxY=-1,zero=0,partial=0,opaque=0,border=0;
    for(int y=0;y<im.Height;y++) for(int x=0;x<im.Width;x++) {
      int a=bytes[y*data.Stride+x*4+3];
      if(a==0)zero++;else if(a==255)opaque++;else partial++;
      if(a>0 && (x==0||y==0||x==im.Width-1||y==im.Height-1))border++;
      if(a>127){minX=Math.Min(minX,x);minY=Math.Min(minY,y);maxX=Math.Max(maxX,x);maxY=Math.Max(maxY,y);}
    }
    im.UnlockBits(data); return new long[]{minX,minY,maxX,maxY,zero,partial,opaque,border};
  }
}
'@
$outDir=Split-Path $PSScriptRoot -Parent
$repo=(Get-Location).Path
$nibPath=Join-Path $repo 'art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png'
$sourcePath=Join-Path $PSScriptRoot 'beastfolk-common-3q-v02-gen02.png'
$finalPath=Join-Path $outDir 'beastfolk-common-3q-v02.png'
$source=[System.Drawing.Bitmap]::FromFile($sourcePath)
$s=[BeastfolkAlphaQA]::Inspect($source)
$scale=1112.0/($s[3]-$s[1]+1)
$dx=768.0-(($s[0]+$s[2]+1)/2.0)*$scale
$dy=218.0-$s[1]*$scale
$final=New-Object System.Drawing.Bitmap 1536,1536,([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g=[System.Drawing.Graphics]::FromImage($final)
$g.CompositingMode=[System.Drawing.Drawing2D.CompositingMode]::SourceCopy
$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear([System.Drawing.Color]::Transparent)
$dest=New-Object System.Drawing.RectangleF ([single]$dx),([single]$dy),([single]($source.Width*$scale)),([single]($source.Height*$scale))
$srcRect=New-Object System.Drawing.RectangleF 0,0,([single]$source.Width),([single]$source.Height)
$g.DrawImage($source,$dest,$srcRect,[System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$final.Save($finalPath,[System.Drawing.Imaging.ImageFormat]::Png)
$f=[BeastfolkAlphaQA]::Inspect($final)
$nib=[System.Drawing.Bitmap]::FromFile($nibPath)
$n=[BeastfolkAlphaQA]::Inspect($nib)
$report=[ordered]@{
  alpha_bbox_threshold='alpha > 127; inclusive coordinates'
  source=[ordered]@{width=$source.Width;height=$source.Height;bbox=$s[0..3];height_px=$s[3]-$s[1]+1;transparent_pixels=$s[4];partial_alpha_pixels=$s[5];opaque_pixels=$s[6];nonzero_border_pixels=$s[7]}
  normalization=[ordered]@{method='Uniform bicubic scale and translation only; no anatomical, color, background-removal or alpha-threshold edits';scale=$scale;dx=$dx;dy=$dy}
  final=[ordered]@{width=$final.Width;height=$final.Height;bbox=$f[0..3];height_px=$f[3]-$f[1]+1;head_top_y=312;head_bottom_boundary_y=832;head_height_approx_px=520;head_ratio_approx_percent=520.0/($f[3]-$f[1]+1)*100;transparent_pixels=$f[4];partial_alpha_pixels=$f[5];opaque_pixels=$f[6];nonzero_border_pixels=$f[7];sha256=(Get-FileHash -LiteralPath $finalPath -Algorithm SHA256).Hash;bytes=(Get-Item -LiteralPath $finalPath).Length}
  nib=[ordered]@{width=$nib.Width;height=$nib.Height;bbox=$n[0..3];height_px=$n[3]-$n[1]+1;head_top_y=218;head_bottom_boundary_y=733;head_height_approx_px=515;head_ratio_approx_percent=515.0/($n[3]-$n[1]+1)*100}
}
$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
if($Compare){
  $sheet=New-Object System.Drawing.Bitmap 1536,820
  $cg=[System.Drawing.Graphics]::FromImage($sheet)
  $cg.Clear([System.Drawing.Color]::FromArgb(235,232,222))
  $cg.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $cg.DrawImage($nib,0,40,768,768)
  $cg.DrawImage($final,768,40,768,768)
  $font=New-Object System.Drawing.Font 'Arial',18
  $brush=[System.Drawing.Brushes]::Black
  $cg.DrawString('Nib v03 | head ~515 / height 1112 = 46.3%',$font,$brush,20,8)
  $cg.DrawString('Beastfolk v02 | head ~520 / height 1113 = 46.7%',$font,$brush,788,8)
  $pen=New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(180,30,110,160)),2
  foreach($yy in @(218,733,1330)){$cg.DrawLine($pen,180,[single](40+$yy/2),590,[single](40+$yy/2))}
  $headTop=312
  $headBottom=832
  foreach($yy in @($headTop,$headBottom,1330)){$cg.DrawLine($pen,948,[single](40+$yy/2),1358,[single](40+$yy/2))}
  $cg.Dispose();$font.Dispose();$pen.Dispose()
  $sheet.Save((Join-Path $PSScriptRoot 'nib-beastfolk-proportion-comparison.png'),[System.Drawing.Imaging.ImageFormat]::Png)
  $sheet.Dispose()
}
$source.Dispose();$final.Dispose();$nib.Dispose()
$report | ConvertTo-Json -Depth 6
