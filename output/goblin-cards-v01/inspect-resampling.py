from pathlib import Path
from PIL import Image,ImageChops,ImageStat
import json
ROOT=Path(__file__).resolve().parents[2]
for id in ['junk_sack','scrap']:
    im=Image.open(ROOT/f'godot/assets/cards/{id}.png')
    actual=Image.open(ROOT/f'godot/assets/cards/hand/{id}.png')
    results=[]
    for name in ['NEAREST','BILINEAR','BICUBIC','LANCZOS','BOX','HAMMING']:
        expected=im.resize((256,384),getattr(Image.Resampling,name))
        diff=ImageChops.difference(actual,expected)
        results.append(dict(filter=name,mean_error=ImageStat.Stat(diff).mean,max_error=[b for a,b in diff.getextrema()],interior_mean=ImageStat.Stat(diff.crop((12,12,244,372))).mean))
    print(json.dumps(dict(id=id,results=results)))
