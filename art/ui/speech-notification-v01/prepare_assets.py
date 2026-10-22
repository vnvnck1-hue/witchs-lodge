"""Local, deterministic post-processing for the authorized speech PNG handoff.

Writes only this asset's art directory and the two explicitly named game PNGs.
Never runs Godot, Git, imports, or exports.
"""
from pathlib import Path
import argparse
import hashlib
import json
import shutil

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
DRAFTS = HERE / 'drafts'
COMMON = ROOT / 'godot/assets/ui/moon_runes/common'
REFERENCE = ROOT / 'output/guest-speech-simplified-v02/03-speech-only.png'
PROTECTED = [
    'godot/scripts', 'godot/scenes', 'godot/shaders', 'godot/assets/cards',
    'godot/assets/ui/moon_runes/extension_v01',
    'godot/assets/ui/moon_runes/approved', 'docs', 'WitchsLodge.exe',
]
GEN = Path('C:/Users/vnvnc/.codex/generated_images/01a163cb-8db0-76b1-b5f6-ab99edf3cdb1')
SOURCES = {
    'body-generated.png': GEN / 'exec-f3ca7fc9-91d6-4f68-8224-72c3526445c4.png',
    'tail-generated.png': GEN / 'exec-5ae3a121-f0c6-4523-addb-3b0f82457100.png',
}


def digest(p):
    h = hashlib.sha256()
    with p.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def snapshot():
    result = {}
    for name in PROTECTED:
        p = ROOT / name
        for f in sorted(p.rglob('*')) if p.is_dir() else [p]:
            if f.is_file():
                result[f.relative_to(ROOT).as_posix()] = digest(f)
    # All other files in common are also outside the requested modification scope.
    for f in COMMON.rglob('*'):
        if f.is_file() and f.name not in ('speech_plain.png', 'speech_tail_left.png'):
            result[f.relative_to(ROOT).as_posix()] = digest(f)
    return result


def save_json(name, data):
    (HERE / name).write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def prepare():
    DRAFTS.mkdir(parents=True, exist_ok=True)
    baseline = DRAFTS / 'protected-before.json'
    if not baseline.exists():
        save_json('drafts/protected-before.json', snapshot())
    for name, src in SOURCES.items():
        shutil.copy2(src, DRAFTS / name)
    ref = Image.open(REFERENCE).convert('RGB')
    ref.crop((176, 263, 526, 368)).save(DRAFTS / 'target-reference-crop.png')
    Image.open(ROOT / 'godot/assets/ui/moon_runes/extension_v01/widgets.png').crop(
        (657, 112, 909, 280)).save(DRAFTS / 'widgets-reference-crop.png')
    Image.open(COMMON / 'tooltip_frame.png').save(DRAFTS / 'common-style-reference.png')
    a = np.array(ref)
    paper = np.median(a[325:342, 240:475].reshape(-1, 3), axis=0).astype(int)
    # Pick a literal target-image ink pixel closest to the handoff's approximate ink.
    region = a[270:280, 235:495].astype(int)
    distance = ((region - np.array([58, 34, 64])) ** 2).sum(axis=2)
    iy, ix = np.unravel_index(distance.argmin(), distance.shape)
    ink = region[iy, ix]
    save_json('drafts/palette-samples.json', {
        'reference': REFERENCE.relative_to(ROOT).as_posix(),
        'paper_sample_rectangle': [240, 325, 475, 342],
        'paper_method': 'per-channel median, text-free interior rectangle',
        'paper_rgb': paper.tolist(),
        'ink_sample_xy': [int(ix + 235), int(iy + 270)],
        'ink_rgb': ink.tolist(),
    })
    print('Prepared originals and protected baseline.')


def nine_slice(im, size, margins):
    if isinstance(margins, int):
        margins = (margins,) * 4
    l, t, r, b = margins
    w, h = im.size
    W, H = size
    sx, sy = [0, l, w-r, w], [0, t, h-b, h]
    dx, dy = [0, l, W-r, W], [0, t, H-b, H]
    out = Image.new('RGBA', size)
    for y in range(3):
        for x in range(3):
            tile = im.crop((sx[x], sy[y], sx[x+1], sy[y+1]))
            tile = tile.resize((dx[x+1]-dx[x], dy[y+1]-dy[y]), Image.Resampling.BICUBIC)
            out.paste(tile, (dx[x], dy[y]))
    return out


