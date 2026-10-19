param([string]$Root = (Get-Location).Path)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
public static class JobPictogramPrep {
    public static void Prepare(string source, string target, string name) {
        using (Bitmap original = new Bitmap(source))
        using (Bitmap flat = new Bitmap(original.Width, original.Height, PixelFormat.Format32bppArgb)) {
            Color ink = Color.FromArgb(42,26,18), cream = Color.FromArgb(252,231,176);
            Color accent = name == "gatherer" ? Color.FromArgb(194,72,55) : Color.FromArgb(216,216,220);
            Color[] palette = name == "warrior" ? new Color[]{ink,cream} : new Color[]{ink,cream,accent};
            int left=original.Width, top=original.Height, right=-1, bottom=-1;
            for (int y=0; y<original.Height; y++) for (int x=0; x<original.Width; x++) {
                Color c=original.GetPixel(x,y);
                if (c.A <= 1) continue;
                int best=int.MaxValue; Color chosen=ink;
                foreach (Color p in palette) {
                    int d=(c.R-p.R)*(c.R-p.R)+(c.G-p.G)*(c.G-p.G)+(c.B-p.B)*(c.B-p.B);
                    if (d < best) {best=d; chosen=p;}
                }
                flat.SetPixel(x,y,Color.FromArgb(c.A,chosen));
                left=Math.Min(left,x); right=Math.Max(right,x); top=Math.Min(top,y); bottom=Math.Max(bottom,y);
            }
            if (right<left) throw new Exception("Empty source: "+source);
            int width=right-left+1, height=bottom-top+1;
            double scale=108.0/Math.Max(width,height);
            int dw=(int)Math.Round(width*scale), dh=(int)Math.Round(height*scale);
            using (Bitmap final=new Bitmap(128,128,PixelFormat.Format32bppArgb)) {
                using (Graphics g=Graphics.FromImage(final))
                using (ImageAttributes attr=new ImageAttributes()) {
                    g.Clear(Color.Transparent);
                    g.CompositingMode=CompositingMode.SourceCopy;
                    g.CompositingQuality=CompositingQuality.HighQuality;
                    g.InterpolationMode=InterpolationMode.HighQualityBicubic;
                    g.PixelOffsetMode=PixelOffsetMode.HighQuality;
                    attr.SetWrapMode(WrapMode.TileFlipXY);
                    g.DrawImage(flat,new Rectangle((128-dw)/2,(128-dh)/2,dw,dh),left,top,width,height,GraphicsUnit.Pixel,attr);
                }
                final.Save(target,ImageFormat.Png);
            }
        }
    }
    public static Bitmap Resize(Bitmap source,int size) {
        Bitmap result=new Bitmap(size,size,PixelFormat.Format32bppArgb);
        using(Graphics g=Graphics.FromImage(result)) {
            g.Clear(Color.Transparent);
            g.InterpolationMode=InterpolationMode.HighQualityBicubic;
            g.PixelOffsetMode=PixelOffsetMode.HighQuality;
            g.DrawImage(source,new Rectangle(0,0,size,size),0,0,source.Width,source.Height,GraphicsUnit.Pixel);
        }
        return result;
    }
    public static int[] Bounds(Bitmap img) {
        int left=img.Width,top=img.Height,right=-1,bottom=-1;
        for(int y=0;y<img.Height;y++) for(int x=0;x<img.Width;x++) if(img.GetPixel(x,y).A>0) {
            left=Math.Min(left,x);right=Math.Max(right,x);top=Math.Min(top,y);bottom=Math.Max(bottom,y);
        }
        return new int[]{left,top,right,bottom};
    }
}
'@
$names = @('warrior','hunter','lumberjack','gatherer')
$badgeColors = @('#FF8573','#8CEBB3','#FFC766','#C7B8FF')
$rows = @()
foreach ($name in $names) {
    $source = Join-Path $Root "art/ui/job-pictograms-v01/$name-generated.png"
    $target = Join-Path $Root "godot/assets/ui/jobs/$name.png"
    [JobPictogramPrep]::Prepare($source,$target,$name)
    $img = [System.Drawing.Bitmap]::FromFile($target)
    try {
        $corners = @($img.GetPixel(0,0).A,$img.GetPixel(127,0).A,$img.GetPixel(0,127).A,$img.GetPixel(127,127).A)
        $edge = @()
        for ($i=0;$i -lt 128;$i++) { $edge += $img.GetPixel($i,0).A,$img.GetPixel($i,127).A,$img.GetPixel(0,$i).A,$img.GetPixel(127,$i).A }
        $bytes = [System.IO.File]::ReadAllBytes($target)
        $bounds = [JobPictogramPrep]::Bounds($img)
        $passed = $img.Width -eq 128 -and $img.Height -eq 128 -and $bytes[25] -eq 6 -and ($corners | Measure-Object -Sum).Sum -eq 0 -and ($edge | Measure-Object -Sum).Sum -eq 0
        $rows += [ordered]@{
            path="godot/assets/ui/jobs/$name.png"; width=$img.Width; height=$img.Height
            channels='RGBA'; png_color_type=[int]$bytes[25]; pixel_format=$img.PixelFormat.ToString()
            corner_alpha=$corners; full_border_alpha_zero=(($edge | Measure-Object -Sum).Sum -eq 0)
            alpha_bounds_inclusive=$bounds; sha256=(Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant(); passed=$passed
        }
    } finally { $img.Dispose() }
}

# A contact sheet only: circles and checkerboards never enter the game assets.
$sheet = New-Object System.Drawing.Bitmap(960,630)
$g = [System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.ColorTranslator]::FromHtml('#171322'))
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$font = New-Object System.Drawing.Font('Segoe UI',13)
$small = New-Object System.Drawing.Font('Segoe UI',10)
$titleFont = New-Object System.Drawing.Font('Segoe UI',19,[System.Drawing.FontStyle]::Bold)
$light = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#FCE7B0'))
$muted = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#B9AEC7'))
$g.DrawString('WITCH''S LODGE / JOB PICTOGRAMS v01',$titleFont,$light,30,20)
$g.DrawString('128 x 128 RGBA  |  generated artwork + palette / size normalization',$small,$muted,30,54)
for($i=0;$i -lt 4;$i++) {
    $x=40+230*$i
    $img=[System.Drawing.Bitmap]::FromFile((Join-Path $Root "godot/assets/ui/jobs/$($names[$i]).png"))
    try {
        $g.DrawString($names[$i],$font,$light,$x,86)
        for($cy=0;$cy -lt 8;$cy++) { for($cx=0;$cx -lt 8;$cx++) {
            $shade = if(($cx+$cy)%2 -eq 0){'#36303F'}else{'#282331'}
            $brush=New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($shade))
            $g.FillRectangle($brush,$x+16*$cx,118+16*$cy,16,16); $brush.Dispose()
        }}
        $g.DrawImage($img,[System.Drawing.Rectangle]::new($x,118,128,128))
        $g.DrawString('Actual size: 20 px',$small,$muted,$x,275)
        $tiny=[JobPictogramPrep]::Resize($img,20)
        try {
            $base=[System.Drawing.ColorTranslator]::FromHtml($badgeColors[$i])
            $dark=[System.Drawing.Color]::FromArgb([int][Math]::Round($base.R*.65),[int][Math]::Round($base.G*.65),[int][Math]::Round($base.B*.65))
            $brush=New-Object System.Drawing.SolidBrush($dark)
            $g.FillEllipse($brush,$x,306,28,28);$brush.Dispose()
            $pen=New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#D6B368'),1)
            $g.DrawEllipse($pen,$x,306,28,28);$pen.Dispose()
            $g.DrawImageUnscaled($tiny,$x+4,310)
            $g.DrawString($badgeColors[$i]+' x 0.65',$small,$muted,$x+36,310)
            $g.DrawString('20 px / contrast checks',$small,$muted,$x,380)
            for($j=0;$j -lt 4;$j++) {
                $base=[System.Drawing.ColorTranslator]::FromHtml($badgeColors[$j])
                $dark=[System.Drawing.Color]::FromArgb([int][Math]::Round($base.R*.65),[int][Math]::Round($base.G*.65),[int][Math]::Round($base.B*.65))
                $brush=New-Object System.Drawing.SolidBrush($dark)
                $g.FillEllipse($brush,$x+42*$j,416,28,28);$brush.Dispose()
                $g.DrawImageUnscaled($tiny,$x+42*$j+4,420)
            }
            $g.DrawString('Dark navy-purple background',$small,$muted,$x,478)
            $g.DrawImageUnscaled($tiny,$x+4,510)
        } finally {$tiny.Dispose()}
    } finally {$img.Dispose()}
}
$g.DrawString('Circles appear only in this preview. Game PNGs contain the isolated tools and transparent alpha.',$small,$muted,30,585)
$g.Dispose();$font.Dispose();$small.Dispose();$titleFont.Dispose();$light.Dispose();$muted.Dispose()
$sheet.Save((Join-Path $Root 'godot/screenshots/party-frames/job-pictograms-sheet.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$sheet.Dispose()
$report = [ordered]@{
    generated_at='2026-10-19'; generator='built-in image_gen.imagegen'; transparent_background=$true
    postprocessing='Preserve alpha; nearest flat palette at source size; proportional bicubic resize into centered 108px bounds on 128px RGBA canvas.'
    files=$rows; visual_review=[ordered]@{passed=$false;status='pending sheet inspection'}
    godot_import=[ordered]@{exit_code=$null;status='pending'}; passed=$false
}
$report | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 (Join-Path $Root 'output/job-pictograms-v01/verification.json')
$rows | ForEach-Object { [pscustomobject]$_ } | Format-Table path,width,height,channels,passed
