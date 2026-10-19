Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class NibAlpha {
  public static object Clean(string input, string output, string preview) {
    using (var source = new Bitmap(input)) {
      int w=source.Width,h=source.Height,n=w*h;
      byte[] rgb=new byte[n*4];
      var data=source.LockBits(new Rectangle(0,0,w,h),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
      for(int y=0;y<h;y++) Marshal.Copy(IntPtr.Add(data.Scan0,y*data.Stride),rgb,y*w*4,w*4);
      source.UnlockBits(data);
      var mask=new bool[n]; long[] rawHist=new long[256];
      for(int i=0;i<n;i++) {
        int b=rgb[4*i],g=rgb[4*i+1],r=rgb[4*i+2],a=rgb[4*i+3]; rawHist[a]++;
        // Never key by hue: the orange-red scarf shares edge-spill colors.
        mask[i]=a>=192;
      }
      // One-pixel morphological opening removes thin edge spikes.
      var eroded=new bool[n]; var opened=new bool[n];
      for(int y=1;y<h-1;y++) for(int x=1;x<w-1;x++) {
        int i=y*w+x; bool yes=true;
        for(int dy=-1;dy<=1;dy++) for(int dx=-1;dx<=1;dx++) yes &= mask[i+dy*w+dx];
        eroded[i]=yes;
      }
      for(int y=1;y<h-1;y++) for(int x=1;x<w-1;x++) if(eroded[y*w+x])
        for(int dy=-1;dy<=1;dy++) for(int dx=-1;dx<=1;dx++) opened[(y+dy)*w+x+dx]=true;
      // Retain only the connected character, removing detached speckles.
      var seen=new bool[n]; var queue=new int[n]; var best=new List<int>(); int components=0;
      for(int seed=0;seed<n;seed++) if(opened[seed]&&!seen[seed]) {
        components++; int head=0,tail=1;queue[0]=seed;seen[seed]=true;
        while(head<tail) {int i=queue[head++],x=i%w,y=i/w;
          for(int dy=-1;dy<=1;dy++) for(int dx=-1;dx<=1;dx++) {
            int xx=x+dx,yy=y+dy;if(xx<0||xx>=w||yy<0||yy>=h)continue;
            int j=yy*w+xx;if(opened[j]&&!seen[j]){seen[j]=true;queue[tail++]=j;}
          }
        }
        if(tail>best.Count){best.Clear(); for(int k=0;k<tail;k++)best.Add(queue[k]);}
      }
      mask=new bool[n];foreach(int i in best)mask[i]=true;
      // Fill only isolated pinholes <=16 pixels; preserve genuine negative spaces.
      seen=new bool[n];
      for(int seed=0;seed<n;seed++) if(!mask[seed]&&!seen[seed]) {
        int head=0,tail=1;queue[0]=seed;seen[seed]=true;bool border=false;
        while(head<tail){int i=queue[head++],x=i%w,y=i/w;
          if(x==0||y==0||x==w-1||y==h-1)border=true;
          int[] ns={i-w,i+w,i-1,i+1};
          foreach(int j in ns)if(j>=0&&j<n&&Math.Abs(j%w-x)+Math.Abs(j/w-y)==1&&!mask[j]&&!seen[j]){seen[j]=true;queue[tail++]=j;}
        }
        if(!border&&tail<=16)for(int k=0;k<tail;k++)mask[queue[k]]=true;
      }
      int[] weights={1,6,1}; byte[] result=new byte[n*4]; long[] hist=new long[256];
      int minX=w,minY=h,maxX=0,maxY=0,edge=0,edgeMaxDistance=0;
      long core=0,coreOpaque=0,outside=0,outsideZero=0;
      for(int y=0;y<h;y++)for(int x=0;x<w;x++) {
        int i=y*w+x,sum=0;bool near=false,all=true;
        for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){
          int xx=x+dx,yy=y+dy;bool v=xx>=0&&xx<w&&yy>=0&&yy<h&&mask[yy*w+xx];
          near|=v;all&=v;if(v)sum+=weights[dx+1]*weights[dy+1];
        }
        int a=(sum*255+32)/64;if(a<8)a=0;else if(a>247)a=255;
        hist[a]++;if(all){core++;if(a==255)coreOpaque++;}if(!near){outside++;if(a==0)outsideZero++;}
        if(a>0){minX=Math.Min(minX,x);maxX=Math.Max(maxX,x);minY=Math.Min(minY,y);maxY=Math.Max(maxY,y);}
        if(a>0&&a<255){edge++;edgeMaxDistance=1;}
        if(a>0){
          // Pull edge RGB from an interior foreground pixel to remove color spill.
          int sample=i;
          if(a<255){bool found=false;
            for(int rad=1;rad<=4&&!found;rad++)for(int dy=-rad;dy<=rad&&!found;dy++)for(int dx=-rad;dx<=rad;dx++){
              int xx=x+dx,yy=y+dy;if(xx<1||xx>=w-1||yy<1||yy>=h-1)continue;int j=yy*w+xx;
              if(mask[j]&&mask[j-1]&&mask[j+1]&&mask[j-w]&&mask[j+w]){sample=j;found=true;break;}
            }
          }
          result[4*i]=rgb[4*sample];result[4*i+1]=rgb[4*sample+1];result[4*i+2]=rgb[4*sample+2];result[4*i+3]=(byte)a;
        }
      }
      // Add transparent margin without resizing the generated character.
      int canvasW=Math.Max(1536,w),canvasH=Math.Max(1536,h),ox=(canvasW-w)/2,oy=(canvasH-h)/2;
      long canvasN=(long)canvasW*canvasH,padding=canvasN-n;
      hist[0]+=padding;outside+=padding;outsideZero+=padding;
      using(var final=new Bitmap(canvasW,canvasH,PixelFormat.Format32bppArgb)){
        var fd=final.LockBits(new Rectangle(ox,oy,w,h),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);
        for(int y=0;y<h;y++)Marshal.Copy(result,y*w*4,IntPtr.Add(fd.Scan0,y*fd.Stride),w*4);
        final.UnlockBits(fd);final.Save(output,ImageFormat.Png);
        using(var proof=new Bitmap(canvasW*2,canvasH))using(var g=Graphics.FromImage(proof)){
          g.Clear(Color.White);g.FillRectangle(Brushes.DimGray,canvasW,0,canvasW,canvasH);g.DrawImageUnscaled(final,0,0);g.DrawImageUnscaled(final,canvasW,0);proof.Save(preview,ImageFormat.Png);
        }
      }
      return new { Width=canvasW,Height=canvasH,RawWidth=w,RawHeight=h,RawAlpha0=rawHist[0],RawAlpha255=rawHist[255],RawAlpha1to7=Sum(rawHist,1,7),RawAlpha252to253=Sum(rawHist,252,253),Alpha0=hist[0],Alpha255=hist[255],Alpha1to7=Sum(hist,1,7),Alpha252to253=Sum(hist,252,253),FractionAlpha0=(double)hist[0]/canvasN,FractionAlpha255=(double)hist[255]/canvasN,AntialiasedPixels=edge,EdgeChebyshevRadius=edgeMaxDistance,CorePixels=core,CoreOpaquePixels=coreOpaque,CoreOpaqueRatio=(double)coreOpaque/core,OutsidePixels=outside,OutsideZeroPixels=outsideZero,OutsideZeroRatio=(double)outsideZero/outside,Bounds=new int[]{minX+ox,minY+oy,maxX+ox,maxY+oy},Margins=new int[]{minX+ox,minY+oy,canvasW-1-maxX-ox,canvasH-1-maxY-oy},RawMaskComponents=components,FinalComponents=1 };
    }
  }
  static long Sum(long[] a,int lo,int hi){long s=0;for(int i=lo;i<=hi;i++)s+=a[i];return s;}
}
'@
$folder = Split-Path -Parent $PSScriptRoot
$report = @{}
foreach ($variant in @('a','b')) {
  $name = 'nib-3q-' + $variant + '-v02.png'
  $report[$variant] = [NibAlpha]::Clean((Join-Path $PSScriptRoot $name),(Join-Path $folder $name),(Join-Path $PSScriptRoot ('alpha-proof-' + $variant + '.png')))
}
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'alpha-report.json') -Encoding UTF8
$report | ConvertTo-Json -Depth 5
