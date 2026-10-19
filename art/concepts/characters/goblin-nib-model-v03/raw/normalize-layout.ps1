Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
public static class NibLayout {
 public static object Normalize(string input,string reference,string output) {
  using(var src=new Bitmap(input)) using(var b=new Bitmap(reference)) {
   int[] s=Bounds(src),t=Bounds(b);
   double scale=(double)(t[3]-t[1]+1)/(s[3]-s[1]+1);
   float cx=(t[0]+t[2])/2f, scx=(s[0]+s[2])/2f;
   float dx=cx-(float)scale*scx,dy=t[1]-(float)scale*s[1];
   using(var dst=new Bitmap(1536,1536,PixelFormat.Format32bppArgb)) using(var g=Graphics.FromImage(dst)) {
    g.Clear(Color.Transparent);g.CompositingMode=CompositingMode.SourceCopy;
    g.CompositingQuality=CompositingQuality.HighQuality;g.InterpolationMode=InterpolationMode.HighQualityBicubic;
    g.PixelOffsetMode=PixelOffsetMode.HighQuality;
    g.DrawImage(src,new RectangleF(dx,dy,(float)(src.Width*scale),(float)(src.Height*scale)),new RectangleF(0,0,src.Width,src.Height),GraphicsUnit.Pixel);
    dst.Save(output,ImageFormat.Png);
   }
   return new {SourceWidth=src.Width,SourceHeight=src.Height,SourceBounds=s,ReferenceBounds=t,UniformScale=scale,TranslateX=dx,TranslateY=dy,Width=1536,Height=1536,Method="Uniform high-quality bicubic layout alignment, alpha>=192 bounds; no nonuniform warp"};
  }
 }
 static int[] Bounds(Bitmap im) {
  int l=im.Width,t=im.Height,r=-1,b=-1;
  for(int y=0;y<im.Height;y++) for(int x=0;x<im.Width;x++) if(im.GetPixel(x,y).A>=192) {l=Math.Min(l,x);t=Math.Min(t,y);r=Math.Max(r,x);b=Math.Max(b,y);}
  if(r<0) throw new Exception("No foreground"); return new int[]{l,t,r,b};
 }
}
'@
$folder = Split-Path -Parent $PSScriptRoot
$base = Join-Path (Split-Path -Parent $folder) 'goblin-nib-model-v02/nib-3q-b-v02.png'
[ NibLayout ]::Normalize((Join-Path $PSScriptRoot 'nib-3q-v03.png'),$base,(Join-Path $PSScriptRoot 'layout-normalized.png')) | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'layout-report.json') -Encoding UTF8
Get-Content -LiteralPath (Join-Path $PSScriptRoot 'layout-report.json') -Encoding UTF8

