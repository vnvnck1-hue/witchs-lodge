$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$rootPath = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
public static class DrinksV03 {
 public static Bitmap Load(string p) {using(var b=new Bitmap(p))return b.Clone(new Rectangle(0,0,b.Width,b.Height),PixelFormat.Format32bppArgb);}
 public static void Save(Bitmap b,string p){Directory.CreateDirectory(Path.GetDirectoryName(p));b.Save(p,ImageFormat.Png);}
 static bool Dark(Color c){return c.R<24&&c.G<24&&c.B<24;}
 // The existing closed ink borders define both permitted edit interiors.
 static bool[] Flood(Bitmap b,int sx,int sy,int ymin,int ymax){
  var m=new bool[b.Width*b.Height];var q=new Queue<int>();int seed=sy*b.Width+sx;m[seed]=true;q.Enqueue(seed);
  while(q.Count>0){int p=q.Dequeue(),x=p%b.Width,y=p/b.Width;int[] ns={p-1,p+1,p-b.Width,p+b.Width};
   foreach(int n in ns){int xx=n%b.Width,yy=n/b.Width;if(xx<25||xx>999||yy<ymin||yy>ymax||Math.Abs(xx-x)+Math.Abs(yy-y)!=1||m[n]||Dark(b.GetPixel(xx,yy)))continue;m[n]=true;q.Enqueue(n);}
  }return m;
 }
 static Bitmap Resize(Bitmap a,int w,int h){var b=new Bitmap(w,h,PixelFormat.Format32bppArgb);using(var g=Graphics.FromImage(b))using(var ia=new ImageAttributes()){g.CompositingMode=CompositingMode.SourceCopy;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;ia.SetWrapMode(WrapMode.TileFlipXY);g.DrawImage(a,new Rectangle(0,0,w,h),0,0,a.Width,a.Height,GraphicsUnit.Pixel,ia);}return b;}
 public static void Prepare(string root){
  using(var src=Load(Path.Combine(root,"godot/assets/cards/wisp_spirit.png")))
  using(var mask=new Bitmap(1024,1536,PixelFormat.Format32bppArgb)){
   var art=Flood(src,100,500,310,1098);var badge=Flood(src,410,1080,1010,1170);
   // Fill tiny enclosed ink holes within badge row spans so the old mini bottle
   // cannot survive. Border-connected pixels stay outside the replacement.
   for(int y=1010;y<=1170;y++){int l=1024,r=-1;for(int x=360;x<660;x++)if(badge[y*1024+x]){l=Math.Min(l,x);r=Math.Max(r,x);}for(int x=l;x<=r;x++)badge[y*1024+x]=true;}
   // Fill source-art black islands surrounded by illustration. Keep all ink
   // connected to the outside (the frame and badge rim) pixel-identical.
   var outside=new bool[1024*1536];var queue=new Queue<int>();outside[0]=true;queue.Enqueue(0);
   while(queue.Count>0){int p=queue.Dequeue(),x=p%1024,y=p/1024;int[] ns={p-1,p+1,p-1024,p+1024};foreach(int n in ns){if(n<0||n>=outside.Length)continue;int xx=n%1024,yy=n/1024;if(Math.Abs(xx-x)+Math.Abs(yy-y)!=1||outside[n]||art[n]||badge[n])continue;outside[n]=true;queue.Enqueue(n);}}
   for(int p=0;p<art.Length;p++)if(!outside[p]&&!badge[p])art[p]=true;
   int ac=0,bc=0;for(int y=0;y<1536;y++)for(int x=0;x<1024;x++){int p=y*1024+x;if(art[p]){mask.SetPixel(x,y,Color.White);ac++;}if(badge[p]){mask.SetPixel(x,y,Color.White);bc++;}}
   Save(mask,Path.Combine(root,"output/tavern-v07/drink-edit-mask-v03.png"));
   Save(src,Path.Combine(root,"output/tavern-v07/drink-frame-source-v03.png"));
   Console.WriteLine("art interior="+ac+"; badge interior="+bc);
   string[] ids={"dragon_breath","frost_giant_spirit"};
   foreach(string id in ids){using(var raw=Load(Path.Combine(root,"art/cards/tavern-v07/drafts/"+id+"_drink-generated-v03.png")))using(var result=Load(Path.Combine(root,"godot/assets/cards/wisp_spirit.png"))){
    if(raw.Width!=1024||raw.Height!=1536)throw new Exception("Unexpected generated size");
    for(int y=0;y<1536;y++)for(int x=0;x<1024;x++){int p=y*1024+x;if(art[p]||badge[p]){Color c=raw.GetPixel(x,y),a=src.GetPixel(x,y);result.SetPixel(x,y,Color.FromArgb(a.A,c.R,c.G,c.B));}}
    string target=Path.Combine(root,"art/cards/tavern-v07/"+id+".png");Save(result,target);File.Copy(target,Path.Combine(root,"godot/assets/cards/"+id+".png"),true);
    using(var hand=Resize(result,256,384)){for(int y=0;y<384;y++)for(int x=0;x<256;x++){Color c=hand.GetPixel(x,y);if(c.A<8)hand.SetPixel(x,y,Color.FromArgb(0,c.R,c.G,c.B));}Save(hand,Path.Combine(root,"godot/assets/cards/hand/"+id+".png"));}
   }}
  }
 }
 public static void Sheet(string root){string[] ids={"dragon_breath","frost_giant_spirit","fire_ale","wisp_spirit","golden_mead","dew_of_forgetting"};
  using(var sheet=new Bitmap(1816,992,PixelFormat.Format32bppArgb))using(var g=Graphics.FromImage(sheet))using(var font=new Font("Arial",12,FontStyle.Bold)){
   g.Clear(Color.FromArgb(255,44,37,55));g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;
   g.DrawString("DRINK FORMAT v03 / illustration only / no baked card text",font,Brushes.White,20,12);
   for(int i=0;i<6;i++){int x=20+i*300;g.DrawString(ids[i],font,Brushes.White,x,48);using(var b=Load(Path.Combine(root,"godot/assets/cards/"+ids[i]+".png")))g.DrawImage(b,new Rectangle(x,76,280,420));}
   g.DrawString("Actual hand PNGs / 256 x 384 / 1:1 pixels",font,Brushes.White,20,524);
   for(int i=0;i<6;i++){int x=32+i*300;using(var b=Load(Path.Combine(root,"godot/assets/cards/hand/"+ids[i]+".png")))g.DrawImageUnscaled(b,x,560);}
   Save(sheet,Path.Combine(root,"godot/screenshots/tavern-v07/drink-format-sheet.png"));
  }
 }
}
'@
[DrinksV03]::Prepare($rootPath)
[DrinksV03]::Sheet($rootPath)
