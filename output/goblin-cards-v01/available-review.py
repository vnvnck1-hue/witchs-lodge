from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json
OUT=Path(__file__).resolve().parent;ROOT=OUT.parents[1]
records=[json.loads(p.read_text('utf-8')) for p in sorted((OUT/'repairs').glob('*.json'))]
im=Image.new('RGB',(1024*3,430*((len(records)+2)//3)),'#231d30');d=ImageDraw.Draw(im)
f=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',22)
for i,r in enumerate(records):
    p=Path(r['source']);a=Image.open(p).convert('RGB')
    x=i%3*1024;y=i//3*430
    d.text((x+10,y+5),r['id'],font=f,fill='#fff0d0')
    im.paste(a.crop((0,0,1024,380)),(x,y+40))
im.save(OUT/'available-header-review.png')
print(len(records))
