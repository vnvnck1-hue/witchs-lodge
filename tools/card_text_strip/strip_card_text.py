"""카드 PNG에 인쇄된 글자(제목·분류·설명)를 지운다.

원리: 글자는 항상 평평한 크림색 판 위의 어두운 잉크다.
  1) 크림색 픽셀 마스크를 만든다(카드별 판 색을 표본으로 잡아 Lab 거리로 판정).
  2) 크림 마스크의 '구멍'(크림에 완전히 둘러싸인 비크림 덩어리) = 글자 획.
     프레임 선·그림 창은 크림 밖과 이어져 있으므로 구멍이 아니다.
  3) 제목·설명 구역 안, 글자 크기인 구멍만 남겨 살짝 팽창 → cv2.inpaint 로 채움.
Codex·이미지 생성 없이 결정적(deterministic)으로 동작하며 원본은 덮어쓰지 않는다.
"""
import argparse, json, sys
from pathlib import Path
import numpy as np, cv2
from scipy import ndimage as ndi

# 1024x1536 기준 구역 (docs/card-role-layout-v02.json 의 title/rules 영역에 여유를 둔 값)
ZONES = {"title": (20, 420), "rules": (1150, 1525)}
MAX_GLYPH_H = 140      # 이보다 큰 구멍은 글자가 아니라 장식/그림으로 본다
CREAM_DIST = 26.0      # 판 색과의 Lab 거리 허용치
DILATE = 2             # 안티에일리어싱 가장자리까지 덮기
CLOSE_R = 22           # 판 배경 추정용 닫힘 반경(글자 획 굵기보다 커야 함)
HALO_R = 14            # 글자 주변 그림자 탐색 반경
LINE_GAP = 61          # 같은 줄로 묶을 글자 간격
LINE_EXT = 60          # 줄 양끝에서 더 찾아볼 폭
FILL_SIGMA = 18        # 채움 색을 구할 주변 반경
GRAIN_MAX = 3.0        # 결 잡음 상한
OVERRIDE_DL = 40       # 수동 보정 사각형에서 지울 어두움 기준
RING = 6               # 채움 색 표본에서 뺄 마스크 주변 폭
FEATHER = 3            # 경계 페더 폭
NOTCH_R = 28           # 판 외곽 홈(프레임에 닿은 글자) 탐지 반경
MIN_PANEL_AREA = 15000  # 크림 판으로 인정할 최소 넓이
BADGE_ZONE = (950, 1150)       # 종족 배지 이름표 높이 범위
BADGE_MIN_W = 150              # 이름표 판 최소 폭(아이콘 얼굴 등 작은 크림 조각 제외)
BADGE_CENTER_TOL = 70          # 이름표 중심과 카드 중심의 허용 거리
BADGE_MAX_CHROMA = 12          # 글자 잉크는 무채색
BADGE_MAX_INK_RATIO = 0.3
PANEL_IN_ZONE = 0.6            # 판으로 인정할 글자 구역 내 비율
BADGE_MIN_SOLIDITY = 0.55      # 이름표 판 넓이 / 경계 상자 넓이 하한
BADGE_MAX_W = 420              # 이름표 판 최대 폭(이보다 넓으면 설명판)
BADGE_CLOSE_R = 7              # 글자 획을 메울 닫힘 반경
BADGE_INK_L = 95               # 이보다 밝은(색 있는) 구멍은 아이콘으로 보고 남긴다
HALO_MIN_L = 150       # 이보다 어두운 픽셀은 후광으로 지우지 않는다(글자 마스크로만)
HALO_DL = 4            # 배경보다 이만큼 어두우면 그림자로 본다


def cream_ref(lab, alpha, sy):
    """설명판 구역의 밝은 픽셀 중 가장 흔한 색 = 크림 판 색(그림 속 눈과 섞이지 않게)."""
    reg = lab[int(1150 * sy):int(1490 * sy), int(lab.shape[1] * .1):int(lab.shape[1] * .9)]
    al = alpha[int(1150 * sy):int(1490 * sy), int(lab.shape[1] * .1):int(lab.shape[1] * .9)]
    px = reg[(reg[..., 0] > 170) & (al > 200)].astype(np.int32)
    q = px // 4
    keys, cnt = np.unique(q[:, 0] * 10000 + q[:, 1] * 100 + q[:, 2], return_counts=True)
    top = keys[np.argmax(cnt)]
    sel = px[(q[:, 0] * 10000 + q[:, 1] * 100 + q[:, 2]) == top]
    return sel.mean(axis=0).astype(np.float32)


ell = lambda r: cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2 * r + 1,) * 2)


