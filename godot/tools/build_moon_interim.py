"""달빛 마법 UI · 임시 런타임 부품 생성기.

Codex 런타임 에셋 패키지(art/ui/moon-runes-v01/runtime)가 납품되기 전까지 게임 HUD가
승인 원본과 같은 그림으로 동작하도록, 승인 아틀라스에서 그룹을 잘라내고 예시 숫자·게이지 채움·
예시 카드만 지운 '빈' 부품을 만든다. 새 그림을 그리지 않는다(원본 픽셀 + 주변색 확산 채움).

출력: godot/assets/ui/moon_runes/interim/*.png, manifest.json
실행(프로젝트 루트): python -I godot/tools/build_moon_interim.py
최종 에셋이 오면 scripts/ui/moon/moon_skin.gd 가 같은 ID의 runtime 파일을 우선 사용한다.
"""
import json
import pathlib
import sys

import numpy as np
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parents[2]
ATLAS = ROOT / "art/ui/moon-runes-v01/approved/atlas.png"
OUT = ROOT / "godot/assets/ui/moon_runes/interim"

# 조각: id -> (x, y, w, h) 아틀라스 절대 좌표. 그룹 영역은 명세 §3 과 동일.
PIECES = {
    "player_status": (6, 6, 577, 195),
    "objective": (5, 197, 398, 148),
    "phase": (625, 7, 526, 175),
    "resources": (1197, 29, 468, 143),
    "pause": (1668, 34, 105, 116),
    "hand_tray": (460, 539, 856, 340),
    "storage": (3, 694, 195, 185),
    "lodge_button": (1315, 696, 225, 183),
    "dragon_disabled": (1540, 696, 233, 183),
    # 원본 채움 줄무늬(동적 게이지가 잘라 쓰는 원본 픽셀)
    "gauge_fill_red": (312, 70, 135, 12),
    "gauge_fill_teal": (312, 126, 134, 13),
    "phase_fill": (754, 124, 125, 14),
    "stack_badge": (812, 746, 70, 58),
}

# 지울 글자 영역(절대 좌표 x0,y0,x1,y1): 주변 배경과 크게 다른 픽셀을 글자로 보고 확산 채움
TEXT_BOXES = {
    "player_status": [(458, 58, 560, 95), (458, 113, 562, 152)],
    "phase": [(816, 32, 958, 72), (830, 80, 946, 104)],
    "resources": [(1290, 74, 1334, 104), (1452, 74, 1475, 104), (1595, 74, 1619, 104)],
    "objective": [(126, 266, 312, 296)],
    "dragon_disabled": [(1572, 806, 1736, 844)],
    "stack_badge": [(830, 762, 862, 788)],
}

# 채움 줄무늬를 빈 트랙 색으로 덮을 영역(절대 좌표)
FILL_BOXES = {
    "player_status": [((311, 70, 448, 83), (34, 14, 46)), ((311, 125, 448, 139), (22, 26, 52))],
    "phase": [((753, 124, 880, 138), (39, 24, 66))],
}


def diffuse_fill(rgba: np.ndarray, mask: np.ndarray, iters: int = 400) -> None:
    """mask 픽셀을 주변 알려진 픽셀의 평균으로 바깥에서 안쪽으로 채운다(제자리)."""
    rgb = rgba[..., :3].astype(np.float32)
    known = ~mask
    for _ in range(iters):
        if known.all():
            break
        acc = np.zeros_like(rgb)
        cnt = np.zeros(mask.shape, np.float32)
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1)):
            k = np.roll(known, (dy, dx), (0, 1))
            v = np.roll(rgb, (dy, dx), (0, 1))
            acc += v * k[..., None]
            cnt += k
        grow = (~known) & (cnt > 0)
        rgb[grow] = acc[grow] / cnt[grow][:, None]
        known = known | grow
    # 채운 부분만 몇 번 부드럽게
    for _ in range(6):
        acc = np.zeros_like(rgb)
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            acc += np.roll(rgb, (dy, dx), (0, 1))
        rgb[mask] = (acc[mask] / 4.0 + rgb[mask]) * 0.5
    rgba[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)


