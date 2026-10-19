"""공용 고블린: 니브 텍스처에서 뺀 소품(등짐·멜빵·귀걸이)이 닿던 자리의 칠을 지운다.

남긴 파츠의 삼각형을 텍스처(UV) 공간에 펼쳐 텍셀마다 3D 위치를 구하고, 뺀 파츠 표면에서 RADIUS 안에 있는 텍셀을
같은 파츠의 가장 가까운 '지우지 않은' 텍셀 색으로 채운다(멜빵 자국 → 주변 셔츠·조끼 색).
옷 파츠(셔츠·조끼·목도리·소매)의 갈색 텍셀도 멜빵 그림으로 보고 함께 지운다(거리만으로는 그림 자국이 다 안 잡힌다).
2단계로 니브와 구분되게 옷·머리 색을 바꾼다(RESTYLE 표).
결과: paint_clean.png (parts.json 의 paint_override 로 임포트 때 쓴다), paint_clean_mask.png(지운 자리 확인용).
실행: python -I art_sources/characters/goblin_common/clean_paint.py   (godot/ 기준)
"""
import io, json, pathlib, struct
import numpy as np
from PIL import Image
from scipy.ndimage import distance_transform_edt, binary_dilation
from scipy.spatial import cKDTree

HERE = pathlib.Path(__file__).resolve().parent
PLAN = json.loads((HERE / 'parts.json').read_text(encoding='utf-8'))
SRC = HERE.parents[2] / PLAN['source']
RADIUS = 0.03   # 원본 단위(키 1.0)

d = SRC.read_bytes()
ln = struct.unpack('<I', d[12:16])[0]
j = json.loads(d[20:20 + ln]); b0 = 20 + ln + 8


def acc(i):
    a = j['accessors'][i]; bv = j['bufferViews'][a['bufferView']]
    n = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3}[a['type']]
    dt = {5126: np.float32, 5125: np.uint32, 5123: np.uint16}[a['componentType']]
    arr = np.frombuffer(d, dtype=dt, count=a['count'] * n, offset=b0 + bv.get('byteOffset', 0) + a.get('byteOffset', 0))
    return arr.reshape(-1, n) if n > 1 else arr


img_bv = j['bufferViews'][j['images'][0]['bufferView']]
tex = np.array(Image.open(io.BytesIO(d[b0 + img_bv.get('byteOffset', 0): b0 + img_bv.get('byteOffset', 0) + img_bv['byteLength']])).convert('RGB'))
H, W = tex.shape[:2]

parts = {}
for node in j['nodes']:
    if 'mesh' not in node: continue
    pid = int(node['name'].split('_')[-1])
    t = np.array(node.get('translation', [0, 0, 0]), dtype=np.float32)
    P, UV, I = [], [], []
    off = 0
    for prim in j['meshes'][node['mesh']]['primitives']:
        p = acc(prim['attributes']['POSITION']) + t
        P.append(p); UV.append(acc(prim['attributes']['TEXCOORD_0']))
        I.append(acc(prim['indices']).astype(np.int64).reshape(-1, 3) + off); off += len(p)
    parts[pid] = (np.concatenate(P), np.concatenate(UV), np.concatenate(I))

drop = set(PLAN['drop'])
# 뺀 파츠 표면 점(정점 + 삼각형 중심·변 중점)으로 거리 판정
pts = []
for pid in drop:
    if pid not in parts: continue
    P, _, I = parts[pid]
    tri = P[I]
    pts += [P, tri.mean(1), (tri[:, 0] + tri[:, 1]) / 2, (tri[:, 1] + tri[:, 2]) / 2, (tri[:, 2] + tri[:, 0]) / 2]
tree = cKDTree(np.concatenate(pts))

