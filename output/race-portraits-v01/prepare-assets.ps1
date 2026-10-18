param([switch]$VerifyOnly)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$manifestPath = Join-Path $PSScriptRoot 'generation-manifest.json'
$jobs = Get-Content -Raw -Encoding UTF8 $manifestPath | ConvertFrom-Json
if (-not ('RacePortraitPixels' -as [type])) {
Add-Type -TypeDefinition @'
public static class RacePortraitPixels {
 public static int[] Scan(byte[] b,int w,int h,int stride) {
  int l=w,t=h,r=-1,bt=-1,clear=0,solid=0,edge=0;
  for(int y=0;y<h;y++) for(int x=0;x<w;x++) {
   int a=b[y*stride+x*4+3];
   if(a==0)clear++; if(a==255)solid++;
   if(x==0||y==0||x==w-1||y==h-1)edge=System.Math.Max(edge,a);
   if(a>8){l=System.Math.Min(l,x);t=System.Math.Min(t,y);r=System.Math.Max(r,x);bt=System.Math.Max(bt,y);}
  }
  return new int[]{l,t,r,bt,clear,solid,edge};
 }
}
'@
}
function Get-ImageRecord($path) {
 $b=[System.Drawing.Bitmap]::new($path)
 try {
  $rect=[System.Drawing.Rectangle]::new(0,0,$b.Width,$b.Height)
  $d=$b.LockBits($rect,[System.Drawing.Imaging.ImageLockMode]::ReadOnly,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  try { $bytes=[byte[]]::new($d.Stride*$d.Height); [Runtime.InteropServices.Marshal]::Copy($d.Scan0,$bytes,0,$bytes.Length); $v=[RacePortraitPixels]::Scan($bytes,$b.Width,$b.Height,$d.Stride) } finally {$b.UnlockBits($d)}
  $header=[IO.File]::ReadAllBytes($path)
  $m=@($v[0],$v[1],($b.Width-1-$v[2]),($b.Height-1-$v[3]))
  [ordered]@{path=$path.Substring($root.Length+1).Replace('\','/');width=$b.Width;height=$b.Height;png_bit_depth=$header[24];png_color_type=$header[25];channels=4;mode='RGBA';bounds_alpha_gt_8=@($v[0],$v[1],$v[2],$v[3]);margins_pixels=$m;margins_fraction=@(($m[0]/$b.Width),($m[1]/$b.Height),($m[2]/$b.Width),($m[3]/$b.Height));fully_transparent_pixels=$v[4];fully_opaque_pixels=$v[5];edge_alpha_max=$v[6];sha256=(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash;passed=($b.Width-eq1122 -and $b.Height-eq1402 -and $header[25]-eq6 -and $v[4]-gt0 -and $v[5]-gt0 -and $m[0]-ge68 -and $m[2]-ge68 -and $m[1]-ge85 -and $m[3]-ge85 -and $v[6]-le8)}
 } finally {$b.Dispose()}
}
$records=@()
foreach($job in $jobs) {
 $source=Join-Path $root "art/portraits/card-style-v01/races/$($job.id).png"
 $runtime=Join-Path $root "godot/assets/portraits/guest_$($job.id)_cutout.png"
 if(-not $VerifyOnly) {
  Copy-Item -LiteralPath $job.generated_path -Destination $source
  $src=[System.Drawing.Bitmap]::new($source)
  $dst=[System.Drawing.Bitmap]::new(1122,1402,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g=[System.Drawing.Graphics]::FromImage($dst)
  try {
   $g.Clear([System.Drawing.Color]::Transparent)
   $g.CompositingMode=[System.Drawing.Drawing2D.CompositingMode]::SourceCopy
   $g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
   $g.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
   # Scale the ENTIRE native canvas uniformly. No crop, segmentation, repaint or alpha removal.
   $scale=[Math]::Min(984.0/$src.Width,1230.0/$src.Height)
   $w=[int][Math]::Floor($src.Width*$scale); $h=[int][Math]::Floor($src.Height*$scale)
   $x=[int][Math]::Floor((1122-$w)/2);$y=[int][Math]::Floor((1402-$h)/2)
   $g.DrawImage($src,[System.Drawing.Rectangle]::new($x,$y,$w,$h),0,0,$src.Width,$src.Height,[System.Drawing.GraphicsUnit]::Pixel)
   $dst.Save($runtime,[System.Drawing.Imaging.ImageFormat]::Png)
  } finally {$g.Dispose();$dst.Dispose();$src.Dispose()}
 }
 $native=[System.Drawing.Bitmap]::new($source)
 try {$nativeInfo=@{path=$source.Substring($root.Length+1).Replace('\','/');width=$native.Width;height=$native.Height;sha256=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash;matches_generated=((Get-FileHash -LiteralPath $source).Hash-eq(Get-FileHash -LiteralPath $job.generated_path).Hash)}} finally {$native.Dispose()}
 $records+=@{id=$job.id;race=$job.race;runtime=(Get-ImageRecord $runtime);source=$nativeInfo;visual_review=$job.visual_review}
}
$expectedIds=@('harald','brynhild','thorgrim','durga','ormu','ketil','signy','thistle','tilia','larch','fern','willow','pip','nivel','graz','pikl','rusk','tak','nib','grik','mala','fargh','saya','urso','momi','luka','tass','selen','garok','kranya','moga','shaga','ulma','bardu','eshka')
$actualIds=@($records | ForEach-Object {$_.id})
$idSetPassed=(@(Compare-Object $expectedIds $actualIds).Count-eq0 -and @($actualIds | Select-Object -Unique).Count-eq35)
$runtimeUnique=@($records | ForEach-Object {$_.runtime.sha256} | Select-Object -Unique).Count
$sourceUnique=@($records | ForEach-Object {$_.source.sha256} | Select-Object -Unique).Count
$raceCounts=@{}; $records | ForEach-Object {[pscustomobject]$_} | Group-Object race | ForEach-Object {$raceCounts[$_.Name]=$_.Count}
$passed=($records.Count-eq35 -and $idSetPassed -and $runtimeUnique-eq35 -and $sourceUnique-eq35 -and @($raceCounts.Values | Where-Object {$_-ne7}).Count-eq0 -and @($records | Where-Object {-not $_.runtime.passed -or -not $_.source.matches_generated -or -not $_.visual_review.passed}).Count-eq0)
$report=[ordered]@{schema='race-portraits-v01';created_at=(Get-Date -Format o);expected_count=35;actual_count=$records.Count;id_set_passed=$idSetPassed;race_counts=$raceCounts;unique_runtime_sha256_count=$runtimeUnique;unique_source_sha256_count=$sourceUnique;alpha_threshold=8;minimum_margin_fraction=0.06;processing='Native originals preserved byte-for-byte; runtime uniformly fits the entire canvas inside 984x1230 on a transparent 1122x1402 RGBA canvas. No content cropping or alpha extraction.';records=$records;passed=$passed}
$report | ConvertTo-Json -Depth 12 | Set-Content -Encoding UTF8 (Join-Path $PSScriptRoot 'asset-verification.json')
$sheet=[System.Drawing.Bitmap]::new(2100,2110)
$g=[System.Drawing.Graphics]::FromImage($sheet)
$font=[System.Drawing.Font]::new('Arial',15)
$heading=[System.Drawing.Font]::new('Arial',17,[System.Drawing.FontStyle]::Bold)
try {
 $g.Clear([System.Drawing.Color]::FromArgb(37,34,42));$g.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
 for($i=0;$i-lt$jobs.Count;$i++) {
  $col=$i%7;$row=[int][Math]::Floor($i/7);$x=$col*300;$y=$row*422
  if($col-eq0){$g.DrawString($jobs[$i].race,$heading,[System.Drawing.Brushes]::Wheat,$x+10,$y+3)}
  $b=[System.Drawing.Bitmap]::new((Join-Path $root "godot/assets/portraits/guest_$($jobs[$i].id)_cutout.png"))
  try {$g.DrawImage($b,[System.Drawing.Rectangle]::new($x+6,$y+30,288,360))} finally {$b.Dispose()}
  $g.DrawString($jobs[$i].id,$font,[System.Drawing.Brushes]::White,$x+12,$y+391)
 }
 $sheet.Save((Join-Path $root 'godot/screenshots/races/portrait-sheet.png'),[System.Drawing.Imaging.ImageFormat]::Png)
} finally {$g.Dispose();$font.Dispose();$heading.Dispose();$sheet.Dispose()}
[ordered]@{expected_count=35;actual_count=$records.Count;passed=$passed} | ConvertTo-Json -Compress
