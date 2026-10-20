$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class HaraldFinalizer {
 public static string Process(string src,string dest) {
  using(var original=new Bitmap(src))
  using(var im=new Bitmap(1536,1536,PixelFormat.Format32bppArgb)) {
   im.SetResolution(96,96);
   using(var g=Graphics.FromImage(im)) {
    g.CompositingMode=CompositingMode.SourceCopy;
    g.InterpolationMode=InterpolationMode.HighQualityBicubic;
    g.PixelOffsetMode=PixelOffsetMode.HighQuality;
    using(var attributes=new ImageAttributes()) {
     attributes.SetWrapMode(WrapMode.TileFlipXY);
     g.DrawImage(original,new Rectangle(0,0,1536,1536),0,0,original.Width,original.Height,GraphicsUnit.Pixel,attributes);
    }
   }
   int w=im.Width,h=im.Height,n=w*h;
   var rect=new Rectangle(0,0,w,h);
   var d=im.LockBits(rect,ImageLockMode.ReadWrite,PixelFormat.Format32bppArgb);
   byte[] b=new byte[d.Stride*h];
   Marshal.Copy(d.Scan0,b,0,b.Length);
   bool[] mask=new bool[n],seen=new bool[n],largest=new bool[n];
   for(int p=0;p<n;p++) mask[p]=b[(p/w)*d.Stride+(p%w)*4+3]>=128;
   var queue=new Queue<int>(); var component=new List<int>(); int largestCount=0;
   for(int p=0;p<n;p++) {
    if(!mask[p]||seen[p])continue;
    component.Clear(); queue.Enqueue(p); seen[p]=true;
    while(queue.Count>0) {
     int q=queue.Dequeue();component.Add(q);int x=q%w,y=q/w;
     for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){
      int xx=x+dx,yy=y+dy;
      if(xx<0||yy<0||xx>=w||yy>=h)continue;
      int k=yy*w+xx;if(mask[k]&&!seen[k]){seen[k]=true;queue.Enqueue(k);}
     }
    }
    if(component.Count>largestCount) {
     Array.Clear(largest,0,n); foreach(int k in component)largest[k]=true;largestCount=component.Count;
    }
   }
   long zero=0,opaque=0,semi=0,interiorNonOpaque=0;int minX=w,minY=h,maxX=-1,maxY=-1;
   for(int y=0;y<h;y++)for(int x=0;x<w;x++) {
    int p=y*w+x,idx=y*d.Stride+x*4;bool inside=largest[p],nearOpposite=false;
    for(int dy=-1;dy<=1&&!nearOpposite;dy++)for(int dx=-1;dx<=1;dx++){
     int xx=x+dx,yy=y+dy;
     if(xx>=0&&yy>=0&&xx<w&&yy<h&&largest[yy*w+xx]!=inside){nearOpposite=true;break;}
    }
    byte a;
    if(inside) a=nearOpposite?(byte)Math.Max(128,(int)b[idx+3]):(byte)255;
    else a=nearOpposite?(byte)Math.Min(127,(int)b[idx+3]):(byte)0;
    b[idx+3]=a;
    if(a==0){zero++;b[idx]=b[idx+1]=b[idx+2]=0;}
    else { if(a==255)opaque++;else semi++;minX=Math.Min(minX,x);minY=Math.Min(minY,y);maxX=Math.Max(maxX,x);maxY=Math.Max(maxY,y); }
    if(inside&&!nearOpposite&&a!=255)interiorNonOpaque++;
   }
   Marshal.Copy(b,0,d.Scan0,b.Length);im.UnlockBits(d);im.Save(dest,ImageFormat.Png);
   return "{\"width\":1536,\"height\":1536,\"alpha0\":"+zero+",\"alpha255\":"+opaque+",\"alpha1to254\":"+semi+",\"interiorNonOpaque\":"+interiorNonOpaque+",\"foregroundComponents\":1,\"alphaEdgeRadiusPx\":1,\"bbox\":["+minX+","+minY+","+maxX+","+maxY+"],\"margins\":["+minX+","+minY+","+(w-1-maxX)+","+(h-1-maxY)+"]}";
  }
 }
}
'@ -ReferencedAssemblies System.Drawing
$folder = Split-Path $PSScriptRoot -Parent
$records = @()
foreach ($v in @('a','b')) {
 $src = Join-Path $PSScriptRoot "harald-3q-$v-generated-v01.png"
 $dst = Join-Path $folder "harald-3q-$v-v01.png"
 $record = [HaraldFinalizer]::Process($src,$dst) | ConvertFrom-Json
 $record | Add-Member NoteProperty file (Split-Path $dst -Leaf)
 $record | Add-Member NoteProperty bytes ((Get-Item -LiteralPath $dst).Length)
 $record | Add-Member NoteProperty sha256 ((Get-FileHash -LiteralPath $dst -Algorithm SHA256).Hash.ToLowerInvariant())
 $record | Add-Member NoteProperty rawSha256 ((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToLowerInvariant())
 $records += $record
}
$records | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'validation.json') -Encoding UTF8
$records | ConvertTo-Json -Depth 5

