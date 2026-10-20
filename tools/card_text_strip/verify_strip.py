import glob,cv2,numpy as np,os
from pathlib import Path
OUT=Path('output/card-text-strip-v01')
rows=[]
for f in sorted(OUT.glob('cards/*.png'))+sorted(OUT.glob('races/*/*.png')):
    rel=f.relative_to(OUT).as_posix()
    sub=rel[len('cards/'):] if rel.startswith('cards/') else rel
    a=cv2.imread('godot/assets/cards/'+sub,cv2.IMREAD_UNCHANGED).astype(int); b=cv2.imread(str(f),cv2.IMREAD_UNCHANGED).astype(int)
    m=cv2.imread(str(OUT/'masks'/sub),0)
    diff=np.abs(a[...,:3]-b[...,:3]).max(axis=2)
    allowed=cv2.dilate(m,np.ones((31,31),np.uint8))>0
    rows.append((int((diff[~allowed]>0).sum()), int((diff[430:1000]>0).sum()), int((a[...,3]!=b[...,3]).sum()), rel))
rows.sort(reverse=True)
for r in rows[:8]: print(r)
print('outside-mask changes:',sum(r[0]>0 for r in rows),'/',len(rows),' alpha changes:',sum(r[2]>0 for r in rows))
