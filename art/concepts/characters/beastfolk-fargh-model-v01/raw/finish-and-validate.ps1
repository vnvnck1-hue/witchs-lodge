param([string]$OutputRoot = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class FarghFinish {
  public static object Run(string src, string dst) {
    using (Bitmap im = new Bitmap(src)) {
      int w=im.Width,h=im.Height,n=w*h;
      var rect=new Rectangle(0,0,w,h);
      var bd=im.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
      byte[] p=new byte[bd.Stride*h]; Marshal.Copy(bd.Scan0,p,0,p.Length); int stride=bd.Stride;
      im.UnlockBits(bd);
      bool[] mask=new bool[n]; int x0=w,y0=h,x1=0,y1=0;
      long raw0=0,raw255=0,rawMid=0;
      for(int y=0;y<h;y++) for(int x=0;x<w;x++) {
        int a=p[y*stride+x*4+3]; if(a==0)raw0++;else if(a==255)raw255++;else rawMid++;
        if(a>=128) {mask[y*w+x]=true;x0=Math.Min(x0,x);y0=Math.Min(y0,y);x1=Math.Max(x1,x);y1=Math.Max(y1,y);}
      }
      int ox=(1536-(x1-x0+1))/2-x0, oy=(1536-(y1-y0+1))/2-y0;
      byte[] output=new byte[1536*1536*4]; long zero=0,opaque=0,mid=0;
      for(int y=1;y<h-1;y++) for(int x=1;x<w-1;x++) {
        bool all=true,any=false;
        for(int j=-1;j<=1;j++)for(int i=-1;i<=1;i++){bool m=mask[(y+j)*w+x+i];all &= m;any |= m;}
        if(!any)continue;
        int s=y*stride+x*4,a=p[s+3];
        if(all)a=255;else if(a<=16)a=0;else if(a>=240)a=255;else a=Math.Min(255,(int)Math.Round(a*255.0/253.0));
        if(a==0)continue;
        int nx=x+ox,ny=y+oy;
        if(nx<0||ny<0||nx>=1536||ny>=1536)throw new Exception("Contour cropped");
        int d=(ny*1536+nx)*4;
        int color=s;
        // For antialiased boundary pixels only, pull RGB from nearest solid interior.
        // This removes colored fringe noise without changing silhouette alpha.
        if(!all) {
          int best=10000;
          for(int j=-3;j<=3;j++)for(int i=-3;i<=3;i++) {
            int xx=x+i,yy=y+j;if(xx<1||yy<1||xx>=w-1||yy>=h-1)continue;
            bool solid=true;
            for(int v=-1;v<=1&&solid;v++)for(int u=-1;u<=1;u++)if(!mask[(yy+v)*w+xx+u]){solid=false;break;}
            int dist=i*i+j*j;
            if(solid&&dist<best){best=dist;color=yy*stride+xx*4;}
          }
        }
        output[d]=p[color];output[d+1]=p[color+1];output[d+2]=p[color+2];output[d+3]=(byte)a;
      }
      // Any isolated low-alpha interior texel is opaque; partial alpha is contour-only.
      for(int y=2;y<1534;y++)for(int x=2;x<1534;x++) {
        int d=(y*1536+x)*4;int a=output[d+3];if(a==0||a==255)continue;
        bool nearZero=false;
        for(int j=-2;j<=2;j++)for(int i=-2;i<=2;i++)if(output[((y+j)*1536+x+i)*4+3]==0)nearZero=true;
        if(!nearZero)output[d+3]=255;
      }
      int bx0=1536,by0=1536,bx1=0,by1=0;int bandViolation=0;
      for(int y=0;y<1536;y++)for(int x=0;x<1536;x++){
        byte a=output[(y*1536+x)*4+3];
        if(a==0){zero++;continue;}
        bx0=Math.Min(bx0,x);by0=Math.Min(by0,y);bx1=Math.Max(bx1,x);by1=Math.Max(by1,y);
        if(a==255)opaque++;else {
          mid++;bool touchesOutside=false;
          for(int j=-2;j<=2;j++)for(int i=-2;i<=2;i++) {
            int xx=x+i,yy=y+j;
            if(xx<0||yy<0||xx>=1536||yy>=1536||output[(yy*1536+xx)*4+3]==0)touchesOutside=true;
          }
          if(!touchesOutside)bandViolation++;
        }
      }
      // Count disconnected visible islands to catch stray background residue.
      bool[] visited=new bool[1536*1536];var sizes=new List<int>();var q=new Queue<int>();
      for(int v=0;v<visited.Length;v++){
        if(visited[v]||output[v*4+3]==0)continue;
        visited[v]=true;q.Enqueue(v);int count=0;
        while(q.Count>0){int cur=q.Dequeue();count++;int cx=cur%1536,cy=cur/1536;
          for(int j=-1;j<=1;j++)for(int i=-1;i<=1;i++){
            int xx=cx+i,yy=cy+j;if(xx<0||yy<0||xx>=1536||yy>=1536)continue;int nv=yy*1536+xx;
            if(!visited[nv]&&output[nv*4+3]>0){visited[nv]=true;q.Enqueue(nv);}
          }
        }sizes.Add(count);
      }
      sizes.Sort();sizes.Reverse();
      using(Bitmap final=new Bitmap(1536,1536,PixelFormat.Format32bppArgb)){
        var fd=final.LockBits(new Rectangle(0,0,1536,1536),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);
        Marshal.Copy(output,0,fd.Scan0,output.Length);final.UnlockBits(fd);final.Save(dst,ImageFormat.Png);
        foreach(var tone in new[]{"light","dark"}){
          using(Bitmap preview=new Bitmap(1536,1536,PixelFormat.Format24bppRgb)){
            using(Graphics g=Graphics.FromImage(preview)){
              g.Clear(tone=="light"?Color.FromArgb(238,234,226):Color.FromArgb(35,39,48));
              g.DrawImageUnscaled(final,0,0);
            }preview.Save(System.IO.Path.Combine(System.IO.Path.GetDirectoryName(src),System.IO.Path.GetFileNameWithoutExtension(dst)+"-qa-"+tone+".png"),ImageFormat.Png);
          }
        }
      }
      return new { raw_width=w,raw_height=h,raw_alpha_zero=raw0,raw_alpha_255=raw255,raw_alpha_intermediate=rawMid,
        width=1536,height=1536,translation_x=ox,translation_y=oy,alpha_zero=zero,alpha_255=opaque,alpha_intermediate=mid,
        intermediate_farther_than_2px_from_zero=bandViolation,visible_bbox=new[]{bx0,by0,bx1,by1},
        margins_ltrb=new[]{bx0,by0,1535-bx1,1535-by1},connected_visible_components=sizes.ToArray() };
    }
  }
}
'@
$farghResults=@()
foreach($farghVariant in @('a','b')){
  $farghSource=if($farghVariant -eq 'a'){'fargh-3q-a-tail-revision-v01.png'}else{'fargh-3q-b-pose-revision-v01.png'}
  $farghPath=Join-Path $OutputRoot "fargh-3q-$farghVariant-v01.png"
  $farghResult=[FarghFinish]::Run((Join-Path $OutputRoot "raw/$farghSource"),$farghPath)
  $farghResults += [pscustomobject]@{file=(Split-Path -Leaf $farghPath);sha256=(Get-FileHash -LiteralPath $farghPath -Algorithm SHA256).Hash.ToLower();bytes=(Get-Item -LiteralPath $farghPath).Length;inspection=$farghResult}
}
$farghResults | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputRoot 'raw/validation.json') -Encoding UTF8
$farghResults | ConvertTo-Json -Depth 8

