$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class GrayWolfVerify {
  static byte[] Read(Bitmap b) {
    var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
    var p=new byte[b.Width*b.Height*4];Marshal.Copy(d.Scan0,p,0,p.Length);b.UnlockBits(d);return p;
  }
  public static string Compare(string original,string final) {
    using(var a=new Bitmap(original))using(var b=new Bitmap(final)) {
      if(a.Size!=b.Size)throw new Exception("Canvas sizes differ.");
      var ap=Read(a);var bp=Read(b);long intersection=0,union=0,diff=0;
      for(int i=3;i<ap.Length;i+=4) {
        bool x=ap[i]>=128,y=bp[i]>=128;
        if(x&&y)intersection++;if(x||y)union++;if(x!=y)diff++;
      }
      return String.Format("alpha>=128 silhouette IoU={0:F6}; intersection={1}; union={2}; differing_mask_pixels={3}; canvas={4}x{5}",(double)intersection/union,intersection,union,diff,a.Width,a.Height);
    }
  }
}
'@
$dest = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$original = [IO.Path]::GetFullPath((Join-Path $dest '../werewolf-witch-model-v01/werewolf-3q-b-v01.png'))
$report = [GrayWolfVerify]::Compare($original,(Join-Path $dest 'werewolf-3q-b-v02.png'))
$report | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'silhouette-report.txt') -Encoding UTF8
$report
