from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import hashlib,json,shutil
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'output/goblin-cards-v01'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
records=[]
sheet=Image.new('RGB',(1400,1100),'#231d30');d=ImageDraw.Draw(sheet)
f=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',24)
for row,id in enumerate(['junk_sack','scrap']):
    d.text((20,20+row*540),id+' · 요청서 기준 원본 / 동시 세션 현재 게임용',font=f,fill='#fff0cf')
    for col,rel in enumerate([f'art/cards/goblin-v01/{id}.png',f'godot/assets/cards/{id}.png']):
        im=Image.open(ROOT/rel).convert('RGBA');im.thumbnail((300,450))
        sheet.paste(im,(20+col*350,65+row*540),im)
    for part in ['', 'hand/']:
        rel=f'godot/assets/cards/{part}{id}.png';p=ROOT/rel
        snap=OUT/'concurrent-observed'/part/f'{id}-{sha(p)[:12]}.png'
        snap.parent.mkdir(parents=True,exist_ok=True)
        if not snap.exists(): shutil.copy2(p,snap)
        expected=OUT/'import-project'/rel.removeprefix('godot/')
        records.append(dict(id=id,path=rel,delivered_sha256=sha(expected),observed_sha256=sha(p),modified_unix=p.stat().st_mtime,observed_copy=snap.relative_to(ROOT).as_posix(),matches_delivered=sha(p)==sha(expected)))
sheet.save(OUT/'concurrent-comparison.png')
result=dict(note='Other session replaced two authorized card IDs after original packaging/import. These PNGs are observed and preserved, not overwritten by this task. scrap now prints 쇠붙이 rather than requested 고물.',files=records)
(OUT/'concurrent-conflicts.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Preserved four concurrent runtime PNG versions and comparison evidence.')
