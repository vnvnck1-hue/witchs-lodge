param([string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$drawingAssemblies = @('System.Drawing.Common','System.Drawing.Primitives','System.Private.Windows.GdiPlus','System.Private.Windows.Core')
Add-Type -ReferencedAssemblies $drawingAssemblies -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
public static class TavernCardPackaging {
  public static void ApplyExistingAlpha(Bitmap image, Bitmap mask) {
    var rect = new Rectangle(0,0,image.Width,image.Height);
    var a = image.LockBits(rect,ImageLockMode.ReadWrite,PixelFormat.Format32bppArgb);
    var b = mask.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
    try {
      byte[] ia = new byte[Math.Abs(a.Stride)*a.Height];
      byte[] ib = new byte[Math.Abs(b.Stride)*b.Height];
      Marshal.Copy(a.Scan0,ia,0,ia.Length); Marshal.Copy(b.Scan0,ib,0,ib.Length);
      for(int y=0;y<a.Height;y++) for(int x=0;x<a.Width;x++) ia[y*a.Stride+x*4+3]=ib[y*b.Stride+x*4+3];
      Marshal.Copy(ia,0,a.Scan0,ia.Length);
    } finally { image.UnlockBits(a); mask.UnlockBits(b); }
  }
  public static Bitmap Resize(Image image,int width,int height) {
    Bitmap result = new Bitmap(width,height,PixelFormat.Format32bppArgb);
    using(var g=Graphics.FromImage(result)) {
      g.CompositingMode=CompositingMode.SourceCopy;
      g.InterpolationMode=InterpolationMode.HighQualityBicubic;
      g.PixelOffsetMode=PixelOffsetMode.HighQuality;
      using(var attrs=new ImageAttributes()) {
        attrs.SetWrapMode(WrapMode.TileFlipXY);
        g.DrawImage(image,new Rectangle(0,0,width,height),0,0,image.Width,image.Height,GraphicsUnit.Pixel,attrs);
      }
    }
    return result;
  }
}
'@
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'prompts-and-sources.json') -Raw | ConvertFrom-Json
if($manifest.cards.Count -ne 8) { throw 'Expected exactly eight approved output records' }
$before = Join-Path $PSScriptRoot 'before'
$sources = Join-Path $PSScriptRoot 'sources'
$hand = Join-Path $PSScriptRoot 'hand'
New-Item -ItemType Directory -Force -Path $before,$sources,$hand | Out-Null
$mask = [System.Drawing.Bitmap]::new((Join-Path $ProjectRoot 'godot/assets/cards/dark_ale.png'))
$records = @()
foreach($card in $manifest.cards) {
  $id = $card.id
  $isVariant = $id -in @('drunk_rant_toast','drunk_rant_pout')
  $sourcePath = Join-Path $sources "$id.png"
  Copy-Item -LiteralPath $card.source -Destination $sourcePath -Force
  $inputImage = [System.Drawing.Bitmap]::new($sourcePath)
  $image = [TavernCardPackaging]::Resize($inputImage,1024,1536)
  $inputImage.Dispose()
  [TavernCardPackaging]::ApplyExistingAlpha($image,$mask)
  $master = Join-Path $PSScriptRoot "$id.png"
  $image.Save($master,[System.Drawing.Imaging.ImageFormat]::Png)
  $small = [TavernCardPackaging]::Resize($image,256,384)
  $small.Save((Join-Path $hand "$id.png"),[System.Drawing.Imaging.ImageFormat]::Png)
  if(-not $isVariant) {
    foreach($relative in @("art/cards/tavern-v01/$id.png","godot/assets/cards/$id.png","godot/assets/cards/hand/$id.png")) {
      $destination = Join-Path $ProjectRoot $relative
      $backupPath = Join-Path $before $relative
      if((Test-Path -LiteralPath $destination) -and -not (Test-Path -LiteralPath $backupPath)) {
        New-Item -ItemType Directory -Force -Path (Split-Path $backupPath -Parent) | Out-Null
        Copy-Item -LiteralPath $destination -Destination $backupPath
      }
      if($relative -like '*/hand/*') { Copy-Item -LiteralPath (Join-Path $hand "$id.png") -Destination $destination -Force }
      else { Copy-Item -LiteralPath $master -Destination $destination -Force }
    }
  }
  if($image.Width -ne 1024 -or $image.Height -ne 1536 -or $small.Width -ne 256 -or $small.Height -ne 384) { throw "Bad dimensions: $id" }
  if($image.GetPixel(0,0).A -ne $mask.GetPixel(0,0).A -or $image.GetPixel(512,768).A -ne 255) { throw "Bad alpha: $id" }
  $records += [ordered]@{id=$id;variant=$isVariant;width=$image.Width;height=$image.Height;format='RGBA';sha256=(Get-FileHash -LiteralPath $master -Algorithm SHA256).Hash;source=$sourcePath}
  $image.Dispose(); $small.Dispose()
  Write-Output "PACKAGED $id"
}
$mask.Dispose()
$records | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'manifest.json') -Encoding utf8
$grid = [System.Drawing.Bitmap]::new(1280,960)
$g = [System.Drawing.Graphics]::FromImage($grid)
$g.Clear([System.Drawing.Color]::FromArgb(39,31,50))
for($i=0;$i -lt $manifest.cards.Count;$i++) {
  $cardImage = [System.Drawing.Bitmap]::new((Join-Path $PSScriptRoot ($manifest.cards[$i].id+'.png')))
  $g.DrawImage($cardImage,[System.Drawing.Rectangle]::new(($i%4)*320,[math]::Floor($i/4)*480,320,480))
  $cardImage.Dispose()
}
$g.Dispose(); $grid.Save((Join-Path $PSScriptRoot 'review-sheet.png'),[System.Drawing.Imaging.ImageFormat]::Png); $grid.Dispose()
Write-Output 'PASS 8 masters + 8 hand cards; six runtime replacements; two art alternatives'
