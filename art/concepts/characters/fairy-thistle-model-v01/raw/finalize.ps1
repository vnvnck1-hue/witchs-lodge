Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class ThistleFinalize {
  static byte[] Read(Bitmap b) {
    var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
    var p=new byte[b.Width*b.Height*4];
    for(int y=0;y<b.Height;y++) Marshal.Copy(IntPtr.Add(d.Scan0,y*d.Stride),p,y*b.Width*4,b.Width*4);
    b.UnlockBits(d); return p;
  }
  static Bitmap Write(byte[] p,int w,int h) {
    var b=new Bitmap(w,h,PixelFormat.Format32bppArgb);
    var d=b.LockBits(new Rectangle(0,0,w,h),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);
    for(int y=0;y<h;y++) Marshal.Copy(p,y*w*4,IntPtr.Add(d.Scan0,y*d.Stride),w*4);
    b.UnlockBits(d); return b;
  }
  static int Nearby(bool[] core,int w,int h,int x,int y,int radius) {
    for(int r=1;r<=radius;r++) for(int dy=-r;dy<=r;dy++) for(int dx=-r;dx<=r;dx++) {
      if(Math.Max(Math.Abs(dx),Math.Abs(dy))!=r) continue;
      int xx=x+dx,yy=y+dy;
      if(xx>=0&&yy>=0&&xx<w&&yy<h&&core[yy*w+xx]) return yy*w+xx;
    }
    return -1;
  }
  public static string Process(string src,string dst) {
    int w,h; byte[] p;
    using(var b=new Bitmap(src)) { w=b.Width;h=b.Height;p=Read(b); }
    int n=w*h,sourceZero=0,sourceOpaque=0;
    var labels=new int[n];var queue=new int[n];int label=0,biggest=0,bigCount=0,totalCore=0;
    for(int i=0;i<n;i++) { if(p[i*4+3]==0) sourceZero++; if(p[i*4+3]==255) sourceOpaque++; if(p[i*4+3]>=128) totalCore++; }
    for(int i=0;i<n;i++) {
      if(p[i*4+3]<128||labels[i]!=0) continue;
      label++;int start=0,end=1;queue[0]=i;labels[i]=label;
      while(start<end) {
        int at=queue[start++],x=at%w,y=at/w;
        for(int dy=-1;dy<=1;dy++) for(int dx=-1;dx<=1;dx++) {
          int xx=x+dx,yy=y+dy;if(xx<0||yy<0||xx>=w||yy>=h)continue;
          int j=yy*w+xx;if(labels[j]==0&&p[j*4+3]>=128){labels[j]=label;queue[end++]=j;}
        }
      }
      if(end>bigCount){bigCount=end;biggest=label;}
    }
    if(bigCount<n/10) throw new Exception("No sufficiently large connected foreground");
    bool[] core=new bool[n];int minX=w,minY=h,maxX=0,maxY=0;
    for(int i=0;i<n;i++) if(labels[i]==biggest) {core[i]=true;int x=i%w,y=i/w;minX=Math.Min(minX,x);maxX=Math.Max(maxX,x);minY=Math.Min(minY,y);maxY=Math.Max(maxY,y);}
    byte[] clean=new byte[p.Length];
    for(int i=0;i<n;i++) {
      if(core[i]) { Buffer.BlockCopy(p,i*4,clean,i*4,4);clean[i*4+3]=255; }
      else if(p[i*4+3]>0&&p[i*4+3]<128) {
        int near=Nearby(core,w,h,i%w,i/w,2);
        if(near>=0) {Buffer.BlockCopy(p,near*4,clean,i*4,3);clean[i*4+3]=p[i*4+3];}
      }
    }
    int cropX=Math.Max(0,minX-3),cropY=Math.Max(0,minY-3);
    int cropW=Math.Min(w-1,maxX+3)-cropX+1,cropH=Math.Min(h-1,maxY+3)-cropY+1;
    double scale=1216.0/Math.Max(cropW,cropH);
    int dw=(int)Math.Round(cropW*scale),dh=(int)Math.Round(cropH*scale);
    byte[] resized;
    using(var from=Write(clean,w,h)) using(var canvas=new Bitmap(1536,1536,PixelFormat.Format32bppArgb)) {
      using(var g=Graphics.FromImage(canvas)) {
        g.CompositingMode=CompositingMode.SourceCopy;g.InterpolationMode=InterpolationMode.HighQualityBicubic;
        g.PixelOffsetMode=PixelOffsetMode.HighQuality;g.SmoothingMode=SmoothingMode.HighQuality;
        g.Clear(Color.Transparent);
        g.DrawImage(from,new Rectangle((1536-dw)/2,(1536-dh)/2,dw,dh),cropX,cropY,cropW,cropH,GraphicsUnit.Pixel);
      }
      resized=Read(canvas);
    }
    int size=1536*1536;bool[] finalCore=new bool[size];
    for(int i=0;i<size;i++) finalCore[i]=resized[i*4+3]>=128;
    byte[] output=new byte[resized.Length];int zeros=0,opaque=0,partial=0,partialFar=0;
    minX=1536;minY=1536;maxX=0;maxY=0;
    for(int i=0;i<size;i++) {
      if(finalCore[i]) { Buffer.BlockCopy(resized,i*4,output,i*4,4);output[i*4+3]=255;opaque++; }
      else if(resized[i*4+3]>0) {
        int near=Nearby(finalCore,1536,1536,i%1536,i/1536,1);
        if(near>=0) { Buffer.BlockCopy(resized,near*4,output,i*4,3);output[i*4+3]=resized[i*4+3];partial++; }
      }
      if(output[i*4+3]==0)zeros++;
      else {int x=i%1536,y=i/1536;minX=Math.Min(minX,x);maxX=Math.Max(maxX,x);minY=Math.Min(minY,y);maxY=Math.Max(maxY,y);}
      if(output[i*4+3]>0&&output[i*4+3]<255&&Nearby(finalCore,1536,1536,i%1536,i/1536,1)<0)partialFar++;
    }
    using(var b=Write(output,1536,1536)) b.Save(dst,ImageFormat.Png);
    return String.Format("{0}: source={1}x{2}, source alpha0={3}, alpha255={4}, partial={5}; core components={6}, discarded core pixels={7}; crop={8},{9},{10},{11}; scale={12:F8}; final=1536x1536 RGBA, alpha0={13}, alpha255={14}, partial={15}, partial farther than 1px={16}, bbox=[{17},{18},{19},{20}], margins L/T/R/B={17}/{18}/{21}/{22}",Path.GetFileName(dst),w,h,sourceZero,sourceOpaque,n-sourceZero-sourceOpaque,label,totalCore-bigCount,cropX,cropY,cropW,cropH,scale,zeros,opaque,partial,partialFar,minX,minY,maxX,maxY,1535-maxX,1535-maxY);
  }
  public static void Preview(string a,string b,string path) {
    using(var canvas=new Bitmap(1536,768)) using(var g=Graphics.FromImage(canvas)) using(var aa=new Bitmap(a)) using(var bb=new Bitmap(b)) {
      g.Clear(Color.FromArgb(225,225,219));g.InterpolationMode=InterpolationMode.HighQualityBicubic;
      g.DrawImage(aa,new Rectangle(0,0,768,768));g.DrawImage(bb,new Rectangle(768,0,768,768));canvas.Save(path,ImageFormat.Png);
    }
  }
}
'@
$thistleOutput = Split-Path -Parent $PSScriptRoot
$thistleA = Join-Path $thistleOutput 'thistle-3q-a-v01.png'
$thistleB = Join-Path $thistleOutput 'thistle-3q-b-v01.png'
$thistleAudit = @(
  [ThistleFinalize]::Process((Join-Path $PSScriptRoot 'thistle-3q-a-generated-02.png'), $thistleA)
  [ThistleFinalize]::Process((Join-Path $PSScriptRoot 'thistle-3q-b-generated-01.png'), $thistleB)
)
$thistleAudit | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'alpha-audit.txt')
$thistleAudit
[ThistleFinalize]::Preview($thistleA,$thistleB,(Join-Path $PSScriptRoot 'qa-contact-sheet.png'))
Get-FileHash -Algorithm SHA256 $thistleA,$thistleB
