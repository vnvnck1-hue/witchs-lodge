$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class SplitVerify {
 static byte[] Read(Bitmap b){var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);var p=new byte[b.Width*b.Height*4];Marshal.Copy(d.Scan0,p,0,p.Length);b.UnlockBits(d);return p;}
 public static string Components(string path){using(var b=new Bitmap(path)){var p=Read(b);var seen=new bool[b.Width*b.Height];var q=new int[seen.Length];var sizes=new List<int>();var boxes=new List<string>();for(int s=0;s<seen.Length;s++){if(seen[s]||p[s*4+3]<128)continue;int a=0,z=0;q[z++]=s;seen[s]=true;while(a<z){int v=q[a++],x=v%b.Width,y=v/b.Width;for(int dy=-1;dy<=1;dy++)for(int dx=-1;dx<=1;dx++){int xx=x+dx,yy=y+dy;if(xx<0||yy<0||xx>=b.Width||yy>=b.Height)continue;int u=yy*b.Width+xx;if(!seen[u]&&p[u*4+3]>=128){seen[u]=true;q[z++]=u;}}}sizes.Add(z);if(z<1000){int x0=b.Width,y0=b.Height,x1=0,y1=0;for(int i=0;i<z;i++){x0=Math.Min(x0,q[i]%b.Width);x1=Math.Max(x1,q[i]%b.Width);y0=Math.Min(y0,q[i]/b.Width);y1=Math.Max(y1,q[i]/b.Width);}boxes.Add(z+"@["+x0+","+y0+","+x1+","+y1+"]");}}sizes.Sort();sizes.Reverse();return "alpha>=128 connected components="+sizes.Count+"; pixel counts="+String.Join(",",sizes.ToArray())+"; small component bounds="+String.Join(";",boxes.ToArray());}}
 public static string Compare(string sheetPath,string bodyPath,string tailPath,string sourcePath){using(var sheet=new Bitmap(sheetPath))using(var body=new Bitmap(bodyPath))using(var tail=new Bitmap(tailPath))using(var source=new Bitmap(sourcePath)){var sp=Read(sheet);var bp=Read(body);var tp=Read(tail);var op=Read(source);int bodyDiff=0,tailDiff=0,leftHand=0,feet=0,headTorso=0;for(int y=0;y<1536;y++)for(int x=0;x<1536;x++){int v=(y*1536+x)*4;for(int k=0;k<4;k++){if((x<1470||y<950||y>=1243)&&bp[v+k]!=sp[(y*2048+x)*4+k])bodyDiff++;if(x>=528&&x<1008&&y>=621&&y<914&&tp[v+k]!=sp[((y-621+950)*2048+x-528+1470)*4+k])tailDiff++;if(op[v+k]!=bp[v+k]){if(x>=260&&x<490&&y>=890&&y<1040&&op[v+3]>=128)leftHand++;if(x>=550&&y>=1220)feet++;if(y<890||x>=710)headTorso++;}}}return "Exact BGRA channel comparison: sheet/body differences="+bodyDiff+"; sheet/tail differences="+tailDiff+"; original left hand opaque verification region differences="+leftHand+"; original feet differences="+feet+"; original head/upper body/right half differences="+headTorso;}}
 public static double Length(double[] xy){double v=0;for(int i=2;i<xy.Length;i+=2){double x=xy[i]-xy[i-2],y=xy[i+1]-xy[i-1];v+=Math.Sqrt(x*x+y*y);}return v;}
}
'@
$dest=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$original=[IO.Path]::GetFullPath((Join-Path $dest '../werewolf-witch-model-v02/werewolf-3q-b-v02.png'))
$lines=@()
foreach($f in @('werewolf-sheet-v03.png','werewolf-body-v03.png','werewolf-tail-v03.png')){$lines+=$f+': '+[SplitVerify]::Components((Join-Path $dest $f))}
$lines+=[SplitVerify]::Compare((Join-Path $dest 'werewolf-sheet-v03.png'),(Join-Path $dest 'werewolf-body-v03.png'),(Join-Path $dest 'werewolf-tail-v03.png'),$original)
$a=@(619,1004,580,1071,518,1130,428,1166,335,1172,251,1149,197,1058)
$b=@(19,137,75,197,162,226,255,234,348,206,422,133,465,42)
$origLength=[SplitVerify]::Length($a)
$tailLength=[SplitVerify]::Length($b)*.96
$lines+=('Approximate manually sampled centerline: source='+[Math]::Round($origLength,2)+'px; final='+[Math]::Round($tailLength,2)+'px; ratio='+[Math]::Round($tailLength/$origLength,4)+'. Screen-space estimate, NOT a 3D anatomical measurement. Source landmarks='+($a -join ',')+'; generated 500px-proxy landmarks='+($b -join ',')+'; final proxy scale=0.96.')
$protected=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'protected-input-hashes.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$mismatch=@($protected | Where-Object {(Get-FileHash -LiteralPath $_.Path -Algorithm SHA256).Hash -ne $_.SHA256})
if($mismatch.Count -gt 0){throw 'Protected input hash changed'}
$lines+='Protected existing inputs verified unchanged: '+$protected.Count+' files.'
$lines | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'verification-report.txt') -Encoding UTF8
$lines




