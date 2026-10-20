$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class BramPng {
  static byte[] Read(Bitmap b) {
    var data=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
    var bytes=new byte[b.Width*b.Height*4];
    for(int y=0;y<b.Height;y++) Marshal.Copy(IntPtr.Add(data.Scan0,y*data.Stride),bytes,y*b.Width*4,b.Width*4);
    b.UnlockBits(data); return bytes;
  }
  public static void Pad(string source,string target) {
    using(var src=new Bitmap(source)) using(var dst=new Bitmap(1536,1536,PixelFormat.Format32bppArgb)) {
      if(src.Width>1536 || src.Height>1536) throw new Exception("Unexpected source dimensions; no implicit resampling allowed.");
      var a=Read(src); var p=new byte[1536*1536*4];
      // Transparent-cutout finishing requested by the common brief. Preserve
      // source RGB in the body; decontaminate only the narrow antialias rim.
      // Retain largest 8-connected silhouette at alpha >= 16; discard faint
      // isolated matte debris. Make everything beyond a 2px rim opaque.
      int w=src.Width,h=src.Height,n=w*h;var labels=new int[n];var queue=new int[n];
      int label=0,bestLabel=0,bestCount=0;
      for(int start=0;start<n;start++) {
        if(labels[start]!=0 || a[start*4+3]<16)continue;
        label++;int head=0,tail=1;queue[0]=start;labels[start]=label;
        while(head<tail){int pos=queue[head++],x=pos%w,y=pos/w;
          for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){
            int xx=x+dx,yy=y+dy;if(xx<0||xx>=w||yy<0||yy>=h)continue;
            int q=yy*w+xx;if(labels[q]==0&&a[q*4+3]>=16){labels[q]=label;queue[tail++]=q;}
          }
        }
        if(tail>bestCount){bestCount=tail;bestLabel=label;}
      }
      var originalAlpha=new byte[n];for(int i=0;i<n;i++) originalAlpha[i]=a[i*4+3];
      var core=new bool[n];
      for(int i=0;i<n;i++){
        if(labels[i]!=bestLabel)continue;int x=i%w,y=i/w;bool valid=true;
        for(int dy=-2;dy<=2&&valid;dy++)for(int dx=-2;dx<=2;dx++){
          int xx=x+dx,yy=y+dy;if(xx<0||xx>=w||yy<0||yy>=h||labels[yy*w+xx]!=bestLabel){valid=false;break;}
        }
        core[i]=valid;
      }
      for(int i=0;i<n;i++){
        if(labels[i]!=bestLabel){a[i*4+3]=0;continue;}
        int x=i%w,y=i/w;bool rim=false;
        for(int dy=-2;dy<=2&&!rim;dy++)for(int dx=-2;dx<=2;dx++){
          int xx=x+dx,yy=y+dy;if(xx<0||xx>=w||yy<0||yy>=h||labels[yy*w+xx]!=bestLabel){rim=true;break;}
        }
        if(rim){
          int best=-1,bestDistance=1000;
          for(int dy=-6;dy<=6;dy++)for(int dx=-6;dx<=6;dx++){
            int xx=x+dx,yy=y+dy,dd=dx*dx+dy*dy;
            if(xx<0||xx>=w||yy<0||yy>=h||dd>=bestDistance)continue;
            int q=yy*w+xx;if(core[q]){best=q;bestDistance=dd;}
          }
          if(best>=0){for(int c=0;c<3;c++)a[i*4+c]=a[best*4+c];}
        }
        a[i*4+3]=rim?(byte)Math.Min(255,(originalAlpha[i]*255+126)/253):(byte)255;
      }
      int ox=(1536-src.Width)/2,oy=(1536-src.Height)/2;
      for(int y=0;y<src.Height;y++) Buffer.BlockCopy(a,y*src.Width*4,p,((y+oy)*1536+ox)*4,src.Width*4);
      var d=dst.LockBits(new Rectangle(0,0,1536,1536),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);
      for(int y=0;y<1536;y++) Marshal.Copy(p,y*1536*4,IntPtr.Add(d.Scan0,y*d.Stride),1536*4);
      dst.UnlockBits(d); dst.Save(target,ImageFormat.Png);
    }
  }
  public static Dictionary<string,object> Inspect(string path) {
    using(var b=new Bitmap(path)) {
      int w=b.Width,h=b.Height,n=w*h;var p=Read(b);var dist=new int[n];var hist=new long[256];
      int x0=w,y0=h,x1=-1,y1=-1;
      for(int i=0;i<n;i++) { int a=p[i*4+3];hist[a]++;dist[i]=a==0?0:100000;
        if(a>0){int x=i%w,y=i/w;x0=Math.Min(x0,x);x1=Math.Max(x1,x);y0=Math.Min(y0,y);y1=Math.Max(y1,y);}
      }
      for(int y=0;y<h;y++)for(int x=0;x<w;x++){int i=y*w+x,v=dist[i];if(x>0)v=Math.Min(v,dist[i-1]+1);if(y>0){v=Math.Min(v,dist[i-w]+1);if(x>0)v=Math.Min(v,dist[i-w-1]+1);if(x<w-1)v=Math.Min(v,dist[i-w+1]+1);}dist[i]=v;}
      for(int y=h-1;y>=0;y--)for(int x=w-1;x>=0;x--){int i=y*w+x,v=dist[i];if(x<w-1)v=Math.Min(v,dist[i+1]+1);if(y<h-1){v=Math.Min(v,dist[i+w]+1);if(x>0)v=Math.Min(v,dist[i+w-1]+1);if(x<w-1)v=Math.Min(v,dist[i+w+1]+1);}dist[i]=v;}
      long partial=0,deep=0;int maxDepth=0;for(int i=0;i<n;i++)if(p[i*4+3]>0&&p[i*4+3]<255){partial++;maxDepth=Math.Max(maxDepth,dist[i]);if(dist[i]>2)deep++;}
      return new Dictionary<string,object>{{"width",w},{"height",h},{"alpha0",hist[0]},{"alpha255",hist[255]},{"partialAlpha",partial},{"partialBeyond2px",deep},{"maxPartialDepth",maxDepth},{"bboxAlphaPositive",new int[]{x0,y0,x1,y1}},{"margins",new int[]{x0,y0,w-1-x1,h-1-y1}},{"alphaHistogram",hist}};
    }
  }
}
'@
$outputFolder = Split-Path -Parent $PSScriptRoot
$report = [ordered]@{}
foreach ($variant in @('a','b')) {
  $rawPath = Join-Path $PSScriptRoot "bram-3q-$variant-generated.png"
  $finalPath = Join-Path $outputFolder "bram-3q-$variant-v01.png"
  [BramPng]::Pad($rawPath,$finalPath)
  $report["raw-$variant"] = [BramPng]::Inspect($rawPath)
  $report["final-$variant"] = [BramPng]::Inspect($finalPath)
}
$report | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'alpha-report.json')
$report.GetEnumerator() | ForEach-Object { [PSCustomObject]@{File=$_.Key;Width=$_.Value.width;Height=$_.Value.height;Transparent=$_.Value.alpha0;Opaque=$_.Value.alpha255;Partial=$_.Value.partialAlpha;PartialBeyond2px=$_.Value.partialBeyond2px;MaxPartialDepth=$_.Value.maxPartialDepth;Margins=($_.Value.margins -join ',')} } | Format-Table -AutoSize
