$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
public static class TavernAssets {
 public static Bitmap Load(string p) { using(var a=new Bitmap(p)) { return a.Clone(new Rectangle(0,0,a.Width,a.Height),PixelFormat.Format32bppArgb); } }
 public static Bitmap Resize(Bitmap a,int w,int h) {var b=new Bitmap(w,h,PixelFormat.Format32bppArgb);using(var g=Graphics.FromImage(b)){g.CompositingMode=CompositingMode.SourceCopy;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;using(var ia=new ImageAttributes()){ia.SetWrapMode(WrapMode.TileFlipXY);g.DrawImage(a,new Rectangle(0,0,w,h),0,0,a.Width,a.Height,GraphicsUnit.Pixel,ia);}}return b;}
 public static void Save(Bitmap b,string p){Directory.CreateDirectory(Path.GetDirectoryName(p));b.Save(p,ImageFormat.Png);}
 static float Lerp(float a,float b,float t){return a+(b-a)*t;}
 static float Bound(int y,int[,] knots,int col){for(int i=1;i<knots.GetLength(0);i++){if(y<=knots[i,0])return Lerp(knots[i-1,col],knots[i,col],(float)(y-knots[i-1,0])/(knots[i,0]-knots[i-1,0]));}return knots[knots.GetLength(0)-1,col];}
 // The row contours stay inside the source illustration. The source frame, diamond,
 // lettering plates and alpha silhouette are never synthesized or repainted.
 static int[,] skill={ {278,216,809},{287,202,823},{300,190,833},{325,148,875},{350,119,902},{375,102,920},{400,95,929},{425,99,925},{450,105,920},{475,108,916},{500,106,917},{525,104,919},{550,96,928},{575,83,942},{600,70,957},{625,56,970},{650,46,978},{675,48,978},{700,59,969},{725,77,953},{750,95,930},{775,115,909},{800,133,894},{825,145,883},{850,164,858},{875,145,879},{900,140,888},{925,134,897},{950,128,897},{975,141,882},{1000,166,855},{1015,225,796},{1025,320,704},{1030,450,570},{1045,511,513} };
 static int[,] evt={ {297,100,925},{307,91,934},{317,83,942},{327,76,949},{337,70,956},{375,53,969},{425,44,978},{500,41,980},{575,40,981},{650,46,979},{700,53,971},{750,73,951},{775,83,939},{800,88,943},{825,72,952},{850,59,965},{875,50,972},{900,49,970},{925,55,960},{950,65,947},{975,79,932},{1000,97,922},{1025,111,934},{1040,205,939},{1055,270,929},{1075,280,943},{1095,292,936},{1105,315,930},{1115,340,900},{1118,470,775} };
 static bool Dark(Color c){return c.R<55&&c.G<55&&c.B<55;}
 static bool Cream(Color c){return c.R>185&&c.G>165&&c.B<230;}
 static bool DiamondBand(int x,int y){
  if(y<265||y>1095)return false;
  double dy=y-659;
  double inner=dy<0?139+(-dy)*0.988:139+dy*0.981;
  double outer=dy<0?79+(-dy)*1.017:79+dy*0.992;
  int a=(int)Math.Floor(outer)-3,b=(int)Math.Ceiling(inner)+3;
  return (x>=a&&x<=b)||(x>=1023-b&&x<=1023-a);
 }
 public static void Card(string root,string id,string source,string raw,bool isSkill){
  using(var b=Load(Path.Combine(root,"output/tavern-v07/reference-snapshots/"+source+".png")))
  using(var art=Load(Path.Combine(root,"art/cards/tavern-v07/drafts/"+raw)))
  using(var cleanDiamond=Load(Path.Combine(root,"output/tavern-v07/reference-snapshots/frost_rune.png")))
  using(var layer=new Bitmap(1024,1536,PixelFormat.Format32bppArgb))
  using(var mask=new Bitmap(1024,1536,PixelFormat.Format32bppArgb)){
   using(var g=Graphics.FromImage(layer)){g.CompositingMode=CompositingMode.SourceCopy;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;
    if(isSkill){ // Uniform fit: landscape originals retain their exact aspect ratio.
     float w=1024f,h=w*art.Height/art.Width;g.DrawImage(art,new RectangleF(0,278,w,h));
    }else{g.DrawImageUnscaled(art,0,0);}
   }
   if(isSkill){ // Recenter the whole new scene, keeping bottle and wolf clear of the frame.
    int sw=880,sh=(int)Math.Round(880.0*art.Height/art.Width),sx=72,sy=332;
    using(var smaller=Resize(art,sw,sh))for(int yy=0;yy<sh;yy++)for(int xx=0;xx<sw;xx++){
     int dx=sx+xx,dy=sy+yy;if(dy>=1536)continue;
     double t=Math.Min(1.0,Math.Min(Math.Min(xx,sw-1-xx),Math.Min(yy,sh-1-yy))/60.0);t=t*t*(3-2*t);
     layer.SetPixel(dx,dy,Mix(layer.GetPixel(dx,dy),smaller.GetPixel(xx,yy),t));
    }
   }
   int[,] knots=isSkill?skill:evt;int y0=knots[0,0],y1=knots[knots.GetLength(0)-1,0];
   for(int y=y0;y<=y1;y++){
    int l=(int)Math.Ceiling(Bound(y,knots,1)),r=(int)Math.Floor(Bound(y,knots,2));
    for(int x=l;x<=r;x++){
     Color orig=b.GetPixel(x,y);
     if(!isSkill&&y<340){
      double top=334-28*Math.Pow(Math.Abs(x-512)/416.0,1.5);
      if(y<top||y<top+10&&Dark(orig))continue;
     }
     if(isSkill&&DiamondBand(x,y)){
      // The original torch crosses and hides two frame segments. Borrow the same
      // role's unobscured diamond pixels; do not preserve fragments of that torch.
      // The lower right ice decoration also occludes the old diamond. Its clean
      // lower left edge supplies the symmetric corresponding segment.
      Color frame=cleanDiamond.GetPixel(y>659&&x>512?1023-x:x,y);
      b.SetPixel(x,y,frame);continue;
     }
     // Preserve the antialias and ink on the inner edge of the original outer frame.
     if((x-l<8||r-x<8||y-y0<8||y1-y<8)&&Dark(orig))continue;
     Color c=layer.GetPixel(x,y);if(c.A==0)continue;
     b.SetPixel(x,y,Color.FromArgb(orig.A,c.R,c.G,c.B));mask.SetPixel(x,y,Color.White);
    }
   }
   for(int y=0;y<b.Height;y++)for(int x=0;x<b.Width;x++){var c=b.GetPixel(x,y);int alpha=c.A;double cx=Math.Max(0,34-Math.Min(x,1023-x)),cy=Math.Max(0,34-Math.Min(y,1535-y));if(cx*cx+cy*cy>34*34)alpha=0;if(alpha<8)alpha=0;if(alpha!=c.A)b.SetPixel(x,y,Color.FromArgb(alpha,c.R,c.G,c.B));}
   string p=Path.Combine(root,"art/cards/tavern-v07/"+id+".png");Save(b,p);
   File.Copy(p,Path.Combine(root,"godot/assets/cards/"+id+".png"),true);
   using(var hand=Resize(b,256,384)){for(int y=0;y<384;y++)for(int x=0;x<256;x++){var c=hand.GetPixel(x,y);if(c.A<8)hand.SetPixel(x,y,Color.FromArgb(0,c.R,c.G,c.B));}Save(hand,Path.Combine(root,"godot/assets/cards/hand/"+id+".png"));}
   Save(mask,Path.Combine(root,"output/tavern-v07/"+id+"-art-mask.png"));
  }
 }
 public static void Decal(string root,string name,int n){using(var a=Load(Path.Combine(root,"art/cards/tavern-v07/drafts/"+name+"_generated.png")))using(var b=Resize(a,n,n)){
  // Preserve generated transparency; clear negligible quantization haze only.
  for(int y=0;y<n;y++)for(int x=0;x<n;x++){var c=b.GetPixel(x,y);if(c.A<3)b.SetPixel(x,y,Color.FromArgb(0,c.R,c.G,c.B));}
  Save(b,Path.Combine(root,"godot/assets/vfx/tavern/"+name+".png"));}}
 public static void Ice(string root){using(var a=Load(Path.Combine(root,"art/cards/tavern-v07/drafts/ice_block_generated.png")))using(var b=Resize(a,512,512)){
  // Normalize physical opacity before edge blending; all pixels remain in [160,230].
  for(int y=0;y<512;y++)for(int x=0;x<512;x++){var c=b.GetPixel(x,y);int lum=(c.R*3+c.G*6+c.B)/10;int alpha=160+(int)Math.Round(70.0*lum/255);b.SetPixel(x,y,Color.FromArgb(alpha,c.R,c.G,c.B));}
  // Symmetric smooth edge crossfade. Opposite edge values and first derivatives match.
  int band=48;
  for(int y=0;y<512;y++)for(int d=0;d<band;d++){int x=511-d;var c=b.GetPixel(d,y);var e=b.GetPixel(x,y);double t=(double)d/(band-1);double w=0.5*(1-t*t*(3-2*t));b.SetPixel(d,y,Mix(c,e,w));b.SetPixel(x,y,Mix(e,c,w));}
  for(int x=0;x<512;x++)for(int d=0;d<band;d++){int y=511-d;var c=b.GetPixel(x,d);var e=b.GetPixel(x,y);double t=(double)d/(band-1);double w=0.5*(1-t*t*(3-2*t));b.SetPixel(x,d,Mix(c,e,w));b.SetPixel(x,y,Mix(e,c,w));}
  Save(b,Path.Combine(root,"godot/assets/vfx/tavern/ice_block.png"));
  using(var sheet=new Bitmap(1024,1024,PixelFormat.Format32bppArgb)){using(var g=Graphics.FromImage(sheet)){g.Clear(Color.FromArgb(255,38,45,58));for(int y=0;y<2;y++)for(int x=0;x<2;x++)g.DrawImageUnscaled(b,x*512,y*512);}Save(sheet,Path.Combine(root,"output/tavern-v07/ice-tile-2x2.png"));}
 }}
 static Color Mix(Color a,Color b,double w){return Color.FromArgb((int)Math.Round(a.A*(1-w)+b.A*w),(int)Math.Round(a.R*(1-w)+b.R*w),(int)Math.Round(a.G*(1-w)+b.G*w),(int)Math.Round(a.B*(1-w)+b.B*w));}
 public static void Sheet(string root){using(var b=new Bitmap(1600,1160,PixelFormat.Format32bppArgb))using(var g=Graphics.FromImage(b))using(var f=new Font("Arial",16,FontStyle.Bold))using(var small=new Font("Arial",12)){
  g.Clear(Color.FromArgb(255,43,36,54));g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;
  string[] ids={"dragon_breath","frost_giant_spirit","cheers","fire_ale","drunk_rant"};
  for(int i=0;i<5;i++){using(var c=Load(Path.Combine(root,"godot/assets/cards/"+ids[i]+".png"))){g.DrawImage(c,new Rectangle(24+i*316,50,288,432));}g.DrawString(ids[i],small,Brushes.White,24+i*316,20);}
  g.DrawString("VFX / light and dark backgrounds",f,Brushes.White,24,520);
  string[] names={"fire_pool","ice_block","vomit_puddle"};
  for(int i=0;i<3;i++){int x=24+i*526;g.DrawString(names[i],f,Brushes.White,x,560);using(var c=Load(Path.Combine(root,"godot/assets/vfx/tavern/"+names[i]+".png"))){g.FillRectangle(Brushes.AntiqueWhite,x,600,240,240);using(var br=new SolidBrush(Color.FromArgb(255,22,26,39)))g.FillRectangle(br,x+252,600,240,240);g.DrawImage(c,new Rectangle(x,600,240,240));g.DrawImage(c,new Rectangle(x+252,600,240,240));}}
  g.DrawString("Actual hand PNGs / 256 x 384 (displayed at half size below)",f,Brushes.White,24,885);
  for(int i=0;i<3;i++){using(var c=Load(Path.Combine(root,"godot/assets/cards/hand/"+ids[i]+".png")))g.DrawImage(c,new Rectangle(24+i*158,935,128,192));}
  g.DrawString("No text is baked into delivered cards. Labels appear on this sheet only.",small,Brushes.White,526,950);
  Save(b,Path.Combine(root,"godot/screenshots/tavern-v07/card-sheet.png"));
 }}
}
'@
[TavernAssets]::Card($root,'dragon_breath','resin_torch','dragon_breath_artwork_v02.png',$true)
[TavernAssets]::Card($root,'frost_giant_spirit','frost_rune','frost_giant_spirit_artwork_v02.png',$true)
[TavernAssets]::Card($root,'cheers','drunk_rant','cheers_generated.png',$false)
[TavernAssets]::Decal($root,'fire_pool',512)
[TavernAssets]::Decal($root,'vomit_puddle',256)
[TavernAssets]::Ice($root)
[TavernAssets]::Sheet($root)
Write-Output 'Prepared 3 cards, 3 hand PNGs, 3 VFX textures and preview sheet.'
