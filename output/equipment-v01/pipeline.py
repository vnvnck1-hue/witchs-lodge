from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import hashlib, json, shutil, sys

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'output/equipment-v01'
ART = ROOT / 'art/cards/equipment-v01'
IDS = ['rusty_longsword', 'oak_staff', 'quilted_gambeson', 'traveler_boots', 'rowan_charm']

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def save(im, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path)

def package():
    records = read(OUT / 'generation-results.json')
    files = []
    for record in records:
        target = ART / 'drafts' / (record['id'] + '-' + record['attempt'] + '.png')
        shutil.copy2(record['source'], target)
        record['preserved_source'] = target.relative_to(ROOT).as_posix()
        record['source_sha256'] = sha(target)
    write(OUT / 'generation-results.json', records)
    mask = Image.new('L', (4096, 6144), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, 4095, 6143), radius=160, fill=255)
    mask = mask.resize((1024, 1536), Image.Resampling.LANCZOS)
    for card_id in IDS:
        record = next(r for r in records if r['id'] == card_id and r['selected'])
        im = Image.open(ROOT / record['preserved_source']).convert('RGBA')
        assert im.size == (1024, 1536)
        # The generated stock is slightly translucent. Only alpha is normalized;
        # original RGB, lettering, frame, and artwork remain pixel-identical.
        im.putalpha(mask)
        for rel in [f'art/cards/equipment-v01/{card_id}.png', f'godot/assets/cards/{card_id}.png']:
            save(im, ROOT / rel)
            files.append(rel)
        rel = f'godot/assets/cards/hand/{card_id}.png'
        save(im.resize((256, 384), Image.Resampling.LANCZOS), ROOT / rel)
        files.append(rel)
        review = Image.new('RGB', (1024, 816), '#201b2e')
        review.paste(im.crop((0, 0, 1024, 380)), (0, 0))
        review.paste(im.crop((0, 1120, 1024, 1536)), (0, 400))
        save(review, OUT / f'review-{card_id}.png')
    write(OUT / 'delivery-files.json', files)
    font = ImageFont.truetype('C:/Windows/Fonts/malgun.ttf', 26)
    small = ImageFont.truetype('C:/Windows/Fonts/malgun.ttf', 18)
    sheet = Image.new('RGB', (2240, 1110), '#211b30')
    draw = ImageDraw.Draw(sheet)
    draw.text((24, 14), '장비 카드 5종 · 기존 유물 2종 비교', font=font, fill='#f5e9cf')
    for i, card_id in enumerate(IDS + ['moonlit_charm', 'wolf_fang_pendant']):
        x = 24 + i * 316
        draw.text((x, 61), card_id, font=small, fill='#f1e6d1')
        im = Image.open(ROOT / f'godot/assets/cards/{card_id}.png').convert('RGBA')
        im = im.resize((288, 432), Image.Resampling.LANCZOS)
        sheet.paste(im, (x, 98), im)
    draw.text((24, 554), '손패 실제 크기 256×384 · 밝은 바탕에서 외곽 알파 확인', font=font, fill='#f5e9cf')
    for i, card_id in enumerate(IDS):
        tile = Image.new('RGBA', (280, 408), '#dcd5df')
        tile.alpha_composite(Image.open(ROOT / f'godot/assets/cards/hand/{card_id}.png'), (12, 12))
        sheet.paste(tile.convert('RGB'), (24 + i * 316, 608))
    approved = Image.open(ROOT / 'art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png').convert('RGBA')
    approved = approved.resize((256, 384), Image.Resampling.LANCZOS)
    sheet.paste(approved, (1630, 620), approved)
    draw.text((1920, 730), '장비·유물', font=font, fill='#f5e9cf')
    draw.text((1920, 775), '승인 포맷', font=font, fill='#f5e9cf')
    draw.text((24, 1050), '그림·문구는 내장 image_gen 생성. RGB 보존 / 카드지 알파 정규화 / LANCZOS 1/4 축소.', font=small, fill='#e2d9cc')
    save(sheet, ROOT / 'godot/screenshots/equipment-cards/sheet.png')
    project = OUT / 'import-project'
    project.mkdir(exist_ok=True)
    (project / 'project.godot').write_text('config_version=5\n[application]\nconfig/name="Equipment Image Import"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n', encoding='utf-8')
    for rel in files:
        if rel.startswith('godot/'):
            target = project / rel.removeprefix('godot/')
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / rel, target)
    lines = ['# 장비 카드 v01 · 실제 생성 프롬프트와 참고 입력', '', '2026-10-19 · 내장 `image_gen`만 사용. 매 호출 `transparent_background=true`, 아래 파일들을 `referenced_image_paths`의 실제 이미지 입력으로 전달했다.', '', '이미지 순서는 각 호출의 목록 순서다. 승인 장비·유물 PNG와 기존 `moonlit_charm`, `wolf_fang_pendant`, `old_spellbook`을 8회 모두 전달했다. `old_spellbook`은 질감 참고이며 마름모 창은 사용하지 않았다.', '']
    for record in records:
        lines += [f"## {record['id']} · {record['attempt']}", '', f"채택: {record['selected']} · 사유: {record['reason']}", '', '실제 참고 입력:']
        lines += [f'{i + 1}. `{p}`' for i, p in enumerate(record['entry']['refs'])]
        lines += ['', '```text', record['entry']['prompt'], '```', '', f"가공 전 생성본: `{record['preserved_source']}`", f"SHA-256: `{record['source_sha256']}`", '']
    lines += ['## 납품 후처리', '', '생성 원본 8개를 drafts에 그대로 보존했다. 채택한 5개의 RGB와 글자를 그대로 유지하고, 약한 내부 반투명을 불투명 카드지로 정규화했다. 40px 라운드 외곽은 4배 해상도 마스크로 안티앨리어싱했다. 게임용은 원본 크기 1024×1536, 손패용은 LANCZOS로 256×384로만 균등 축소했다. 원화·글자에 코드 합성이나 교체는 하지 않았다.', '', '제목 2줄·설명 4줄 여백과 한글 문구는 1:1 검수 이미지 및 전체 시트로 직접 확인한다. 모든 언어의 동적 텍스트 수용이나 픽셀 단위 프레임 마스크 검증을 의미하지 않는다.', '']
    path = ROOT / 'docs/prompts/cards/equipment-v01-prompts.md'
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text('\n'.join(lines), encoding='utf-8')
    print('Packaged 15 PNGs, preserved 8 generated sources; sheet and isolated image project ready.')