def text_mask(piece: np.ndarray, box) -> np.ndarray:
    x0, y0, x1, y1 = box
    sub = piece[y0:y1, x0:x1, :3].astype(int)
    border = np.concatenate([sub[0], sub[-1], sub[:, 0], sub[:, -1]])
    base = np.median(border, axis=0)
    diff = np.abs(sub - base).sum(-1)
    m = diff > 70
    # 2px 팽창(안티에일리어싱 가장자리까지)
    for _ in range(2):
        m = m | np.roll(m, 1, 0) | np.roll(m, -1, 0) | np.roll(m, 1, 1) | np.roll(m, -1, 1)
    full = np.zeros(piece.shape[:2], bool)
    full[y0:y1, x0:x1] = m
    return full


def main() -> int:
    atlas = np.array(Image.open(ATLAS).convert("RGBA"))
    OUT.mkdir(parents=True, exist_ok=True)
    manifest = {"source": str(ATLAS.relative_to(ROOT)).replace("\\", "/"), "kind": "interim", "pieces": {}}
    for pid, (x, y, w, h) in PIECES.items():
        piece = atlas[y:y + h, x:x + w].copy()
        for (bx0, by0, bx1, by1), col in FILL_BOXES.get(pid, []):
            sl = (slice(by0 - y, by1 - y), slice(bx0 - x, bx1 - x))
            region = piece[sl]
            # 원래 채움 픽셀(밝은 색)만 트랙색으로, 테두리는 남긴다
            bright = region[..., :3].astype(int).sum(-1) > 200
            region[bright, :3] = col
        for bx0, by0, bx1, by1 in TEXT_BOXES.get(pid, []):
            m = text_mask(piece, (bx0 - x, by0 - y, bx1 - x, by1 - y))
            diffuse_fill(piece, m)
        if pid == "hand_tray":
            # 예시 카드 4장을 지운다: 카드 바닥선(y=806) 위, 카드 가로 범위는 투명
            piece[: 812 - y, 490 - x: 1290 - x, 3] = 0
            for i in range(6):  # 잘린 윗선을 부드럽게
                row = piece[812 - y + i, 490 - x: 1290 - x, 3]
                row[:] = (row * ((i + 1) / 7.0)).astype(np.uint8)
        if pid == "stack_badge":
            # 카드 그림 모서리를 지우고 원형 배지만 남긴다(청록 테두리 기준 타원)
            hh, ww = piece.shape[:2]
            yy, xx = np.mgrid[0:hh, 0:ww]
            r = np.sqrt(((xx - 36.5) / 33.5) ** 2 + ((yy - 29.5) / 28.5) ** 2)
            edge = np.clip((1.0 - r) * 30.0, 0.0, 1.0)
            piece[..., 3] = (piece[..., 3] * edge).astype(np.uint8)
        # 승인 원본 패널은 알파 253(거의 불투명). 런타임 HUD는 완전 불투명으로 맞춰 월드 후처리가 비치지 않게 한다.
        a = piece[..., 3]
        a[a >= 250] = 255
        Image.fromarray(piece).save(OUT / f"{pid}.png")
        manifest["pieces"][pid] = {"file": f"{pid}.png", "atlas_rect": [x, y, w, h]}
    # 손패 표면(명세 §4.5 '좁은 손패에서 본문을 상시 노출하지 않는다'): 기존 카드 카탈로그 그림에서
    # 제목+그림만 남기고 규칙 문구 상자를 뺀 뒤 원래 카드 아래 테두리를 붙인다.
    cards_dir = OUT / "cards"
    cards_dir.mkdir(exist_ok=True)
    manifest["cards"] = {}
    for cid in ("axe_mercenary", "wool", "timber", "forest_monster"):
        src = Image.open(ROOT / f"godot/assets/cards/{cid}.png").convert("RGBA")
        w, h = src.size
        top = src.crop((0, 0, w, int(h * 0.779)))
        ink = Image.new("RGBA", (w, int(h * 0.006)), (20, 12, 24, 255))
        bottom = src.crop((0, int(h * 0.982), w, h))
        card = Image.new("RGBA", (w, top.height + ink.height + bottom.height), (0, 0, 0, 0))
        card.paste(top, (0, 0))
        card.paste(ink, (int(w * 0.035), top.height))
        card.alpha_composite(bottom, (0, top.height + ink.height))
        card = card.resize((256, round(256 * card.height / w)), Image.LANCZOS)
        card.save(cards_dir / f"{cid}.png")
        manifest["cards"][cid] = {"file": f"cards/{cid}.png", "size": list(card.size), "from": f"godot/assets/cards/{cid}.png"}
    (OUT / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print("interim pieces:", len(PIECES), "->", OUT)
    return 0


if __name__ == "__main__":
    sys.exit(main())
