$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$lobbyRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../../..'))
$lobbyOutput = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class LobbyUnifiedV02 {
    static double Smooth(double a,double b,double x) { double t=Math.Max(0,Math.Min(1,(x-a)/(b-a)));return t*t*(3-2*t); }
    static double KeepRect(int x,int y,int l,int t,int r,int b,double feather) {
        double dx=Math.Max(Math.Max(l-x,0),x-r),dy=Math.Max(Math.Max(t-y,0),y-b);
        return 1-Smooth(0,feather,Math.Sqrt(dx*dx+dy*dy));
    }
    static readonly int[][] UI = {
        new int[]{1285,185,1885,548},new int[]{1440,565,1765,640},
        new int[]{1502,666,1720,713},new int[]{1500,745,1700,795},
        new int[]{1505,829,1582,875},new int[]{1775,984,1868,1020}
    };
    static readonly Point[][] Faces = {
        new Point[]{new Point(953,48),new Point(1090,35),new Point(1180,52),new Point(1236,115),new Point(1248,174),new Point(1229,211),new Point(1216,254),new Point(1185,290),new Point(1105,317),new Point(1000,294),new Point(957,226)},
        new Point[]{new Point(1029,771),new Point(1088,778),new Point(1126,820),new Point(1146,855),new Point(1166,863),new Point(1165,881),new Point(1151,892),new Point(1148,920),new Point(1140,952),new Point(1123,971),new Point(1085,972),new Point(1021,952),new Point(976,918),new Point(976,836)}
    };
    public static Bitmap Scale(Image src,int w,int h) {
        Bitmap dst=new Bitmap(w,h,PixelFormat.Format24bppRgb);
        using(Graphics g=Graphics.FromImage(dst)) using(ImageAttributes a=new ImageAttributes()) {
            g.CompositingMode=CompositingMode.SourceCopy;g.CompositingQuality=CompositingQuality.HighQuality;
            g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;
            a.SetWrapMode(WrapMode.TileFlipXY);g.DrawImage(src,new Rectangle(0,0,w,h),0,0,src.Width,src.Height,GraphicsUnit.Pixel,a);
        } return dst;
    }
    static byte[] Bytes(Bitmap image) {
        var d=image.LockBits(new Rectangle(0,0,image.Width,image.Height),ImageLockMode.ReadOnly,PixelFormat.Format24bppRgb);
        byte[] b=new byte[d.Stride*image.Height];Marshal.Copy(d.Scan0,b,0,b.Length);image.UnlockBits(d);return b;
    }
    static void Save(byte[] b,string path) {
        using(Bitmap image=new Bitmap(1920,1080,PixelFormat.Format24bppRgb)) {
            var d=image.LockBits(new Rectangle(0,0,1920,1080),ImageLockMode.WriteOnly,PixelFormat.Format24bppRgb);
            Marshal.Copy(b,0,d.Scan0,b.Length);image.UnlockBits(d);image.Save(path,ImageFormat.Png);
        }
    }
    public static string Compose(string source,string generated,string dest) {
        using(Bitmap original=new Bitmap(source)) using(Image raw=Image.FromFile(generated))
        using(Bitmap gen=Scale(raw,1920,1080))
        using(Bitmap faceMask=new Bitmap(1920,1080,PixelFormat.Format24bppRgb)) {
            if(original.Width!=1920 || original.Height!=1080) throw new Exception("Original dimensions must be 1920x1080");
            using(Graphics g=Graphics.FromImage(faceMask)) {g.Clear(Color.Black);foreach(var p in Faces)g.FillPolygon(Brushes.White,p);}
            byte[] o=Bytes(original),a=Bytes(gen),face=Bytes(faceMask),f=new byte[o.Length],m=new byte[o.Length];
            int[] edges=new int[1080];
            // Trace the original ensemble's outer ink/fur, without carrying its empty cream moat.
            for(int y=0;y<1080;y++) {
                edges[y]=950;
                for(int x=950;x<=1278;x++) {int i=(y*1920+x)*3;if(o[i+2]<210 || o[i+1]<205 || o[i]<180) edges[y]=x;}
            }
            // Flood connected cream only near the outer silhouette to retain the small gaps in hair and brim.
            bool[] bg=new bool[1920*1080];int[] queue=new int[1920*1080];int head=0,tail=0;
            for(int y=0;y<1080;y++){int q=y*1920+1280;bg[q]=true;queue[tail++]=q;}
            while(head<tail) {
                int q=queue[head++],x=q%1920,y=q/1920;
                int[] next={q-1,q+1,q-1920,q+1920};
                foreach(int n in next) {
                    if(n<0 || n>=bg.Length)continue;int nx=n%1920;if(nx<950 || nx>1280 || Math.Abs(nx-x)>1 || bg[n])continue;
                    int i=n*3;if(o[i+2]>210 && o[i+1]>205 && o[i]>180){bg[n]=true;queue[tail++]=n;}
                }
            }
            long protectedN=0,changedProtected=0,changed=0,faceN=0,faceChanged=0,uiN=0,uiChanged=0;
            long[] uiCounts=new long[UI.Length],uiChanges=new long[UI.Length];
            for(int y=0;y<1080;y++) for(int x=0;x<1920;x++) {
                int p=y*1920+x,i=p*3;
                double keep=1-Smooth(edges[y]-24,edges[y]+2,x);
                if(bg[p])keep=0;
                if(x<950)keep=1;
                // Exact original face pixels. Other five faces are entirely inside x<950.
                bool isFace=face[i]>0 && !bg[p];
                if(isFace)keep=1;
                double uiKeep=0;bool isUI=false;
                for(int u=0;u<UI.Length;u++) {
                    var r=UI[u];double k=KeepRect(x,y,r[0],r[1],r[2],r[3],40);uiKeep=Math.Max(uiKeep,k);
                    if(k==1){isUI=true;uiCounts[u]++;}
                }
                keep=Math.Max(keep,uiKeep);bool diff=false;
                // A translucent warm lavender air layer keeps the extended forest distant.
                double fog=0.22*Smooth(360,700,y);int[] air={231,233,241};
                for(int c=0;c<3;c++){double atmosphere=a[i+c]*(1-fog)+air[c]*fog;f[i+c]=(byte)Math.Round(o[i+c]*keep+atmosphere*(1-keep));m[i+c]=(byte)Math.Round((1-keep)*255);diff|=f[i+c]!=o[i+c];}
                if(diff)changed++;
                if(keep==1){protectedN++;if(diff)changedProtected++;}
                if(isFace){faceN++;if(diff)faceChanged++;}
                if(isUI){uiN++;if(diff)uiChanged++;}
                if(diff && isUI) for(int u=0;u<UI.Length;u++){var r=UI[u];if(x>=r[0]&&x<=r[2]&&y>=r[1]&&y<=r[3])uiChanges[u]++;}
            }
            Save(f,System.IO.Path.Combine(dest,"03-races-closeup-distant.png"));
            Save(m,System.IO.Path.Combine(dest,"drafts/03-generated-blend-mask.png"));
            faceMask.Save(System.IO.Path.Combine(dest,"drafts/04-face-protection-mask.png"),ImageFormat.Png);
            string uiJson="";for(int u=0;u<UI.Length;u++){if(u>0)uiJson+=",";uiJson+="{\"rectangle\":["+String.Join(",",UI[u])+"],\"pixels\":"+uiCounts[u]+",\"changed_pixels\":"+uiChanges[u]+"}";}
            return "{\n  \"output_size\": [1920,1080],\n  \"generated_size\": ["+raw.Width+","+raw.Height+"],\n  \"comparison_baseline\": \"../../races-closeup-distant-v01/03-races-closeup-distant.png\",\n  \"protected_pixels\": "+protectedN+",\n  \"changed_protected_pixels\": "+changedProtected+",\n  \"additional_orc_goblin_face_mask_pixels\": "+faceN+",\n  \"changed_additional_face_pixels\": "+faceChanged+",\n  \"ui_protected_pixels\": "+uiN+",\n  \"changed_ui_pixels\": "+uiChanged+",\n  \"changed_pixels\": "+changed+",\n  \"ui_regions\": ["+uiJson+"]\n}\n";
        }
    }
    public static void Sheet(string source,string edited,string dest) {
        using(Image o=Image.FromFile(source))using(Image e=Image.FromFile(edited))
        using(Bitmap sheet=new Bitmap(2880,918,PixelFormat.Format24bppRgb))using(Graphics g=Graphics.FromImage(sheet))
        using(Font title=new Font("Malgun Gothic",23,FontStyle.Bold))using(Font body=new Font("Malgun Gothic",14))
        using(SolidBrush ink=new SolidBrush(Color.FromArgb(66,43,65))) {
            g.Clear(Color.FromArgb(242,234,219));g.TextRenderingHint=System.Drawing.Text.TextRenderingHint.AntiAliasGridFit;
            g.DrawString("v01 · 원경과 인물 사이 빈 크림 띠",title,ink,32,18);
            g.DrawString("v02 · 인물 뒤로 이어지는 숲과 설경",title,ink,1456,18);
            using(Bitmap left=Scale(o,1392,783))using(Bitmap right=Scale(e,1392,783)){g.DrawImageUnscaled(left,32,78);g.DrawImageUnscaled(right,1456,78);}
            g.DrawString("동일 크기 비교 · 원본 얼굴과 UI 보존 · 라벤더 안개와 실루엣 가장자리 연결",body,ink,32,878);
            sheet.Save(dest,ImageFormat.Png);
        }
    }
}
'@
$lobbyOriginal = Join-Path $lobbyRoot 'art/concepts/lobby/races-closeup-distant-v01/03-races-closeup-distant.png'
$lobbyGenerated = Join-Path $PSScriptRoot '01-imagegen-edit.png'
$lobbyReport = [LobbyUnifiedV02]::Compose($lobbyOriginal,$lobbyGenerated,$lobbyOutput)
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'pixel-verification.json'),$lobbyReport,[Text.UTF8Encoding]::new($false))
[LobbyUnifiedV02]::Sheet($lobbyOriginal,(Join-Path $lobbyOutput '03-races-closeup-distant.png'),(Join-Path $lobbyOutput 'sheet.png'))
Write-Output $lobbyReport
