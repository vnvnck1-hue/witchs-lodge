param([string]$ProjectRoot=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing.Common,System.Drawing.Primitives,System.Private.Windows.GdiPlus,System.Private.Windows.Core -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
public static class ErinOriginalComposite {
  static int SourceInset(int y) {
    int[] ys={300,350,400,500,600,700,750,800,850,900,950,1000,1050,1100,1130,1140,1150,1156};
    int[] xs={98,60,47,37,38,40,45,57,77,102,118,117,100,107,145,179,224,300};
    for(int k=1;k<ys.Length;k++) if(y<=ys[k]) return (int)Math.Ceiling(xs[k-1]+(xs[k]-xs[k-1])*(y-ys[k-1])/(double)(ys[k]-ys[k-1]));
    return 512;
  }
  static byte[] Read(Bitmap b) {
    var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
    byte[] a=new byte[d.Stride*d.Height]; Marshal.Copy(d.Scan0,a,0,a.Length);b.UnlockBits(d);return a;
  }
  static void Write(Bitmap b,byte[] a) {
    var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);
    Marshal.Copy(a,0,d.Scan0,a.Length);b.UnlockBits(d);
  }
  static void Patch(byte[] dst,byte[] clean,int x0,int y0,int x1,int y1,int offsetY,int feather) {
    for(int y=y0;y<y1;y++) for(int x=x0;x<x1;x++) {
      int dist=Math.Min(Math.Min(x-x0,x1-1-x),Math.Min(y-y0,y1-1-y));
      double t=Math.Min(1,dist/(double)feather); t=t*t*(3-2*t);
      int i=(y*1024+x)*4, j=((y+offsetY)*1024+x)*4;
      for(int c=0;c<3;c++) dst[i+c]=(byte)Math.Round(dst[i+c]*(1-t)+clean[j+c]*t);
    }
  }
  public static long[] Compose(string originalPath,string framePath,string outputPath,string maskPath) {
    using(var original=new Bitmap(originalPath)) using(var frame=new Bitmap(framePath)) using(var mask=new Bitmap(1024,1536,PixelFormat.Format32bppArgb)) {
      if(original.Width!=1024||original.Height!=1536||frame.Width!=1024||frame.Height!=1536) throw new Exception("Inputs must be same 1024x1536, no scaling allowed");
      byte[] src=Read(original), dst=Read(frame), clean=(byte[])dst.Clone();
      Patch(dst,clean,200,70,830,194,1160,10);
      Patch(dst,clean,370,212,666,267,1110,4);
      using(var g=Graphics.FromImage(mask)) using(var p=new GraphicsPath()) {
        g.Clear(Color.Black);g.SmoothingMode=SmoothingMode.None;
        p.StartFigure();p.AddBezier(174,247,282,273,391,292,512,293);
        p.AddBezier(512,293,640,292,747,272,849,248);
        p.AddBezier(849,248,934,276,977,326,980,397);
        p.AddBezier(980,397,988,470,971,542,949,602);
        p.AddBezier(949,602,932,655,938,710,959,758);
        p.AddBezier(959,758,982,810,988,870,974,931);
        p.AddBezier(974,931,965,972,947,1001,940,1024);
        p.AddBezier(940,1024,933,1050,954,1080,941,1112);
        p.AddBezier(941,1112,922,1155,844,1161,758,1160);
        p.AddBezier(758,1160,650,1162,588,1171,512,1175);
        p.AddBezier(512,1175,430,1173,361,1161,265,1160);
        p.AddBezier(265,1160,176,1163,99,1156,79,1120);
        p.AddBezier(79,1120,63,1096,80,1073,76,1050);
        p.AddBezier(76,1050,63,1024,47,1002,40,963);
        p.AddBezier(40,963,25,902,37,839,57,786);
        p.AddBezier(57,786,82,727,88,682,67,628);
        p.AddBezier(67,628,41,562,27,495,33,418);
        p.AddBezier(33,418,35,332,76,282,174,247);p.CloseFigure();
        g.FillPath(Brushes.White,p);
        g.FillEllipse(Brushes.Black,400,1003,224,186);
        g.FillEllipse(Brushes.Black,344,1084,336,160);
        g.FillPolygon(Brushes.Black,new Point[]{new Point(512,978),new Point(529,1024),new Point(512,1050),new Point(495,1024)});
        g.FillPolygon(Brushes.Black,new Point[]{new Point(378,1092),new Point(418,1074),new Point(444,1092),new Point(418,1113)});
        g.FillPolygon(Brushes.Black,new Point[]{new Point(588,1092),new Point(616,1074),new Point(652,1092),new Point(616,1113)});
      }
      byte[] m=Read(mask);long copied=0,mismatch=0,faceMismatch=0;
      for(int y=0;y<1536;y++) for(int x=0;x<1024;x++) {
        int i=(y*1024+x)*4;
        int inset=SourceInset(y);
        if(y<300||y>1155||x<inset||x>=1024-inset) { m[i]=m[i+1]=m[i+2]=0; }
        if(m[i]>127) { for(int c=0;c<3;c++) dst[i+c]=src[i+c];dst[i+3]=255;copied++; }
      }
      Write(mask,m);
      using(var corners=new Bitmap(1024,1536,PixelFormat.Format32bppArgb)) {
        using(var g=Graphics.FromImage(corners)) using(var p=new GraphicsPath()) {
          g.Clear(Color.Black);g.SmoothingMode=SmoothingMode.AntiAlias;
          p.AddArc(0,0,88,88,180,90);p.AddArc(935,0,88,88,270,90);
          p.AddArc(935,1447,88,88,0,90);p.AddArc(0,1447,88,88,90,90);p.CloseFigure();
          g.FillPath(Brushes.White,p);
        }
        byte[] edge=Read(corners);
        for(int i=0;i<dst.Length;i+=4) dst[i+3]=Math.Min(dst[i+3],edge[i]);
      }
      Write(frame,dst);frame.Save(outputPath,ImageFormat.Png);mask.Save(maskPath,ImageFormat.Png);
      using(var check=new Bitmap(outputPath)) {
        byte[] verified=Read(check);
        for(int y=0;y<1536;y++) for(int x=0;x<1024;x++) {
          int i=(y*1024+x)*4;
          bool unequal=verified[i]!=src[i]||verified[i+1]!=src[i+1]||verified[i+2]!=src[i+2];
          if(m[i]>127&&unequal)mismatch++;
          if(x>=430&&x<740&&y>=370&&y<630&&unequal)faceMismatch++;
        }
      }
      return new long[]{copied,mismatch,faceMismatch};
    }
  }
}
'@
New-Item -ItemType Directory -Force -Path (Join-Path $PSScriptRoot 'sources') | Out-Null
$original=Join-Path $ProjectRoot 'art/cards/tavern-v01/drafts/drunken_erin_v02.png'
$frame=Join-Path $ProjectRoot 'art/cards/tavern-v05/drunken_erin.png'
Copy-Item -LiteralPath $original -Destination (Join-Path $PSScriptRoot 'sources/original-blonde-erin.png') -Force
Copy-Item -LiteralPath $frame -Destination (Join-Path $PSScriptRoot 'sources/legendary-frame-before.png') -Force
$result=[ErinOriginalComposite]::Compose($original,$frame,(Join-Path $PSScriptRoot 'drunken_erin.png'),(Join-Path $PSScriptRoot 'original-art-mask.png'))
[ordered]@{method='deterministic original-pixel copy; no image generation';original=$original;originalSha256=(Get-FileHash -LiteralPath $original -Algorithm SHA256).Hash;copiedPixels=$result[0];artPixelMismatch=$result[1];facePixelMismatch=$result[2];sourceScale=1;sourceTranslation=@(0,0);topText='removed';bottomText='removed'} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'pixel-verification.json') -Encoding utf8
if($result[1] -ne 0 -or $result[2] -ne 0) { throw 'Original pixel preservation failed' }
Write-Output "PASS copied $($result[0]) original pixels, zero artwork/face mismatch"