def strip(img, overrides=None):
    h, w = img.shape[:2]
    sy = h / 1536.0
    bgr, alpha = img[..., :3], img[..., 3] if img.shape[2] == 4 else np.full((h, w), 255, np.uint8)
    lab = cv2.cvtColor(bgr, cv2.COLOR_BGR2LAB).astype(np.float32)
    ref = cream_ref(lab, alpha, sy)
    ref_bgr = cv2.cvtColor(ref.round().clip(0, 255).astype(np.uint8)[None, None], cv2.COLOR_LAB2BGR)[0, 0].astype(np.float32)
    cream = (np.linalg.norm(lab - ref, axis=2) < CREAM_DIST) & (alpha > 200)
    cream = cv2.morphologyEx(cream.astype(np.uint8), cv2.MORPH_OPEN, np.ones((3, 3), np.uint8)).astype(bool)

    mask = np.zeros((h, w), bool)
    panel = np.zeros((h, w), bool)     # 크림 판 + 그 안의 구멍. 모든 수정은 이 안에서만.
    stats = {}
    # 카드 전체에서 구멍을 찾고(긴 제목판이 구역 경계에 잘리지 않게), 구멍 중심이 어느 구역인지로 판정한다.
    cc, _ = ndi.label(cream)
    sizes = np.bincount(cc.ravel()); sizes[0] = 0
    # 판 = 충분히 크고, 픽셀 대부분이 글자 구역(제목·설명 높이)에 있는 크림 덩어리. 그림 속 양털·눈은 제외.
    rows = np.zeros(h, bool)
    for y0, y1 in ZONES.values():
        rows[int(y0 * sy):int(y1 * sy)] = True
    in_zone = np.bincount(cc[rows].ravel(), minlength=len(sizes))
    ok = (sizes >= MIN_PANEL_AREA * sy * sy) & (in_zone >= PANEL_IN_ZONE * sizes)
    ok[0] = False
    big = np.isin(cc, np.nonzero(ok)[0])
    stats.update({n: 0 for n in ZONES}); stats["badge"] = 0
    filled = ndi.binary_fill_holes(big)
    holes = filled & ~big
    lab_cc, _ = ndi.label(holes)
    for i, sl in enumerate(ndi.find_objects(lab_cc), 1):
        comp = lab_cc[sl] == i
        cy = (sl[0].start + sl[0].stop) / 2 / sy
        if sl[0].stop - sl[0].start > MAX_GLYPH_H * sy: continue
        zname = next((n for n, (y0, y1) in ZONES.items() if y0 <= cy <= y1), None)
        if zname is None: continue
        mask[sl] |= comp
        stats[zname] += int(comp.sum())
    panel |= filled & ~(holes & ~mask)

    # 판은 글자 구역 근처로만 제한(그림 창 안쪽 등 다른 크림 영역 보호)
    zone_rows = np.zeros((h, 1), bool)
    for y0, y1 in list(ZONES.values()) + [BADGE_ZONE]:
        zone_rows[int(y0 * sy):int(y1 * sy)] = True
    panel &= zone_rows

    # 프레임에 닿은 글자: 판 외곽선에 생긴 '홈'을 닫힘으로 찾고, 글자 줄과 같은 높이일 때만 글자로 본다.
    ell0 = lambda r: cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2 * r + 1,) * 2)
    notch = cv2.morphologyEx(panel.astype(np.uint8), cv2.MORPH_CLOSE, ell0(round(NOTCH_R * sy))).astype(bool) & ~panel
    touch = np.zeros((h, w), bool)
    lab_l, _ = ndi.label(cv2.dilate(mask.astype(np.uint8), np.ones((1, round(61 * sy)), np.uint8)))
    for sl in ndi.find_objects(lab_l):
        if sl is None: continue
        line_h = sl[0].stop - sl[0].start
        ext = round(90 * sy)
        xs = slice(max(0, sl[1].start - ext), sl[1].stop + ext)
        sub = notch[sl[0], xs] & (lab[sl[0], xs, 0] < 140)
        cc, _ = ndi.label(sub)
        for i, csl in enumerate(ndi.find_objects(cc), 1):
            ch = csl[0].stop - csl[0].start; cw = csl[1].stop - csl[1].start
            if ch >= 0.6 * line_h and cw <= 1.6 * line_h:     # 글자 크기의 홈만(완만한 프레임 굴곡 제외)
                # 홈 상자(+여유) 안의 진한 픽셀 전체 = 그 글자. 줄 높이 안으로만 제한해 프레임을 보호한다.
                pad = round(6 * sy)
                ys0 = sl[0].start + max(0, csl[0].start - pad); ys1 = sl[0].start + min(line_h, csl[0].stop + pad)
                xs0 = xs.start + max(0, csl[1].start - pad); xs1 = xs.start + csl[1].stop + pad
                touch[ys0:ys1, xs0:xs1] |= (lab[ys0:ys1, xs0:xs1, 0] < 140)
    mask |= touch
    panel |= cv2.dilate(touch.astype(np.uint8), ell0(round(4 * sy))).astype(bool)
    stats["touching_glyph_px"] = int(touch.sum())

    # 종족 배지 이름표: 배지 높이에 있는 작은 크림판. 글자가 테두리에 닿아 구멍이 안 되므로
    # 크림을 작은 반경으로 닫아(가는 획만 메워짐) 메워진 진한 픽셀 = 글자로 본다. 색 있는 아이콘은 밝아서 제외.
    all_cc, _ = ndi.label(cream)
    for i, sl in enumerate(ndi.find_objects(all_cc), 1):
        if sl is None: continue
        top, bot = sl[0].start / sy, sl[0].stop / sy
        wid = (sl[1].stop - sl[1].start) / sy
        cx = (sl[1].start + sl[1].stop) / 2 / sy
        if not (BADGE_ZONE[0] <= top and bot <= BADGE_ZONE[1] and BADGE_MIN_W <= wid <= BADGE_MAX_W): continue
        if abs(cx - 512) > BADGE_CENTER_TOL: continue          # 이름표는 카드 가운데에 있다
        pad = round(12 * sy)
        ys, xs = slice(max(0, sl[0].start - pad), sl[0].stop + pad), slice(max(0, sl[1].start - pad), sl[1].stop + pad)
        plate = all_cc[ys, xs] == i
        # 이름표 판은 속이 찬 타원이다. 가죽 테두리 같은 얇은 고리는 넓이가 상자에 비해 작아서 제외한다(토끼 가죽).
        if plate.sum() < BADGE_MIN_SOLIDITY * (sl[0].stop - sl[0].start) * (sl[1].stop - sl[1].start): continue
        closed = cv2.morphologyEx(plate.astype(np.uint8), cv2.MORPH_CLOSE, ell(round(BADGE_CLOSE_R * sy))).astype(bool)
        closed = ndi.binary_fill_holes(closed)
        glyph = closed & ~plate & (lab[ys, xs, 0] < BADGE_INK_L)
        if glyph.sum() < 30 * sy * sy: continue
        a_, b_ = lab[ys, xs, 1][glyph] - 128, lab[ys, xs, 2][glyph] - 128
        if np.sqrt(a_ ** 2 + b_ ** 2).mean() > BADGE_MAX_CHROMA: continue   # 색 있는 아이콘(갈색 그릇 등)은 글자가 아니다
        if glyph.sum() > BADGE_MAX_INK_RATIO * closed.sum(): continue     # 판을 가득 채우면 아이콘
        mask[ys, xs] |= glyph
        panel[ys, xs] |= closed
        stats["badge"] += int(glyph.sum())

    # 글자 그림자·후광까지: 글자 주변에서 '판 배경보다 어두운' 픽셀을 추가한다.
    k = max(1, round(DILATE * sy))
    big = max(5, round(CLOSE_R * sy))
    bg = cv2.morphologyEx(bgr, cv2.MORPH_CLOSE, ell(big))          # 글자를 지운 판 배경 추정
    L, Lbg = lab[..., 0], cv2.cvtColor(bg, cv2.COLOR_BGR2LAB)[..., 0].astype(np.float32)
    near = cv2.dilate(mask.astype(np.uint8), ell(round(HALO_R * sy))).astype(bool)
    bg_is_cream = np.linalg.norm(cv2.cvtColor(bg, cv2.COLOR_BGR2LAB).astype(np.float32) - ref, axis=2) < CREAM_DIST * 1.6
    halo = near & bg_is_cream & (Lbg - L > HALO_DL) & panel & (L > HALO_MIN_L)   # 진한 잉크(테두리선)는 후광이 아니다
    # 수동 보정: 프레임에 닿아 구멍으로 잡히지 않는 글자 등. 사각형 안의 '배경보다 어두운' 픽셀을 지운다.
    for x, y, rw, rh in (overrides or []):
        x, y, rw, rh = (round(v * sy) for v in (x, y, rw, rh))
        box = np.zeros((h, w), bool); box[y:y + rh, x:x + rw] = True
        halo |= box & (Lbg - L > OVERRIDE_DL)
    full = cv2.dilate((mask | halo).astype(np.uint8), ell(k)).astype(bool) & (alpha > 0)
    full &= cv2.dilate(panel.astype(np.uint8), ell(k)).astype(bool) | cv2.dilate(halo.astype(np.uint8), ell(k)).astype(bool)
    # 채우기: 마스크 밖 크림 픽셀만으로 국소 평균(정규화 컨볼루션) → 판의 그라데이션 유지.
    valid = (cream & ~cv2.dilate(full.astype(np.uint8), ell(round(RING * sy))).astype(bool)).astype(np.float32)
    sig = FILL_SIGMA * sy
    fill = np.zeros((h, w, 3), np.float32); got = np.zeros((h, w, 1), np.float32)
    for mul in (1, 2.5, 6):                          # 근처에 표본이 없으면 반경을 넓혀 채운다
        num = cv2.GaussianBlur(bgr.astype(np.float32) * valid[..., None], (0, 0), sig * mul)
        den = cv2.GaussianBlur(valid, (0, 0), sig * mul)[..., None]
        wgt = np.clip(den / 0.15, 0, 1) * (1 - got)
        fill += wgt * num / np.maximum(den, 1e-6); got += wgt
    fill += (1 - got) * ref_bgr
    # 양피지 결: 주변 크림의 고주파 성분 세기를 재서 같은 세기의 잡음을 얹는다.
    hp = bgr.astype(np.float32) - cv2.GaussianBlur(bgr.astype(np.float32), (0, 0), 3)
    core = cv2.erode(valid, np.ones((7, 7), np.uint8)) > 0       # 판 경계·글자 가장자리 제외
    g = hp[core].mean(axis=1) if core.any() else np.zeros(1, np.float32)
    grain_sd = min(GRAIN_MAX, 1.4826 * float(np.median(np.abs(g - np.median(g)))))
    rng = np.random.default_rng(0)
    noise = cv2.GaussianBlur(rng.normal(0, 1, (h, w)).astype(np.float32), (0, 0), 0.8)
    noise *= grain_sd / max(float(noise.std()), 1e-4)
    fill = fill + noise[..., None]
    w8 = cv2.GaussianBlur(cv2.dilate(full.astype(np.uint8), ell(round(FEATHER * sy))).astype(np.float32), (0, 0), FEATHER * sy)[..., None]
    w8 *= cv2.dilate(panel.astype(np.uint8), ell(k)).astype(np.float32)[..., None] if not overrides else 1.0
    w8 = np.maximum(w8, full[..., None].astype(np.float32))
    out_bgr = (bgr * (1 - w8) + fill * w8).round().clip(0, 255).astype(np.uint8)
    m8 = full.astype(np.uint8) * 255
    # 검수 지표: 글자 줄 근처에 남은 진한 잉크(프레임에 닿은 글자 등) 픽셀 수
    lines = cv2.dilate(mask.astype(np.uint8), np.ones((round(30 * sy), round(160 * sy)), np.uint8)).astype(bool)
    Lout = cv2.cvtColor(out_bgr, cv2.COLOR_BGR2LAB)[..., 0]
    resid = lines & ~panel & (Lout < 90)
    near_panel = cv2.dilate(panel.astype(np.uint8), ell(round(6 * sy))).astype(bool)
    edge = near_panel & ~panel                     # 판 테두리선(정상) 은 얇고 길다 → 덩어리 크기로 구분 못 하므로 수치만 보고
    stats["residual_ink"] = int((resid & ~edge).sum())
    # 그림 보호 검사: 그림 띠(제목 구역 아래 ~ 배지 구역 위)에서 바뀐 픽셀 수. 0 이어야 정상.
    stats["art_px_changed"] = int((np.abs(out_bgr.astype(int) - bgr.astype(int)).max(axis=2)[int(ZONES["title"][1] * sy):int(BADGE_ZONE[0] * sy)] > 0).sum())
    out = np.dstack([out_bgr, alpha]) if img.shape[2] == 4 else out_bgr
    return out, m8, stats


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inputs", nargs="+")
    ap.add_argument("--out", required=True)
    ap.add_argument("--masks", help="검수용 마스크 저장 폴더")
    ap.add_argument("--overrides", help="카드별 수동 보정 사각형 JSON {id: [[x,y,w,h],...]} (1024x1536 기준)")
    a = ap.parse_args()
    out = Path(a.out); out.mkdir(parents=True, exist_ok=True)
    report = {}
    ov = json.loads(Path(a.overrides).read_text(encoding="utf-8")) if a.overrides else {}
    for p in map(Path, a.inputs):
        img = cv2.imread(str(p), cv2.IMREAD_UNCHANGED)
        res, m, st = strip(img, ov.get(p.stem))
        cv2.imwrite(str(out / p.name), res)
        if a.masks:
            Path(a.masks).mkdir(parents=True, exist_ok=True)
            cv2.imwrite(str(Path(a.masks) / p.name), m)
        report[p.stem] = st
        print(p.stem, st)
    (out / "strip-report.json").write_text(json.dumps(report, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    main()
