"""볼륨 확장 E1~E3 신규 카드 12종을 카탈로그에 등록하고 임시(placeholder) 카드 이미지를 만든다.

정식 원화는 docs/card-design-guide.md 기준으로 따로 제작해 같은 경로에 덮어쓴다.
catalog.json 항목의 "placeholder": true 는 원화 교체 대상 표시다(원화를 넣으면 지운다).

실행(저장소 루트): python tools/build_expansion_placeholder_cards.py
"""
import io
import json
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CARDS = os.path.join(ROOT, "godot", "assets", "cards")
CATALOG = os.path.join(CARDS, "catalog.json")
FONT = os.path.join(ROOT, "godot", "assets", "fonts", "NotoSansKR-wght.ttf")

# 역할별 바탕색(프레임, 안쪽 면)
ROLE = {
    "spell": ((92, 70, 150), (232, 224, 248)),
    "structure": ((110, 84, 60), (240, 230, 214)),
    "resource": ((96, 120, 70), (232, 240, 220)),
    "power": ((70, 90, 160), (220, 230, 252)),
    "trophy": ((60, 110, 140), (220, 238, 246)),
    "corruption": ((70, 30, 80), (200, 180, 210)),
}

NEW = [
    {"id": "moss_bandage", "name": "이끼 붕대", "category": "숲 카드 · 회복과 정화", "kind": "spell", "role": "spell",
     "rules": ["마녀에게 놓아 체력을 돌봅니다.", "침식 카드 한 장을 정화합니다."],
     "description": "숲의 이끼로 감은 붕대입니다. 마녀에게 사용하면 체력을 조금 회복하고, 손패(없으면 주머니)의 침식 카드 한 장을 없앱니다.",
     "acquisition": "새벽 보상 · 장날", "target_tags": ["player"]},
    {"id": "resin_torch", "name": "송진 횃불", "category": "숲 카드 · 지속 불길", "kind": "spell", "role": "spell",
     "rules": ["밤에 땅이나 적에게 던집니다.", "잠시 동안 불길이 적을 태웁니다."],
     "description": "송진을 먹인 횃불입니다. 밤 전투 중 땅이나 적에게 사용하면 그 자리에 몇 초 동안 불길이 남아 범위 안의 적에게 매초 피해를 줍니다.",
     "acquisition": "새벽 보상 · 장날", "target_tags": ["enemy", "walkable_ground"]},
    {"id": "firefly_swarm", "name": "반딧불이 떼", "category": "숲 카드 · 시야", "kind": "structure", "role": "structure",
     "rules": ["땅에 풀어 안개를 걷어 냅니다.", "오늘 밤 전투가 끝나면 흩어집니다."],
     "description": "유리병에 모아 둔 반딧불이입니다. 땅에 풀면 넓은 범위의 안개를 걷어 냅니다. 안개의 밤에 특히 유용합니다.",
     "acquisition": "새벽 보상 · 장날", "target_tags": ["walkable_ground"]},
    {"id": "vine_snare", "name": "덩굴 덫", "category": "숲 카드 · 속박", "kind": "spell", "role": "spell",
     "rules": ["밤에 땅이나 적에게 놓습니다.", "주변 적을 덩굴로 묶습니다."],
     "description": "숲 바닥의 덩굴을 깨워 묶는 덫입니다. 밤 전투 중 사용하면 범위 안의 적에게 피해를 주고 몇 초 동안 거의 움직이지 못하게 합니다.",
     "acquisition": "새벽 보상 · 장날", "target_tags": ["enemy", "walkable_ground"]},
    {"id": "winter_firewood", "name": "겨울 장작", "category": "숲 카드 · 산장 보강", "kind": "resource", "role": "resource",
     "rules": ["산장에 놓아 벽을 보강합니다.", "밤에도 쓸 수 있습니다."],
     "description": "겨울을 나려고 쌓아 둔 단단한 장작입니다. 산장에 사용하면 체력을 회복합니다. 목재 수리와 달리 밤 전투 중에도 쓸 수 있습니다.",
     "acquisition": "새벽 보상 · 장날", "target_tags": ["damaged_lodge"]},
    {"id": "shroud_cloth", "name": "수의", "category": "권능 · 수의의 의식", "kind": "spell", "role": "power",
     "rules": ["오늘 밤 마녀와 아군이", "치명타를 한 번 버팁니다."],
     "description": "제단에서 처음 수의의 의식을 완성하면 얻는 권능입니다. 사용한 날 밤 동안 마녀와 아군은 쓰러질 피해를 한 번 버티고 체력 1로 남습니다.",
     "acquisition": "제단 · 수의의 의식(첫 완성)", "target_tags": ["walkable_ground"]},
    {"id": "thorn_bind", "name": "가시 속박", "category": "권능 · 가시의 봉헌", "kind": "spell", "role": "power",
     "rules": ["밤에 땅이나 적에게 놓습니다.", "넓은 범위의 적을 가시로 묶습니다."],
     "description": "제단에서 처음 가시의 봉헌을 완성하면 얻는 권능입니다. 밤 전투 중 사용하면 넓은 범위의 적에게 피해를 주고 가시로 묶어 거의 멈춰 세웁니다.",
     "acquisition": "제단 · 가시의 봉헌(첫 완성)", "target_tags": ["enemy", "walkable_ground"]},
    {"id": "red_chalice", "name": "붉은 잔", "category": "권능 · 붉은 만찬", "kind": "spell", "role": "power",
     "rules": ["마녀에게 놓습니다.", "오늘 밤 마법탄이 체력을 되돌립니다."],
     "description": "제단에서 처음 붉은 만찬을 완성하면 얻는 권능입니다. 사용한 날 밤 동안 마녀의 마법탄이 준 피해의 일부만큼 마녀를 회복합니다.",
     "acquisition": "제단 · 붉은 만찬(첫 완성)", "target_tags": ["player"]},
    {"id": "hibernation_pelt", "name": "겨울잠 털가죽", "category": "전리품 · 빈 굴의 주인", "kind": "spell", "role": "trophy",
     "rules": ["산장에 덮습니다.", "오늘 밤 산장이 받는 피해가 절반입니다."],
     "description": "고대 존재에게 깨워진 거대 짐승, 빈 굴의 주인을 쓰러뜨리면 얻는 전리품입니다. 산장에 사용하면 그날 밤 산장이 받는 피해가 절반이 됩니다.",
     "acquisition": "보스 · 빈 굴의 주인 처치", "target_tags": ["lodge"]},
    {"id": "corrupt_prayer", "name": "침식된 기도문", "category": "침식 · 쓸 수 없음", "kind": "corruption", "role": "corruption",
     "rules": ["사용할 수 없습니다.", "손패 한 칸을 차지합니다."],
     "description": "침식된 자가 산장 벽에 새긴 기도문이 주머니에 스며든 것입니다. 쓸 수 없고 손패만 차지합니다. 이끼 붕대나 장날 정화로 없앱니다.",
     "acquisition": "침식된 자가 산장을 공격", "target_tags": []},
    {"id": "poison_spore", "name": "독 포자", "category": "침식 · 쓸 수 없음", "kind": "corruption", "role": "corruption",
     "rules": ["사용할 수 없습니다.", "손패에 있으면 새벽마다 체력을 잃습니다."],
     "description": "맹독 곤충이 남긴 포자입니다. 쓸 수 없고, 손패에 있으면 새벽마다 마녀의 체력을 조금 빼앗습니다(치명적이지 않음). 정화로 없앱니다.",
     "acquisition": "맹독 곤충이 마녀를 공격", "target_tags": []},
    {"id": "cursed_whisper", "name": "저주의 속삭임", "category": "침식 · 쓸 수 없음", "kind": "corruption", "role": "corruption",
     "rules": ["사용할 수 없습니다.", "손패에 있으면 아침 드로우를 막습니다."],
     "description": "보스의 울부짖음이 남긴 저주입니다. 쓸 수 없고, 손패에 있으면 그날 아침 드로우를 하지 못합니다. 정화로 없앱니다.",
     "acquisition": "보스의 울부짖음", "target_tags": []},
]


