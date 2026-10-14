"""Numerical terrain blend masks from the real runtime prop layout.
The artwork is built-in imagegen; this script only encodes placement weights.
R: tree/shrub moss beds, G: rock/log contact wear. Not albedo artwork.
"""
import json,math,hashlib
from pathlib import Path
import numpy as np
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT.parent/'output/painted-ground'
ASSETS=ROOT/'assets/ground'
data=json.loads((OUT/'ground-layout.json').read_text(encoding='utf-8'))
N=2048
x0,z0,w,h=data['mask_bounds']
x=np.linspace(x0,x0+w,N,dtype=np.float32)[None,:]
z=np.linspace(z0,z0+h,N,dtype=np.float32)[:,None]
forest=np.zeros((N,N),dtype=np.float32)
wear=np.zeros_like(forest)
for p in data['props']:
    kind=p['id'];px,pz=p['position'];s=p['scale']
    if kind.startswith('pine'):
        target=forest;rx=3.30*s;rz=2.85*s;gain=.94
    elif kind in ['berry_shrub','fern_clump']:
        target=forest;rx=1.45*s;rz=1.1*s;gain=.82
    elif kind=='fallen_log':
        target=forest;rx=2.7*s;rz=1.35*s;gain=.78
    elif kind.startswith('rock'):
        target=wear;rx=2.0*s;rz=1.75*s;gain=.88
    else:continue
    # Smooth compact-support foot beds, evaluated only in a local bounding box.
    ix0=max(0,int((px-rx*1.65-x0)/w*(N-1)));ix1=min(N,int((px+rx*1.65-x0)/w*(N-1))+1)
    iz0=max(0,int((pz-rz*1.65-z0)/h*(N-1)));iz1=min(N,int((pz+rz*1.65-z0)/h*(N-1))+1)
    d=np.sqrt(((x[:,ix0:ix1]-px)/rx)**2+((z[iz0:iz1,:]-pz)/rz)**2)
    t=np.clip((d-.25)/1.30,0,1)
    mask=(1-t*t*(3-2*t))*gain
    target[iz0:iz1,ix0:ix1]=np.maximum(target[iz0:iz1,ix0:ix1],mask)
rgb=np.stack([forest,wear,np.zeros_like(forest)],axis=-1)
Image.fromarray((rgb*255).astype(np.uint8),'RGB').save(ASSETS/'prop_blend_mask.png')
manifest={'version':1,'artwork_tool':'imagegen built-in','references':['11_Ice_Peake.jpg','15_Magic_Forest.jpg','16_Forest.jpg'],
          'props_in_layout':len(data['props']),'mask_resolution':[N,N],'mask_bounds':data['mask_bounds'],
          'mask_channels':{'R':'tree, shrub, log forest bed','G':'rock contact wear','B':'unused'},'textures':[]}
for name in ['painted_snow_v1.png','painted_trail_v1.png','painted_forest_v1.png','prop_blend_mask.png']:
    p=ASSETS/name
    manifest['textures'].append({'file':name,'size':list(Image.open(p).size),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(OUT/'asset-manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf-8')
print('GROUND_MASK_READY',len(data['props']),'props')
