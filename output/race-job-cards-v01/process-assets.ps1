param([switch]$VerifyOnly)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$jobs=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'generation-manifest.json') | ConvertFrom-Json
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
public static class RaceJobPixels {
 public static byte[] Bytes(Bitmap b) {
  var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
  try {var p=new byte[d.Stride*b.Height];Marshal.Copy(d.Scan0,p,0,p.Length);return p;}finally{b.UnlockBits(d);}
 }
 public static string Hash(byte[] p) {using(var h=SHA256.Create())return BitConverter.ToString(h.ComputeHash(p)).Replace("-","").ToLowerInvariant();}
 public static Rectangle Title(string job){return job=="warrior"?new Rectangle(290,60,450,130):job=="hunter"?new Rectangle(295,60,435,137):job=="lumberjack"?new Rectangle(308,60,416,131):new Rectangle(325,60,378,128);}
 public static Rectangle Category(string job){return job=="warrior"?new Rectangle(356,190,315,52):job=="hunter"?new Rectangle(332,200,364,56):job=="lumberjack"?new Rectangle(340,193,350,53):new Rectangle(350,185,332,59);}
 public static byte[] Crop(Bitmap b,Rectangle r){using(var c=b.Clone(r,PixelFormat.Format32bppArgb)){var p=Bytes(c);for(int i=3;i<p.Length;i+=4)p[i]=255;return p;}}
 public static string TextHash(Bitmap b,string job){var a=Crop(b,Title(job));var c=Crop(b,Category(job));var d=Crop(b,new Rectangle(100,1180,824,240));var all=new byte[a.Length+c.Length+d.Length];Buffer.BlockCopy(a,0,all,0,a.Length);Buffer.BlockCopy(c,0,all,a.Length,c.Length);Buffer.BlockCopy(d,0,all,a.Length+c.Length,d.Length);return Hash(all);}
 public static bool BadgeMask(int x,int y){
  double a=(x-512.0)/88.0,b=(y-1006.0)/72.0;
  bool medal=a*a+b*b<=1;
  // Rounded nameplate union, matching the current warrior badge footprint.
  double cx=Math.Max(406,Math.Min(618,x)),cy=Math.Max(1078,Math.Min(1080,y));
  bool plate=x>=348&&x<=676&&y>=1020&&y<=1138&&((x-cx)*(x-cx)+(y-cy)*(y-cy)<=58*58);
  return medal||plate;
 }
 public static string BadgeHash(Bitmap b){var p=Bytes(b);var v=new System.Collections.Generic.List<byte>();for(int y=934;y<=1138;y++)for(int x=348;x<=676;x++)if(BadgeMask(x,y)){int i=(y*b.Width+x)*4;v.Add(p[i]);v.Add(p[i+1]);v.Add(p[i+2]);v.Add(p[i+3]);}return Hash(v.ToArray());}
 public static bool[] PanelMask(Bitmap b,int seedX,int seedY){
  int w=b.Width,h=b.Height;var pixels=Bytes(b);var mask=new bool[w*h];var q=new System.Collections.Generic.Queue<int>();
  int seed=seedY*w+seedX;mask[seed]=true;q.Enqueue(seed);
  while(q.Count>0){int i=q.Dequeue(),x=i%w,y=i/w;int[] ns={x>0?i-1:-1,x<w-1?i+1:-1,y>0?i-w:-1,y<h-1?i+w:-1};foreach(int n in ns)if(n>=0&&!mask[n]){int p=n*4;int blue=pixels[p],green=pixels[p+1],red=pixels[p+2];if(red>170&&green>140&&blue>85&&red>green&&green>blue){mask[n]=true;q.Enqueue(n);}}}
  // Fill enclosed type holes, while the artwork and projecting badge stay connected to the exterior.
  var exterior=new bool[w*h];q.Clear();
  for(int x=0;x<w;x++){if(!mask[x]){exterior[x]=true;q.Enqueue(x);}int k=(h-1)*w+x;if(!mask[k]){exterior[k]=true;q.Enqueue(k);}}
  for(int y=0;y<h;y++){int a=y*w,z=a+w-1;if(!mask[a]&&!exterior[a]){exterior[a]=true;q.Enqueue(a);}if(!mask[z]&&!exterior[z]){exterior[z]=true;q.Enqueue(z);}}
  while(q.Count>0){int i=q.Dequeue(),x=i%w,y=i/w;int[] ns={x>0?i-1:-1,x<w-1?i+1:-1,y>0?i-w:-1,y<h-1?i+w:-1};foreach(int n in ns)if(n>=0&&!mask[n]&&!exterior[n]){exterior[n]=true;q.Enqueue(n);}}
  for(int i=0;i<mask.Length;i++)if(!exterior[i])mask[i]=true;
  // Extend two pixels into the existing panel outline for a natural ink boundary.
  var result=(bool[])mask.Clone();for(int y=2;y<h-2;y++)for(int x=2;x<w-2;x++)if(mask[y*w+x])for(int dy=-2;dy<=2;dy++)for(int dx=-2;dx<=2;dx++)result[(y+dy)*w+x+dx]=true;
  return result;
 }
 public static void Process(string source,string human,string canonical,string job,string output,string hand){
  using(var src=new Bitmap(source))using(var tpl=new Bitmap(human))using(var badge=new Bitmap(canonical))using(var dst=new Bitmap(1024,1536,PixelFormat.Format32bppArgb)) {
   using(var g=Graphics.FromImage(dst)) {g.CompositingMode=CompositingMode.SourceCopy;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.DrawImage(src,new Rectangle(0,0,1024,1536));}
   // Copy whole connected cream panels, including type holes; never paste rectangular type patches.
   var p=Bytes(dst);var t=Bytes(tpl);var c=Bytes(badge);var top=PanelMask(tpl,512,50);var bottom=PanelMask(tpl,512,1450);
   for(int y=0;y<1536;y++)for(int x=0;x<1024;x++) {
    int i=(y*1024+x)*4;
    if(top[y*1024+x]||bottom[y*1024+x]) Buffer.BlockCopy(t,i,p,i,4);
    if(BadgeMask(x,y)) Buffer.BlockCopy(c,i,p,i,4);
    // Card stock is opaque; only rounded exterior corners are transparent.
    p[i+3]=255;
    // 56 px radius, 4x4 supersampling: preserve RGB, change only corner alpha.
    if((x<56||x>=968)&&(y<56||y>=1480)) {
     double cx=x<56?56:968,cy=y<56?56:1480;int n=0;
     for(int sy=0;sy<4;sy++)for(int sx=0;sx<4;sx++){double dx=x+(sx+.5)/4-cx,dy=y+(sy+.5)/4-cy;if(dx*dx+dy*dy<=56*56)n++;}
     p[i+3]=(byte)(p[i+3]*n/16);
    }
   }
   var data=dst.LockBits(new Rectangle(0,0,1024,1536),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);try{Marshal.Copy(p,0,data.Scan0,p.Length);}finally{dst.UnlockBits(data);}
   dst.Save(output,ImageFormat.Png);
   using(var small=new Bitmap(256,384,PixelFormat.Format32bppArgb))using(var g=Graphics.FromImage(small)) {
    g.CompositingMode=CompositingMode.SourceCopy;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;
    using(var ia=new ImageAttributes()){ia.SetWrapMode(WrapMode.TileFlipXY);g.DrawImage(dst,new Rectangle(0,0,256,384),0,0,1024,1536,GraphicsUnit.Pixel,ia);}
    small.Save(hand,ImageFormat.Png);
   }
  }
 }
 public static int[] Alpha(Bitmap b){var p=Bytes(b);int clear=0,solid=0;for(int i=3;i<p.Length;i+=4){if(p[i]==0)clear++;if(p[i]==255)solid++;}return new int[]{b.GetPixel(0,0).A,b.GetPixel(b.Width-1,0).A,b.GetPixel(0,b.Height-1).A,b.GetPixel(b.Width-1,b.Height-1).A,clear,solid};}
}
'@
function File-Record($relative,$width,$height) {
 $path=Join-Path $root $relative; $b=[Drawing.Bitmap]::new($path)
 try {$a=[RaceJobPixels]::Alpha($b);$header=[IO.File]::ReadAllBytes($path);[ordered]@{path=$relative;width=$b.Width;height=$b.Height;mode='RGBA';channels=4;png_bit_depth=$header[24];png_color_type=$header[25];corner_alpha=@($a[0],$a[1],$a[2],$a[3]);transparent_pixels=$a[4];opaque_pixels=$a[5];sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant();passed=($b.Width-eq$width-and$b.Height-eq$height-and$header[25]-eq6-and($a[0]+$a[1]+$a[2]+$a[3])-eq0-and$a[4]-gt0-and$a[5]-gt0)}} finally{$b.Dispose()}
}
$records=@()
foreach($j in $jobs) {
 $source='art/cards/races-v01/'+$j.race+'-'+$j.job+'.png'
 $game='godot/assets/cards/races/'+$j.race+'/'+$j.job+'.png'
 $hand='godot/assets/cards/races/'+$j.race+'/hand/'+$j.job+'.png'
 if(-not $VerifyOnly) {
  New-Item -ItemType Directory -Force -Path (Split-Path (Join-Path $root $game)),(Split-Path (Join-Path $root $hand)) | Out-Null
  [RaceJobPixels]::Process((Join-Path $root $source),(Join-Path $root ('godot/assets/cards/'+$j.job+'.png')),(Join-Path $root ('art/cards/races-v01/'+$j.race+'-warrior.png')),$j.job,(Join-Path $root $game),(Join-Path $root $hand))
 }
 $b=[Drawing.Bitmap]::new((Join-Path $root $game));$t=[Drawing.Bitmap]::new((Join-Path $root ('godot/assets/cards/'+$j.job+'.png')))
 try {$textHash=[RaceJobPixels]::TextHash($b,$j.job);$templateHash=[RaceJobPixels]::TextHash($t,$j.job);$badgeHash=[RaceJobPixels]::BadgeHash($b)}finally{$b.Dispose();$t.Dispose()}
 $records+= [ordered]@{id=($j.race+'-'+$j.job);person=$j.id;race=$j.race;job=$j.job;source=@{path=$source;sha256=(Get-FileHash -LiteralPath (Join-Path $root $source)).Hash.ToLowerInvariant();matches_generated=((Get-FileHash -LiteralPath (Join-Path $root $source)).Hash-eq(Get-FileHash -LiteralPath $j.generated_path).Hash)};game=(File-Record $game 1024 1536);hand=(File-Record $hand 256 384);text=$j.text;race_name=$j.race_name;text_pixels_sha256=$textHash;human_text_pixels_sha256=$templateHash;text_pixels_identical=($textHash-eq$templateHash);badge_pixels_sha256=$badgeHash;visual_review=$j.visual_review}
}
foreach($record in $records){
 $archivePath=Join-Path $root $record.source.path;$native=[Drawing.Bitmap]::new($archivePath)
 try{$header=[IO.File]::ReadAllBytes($archivePath);$record.source.width=$native.Width;$record.source.height=$native.Height;$record.source.mode='RGBA';$record.source.channels=4;$record.source.png_bit_depth=$header[24];$record.source.png_color_type=$header[25];$record.source.corner_alpha=@($native.GetPixel(0,0).A,$native.GetPixel($native.Width-1,0).A,$native.GetPixel(0,$native.Height-1).A,$native.GetPixel($native.Width-1,$native.Height-1).A);$record.source.archive_role='Unmodified native generation, before runtime corner/panel processing.'}finally{$native.Dispose()}
}
$badgeChecks=@($records | ForEach-Object {[pscustomobject]$_} | Group-Object race | ForEach-Object {[ordered]@{race=$_.Name;cards=$_.Count;unique_badge_hashes=@($_.Group.badge_pixels_sha256 | Select-Object -Unique).Count;passed=(@($_.Group.badge_pixels_sha256 | Select-Object -Unique).Count-eq1)}})
$passed=($records.Count-eq20-and@($records | Where-Object {-not $_.game.passed-or-not $_.hand.passed-or-not $_.source.matches_generated-or-not $_.text_pixels_identical-or-not $_.visual_review.passed}).Count-eq0-and@($badgeChecks | Where-Object {-not $_.passed}).Count-eq0)
$uniqueGame=@($records | ForEach-Object {$_.game.sha256} | Select-Object -Unique).Count
$uniqueHand=@($records | ForEach-Object {$_.hand.sha256} | Select-Object -Unique).Count
$uniqueSource=@($records | ForEach-Object {$_.source.sha256} | Select-Object -Unique).Count
$reference=$null;$import=$null;$engine=$null
if(Test-Path -LiteralPath (Join-Path $PSScriptRoot 'reference-verification.json')){$reference=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'reference-verification.json') | ConvertFrom-Json}
if(Test-Path -LiteralPath (Join-Path $PSScriptRoot 'godot-import-result.json')){$import=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'godot-import-result.json') | ConvertFrom-Json}
if(Test-Path -LiteralPath (Join-Path $PSScriptRoot 'godot-import-verification.json')){$engine=Get-Content -Raw -Encoding UTF8 (Join-Path $PSScriptRoot 'godot-import-verification.json') | ConvertFrom-Json}
$engineBindings=@();foreach($record in $records){foreach($asset in @($record.game,$record.hand)){$resPath='res://'+$asset.path.Substring(6);$engineRecord=@($engine.records | Where-Object {$_.path-eq$resPath});$engineBindings+=@{path=$asset.path;source_png_sha256=$asset.sha256;imported_from_png_sha256=$engineRecord[0].source_png_sha256;passed=($engineRecord.Count-eq1-and$engineRecord[0].source_png_sha256-eq$asset.sha256)}}}
$passed=($passed-and$uniqueGame-eq20-and$uniqueHand-eq20-and$uniqueSource-eq20-and$reference.passed-and$import.passed-and$engine.passed-and$engine.count-eq40-and@($engineBindings | Where-Object {-not $_.passed}).Count-eq0)
[ordered]@{schema='race-job-cards-v01';created_at=(Get-Date -Format o);expected_count=20;actual_count=$records.Count;unique_source_sha256_count=$uniqueSource;unique_game_sha256_count=$uniqueGame;unique_hand_sha256_count=$uniqueHand;reference_input_calls=$reference.count;reference_inputs_passed=$reference.passed;godot_import_exit_code=$import.import_exit_code;godot_texture_load_count=$engine.count;godot_texture_load_passed=$engine.passed;godot_source_bindings=$engineBindings;processing='Native generated originals retained byte-for-byte. Runtime: connected cream title/class/rules panel contours and enclosed type holes restored from the original job card RGB, with 2px ink-edge padding; interior alpha normalized to 255 (some human references contain alpha 254); one generated warrior badge per race shared by a fixed union mask; 56px supersampled corner alpha; 256x384 uniform bicubic downsample. Text hashes normalize alpha to 255. No portrait cut-and-paste or painted/recolored character.';badge_checks=$badgeChecks;records=$records;passed=$passed} | ConvertTo-Json -Depth 15 | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'verification.json')
# Human reference first row, then five race rows, four job columns; preserve 2:3 throughout.
$sheet=[Drawing.Bitmap]::new(1504,3556);$g=[Drawing.Graphics]::FromImage($sheet);$font=[Drawing.Font]::new('Malgun Gothic',18);$heading=[Drawing.Font]::new('Malgun Gothic',20,[Drawing.FontStyle]::Bold)
try {
 $g.Clear([Drawing.Color]::FromArgb(31,27,39));$g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
 $races=@('human','dwarf','fairy','goblin','beastfolk','orc');$types=@('warrior','hunter','lumberjack','gatherer')
 for($row=0;$row-lt6;$row++){for($col=0;$col-lt4;$col++){
  $x=16+$col*372;$y=12+$row*590;$race=$races[$row];$job=$types[$col];$p=if($row-eq0){'godot/assets/cards/'+$job+'.png'}else{'godot/assets/cards/races/'+$race+'/'+$job+'.png'}
  $label=$race+' / '+$job;$g.DrawString($label,$font,[Drawing.Brushes]::Wheat,$x,$y)
  $im=[Drawing.Bitmap]::new((Join-Path $root $p));try{$g.DrawImage($im,[Drawing.Rectangle]::new($x,$y+36,352,528))}finally{$im.Dispose()}
 }}
 $sheet.Save((Join-Path $root 'godot/screenshots/race-job-cards/sheet.png'),[Drawing.Imaging.ImageFormat]::Png)
}finally{$heading.Dispose();$font.Dispose();$g.Dispose();$sheet.Dispose()}
Write-Output ('Cards: '+$records.Count+'; passed='+$passed)
if(-not $passed){exit 1}
