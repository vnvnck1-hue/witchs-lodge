Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class HumanQA {
 public static object Inspect(string file,int chin) {
  using(var im=new Bitmap(file)){
   int w=im.Width,h=im.Height;byte[] pixels=new byte[w*h*4];long[] hist=new long[256];
   var bits=im.LockBits(new Rectangle(0,0,w,h),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
   for(int y=0;y<h;y++)Marshal.Copy(IntPtr.Add(bits.Scan0,y*bits.Stride),pixels,y*w*4,w*4);im.UnlockBits(bits);
   int l=w,t=h,r=-1,b=-1;int invalidTransparentRGB=0;
   for(int y=0;y<h;y++)for(int x=0;x<w;x++){
    int i=(y*w+x)*4,a=pixels[i+3];hist[a]++;
    if(a>=192){l=Math.Min(l,x);t=Math.Min(t,y);r=Math.Max(r,x);b=Math.Max(b,y);}
    if(a==0&&(pixels[i]!=0||pixels[i+1]!=0||pixels[i+2]!=0))invalidTransparentRGB++;
   }
   return new{Width=w,Height=h,BoundsAlpha192=new int[]{l,t,r,b},TotalHeight=b-t+1,HairCrownY=t,ChinY=chin,HeadHeight=chin-t+1,HeadPercent=100.0*(chin-t+1)/(b-t+1),AlphaZero=hist[0],Alpha255=hist[255],PartialAlpha=w*h-hist[0]-hist[255],TransparentPixelsWithNonzeroRGB=invalidTransparentRGB,CornerAlpha=new int[]{im.GetPixel(0,0).A,im.GetPixel(w-1,0).A,im.GetPixel(0,h-1).A,im.GetPixel(w-1,h-1).A}};
  }
 }
 public static void Compare(string human,string nib,string output){
  using(var a=new Bitmap(nib))using(var b=new Bitmap(human))using(var dst=new Bitmap(1536,860))using(var g=Graphics.FromImage(dst))using(var font=new Font("Arial",18))using(var small=new Font("Arial",14))using(var pen=new Pen(Color.FromArgb(180,40,120,180),1)){
   g.Clear(Color.FromArgb(236,236,236));g.InterpolationMode=InterpolationMode.HighQualityBicubic;
   g.DrawString("NIB v03  |  head 46.4%",font,Brushes.Black,24,15);g.DrawString("HUMAN v02  |  head 47.0%",font,Brushes.Black,792,15);
   g.DrawImage(a,new Rectangle(0,50,768,768));g.DrawImage(b,new Rectangle(768,50,768,768));
   for(int side=0;side<2;side++){int ox=768*side;int chin=side==0?733:740;foreach(int yy in new int[]{218,chin,1329}){float y=50+yy/2f;g.DrawLine(pen,ox+110,y,ox+660,y);g.DrawString("y="+yy,small,Brushes.SteelBlue,ox+28,y-10);}}
   g.DrawString("Same 1536 canvas, same display scale; head = hair crown to chin, ears excluded. Manual chin +/- 5px.",small,Brushes.Black,24,825);
   dst.Save(output,ImageFormat.Png);
  }
 }
}
'@
$folder = Split-Path -Parent $PSScriptRoot
$human = Join-Path $folder 'human-common-3q-v02.png'
$nib = Join-Path (Split-Path -Parent $folder) 'goblin-nib-model-v03/nib-3q-v03.png'
$report = [PSCustomObject]@{
 Human = [HumanQA]::Inspect($human,740)
 Nib = [HumanQA]::Inspect($nib,733)
 Method = 'Alpha >=192 full-height bounds; visually selected crown-to-chin landmarks with hair included and ears excluded; inclusive pixel counts; chin uncertainty +/-5px. No body-part rescaling.'
}
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'proportion-report.json') -Encoding UTF8
[HumanQA]::Compare($human,$nib,(Join-Path $PSScriptRoot 'nib-human-comparison.png'))
$report | ConvertTo-Json -Depth 8
