param(
    [string]$InputName = 'preserve-concept',
    [string]$OutputName = 'drafts/06-final.png',
    [double]$Scale = 0.4444444444444444,
    [double]$OffsetX = 79.27777777777777,
    [double]$OffsetY = -21.22222222222222,
    [string]$SheetName = 'sheet.png',
    [switch]$Install
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$taskRoot = (Get-Location).Path
$taskArt = Join-Path $taskRoot 'art/portraits/graz-medal-v01'
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
public static class GrazSheet {
    static Bitmap New(int w,int h) {return new Bitmap(w,h,PixelFormat.Format32bppArgb);}
    static Graphics G(Bitmap b) {var g=Graphics.FromImage(b);g.CompositingMode=CompositingMode.SourceOver;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;g.SmoothingMode=SmoothingMode.AntiAlias;return g;}
    public static Rectangle Bounds(Bitmap b, int threshold) {
        int l=b.Width,t=b.Height,r=-1,d=-1;
        for(int y=0;y<b.Height;y++)for(int x=0;x<b.Width;x++)if(b.GetPixel(x,y).A>threshold){l=Math.Min(l,x);t=Math.Min(t,y);r=Math.Max(r,x);d=Math.Max(d,y);}
        return Rectangle.FromLTRB(l,t,r+1,d+1);
    }
    public static void Normalize(string input,string output) {
        using(var src=new Bitmap(input))using(var dst=New(1122,1402)) {
            var box=Bounds(src,0);double s=Math.Min(962.0/box.Width,1174.0/box.Height);
            float w=(float)(box.Width*s),h=(float)(box.Height*s);
            using(var g=G(dst))g.DrawImage(src,new RectangleF((1122-w)/2,112,w,h),box,GraphicsUnit.Pixel);
            dst.Save(output,ImageFormat.Png);
        }
    }
    static PointF[] P(float[] a) {var p=new PointF[a.Length/2];for(int i=0;i<p.Length;i++)p[i]=new PointF(a[i*2],a[i*2+1]);return p;}
    public static void PreserveConcept(string concept,string generated,string output) {
        using(var source=new Bitmap(concept))using(var gen=new Bitmap(generated))using(var baseArt=New(570,670))using(var mask=New(570,670))using(var exact=New(570,670))using(var final=New(1122,1402)) {
            // Generated v02 is used only for body portions occluded by the original rim.
            using(var temp=New(570,670)) {
                using(var g=G(temp))g.DrawImage(gen,new RectangleF(83,-55,gen.Width*0.44f,gen.Height*0.44f));
                using(var g=G(baseArt)) {
                    g.DrawImage(temp,new RectangleF(0,0,570,380),new RectangleF(0,0,570,380),GraphicsUnit.Pixel);
                    g.DrawImage(temp,new RectangleF(0,380,570,377),new RectangleF(0,380,570,290),GraphicsUnit.Pixel);
                }
            }
            using(var g=G(mask))using(var white=new SolidBrush(Color.White)) {
                // Actual visible subject contours, traced on the supplied 3x concept.
                g.FillPolygon(white,P(new float[]{
                    238,65,240,55,248,47,264,39,283,33,301,29,313,29,320,34,324,44,335,44,341,54,
                    354,56,374,61,396,70,417,82,434,96,443,108,452,109,463,105,472,111,470,123,476,132,472,141,
                    480,151,485,159,516,152,523,154,522,160,512,167,495,174,488,180,493,193,504,199,508,207,
                    514,224,514,237,511,247,505,251,499,249,495,241,495,232,500,226,492,223,480,222,471,223,470,239,473,249,468,252,462,249,459,240,455,228,447,236,445,246,450,251,459,260,466,270,476,270,480,277,480,286,503,289,515,296,503,309,489,335,472,357,453,377,432,389,408,400,
                    381,407,350,412,320,411,295,405,271,395,250,382,234,369,222,355,210,350,197,342,
                    184,326,177,310,172,289,174,278,182,268,202,268,215,268,228,263,240,260,247,250,
                    245,241,260,239,273,230,270,221,256,217,238,215,217,208,221,203,238,201,252,202,
                    242,202,227,198,222,189,222,174,227,156,236,138,250,119,266,103,279,91,267,85,253,85,
                    242,78}));
                g.FillPolygon(white,P(new float[]{225,194,221,181,224,165,232,148,244,130,259,112,279,94,300,78,322,64,343,55,360,58,382,64,402,74,421,86,436,101,445,110,429,112,406,119,381,131,358,145,334,162,309,180,280,195,252,204,231,201}));
                g.FillPolygon(white,P(new float[]{151,30,160,39,171,57,180,80,187,107,193,137,199,169,205,200,210,229,212,239,
                    230,237,242,240,247,248,246,256,233,262,213,269,192,274,173,276,158,269,151,261,155,253,169,247,
                    164,218,158,186,151,150,143,113,139,85,140,62}));
                // Remove the open interior of the helmet handle rather than carrying medal background.
                g.CompositingMode=CompositingMode.SourceCopy;
                using(var clear=new SolidBrush(Color.Transparent)) {
                    g.FillPolygon(clear,P(new float[]{251,62,262,54,278,47,297,41,307,40,313,52,314,57,296,63,276,72,260,77,253,72}));
                    g.FillEllipse(clear,503,229,6,13);
                }
            }
            // Outside the original round window use only the completed lower body.
            // The transition lies behind the inspection sheet's inner frame edge.
            for(int y=0;y<670;y++)for(int x=0;x<570;x++) {
                var b=baseArt.GetPixel(x,y);
                if(y<270) b=Color.Transparent;
                else if(y<294) b=Color.FromArgb((int)(b.A*(y-270)/24.0),b.R,b.G,b.B);
                baseArt.SetPixel(x,y,b);
                if(y<source.Height) {
                    var c=source.GetPixel(x,y);int a=mask.GetPixel(x,y).A;
                    double radius=Math.Sqrt((x-342.0)*(x-342.0)+(y-223.0)*(y-223.0));
                    if(y>278 && radius>174) a=(int)(a*Math.Max(0,Math.Min(1,(181-radius)/7)));
                    exact.SetPixel(x,y,Color.FromArgb(a,c.R,c.G,c.B));
                }
            }
            using(var g=G(baseArt))g.DrawImageUnscaled(exact,0,0);
            // Concept-space -> production portrait; alpha-cleaned top margin is 112 px.
            const float scale=2.25f,ox=-178.375f,oy=47.75f;
            using(var g=G(final))g.DrawImage(baseArt,new RectangleF(ox,oy,570*scale,670*scale));
            for(int y=0;y<final.Height;y++)for(int x=0;x<final.Width;x++) {
                var c=final.GetPixel(x,y); if(c.A<=2)final.SetPixel(x,y,Color.Transparent);
                else if(c.A>=250 && c.A<255)final.SetPixel(x,y,Color.FromArgb(255,c.R,c.G,c.B));
            }
            final.Save(output,ImageFormat.Png);
        }
    }
    public static void Composite(string portrait,string frame,string output,double scale,double ox,double oy) {
        using(var src=new Bitmap(portrait))using(var rim=new Bitmap(frame))using(var dst=New(570,510))using(var p=New(570,510)) {
            using(var g=G(p))g.DrawImage(src,new RectangleF((float)ox,(float)oy,(float)(src.Width*scale),(float)(src.Height*scale)));
            const double cx=342,cy=223,inner=185,split=245;
            using(var lower=(Bitmap)p.Clone())using(var upper=(Bitmap)p.Clone()) {
                for(int y=0;y<510;y++)for(int x=0;x<570;x++){
                    double rr=(x-cx)*(x-cx)+(y-cy)*(y-cy);
                    if(y<split||rr>inner*inner)lower.SetPixel(x,y,Color.Transparent);
                    if(y>=split)upper.SetPixel(x,y,Color.Transparent);
                }
                using(var g=G(dst)) {
                    g.Clear(Color.FromArgb(162,175,200));
                    g.FillEllipse(new SolidBrush(Color.FromArgb(40,24,56)),(float)(cx-inner),(float)(cy-inner),(float)(inner*2),(float)(inner*2));
                    g.DrawImageUnscaled(lower,0,0);
                    float side=450f/0.96f;
                    g.DrawImage(rim,new RectangleF((float)cx-side/2,(float)cy-side/2,side,side));
                    g.DrawImageUnscaled(upper,0,0);
                }
            }
            dst.Save(output,ImageFormat.Png);
        }
    }
    static void Text(Graphics g,string s,int size,int x,int y,Color c) {
        using(var f=new Font("Malgun Gothic",size,FontStyle.Regular,GraphicsUnit.Pixel))using(var b=new SolidBrush(c))g.DrawString(s,f,b,x,y);
    }
    public static System.Collections.Generic.Dictionary<string,object> Inspect(string portrait,string composite,string concept) {
        var result=new System.Collections.Generic.Dictionary<string,object>();
        using(var p=new Bitmap(portrait))using(var m=new Bitmap(composite))using(var c=new Bitmap(concept)) {
            int zero=0,semi=0,opaque=0,borderMax=0;var box=Bounds(p,0);
            for(int y=0;y<p.Height;y++)for(int x=0;x<p.Width;x++) {
                int a=p.GetPixel(x,y).A;if(a==0)zero++;else if(a==255)opaque++;else semi++;
                if(x==0||y==0||x==p.Width-1||y==p.Height-1)borderMax=Math.Max(borderMax,a);
            }
            double faceError=0;int samples=0;
            for(int y=158;y<=264;y++)for(int x=338;x<=426;x++) {
                var a=m.GetPixel(x,y);var b=c.GetPixel(x,y);
                faceError+=Math.Abs(a.R-b.R)+Math.Abs(a.G-b.G)+Math.Abs(a.B-b.B);samples+=3;
            }
            result["width"]=p.Width;result["height"]=p.Height;result["pixelFormat"]=p.PixelFormat.ToString();
            result["bboxExclusive"]=new int[]{box.Left,box.Top,box.Right,box.Bottom};
            result["topMarginPercent"]=100.0*box.Top/p.Height;
            result["horizontalCenter"]=0.5*(box.Left+box.Right);
            result["transparentPixels"]=zero;result["partialAlphaPixels"]=semi;result["opaquePixels"]=opaque;
            result["outerBorderMaximumAlpha"]=borderMax;
            result["faceCropMeanAbsoluteRgbError"]=faceError/samples;
            result["faceCropConceptCoordinates"]=new int[]{338,158,427,265};
            result["faceErrorNote"]="Resampling error on source-preserved face, not an independent generative similarity score.";
            result["worldStyleVisualReview"]="Medieval fantasy goblin, pot helmet, dagger, leather/cloth, painted ink.";
        }
        return result;
    }
    public static void Sheet(string concept,string composite,string portrait,string output) {
        using(var c=new Bitmap(concept))using(var m=new Bitmap(composite))using(var p=new Bitmap(portrait))using(var dst=New(1860,980))using(var g=G(dst)) {
            g.Clear(Color.FromArgb(22,23,30));
            Text(g,"GRAZ / MEDAL PORTRAIT",30,28,18,Color.FromArgb(239,207,137));
            Text(g,"시안의 포즈 · 투구/칼 비율 · 얼굴/귀/목도리 대조",20,28,62,Color.LightGray);
            Text(g,"01  시안 메달 / 3배 발췌",23,28,112,Color.White);
            Text(g,"02  새 컷아웃 + 지정 메달 틀 / 같은 크기",23,632,112,Color.White);
            Text(g,"03  새 컷아웃 전체 / 투명도 확인",23,1236,112,Color.White);
            g.DrawImageUnscaled(c,28,158);g.DrawImageUnscaled(m,632,158);
            int bx=1236,by=158,bw=590,bh=737;
            for(int y=0;y<bh;y+=18)for(int x=0;x<bw;x+=18)using(var b=new SolidBrush(((x/18+y/18)%2==0)?Color.FromArgb(192,195,201):Color.FromArgb(223,225,229)))g.FillRectangle(b,bx+x,by+y,Math.Min(18,bw-x),Math.Min(18,bh-y));
            g.DrawImage(p,new RectangleF(bx,by,bw,bh));
            Text(g,"왼쪽은 시안 원본. 오른쪽 합성은 실제 지정 medal_frame.png 사용.",20,28,700,Color.LightGray);
            Text(g,"하단은 원 안쪽으로 자르고, 상단의 칼끝·투구는 틀 위에 표시.",20,28,736,Color.LightGray);
            Text(g,"1122 × 1402 RGBA / 바깥 alpha 0 / 상단 여백 112 px (8%)",20,28,796,Color.FromArgb(239,207,137));
            Text(g,"전용 에셋 제작 · 기존 초상 / UI / 코드 / 실행파일 보존",20,28,836,Color.LightGray);
            Text(g,"ART ONLY — Godot 임포트·연결·내보내기는 구현 담당 범위",18,28,920,Color.FromArgb(170,175,187));
            dst.Save(output,ImageFormat.Png);
        }
    }
}
'@
$taskInput = Join-Path $taskArt $InputName
$taskOutput = Join-Path $taskArt $OutputName
if ($InputName -eq 'preserve-concept') {
    [GrazSheet]::PreserveConcept((Join-Path $taskRoot 'docs/handoff/refs/speech-medal-concept-crop3x.png'),(Join-Path $taskArt 'drafts/02-normalized.png'),$taskOutput)
} else {
    [GrazSheet]::Normalize($taskInput,$taskOutput)
}
$taskMedal = Join-Path $taskArt ($SheetName -replace '\.png$','-medal.png')
[GrazSheet]::Composite($taskOutput,(Join-Path $taskRoot 'godot/assets/ui/moon_runes/common/medal_frame.png'),$taskMedal,$Scale,$OffsetX,$OffsetY)
[GrazSheet]::Sheet((Join-Path $taskRoot 'docs/handoff/refs/speech-medal-concept-crop3x.png'),$taskMedal,$taskOutput,(Join-Path $taskArt $SheetName))
$taskQa = [GrazSheet]::Inspect($taskOutput,$taskMedal,(Join-Path $taskRoot 'docs/handoff/refs/speech-medal-concept-crop3x.png'))
$taskQa | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskArt 'verification.json') -Encoding UTF8
if ($Install) {
    Copy-Item -LiteralPath $taskOutput -Destination (Join-Path $taskRoot 'godot/assets/portraits/guest_graz_medal.png')
}
$taskBitmap = [Drawing.Bitmap]::FromFile($taskOutput)
[GrazSheet]::Bounds($taskBitmap,0)
$taskBitmap.Dispose()
