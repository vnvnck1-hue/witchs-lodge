from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import hashlib, json, shutil, sys

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'output/meat-stew-v01'
ART = ROOT / 'art/cards/meat-stew-v01'
GEN = Path('C:/Users/vnvnc/.codex/generated_images/01a14f45-5000-77a2-8f44-13b70ab3cc5f')
SOURCES = ['exec-3215995b-4150-4e40-8029-15c895736e97.png', 'exec-959a4620-467d-4c5b-a41e-6c9a25e3b9ed.png', 'exec-c89a9030-3eb2-47fa-8aeb-820346102c58.png']
TEXT = ['고기 스튜', '자원 · 모닥불 요리', '켜진 모닥불에서 생고기로 끓입니다.', '다친 용병의 체력을 회복합니다.']

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p, data):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
def save(im,p):
    p.parent.mkdir(parents=True,exist_ok=True)
    im.save(p)
def protected():
    paths=[]
    for folder in ['godot/scripts','godot/scenes','godot/shaders']:
        paths += [p for p in (ROOT/folder).rglob('*') if p.is_file()]
    paths += list((ROOT/'godot/assets/cards').glob('*.png'))
    paths += list((ROOT/'godot/assets/cards/hand').glob('*.png'))
    paths += [ROOT/p for p in ['godot/assets/cards/catalog.json','godot/project.godot','docs/resource-uses-expansion-v01.md','WitchsLodge.exe']]
    return {p.relative_to(ROOT).as_posix():sha(p) for p in paths if p.name!='meat_stew.png'}

def package():
    write(OUT/'protected-before.json', protected())
    (ART/'drafts').mkdir(parents=True,exist_ok=True)
    for src,name in zip(SOURCES[:2],['meat_stew-initial.png','meat_stew-layout-01.png']):
        shutil.copy2(GEN/src, ART/'drafts'/name)
    # Preserve the selected unmodified generated file, including its original alpha.
    shutil.copy2(GEN/SOURCES[2],ART/'meat_stew.png')
    im=Image.open(ART/'meat_stew.png').convert('RGBA')
    assert im.size==(1024,1536)
    # Production-only alpha normalization; RGB illustration and all lettering stay untouched.
    mask=Image.new('L',(4096,6144),0)
    ImageDraw.Draw(mask).rounded_rectangle((0,0,4095,6143),radius=160,fill=255)
    im.putalpha(mask.resize(im.size,Image.Resampling.LANCZOS))
    save(im,ROOT/'godot/assets/cards/meat_stew.png')
    save(im.resize((256,384),Image.Resampling.LANCZOS), ROOT/'godot/assets/cards/hand/meat_stew.png')
    review=Image.new('RGB',(1024,792),'#241e31')
    review.paste(im.crop((0,0,1024,340)),(0,0))
    review.paste(im.crop((0,1120,1024,1536)),(0,376))
    save(review,OUT/'text-review-1to1.png')
    font=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',23)
    small=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',18)
    sheet=Image.new('RGB',(1280,1230),'#251e34'); d=ImageDraw.Draw(sheet)
    d.text((28,18),'고기 스튜 · 자원 포맷 / 생고기·목재 화풍 비교',font=font,fill='#f5e9cd')
    for i,id in enumerate(['meat_stew','raw_meat','timber']):
        x=28+i*416
        d.text((x,62),id,font=small,fill='#f5e9cd')
        card=Image.open(ROOT/f'godot/assets/cards/{id}.png').convert('RGBA').resize((384,576),Image.Resampling.LANCZOS)
        sheet.paste(card,(x,96),card)
    d.text((28,700),'손패 실제 크기 256×384 · 밝고 어두운 바탕 / 승인 자원 포맷',font=font,fill='#f5e9cd')
    hand=Image.open(ROOT/'godot/assets/cards/hand/meat_stew.png')
    for x,color in [(28,'#ddd5e3'),(340,'#15101e')]:
        tile=Image.new('RGBA',(280,408),color);tile.alpha_composite(hand,(12,12));sheet.paste(tile.convert('RGB'),(x,758))
    ref=Image.open(ROOT/'art/concepts/cards/roles-individual-v02/03-resource-timber.png').convert('RGBA').resize((256,384),Image.Resampling.LANCZOS)
    sheet.paste(ref,(700,770),ref)
    d.text((990,850),'승인 목재\n자원 역할\n1024×1536\n→ 256×384',font=small,fill='#f5e9cd',spacing=10)
    save(sheet,ROOT/'godot/screenshots/meat-stew-card/sheet.png')
    plans=[json.loads((OUT/p).read_text(encoding='utf-8')) for p in ['generation-plan.json','repair-plan-01-actual.json','repair-plan-02.json']]
    lines=['# 고기 스튜 v01 · 실제 생성 프롬프트와 납품 처리','','2026-10-18 · 내장 `image_gen` 사용. 세 호출 모두 `transparent_background=true`, `referenced_image_paths`로 실제 입력.','']
    reasons=['첫 생성: 원화·문구 양호. 제목이 크고 분류·표식이 여백을 압박하여 미채택.','1차 보정: 제목 축소가 부족하고 분류가 제목 안전 영역과 겹쳐 미채택.','2차 보정: 제목을 더 줄이고 분류를 아래로, 표식을 축소·상향해 채택.']
    for n,(plan,reason,src) in enumerate(zip(plans,reasons,SOURCES),1):
        lines += [f'## 생성 {n}','','판정: '+reason,'','실제 참고 입력:']+[f'- `{p}`' for p in plan['refs']]+['','실제 프롬프트:','','```text',plan['prompt'],'```','',f'생성 파일: `{GEN/src}`','']
    lines += ['## 보존·후처리·검수','','선택된 생성 원본은 `art/cards/meat-stew-v01/meat_stew.png`에 바이트 그대로 보존했다. 초기·1차 보정은 `drafts/`에 보존. 원본 알파는 전체 카드지에 반투명도가 있어 게임용만 내부 alpha=255와 40px 라운드 모서리 알파로 정규화했다. RGB와 인쇄 글자를 수정하거나 다시 그리지 않았다. 손패는 게임용을 LANCZOS로 256×384 축소했다.','','제목·분류·설명 2줄은 `output/meat-stew-v01/text-review-1to1.png`와 게임용 원본으로 직접 대조했다. 한국어 인쇄 PNG이며 다국어 런타임 구현은 이번 범위가 아니다. 원본 보존 파일의 반투명 알파와 실사용 파일의 라운드 모서리 검증은 구분한다.','']
    p=ROOT/'docs/prompts/cards/meat-stew-v01-prompts.md';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('\n'.join(lines),encoding='utf-8')
    print('Packaged preserved original, 2 drafts, game/hand PNGs, 1:1 text review, comparison sheet and prompts.')

