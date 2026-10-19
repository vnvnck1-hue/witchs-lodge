param([string]$Root = (Get-Location).Path)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Collections.Generic;
public static class JobPictogramsV02 {
 static Color Ink=Color.FromArgb(42,26,18), Cream=Color.FromArgb(252,231,176), Silver=Color.FromArgb(201,206,214), Red=Color.FromArgb(200,80,60);
 static GraphicsPath Polygon(params float[] xy) {
  var p=new GraphicsPath(); var points=new PointF[xy.Length/2];
  for(int i=0;i<points.Length;i++) points[i]=new PointF(xy[i*2],xy[i*2+1]);
  p.AddPolygon(points); return p;
 }
 static GraphicsPath Curve(float[] start, params float[][] curves) {
  var p=new GraphicsPath(); float x=start[0],y=start[1];
  foreach(var c in curves){p.AddBezier(x,y,c[0],c[1],c[2],c[3],c[4],c[5]);x=c[4];y=c[5];}
  p.CloseFigure();return p;
 }
 public static int[] Bounds(Bitmap b,int threshold) {
  int l=b.Width,t=b.Height,r=-1,d=-1;
  for(int y=0;y<b.Height;y++)for(int x=0;x<b.Width;x++)if(b.GetPixel(x,y).A>=threshold){l=Math.Min(l,x);t=Math.Min(t,y);r=Math.Max(r,x);d=Math.Max(d,y);}
  return new int[]{l,t,r,d};
 }
 public static Bitmap Resize(Bitmap b,int w,int h) {
  var result=new Bitmap(w,h,PixelFormat.Format32bppArgb);
  using(var g=Graphics.FromImage(result))using(var attr=new ImageAttributes()){
   g.Clear(Color.Transparent);g.CompositingMode=CompositingMode.SourceCopy;
   g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;
   attr.SetWrapMode(WrapMode.TileFlipXY);
   g.DrawImage(b,new Rectangle(0,0,w,h),0,0,b.Width,b.Height,GraphicsUnit.Pixel,attr);
  } return result;
 }
 public static void Prepare(string name,string target) {
  // Manual contour cleanup of the generated PNG: remove fine bands/shine,
  // broaden bodies, shorten axe head, and unify all visible outlines to 11 logical px.
  var paths=new List<GraphicsPath>();var colors=new List<Color>();
  if(name=="warrior") {
   paths.Add(Curve(new float[]{54,86},new float[]{54,94,54,100,52,108},new float[]{49,120,79,120,76,108},new float[]{74,100,74,94,74,86})); colors.Add(Cream);
   paths.Add(Polygon(64,9,83,32,86,87,42,87,45,32));colors.Add(Silver);
   paths.Add(Curve(new float[]{10,83},new float[]{16,80,18,76,20,78},new float[]{30,87,41,86,64,86},new float[]{87,86,98,87,108,78},new float[]{110,76,112,80,118,83},new float[]{116,88,113,92,109,96},new float[]{92,93,80,94,64,94},new float[]{48,94,36,93,19,96},new float[]{15,92,12,88,10,83}));colors.Add(Cream);
  } else if(name=="hunter") {
   paths.Add(Curve(new float[]{79,10},new float[]{39,10,10,32,10,64},new float[]{10,96,39,118,79,118},new float[]{79,111,79,104,79,97},new float[]{50,97,31,84,31,64},new float[]{31,44,50,31,79,31},new float[]{79,24,79,17,79,10}));colors.Add(Cream);
   paths.Add(Polygon(73,10,85,10,85,118,73,118));colors.Add(Cream);
   paths.Add(Polygon(26,58,98,58,98,44,118,64,98,84,98,70,26,70));colors.Add(Cream);
  } else if(name=="lumberjack") {
   paths.Add(Curve(new float[]{81,48},new float[]{81,73,82,94,78,109},new float[]{74,122,112,122,108,109},new float[]{104,94,105,73,105,48}));colors.Add(Cream);
   paths.Add(Curve(new float[]{48,10},new float[]{26,14,10,25,10,40},new float[]{10,57,26,69,48,73},new float[]{39,62,40,52,50,48},new float[]{68,40,85,52,112,50},new float[]{119,46,119,30,112,26},new float[]{80,27,57,28,48,10}));colors.Add(Silver);
  } else {
   paths.Add(Curve(new float[]{48,60},new float[]{51,76,48,89,41,101},new float[]{26,123,102,123,87,101},new float[]{80,89,77,76,80,60}));colors.Add(Cream);
   paths.Add(Curve(new float[]{10,65},new float[]{16,35,39,10,64,10},new float[]{89,10,112,35,118,65},new float[]{122,84,88,72,64,72},new float[]{40,72,6,84,10,65}));colors.Add(Red);
  }
  using(var hi=new Bitmap(512,512,PixelFormat.Format32bppArgb)){
   using(var g=Graphics.FromImage(hi))using(var pen=new Pen(Ink,22)){
    g.Clear(Color.Transparent);g.ScaleTransform(4,4);g.SmoothingMode=SmoothingMode.AntiAlias;
    pen.LineJoin=LineJoin.Round;pen.StartCap=LineCap.Round;pen.EndCap=LineCap.Round;
    // Ink silhouettes first, then flat fills: no seams at connected component joins.
    foreach(var p in paths){using(var b=new SolidBrush(Ink))g.FillPath(b,p);g.DrawPath(pen,p);}
    for(int i=0;i<paths.Count;i++)using(var b=new SolidBrush(colors[i]))g.FillPath(b,paths[i]);
    // Filling over the inner half of the 22px stroke leaves 11px visible exterior ink.
    pen.Width=11;
    // One broad color boundary for blade/cap/head. These are large regions, no detail lines.
    if(name=="warrior")g.DrawLine(pen,43,81,85,81);
    if(name=="hunter"){
     using(var b=new SolidBrush(Silver))g.FillPolygon(b,new PointF[]{new PointF(99,47),new PointF(116,64),new PointF(99,81)});
    }
    if(name=="lumberjack")g.DrawLine(pen,79,52,107,52);
    if(name=="gatherer")g.DrawBezier(pen,44,74,54,71,74,71,84,74);
   }
   var box=Bounds(hi,1);
   using(var crop=hi.Clone(new Rectangle(box[0],box[1],box[2]-box[0]+1,box[3]-box[1]+1),PixelFormat.Format32bppArgb))
   using(var fit=Resize(crop,120,120))
   using(var final=new Bitmap(128,128,PixelFormat.Format32bppArgb)){
    using(var g=Graphics.FromImage(final)){g.Clear(Color.Transparent);g.CompositingMode=CompositingMode.SourceCopy;g.DrawImageUnscaled(fit,4,4);}
    // All fully covered pixels use exact palette. Edge AA alone retains mixed coverage.
    Color[] pal=new Color[]{Ink,Cream,name=="gatherer"?Red:Silver};
    for(int y=0;y<128;y++)for(int x=0;x<128;x++){
     var c=final.GetPixel(x,y);if(c.A==0)continue;
     int best=int.MaxValue;Color chosen=Ink;
     foreach(var p in pal){int d=(c.R-p.R)*(c.R-p.R)+(c.G-p.G)*(c.G-p.G)+(c.B-p.B)*(c.B-p.B);if(d<best){best=d;chosen=p;}}
     // Preserve RGB blending at antialiased internal boundaries as smooth edge coverage.
     if(c.A==255 && best<2200)final.SetPixel(x,y,Color.FromArgb(c.A,chosen));
    }
    final.Save(target,ImageFormat.Png);
   }
  }
  foreach(var p in paths)p.Dispose();
 }
 public static Bitmap Silhouette(Bitmap b) {
  var result=new Bitmap(b.Width,b.Height,PixelFormat.Format32bppArgb);
  for(int y=0;y<b.Height;y++)for(int x=0;x<b.Width;x++)result.SetPixel(x,y,Color.FromArgb(b.GetPixel(x,y).A,0,0,0));
  return result;
 }
 public static int Components(Bitmap b) {
  bool[,] seen=new bool[b.Width,b.Height];int n=0;
  for(int y=0;y<b.Height;y++)for(int x=0;x<b.Width;x++)if(!seen[x,y]&&b.GetPixel(x,y).A>=128){
   n++;var q=new Queue<Point>();q.Enqueue(new Point(x,y));seen[x,y]=true;
   while(q.Count>0){var p=q.Dequeue();for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){
    int xx=p.X+dx,yy=p.Y+dy;if(xx>=0&&yy>=0&&xx<b.Width&&yy<b.Height&&!seen[xx,yy]&&b.GetPixel(xx,yy).A>=128){seen[xx,yy]=true;q.Enqueue(new Point(xx,yy));}
   }}
  }return n;
 }
}
'@
$names=@('warrior','hunter','lumberjack','gatherer')
$badgeColors=@('#FF8573','#8CEBB3','#FFC766','#C7B8FF')
$rows=@()
foreach($name in $names){
 $target=Join-Path $Root "godot/assets/ui/jobs/$name.png"
 [JobPictogramsV02]::Prepare($name,$target)
 Copy-Item -LiteralPath $target -Destination (Join-Path $Root "art/ui/job-pictograms-v02/$name.png")
 $img=[System.Drawing.Bitmap]::FromFile($target)
 try {
  $bounds=[JobPictogramsV02]::Bounds($img,1)
  $opaque=[JobPictogramsV02]::Bounds($img,255)
  $corners=@($img.GetPixel(0,0).A,$img.GetPixel(127,0).A,$img.GetPixel(0,127).A,$img.GetPixel(127,127).A)
  $margin=@($bounds[0],$bounds[1],(127-$bounds[2]),(127-$bounds[3]))
  $bw=$opaque[2]-$opaque[0]+1; $bh=$opaque[3]-$opaque[1]+1
  $png=[IO.File]::ReadAllBytes($target)
  $parts=[JobPictogramsV02]::Components($img)
  $passed=$img.Width -eq 128 -and $img.Height -eq 128 -and $png[25] -eq 6 -and ($corners|Measure-Object -Sum).Sum -eq 0 -and $bw -ge 116 -and $bh -ge 116 -and ($margin|Measure-Object -Maximum).Maximum -le 4 -and $parts -eq 1
  $rows += [ordered]@{path="godot/assets/ui/jobs/$name.png";width=128;height=128;channels='RGBA';png_color_type=[int]$png[25];corner_alpha=$corners;alpha_bounds_inclusive=$bounds;opaque_bounds_inclusive=$opaque;opaque_bounds_size=@($bw,$bh);transparent_margins_ltrb=$margin;connected_components=$parts;sha256=(Get-FileHash -LiteralPath $target).Hash.ToLowerInvariant();passed=$passed}
 }finally{$img.Dispose()}
}
$sheet=[Drawing.Bitmap]::new(1040,800)
$g=[Drawing.Graphics]::FromImage($sheet)
$g.Clear([Drawing.ColorTranslator]::FromHtml('#171322'))
$g.SmoothingMode=[Drawing.Drawing2D.SmoothingMode]::AntiAlias
$font=[Drawing.Font]::new('Segoe UI',10)
$title=[Drawing.Font]::new('Segoe UI',19,[Drawing.FontStyle]::Bold)
$light=[Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml('#FCE7B0'))
$muted=[Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml('#B9AEC7'))
$g.DrawString("WITCH'S LODGE / JOB PICTOGRAMS v02",$title,$light,28,16)
$g.DrawString('One bold connected silhouette / 128px originals and actual-size readability checks',$font,$muted,28,52)
$labels=@('128 px / transparent','16 px / badge','20 px / badge','24 px / badge','20 px / black silhouette','20 px / v01 then v02','20 px / v02 enlarged 4x')
$ys=@(110,300,357,414,480,554,640)
for($r=0;$r -lt $labels.Length;$r++){$g.DrawString($labels[$r],$font,$muted,24,$ys[$r]+4)}
for($i=0;$i -lt 4;$i++){
 $x=260+190*$i
 $g.DrawString($names[$i],$font,$light,$x,83)
 $img=[Drawing.Bitmap]::FromFile((Join-Path $Root "godot/assets/ui/jobs/$($names[$i]).png"))
 $old=[Drawing.Bitmap]::FromFile((Join-Path $Root "art/ui/job-pictograms-v02/drafts/$($names[$i]).png"))
 try {
  for($cy=0;$cy -lt 8;$cy++){for($cx=0;$cx -lt 8;$cx++){
   $shade=if(($cx+$cy)%2 -eq 0){'#36303F'}else{'#282331'}
   $b=[Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($shade))
   $g.FillRectangle($b,$x+$cx*16,110+$cy*16,16,16);$b.Dispose()
  }}
  $g.DrawImageUnscaled($img,$x,110)
  $base=[Drawing.ColorTranslator]::FromHtml($badgeColors[$i])
  $dark=[Drawing.Color]::FromArgb([int][Math]::Round($base.R*.65),[int][Math]::Round($base.G*.65),[int][Math]::Round($base.B*.65))
  $b=[Drawing.SolidBrush]::new($dark)
  $g.DrawString($badgeColors[$i]+' x 0.65',$font,$muted,$x,252)
  $sizes=@(16,20,24)
  for($r=0;$r -lt 3;$r++){
   $sz=$sizes[$r];$y=$ys[$r+1]
   $g.FillEllipse($b,$x,$y,32,32)
   $tiny=[JobPictogramsV02]::Resize($img,$sz,$sz)
   $g.DrawImageUnscaled($tiny,$x+[int]((32-$sz)/2),$y+[int]((32-$sz)/2));$tiny.Dispose()
  }
  $sil=[JobPictogramsV02]::Silhouette($img);$tiny=[JobPictogramsV02]::Resize($sil,20,20)
  $white=[Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(237,228,213))
  $g.FillRectangle($white,$x,480,32,32);$g.DrawImageUnscaled($tiny,$x+6,486)
  $white.Dispose();$sil.Dispose();$tiny.Dispose()
  $j=0
  foreach($item in @($old,$img)){
   $tiny=[JobPictogramsV02]::Resize($item,20,20)
   $g.FillEllipse($b,$x+$j*52,554,32,32);$g.DrawImageUnscaled($tiny,$x+$j*52+6,560)
   $tiny.Dispose();$j++
  }
  $tiny=[JobPictogramsV02]::Resize($img,20,20)
  $g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  $g.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::Half
  $g.FillEllipse($b,$x,640,104,104)
  $g.DrawImage($tiny,[Drawing.Rectangle]::new($x+12,652,80,80),0,0,20,20,[Drawing.GraphicsUnit]::Pixel)
  $tiny.Dispose();$b.Dispose()
 }finally{$img.Dispose();$old.Dispose()}
}
$g.DrawString('Circles/checkerboards are preview only. PNGs contain no badge background. 16 / 20 / 24 rows are actual pixel sizes.',$font,$muted,24,770)
$g.Dispose();$font.Dispose();$title.Dispose();$light.Dispose();$muted.Dispose()
$sheet.Save((Join-Path $Root 'godot/screenshots/party-frames/job-pictograms-v02-sheet.png'),[Drawing.Imaging.ImageFormat]::Png);$sheet.Dispose()
$report=[ordered]@{generated_at='2026-10-19';generator='built-in image_gen.imagegen';generation_calls=4;references_per_call=3;transparent_background=$true;postprocessing='Manual Bezier contour cleanup of generated shapes, 11px outer ink, no fine detail, 120x120 fit at (4,4), palette flattening with edge antialiasing.';files=$rows;visual_review=[ordered]@{passed=$false;status='pending sheet inspection'};godot_import=[ordered]@{exit_code=$null;status='pending'};passed=$false}
$report|ConvertTo-Json -Depth 8|Set-Content -Encoding UTF8 (Join-Path $Root 'output/job-pictograms-v02/verification.json')
$rows|ForEach-Object{[pscustomobject]$_}|Format-Table path,opaque_bounds_size,transparent_margins_ltrb,connected_components,passed

