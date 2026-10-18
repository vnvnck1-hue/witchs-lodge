param([int]$InkLimit = 100)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
public static class PropEdgeGeometry {
 public static int[] Trace(byte[] rgb, int w, int h, int limit, int[] seeds, bool flame, bool gold, int[] guard, int margin) {
  int n=w*h; var ink=new bool[n]; var block=new bool[n]; var outside=new bool[n];
  for(int p=0;p<n;p++) { int r=rgb[p*3],g=rgb[p*3+1],b=rgb[p*3+2];
   ink[p]=Math.Max(r,Math.Max(g,b))<limit && (r*0.2126+g*0.7152+b*0.0722)<55; }
  for(int y=1;y<h-1;y++) for(int x=1;x<w-1;x++) {
   int p=y*w+x;
   for(int dy=-1;dy<=1;dy++) for(int dx=-1;dx<=1;dx++) if(ink[p+dy*w+dx]) block[p]=true;
  }
  var q=new Queue<int>();
  for(int x=0;x<w;x++) { outside[x]=outside[(h-1)*w+x]=true; q.Enqueue(x);q.Enqueue((h-1)*w+x); }
  for(int y=1;y<h-1;y++) { outside[y*w]=outside[y*w+w-1]=true;q.Enqueue(y*w);q.Enqueue(y*w+w-1); }
  int[] delta={-1,1,-w,w};
  while(q.Count>0) { int p=q.Dequeue(); foreach(int d in delta) { int t=p+d;
    if(t<0||t>=n||Math.Abs(t%w-p%w)>1||outside[t]||block[t]) continue;outside[t]=true;q.Enqueue(t); } }
  var keep=new bool[n];
  for(int s=0;s<seeds.Length;s+=2) {
   int p=seeds[s+1]*w+seeds[s]; if(p<0||p>=n||outside[p]||keep[p]) continue;keep[p]=true;q.Enqueue(p);
   while(q.Count>0) { int t=q.Dequeue();foreach(int d in delta) { int u=t+d;
    if(u<0||u>=n||Math.Abs(u%w-t%w)>1||outside[u]||keep[u]) continue;keep[u]=true;q.Enqueue(u); } }
  }
  // Retain the original warm flame above the inked candle outline.
  if(flame) for(int y=0;y<65 && y<h;y++) for(int x=35;x<80 && x<w;x++) {
   int p=y*w+x;int r=rgb[p*3],g=rgb[p*3+1],b=rgb[p*3+2];
   if(r>135&&g>65&&b<r*0.8) keep[p]=true;
  }
  if(guard.Length>0) for(int y=0;y<h;y++) for(int x=0;x<w;x++) {
   int p=y*w+x;if(!keep[p])continue;bool inside=false;double best=1e9;
   for(int i=0,j=guard.Length-2;i<guard.Length;j=i,i+=2) {
    double ax=guard[j],ay=guard[j+1],bx=guard[i],by=guard[i+1];
    if((ay>y)!=(by>y) && x<(bx-ax)*(y-ay)/(by-ay)+ax)inside=!inside;
    double dx=bx-ax,dy=by-ay, t=Math.Max(0,Math.Min(1,((x-ax)*dx+(y-ay)*dy)/Math.Max(1,dx*dx+dy*dy)));
    double ex=x-ax-t*dx,ey=y-ay-t*dy;best=Math.Min(best,ex*ex+ey*ey);
   }
   if(!inside&&best>margin*margin) keep[p]=false;
  }
  if(gold) {
   var metal=new bool[n];
   for(int p=0;p<n;p++) {int r=rgb[p*3],g=rgb[p*3+1],b=rgb[p*3+2];metal[p]=r>50&&r>g*1.2&&r>b*1.05;}
   for(int y=0;y<h;y++) for(int x=0;x<w;x++) {int p=y*w+x;keep[p]=false;
    for(int dy=-2;dy<=2;dy++) for(int dx=-2;dx<=2;dx++) {
     int xx=x+dx,yy=y+dy;if(xx>=0&&xx<w&&yy>=0&&yy<h&&dx*dx+dy*dy<=4&&metal[yy*w+xx]) keep[p]=true;
    }
   }
  } else {
   var clean=(bool[])keep.Clone();
   for(int y=1;y<h-1;y++) for(int x=1;x<w-1;x++) {int p=y*w+x;
    if(keep[p]&&!ink[p]&&(!keep[p-1]||!keep[p+1]||!keep[p-w]||!keep[p+w])) {
     bool warm=flame&&y<65&&x>35&&x<80&&rgb[p*3]>135&&rgb[p*3+1]>65&&rgb[p*3+2]<rgb[p*3]*0.8;
     if(!warm)clean[p]=false;
    }
   }
   keep=clean;
  }
  if(gold) {
   var seen=new bool[n];var bestComponent=new List<int>();
   for(int start=0;start<n;start++) if(keep[start]&&!seen[start]) {
    var component=new List<int>();q.Enqueue(start);seen[start]=true;
    while(q.Count>0) {int p=q.Dequeue();component.Add(p);foreach(int d in delta) {int t=p+d;
     if(t<0||t>=n||Math.Abs(t%w-p%w)>1||seen[t]||!keep[t])continue;seen[t]=true;q.Enqueue(t);}}
    if(component.Count>bestComponent.Count)bestComponent=component;
   }
   Array.Clear(keep,0,n);foreach(int p in bestComponent)keep[p]=true;
  }
  var runs=new List<int>();
  for(int y=0;y<h;y++) { int x=0;while(x<w) {
   while(x<w&&!keep[y*w+x])x++;int a=x;while(x<w&&keep[y*w+x])x++;
   if(x>a) {runs.Add(a);runs.Add(y);runs.Add(x-a);} }
  }
  return runs.ToArray();
 }
}
'@
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$approvedPath = Join-Path $projectRoot 'godot/assets/ui/hand_workbench/approved/layout-v04.png'
$hiddenPath = Join-Path $projectRoot 'godot/assets/ui/hand_workbench/approved/layout-v03.png'
$approvedBitmap = [System.Drawing.Bitmap]::new($approvedPath)
$hiddenBitmap = [System.Drawing.Bitmap]::new($hiddenPath)
$guards = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'region-guards.json') -Raw | ConvertFrom-Json -AsHashtable
$parts = @(
 @{Name='SpellbookAndCandle'; Rect=@(54,300,296,222); Seeds=@(156,130,48,85,90,170); Flame=$true},
 @{Name='PotionsAndHerbs'; Rect=@(1136,282,296,240); Seeds=@(178,113,89,138,239,178,134,183)},
 @{Name='InkAndQuill'; Rect=@(304,346,145,165); Seeds=@(106,119,46,44)},
 @{Name='DriedHerbs'; Rect=@(438,430,145,88); Seeds=@(72,43); Hidden=$true},
 @{Name='RolledParchment'; Rect=@(566,440,110,56); Seeds=@(44,27); Hidden=$true},
 @{Name='IngredientPouch'; Rect=@(990,382,105,125); Seeds=@(50,78)},
 @{Name='MoonCharm'; Rect=@(1075,430,68,82); Seeds=@(25,55)}
)
$edgeScript = "extends RefCounted`n## Generated source-pixel run geometry. Approved RGB stays unchanged.`nconst PARTS := [`n"
foreach($part in $parts) {
 $rect=$part.Rect; $w=$rect[2];$h=$rect[3];$bitmap=if($part.Hidden){$hiddenBitmap}else{$approvedBitmap}
 $rgb=[byte[]]::new($w*$h*3)
 for($y=0;$y -lt $h;$y++) {for($x=0;$x -lt $w;$x++) {
  $c=$bitmap.GetPixel($rect[0]+$x,$rect[1]+$y);$p=($y*$w+$x)*3
  $rgb[$p]=$c.R;$rgb[$p+1]=$c.G;$rgb[$p+2]=$c.B
 }}
 $guard=[int[]]@()
 if($guards.ContainsKey($part.Name)) {
  $guard=[int[]]$guards[$part.Name].Clone()
  for($i=0;$i -lt $guard.Length;$i+=2) {$guard[$i]-=$rect[0];$guard[$i+1]-=$rect[1]}
 }
 $guardMargin=if($part.Name -eq 'SpellbookAndCandle'){8}elseif($part.Name -eq 'PotionsAndHerbs'){12}else{3}
 $runs=[PropEdgeGeometry]::Trace($rgb,$w,$h,$InkLimit,[int[]]$part.Seeds,[bool]$part.Flame,($part.Name -eq 'MoonCharm'),$guard,$guardMargin)
 $edgeScript += "`t{`"name`": `"$($part.Name)`", `"rect`": Rect2($($rect -join ',')), `"hidden`": $([bool]$part.Hidden).ToString().ToLower(), `"runs`": [$($runs -join ',')]},`n".Replace('$([bool]$part.Hidden).ToString().ToLower()',([bool]$part.Hidden).ToString().ToLower())
 Write-Output "$($part.Name): $($runs.Length/3) rows"
}
$edgeScript += "]`n"
$edgeScript=$edgeScript.Replace('True.ToString().ToLower()','true').Replace('False.ToString().ToLower()','false')
[System.IO.File]::WriteAllText((Join-Path $projectRoot 'godot/assets/ui/hand_workbench/approved/edge_geometry.gd'),$edgeScript,[System.Text.UTF8Encoding]::new($false))
$approvedBitmap.Dispose();$hiddenBitmap.Dispose()