owner = np.full((H, W), -1, np.int32)
pos_x = np.zeros((H, W), np.float32); pos_y = np.zeros((H, W), np.float32); pos_z = np.zeros((H, W), np.float32)
mask = np.zeros((H, W), bool)
for pid, (P, UV, I) in parts.items():
    if pid in drop: continue
    for f in I:
        uv = UV[f] * [W, H]          # glTF UV: v 아래로(이미지 행과 같다)
        x0, y0 = np.floor(uv.min(0)).astype(int); x1, y1 = np.ceil(uv.max(0)).astype(int)
        x0, y0 = max(x0, 0), max(y0, 0); x1, y1 = min(x1, W - 1), min(y1, H - 1)
        if x1 < x0 or y1 < y0: continue
        xs, ys = np.meshgrid(np.arange(x0, x1 + 1) + .5, np.arange(y0, y1 + 1) + .5)
        a, b, c = uv
        den = (b[1] - c[1]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[1] - c[1])
        if abs(den) < 1e-12: continue
        w0 = ((b[1] - c[1]) * (xs - c[0]) + (c[0] - b[0]) * (ys - c[1])) / den
        w1 = ((c[1] - a[1]) * (xs - c[0]) + (a[0] - c[0]) * (ys - c[1])) / den
        w2 = 1 - w0 - w1
        inside = (w0 >= -0.02) & (w1 >= -0.02) & (w2 >= -0.02)
        if not inside.any(): continue
        pos = w0[inside, None] * P[f[0]] + w1[inside, None] * P[f[1]] + w2[inside, None] * P[f[2]]
        yy = (ys[inside] - .5).astype(int); xx = (xs[inside] - .5).astype(int)
        owner[yy, xx] = pid
        pos_x[yy, xx] = pos[:, 0]; pos_y[yy, xx] = pos[:, 1]; pos_z[yy, xx] = pos[:, 2]
        dist, _ = tree.query(pos)
        hit = dist < RADIUS
        mask[yy[hit], xx[hit]] = True

# 색 기준: 셔츠·조끼·목도리·소매(파츠 2·14·9·5·6)에는 원래 갈색이 없다(벨트·버클·머리·바지는 다른 파츠).
# 그 파츠 위의 갈색 텍셀은 멜빵·등짐을 그린 자국이므로 함께 지운다.
CLOTH = [2, 14, 9, 5, 6]
f = tex.astype(np.float32) / 255.0
mx, mn = f.max(2), f.min(2)
hue = np.zeros_like(mx)
r, g, b = f[..., 0], f[..., 1], f[..., 2]
dlt = np.maximum(mx - mn, 1e-6)
hue = np.where(mx == r, ((g - b) / dlt) % 6, np.where(mx == g, (b - r) / dlt + 2, (r - g) / dlt + 4)) * 60
sat = (mx - mn) / np.maximum(mx, 1e-6)
brown = (hue > 8) & (hue < 45) & (mx < 0.62) & (sat > 0.25)
mask |= brown & np.isin(owner, CLOTH)
# 벨트(파츠 12, 버클은 19 로 따로)는 갈색뿐 — 밝은 주황·붉은 텍셀은 뒤에 매달렸던 등불 빛을 그린 자국이다.
glow = ((mx > 0.5) & (sat > 0.45) & ((hue < 50) | (hue > 330))) | ((sat > 0.55) & ((hue < 14) | (hue > 330)))   # 옅은 붉은 기까지
mask |= glow & (owner == 12)
mask = binary_dilation(mask, iterations=2) & (owner >= 0)
out = tex.copy()
for pid in np.unique(owner[mask]):
    region = owner == pid
    src = region & ~mask
    if not src.any(): continue
    _, (iy, ix) = distance_transform_edt(~src, return_indices=True)
    m = mask & region
    out[m] = tex[iy[m], ix[m]]

# ── 2단계: 니브와 구분되게 옷·머리 색을 바꾼다(사용자 지시 2026-10-19 "아직 니브와 비슷 — 옷 컬러·머리 스타일 변경") ──
# 종족 보조색(이끼·구리, docs/races-guests-v01.md)을 따른다. 명도는 원래 칠을 유지해 붓질·명암이 남는다.
def to_hsv(rgb):
    f = rgb.astype(np.float32) / 255.0
    mx, mn = f.max(2), f.min(2); d_ = np.maximum(mx - mn, 1e-6)
    r_, g_, b_ = f[..., 0], f[..., 1], f[..., 2]
    h_ = np.where(mx == r_, ((g_ - b_) / d_) % 6, np.where(mx == g_, (b_ - r_) / d_ + 2, (r_ - g_) / d_ + 4)) * 60
    return h_, (mx - mn) / np.maximum(mx, 1e-6), mx


