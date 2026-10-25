from pathlib import Path
from PIL import Image, ImageFilter
import numpy as np
import json

D = Path(__file__).resolve().parent
src = Image.open(D / 'lobby_characters-source.png').convert('RGB')
gen = Image.open(D / '01-characters-imagegen.png').convert('RGBA').resize((2640,1080),Image.Resampling.LANCZOS)
# Low-resolution patch correspondence, no source pixels are transformed.
s = np.asarray(src.resize((960,540)).convert('L'), dtype=np.float32)
g = np.asarray(gen.resize((1320,540)).convert('L'), dtype=np.float32)
records = []
for yy in range(12,530,24):
    for xx in [12,32,56]:
        template = s[yy-8:yy+9,xx-8:xx+9]
        template = template-template.mean()
        best = (-2,None,None)
        for dy in range(-32,33):
            cy=yy+dy
            if cy<8 or cy>=532: continue
            for dx in range(-32,33):
                cx=360+xx+dx
                patch=g[cy-8:cy+9,cx-8:cx+9]
                p=patch-patch.mean()
                score=float(np.sum(p*template)/np.sqrt(np.sum(p*p)*np.sum(template*template)+1e-8))
                if score>best[0]: best=(score,dx*2,dy*2)
        records.append({'x':xx*2,'y':yy*2,'score':best[0],'dx':best[1],'dy':best[2]})
(D/'alignment-points.json').write_text(json.dumps(records,indent=2),encoding='utf-8')
print(json.dumps(records))
