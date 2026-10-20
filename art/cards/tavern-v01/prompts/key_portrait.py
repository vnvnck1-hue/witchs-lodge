import sys
from PIL import Image, ImageFilter
import numpy as np
src, outs = sys.argv[1], sys.argv[2:]
im=np.asarray(Image.open(src).convert('RGB')).astype(np.float32)
r,g,b=im[...,0],im[...,1],im[...,2]
M=np.array([255,0,255],np.float32)
a=1-np.clip(((np.minimum(r,b)-g)-40)/(170-40),0,1)
fg=np.clip((im-(1-a)[...,None]*M)/np.maximum(a,1e-3)[...,None],0,255)
band=np.asarray(Image.fromarray((a<0.995).astype(np.uint8)*255).filter(ImageFilter.MaxFilter(5)))>0
fix=band&((np.minimum(fg[...,0],fg[...,2])-fg[...,1])>0)
fg[...,2]=np.where(fix,np.minimum(fg[...,2],fg[...,1]),fg[...,2])
fg[...,0]=np.where(fix,np.minimum(fg[...,0],fg[...,1]+np.clip(fg[...,0]-fg[...,2],0,60)),fg[...,0])
a=np.where(a<0.04,0,a)
img=Image.fromarray(np.dstack([fg,a*255]).clip(0,255).astype(np.uint8),'RGBA')
img=img.crop(img.split()[3].point(lambda v:255 if v>20 else 0).getbbox())
W,H=1122,1402; s=min((W-40)/img.width,(H-30)/img.height); img=img.resize((round(img.width*s),round(img.height*s)),Image.LANCZOS)
can=Image.new('RGBA',(W,H),(0,0,0,0)); can.paste(img,((W-img.width)//2,H-img.height-10),img)
for o in outs: can.save(o)