def from_hsv(h_, s_, v_):
    c = v_ * s_; x = c * (1 - np.abs((h_ / 60) % 2 - 1)); m = v_ - c
    k = (h_ // 60).astype(int) % 6
    r_ = np.choose(k, [c, x, 0 * c, 0 * c, x, c]); g_ = np.choose(k, [x, c, c, x, 0 * c, 0 * c]); b_ = np.choose(k, [0 * c, 0 * c, x, c, c, x])
    return (np.stack([r_ + m, g_ + m, b_ + m], -1).clip(0, 1) * 255).astype(np.uint8)


h2, s2, v2 = to_hsv(out)
# 텍셀의 3D 위치(원본 단위, 키 1.0): 머리카락은 얼굴 앞판(z>0.15 이고 높이 0.55~0.85)을 뺀 머리 위·옆·뒤, 목도리는 목 높이 띠.
HAIR_ZONE = (pos_y > 0.56) & ~((pos_z > 0.2) & (pos_y > 0.58) & (pos_y < 0.8) & (np.abs(pos_x) < 0.15))
NECK_ZONE = (pos_y > 0.44) & (pos_y < 0.56)
RESTYLE = [
    # (설명, 파츠, 조건, 새 색상(도), 채도 배율·고정, 명도 배율)
    ('조끼 보라 → 이끼 초록', [2, 14], (h2 > 245) & (h2 < 335) & (s2 > 0.18), 92, ('mul', 0.8), 0.95),
    ('목도리 빨강 → 구리 주황', [9, 2, 14], ((h2 < 22) | (h2 > 330)) & (s2 > 0.3) & ((owner == 9) | NECK_ZONE), 26, ('mul', 0.85), 0.92),
    ('셔츠·소매 흰색 → 귀리색', [2, 5, 6], (s2 < 0.38) & (v2 > 0.55) & ((h2 < 50) | (s2 < 0.12)), 36, ('set', 0.26), 0.92),
    # 얼굴·머리카락·눈이 한 파츠(13)라 색만으로 고르면 얼굴 그늘·눈까지 칠해진다 → 3D 위치로 머리카락 쪽만(HAIR_ZONE).
    ('머리카락 갈색 → 숯빛 검정', [13], HAIR_ZONE & (h2 > 4) & (h2 < 42) & (v2 < 0.62) & (v2 > 0.12) & (s2 > 0.3), 230, ('set', 0.18), 0.55),
]
restyled = out.copy()
for name, pids, cond, hue_new, (mode, sv), vmul in RESTYLE:
    m = cond & np.isin(owner, pids)
    s_new = s2[m] * sv if mode == 'mul' else np.full(m.sum(), sv, np.float32)
    restyled[m] = from_hsv(np.full(m.sum(), float(hue_new), np.float32), s_new, (v2[m] * vmul).clip(0, 1))
    print('RESTYLE', name, int(m.sum()))
out = restyled

# 뺀 앞머리(11) 밑에 가려져 있던 얼굴 판: 칠이 엉망(눈 둘레가 어둡게 번짐)이라 피부색으로 덮는다.
if 11 in drop:
    P11 = parts[11][0]
    t11 = cKDTree(P11)
    face = owner == 13
    pts13 = np.stack([pos_x[face], pos_y[face], pos_z[face]], -1)
    dd, _ = t11.query(pts13)
    under = np.zeros_like(face); under[face] = dd < 0.035
    under &= (pos_z > 0.17) & (pos_y < 0.8)   # 얼굴 앞판만(정수리 쪽 머리카락은 그대로)
    hh, ss, vv = to_hsv(out)
    skin = face & ~under & (hh > 45) & (hh < 70) & (ss > 0.35) & (vv > 0.7)
    eye = face & (vv < 0.2)
    fill = under & ~eye
    if skin.any():
        _, (iy, ix) = distance_transform_edt(~skin, return_indices=True)
        out[fill] = out[iy[fill], ix[fill]]
    print('FACE_UNDER_FRINGE', int(fill.sum()))

Image.fromarray(out).save(HERE / 'paint_clean.png')
Image.fromarray((mask * 255).astype(np.uint8)).save(HERE / 'paint_clean_mask.png')
print('CLEAN_PAINT', W, H, 'masked_texels', int(mask.sum()), 'parts', sorted(int(p) for p in np.unique(owner[mask])))
