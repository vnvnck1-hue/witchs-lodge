"""Authorized medal PNG post-processing only. Never invokes Godot or Git.

Writes only medal_frame.png and this handoff's frame-* artifacts.
"""
from pathlib import Path
import argparse
import hashlib
import json
import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
DRAFTS = HERE / 'frame-drafts'
FINAL = ROOT / 'godot/assets/ui/moon_runes/common/medal_frame.png'


def dump(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def sample(a, x, y):
    x = np.clip(x, 0, a.shape[1] - 1)
    y = np.clip(y, 0, a.shape[0] - 1)
    ix, iy = x.astype(int), y.astype(int)
    jx, jy = np.minimum(ix + 1, a.shape[1] - 1), np.minimum(iy + 1, a.shape[0] - 1)
    fx, fy = (x - ix)[..., None], (y - iy)[..., None]
    return ((a[iy, ix] * (1 - fx) + a[iy, jx] * fx) * (1 - fy)
            + (a[jy, ix] * (1 - fx) + a[jy, jx] * fx) * fy)


def build():
    config = json.loads((DRAFTS / 'geometry-source.json').read_text(encoding='utf-8'))
    source = np.array(Image.open(DRAFTS / config['source']).convert('RGBA')).astype(np.float32)
    h, w = source.shape[:2]
    cx, cy = config.get('center', [w / 2, h / 2])
    # Trace source inner/outer alpha boundaries without painting replacement artwork.
    angles = np.arange(4096) * 2 * np.pi / 4096
    radii = np.arange(w * .28, w * .56, .25)
    sx = np.clip(np.rint(cx + np.cos(angles[:, None]) * radii - .5).astype(int), 0, w-1)
    sy = np.clip(np.rint(cy + np.sin(angles[:, None]) * radii - .5).astype(int), 0, h-1)
    valid = source[sy, sx, 3] >= 128
    assert valid.any(axis=1).all(), 'Every ray must intersect the source ring'
    inner = radii[valid.argmax(axis=1)]
    outer = radii[len(radii) - 1 - valid[:, ::-1].argmax(axis=1)]
    # Optional measured hardware centers regularize angle/radius while retaining pixels.
    centers = config.get('rivet_centers_clockwise_from_right', [])
    has_centers = bool(centers)
    if has_centers:
        centers = np.array(centers, dtype=float)
        ra = np.unwrap(np.arctan2(centers[:, 1]-cy, centers[:, 0]-cx))
        ra = np.mod(ra[0], 2*np.pi) + (ra-ra[0])
        rr = np.hypot(centers[:, 0]-cx, centers[:, 1]-cy)
        ta = np.arange(len(centers)) * 2*np.pi/len(centers)
    # Supersample only the resampling; final alpha is an exact concentric annulus.
    scale = 3
    yy, xx = np.mgrid[:512*scale, :512*scale]
    x, y = (xx+.5)/scale-256, (yy+.5)/scale-256
    r = np.hypot(x, y)
    theta = np.mod(np.arctan2(y, x), 2*np.pi)
    if has_centers:
        source_theta = np.interp(theta, np.r_[ta, 2*np.pi], np.r_[ra, ra[0]+2*np.pi])
        source_middle = np.interp(theta, np.r_[ta, 2*np.pi], np.r_[rr, rr[0]])
    else:
        source_theta = theta
    source_theta %= 2*np.pi
    ir = np.interp(source_theta, np.r_[angles, 2*np.pi], np.r_[inner, inner[0]])
    ou = np.interp(source_theta, np.r_[angles, 2*np.pi], np.r_[outer, outer[0]])
    if has_centers:
        src_r = np.where(r < 219, ir+(source_middle-ir)*(r-192)/27,
                         source_middle+(ou-source_middle)*(r-219)/27)
    else:
        src_r = ir+(ou-ir)*(r-192)/54
    src_r = np.clip(src_r, ir+.35, ou-.35)
    pixels = sample(source[:, :, :3], cx+np.cos(source_theta)*src_r-.5,
                    cy+np.sin(source_theta)*src_r-.5)
    rgb = pixels.reshape(512, scale, 512, scale, 3).mean(axis=(1,3))
    yy, xx = np.mgrid[:512, :512]
    radius = np.hypot(xx+.5-256, yy+.5-256)
    alpha = np.rint(255*np.clip((radius-192)*2, 0, 1)*np.clip((246-radius)*2, 0, 1)).astype(np.uint8)
    rgb = np.clip(np.rint(rgb), 0, 255).astype(np.uint8)
    rgb[alpha == 0] = 0
    final = Image.fromarray(np.dstack((rgb, alpha)))
    final.save(FINAL)
    sheet(final)
    verify()


def font(size):
    return ImageFont.truetype('C:/Windows/Fonts/malgun.ttf', size)


def portrait_composite(frame):
    portrait = Image.open(ROOT / 'godot/assets/portraits/guest_graz_cutout.png').convert('RGBA')
    # Face-centered crop for preview only; original portrait remains untouched.
    portrait = portrait.crop((260, 225, 1010, 975)).resize((512, 512), Image.Resampling.LANCZOS)
    yy, xx = np.mgrid[:512, :512]
    radius = np.hypot(xx+.5-256, yy+.5-256)
    mask = np.clip((194-radius)*255, 0, 255).astype(np.uint8)
    a = np.array(portrait)
    a[:, :, 3] = np.minimum(a[:, :, 3], mask)
    base = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
    backing = np.zeros((512, 512, 4), dtype=np.uint8)
    backing[:, :, :3] = (42, 26, 46)
    backing[:, :, 3] = mask
    base.alpha_composite(Image.fromarray(backing))
    base.alpha_composite(Image.fromarray(a))
    base.alpha_composite(frame)
    base.save(DRAFTS / 'portrait-composite.png')
    return base


def sheet(frame):
    canvas = Image.new('RGB', (1680, 1360), '#e9dfcd')
    draw = ImageDraw.Draw(canvas)
    draw.text((40, 25), '손님 초상 메달 틀 · 512 × 512 RGBA', font=font(32), fill='#2a1a2e')
    draw.text((40, 76), '나무 띠 + 놋쇠 테 + 균등한 리벳 16개 | 중앙·외부 투명', font=font(22), fill='#604332')
    for i, (bg, text_color, label, asset) in enumerate([
        ('#21182f', '#f6e0ba', '틀 단독 · 어두운 배경', frame),
        ('#f7efdc', '#2a1a2e', '틀 단독 · 밝은 배경', frame),
        ('#6d6b8a', '#fff4d9', '그라즈 얼굴 위 합성 예', portrait_composite(frame)),
    ]):
        x = 30 + i*550
        draw.rounded_rectangle((x, 128, x+530, 730), radius=16, fill=bg)
        draw.text((x+18, 147), label, font=font(23), fill=text_color)
        canvas.paste(asset, (x+9, 200), asset)
    draw.text((40, 764), '목표 시안 비교 · 실제 UI 축소 크기', font=font(27), fill='#2a1a2e')
    ref = Image.open(ROOT / 'docs/handoff/refs/speech-medal-concept-crop3x.png').convert('RGB')
    ref.thumbnail((390, 350), Image.Resampling.LANCZOS)
    canvas.paste(ref, (40, 825))
    draw.text((40, 1200), '시안 발췌 (읽기 전용 참고)', font=font(21), fill='#604332')
    for i, size in enumerate([256, 128, 96]):
        x = 485 + i*365
        draw.rounded_rectangle((x, 825, x+330, 1175), radius=12, fill='#33273e')
        thumb = frame.resize((size, size), Image.Resampling.LANCZOS)
        canvas.paste(thumb, (x+(330-size)//2, 850+(280-size)//2), thumb)
        draw.text((x+28, 1200), f'{size} × {size} px', font=font(23), fill='#604332')
    draw.text((40, 1280), '외경 492px · 내경 384px · 띠 54px · 중심 (256, 256) | 미리보기 문구·배경은 게임 PNG에 없음',
              font=font(21), fill='#604332')
    canvas.save(HERE / 'frame-sheet.png')


def verify():
    im = Image.open(FINAL)
    a = np.array(im)
    yy, xx = np.mgrid[:512, :512]
    r = np.hypot(xx+.5-256, yy+.5-256)
    alpha = a[:, :, 3]
    # Measure real bright nail-head components, excluding the inner/outer brass rims.
    bright = (a[:,:,0]>195)&(a[:,:,1]>135)&(a[:,:,2]>50)&(r>209)&(r<229)
    rivets = []
    while bright.any():
        y, x = np.argwhere(bright)[0]
        stack, points = [(y,x)], []
        bright[y,x] = False
        while stack:
            y,x = stack.pop()
            points.append((int(y),int(x)))
            for dy,dx in ((1,0),(-1,0),(0,1),(0,-1)):
                ny,nx = y+dy,x+dx
                if 0<=ny<512 and 0<=nx<512 and bright[ny,nx]:
                    bright[ny,nx] = False
                    stack.append((ny,nx))
        if len(points)>=4:
            py,px = np.mean(points,axis=0)
            rivets.append({'angle':float(np.degrees(np.arctan2(py+.5-256,px+.5-256))%360),
                           'highlight_pixels':len(points)})
    rivets.sort(key=lambda p:p['angle'])
    measured_angles = np.array([p['angle'] for p in rivets])
    gaps = np.diff(np.r_[measured_angles, measured_angles[0]+360]) if rivets else np.array([])
    checks = {
        'size_512x512': im.size == (512,512), 'RGBA': im.mode == 'RGBA',
        'center_hole_alpha_zero': bool((alpha[r <= 192] == 0).all()),
        'outside_alpha_zero': bool((alpha[r >= 246] == 0).all()),
        'band_fully_opaque': bool((alpha[(r >= 192.5)&(r <= 245.5)] == 255).all()),
        'transparent_RGB_zero': bool((a[alpha == 0, :3] == 0).all()),
        'alpha_quarter_turn_symmetric': bool(np.array_equal(alpha, np.rot90(alpha))),
        'bounds_10_10_502_502': im.getbbox() == (10,10,502,502),
        'measured_16_rivets': len(rivets)==16,
        'rivet_gap_within_1_degree_of_22_5': bool(len(gaps)==16 and np.max(np.abs(gaps-22.5))<1),
    }
    before = json.loads((DRAFTS / 'protected-before.json').read_text(encoding='utf-8-sig'))
    changed, missing = [], []
    for name, old in before.items():
        p = ROOT / name
        if not p.exists(): missing.append(name)
        elif digest(p) != old: changed.append(name)
    protected_roots = ['godot/scripts','godot/scenes','godot/shaders','godot/assets/cards',
                       'godot/assets/ui/moon_runes/extension_v01','godot/assets/ui/moon_runes/approved','docs']
    current = {p.relative_to(ROOT).as_posix() for rel in protected_roots for p in (ROOT/rel).rglob('*') if p.is_file()}
    current.update(p.relative_to(ROOT).as_posix() for p in FINAL.parent.iterdir() if p.is_file() and p.name!='medal_frame.png')
    added = sorted(current-set(before))
    result = {'checks': checks, 'all_asset_checks_pass': all(checks.values()),
              'geometry': {'center':[256,256], 'outer_radius':246, 'inner_radius':192,
                           'band_width':54, 'rivet_count':16, 'rivet_spacing_degrees':22.5},
              'measured_rivet_highlights':rivets,
              'measured_rivet_gap_degrees':gaps.tolist(),
              'final_sha256':digest(FINAL), 'source_sha256':digest(DRAFTS/'frame-edited.png'),
              'protected_observation': {'baseline_count':len(before), 'changed':changed,
                                         'missing':missing, 'added':added,
                                         'all_unchanged':not(changed or missing or added)}}
    dump(HERE/'frame-validation.json', result)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    assert all(checks.values()), 'Asset verification failed'


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices=['build','verify'])
    args = parser.parse_args()
    build() if args.command == 'build' else verify()