def normalized_body():
    src = Image.open(DRAFTS / 'body-generated.png').convert('RGBA')
    mask = src.getchannel('A').point(lambda v: 255 if v > 128 else 0)
    src = src.crop(mask.getbbox())
    # Resample the generated corner independently; extend straight edges, rather
    # than distorting a wide generated rectangle into the final body ratio.
    corner = 192
    sx = [0, corner, src.width-corner, src.width]
    sy = [0, corner, src.height-corner, src.height]
    dx, dy = [2, 50, 462, 510], [2, 50, 206, 254]
    out = Image.new('RGBA', (512, 256))
    for y in range(3):
        for x in range(3):
            tile = src.crop((sx[x], sy[y], sx[x+1], sy[y+1]))
            tile = tile.resize((dx[x+1]-dx[x], dy[y+1]-dy[y]), Image.Resampling.LANCZOS)
            out.paste(tile, (dx[x], dy[y]))
    out.save(DRAFTS / 'body-resampled-before-flatten.png')
    return out


def build():
    palette = json.loads((DRAFTS / 'palette-samples.json').read_text(encoding='utf-8'))
    paper = np.array(palette['paper_rgb'], dtype=float)
    ink = np.array(palette['ink_rgb'], dtype=float)
    raw = normalized_body()
    # Preserve the generated silhouette. Turn its broad inner bevel into a
    # quiet ~1px paper lip, and normalize ink thickness to 7px on all sides.
    # A rounded mask derived from the generated alpha is symmetric and halo-free.
    # Standardize the four straight sections for a seam-free 48px nine-slice.
    scale = 4
    high = Image.new('L', (512*scale, 256*scale))
    ImageDraw.Draw(high).rounded_rectangle((2*scale, 2*scale, 510*scale-1, 254*scale-1),
                                          radius=40*scale, fill=255)
    alpha = high.resize((512, 256), Image.Resampling.LANCZOS)
    inner = Image.new('L', high.size)
    ImageDraw.Draw(inner).rounded_rectangle((9*scale, 9*scale, 503*scale-1, 247*scale-1),
                                           radius=33*scale, fill=255)
    inner = inner.resize((512, 256), Image.Resampling.LANCZOS)
    lip = Image.new('L', high.size)
    ImageDraw.Draw(lip).rounded_rectangle((10*scale, 10*scale, 502*scale-1, 246*scale-1),
                                         radius=32*scale, fill=255)
    lip = lip.resize((512, 256), Image.Resampling.LANCZOS)
    # The source is preserved above. Exact flatness and common stroke geometry
    # take priority over the generated large bevel, gradient and uneven alpha.
    rgb = np.broadcast_to(ink, (256, 512, 3)).copy()
    ai = np.array(inner, dtype=float) / 255
    al = np.array(lip, dtype=float) / 255
    lip_color = paper - np.array([12, 15, 16])
    rgb = rgb * (1-ai[..., None]) + lip_color * ai[..., None]
    rgb = rgb * (1-al[..., None]) + paper * al[..., None]
    # Reuse only the generated ink's subtle value variation (under one RGB
    # level); never carry its face gradient into the stretchable paper.
    source_ink_value = np.array(raw.convert('RGB'), dtype=float).mean(axis=2)
    subtle_ink = np.clip((source_ink_value - 40) / 30, -0.7, 0.7)
    rgb += subtle_ink[..., None] * (1-ai[..., None])
    rgba = np.dstack([np.rint(rgb).astype('uint8'), np.array(alpha)])
    # Lanczos support can otherwise deposit alpha=1 on the canvas boundary.
    rgba[:2, :, 3] = 0
    rgba[-2:, :, 3] = 0
    rgba[:, :2, 3] = 0
    rgba[:, -2:, 3] = 0
    # Absolutely flat entire stretchable center including both slice boundaries.
    rgba[48:208, 48:464] = [*paper.astype(int), 255]
    rgba[rgba[:, :, 3] == 0, :3] = 0
    body = Image.fromarray(rgba)
    body.save(COMMON / 'speech_plain.png')

    # Open cream joining tab begins at x60. Ink on ONLY the two left slopes.
    # Body's left origin is local tail x50; its border occupies x52..59.
    # Thus tail ink terminates exactly where body paper begins, with no end cap.
    s = 8
    m = Image.new('L', (96*s, 96*s))
    d = ImageDraw.Draw(m)
    d.polygon([(6*s, 48*s), (60*s, 24*s), (96*s, 24*s),
               (96*s, 72*s), (60*s, 72*s)], fill=255)
    # Retain only the inside half of a 14px contour for a true 7px inset stroke.
    contour = Image.new('L', m.size)
    dc = ImageDraw.Draw(contour)
    dc.line([(60*s, 24*s), (6*s, 48*s), (60*s, 72*s)], fill=255,
            width=14*s, joint='curve')
    cm = np.array(contour)
    cm[:, 60*s:] = 0
    mm = np.array(m)
    rgbhi = np.broadcast_to(paper, (96*s, 96*s, 3)).copy()
    rgbhi[cm > 0] = ink
    # A tiny matching compressed paper lip on the sloping inside edges.
    rgbhi[mm == 0] = 0
    arr = np.dstack([rgbhi.astype('uint8'), mm])
    tail = Image.fromarray(arr).resize((96, 96), Image.Resampling.LANCZOS)
    ta = np.array(tail)
    ta[:, :, 3] = np.minimum(ta[:, :, 3], ta[::-1, :, 3])
    # Exact mirrored pixel rows; x60..95 is a fully flat open joining tab.
    ta = ((ta.astype('uint16') + ta[::-1].astype('uint16')) // 2).astype('uint8')
    ta[:, 60:96, :3] = paper.astype('uint8')
    ta[25:71, 60:96] = [*paper.astype(int), 255]
    ta[ta[:, :, 3] == 0, :3] = 0
    tail = Image.fromarray(ta)
    tail.save(COMMON / 'speech_tail_left.png')
    create_sheet(body, tail)
    verify()


def font(size):
    return ImageFont.truetype('C:/Windows/Fonts/malgun.ttf', size)


def joined(body, tail):
    out = Image.new('RGBA', (body.width+50, body.height))
    out.alpha_composite(body, (50, 0))
    out.alpha_composite(tail, (0, (body.height-96)//2))
    return out


def create_sheet(body, tail):
    sheet = Image.new('RGB', (1440, 1800), '#191323')
    d = ImageDraw.Draw(sheet)
    d.text((40, 22), '손님 말 걸기 · 말풍선 PNG / v01', font=font(28), fill='#F6E8C6')
    d.text((40, 64), '48px 9분할 · 모서리/먹선 고정 · 몸통 + 왼쪽 꼬리 겹침 검수', font=font(19), fill='#C9BBD6')
    for y, bg, fg in [(108, '#2A2037', '#F6E8C6'), (950, '#E9E4DA', '#3A2240')]:
        d.rectangle((20, y, 1419, y+815), fill=bg)
        d.text((40, y+14), '어두운 배경' if y == 108 else '밝은 배경', font=font(20), fill=fg)
        d.text((40, y+51), '원본 512 × 256 + 꼬리 96 × 96', font=font(17), fill=fg)
        sheet.paste(joined(body, tail), (40, y+82), joined(body, tail))
        # Original approved crop is shown next to the new native-size version.
        ref = Image.open(DRAFTS / 'target-reference-crop.png').convert('RGB')
        d.text((660, y+51), '목표 시안 발췌 (원본 크기)', font=font(17), fill=fg)
        sheet.paste(ref, (660, y+90))
        d.text((660, y+218), '몸통 중앙 48..464 / 48..208: 단색 종이 면', font=font(17), fill=fg)
        d.text((660, y+249), '꼬리 오른쪽 x60..95: 먹선 없는 크림 접합부', font=font(17), fill=fg)
        d.text((40, y+350), '가로 2배·세로 1.5배 / 1024 × 384 / 48px 9분할', font=font(17), fill=fg)
        large = joined(nine_slice(body, (1024, 384), 48), tail)
        # Both the overview and separate proofs use native 1:1 pixel scale.
        sheet.paste(large, (40, y+382), large)
    # Full-size light/dark proofs are also retained for pixel-level inspection.
    sheet.save(HERE / 'sheet.png')
    for name, bg in [('dark', '#2A2037'), ('light', '#E9E4DA')]:
        proof = Image.new('RGBA', (1200, 760), bg)
        proof.alpha_composite(joined(body, tail), (35, 30))
        proof.alpha_composite(joined(nine_slice(body, (1024, 384), 48), tail), (35, 330))
        proof.convert('RGB').save(DRAFTS / f'nine-slice-{name}.png')
    enlarged = joined(body, tail).resize((1124, 512), Image.Resampling.NEAREST)
    bg = Image.new('RGBA', enlarged.size, '#594960')
    bg.alpha_composite(enlarged)
    bg.convert('RGB').save(DRAFTS / 'join-inspection-2x.png')


def verify():
    body = Image.open(COMMON / 'speech_plain.png')
    tail = Image.open(COMMON / 'speech_tail_left.png')
    a, t = np.array(body), np.array(tail)
    center = a[48:208, 48:464]
    palette = json.loads((DRAFTS / 'palette-samples.json').read_text(encoding='utf-8'))
    before = json.loads((DRAFTS / 'protected-before.json').read_text(encoding='utf-8'))
    after = snapshot()
    changes = sorted(k for k in before.keys() | after.keys() if before.get(k) != after.get(k))
    comp = np.array(joined(body, tail))
    cy = body.height // 2
    checks = {
        'body_512x256_RGBA': body.size == (512, 256) and body.mode == 'RGBA',
        'tail_96x96_RGBA': tail.size == (96, 96) and tail.mode == 'RGBA',
        'body_exterior_alpha_zero': bool((a[0, :, 3] == 0).all() and (a[-1, :, 3] == 0).all()
                                          and (a[:, 0, 3] == 0).all() and (a[:, -1, 3] == 0).all()),
        'tail_exterior_alpha_zero': bool((t[0, :, 3] == 0).all() and (t[-1, :, 3] == 0).all()
                                          and (t[:, 0, 3] == 0).all()),
        'center_exactly_flat_and_opaque': bool((center == [*palette['paper_rgb'], 255]).all()),
        'tail_right_join_opaque_cream_without_ink': bool((t[25:71, 60:96] == [*palette['paper_rgb'], 255]).all()),
        'tail_vertical_mirror_exact': bool(np.array_equal(t, t[::-1])),
        'alpha_antialiasing_present_body': bool(((a[:, :, 3] > 0) & (a[:, :, 3] < 255)).any()),
        'alpha_antialiasing_present_tail': bool(((t[:, :, 3] > 0) & (t[:, :, 3] < 255)).any()),
        'transparent_pixels_rgb_zero': bool((a[a[:, :, 3] == 0, :3] == 0).all()
                                            and (t[t[:, :, 3] == 0, :3] == 0).all()),
        'join_center_no_remnant_vertical_ink': bool((comp[cy-6:cy+6, 52:100] == [*palette['paper_rgb'], 255]).all()),
    }
    save_json('validation.json', {
        'checks': checks, 'protected_file_count': len(before),
        'protected_observation': {
            'all_hashes_unchanged': not changes,
            'changed_during_work': changes,
            'note': 'Observed differences only. This workflow never writes protected paths; concurrent edits are not reverted.',
        },
        'palette': palette, 'nine_slice_margins': [48]*4,
        'preview_stretch_size': [1024, 384],
        'tail_placement_relative_to_body': [-50, 'body_height / 2 - 48'],
        'outputs': {p.relative_to(ROOT).as_posix(): digest(p) for p in [
            COMMON / 'speech_plain.png', COMMON / 'speech_tail_left.png', HERE / 'sheet.png']},
    })
    print(json.dumps(checks, ensure_ascii=False, indent=2))
    if not all(checks.values()):
        raise SystemExit('Validation failed; inspect validation.json')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['prepare', 'build', 'verify'])
    args = parser.parse_args()
    {'prepare': prepare, 'build': build, 'verify': verify}[args.action]()
