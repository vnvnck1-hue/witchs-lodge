param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public class FairyAlphaAudit {
 public static string Inspect(string path) {
  using (Bitmap b = new Bitmap(path)) {
   var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
   byte[] p=new byte[Math.Abs(d.Stride)*b.Height]; Marshal.Copy(d.Scan0,p,0,p.Length); b.UnlockBits(d);
   long zero=0,full=0,partial=0; int x0=b.Width,y0=b.Height,x1=-1,y1=-1; int border=0;
   for(int y=0;y<b.Height;y++) for(int x=0;x<b.Width;x++) {
    int a=p[y*d.Stride+x*4+3]; if(a==0)zero++;else if(a==255)full++;else partial++;
    if(a>0&&(x==0||y==0||x==b.Width-1||y==b.Height-1))border++;
    if(a>=128){x0=Math.Min(x0,x);y0=Math.Min(y0,y);x1=Math.Max(x1,x);y1=Math.Max(y1,y);}
   }
   return String.Format("{{\"width\":{0},\"height\":{1},\"transparent_pixels\":{2},\"opaque_pixels\":{3},\"partial_alpha_pixels\":{4},\"nonzero_border_pixels\":{5},\"alpha128_bbox_xyxy_exclusive\":[{6},{7},{8},{9}]}}",b.Width,b.Height,zero,full,partial,border,x0,y0,x1+1,y1+1);
  }
 }
}
'@
[FairyAlphaAudit]::Inspect((Resolve-Path -LiteralPath $Path).Path)
