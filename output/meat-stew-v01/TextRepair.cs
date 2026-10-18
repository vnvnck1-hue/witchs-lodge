using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.IO;
using System.Collections.Generic;

public static class TextRepair {
    static Rectangle[] areas = {new Rectangle(110,72,804,220),new Rectangle(110,1185,804,260)};
    static bool[,] Mask(Bitmap b, Rectangle r, int pad) {
        var core=new bool[b.Width,b.Height]; var seen=new bool[b.Width,b.Height];var m=new bool[b.Width,b.Height];
        for(int y=r.Top;y<r.Bottom;y++) for(int x=r.Left;x<r.Right;x++) {
            var c=b.GetPixel(x,y); core[x,y]=c.R<170 && c.G<170 && c.B<170;
        }
        for(int y=r.Top;y<r.Bottom;y++) for(int x=r.Left;x<r.Right;x++) if(core[x,y]&&!seen[x,y]) {
            var points=new List<Point>();var queue=new Queue<Point>();queue.Enqueue(new Point(x,y));seen[x,y]=true;bool edge=false;
            while(queue.Count>0) {var p=queue.Dequeue();points.Add(p);if(p.X==r.Left||p.X==r.Right-1||p.Y==r.Top||p.Y==r.Bottom-1) edge=true;
                for(int dy=-1;dy<=1;dy++) for(int dx=-1;dx<=1;dx++) {int xx=p.X+dx,yy=p.Y+dy;if(r.Contains(xx,yy)&&core[xx,yy]&&!seen[xx,yy]) {seen[xx,yy]=true;queue.Enqueue(new Point(xx,yy));}}
            }
            if(!edge) foreach(var p in points) for(int dy=-pad;dy<=pad;dy++) for(int dx=-pad;dx<=pad;dx++) if(r.Contains(p.X+dx,p.Y+dy)) m[p.X+dx,p.Y+dy]=true;
        } return m;
    }
    static Rectangle Bounds(Bitmap b, Rectangle r) {
        int x0=r.Right,y0=r.Bottom,x1=-1,y1=-1;
        var m=Mask(b,r,0);
        for(int y=r.Top;y<r.Bottom;y++) for(int x=r.Left;x<r.Right;x++)
            if(m[x,y]&&b.GetPixel(x,y).R<100) {x0=Math.Min(x0,x);y0=Math.Min(y0,y);x1=Math.Max(x1,x);y1=Math.Max(y1,y);}
        return Rectangle.FromLTRB(x0,y0,x1+1,y1+1);
    }
    static void Erase(Bitmap b, Rectangle r) {
        var m=Mask(b,r,3); using(var source=(Bitmap)b.Clone()) {
            for(int y=r.Top;y<r.Bottom;y++) for(int x=r.Left;x<r.Right;x++) if(m[x,y]) {
                double rr=0,gg=0,bb=0,total=0;
                int[,] dirs={{1,0},{-1,0},{0,1},{0,-1},{1,1},{-1,1},{1,-1},{-1,-1}};
                for(int d=0;d<8;d++) for(int dist=1;dist<100;dist++) {
                    int xx=x+dirs[d,0]*dist, yy=y+dirs[d,1]*dist;
                    if(xx<0||yy<0||xx>=b.Width||yy>=b.Height) break;
                    if(!m[xx,yy]) {var c=source.GetPixel(xx,yy);double w=1.0/(dist*dist);rr+=c.R*w;gg+=c.G*w;bb+=c.B*w;total+=w;break;}
                }
                b.SetPixel(x,y,Color.FromArgb(source.GetPixel(x,y).A,(int)Math.Round(rr/total),(int)Math.Round(gg/total),(int)Math.Round(bb/total)));
            }
        }
    }
    static Bitmap Ink(Bitmap source, Rectangle r) {
        var box=Bounds(source,r); box.Inflate(3,3); var m=Mask(source,r,3);
        var ink=new Bitmap(box.Width,box.Height,PixelFormat.Format32bppArgb);
        for(int y=box.Top;y<box.Bottom;y++) for(int x=box.Left;x<box.Right;x++) if(m[x,y]) {
            var c=source.GetPixel(x,y); int a=(int)Math.Round(255*Math.Max(0,Math.Min(1,(250.0-c.R)/242)));
            ink.SetPixel(x-box.Left,y-box.Top,Color.FromArgb(a,8,7,4));
        } return ink;
    }
    static Bitmap Scale(Bitmap src,int w,int h) {
        var dst=new Bitmap(w,h,PixelFormat.Format32bppArgb);
        using(var g=Graphics.FromImage(dst)) {g.CompositingMode=CompositingMode.SourceCopy;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;g.DrawImage(src,new Rectangle(0,0,w,h),new Rectangle(0,0,src.Width,src.Height),GraphicsUnit.Pixel);}
        return dst;
    }
    static void PutInk(Bitmap target,Bitmap source,Rectangle src,int glyphHeight,int top) {
        using(var ink=Ink(source,src)) {
            int h=glyphHeight+6,w=(int)Math.Round(ink.Width*(double)h/ink.Height);
            if(w>800) w=800;
            using(var scaled=Scale(ink,w,h)) using(var g=Graphics.FromImage(target)) g.DrawImageUnscaled(scaled,(1024-w)/2,top-3);
        }
    }
    public static void Run(string root,string generated) {
        string task=Path.Combine(root,"output/meat-stew-v01"),art=Path.Combine(root,"art/cards/meat-stew-v01");
        using(var original=new Bitmap(Path.Combine(art,"drafts/v1-game.png")))
        using(var src=new Bitmap(generated)) using(var final=(Bitmap)original.Clone()) {
            foreach(var r in areas) Erase(final,r);
            PutInk(final,src,new Rectangle(200,65,620,150),108,86);
            PutInk(final,src,new Rectangle(200,217,620,70),44,216);
            PutInk(final,src,new Rectangle(105,1185,810,100),58,1235);
            PutInk(final,src,new Rectangle(110,1290,804,90),58,1320);
            final.Save(Path.Combine(task,"text-repair-preview.png"),ImageFormat.Png);
            using(var diff=new Bitmap(1024,1536)) {
                int outside=0,changed=0;
                for(int y=0;y<1536;y++) for(int x=0;x<1024;x++) if(original.GetPixel(x,y)!=final.GetPixel(x,y)) {
                    bool allowed=false;foreach(var r in areas) if(r.Contains(x,y)) allowed=true;
                    if(!allowed) outside++; changed++;diff.SetPixel(x,y,Color.Magenta);
                }
                diff.Save(Path.Combine(task,"text-repair-diff.png"),ImageFormat.Png);
                File.WriteAllText(Path.Combine(task,"text-repair-pixel-check.json"),"{\"changed_pixels\":"+changed+",\"changed_pixels_outside_text_regions\":"+outside+",\"artwork_frame_badge_alpha_unchanged\":"+(outside==0?"true":"false")+",\"passed\":"+(outside==0?"true":"false")+"}");
                if(outside!=0) throw new Exception("Non-text pixels changed");
            }
            foreach(var spec in new[]{new Rectangle(110,72,804,135),new Rectangle(110,210,804,65),new Rectangle(110,1220,804,80),new Rectangle(110,1310,804,80)}) Console.WriteLine("Final glyph bounds: "+Bounds(final,spec));
        }
    }
    public static void Package(string root) {
        string task=Path.Combine(root,"output/meat-stew-v01"), art=Path.Combine(root,"art/cards/meat-stew-v01/meat_stew.png"),game=Path.Combine(root,"godot/assets/cards/meat_stew.png");
        File.Copy(Path.Combine(task,"text-repair-preview.png"),art,true);File.Copy(art,game,true);
        using(var card=new Bitmap(game)) using(var hand=Scale(card,256,384)) hand.Save(Path.Combine(root,"godot/assets/cards/hand/meat_stew.png"),ImageFormat.Png);
        using(var sheet=new Bitmap(3072,1536,PixelFormat.Format32bppArgb)) {
            using(var g=Graphics.FromImage(sheet)) {g.Clear(Color.FromArgb(36,29,48));int i=0;foreach(var id in new[]{"meat_stew","raw_meat","timber"}) using(var b=new Bitmap(Path.Combine(root,"godot/assets/cards/"+id+".png"))) {g.DrawImageUnscaled(b,1024*i,0);i++;}}
            sheet.Save(Path.Combine(root,"godot/screenshots/meat-stew-card/sheet.png"),ImageFormat.Png);
        }
        using(var crop=new Bitmap(3072,760)) using(var sheet=new Bitmap(Path.Combine(root,"godot/screenshots/meat-stew-card/sheet.png"))) {
            using(var g=Graphics.FromImage(crop)) {g.DrawImage(sheet,new Rectangle(0,0,3072,330),new Rectangle(0,0,3072,330),GraphicsUnit.Pixel);g.DrawImage(sheet,new Rectangle(0,330,3072,430),new Rectangle(0,1106,3072,430),GraphicsUnit.Pixel);}
            crop.Save(Path.Combine(task,"text-review-1to1.png"),ImageFormat.Png);
        }
    }
}
