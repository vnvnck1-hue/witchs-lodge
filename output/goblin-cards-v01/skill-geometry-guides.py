from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json
OUT=Path(__file__).resolve().parent
plan=json.loads((OUT/'generation-plan.json').read_text('utf-8'))
for e in plan:
    if e['role']!='skill': continue
    im=Image.new('RGB',(1024,1536),'#79608e');d=ImageDraw.Draw(im)
    d.rounded_rectangle((50,35,974,328),radius=70,fill='#fff0cf',outline='black',width=14)
    d.rounded_rectangle((50,1105,974,1500),radius=60,fill='#fff0cf',outline='black',width=14)
    d.polygon([(512,340),(892,720),(512,1100),(132,720)],fill='#494154',outline='black',width=22)
    d.line([(512,340),(892,720),(512,1100),(132,720),(512,340)],fill='#fff0cf',width=7)
    for text,fs,y in [(e['title'],65,125),(e['category'],36,285),(e['lines'][0],43,1275),(e['lines'][1],43,1335)]:
        d.text((512,y),text,font=ImageFont.truetype('C:/Windows/Fonts/malgunbd.ttf',fs),anchor='mm',fill='black')
    p=OUT/'geometry-guides'/f'{e["id"]}.png';p.parent.mkdir(exist_ok=True);im.save(p)