def verify():
    files=[]
    for rel,expected,production in [('art/cards/meat-stew-v01/meat_stew.png',(1024,1536),False),('godot/assets/cards/meat_stew.png',(1024,1536),True),('godot/assets/cards/hand/meat_stew.png',(256,384),True),('godot/screenshots/meat-stew-card/sheet.png',(1280,1230),False)]:
        p=ROOT/rel; im=Image.open(p); w,h=im.size; a=im.getchannel('A') if im.mode=='RGBA' else None
        corners=[a.getpixel(xy) for xy in [(0,0),(w-1,0),(0,h-1),(w-1,h-1)]] if a else None
        center=a.getpixel((w//2,h//2)) if a else None
        inset=w//25+2
        ok=im.size==expected and (not production or (im.mode=='RGBA' and corners==[0]*4 and center==255 and a.crop((inset,inset,w-inset,h-inset)).getextrema()==(255,255)))
        files.append(dict(path=rel,width=w,height=h,mode=im.mode,channels=list(im.getbands()),corner_alpha=corners,center_alpha=center,alpha_range=a.getextrema() if a else None,sha256=sha(p),bytes=p.stat().st_size,production=production,passed=ok))
    before=json.loads((OUT/'protected-before.json').read_text(encoding='utf-8'));after=protected()
    changes=[dict(path=p,before=h,after=after.get(p)) for p,h in before.items() if after.get(p)!=h]
    added=[p for p in after if p not in before]
    import_result=json.loads((OUT/'import-result.json').read_text(encoding='utf-8-sig'))
    visual=json.loads((OUT/'visual-review.json').read_text(encoding='utf-8'))
    sidecars=[dict(path=rel,exists=(ROOT/rel).is_file(),sha256=sha(ROOT/rel) if (ROOT/rel).is_file() else None) for rel in ['godot/assets/cards/meat_stew.png.import','godot/assets/cards/hand/meat_stew.png.import']]
    runtime=json.loads((OUT/'texture-verification.json').read_text(encoding='utf-8'))
    result=dict(date='2026-10-18',files=files,import_result=import_result,import_sidecars=sidecars,godot_texture_verification=runtime,visual_review=visual,protected_files_checked=len(before),protected_changes_observed=changes,protected_added_files=added,protected_write_policy='Only meat_stew deliverables, task documentation/output and authorized Godot import metadata/cache are written. No commits, no export, no reverts. Concurrent changes are reported, never reverted.',notes=['Godot reported Failed to read the root certificate store; local texture import still exited 0.', 'WitchsLodge.exe changed concurrently; this pipeline does not write or export it.'],passed=all(f['passed'] for f in files) and import_result['exit_code']==0 and visual['passed'] and runtime['passed'] and all(x['exists'] for x in sidecars))
    write(OUT/'verification.json',result)
    print(json.dumps({'passed':result['passed'],'protected_changed':len(changes),'protected_added':len(added),'files':len(files)},ensure_ascii=False))
    assert result['passed']

if __name__=='__main__': {'package':package,'verify':verify}[sys.argv[1]]()
