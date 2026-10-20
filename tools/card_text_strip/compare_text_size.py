"""원본(그림 글자) 카드와 실제 텍스트 렌더(faces/full)의 글자 줄 높이를 카드마다 비교한다.
빈 카드와 다른 진한 픽셀 = 글자 잉크로 보고 제목판·설명판 줄을 찾는다. 결과는 JSON 으로 저장한다."""
import json, sys, glob, os
import cv2, numpy as np
from scipy import ndimage as ndi

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
O = os.path.join(ROOT, "output", "card-text-strip-v01")
ZONES = {"title": (40, 190), "category": (190, 300), "rules": (1160, 1500)}


def imread(path):
    """한글 경로도 읽는다(cv2.imread 는 비 ASCII 경로를 못 연다)."""
    return cv2.imdecode(np.fromfile(path, np.uint8), cv2.IMREAD_UNCHANGED)


def lines(img, blank, y0, y1, x0=60, x1=964):
    L = cv2.cvtColor(img[..., :3], cv2.COLOR_BGR2LAB)[..., 0].astype(int)
    Lb = cv2.cvtColor(blank[..., :3], cv2.COLOR_BGR2LAB)[..., 0].astype(int)
    ink = np.zeros(L.shape, bool)
    ink[y0:y1, x0:x1] = ((Lb - L) > 60)[y0:y1, x0:x1]
    rows = ndi.binary_closing(ink.any(1), iterations=3)
    out = []
    for sl in ndi.find_objects(ndi.label(rows)[0]):
        h = sl[0].stop - sl[0].start
        if h < 8:
            continue
        xs = np.nonzero(ink[sl[0]].any(0))[0]
        out.append({"y": int(sl[0].start), "h": int(h), "w": int(xs.max() - xs.min())})
    return out


def main():
    rep = {}
    for f in sorted(glob.glob(os.path.join(O, "faces", "full", "*.png"))):
        cid = os.path.splitext(os.path.basename(f))[0]
        before = os.path.join(O, "before", cid + ".png")
        blank = os.path.join(O, "cards", cid + ".png")
        if not (os.path.exists(before) and os.path.exists(blank)):
            continue
        o, r, b = (imread(p) for p in (before, f, blank))
        entry = {}
        for z, (y0, y1) in ZONES.items():
            a, c = lines(o, b, y0, y1), lines(r, b, y0, y1)
            entry[z] = {"orig": a, "new": c}
            if a and c and len(a) == len(c):
                entry[z]["h_ratio"] = round(float(np.mean([q["h"] for q in c]) / np.mean([p["h"] for p in a])), 2)
        rep[cid] = entry
    json.dump(rep, open(os.path.join(O, "text-size-compare.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    rs = {z: [e[z]["h_ratio"] for e in rep.values() if "h_ratio" in e[z]] for z in ZONES}
    for z, v in rs.items():
        print(z, "cards=%d  height ratio new/orig: median %.2f  min %.2f  max %.2f" % (len(v), np.median(v), min(v), max(v)))
    return rep


if __name__ == "__main__":
    main()
