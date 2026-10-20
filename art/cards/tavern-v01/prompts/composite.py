import sys
from PIL import Image, ImageFilter
import numpy as np
for c in sys.argv[1:]:
    t=np.asarray(Image.open(f'tpl_{c}.png').convert('RGB').resize((1024,1536))).astype(np.float32)
    r,g,b=t[...,0],t[...,1],t[...,2]
    k=np.clip(((g-np.maximum(r,b))-60)/(160-60),0,1)        # 1 = green window
    core=k>0.5
    ys,xs=np.where(core); x0,x1,y0,y1=xs.min(),xs.max(),ys.min(),ys.max()
    W,H=x1-x0+1,y1-y0+1
    art=Image.open(f'art_{c}.png').convert('RGB')
    s=max(W/art.width,H/art.height)*1.02
    art=art.resize((round(art.width*s),round(art.height*s)),Image.LANCZOS)
    ox=(art.width-W)//2; oy=(art.height-H)//2
    art=np.asarray(art.crop((ox,oy,ox+W,oy+H))).astype(np.float32)
    full=np.zeros_like(t); full[y0:y1+1,x0:x1+1]=art
    # grow window a bit so antialiased green edge is covered by art, then feather
    m=Image.fromarray((k*255).astype(np.uint8)).filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
    m=np.asarray(m).astype(np.float32)[...,None]/255
    out=t*(1-m)+full*m
    # kill green spill left on border pixels
    gg=out[...,1]; lim=np.maximum(out[...,0],out[...,2])
    spill=(gg>lim+25)&(m[...,0]<0.98)
    out[...,1]=np.where(spill,lim,gg)
    Image.fromarray(out.clip(0,255).astype(np.uint8)).save(f'comp_{c}.png')
    print(c,(x0,y0,x1,y1))
