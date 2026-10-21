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
public static class LobbyDistant {
    static double Smooth(double a, double b, double x) {
        double t=Math.Max(0,Math.Min(1,(x-a)/(b-a))); return t*t*(3-2*t);
    }
    static double Outside(double x,double y,double l,double t,double r,double b,double feather) {
        double dx=Math.Max(Math.Max(l-x,0),x-r), dy=Math.Max(Math.Max(t-y,0),y-b);
        return Smooth(0,feather,Math.Sqrt(dx*dx+dy*dy));
    }
    public static Bitmap Scale(Image src,int w,int h) {
        Bitmap dst=new Bitmap(w,h,PixelFormat.Format24bppRgb);
        using(Graphics g=Graphics.FromImage(dst)) using(ImageAttributes a=new ImageAttributes()) {
            g.CompositingMode=CompositingMode.SourceCopy;
            g.CompositingQuality=CompositingQuality.HighQuality;
            g.InterpolationMode=InterpolationMode.HighQualityBicubic;
            g.PixelOffsetMode=PixelOffsetMode.HighQuality;
            a.SetWrapMode(WrapMode.TileFlipXY);
            g.DrawImage(src,new Rectangle(0,0,w,h),0,0,src.Width,src.Height,GraphicsUnit.Pixel,a);
        } return dst;
    }
    public static string Compose(string original,string draft,string dest) {
        using(Image oi=Image.FromFile(original)) using(Image gi=Image.FromFile(draft))
        using(Bitmap o=Scale(oi,1920,1080)) using(Bitmap g=Scale(gi,1920,1080))
        using(Bitmap final=new Bitmap(1920,1080,PixelFormat.Format24bppRgb))
        using(Bitmap mask=new Bitmap(1920,1080,PixelFormat.Format24bppRgb)) {
            Rectangle rect=new Rectangle(0,0,1920,1080);
            BitmapData od=o.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format24bppRgb);
            BitmapData gd=g.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format24bppRgb);
            BitmapData fd=final.LockBits(rect,ImageLockMode.WriteOnly,PixelFormat.Format24bppRgb);
            BitmapData md=mask.LockBits(rect,ImageLockMode.WriteOnly,PixelFormat.Format24bppRgb);
            int n=od.Stride*1080; byte[] ob=new byte[n],gb=new byte[n],fb=new byte[n],mb=new byte[n];
            Marshal.Copy(od.Scan0,ob,0,n); Marshal.Copy(gd.Scan0,gb,0,n);
            long protectedCount=0,changedCount=0,protectedChanged=0; int maxChange=0;
            for(int y=0;y<1080;y++) for(int x=0;x<1920;x++) {
                double sx=x*1672.0/1920.0, sy=y*941.0/1080.0;
                // All original characters and the entire title are inside these unedited bounds.
                double alpha=0.58*Smooth(1080,1150,sx)*Smooth(515,710,sy);
                // Preserve broad original cream fields behind navigation and the exit, with soft fog transitions.
                alpha*=Outside(sx,sy,1235,480,1550,785,85);
                alpha*=Outside(sx,sy,1515,835,1672,925,75);
                int at=y*od.Stride+x*3; bool changed=false;
                for(int c=0;c<3;c++) {
                    fb[at+c]=(byte)Math.Round(ob[at+c]*(1-alpha)+gb[at+c]*alpha);
                    mb[at+c]=(byte)Math.Round(alpha*255);
                    int d=Math.Abs(fb[at+c]-ob[at+c]); maxChange=Math.Max(maxChange,d);
                    changed|=d>0;
                }
                if(changed) changedCount++;
                if(alpha==0) { protectedCount++; if(changed) protectedChanged++; }
            }
            Marshal.Copy(fb,0,fd.Scan0,n); Marshal.Copy(mb,0,md.Scan0,n);
            o.UnlockBits(od);g.UnlockBits(gd);final.UnlockBits(fd);mask.UnlockBits(md);
            final.Save(System.IO.Path.Combine(dest,"03-races-closeup-distant.png"),ImageFormat.Png);
            o.Save(System.IO.Path.Combine(dest,"drafts/02-original-1920x1080.png"),ImageFormat.Png);
            mask.Save(System.IO.Path.Combine(dest,"drafts/03-scenery-blend-mask.png"),ImageFormat.Png);
            return "{\n  \"output_size\": [1920, 1080],\n  \"original_size\": ["+oi.Width+", "+oi.Height+"],\n  \"generated_size\": ["+gi.Width+", "+gi.Height+"],\n  \"protected_pixels\": "+protectedCount+",\n  \"changed_protected_pixels\": "+protectedChanged+",\n  \"changed_background_pixels\": "+changedCount+",\n  \"maximum_channel_difference\": "+maxChange+",\n  \"maximum_background_blend\": 0.58,\n  \"comparison_baseline\": \"drafts/02-original-1920x1080.png\"\n}\n";
        }
    }
    public static void Sheet(string original,string edited,string output) {
        using(Image o=Image.FromFile(original)) using(Image e=Image.FromFile(edited))
        using(Bitmap sheet=new Bitmap(2880,918,PixelFormat.Format24bppRgb))
        using(Graphics g=Graphics.FromImage(sheet))
        using(Font font=new Font("Malgun Gothic",23,FontStyle.Bold))
        using(Font small=new Font("Malgun Gothic",14))
        using(SolidBrush text=new SolidBrush(Color.FromArgb(66,43,65))) {
            g.Clear(Color.FromArgb(242,234,219)); g.TextRenderingHint=System.Drawing.Text.TextRenderingHint.AntiAliasGridFit;
            g.DrawString("원본 · 03-races-closeup",font,text,32,18);
            g.DrawString("원경 추가 · 안개 속 설경과 작은 산장",font,text,1456,18);
            using(Bitmap a=Scale(o,1392,783)) using(Bitmap b=Scale(e,1392,783)) {
                g.DrawImageUnscaled(a,32,78); g.DrawImageUnscaled(b,1456,78);
            }
            g.DrawString("동일 크기 비교 · 인물과 UI 보존 · 설경은 메뉴 아래와 인물 뒤에만 옅게 배치",small,text,32,878);
            sheet.Save(output,ImageFormat.Png);
        }
    }
}
'@
$lobbyOriginal = Join-Path $lobbyRoot 'art/concepts/lobby/reference-composition-v01/03-races-closeup.png'
$lobbyGenerated = Join-Path $PSScriptRoot '01-imagegen-edit.png'
$lobbyReport = [LobbyDistant]::Compose($lobbyOriginal, $lobbyGenerated, $lobbyOutput)
[IO.File]::WriteAllText((Join-Path $lobbyOutput 'drafts/pixel-verification.json'),$lobbyReport,(New-Object Text.UTF8Encoding($false)))
[LobbyDistant]::Sheet((Join-Path $PSScriptRoot '02-original-1920x1080.png'),(Join-Path $lobbyOutput '03-races-closeup-distant.png'),(Join-Path $lobbyOutput 'sheet.png'))
Write-Output $lobbyReport
