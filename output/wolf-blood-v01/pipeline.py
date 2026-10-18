from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import hashlib, json, shutil, sys, math

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'output/wolf-blood-v01'
ART = ROOT / 'art/cards/wolf-blood-v01'
CARDS = ['wolf_blood', 'crescent_moon', 'half_moon', 'full_moon']
ICONS = ['wolf_claw', 'wolf_pounce']
TEXT = {
 'wolf_blood': ['늑대의 피', '늑대 수인의 선물 · 변화', '마녀에게 쓰면 잠시 고통스럽습니다.', '달의 힘 세 가지가 주머니에 들어옵니다.'],
 'crescent_moon': ['초승달', '늑대의 피 · 밤의 힘', '밤에 마녀에게 씁니다.', '오늘 밤 공격 속도가 오릅니다.'],
 'half_moon': ['상현달', '늑대의 피 · 밤의 힘', '밤에 마녀에게 씁니다.', '오늘 밤 공격과 이동이 빨라집니다.'],
 'full_moon': ['보름달', '늑대의 피 · 밤의 힘', '밤에 마녀에게 씁니다.', '오늘 밤 늑대로 변신합니다.']
}
def write_json(path, data):
 path.parent.mkdir(parents=True, exist_ok=True)
 path.write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
def digest(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def save(im, path):
 path.parent.mkdir(parents=True, exist_ok=True)
 im.save(path)
def rounded_alpha(size):
 w,h=size; scale=4
 mask=Image.new('L',(w*scale,h*scale),0)
 ImageDraw.Draw(mask).rounded_rectangle((0,0,w*scale-1,h*scale-1), radius=40*scale, fill=255)
 return mask.resize(size, Image.Resampling.LANCZOS)
def package():
 selected=json.loads((OUT/'selected.json').read_text(encoding='utf-8'))
 delivery=[]
 for id in CARDS:
  raw=Image.open(selected[id]['path']).convert('RGBA')
  assert raw.size == (1024,1536)
  shutil.copy2(selected[id]['path'], ART/'drafts'/f'{id}-layout-generated.png')
  # Requested production postprocessing: opaque card stock, antialiased transparent rounded corners.
  # RGB artwork and printed lettering stay untouched. Raw generated outputs are retained above.
  raw.putalpha(rounded_alpha(raw.size))
  for rel in [f'art/cards/wolf-blood-v01/{id}.png',f'godot/assets/cards/{id}.png']:
   save(raw,ROOT/rel); delivery.append(rel)
  rel=f'godot/assets/cards/hand/{id}.png'
  save(raw.resize((256,384),Image.Resampling.LANCZOS),ROOT/rel);delivery.append(rel)
 for id in ICONS:
  raw=Image.open(selected[id]['path']).convert('RGBA')
  # Preserve generated circular cutout alpha; trim transparent margins equally and fit a shared circle diameter.
  bbox=raw.getchannel('A').point(lambda a: 255 if a>=128 else 0).getbbox()
  raw=raw.crop(bbox)
  # Generated icon interiors are also slightly translucent. Restore opacity without losing the cutout edge.
  raw.putalpha(raw.getchannel('A').point(lambda a: min(255, round(a * 255 / 240))))
  side=max(raw.size)
  square=Image.new('RGBA',(side,side))
  square.alpha_composite(raw,((side-raw.width)//2,(side-raw.height)//2))
  icon=Image.new('RGBA',(128,128))
  icon.alpha_composite(square.resize((124,124),Image.Resampling.LANCZOS),(2,2))
  rel=f'godot/assets/ui/skills/{id}.png';save(icon,ROOT/rel);delivery.append(rel)
 write_json(OUT/'delivery-files.json',delivery)
 # 1:1 pixel typography crops for direct visual comparison with the source request.
 for id in CARDS:
  im=Image.open(ROOT/f'godot/assets/cards/{id}.png')
  review=Image.new('RGB',(1024,810),(32,27,46))
  review.paste(im.crop((0,0,1024,340)),(0,0))
  review.paste(im.crop((0,1120,1024,1536)),(0,380))
  save(review,OUT/f'review-{id}.png')
 font=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',25)
 small=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',18)
 sheet=Image.new('RGB',(1900,1410),(29,24,42));d=ImageDraw.Draw(sheet)
 d.text((30,15),'늑대의 피 · 카드 4장 / 기존 카드 비교 / 스킬 아이콘',font=font,fill='#f4e7c8')
 ids=CARDS+['treasure_chest','frost_rune']
 for i,id in enumerate(ids):
  x=30+i*310
  d.text((x,62),id,font=small,fill='#e9decb')
  im=Image.open(ROOT/f'godot/assets/cards/{id}.png').convert('RGBA').resize((288,432),Image.Resampling.LANCZOS)
  sheet.paste(im,(x,100),im)
 d.text((30,568),'손패 실제 크기 256×384 · 밝은 바탕의 알파 합성',font=font,fill='#f4e7c8')
 for i,id in enumerate(CARDS):
  x=30+i*310
  tile=Image.new('RGBA',(280,408),(219,212,224,255))
  tile.alpha_composite(Image.open(ROOT/f'godot/assets/cards/hand/{id}.png'),(12,12))
  sheet.paste(tile.convert('RGB'),(x,620))
 for i,id in enumerate(ICONS):
  x=1310+i*285
  d.text((x,620),id,font=small,fill='#e9decb')
  im=Image.open(ROOT/f'godot/assets/ui/skills/{id}.png')
  sheet.paste(im,(x,665),im)
  mini=im.resize((56,56),Image.Resampling.LANCZOS)
  sheet.paste(mini,(x,835),mini)
  d.text((x,910),'128px / 56px',font=small,fill='#e9decb')
 d.text((30,1080),'같은 역할의 승인 프레임 참고',font=font,fill='#f4e7c8')
 for i,(role,name) in enumerate([('사건','06-event-forbidden-harvest.png'),('스킬','02-skill-warm-welcome.png')]):
  im=Image.open(ROOT/'art/concepts/cards/roles-individual-v02'/name).convert('RGBA').resize((176,264),Image.Resampling.LANCZOS)
  sheet.paste(im,(30+i*310,1120),im)
  d.text((230+i*310,1180),role,font=small,fill='#e9decb')
 save(sheet,ROOT/'godot/screenshots/wolf-blood-cards/sheet.png')
 # Same resource paths as the game, but no game scripts or scenes enter the isolated project.
 project=OUT/'import-project';project.mkdir(exist_ok=True)
 (project/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Wolf Blood Asset Import"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n',encoding='utf-8')
 for rel in delivery:
  if rel.startswith('godot/'):
   dest=project/rel.removeprefix('godot/');dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(ROOT/rel,dest)
 # Exact built-in generation prompts, actual reference paths and per-card regeneration reasons.
 plan=json.loads((OUT/'generation-plan.json').read_text(encoding='utf-8'))
 repairs=json.loads((OUT/'repair-plan.json').read_text(encoding='utf-8'))
 lines=['# 늑대의 피 v01 · 실제 이미지 생성 기록','', '2026-10-18 · 내장 `image_gen` 사용. 모든 호출은 `transparent_background=true`. 참고 이미지는 `referenced_image_paths`로 실제 전달했다.','']
 for s in plan['cards']+plan['icons']:
  lines += [f"## {s['id']} · 첫 생성",'', '실제 참고 입력:']+[f'- `{p}`' for p in s['refs']]+['','```text',s['prompt'],'```','']
  if s['id'] in CARDS:
   r=next(r for r in repairs if r['id']==s['id'])
   lines += ['재생성 이유: 큰 제목과 분류가 제목 2줄 여백을 압박해 제목·설명 크기와 패널 여백을 보완했다. 첫 생성은 `drafts/<id>-initial.png`, 채택한 재생성의 가공 전 원본은 `drafts/<id>-layout-generated.png`에 보존했다.','', '재생성 실제 참고 입력:']+[f'- `{p}`' for p in r['refs']]+['','```text',r['prompt'],'```','']
  else: lines += ['재생성 없음. 생성 원본을 `drafts/<id>-initial.png`에 보존하고, 원형 컷아웃의 안티앨리어싱을 보존하면서 내부 알파를 불투명하게 정규화한 뒤 동일 원형 지름·128×128로 축소했다.','']
 lines += ['## 납품 후처리','', '카드 RGB와 인쇄 글자는 바꾸지 않고, 내부 반투명 알파를 불투명 카드지로 정규화했다. 40px 라운드 외곽을 4배 마스크로 안티앨리어싱하고 손패는 LANCZOS 1/4 축소했다. 아이콘은 생성된 원형 컷아웃 알파를 유지했다. 원본 크기 글자 검수 이미지는 `output/wolf-blood-v01/review-<id>.png`, 전체 비교 시트는 `godot/screenshots/wolf-blood-cards/sheet.png`다.','']
 p=ROOT/'docs/prompts/cards/wolf-blood-v01-prompts.md';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('\n'.join(lines),encoding='utf-8')
 print('Packaged',len(delivery),'PNGs; review sheets and isolated import project ready.')

def verify():
 delivery=json.loads((OUT/'delivery-files.json').read_text())
 files=[]
 for rel in delivery:
  p=ROOT/rel;im=Image.open(p);w,h=im.size;a=im.getchannel('A')
  expected=(128,128) if '/skills/' in rel else (256,384) if '/hand/' in rel else (1024,1536)
  corners=[a.getpixel(xy) for xy in [(0,0),(w-1,0),(0,h-1),(w-1,h-1)]]
  center=a.getpixel((w//2,h//2))
  passed=im.size==expected and im.mode=='RGBA' and corners==[0]*4 and center==255
  files.append(dict(path=rel,width=w,height=h,mode=im.mode,channels=list(im.getbands()),corner_alpha=corners,center_alpha=center,sha256=digest(p),passed=passed))
 before=json.loads((OUT/'protected-before.json').read_text(encoding='utf-8-sig'))
 changed=[{'path':p['path'],'before':p['sha256'],'after':digest(Path(p['path'])) if Path(p['path']).exists() else None} for p in before if not Path(p['path']).exists() or digest(Path(p['path'])).upper()!=p['sha256'].upper()]
 imports=json.loads((OUT/'import-result.json').read_text(encoding='utf-8-sig'))
 visual=json.loads((OUT/'visual-review.json').read_text(encoding='utf-8'))
 runtime=json.loads((OUT/'import-project/texture-verification.json').read_text(encoding='utf-8'))
 result={'date':'2026-10-18','files':files,'import':imports,'godot_texture_verification':runtime,'visual_review':visual,'protected_files_checked':len(before),'protected_changes_observed':changed,'protected_write_policy':'This pipeline writes only new delivery PNGs, their import sidecars/cache, task output/docs, and the appended handoff section. Other sessions may modify protected files; no changes are reverted.','passed':all(f['passed'] for f in files) and imports['exit_code']==0 and runtime['passed'] and visual['passed']}
 write_json(OUT/'verification.json',result)
 print(json.dumps({'files':len(files),'passed':result['passed'],'protected_changes_observed':len(changed)},ensure_ascii=False))
 assert result['passed']

if __name__=='__main__':
 {'package':package,'verify':verify}[sys.argv[1]]()
