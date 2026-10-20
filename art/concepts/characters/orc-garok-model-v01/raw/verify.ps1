Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class GarokImageAudit {
  public static string Inspect(string path) {
    using(var im = new Bitmap(path)) {
      var rect = new Rectangle(0,0,im.Width,im.Height);
      var data=im.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
      var p=new byte[data.Stride*im.Height]; Marshal.Copy(data.Scan0,p,0,p.Length); im.UnlockBits(data);
      int w=im.Width,h=im.Height,n=w*h, minX=w,minY=h,maxX=-1,maxY=-1;
      long zero=0,solid=0,partial=0; var hist=new long[256];
      var d=new int[n]; var q=new Queue<int>();
      for(int y=0;y<h;y++)for(int x=0;x<w;x++){
        int i=y*w+x,a=p[y*data.Stride+x*4+3]; hist[a]++;
        if(a==0){zero++;d[i]=0;q.Enqueue(i);}else{
          d[i]=int.MaxValue;
          if(a==255)solid++;else partial++;
          minX=Math.Min(minX,x);minY=Math.Min(minY,y);maxX=Math.Max(maxX,x);maxY=Math.Max(maxY,y);
        }
      }
      while(q.Count>0){int i=q.Dequeue(),x=i%w,y=i/w;
        for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){int xx=x+dx,yy=y+dy;if(xx<0||xx>=w||yy<0||yy>=h)continue;int j=yy*w+xx;if(d[j]>d[i]+1){d[j]=d[i]+1;q.Enqueue(j);}}
      }
      int maxPartialDepth=0;long deepPartial=0;
      for(int y=0;y<h;y++)for(int x=0;x<w;x++){int a=p[y*data.Stride+x*4+3];if(a>0 && a<255){int depth=d[y*w+x];maxPartialDepth=Math.Max(maxPartialDepth,depth);if(depth>2)deepPartial++;}}
      if(w==1536 && h==1536){
        if(deepPartial!=0 || solid==0 || zero==0)throw new Exception("Final alpha validation failed");
        for(int x=0;x<w;x++)if(p[x*4+3]!=0||p[(h-1)*data.Stride+x*4+3]!=0)throw new Exception("Top/bottom edge is not transparent");
        for(int y=0;y<h;y++)if(p[y*data.Stride+3]!=0||p[y*data.Stride+(w-1)*4+3]!=0)throw new Exception("Left/right edge is not transparent");
      }
      return string.Format("size={0}x{1}; alpha0={2}; alpha255={3}; alpha1to254={4}; bbox=({5},{6})-({7},{8}); maxPartialDepth8={9}; partialDeeperThan2={10}; alpha254={11}; alpha1={12}",w,h,zero,solid,partial,minX,minY,maxX,maxY,maxPartialDepth,deepPartial,hist[254],hist[1]);
    }
  }
  public static void Pad(string source,string target) {
    using(var im=new Bitmap(source))using(var dst=new Bitmap(1536,1536,PixelFormat.Format32bppArgb)){
      if(im.Width>1536 || im.Height>1536)throw new Exception("Source exceeds canvas");
      int w=im.Width,h=im.Height,n=w*h;
      var id=im.LockBits(new Rectangle(0,0,w,h),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
      int sourceStride=id.Stride;var p=new byte[sourceStride*h];Marshal.Copy(id.Scan0,p,0,p.Length);im.UnlockBits(id);
      var visited=new bool[n];var largest=new List<int>();int componentCount=0;
      for(int start=0;start<n;start++){
        if(visited[start]||p[(start/w)*sourceStride+(start%w)*4+3]<128)continue;
        componentCount++;var component=new List<int>();var queue=new Queue<int>();visited[start]=true;queue.Enqueue(start);
        while(queue.Count>0){int i=queue.Dequeue(),x=i%w,y=i/w;component.Add(i);
          for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){int xx=x+dx,yy=y+dy;if(xx<0||xx>=w||yy<0||yy>=h)continue;int j=yy*w+xx;if(!visited[j]&&p[yy*sourceStride+xx*4+3]>=128){visited[j]=true;queue.Enqueue(j);}}
        }
        if(component.Count>largest.Count)largest=component;
      }
      var mask=new bool[n];foreach(int i in largest)mask[i]=true;
      var dd=dst.LockBits(new Rectangle(0,0,1536,1536),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);var output=new byte[dd.Stride*1536];
      int ox=(1536-w)/2,oy=(1536-h)/2;
      for(int y=0;y<h;y++)for(int x=0;x<w;x++){
        int sum=0,nearest=-1,best=100;
        for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){int xx=x+dx,yy=y+dy;if(xx<0||xx>=w||yy<0||yy>=h)continue;if(mask[yy*w+xx]){sum++;int dist=dx*dx+dy*dy;if(dist<best){best=dist;nearest=yy*sourceStride+xx*4;}}}
        if(sum==0)continue;
        int src=mask[y*w+x]?y*sourceStride+x*4:nearest, dest=(y+oy)*dd.Stride+(x+ox)*4;
        output[dest]=p[src];output[dest+1]=p[src+1];output[dest+2]=p[src+2];output[dest+3]=(byte)Math.Round(255.0*sum/9.0);
      }
      // A tiny alpha hole must not leave a translucent patch deep inside the body.
      var distance=new int[1536*1536];var outer=new Queue<int>();
      for(int y=0;y<1536;y++)for(int x=0;x<1536;x++){int i=y*1536+x;if(output[y*dd.Stride+x*4+3]==0){distance[i]=0;outer.Enqueue(i);}else distance[i]=int.MaxValue;}
      while(outer.Count>0){int i=outer.Dequeue(),x=i%1536,y=i/1536;for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){int xx=x+dx,yy=y+dy;if(xx<0||xx>=1536||yy<0||yy>=1536)continue;int j=yy*1536+xx;if(distance[j]>distance[i]+1){distance[j]=distance[i]+1;outer.Enqueue(j);}}}
      int repaired=0;for(int y=0;y<1536;y++)for(int x=0;x<1536;x++){int at=y*dd.Stride+x*4+3;if(output[at]>0&&output[at]<255&&distance[y*1536+x]>2){output[at]=255;repaired++;}}
      Console.WriteLine("Interior partial pixels promoted to 255: "+repaired);
      Marshal.Copy(output,0,dd.Scan0,output.Length);dst.UnlockBits(dd);
      Console.WriteLine("Matte: threshold=128, components="+componentCount+", retainedPixels="+largest.Count+", AA=3x3 binary coverage, padding=("+ox+","+oy+"), no resampling");
      dst.Save(target,ImageFormat.Png);
    }
  }
  public static void Preview(string source,string target){
    using(var im=new Bitmap(source))using(var dst=new Bitmap(im.Width,im.Height,PixelFormat.Format24bppRgb)){
      using(var g=Graphics.FromImage(dst)){g.Clear(Color.FromArgb(155,155,155));g.DrawImageUnscaled(im,0,0);}
      dst.Save(target,ImageFormat.Png);
    }
  }
}
'@
$base = Split-Path $PSScriptRoot -Parent
$report = @()
foreach ($v in @('a','b')) {
  $source = Join-Path $PSScriptRoot "garok-3q-$v-generated-v01.png"
  $target = Join-Path $base "garok-3q-$v-v01.png"
  [GarokImageAudit]::Pad($source,$target)
  [GarokImageAudit]::Preview($target,(Join-Path $PSScriptRoot "qa-$v-gray.png"))
  $report += "RAW $v " + [GarokImageAudit]::Inspect($source)
  $report += "FINAL $v " + [GarokImageAudit]::Inspect($target)
  $report += "SHA256 raw $v " + (Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash
  $report += "SHA256 final $v " + (Get-FileHash -Algorithm SHA256 -LiteralPath $target).Hash
}
$report | Set-Content -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'alpha-audit.txt')
$report
