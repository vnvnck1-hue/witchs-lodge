using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;

public static class LegendPackage {
  public static byte[] Read(Bitmap b) {
    var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
    byte[] a=new byte[d.Stride*d.Height];Marshal.Copy(d.Scan0,a,0,a.Length);b.UnlockBits(d);return a;
  }
  static void Write(Bitmap b,byte[] a) {
    var d=b.LockBits(new Rectangle(0,0,b.Width,b.Height),ImageLockMode.WriteOnly,PixelFormat.Format32bppArgb);
    Marshal.Copy(a,0,d.Scan0,a.Length);b.UnlockBits(d);
  }
  public static Bitmap Scale(Bitmap b,int w,int h) {
    var r=new Bitmap(w,h,PixelFormat.Format32bppArgb);
    using(var g=Graphics.FromImage(r))using(var attr=new ImageAttributes()){
      g.CompositingMode=CompositingMode.SourceCopy;g.CompositingQuality=CompositingQuality.HighQuality;
      g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;
      attr.SetWrapMode(WrapMode.TileFlipXY);
      g.DrawImage(b,new Rectangle(0,0,w,h),0,0,b.Width,b.Height,GraphicsUnit.Pixel,attr);
    }return r;
  }
  public static Bitmap Mask(bool resource,bool badge) {
    var m=new Bitmap(1024,1536,PixelFormat.Format32bppArgb);
    using(var g=Graphics.FromImage(m))using(var p=new GraphicsPath()){
      g.Clear(Color.Black);g.SmoothingMode=SmoothingMode.None;
      if(badge){
        if(resource) {
          p.StartFigure();p.AddLine(451,1026,575,1026);p.AddBezier(575,1026,611,1026,628,1050,628,1089);
          p.AddBezier(628,1089,628,1135,609,1153,575,1153);p.AddLine(575,1153,450,1153);
          p.AddBezier(450,1153,415,1153,399,1135,399,1089);p.AddBezier(399,1089,399,1050,415,1026,451,1026);p.CloseFigure();g.FillPath(Brushes.White,p);
        } else {
          g.FillEllipse(Brushes.White,419,1018,186,146);
          g.FillPolygon(Brushes.Black,new Point[]{new Point(378,1094),new Point(414,1076),new Point(435,1094),new Point(414,1111)});
          g.FillPolygon(Brushes.Black,new Point[]{new Point(590,1094),new Point(615,1076),new Point(652,1094),new Point(615,1111)});
        }
      }else if(resource){
        p.StartFigure();p.AddLine(157,317,867,317);
        p.AddBezier(867,317,936,317,976,348,976,396);
        p.AddLine(976,396,976,944);
        p.AddBezier(976,944,976,1037,915,1088,820,1088);
        p.AddLine(820,1088,647,1088);
        p.AddBezier(647,1088,644,1040,621,1016,579,1016);
        p.AddLine(579,1016,451,1016);
        p.AddBezier(451,1016,409,1016,387,1040,383,1088);
        p.AddLine(383,1088,204,1088);
        p.AddBezier(204,1088,101,1088,48,1037,48,944);
        p.AddLine(48,944,48,396);
        p.AddBezier(48,396,48,348,89,317,157,317);p.CloseFigure();g.FillPath(Brushes.White,p);
      }else{
        p.StartFigure();p.AddBezier(190,232,300,270,405,293,512,293);
        p.AddBezier(512,293,625,293,730,270,834,232);
        p.AddBezier(834,232,927,271,985,335,987,423);
        p.AddBezier(987,423,998,614,983,773,927,902);
        p.AddBezier(927,902,903,951,904,982,919,1023);
        p.AddBezier(919,1023,933,1054,944,1080,928,1104);
        p.AddBezier(928,1104,896,1153,811,1157,677,1157);
        p.AddLine(677,1157,660,1147);
        p.AddBezier(660,1147,647,1123,630,1120,618,1128);
        p.AddBezier(618,1128,638,1077,590,1005,524,1005);
        p.AddLine(524,1005,512,975);p.AddLine(512,975,499,1005);
        p.AddBezier(499,1005,433,1005,385,1077,405,1128);
        p.AddBezier(405,1128,392,1120,374,1123,362,1147);
        p.AddLine(362,1147,346,1157);
        p.AddBezier(346,1157,212,1157,127,1153,95,1104);
        p.AddBezier(95,1104,80,1080,91,1054,104,1023);
        p.AddBezier(104,1023,119,982,120,951,96,902);
        p.AddBezier(96,902,41,773,25,614,36,423);
        p.AddBezier(36,423,38,335,96,271,190,232);p.CloseFigure();g.FillPath(Brushes.White,p);
        // Gold badge sparkle tips belong to the frame, never to the artwork.
        g.FillPolygon(Brushes.Black,new Point[]{new Point(378,1094),new Point(414,1076),new Point(435,1094),new Point(414,1111)});
        g.FillPolygon(Brushes.Black,new Point[]{new Point(590,1094),new Point(615,1076),new Point(652,1094),new Point(615,1111)});
      }
    } return m;
  }
  public static void Preview(string basePath,string outPath,bool resource){
    using(var b=new Bitmap(basePath))using(var a=Mask(resource,false))using(var badge=Mask(resource,true)){
      byte[] d=Read(b),m=Read(a),q=Read(badge);
      for(int i=0;i<d.Length;i+=4)if(m[i]>0||q[i]>0){d[i]=220;d[i+1]=210;d[i+2]=0;}
      Write(b,d);b.Save(outPath,ImageFormat.Png);
      a.Save(outPath.Replace(".png","-art-mask.png"),ImageFormat.Png);
      badge.Save(outPath.Replace(".png","-badge-mask.png"),ImageFormat.Png);
    }
  }
  public static long[] Compose(string basePath,string picturePath,string draftPath,string outputPath,bool resource){
    int side=picturePath.Contains("fire_brazier")?900:974;int left=(1024-side)/2;
    using(var b=new Bitmap(basePath))using(var raw=new Bitmap(picturePath))using(var draft=new Bitmap(draftPath))
    using(var main=resource?(Bitmap)draft.Clone():Scale(raw,side,side))using(var artMask=Mask(resource,false))using(var badgeMask=Mask(resource,true)){
      byte[] dst=Read(b),src=Read(main),ico=Read(draft),a=Read(artMask),q=Read(badgeMask);long ac=0,bc=0;
      for(int y=0;y<1536;y++)for(int x=0;x<1024;x++){
        int i=(y*1024+x)*4;
        if(a[i]>127){int j=resource?i:(Math.Min(side-1,Math.Max(0,y-250))*side+Math.Min(side-1,Math.Max(0,x-left)))*4;for(int c=0;c<3;c++)dst[i+c]=src[j+c];ac++;}
        if(q[i]>127){for(int c=0;c<3;c++)dst[i+c]=ico[i+c];bc++;}
      }
      Write(b,dst);b.Save(outputPath,ImageFormat.Png);
      return new long[]{ac,bc};
    }
  }
  public static long[] Verify(string basePath,string filePath,bool resource){
    using(var b=new Bitmap(basePath))using(var f=new Bitmap(filePath))using(var a=Mask(resource,false))using(var q=Mask(resource,true)){
      var x=Read(b);var y=Read(f);var m=Read(a);var n=Read(q);long preserved=0,alpha=0,changed=0;
      for(int i=0;i<x.Length;i+=4){bool diff=false;for(int c=0;c<4;c++)if(x[i+c]!=y[i+c])diff=true;
        if(x[i+3]!=y[i+3])alpha++;if(diff){changed++;if(m[i]==0&&n[i]==0)preserved++;}
      }return new long[]{preserved,alpha,changed};
    }
  }
  public static long[] VerifyHand(string basePath,string handPath,bool resource){
    using(var b=new Bitmap(basePath))using(var f=new Bitmap(handPath))using(var expected=Scale(b,256,384))using(var a=Mask(resource,false))using(var q=Mask(resource,true)){
      var x=Read(expected);var y=Read(f);var m=Read(a);var n=Read(q);long preserved=0,alpha=0;
      for(int py=0;py<384;py++)for(int px=0;px<256;px++){
        int i=(py*256+px)*4;bool allowed=false;
        for(int yy=Math.Max(0,py*4-8);yy<=Math.Min(1535,py*4+11)&&!allowed;yy++)
          for(int xx=Math.Max(0,px*4-8);xx<=Math.Min(1023,px*4+11);xx++)if(m[(yy*1024+xx)*4]>0||n[(yy*1024+xx)*4]>0){allowed=true;break;}
        if(x[i+3]!=y[i+3])alpha++;
        if(!allowed){for(int c=0;c<4;c++)if(x[i+c]!=y[i+c]){preserved++;break;}}
      }return new long[]{preserved,alpha};
    }
  }
  public static void Sheet(string root,string path){
    string[] ids={"frost_crown","lich_crown","wild_grimoire","fire_brazier","winter_bell","ore","drunken_erin","timber"};
    string[] labels={"서리 여왕의 왕관","망자의 왕관","폭주하는 마법서","불의 정령 화로","겨울의 끝 종","광석","비교 · 에린 전설 틀","비교 · 목재 자원 틀"};
    using(var canvas=new Bitmap(1184,1030,PixelFormat.Format32bppArgb))using(var g=Graphics.FromImage(canvas))
    using(var title=new Font("Malgun Gothic",22,FontStyle.Bold))using(var label=new Font("Malgun Gothic",12,FontStyle.Regular))using(var small=new Font("Consolas",10)){
      g.Clear(Color.FromArgb(255,27,21,43));g.TextRenderingHint=System.Drawing.Text.TextRenderingHint.AntiAliasGridFit;
      g.DrawString("마녀산장 · 전설 5종 + 광석",title,Brushes.White,30,16);
      g.DrawString("256 × 384 실제 손패 크기 · 게임 글자 미인쇄 · 2026-10-25",label,Brushes.LightGray,32,61);
      for(int k=0;k<ids.Length;k++){
        int x=32+(k%4)*288,y=100+(k/4)*453;
        using(var b=new Bitmap(System.IO.Path.Combine(root,"godot/assets/cards/hand/"+ids[k]+".png"))){
          g.DrawImageUnscaled(b,x,y);
        }
        g.DrawString(labels[k],label,Brushes.White,x,y+391);g.DrawString(ids[k],small,Brushes.LightGray,x,y+416);
      }
      g.DrawString("프레임·빈 글자판은 기준 PNG 보존 / 원화·아이콘만 교체",label,Brushes.LightGray,32,1000);
      canvas.Save(path,ImageFormat.Png);
    }
  }
}
