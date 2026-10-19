using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
public static class RaceCardImages {
 public static void Normalize(Bitmap image) {
  var bits=image.LockBits(new Rectangle(0,0,image.Width,image.Height),ImageLockMode.ReadWrite,PixelFormat.Format32bppArgb);
  byte[] bytes=new byte[bits.Stride*image.Height];Marshal.Copy(bits.Scan0,bytes,0,bytes.Length);
  for(int y=0;y<image.Height;y++)for(int x=0;x<image.Width;x++){
   double dx=Math.Max(40-(x+0.5),Math.Max(x+0.5-(image.Width-40),0));
   double dy=Math.Max(40-(y+0.5),Math.Max(y+0.5-(image.Height-40),0));
   int alpha=255;if(dx>0 && dy>0)alpha=(int)Math.Round(255*Math.Min(1,Math.Max(0,40.5-Math.Sqrt(dx*dx+dy*dy))));
   bytes[y*bits.Stride+x*4+3]=(byte)alpha;
  }
  Marshal.Copy(bytes,0,bits.Scan0,bytes.Length);image.UnlockBits(bits);
 }
 public static Bitmap Resize(Bitmap image,int w,int h) {
  var result=new Bitmap(w,h,PixelFormat.Format32bppArgb);
  using(var g=Graphics.FromImage(result))using(var a=new ImageAttributes()) {
   g.CompositingMode=CompositingMode.SourceCopy;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.PixelOffsetMode=PixelOffsetMode.HighQuality;
   a.SetWrapMode(WrapMode.TileFlipXY);g.DrawImage(image,new Rectangle(0,0,w,h),0,0,image.Width,image.Height,GraphicsUnit.Pixel,a);
  }return result;
 }
 public static string Hash(Bitmap image,bool ignoreAlpha) {
  var bits=image.LockBits(new Rectangle(0,0,image.Width,image.Height),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
  byte[] bytes=new byte[bits.Stride*image.Height];Marshal.Copy(bits.Scan0,bytes,0,bytes.Length);image.UnlockBits(bits);
  if(ignoreAlpha)for(int i=3;i<bytes.Length;i+=4)bytes[i]=255;
  using(var sha=SHA256.Create())return BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-","").ToLowerInvariant();
 }
}
