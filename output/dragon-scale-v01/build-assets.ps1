$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class DragonScaleAssets {
    static byte[] Pixels(Bitmap image) {
        var data = image.LockBits(new Rectangle(0, 0, image.Width, image.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
        var result = new byte[image.Width * image.Height * 4];
        Marshal.Copy(data.Scan0, result, 0, result.Length);
        image.UnlockBits(data);
        return result;
    }
    static Bitmap FromPixels(byte[] pixels, int width, int height) {
        var image = new Bitmap(width, height, PixelFormat.Format32bppArgb);
        var data = image.LockBits(new Rectangle(0, 0, width, height), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
        Marshal.Copy(pixels, 0, data.Scan0, pixels.Length);
        image.UnlockBits(data);
        return image;
    }
    static Bitmap Resize(Bitmap source, int width, int height) {
        var target = new Bitmap(width, height, PixelFormat.Format32bppArgb);
        using (var graphics = Graphics.FromImage(target))
        using (var attributes = new ImageAttributes()) {
            graphics.CompositingMode = CompositingMode.SourceCopy;
            graphics.CompositingQuality = CompositingQuality.HighQuality;
            graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
            graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;
            attributes.SetWrapMode(WrapMode.TileFlipXY);
            graphics.DrawImage(source, new Rectangle(0, 0, width, height), 0, 0, source.Width, source.Height, GraphicsUnit.Pixel, attributes);
        }
        return target;
    }
    public static void Build(string root) {
        using (var frame = new Bitmap(root + "/godot/assets/cards/rowan_charm.png"))
        using (var generated = new Bitmap(root + "/art/cards/dragon-scale-v01/dragon_scale-generated.png"))
        using (var mask = new Bitmap(1024,1536,PixelFormat.Format32bppArgb))
        using (var path = new GraphicsPath()) {
            if (frame.Width != 1024 || frame.Height != 1536 || generated.Width != 1024 || generated.Height != 1536) throw new Exception("Unexpected source size");
            // Trace the inside of the existing shield, keeping the original gold/ink/purple border.
            path.StartFigure();
            path.AddBezier(107,343, 133,320, 151,299, 170,285);
            path.AddBezier(170,285, 280,327, 744,327, 854,285);
            path.AddBezier(854,285, 876,302, 895,324, 916,343);
            path.AddBezier(916,343, 889,411, 898,715, 813,865);
            path.AddBezier(813,865, 755,993, 659,1039, 587,1067);
            path.AddBezier(587,1067, 546,1082, 526,1095, 512,1103);
            path.AddBezier(512,1103, 495,1088, 477,1081, 437,1066);
            path.AddBezier(437,1066, 355,1034, 267,990, 210,865);
            path.AddBezier(210,865, 126,713, 133,411, 107,343);
            path.CloseFigure();
            using (var graphics = Graphics.FromImage(mask)) {
                graphics.SmoothingMode = SmoothingMode.AntiAlias;
                graphics.FillPath(Brushes.White,path);
            }
            var original = Pixels(frame);
            var art = Pixels(generated);
            var maskBytes = Pixels(mask);
            var result = (byte[])original.Clone();
            for (int y=0;y<1536;y++) for (int x=0;x<1024;x++) {
                int i=(y*1024+x)*4;
                double mix=maskBytes[i+3]/255.0;
                if (mix==0) continue;
                if (x>=220 && x<804 && y>=267 && y<307) continue;
                // Preserve the cream title and the exact black outline immediately below it.
                if(y<340 && x>=150 && x<=874) {
                    int lastCream=-1;
                    int creamRun=0;
                    for(int t=200;t<330;t++) {
                        int q=(t*1024+x)*4;
                        bool cream=original[q+2]>190 && original[q+1]>175 && original[q]>130;
                        if(cream) { lastCream=t; creamRun++; }
                        else if(creamRun>=4) break;
                    }
                    if(lastCream>=0 && y<=lastCream+12) continue;
                }
                // Ignore the image generator's slightly translucent interior; the card is solid.
                for(int c=0;c<3;c++) result[i+c]=(byte)Math.Round(original[i+c]*(1-mix)+art[i+c]*mix);
                result[i+3]=original[i+3];
            }
            using(var final=FromPixels(result,1024,1536)) {
                final.Save(root+"/art/cards/dragon-scale-v01/dragon_scale.png",ImageFormat.Png);
                final.Save(root+"/godot/assets/cards/dragon_scale.png",ImageFormat.Png);
                using(var hand=Resize(final,256,384)) hand.Save(root+"/godot/assets/cards/hand/dragon_scale.png",ImageFormat.Png);
                using(var sheet=new Bitmap(1152,1280,PixelFormat.Format32bppArgb))
                using(var graphics=Graphics.FromImage(sheet))
                using(var newPreview=Resize(final,512,768))
                using(var oldPreview=Resize(frame,512,768))
                using(var newHand=Resize(final,256,384))
                using(var oldHand=Resize(frame,256,384))
                using(var font=new Font("Arial",18,FontStyle.Bold)) {
                    graphics.Clear(Color.FromArgb(255,38,32,50));
                    graphics.DrawString("DRAGON SCALE",font,Brushes.White,32,15);
                    graphics.DrawString("ROWAN CHARM / FRAME REFERENCE",font,Brushes.White,608,15);
                    graphics.DrawImageUnscaled(newPreview,32,58);
                    graphics.DrawImageUnscaled(oldPreview,608,58);
                    graphics.DrawString("256 x 384 / ACTUAL HAND SIZE",font,Brushes.White,32,850);
                    graphics.DrawImageUnscaled(newHand,160,888);
                    graphics.DrawImageUnscaled(oldHand,736,888);
                    sheet.Save(root+"/godot/screenshots/dragon-scale/card-sheet.png",ImageFormat.Png);
                }
            }
            mask.Save(root+"/output/dragon-scale-v01/art-mask.png",ImageFormat.Png);
        }
    }
}
'@
[DragonScaleAssets]::Build((Get-Location).Path)
Write-Output 'Built final card, hand card, comparison sheet, and artwork mask.'
