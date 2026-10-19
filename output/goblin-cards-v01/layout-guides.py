from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json
OUT=Path(__file__).resolve().parent
plan=json.loads((OUT/'generation-plan.json').read_text('utf-8'))
for e in plan:
    im=Image.new('RGB',(1024,1536),'#79608e');d=ImageDraw.Draw(im)
    d.rectangle((65,45,959,330),fill='#fff0cf')
    d.rectangle((65,1120,959,1495),fill='#fff0cf')
    d.rectangle((65,340,959,1110),fill='#494154')
    for text,fs,y in [(e['title'],65,125),(e['category'],36,285),(e['lines'][0],43,1275),(e['lines'][1],43,1335)]:
        f=ImageFont.truetype('C:/Windows/Fonts/malgunbd.ttf',fs)
        d.text((512,y),text,font=f,anchor='mm',fill='#141117')
    p=OUT/'layout-guides'/f'{e["id"]}.png';p.parent.mkdir(exist_ok=True);im.save(p)
print('13 typography position/scale diagrams; not delivery art.')
