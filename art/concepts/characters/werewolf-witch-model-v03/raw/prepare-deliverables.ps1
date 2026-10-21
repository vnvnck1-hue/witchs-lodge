$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.IO;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class WolfSplit {
 static byte[] Read(Bitmap b) {var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);var p=new byte[b.Width*b.Height*4];Marshal.Copy(d.Scan0,p,0,p.Length);b.UnlockBits(d);return p;}
 static Bitmap From(byte[] p,int w,int h){var b=new Bitmap(w,h,PixelFormat.Format32bppArgb);var d=b.LockBits(new Rectangle(0,0,w,h),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);Marshal.Copy(p,0,d.Scan0,p.Length);b.UnlockBits(d);return b;}
 static Bitmap Load(string s){return new Bitmap(s);} static void Put(Bitmap b,byte[] p){var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);Marshal.Copy(p,0,d.Scan0,p.Length);b.UnlockBits(d);}
 static Rectangle Bounds(Bitmap b){var p=Read(b);int x0=b.Width,y0=b.Height,x1=-1,y1=-1;for(int y=0;y<b.Height;y++)for(int x=0;x<b.Width;x++)if(p[(y*b.Width+x)*4+3]>0){x0=Math.Min(x0,x);y0=Math.Min(y0,y);x1=Math.Max(x1,x);y1=Math.Max(y1,y);}return Rectangle.FromLTRB(x0,y0,x1+1,y1+1);}
 static Bitmap Clean(Bitmap b){int w=b.Width,h=b.Height,n=w*h;var p=Read(b);var seen=new bool[n];var largest=new List<int>();var q=new int[n];for(int s=0;s<n;s++){if(seen[s]||p[4*s+3]<128)continue;int a=0,z=0;q[z++]=s;seen[s]=true;var c=new List<int>();while(a<z){int v=q[a++];c.Add(v);int x=v%w,y=v/w;for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){int xx=x+dx,yy=y+dy;if(xx<0||xx>=w||yy<0||yy>=h)continue;int u=yy*w+xx;if(!seen[u]&&p[4*u+3]>=128){seen[u]=true;q[z++]=u;}}}if(c.Count>largest.Count)largest=c;}
 var mask=new bool[n];foreach(int v in largest)mask[v]=true;var o=(byte[])p.Clone();for(int v=0;v<n;v++){int x=v%w,y=v/w;bool near=false,inside=true;int nearest=-1,dist=99;for(int dy=-2;dy<=2;dy++)for(int dx=-2;dx<=2;dx++){int xx=x+dx,yy=y+dy;bool on=xx>=0&&yy>=0&&xx<w&&yy<h&&mask[yy*w+xx];if(!on)inside=false;else{near=true;int dd=dx*dx+dy*dy;if(dd<dist){dist=dd;nearest=yy*w+xx;}}}if(!near||p[v*4+3]==0||(!mask[v]&&p[v*4+3]>=128)){for(int k=0;k<4;k++)o[v*4+k]=0;continue;}if(inside)o[v*4+3]=255;if(p[v*4+3]<255&&nearest>=0)for(int k=0;k<3;k++)o[v*4+k]=p[nearest*4+k];}return From(o,w,h);}
 static void Draw(Bitmap target,Bitmap src,Rectangle dst,Rectangle sr){using(var g=Graphics.FromImage(target)){g.CompositingMode=CompositingMode.SourceCopy;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;using(var at=new ImageAttributes()){at.SetWrapMode(WrapMode.TileFlipXY);g.DrawImage(src,dst,sr.X,sr.Y,sr.Width,sr.Height,GraphicsUnit.Pixel,at);}}}
 static double Fit(byte[] a,byte[] b,int bw,int bh,double scale,double ox,double oy){double sum=0;int count=0;for(int y=250;y<1190;y+=9)for(int x=530;x<1250;x+=9){if(y>950&&x<720)continue;int gx=(int)Math.Round((x-ox)/scale),gy=(int)Math.Round((y-oy)/scale);if(gx<0||gy<0||gx>=bw||gy>=bh)continue;int v=(y*1536+x)*4,u=(gy*bw+gx)*4;if(a[v+3]<255||b[u+3]<240)continue;for(int k=0;k<3;k++){double delta=a[v+k]-b[u+k];sum+=delta*delta;}count++;}return sum/Math.Max(1,count);}
 static bool ROI(int x,int y){return y>=890&&y<1300&&x<710;}
 public static void Run(string original,string raw,string dest){using(var src=Load(original))using(var generated=Load(raw))using(var bodyRaw=generated.Clone(new Rectangle(0,0,965,generated.Height),PixelFormat.Format32bppArgb))using(var bodyGen=Clean(bodyRaw))using(var tailRaw=generated.Clone(new Rectangle(965,0,generated.Width-965,generated.Height),PixelFormat.Format32bppArgb))using(var tailGen=Clean(tailRaw)){
 var ap=Read(src);var gp=Read(bodyGen);double best=1e30,bs=0,bx=0,by=0;for(double s=1.265;s<=1.3101;s+=.005)for(int ox=160;ox<=190;ox+=3)for(int oy=-6;oy<=21;oy+=3){double e=Fit(ap,gp,bodyGen.Width,bodyGen.Height,s,ox,oy);if(e<best){best=e;bs=s;bx=ox;by=oy;}}
 double coarseS=bs,coarseX=bx,coarseY=by;for(double s=coarseS-.004;s<=coarseS+.0041;s+=.001)for(int ox=(int)coarseX-3;ox<=coarseX+3;ox++)for(int oy=(int)coarseY-3;oy<=coarseY+3;oy++){double e=Fit(ap,gp,bodyGen.Width,bodyGen.Height,s,ox,oy);if(e<best){best=e;bs=s;bx=ox;by=oy;}}
 var report=new List<string>();report.Add(String.Format("Generated body registration: scale={0:F4}; offset=({1},{2}); mean summed RGB squared error={3:F2}",bs,bx,by,best));
 using(var aligned=new Bitmap(1536,1536,PixelFormat.Format32bppArgb)){Draw(aligned,bodyGen,new Rectangle((int)bx,(int)by,(int)Math.Round(bodyGen.Width*bs),(int)Math.Round(bodyGen.Height*bs)),new Rectangle(0,0,bodyGen.Width,bodyGen.Height));using(var alignedClean=Clean(aligned)){alignedClean.Save(Path.Combine(dest,"raw/body-aligned-preview.png"),ImageFormat.Png);var pp=Read(alignedClean);var output=(byte[])ap.Clone();int changed=0,protectedChanged=0,protectedVisible=0;
 var tailMask=new bool[1536*1536];var queue=new int[1536*1536];int q0=0,q1=0;int seed=1100*1536+200;queue[q1++]=seed;tailMask[seed]=true;while(q0<q1){int n=queue[q0++],xx=n%1536,yy=n/1536;for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){int ax=xx+dx,ay=yy+dy;if(ax<0||ax>=550||ay<950||ay>=1300)continue;int z=ay*1536+ax;if(!tailMask[z]&&ap[z*4+3]>0){tailMask[z]=true;queue[q1++]=z;}}}
for(int y=0;y<1536;y++)for(int x=0;x<1536;x++){int n=y*1536+x,v=n*4;if(!ROI(x,y))continue;if(x<550){if(tailMask[n])for(int k=0;k<4;k++)output[v+k]=0;continue;}if(y>=1200)continue;
double region=Math.Min(1,Math.Max(0,(y-890)/60.0));region*=Math.Min(1,Math.Max(0,(1200-y)/35.0));region*=Math.Min(1,Math.Max(0,(710-x)/25.0));
int distance=20;for(int dy=-18;dy<=18;dy++)for(int dx=-18;dx<=18;dx++){int xx=x+dx,yy=y+dy;if(xx<0||xx>=1536||yy<0||yy>=1536)continue;if(pp[(yy*1536+xx)*4+3]<128)distance=Math.Min(distance,Math.Max(Math.Abs(dx),Math.Abs(dy)));}
double t=ap[v+3]==0?1:Math.Max(0,1-distance/18.0);t*=region;
double alpha=ap[v+3]*(1-region)+pp[v+3]*region;output[v+3]=(byte)Math.Round(alpha);for(int k=0;k<3;k++)output[v+k]=(byte)Math.Round(ap[v+k]*(1-t)+pp[v+k]*t);if(output[v+3]==0)for(int k=0;k<3;k++)output[v+k]=0;
}
using(var unclean=From(output,1536,1536))using(var cleaned=Clean(unclean)){var cp=Read(cleaned);for(int y=0;y<1536;y++)for(int x=0;x<1536;x++)if(ROI(x,y)){int v=(y*1536+x)*4;for(int k=0;k<4;k++)output[v+k]=((x<550&&!tailMask[y*1536+x]&&ap[v+3]>=128)||(x>=550&&y>=1220))?ap[v+k]:cp[v+k];}}
for(int y=0;y<1536;y++)for(int x=0;x<1536;x++){int v=(y*1536+x)*4;bool diff=false;for(int k=0;k<4;k++)if(ap[v+k]!=output[v+k])diff=true;if(diff)changed++;if(!ROI(x,y)){if(diff)protectedChanged++;if(ap[v+3]>0)protectedVisible++;}}
 using(var body=From(output,1536,1536)){body.Save(Path.Combine(dest,"werewolf-body-v03.png"),ImageFormat.Png);var tb=Bounds(tailGen);int tw=480,th=(int)Math.Round(tb.Height*tw/(double)tb.Width);
 using(var tailCanvas=new Bitmap(tw,th,PixelFormat.Format32bppArgb)){Draw(tailCanvas,tailGen,new Rectangle(0,0,tw,th),tb);using(var tail=Clean(tailCanvas))using(var sheet=new Bitmap(2048,1536,PixelFormat.Format32bppArgb))using(var singleTail=new Bitmap(1536,1536,PixelFormat.Format32bppArgb)){
 using(var g=Graphics.FromImage(sheet)){g.CompositingMode=CompositingMode.SourceCopy;g.DrawImageUnscaled(body,0,0);g.DrawImageUnscaled(tail,1470,950);}using(var g=Graphics.FromImage(singleTail)){g.CompositingMode=CompositingMode.SourceCopy;g.DrawImageUnscaled(tail,(1536-tw)/2,(1536-th)/2);}
 var sheetPixels=new byte[2048*1536*4];for(int row=0;row<1536;row++)Array.Copy(output,row*1536*4,sheetPixels,row*2048*4,1536*4);var tailPixels=Read(tail);var soloPixels=new byte[1536*1536*4];for(int row=0;row<th;row++){Array.Copy(tailPixels,row*tw*4,sheetPixels,((row+950)*2048+1470)*4,tw*4);Array.Copy(tailPixels,row*tw*4,soloPixels,((row+(1536-th)/2)*1536+(1536-tw)/2)*4,tw*4);}Put(sheet,sheetPixels);Put(singleTail,soloPixels);sheet.Save(Path.Combine(dest,"werewolf-sheet-v03.png"),ImageFormat.Png);singleTail.Save(Path.Combine(dest,"werewolf-tail-v03.png"),ImageFormat.Png);
 var bb=Bounds(body);var tt=Bounds(tail);report.Add("Body bounds="+bb+"; tail crop bounds="+tb+"; final tail bounds="+tt+"; body to tail horizontal blank columns="+(1470+tt.X-bb.Right));report.Add("Original body scale=1.0000; translation=(0,0). Total changed pixels="+changed+"; unchanged visible pixels outside tail edit ROI="+protectedVisible+"; changed pixels outside ROI="+protectedChanged);report.Add("Detached tail target width="+tw+"; height="+th+". Sheet tail origin=(1470,950); solo tail origin=("+(1536-tw)/2+","+(1536-th)/2+")");
 Contact(src,sheet,Path.Combine(dest,"werewolf-v03-contact.png"));}
 }
 }
 }}File.WriteAllLines(Path.Combine(dest,"raw/preparation-report.txt"),report.ToArray(),new System.Text.UTF8Encoding(true));
 }}
 static void Contact(Bitmap original,Bitmap sheet,string path){using(var board=new Bitmap(1872,900,PixelFormat.Format24bppRgb))using(var g=Graphics.FromImage(board))using(var font=new Font("Arial",20,FontStyle.Bold))using(var small=new Font("Arial",12)){g.Clear(Color.FromArgb(232,228,222));g.TextRenderingHint=System.Drawing.Text.TextRenderingHint.AntiAliasGridFit;g.DrawString("v02 / ORIGINAL",font,Brushes.DimGray,24,20);g.DrawString("v03 / BODY + DETACHED TAIL",font,Brushes.DimGray,832,20);g.DrawString("Same pixel scale: 50% | Original body pixels preserved outside tail edit region",small,Brushes.DimGray,24,60);g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.DrawImage(original,new Rectangle(24,95,768,768));g.DrawImage(sheet,new Rectangle(824,95,1024,768));board.Save(path,ImageFormat.Png);}}
 public static string Report(string path){using(var b=Load(path)){var p=Read(b);int n=b.Width*b.Height,zero=0,full=0,partial=0,deep=0;for(int v=0;v<n;v++){int a=p[v*4+3];if(a==0)zero++;else if(a==255)full++;else{partial++;bool inside=false,outside=false;int x=v%b.Width,y=v/b.Width;for(int dy=-2;dy<=2;dy++)for(int dx=-2;dx<=2;dx++){int xx=x+dx,yy=y+dy;if(xx<0||xx>=b.Width||yy<0||yy>=b.Height){outside=true;continue;}if(p[(yy*b.Width+xx)*4+3]>=128)inside=true;else outside=true;}if(!inside||!outside)deep++;}}return String.Format("{0}: {1}x{2}; bbox={3}; alpha0={4}; alpha255={5}; alpha1to254={6}; partial_outside_2px_boundary={7}; corners={8}/{9}/{10}/{11}",Path.GetFileName(path),b.Width,b.Height,Bounds(b),zero,full,partial,deep,b.GetPixel(0,0).A,b.GetPixel(b.Width-1,0).A,b.GetPixel(0,b.Height-1).A,b.GetPixel(b.Width-1,b.Height-1).A);}}
}
'@
$dest = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$original = [IO.Path]::GetFullPath((Join-Path $dest '../werewolf-witch-model-v02/werewolf-3q-b-v02.png'))
[WolfSplit]::Run($original,(Join-Path $PSScriptRoot 'werewolf-split-generated.png'),$dest)
@('werewolf-sheet-v03.png','werewolf-body-v03.png','werewolf-tail-v03.png') | ForEach-Object {[WolfSplit]::Report((Join-Path $dest $_))} | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'alpha-report.txt') -Encoding UTF8
Get-Content -LiteralPath (Join-Path $PSScriptRoot 'preparation-report.txt') -Encoding UTF8
Get-Content -LiteralPath (Join-Path $PSScriptRoot 'alpha-report.txt') -Encoding UTF8