def verify():
    files = []
    for rel in read(OUT / 'delivery-files.json'):
        path = ROOT / rel
        im = Image.open(path)
        w, h = im.size
        a = im.getchannel('A')
        corners = [a.getpixel(p) for p in [(0, 0), (w-1, 0), (0, h-1), (w-1, h-1)]]
        expected = (256, 384) if '/hand/' in rel else (1024, 1536)
        center = a.getpixel((w//2, h//2))
        outer = [a.getpixel(p) for p in [(0, 0), (w-1, 0), (0, h-1), (w-1, h-1)]]
        ok = im.size == expected and im.mode == 'RGBA' and corners == [0]*4 and center == 255
        files.append(dict(path=rel, width=w, height=h, mode=im.mode, channels=list(im.getbands()), corner_alpha=corners, center_alpha=center, sha256=sha(path), passed=ok))
    backups = []
    for card_id in IDS:
        for part in ['', 'hand/']:
            path = ART / 'placeholder-backup' / part / (card_id + '.png')
            im = Image.open(path)
            a = im.getchannel('A') if 'A' in im.getbands() else None
            w,h = im.size
            backups.append(dict(path=path.relative_to(ROOT).as_posix(), width=w, height=h, mode=im.mode, channels=list(im.getbands()), corner_alpha=[a.getpixel(p) for p in [(0,0),(w-1,0),(0,h-1),(w-1,h-1)]] if a else None, sha256=sha(path), passed=im.size==((256,384) if part else (1024,1536))))
    records = read(OUT / 'generation-results.json')
    rgb_checks = []
    for card_id in IDS:
        record = next(r for r in records if r['id']==card_id and r['selected'])
        raw = Image.open(ROOT / record['preserved_source']).convert('RGB').tobytes()
        game = Image.open(ROOT / f'godot/assets/cards/{card_id}.png').convert('RGB').tobytes()
        rgb_checks.append(dict(id=card_id, raw_rgb_preserved=raw==game, art_equals_game=sha(ART/(card_id+'.png'))==sha(ROOT/f'godot/assets/cards/{card_id}.png')))
    changes = []
    before = read(OUT / 'protected-before.json')
    for entry in before:
        path = Path(entry['path'])
        after = sha(path) if path.exists() else None
        if after is None or after.lower() != entry['sha256'].lower():
            changes.append(dict(path=str(path), before=entry['sha256'], after=after))
    imports = read(OUT / 'import-result.json')
    textures = read(OUT / 'import-project/texture-verification.json')
    visual = read(OUT / 'visual-review.json')
    result = dict(date='2026-10-19', files=files, placeholder_backups=backups, source_rgb_checks=rgb_checks, import_result=imports, imported_textures=textures, visual_review=visual, protected_files_checked=len(before), protected_changes_observed=changes, protected_write_policy='Only the five authorized card IDs, their sidecars/cache, task artifacts, sheet, prompt log, and appended handoff are written. No protected files are written or reverted. Concurrent-session changes are observations only; no commit or EXE export.')
    result['passed'] = all(f['passed'] for f in files+backups) and all(c['raw_rgb_preserved'] and c['art_equals_game'] for c in rgb_checks) and imports['exit_code']==0 and textures['passed'] and visual['passed']
    write(OUT / 'verification.json', result)
    print(json.dumps(dict(files=len(files), backups=len(backups), passed=result['passed'], protected_changes_observed=len(changes)), ensure_ascii=False))
    assert result['passed']

if __name__ == '__main__':
    {'package': package, 'verify': verify}[sys.argv[1]]()
