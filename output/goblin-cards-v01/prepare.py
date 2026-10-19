from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json, hashlib
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'output/goblin-cards-v01'
plan=json.loads((OUT/'generation-plan.json').read_text('utf-8'))
refs=plan[0]['refs'][3:]
sheet=Image.new('RGB',(1800,1300),'#282231')
d=ImageDraw.Draw(sheet)
font=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',20)
for i,p in enumerate(refs):
    im=Image.open(ROOT/p).convert('RGBA')
    im.thumbnail((560,570),Image.Resampling.LANCZOS)
    x=20+(i%3)*600; y=25+(i//3)*640
    d.text((x,y),Path(p).stem,font=font,fill='#fff0d4')
    sheet.paste(im,(x+(560-im.width)//2,y+40),im)
sheet.save(OUT/'goblin-appearance-reference.png')
for e in plan:
    e['source_appearance_refs']=e['refs'][3:]
    e['refs']=e['refs'][:3]+['output/goblin-cards-v01/goblin-appearance-reference.png']
    e['prompt']=e['prompt'].replace('remaining images are goblin appearance references ONLY','image 4 is a contact sheet of ALL SIX goblin appearance references ONLY')
(OUT/'generation-plan.json').write_text(json.dumps(plan,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
protected={}
for folder in ['godot/scripts','godot/scenes','godot/shaders','godot/tools','godot/assets/cards','docs','art/concepts/cards/roles-individual-v02']:
    for p in (ROOT/folder).rglob('*'):
        if p.is_file() and not (folder=='godot/assets/cards' and p.suffix not in ['.png','.json']):
            protected[p.relative_to(ROOT).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
for rel in ['godot/project.godot','WitchsLodge.exe']:
    protected[rel]=hashlib.sha256((ROOT/rel).read_bytes()).hexdigest()
(OUT/'protected-before.json').write_text(json.dumps(protected,indent=2)+'\n',encoding='utf-8')
assert all(not (ROOT/f'godot/assets/cards/{e["id"]}.png').exists() for e in plan)
print('Prepared 13 entries, all new targets, appearance contact sheet, protected snapshot',len(protected))
