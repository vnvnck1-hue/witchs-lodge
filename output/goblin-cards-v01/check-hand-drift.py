from pathlib import Path
from PIL import Image,ImageChops
import json
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'output/goblin-cards-v01'
for id in ['junk_sack','scrap']:
    g=ROOT/f'godot/assets/cards/hand/{id}.png';q=OUT/f'import-project/assets/cards/hand/{id}.png'
    a=Image.open(g);b=Image.open(q)
    diff=ImageChops.difference(a,b)
    counts={k:sum(v!=0 for v in diff.getchannel(k).getdata()) for k in a.getbands()}
    print(json.dumps(dict(id=id,game_mtime=g.stat().st_mtime,import_source_mtime=q.stat().st_mtime,channels_changed=counts,bounds_by_channel={k:diff.getchannel(k).getbbox() for k in a.getbands()})))
