# Reproduce final palette-only edits from immutable v01 source pixels.
# ImageGen palette studies: 01 generated-b / 02 generated-a.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$taskRoot = (Resolve-Path (Join-Path $PSScriptRoot '../../../../..')).Path
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;
public static class LobbyPaletteV02 {
    static double Clamp(double x,double a,double b){return Math.Max(a,Math.Min(b,x));}
    static double Smooth(double a,double b,double x){double t=Clamp((x-a)/(b-a),0,1);return t*t*(3-2*t);}
    static double Mix(double a,double b,double t){return a+(b-a)*t;}
    static double HueMix(double a,double b,double t){double d=(b-a+540)%360-180;return (a+d*t+360)%360;}
    static bool Box(int x,int y,int a,int b,int c,int d){return x>=a&&x<c&&y>=b&&y<d;}
    // Frozen original title, menu lettering/ornaments and exit, never re-typeset.
    static bool UI(int x,int y,int id){
        if(id==1) return Box(x,y,1260,195,1900,490)||Box(x,y,1400,535,1780,640)||
            Box(x,y,1470,668,1710,718)||Box(x,y,1470,752,1690,800)||
            Box(x,y,1470,832,1570,880)||Box(x,y,1755,980,1895,1048);
        return Box(x,y,140,130,715,365)||Box(x,y,140,378,435,458)||
            Box(x,y,208,471,431,513)||Box(x,y,210,535,405,574)||
            Box(x,y,210,596,292,639)||Box(x,y,58,993,145,1037);
    }
    static bool Face(int x,int y,int id){
        if(id==1) return Box(x,y,377,548,493,657)||Box(x,y,386,226,449,294)||
            Box(x,y,600,95,671,165)||Box(x,y,790,279,844,342)||
            Box(x,y,846,635,901,683)||Box(x,y,1053,675,1117,738);
        return Box(x,y,1486,377,1594,493)||Box(x,y,1328,229,1390,285)||
            Box(x,y,1061,572,1125,638)||Box(x,y,1237,560,1300,629)||
            Box(x,y,553,669,662,765);
    }
    static double Channel(double p,double q,double t){
        if(t<0)t+=1;if(t>1)t-=1;
        if(t<1.0/6)return p+(q-p)*6*t;if(t<.5)return q;
        if(t<2.0/3)return p+(q-p)*(2.0/3-t)*6;return p;
    }
    static byte B(double x){return (byte)Math.Round(Clamp(x,0,1)*255);}
    public static string Verify(string input,string output,int id){
        using(var a=new Bitmap(input))using(var b=new Bitmap(output)){
            long changed=0,uiCount=0,uiMismatch=0,inkCount=0,inkMismatch=0,creamCount=0,creamMismatch=0;
            int maxLightnessSumDifference=0;double warmSource=0,warmFinal=0;long warmCount=0;
            for(int y=0;y<a.Height;y++)for(int x=0;x<a.Width;x++){
                Color p=a.GetPixel(x,y),q=b.GetPixel(x,y);
                bool same=p.ToArgb()==q.ToArgb();if(!same)changed++;
                int hi=Math.Max(p.R,Math.Max(p.G,p.B)),lo=Math.Min(p.R,Math.Min(p.G,p.B));
                int qhi=Math.Max(q.R,Math.Max(q.G,q.B)),qlo=Math.Min(q.R,Math.Min(q.G,q.B));
                maxLightnessSumDifference=Math.Max(maxLightnessSumDifference,Math.Abs(hi+lo-qhi-qlo));
                if(UI(x,y,id)){uiCount++;if(!same)uiMismatch++;}
                if(hi<=61){inkCount++;if(!same)inkMismatch++;}
                if((hi+lo)>428&&p.R>=p.G&&p.G>=p.B){creamCount++;if(!same)creamMismatch++;}
                if(p.GetHue()>8&&p.GetHue()<65&&p.GetSaturation()>.35&&!UI(x,y,id)){
                    warmCount++;warmSource+=p.GetSaturation();warmFinal+=q.GetSaturation();
                }
            }
            return "{\"width\":"+b.Width+",\"height\":"+b.Height+",\"changed_color_pixels\":"+changed+
                ",\"frozen_ui_pixels\":"+uiCount+",\"ui_pixel_mismatches\":"+uiMismatch+
                ",\"deep_ink_pixels\":"+inkCount+",\"deep_ink_mismatches\":"+inkMismatch+
                ",\"bright_cream_pixels\":"+creamCount+",\"bright_cream_mismatches\":"+creamMismatch+
                ",\"max_hsl_lightness_sum_difference_0_to_510\":"+maxLightnessSumDifference+
                ",\"selected_warm_mean_saturation_source\":"+(warmSource/warmCount).ToString(System.Globalization.CultureInfo.InvariantCulture)+
                ",\"selected_warm_mean_saturation_final\":"+(warmFinal/warmCount).ToString(System.Globalization.CultureInfo.InvariantCulture)+"}";
        }
    }
    public static void Recolor(string input,string output,int id){
        using(var src=new Bitmap(input))
        using(var dst=new Bitmap(src.Width,src.Height,PixelFormat.Format24bppRgb)){
            var rect=new Rectangle(0,0,src.Width,src.Height);
            var sd=src.LockBits(rect,ImageLockMode.ReadOnly,PixelFormat.Format24bppRgb);
            var dd=dst.LockBits(rect,ImageLockMode.WriteOnly,PixelFormat.Format24bppRgb);
            byte[] a=new byte[sd.Stride*src.Height],o=new byte[dd.Stride*src.Height];
            Marshal.Copy(sd.Scan0,a,0,a.Length);
            for(int y=0;y<src.Height;y++)for(int x=0;x<src.Width;x++){
                int i=y*sd.Stride+x*3,j=y*dd.Stride+x*3;
                double r=a[i+2]/255.0,g=a[i+1]/255.0,b=a[i]/255.0;
                double hi=Math.Max(r,Math.Max(g,b)),lo=Math.Min(r,Math.Min(g,b));
                double l=(hi+lo)/2,d=hi-lo;
                // Lock UI, deepest original ink, clean cream paper and near-neutral highlights.
                if(UI(x,y,id)||hi<=.24||d<.022||(l>.84&&r>=g&&g>=b)){
                    o[j]=a[i];o[j+1]=a[i+1];o[j+2]=a[i+2];continue;
                }
                double s=d/(1-Math.Abs(2*l-1));
                double h=hi==r?60*((g-b)/d%6):hi==g?60*((b-r)/d+2):60*((r-g)/d+4);
                if(h<0)h+=360;
                double nh=h,ns=s,ink=Smooth(.24,.36,hi);
                bool face=Face(x,y,id);
                // Deliberate pigment-specific recoloring; no uniform saturation factor.
                if(h<65||h>=345){
                    if(h>=345||h<9){nh=HueMix(h,350,.20);ns=s*.73;} // red -> muted burgundy
                    else {
                        double hot=Smooth(.28,.72,s);
                        double factor=face?.90:Mix(.84,.57,hot);
                        // Fire witch clothes, flame and hair are the loudest original group.
                        bool fire=id==1?Box(x,y,445,25,832,352):Box(x,y,1160,480,1375,759);
                        if(fire&&!face)factor*=.93;
                        ns=s*factor;
                        nh=HueMix(h,h<27?29:39,face?.08:.25);
                    }
                } else if(h>=65&&h<160){
                    ns=s*.89; // retain olive skin and subdued living green identity
                    if(l<.29)nh=HueMix(h,240,.24*(1-Smooth(.17,.29,l)));
                } else if(h>=160&&h<225){
                    nh=HueMix(h,218,.32);ns=s*.83; // teal -> quiet blue-teal
                    if(l<.34)nh=HueMix(nh,238,.34*(1-Smooth(.15,.34,l)));
                } else if(h>=225&&h<265){
                    nh=HueMix(h,244,.13);
                    ns=s*(l>.67?.93:.96); // clean lavender snow / alive indigo shadows
                } else {
                    // Quiet original pure violet/magenta into ink violet, never gray.
                    nh=HueMix(h,265,.32);
                    ns=s*(l>.72?.84:.78);
                }
                // Deep colored shadows grouped toward midnight indigo/plum; original ink stays exact.
                if(l<.29&&s>.12){
                    double target=(h>=265||h<25)?267:242;
                    nh=HueMix(nh,target,.24*(1-Smooth(.15,.29,l)));
                }
                nh=HueMix(h,nh,ink);ns=Mix(s,ns,ink);
                // Exact original HSL lightness preserves every value step and texture edge.
                double q=l<.5?l*(1+ns):l+ns-l*ns,p=2*l-q;
                double rr=Channel(p,q,nh/360+1.0/3),gg=Channel(p,q,nh/360),bb=Channel(p,q,nh/360-1.0/3);
                o[j]=B(bb);o[j+1]=B(gg);o[j+2]=B(rr);
            }
            Marshal.Copy(o,0,dd.Scan0,o.Length);src.UnlockBits(sd);dst.UnlockBits(dd);
            dst.Save(output,ImageFormat.Png);
        }
    }
    public static void Sheet(string a,string b,string c,string d,string output){
        using(var dst=new Bitmap(3840,2160,PixelFormat.Format24bppRgb))
        using(var g=Graphics.FromImage(dst)){
            string[] paths={a,b,c,d};
            for(int n=0;n<4;n++)using(var im=new Bitmap(paths[n]))g.DrawImageUnscaled(im,(n%2)*1920,(n/2)*1080);
            dst.Save(output,ImageFormat.Png);
        }
    }
}
'@
$sourceDir = Join-Path $taskRoot 'art/concepts/lobby/game-style-v01'
$outputDir = Join-Path $taskRoot 'art/concepts/lobby/game-style-v02'
[LobbyPaletteV02]::Recolor((Join-Path $sourceDir '01-story-edge.png'), (Join-Path $outputDir '01-story-edge.png'), 1)
[LobbyPaletteV02]::Recolor((Join-Path $sourceDir '02-winter-inn-window.png'), (Join-Path $outputDir '02-winter-inn-window.png'), 2)
[LobbyPaletteV02]::Sheet((Join-Path $sourceDir '01-story-edge.png'),(Join-Path $outputDir '01-story-edge.png'),(Join-Path $sourceDir '02-winter-inn-window.png'),(Join-Path $outputDir '02-winter-inn-window.png'),(Join-Path $outputDir 'sheet.png'))
Write-Output 'Wrote 2 original-resolution RGB PNGs and 3840x2160 comparison sheet.'
$qa = [ordered]@{}
$qa['01'] = [LobbyPaletteV02]::Verify((Join-Path $sourceDir '01-story-edge.png'),(Join-Path $outputDir '01-story-edge.png'),1) | ConvertFrom-Json
$qa['02'] = [LobbyPaletteV02]::Verify((Join-Path $sourceDir '02-winter-inn-window.png'),(Join-Path $outputDir '02-winter-inn-window.png'),2) | ConvertFrom-Json
$qa | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 (Join-Path $outputDir 'drafts/pixel-qa.json')
$qa | ConvertTo-Json -Depth 5 | Write-Output

