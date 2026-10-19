from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageChops
import json, hashlib, shutil, sys

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'output/goblin-cards-v01'
ART=ROOT/'art/cards/goblin-v01'
def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,obj):
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def save(im,p):
    p.parent.mkdir(parents=True,exist_ok=True)
    im.save(p)
PLAN=read(OUT/'generation-plan.json')
IDS=[e['id'] for e in PLAN]

def package():
    records=read(OUT/'generation-results.json')
    for r in records:
        target=ART/'drafts'/f'{r["id"]}-{r["attempt"]}.png'
        target.parent.mkdir(parents=True,exist_ok=True)
        if not target.exists(): shutil.copy2(r['source'],target)
        r['preserved_source']=target.relative_to(ROOT).as_posix()
        r['source_sha256']=sha(target)
    write(OUT/'generation-results.json',records)
    mask=Image.new('L',(4096,6144),0)
    ImageDraw.Draw(mask).rounded_rectangle((0,0,4095,6143),radius=160,fill=255)
    mask=mask.resize((1024,1536),Image.Resampling.LANCZOS)
    files=[]
    for id in IDS:
        r=next(r for r in records if r['id']==id and r['selected'])
        im=Image.open(ROOT/r['preserved_source']).convert('RGBA')
        assert im.size==(1024,1536),(id,im.size)
        # Normalize only card-stock alpha; no RGB, art or lettering changes.
        im.putalpha(mask)
        for rel in [f'art/cards/goblin-v01/{id}.png',f'godot/assets/cards/{id}.png']:
            save(im,ROOT/rel); files.append(rel)
        rel=f'godot/assets/cards/hand/{id}.png'
        save(im.resize((256,384),Image.Resampling.LANCZOS),ROOT/rel); files.append(rel)
        # Unscaled crops let the reviewer inspect every printed glyph at 1:1.
        review=Image.new('RGB',(1024,816),'#241c32')
        review.paste(im.crop((0,0,1024,380)),(0,0))
        review.paste(im.crop((0,1120,1024,1536)),(0,400))
        save(review,OUT/f'review-{id}.png')
    write(OUT/'delivery-files.json',files)
    project=OUT/'import-project'
    project.mkdir(exist_ok=True)
    (project/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Goblin Card Image Import"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n',encoding='utf-8')
    for rel in files:
        if rel.startswith('godot/'):
            target=project/rel.removeprefix('godot/')
            target.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(ROOT/rel,target)
    verifier=(ROOT/'output/equipment-v01/import-project/verify_textures.gd').read_text('utf-8')
    verifier=verifier.replace('["rusty_longsword", "oak_staff", "quilted_gambeson", "traveler_boots", "rowan_charm"]',json.dumps(IDS)).replace('RESULT %s/10','RESULT %s/26')
    (project/'verify_textures.gd').write_text(verifier,encoding='utf-8')
    lines=['# 고블린 카드 v01 · 실제 생성 프롬프트', '', '2026-10-19 · 내장 `image_gen` 사용. 매 호출 `transparent_background=true`.', '', '매 호출에 역할 승인 PNG, 같은 역할의 게임 카드 1~2장, 고블린 외형 참고 시트를 실제 이미지 입력으로 전달했다. 외형 시트는 다음 6개를 비율 유지 축소·배열한 자료이며, 개별 원화의 색·형태를 바꾸지 않았다.', '']
    lines += [f'- `{p}`' for p in PLAN[0]['source_appearance_refs']]
    lines += ['', '도구의 참고 이미지 최대 5장 제한에 맞춰 외형 자료만 시트로 묶었다. 프레임 기준은 항상 첫 번째 승인 개별 PNG다. 후반 수정에서는 원화 대상과 배치/마름모 도식을 추가하고 같은 역할의 게임 참고를 1장으로 줄여 입력 상한을 지켰다. 도식은 글자 크기·위치·원화창 하단 설명용 보조 입력이며 납품 원화로 사용하지 않았다.', '']
    for r in records:
        lines += [f'## {r["id"]} · {r["attempt"]}', '', f'채택: {r["selected"]} · 사유: {r["reason"]}', '', '실제 참고 입력:']
        lines += [f'{i+1}. `{p}`' for i,p in enumerate(r['entry']['refs'])]
        lines += ['', '```text',r['entry']['prompt'],'```','',f'가공 전 생성본: `{r["preserved_source"]}`',f'SHA-256: `{r["source_sha256"]}`','']
    lines += ['## 납품 후처리', '', '모든 가공 전 생성본을 drafts에 보존했다. 선택본의 RGB·먹선·프레임·인쇄 글자는 변경하지 않았다. 약한 내부 반투명을 불투명 카드지로 정규화하고 40px 라운드 모서리의 바깥을 투명 처리했다. 손패는 LANCZOS로 정확히 1/4 균등 축소했다. 미리보기·원본 크기 글자 검수 이미지는 원화 수정 없이 축소·배열·크롭했다.', '', '한국어 인쇄 PNG 납품이며 다국어 동적 텍스트 구현을 의미하지 않는다.','']
    (ROOT/'docs/prompts/cards/goblin-v01-prompts.md').write_text('\n'.join(lines),encoding='utf-8')
    sheet()
    print('Packaged 39 PNGs, preserved sources, prompts, reviews, sheet, isolated import project.')

def sheet():
    # All delivered cards are shown at the actual 256x384 hand size.
    refs=[]
    for e in PLAN:
        if e['refs'][0] not in refs: refs.append(e['refs'][0])
    items=[(e['id'],f'art/cards/goblin-v01/{e["id"]}.png') for e in PLAN]
    items += [('승인 '+Path(p).stem,p) for p in refs]
    board=Image.new('RGB',(1800,1500),'#231d30'); d=ImageDraw.Draw(board)
    font=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',28)
    label=ImageFont.truetype('C:/Windows/Fonts/malgun.ttf',17)
    d.text((24,15),'고블린 카드 13종 · 승인 역할 포맷 5종',font=font,fill='#f9ecd2')
    d.text((24,58),'카드 256×384 · 균등 축소 · 역할별 프레임 / 실루엣 / 문구 비교',font=label,fill='#ded4e8')
    for i,(name,p) in enumerate(items):
        x=24+(i%6)*296; y=100+(i//6)*450
        d.text((x,y),name,font=label,fill='#f3e8d1')
        im=Image.open(ROOT/p).convert('RGBA').resize((256,384),Image.Resampling.LANCZOS)
        board.paste(im,(x,y+32),im)
    save(board,ROOT/'godot/screenshots/goblin-cards/sheet.png')

def verify():
    files=[]
    for rel in read(OUT/'delivery-files.json'):
        p=ROOT/rel; im=Image.open(p); w,h=im.size
        a=im.getchannel('A'); points=[(0,0),(w-1,0),(0,h-1),(w-1,h-1)]
        corners=[a.getpixel(q) for q in points]
        center=a.getpixel((w//2,h//2))
        expected=(256,384) if '/hand/' in rel else (1024,1536)
        ok=im.size==expected and im.mode=='RGBA' and corners==[0]*4 and center==255
        files.append(dict(path=rel,width=w,height=h,mode=im.mode,channels=list(im.getbands()),corner_alpha=corners,center_alpha=center,sha256=sha(p),passed=ok))
    records=read(OUT/'generation-results.json'); consistency=[]
    for id in IDS:
        r=next(r for r in records if r['id']==id and r['selected'])
        game=Image.open(ROOT/f'godot/assets/cards/{id}.png')
        hand=Image.open(ROOT/f'godot/assets/cards/hand/{id}.png')
        consistency.append(dict(id=id,raw_rgb_preserved=Image.open(ROOT/r['preserved_source']).convert('RGB').tobytes()==game.convert('RGB').tobytes(),art_equals_game=sha(ART/f'{id}.png')==sha(ROOT/f'godot/assets/cards/{id}.png'),hand_exact_uniform_downscale=game.resize((256,384),Image.Resampling.LANCZOS).tobytes()==hand.tobytes()))
    before=read(OUT/'protected-before.json'); changes=[]
    for rel,old in before.items():
        now=sha(ROOT/rel) if (ROOT/rel).exists() else None
        if old!=now: changes.append(dict(path=rel,before=old,after=now))
    imports=read(OUT/'import-result.json'); textures=read(OUT/'import-project/texture-verification.json'); visual=read(OUT/'visual-review.json')
    text_check=read(OUT/'request-text-check.json')
    appendix=read(OUT/'handoff-append.json') if (OUT/'handoff-append.json').exists() else None
    result=dict(date='2026-10-19',files=files,consistency=consistency,import_result=imports,imported_textures=textures,visual_review=visual,request_text_check=text_check,generation_count=len(records),preserved_raw_sources=len(list((ART/'drafts').glob('*.png'))),protected_files_checked=len(before),protected_changes_observed=changes,write_policy='Only 13 authorized card IDs and sidecars/cache, task art/output, preview sheet, prompt log, and appended handoff section. Concurrent changes observed only; no revert, no commit, no EXE export.')
    result['passed']=len(files)==39 and all(f['passed'] for f in files) and all(all(v for k,v in c.items() if k!='id') for c in consistency) and imports['exit_code']==0 and textures['passed'] and visual['passed'] and text_check['passed']
    original_checks=[]
    for id in IDS:
        art=Image.open(ART/f'{id}.png')
        imported_source=OUT/f'import-project/assets/cards/{id}.png'
        imported_hand=OUT/f'import-project/assets/cards/hand/{id}.png'
        original_checks.append(dict(id=id,full_matches_preserved_original=sha(ART/f'{id}.png')==sha(imported_source),hand_matches_uniform_downscale=Image.open(imported_hand).tobytes()==art.resize((256,384),Image.Resampling.LANCZOS).tobytes()))
    result['preserved_delivery_checks']=original_checks
    result['preserved_delivery_passed']=all(all(v for k,v in c.items() if k!='id') for c in original_checks) and textures['passed'] and visual['passed']
    runtime_matches=[]
    for id in IDS:
        for part in ['', 'hand/']:
            rel=f'assets/cards/{part}{id}.png'
            runtime_matches.append(dict(path='godot/'+rel,matches_import_verified_delivery=sha(ROOT/'godot'/rel)==sha(OUT/'import-project'/rel)))
    result['runtime_matches_import_verified_delivery']=runtime_matches
    result['concurrent_conflicts']=read(OUT/'concurrent-conflicts.json') if (OUT/'concurrent-conflicts.json').exists() else None
    result['protected_change_classification']={'authorized_handoff_append':[c for c in changes if c['path']=='docs/handoff/codex-goblin-cards-v01.md'],'other_session_observed':[c for c in changes if c['path']!='docs/handoff/codex-goblin-cards-v01.md']}
    result['runtime_content_issues']=[{'id':c['id'],'issue':'Runtime PNGs differ from preserved request-based delivery; concurrent edits retained. '+('Runtime title is 쇠붙이, requested title is 고물.' if c['id']=='scrap' else 'Runtime illustration was replaced.'),'passed':False} for c in consistency if not c['art_equals_game']]
    if appendix:
        prefix=(ROOT/appendix['path']).read_bytes()[:appendix['original_bytes']]
        appendix['original_prefix_current_sha256']=hashlib.sha256(prefix).hexdigest()
        appendix['passed']=appendix['passed'] and appendix['original_prefix_current_sha256']==appendix['original_sha256']
        result['handoff_append']=appendix
        result['passed']=result['passed'] and appendix['passed']
    write(OUT/'verification.json',result)
    print(json.dumps(dict(files=len(files),passed=result['passed'],protected_changes_observed=len(changes)),ensure_ascii=False))
    assert result['passed']

if __name__=='__main__': {'package':package,'verify':verify,'sheet':sheet}[sys.argv[1]]()
