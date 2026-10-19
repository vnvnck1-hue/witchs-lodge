$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Collections.Generic;
public static class CardImages {
  public static Bitmap Read(string path) {
    using (var source = new Bitmap(path)) {
      return source.Clone(new Rectangle(0,0,source.Width,source.Height),PixelFormat.Format32bppArgb);
    }
  }
  public static Bitmap Resize(Bitmap source,int width,int height) {
    var result=new Bitmap(width,height,PixelFormat.Format32bppArgb);
    using(var g=Graphics.FromImage(result)) using(var attr=new ImageAttributes()) {
      g.CompositingMode=CompositingMode.SourceCopy;
      g.CompositingQuality=CompositingQuality.HighQuality;
      g.InterpolationMode=InterpolationMode.HighQualityBicubic;
      g.PixelOffsetMode=PixelOffsetMode.HighQuality;
      attr.SetWrapMode(WrapMode.TileFlipXY);
      g.DrawImage(source,new Rectangle(0,0,width,height),0,0,source.Width,source.Height,GraphicsUnit.Pixel,attr);
    }
    return result;
  }
  public static void AlphaFrom(Bitmap target,Bitmap reference) {
    if(target.Size!=reference.Size) throw new Exception("Alpha dimensions mismatch");
    for(int y=0;y<target.Height;y++) for(int x=0;x<target.Width;x++) {
      var c=target.GetPixel(x,y); var a=reference.GetPixel(x,y).A;
      target.SetPixel(x,y,Color.FromArgb(a,c.R,c.G,c.B));
    }
  }
  public static string[] TextRows(Bitmap b) {
    var lines=new List<string>(); int start=-1,last=-1;
    for(int y=1185;y<1445;y++) {
      int count=0;
      for(int x=110;x<914;x++) { var c=b.GetPixel(x,y); if(c.R<85&&c.G<85&&c.B<85) count++; }
      if(count>=3) {if(start<0)start=y;last=y;}
      else if(start>=0&&y-last>3) {lines.Add(start+":"+last);start=-1;}
    }
    if(start>=0)lines.Add(start+":"+last);
    return lines.ToArray();
  }
  public static void Patch(Bitmap target,Bitmap edited,int left,int top,int right,int bottom,int feather) {
    for(int y=top;y<bottom;y++) for(int x=left;x<right;x++) {
      int d=Math.Min(Math.Min(x-left,right-1-x),Math.Min(y-top,bottom-1-y));
      double t=Math.Min(1.0,(double)d/feather);t=t*t*(3-2*t);
      var a=target.GetPixel(x,y);var b=edited.GetPixel(x,y);
      target.SetPixel(x,y,Color.FromArgb(a.A,(int)Math.Round(a.R+(b.R-a.R)*t),(int)Math.Round(a.G+(b.G-a.G)*t),(int)Math.Round(a.B+(b.B-a.B)*t)));
    }
  }
  public static long[] Diff(Bitmap a,Bitmap b,int left,int top,int right,int bottom) {
    long total=0,outside=0;int minx=a.Width,miny=a.Height,maxx=-1,maxy=-1;
    for(int y=0;y<a.Height;y++)for(int x=0;x<a.Width;x++) {
      if(a.GetPixel(x,y).ToArgb()!=b.GetPixel(x,y).ToArgb()) {
        total++;if(x<left||x>=right||y<top||y>=bottom)outside++;
        minx=Math.Min(minx,x);maxx=Math.Max(maxx,x);miny=Math.Min(miny,y);maxy=Math.Max(maxy,y);
      }
    }
    return new long[]{total,outside,minx,miny,maxx,maxy};
  }
}
'@
function Save-Png($image,[string]$path) {
  $absolute=[System.IO.Path]::GetFullPath((Join-Path $taskRoot $path))
  [System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($absolute)) | Out-Null
  $image.Save($absolute,[System.Drawing.Imaging.ImageFormat]::Png)
}
