"""글자 없는 카드 그림에서 글자를 놓을 크림판의 안쪽 사각형을 재어 godot/assets/cards/text_layout.json 에 쓴다.

카드 템플릿(인물·스킬·장비·시설…)마다 제목판·설명판·이름표의 모양과 폭이 다르다. 카드마다
  title : 위쪽 크림판(제목 + 분류)      rules : 아래 설명판      badge : 가운데 작은 이름표(없으면 생략)
의 행마다 가운데(x=512)를 지나는 크림 구간 [l, r] 을 4행 간격으로 기록한다. 타원 판은 줄마다 쓸 수 있는 폭이
다르므로 CardFace 가 줄 위치에 따라 폭을 맞춘다.
새 카드가 들어오면 다시 실행하면 된다. 키는 assets/cards/ 기준 경로(확장자 없음): "lumberjack", "races/orc/warrior".
"""
import json, os, glob
import cv2, numpy as np
from scipy import ndimage as ndi

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CARDS = os.path.join(ROOT, "godot", "assets", "cards")
OUT = os.path.join(CARDS, "text_layout.json")
CREAM_DIST = 26.0
ZONES = {"title": (20, 420), "rules": (1150, 1525)}
BADGE_ZONE = (950, 1150)


def imread(path):
    return cv2.imdecode(np.fromfile(path, np.uint8), cv2.IMREAD_UNCHANGED)


def cream_mask(img):
    bgr, alpha = img[..., :3], img[..., 3]
    lab = cv2.cvtColor(bgr, cv2.COLOR_BGR2LAB).astype(np.float32)
    reg = lab[1150:1490, 100:924]
    al = alpha[1150:1490, 100:924]
    px = reg[(reg[..., 0] > 170) & (al > 200)].astype(np.int32)
    q = px // 4
    keys, cnt = np.unique(q[:, 0] * 10000 + q[:, 1] * 100 + q[:, 2], return_counts=True)
    top = keys[np.argmax(cnt)]
    ref = px[(q[:, 0] * 10000 + q[:, 1] * 100 + q[:, 2]) == top].mean(axis=0).astype(np.float32)
    cream = (np.linalg.norm(lab - ref, axis=2) < CREAM_DIST) & (alpha > 200)
    return cv2.morphologyEx(cream.astype(np.uint8), cv2.MORPH_OPEN, np.ones((3, 3), np.uint8)).astype(bool)


def center_runs(comp):
    """행마다 x=512 를 포함하는 크림 구간 (l, r). 없으면 None."""
    h, w = comp.shape
    runs = [None] * h
    for y in range(h):
        row = comp[y]
        if not row[512]:
            continue
        l = 512
        while l > 0 and row[l - 1]:
            l -= 1
        r = 512
        while r < w - 1 and row[r + 1]:
            r += 1
        runs[y] = (l, r)
    return runs


STEP = 8   # 프로파일 행 간격


def profile(runs, y0, y1):
    """[y0,y1) 에서 가운데를 지나는 크림 행이 이어지는 가장 긴 구간의 프로파일 {"y": 시작행, "step": STEP, "runs": [[l, r], ...]}."""
    best = (0, 0, 0)
    y = y0
    while y < y1:
        if runs[y] is None:
            y += 1
            continue
        a = y
        while y + 1 < y1 and runs[y + 1] is not None:
            y += 1
        if y - a + 1 > best[0]:
            best = (y - a + 1, a, y)
        y += 1
    if best[0] < 30:
        return None
    _, a, b = best
    # 판이 그림 창의 크림 테두리(스킬 카드의 마름모 등)와 가운데 열에서 이어지면 폭이 급격히 좁아지는 곳에서 끊는다.
    widest = 0
    cut = b
    for yy in range(a, b + 1):
        w = runs[yy][1] - runs[yy][0]
        widest = max(widest, w)
        if widest > 200 and w < 0.3 * widest:
            cut = yy - 1
            break
    b = cut
    rows = [[int(runs[yy][0]), int(runs[yy][1])] for yy in range(a, b + 1, STEP)]
    return {"y": int(a), "step": STEP, "runs": rows}


def measure(path):
    img = imread(path)
    cream = cream_mask(img)
    cc, _ = ndi.label(cream)
    sizes = np.bincount(cc.ravel()); sizes[0] = 0
    out = {}
    for name, (y0, y1) in ZONES.items():
        # 그 구역 안에서 x=512 열을 가장 많이 차지하는 크림 덩어리 = 판
        col = cc[y0:y1, 512]
        ids, cnt = np.unique(col[col > 0], return_counts=True)
        if len(ids) == 0:
            continue
        pid = ids[np.argmax(cnt)]
        comp = cc == pid
        comp = ndi.binary_fill_holes(comp)         # 글자 구멍이 남아 있어도 판으로 본다
        prof = profile(center_runs(comp), y0, y1)
        if prof:
            out[name] = prof
    # 이름표: 배지 높이의 작은 크림 덩어리(가운데, 폭 150~420, 속이 찬 것)
    for i in range(1, len(sizes)):
        if sizes[i] < 1500:
            continue
        ys, xs = np.nonzero(cc == i)
        top, bot, l, r = ys.min(), ys.max(), xs.min(), xs.max()
        wid = r - l
        if not (BADGE_ZONE[0] <= top and bot <= BADGE_ZONE[1] and 150 <= wid <= 420 and abs((l + r) / 2 - 512) <= 70):
            continue
        if sizes[i] < 0.55 * (bot - top + 1) * (wid + 1):
            continue
        comp = ndi.binary_fill_holes(cc == i)
        prof = profile(center_runs(comp), top, bot + 1)
        if prof:
            out["badge"] = prof
        break
    return out


def main():
    layout = {}
    files = sorted(glob.glob(os.path.join(CARDS, "*.png"))) + sorted(glob.glob(os.path.join(CARDS, "races", "*", "*.png")))
    for f in files:
        key = os.path.relpath(f, CARDS).replace(os.sep, "/")[:-4]
        if key == "card_back":
            continue
        layout[key] = measure(f)
    json.dump(layout, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    missing = [k for k, v in layout.items() if "title" not in v or "rules" not in v]
    print(f"WROTE {OUT}: {len(layout)} cards, badge on {sum('badge' in v for v in layout.values())}, missing title/rules: {missing}")
    hs = [len(v["title"]["runs"]) * STEP for v in layout.values() if "title" in v]
    print("title plate height: min %d  median %d  max %d" % (min(hs), np.median(hs), max(hs)))
    print("size %dKB" % (os.path.getsize(OUT) // 1024))


if __name__ == "__main__":
    main()