def font(size, weight=500):
    f = ImageFont.truetype(FONT, size)
    try:
        f.set_variation_by_axes([weight])
    except Exception:
        pass
    return f


def wrap(draw, text, font, width):
    lines, cur = [], ""
    for ch in text:
        if draw.textlength(cur + ch, font=font) > width and cur:
            lines.append(cur)
            cur = ch
        else:
            cur += ch
    if cur:
        lines.append(cur)
    return lines


def make_card(card, path, size=(1024, 1536)):
    frame, face = ROLE[card["role"]]
    w, h = size
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, w - 1, h - 1], radius=72, fill=frame + (255,))
    d.rounded_rectangle([40, 40, w - 41, h - 41], radius=52, fill=face + (255,))
    # 그림 자리(임시): 역할 색의 원과 "원화 준비 중"
    cx, cy, r = w // 2, int(h * 0.36), int(w * 0.3)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=tuple(min(255, c + 40) for c in frame) + (255,))
    big = font(240, 800)
    initial = card["name"][0]
    tw = d.textlength(initial, font=big)
    d.text((cx - tw / 2, cy - 160), initial, font=big, fill=face + (255,))
    small = font(34, 500)
    note = "원화 준비 중"
    d.text((cx - d.textlength(note, font=small) / 2, cy + r + 18), note, font=small, fill=frame + (200,))
    # 제목·분류·규칙 2줄
    title = font(92, 800)
    tw = d.textlength(card["name"], font=title)
    d.text(((w - tw) / 2, int(h * 0.64)), card["name"], font=title, fill=(40, 28, 48, 255))
    cat = font(40, 600)
    cw = d.textlength(card["category"], font=cat)
    d.text(((w - cw) / 2, int(h * 0.64) + 120), card["category"], font=cat, fill=frame + (255,))
    body = font(50, 600)
    y = int(h * 0.64) + 210
    for line in card["rules"]:
        for part in wrap(d, line, body, w - 180):
            pw = d.textlength(part, font=body)
            d.text(((w - pw) / 2, y), part, font=body, fill=(50, 40, 60, 255))
            y += 68
    img.save(path)
    hand = img.resize((256, 384), Image.LANCZOS)
    hand.save(os.path.join(os.path.dirname(path), "hand", os.path.basename(path)))


def main():
    data = json.load(io.open(CATALOG, encoding="utf-8"))
    by_id = {c["id"]: c for c in data["cards"]}
    for card in NEW:
        path = os.path.join(CARDS, card["id"] + ".png")
        entry = by_id.get(card["id"])
        if entry is None or entry.get("placeholder", False):
            make_card(card, path)
        new_entry = {
            "id": card["id"], "name": card["name"], "category": card["category"], "kind": card["kind"],
            "texture": "res://assets/cards/%s.png" % card["id"],
            "hand_texture": "res://assets/cards/hand/%s.png" % card["id"],
            "printed_rules": card["rules"], "description": card["description"],
            "acquisition": card["acquisition"], "target_tags": card["target_tags"], "stackable": False,
            "placeholder": True,
        }
        if entry is None:
            data["cards"].append(new_entry)
        elif entry.get("placeholder", False):
            entry.update(new_entry)
    # 원본 형식(2칸 들여쓰기, CRLF)을 유지한다
    with io.open(CATALOG, "w", encoding="utf-8", newline="\r\n") as f:
        f.write(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
    print("cards:", len(data["cards"]))


if __name__ == "__main__":
    main()
