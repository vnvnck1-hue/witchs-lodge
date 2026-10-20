"""카드 도감 HTML(output/card-gallery.html) 빌더.

게임의 '마녀의 주머니' 갤러리처럼 카드를 넓게 펼치고, 마우스를 올린 카드는 들어 올려 크게·나머지는 어둡게·옆에 툴팁을 띄운다.
1) .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/export_card_gallery.gd   (게임 문구 추출 → output/card-gallery-data.json)
2) python tools/build_card_gallery.py                                                            (손패용 원화를 WebP로 넣은 단일 HTML)
"""
import argparse
import base64
import html
import io
import json
import os
from collections import OrderedDict

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GODOT = os.path.join(ROOT, "godot")
DATA = os.path.join(ROOT, "output", "card-gallery-data.json")
OUT = os.path.join(ROOT, "output", "card-gallery.html")
FACES = None       # --faces: 실제 텍스트로 구운 카드(손패 256×384) 폴더. 있으면 이 그림을 쓰고 원본은 토글로 넣는다
BEFORE = None      # --before: 글자가 그림에 박힌 원본 카드 폴더(hand/ 와 races/<race>/hand/ 구조) — 토글용
FIT = {}           # faces/fit.json: 카드별 칸마다 쓴 글자 크기
HEADLINE = ""

FACTIONS = OrderedDict([
    ("", "기본 카드"), ("goblin", "고블린"), ("fairy", "요정"), ("dwarf", "드워프"), ("orc", "오크"),
    ("beastfolk", "수인"), ("human", "인간"), ("bridge", "종족 연계"), ("undead", "언데드"),
    ("harmony", "화합"), ("neutral", "중립 사건"), ("tavern", "주점"),
])
KINDS = OrderedDict([
    ("contract", "계약 인물"), ("summon", "소환"), ("spell", "주문·권능"), ("structure", "시설"),
    ("equipment", "장비"), ("resource", "원재료"), ("consumable", "소모품"), ("livestock", "가축"), ("draw", "드로우"),
    ("invite", "초대"), ("treasure", "보물"), ("event", "사건"), ("relic", "유물"), ("corruption", "침식"),
])
TAGS = {
    "walkable_ground": "지면", "any": "어디든", "merc": "용병", "player": "마녀", "enemy": "적",
    "defense_point": "방어 지점", "lodge_trade": "산장(교역)", "pasture": "목장", "damaged_lodge": "손상된 산장",
    "lodge": "산장", "thorn_plant": "가시 식물", "harvestable_tree": "벌목 나무",
}
RACE_JOBS = ["warrior", "hunter", "lumberjack", "gatherer"]
RACE_DIRS = ["goblin", "fairy", "dwarf", "orc", "beastfolk"]
NO_HINT = "지금은 사용할 수 없습니다"   # 게임의 기본(맞는 분기 없음) 문구 — 도감에는 싣지 않는다


def res(path):
    return os.path.join(GODOT, path.replace("res://", "").replace("/", os.sep))


_img_cache = {}


def img_uri(path):
    if path not in _img_cache:
        im = Image.open(path).convert("RGB")
        if im.width != 256:
            im = im.resize((256, 384), Image.LANCZOS)
        buf = io.BytesIO()
        im.save(buf, "WEBP", quality=84, method=6)
        _img_cache[path] = "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode()
    return _img_cache[path]


def face_uri(key, fallback):
    """실제 텍스트 렌더 그림. key 는 assets/cards 기준 경로(확장자 없음): 'lumberjack', 'races/orc/warrior'."""
    if FACES:
        p = os.path.join(FACES, "hand", key.replace("/", os.sep) + ".png")
        if os.path.exists(p):
            return img_uri(p)
    return img_uri(fallback)


def before_uri(key, fallback):
    if BEFORE:
        parts = key.split("/")
        p = os.path.join(BEFORE, *parts[:-1], "hand", parts[-1] + ".png")
        if os.path.exists(p):
            return img_uri(p)
    return img_uri(fallback) if fallback and os.path.exists(fallback) else ""


def fit_note(key):
    """fit.json 에서 기준보다 10% 넘게 줄어든 칸을 '제목 97/136' 식으로. 없으면 ''."""
    f = FIT.get(key, {})
    names = {"title": "제목", "category": "분류", "rules": "설명", "badge": "이름표"}
    parts = []
    for slot, v in f.items():
        if v.get("used", 0) < v.get("target", 0) * 0.9:   # 10% 넘게 줄었을 때만(1~2px 차이는 표시하지 않음)
            parts.append("%s %d/%d%s" % (names.get(slot, slot), v["used"], v["target"], " · 2줄" if slot == "title" and v.get("lines") == 2 else ""))
    return ", ".join(parts)


def note_box(info):
    return (f'<textarea class="note" rows="1" data-id="{html.escape(info["id"])}" data-name="{html.escape(info["name"])}" '
            f'placeholder="코멘트" aria-label="{html.escape(info["name"])} 코멘트"></textarea>')


def main():
    global FACES, BEFORE, FIT, HEADLINE
    ap = argparse.ArgumentParser()
    ap.add_argument("--faces", help="실제 텍스트 렌더 폴더(faces/: hand/, fit.json)")
    ap.add_argument("--before", help="원본(글자가 그림에 박힌) 카드 폴더 — 토글용")
    ap.add_argument("--headline", default="", help="머리글 HTML(<p>…</p>)")
    ap.add_argument("--out", default=OUT)
    a = ap.parse_args()
    FACES, BEFORE, HEADLINE, out_path = a.faces, a.before, a.headline, a.out
    if FACES and os.path.exists(os.path.join(FACES, "fit.json")):
        FIT = json.load(open(os.path.join(FACES, "fit.json"), encoding="utf-8"))
    cards = json.load(open(DATA, encoding="utf-8"))["cards"]
    catalog = json.load(open(os.path.join(GODOT, "assets", "cards", "catalog.json"), encoding="utf-8"))
    back = res(catalog["back_hand"])
    names = {c["id"]: c["name"] for c in cards}

    groups = OrderedDict((k, []) for k in FACTIONS)
    missing = 0
    for c in cards:
        tex = res(c.get("hand_texture", ""))
        has_art = os.path.exists(tex)
        missing += 0 if has_art else 1
        info = {
            "id": c["id"], "name": c["name"], "category": c.get("category", ""),
            "acquisition": c.get("acquisition", ""), "description": c.get("description", ""),
            "rules": c.get("printed_rules", []), "stackable": c.get("stackable", False),
            "tags": [TAGS.get(t, t) for t in c.get("target_tags", [])],
            "prep": "" if c["prep"] == NO_HINT else c["prep"],
            "combat": "" if c["combat"] == NO_HINT else c["combat"],
            "relic": c.get("relic", ""), "kind": c["kind"], "kindName": KINDS.get(c["kind"], c["kind"]),
            "faction": FACTIONS.get(c.get("race", ""), c.get("race", "")), "noArt": not has_art,
        }
        if info["prep"] == info["combat"] and info["prep"]:
            info["both"] = info["prep"]
        info["fit"] = fit_note(c["id"]) if has_art else ""
        uri = face_uri(c["id"], tex if has_art else back)
        groups.setdefault(c.get("race", ""), []).append((info, uri, before_uri(c["id"], tex if has_art else "")))

    kind_order = list(KINDS)
    parts = []
    nav = []
    for key, items in groups.items():
        if not items:
            continue
        items.sort(key=lambda x: kind_order.index(x[0]["kind"]) if x[0]["kind"] in kind_order else 99)
        title = FACTIONS.get(key, key)
        sid = "f-" + (key or "base")
        nav.append(f'<a href="#{sid}">{html.escape(title)} <b>{len(items)}</b></a>')
        parts.append(f'<section id="{sid}" data-faction="{html.escape(title)}"><h2>{html.escape(title)} <span class="n">{len(items)}장</span></h2><div class="row">')
        for info, uri, before in items:
            badge = '<i class="badge">원화 준비 중</i>' if info["noArt"] else ('<i class="badge small">글자 축소</i>' if info.get("fit") else "")
            parts.append(
                f'<div class="tile{" shrunk" if info.get("fit") else ""}" tabindex="0" data-kind="{info["kind"]}" data-search="{html.escape((info["name"] + " " + info["category"] + " " + info["id"]).lower())}" '
                f'data-info="{html.escape(json.dumps(info, ensure_ascii=False))}"><div class="art"><img src="{uri}" data-after="{uri}" data-before="{before}" alt="{html.escape(info["name"])}" loading="lazy">{badge}</div>'
                f'<div class="cap">{html.escape(info["name"])}</div>{note_box(info)}</div>')
        parts.append("</div></section>")

    # 종족별 계약 인물 그림(고용한 손님의 종족에 따라 계약 카드 그림이 바뀐다)
    variants = []
    for race in RACE_DIRS:
        for job in RACE_JOBS:
            p = os.path.join(GODOT, "assets", "cards", "races", race, "hand", job + ".png")
            if os.path.exists(p):
                base = next(c for c in cards if c["id"] == job)
                info = {
                    "id": f"{job} ({race})", "name": f'{base["name"]} — {FACTIONS[race]}', "category": base["category"],
                    "acquisition": f'{FACTIONS[race]} 손님 고용', "description": f'{FACTIONS[race]} 손님을 고용하면 {base["name"]} 계약 카드가 이 그림으로 보입니다. 규칙은 기본 {base["name"]} 카드와 같습니다.',
                    "rules": base.get("printed_rules", []), "stackable": False, "tags": [], "prep": "", "combat": "", "relic": "",
                    "kind": "contract", "kindName": "계약 인물", "faction": FACTIONS[race], "noArt": False, "variant": True,
                }
                key = f"races/{race}/{job}"
                info["fit"] = fit_note(key)
                variants.append((info, face_uri(key, p), before_uri(key, p)))
    if variants:
        nav.append(f'<a href="#f-variants">종족별 계약 그림 <b>{len(variants)}</b></a>')
        parts.append(f'<section id="f-variants" class="variants"><h2>종족별 계약 인물 그림 <span class="n">{len(variants)}장 · 같은 카드의 종족 그림(장수에 포함 안 함)</span></h2><div class="row">')
        for info, uri, before in variants:
            parts.append(
                f'<div class="tile{" shrunk" if info.get("fit") else ""}" tabindex="0" data-kind="contract" data-search="{html.escape((info["name"] + " " + info["id"]).lower())}" '
                f'data-info="{html.escape(json.dumps(info, ensure_ascii=False))}"><div class="art"><img src="{uri}" data-after="{uri}" data-before="{before}" alt="{html.escape(info["name"])}" loading="lazy"></div>'
                f'<div class="cap">{html.escape(info["name"])}</div>{note_box(info)}</div>')
        parts.append("</div></section>")

    kinds_present = [k for k in KINDS if any(c["kind"] == k for c in cards)]
    chips = '<button class="chip on" data-kind="">전체</button>' + "".join(
        f'<button class="chip" data-kind="{k}">{KINDS[k]} <b>{sum(1 for c in cards if c["kind"] == k)}</b></button>' for k in kinds_present)

    shrunk = sum(1 for g in groups.values() for it in g if it[0].get("fit")) + sum(1 for it in variants if it[0].get("fit"))
    page = TEMPLATE.replace("{{COUNT}}", str(len(cards))).replace("{{MISSING}}", str(missing)).replace("{{SHRUNK}}", str(shrunk)) \
        .replace("{{HEADLINE}}", HEADLINE) \
        .replace("{{NAV}}", "".join(nav)).replace("{{CHIPS}}", chips).replace("{{BODY}}", "".join(parts))
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(page)
    print(f"WROTE {out_path}  cards={len(cards)} variants={len(variants)} missing_art={missing} shrunk={shrunk} size={os.path.getsize(out_path)//1024}KB")


TEMPLATE = r"""<!doctype html>
<html lang="ko"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>마녀산장 카드 도감</title>
<style>
:root { --bg:#141027; --panel:#1b1533; --line:#39305a; --cream:#fce7b0; --cream-dim:#d6c8b2; --lav:#a796cd; --paper:#f6e6c3; --ink:#2b1d2e; --sub:#62475a; --ok:#23614e; --gold:#c9a24a; }
* { box-sizing:border-box; }
html { scroll-behavior:smooth; scroll-padding-top:120px; }
body { margin:0; background:radial-gradient(ellipse at 50% -10%, #2a2050 0%, var(--bg) 55%) fixed, var(--bg); color:var(--cream-dim); font-family:"Noto Sans KR","Malgun Gothic",system-ui,sans-serif; }
header { padding:26px 32px 6px; text-align:center; }
header h1 { margin:0; color:var(--cream); font-size:30px; letter-spacing:2px; font-weight:700; }
header h1::before, header h1::after { content:"✦"; color:var(--gold); font-size:16px; margin:0 14px; vertical-align:middle; }
header p { margin:8px auto 0; color:var(--lav); font-size:14px; max-width:860px; }
.bar { position:sticky; top:0; z-index:15; background:rgba(20,16,39,.93); backdrop-filter:blur(6px); border-bottom:1px solid var(--line); padding:10px 32px; }
.bar .line { display:flex; flex-wrap:wrap; gap:6px 8px; align-items:center; }
.bar .line + .line { margin-top:8px; }
.bar a { color:var(--cream-dim); text-decoration:none; font-size:13px; padding:4px 10px; border:1px solid var(--line); border-radius:999px; background:var(--panel); }
.bar a:hover { color:var(--cream); border-color:var(--lav); }
.bar b { color:var(--lav); font-weight:600; margin-left:2px; }
.chip { font:inherit; font-size:13px; color:var(--cream-dim); background:transparent; border:1px solid var(--line); border-radius:8px; padding:4px 10px; cursor:pointer; }
.chip.on { background:var(--cream); color:var(--ink); border-color:var(--cream); }
.chip.on b { color:var(--sub); }
#q { font:inherit; font-size:13px; background:var(--panel); color:var(--cream); border:1px solid var(--line); border-radius:8px; padding:5px 10px; width:200px; margin-left:auto; }
#q::placeholder { color:#7a6f9a; }
main { padding:4px 32px 80px; }
section { margin-top:26px; }
section.hidden, .tile.hidden { display:none; }
h2 { font-size:17px; color:var(--cream); margin:0 0 12px; border-bottom:1px solid var(--line); padding-bottom:6px; }
h2 .n { color:var(--lav); font-weight:normal; font-size:13px; margin-left:6px; }
.variants h2 { color:var(--cream-dim); }
.row { display:flex; flex-wrap:wrap; gap:22px 18px; }
.tile { width:150px; cursor:pointer; outline:none; transition:filter .25s, opacity .25s; }
.tile .art { position:relative; width:150px; height:225px; transition:transform .22s cubic-bezier(.2,1.4,.4,1); transform-origin:50% 100%; }
.tile img { display:block; width:150px; height:225px; border-radius:9px; box-shadow:0 6px 16px rgba(0,0,0,.55); transition:box-shadow .22s; }
.badge.small { top:auto; bottom:8px; font-size:11px; padding:2px 7px; border-color:var(--gold); }
body.show-before .badge.small { display:none; }
.tile.shrunk .cap::after { content:" ▾"; color:var(--gold); }
#tip .fitnote { color:#7a4b12; font-size:12.5px; margin-bottom:6px; }
.badge { position:absolute; left:50%; top:46%; transform:translate(-50%,-50%); font-style:normal; font-size:12px; background:rgba(20,16,39,.85); color:var(--cream); padding:3px 9px; border-radius:6px; border:1px solid var(--lav); white-space:nowrap; }
.tile .cap { text-align:center; font-size:13px; margin-top:6px; color:var(--cream-dim); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
body.focus .tile:not(.active) { filter:brightness(.36) saturate(.7); }
.tile.active { position:relative; z-index:20; }
.tile.active .art { transform:translateY(-14px) scale(1.6); }
.tile.active img { box-shadow:0 30px 50px rgba(0,0,0,.75), 0 0 0 2px rgba(252,231,176,.35); }
.tile.active .cap { opacity:0; }
#tip { position:fixed; z-index:30; width:350px; background:var(--paper); color:var(--ink); border-radius:12px; padding:14px 16px; box-shadow:0 18px 40px rgba(0,0,0,.6); border:2px solid #c9b58b; outline:1px solid #6d5a8f; outline-offset:2px; display:none; pointer-events:none; font-size:14px; line-height:1.55; }
#tip h3 { margin:0 0 2px; font-size:20px; }
#tip .sub { color:var(--sub); font-size:12.5px; margin-bottom:8px; }
#tip .desc { margin-bottom:8px; }
#tip .rules { margin:0 0 8px; padding:8px 10px; background:rgba(43,29,46,.07); border-radius:8px; font-style:italic; color:#4a3550; }
#tip .use { color:var(--ok); }
#tip .use.no { color:var(--sub); }
#tip .meta { margin-top:8px; color:var(--sub); font-size:12px; border-top:1px dashed #c9b58b; padding-top:6px; }
#tip .relic { color:#7a4b12; margin-bottom:6px; }
.note { display:block; width:100%; margin-top:5px; font:inherit; font-size:12px; line-height:1.4; color:var(--cream); background:rgba(27,21,51,.85); border:1px solid var(--line); border-radius:6px; padding:4px 6px; resize:none; overflow:hidden; height:26px; }
.note::placeholder { color:#6d6390; }
.note:focus { outline:none; border-color:var(--lav); background:var(--panel); }
.tile.has-note .note { border-color:var(--gold); background:rgba(201,162,74,.12); }
.tile.has-note .cap::before { content:"✎ "; color:var(--gold); }
.tile.active .note { opacity:0; }
.btn { font:inherit; font-size:13px; border-radius:8px; padding:5px 12px; cursor:pointer; border:1px solid var(--line); background:var(--panel); color:var(--cream-dim); }
.btn.primary { background:var(--gold); color:var(--ink); border-color:var(--gold); font-weight:700; }
.toast { font-size:12.5px; color:var(--lav); }
.report { margin-top:44px; padding:18px 20px; background:var(--panel); border:1px solid var(--line); border-radius:12px; }
.report h2 { border:0; padding:0; }
.report .hint { font-size:13.5px; color:var(--lav); margin:0 0 10px; }
.report #overall { width:100%; min-height:80px; font:inherit; font-size:14px; color:var(--cream); background:var(--bg); border:1px solid var(--line); border-radius:8px; padding:8px 10px; }
.report pre { white-space:pre-wrap; font-size:12.5px; color:var(--cream-dim); background:var(--bg); border:1px dashed var(--line); border-radius:8px; padding:10px 12px; max-height:260px; overflow:auto; margin:0; }
#empty { display:none; text-align:center; color:var(--lav); margin-top:60px; }
@media (max-width:700px) {
  header, main, .bar { padding-left:16px; padding-right:16px; }
  #q { width:100%; margin-left:0; }
  .row { gap:18px 12px; }
  .tile, .tile .art, .tile img { width:104px; } .tile .art, .tile img { height:156px; }
  #tip { width:min(350px, calc(100vw - 24px)); }
}
</style></head>
<body>
<header><h1>마녀의 주머니 — 전체 카드 도감</h1>
{{HEADLINE}}<p>카탈로그 {{COUNT}}장(원화 준비 중 {{MISSING}}장) · 카드에 마우스를 올리면(모바일은 탭) 게임 주머니처럼 들어 올려지고 옆에 게임 툴팁과 같은 설명이 뜹니다. 클릭하면 고정, 빈 곳 클릭·Esc 로 내려놓습니다.<br>카드 아래 칸에 코멘트를 적고 <b>결과 복사</b>로 대화창에 붙여 주세요.</p></header>
<div class="bar"><div class="line">{{NAV}}</div><div class="line">{{CHIPS}}<button class="chip" data-kind="__noted">✎ 코멘트 단 카드 <b id="noteCount">0</b></button><button class="chip" data-kind="__shrunk">▾ 글자 축소된 카드 <b>{{SHRUNK}}</b></button><button class="btn" id="toggleBefore" type="button" title="그림에 글자가 박힌 원본과 실제 텍스트 렌더를 번갈아 봅니다 (단축키 B)">원본(이미지 글자) 보기</button><input id="q" type="search" placeholder="이름·분류·id 검색"><button class="btn primary" id="copyTop" type="button">결과 복사</button></div></div>
<main>{{BODY}}<div id="empty">조건에 맞는 카드가 없습니다.</div>
<section class="report" id="report"><h2>전체 의견 · 결과 복사</h2>
<p class="hint">카드 아래 칸에 적은 코멘트는 이 브라우저에 자동 저장됩니다(도감을 새로 만들어도 카드 id 기준으로 남음). 다 적은 뒤 <b>결과 복사</b>를 눌러 대화창에 붙여 주세요. 코멘트를 단 카드만 정리돼 복사됩니다.</p>
<textarea id="overall" placeholder="전체 의견 (예: 언데드 카드 그림 톤이 너무 어둡다, 주점 카드 원화 우선순위…)"></textarea>
<div style="display:flex;flex-wrap:wrap;gap:10px;align-items:center;margin:10px 0"><button class="btn primary" id="copyBottom" type="button">결과 복사</button><button class="btn" id="clearAll" type="button">코멘트 모두 지우기</button><span class="toast" id="toast"></span></div>
<pre id="out"></pre></section></main>
<div id="tip"></div>
<script>
const tip = document.getElementById('tip');
let active = null, pinned = false;
function esc(s) { return String(s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'})[c]); }
function useLine(label, t) { return '<div class="use' + (t.startsWith('▶') ? '' : ' no') + '">' + label + esc(t) + '</div>'; }
function show(tile) {
  if (active && active !== tile) active.classList.remove('active');
  active = tile; tile.classList.add('active'); document.body.classList.add('focus');
  const i = JSON.parse(tile.dataset.info);
  let sub = i.category; if (i.acquisition) sub += '  ·  획득: ' + i.acquisition; if (i.stackable) sub += '  ·  수량 묶음';
  let h = '<h3>' + esc(i.name) + '</h3><div class="sub">' + esc(sub) + '</div>';
  if (i.relic) h += '<div class="relic">유물 효과: ' + esc(i.relic) + '</div>';
  if (i.description) h += '<div class="desc">' + esc(i.description) + '</div>';
  if (i.rules && i.rules.length) h += '<div class="rules">' + i.rules.map(esc).join('<br>') + '</div>';
  if (i.both) h += useLine('낮·밤 · ', i.both);
  else { if (i.prep) h += useLine('낮(준비) · ', i.prep); if (i.combat) h += useLine('밤(전투) · ', i.combat); }
  if (i.fit) h += '<div class="fitnote">글자 축소: ' + esc(i.fit) + ' (실제/기준 px, 1024 기준)</div>';
  h += '<div class="meta">' + esc(i.faction) + ' · ' + esc(i.kindName) + ' · id: ' + esc(i.id) + (i.tags.length ? ' · 대상: ' + esc(i.tags.join(', ')) : '') + (i.noArt ? ' · 원화 준비 중(게임에서는 뒷면으로 보임)' : '') + '</div>';
  tip.innerHTML = h; tip.style.display = 'block';
  place(tile);
}
function place(tile) {
  const r = tile.querySelector('img').getBoundingClientRect();
  const w = tip.offsetWidth, hgt = tip.offsetHeight, vw = innerWidth, vh = innerHeight;
  let x = r.right + 14; if (x + w > vw - 12) x = r.left - 14 - w; x = Math.max(12, Math.min(x, vw - w - 12));
  let y = Math.max(12, Math.min(r.top, vh - hgt - 12));
  tip.style.left = x + 'px'; tip.style.top = y + 'px';
}
function hide() { if (active) active.classList.remove('active'); active = null; pinned = false; document.body.classList.remove('focus'); tip.style.display = 'none'; }
document.querySelectorAll('.tile').forEach(t => {
  t.addEventListener('mouseenter', () => { if (!pinned && !document.activeElement.classList.contains('note')) show(t); });
  t.addEventListener('mouseleave', () => { if (!pinned) hide(); });
  t.addEventListener('click', e => { e.stopPropagation(); if (e.target.classList.contains('note')) return; if (active === t && pinned) { hide(); } else { show(t); pinned = true; } });
  t.addEventListener('focus', () => show(t));
});
document.addEventListener('click', e => { if (!e.target.closest('.bar') && !e.target.closest('.report')) hide(); });
document.addEventListener('keydown', e => { if (e.key === 'Escape') hide(); });
addEventListener('scroll', () => { if (active) place(active); }, { passive: true });
addEventListener('resize', () => { if (active) place(active); });
document.querySelectorAll('.tile .art').forEach(a => a.addEventListener('transitionend', () => { if (active) place(active); }));
// 종류 필터 + 검색
let kind = '';
const q = document.getElementById('q');
function filter() {
  hide();
  const s = q.value.trim().toLowerCase(); let any = false;
  document.querySelectorAll('main section').forEach(sec => {
    let n = 0;
    sec.querySelectorAll('.tile').forEach(t => {
      const ok = (!kind || t.dataset.kind === kind || (kind === '__noted' && t.classList.contains('has-note')) || (kind === '__shrunk' && t.classList.contains('shrunk'))) && (!s || t.dataset.search.includes(s) || t.dataset.info.toLowerCase().includes(s));
      t.classList.toggle('hidden', !ok); if (ok) n++;
    });
    sec.classList.toggle('hidden', n === 0); if (n) any = true;
  });
  document.getElementById('empty').style.display = any ? 'none' : 'block';
}
document.querySelectorAll('.chip').forEach(c => c.addEventListener('click', () => {
  document.querySelectorAll('.chip').forEach(x => x.classList.toggle('on', x === c)); kind = c.dataset.kind; filter();
}));
q.addEventListener('input', filter);
// 원본(이미지 글자) ↔ 실제 텍스트 토글
let before = false;
const tb = document.getElementById('toggleBefore');
function applyBefore() {
  document.body.classList.toggle('show-before', before);
  document.querySelectorAll('.tile img').forEach(im => { const src = before ? im.dataset.before : im.dataset.after; if (src) im.src = src; });
  tb.textContent = before ? '실제 텍스트 보기' : '원본(이미지 글자) 보기';
  tb.classList.toggle('primary', before);
}
tb.addEventListener('click', () => { before = !before; applyBefore(); });
document.addEventListener('keydown', e => {
  if (e.key !== 'b' && e.key !== 'B') return;
  const a = document.activeElement; if (a && (a.tagName === 'TEXTAREA' || a.tagName === 'INPUT')) return;
  before = !before; applyBefore();
});
// 카드별 코멘트(소리 보고 틀과 같은 방식): 브라우저 저장 + 결과 복사
const STORE = 'witchs-lodge-card-gallery';
let notes = {}, overall = '';
try { notes = JSON.parse(localStorage.getItem(STORE + ':notes') || '{}') || {}; overall = localStorage.getItem(STORE + ':overall') || ''; } catch (e) { notes = {}; }
function saveNotes() { try { localStorage.setItem(STORE + ':notes', JSON.stringify(notes)); localStorage.setItem(STORE + ':overall', overall); } catch (e) {} }
function grow(ta) { ta.style.height = 'auto'; ta.style.height = Math.max(26, ta.scrollHeight + 2) + 'px'; }
const out = document.getElementById('out'), ov = document.getElementById('overall'), toast = document.getElementById('toast');
function render() {
  const lines = [];
  document.querySelectorAll('.note').forEach(ta => {
    const v = (notes[ta.dataset.id] || '').trim();
    if (v) lines.push('- ' + ta.dataset.name + ' (' + ta.dataset.id + '): ' + v.replace(/\s*\n+\s*/g, ' / '));
  });
  document.getElementById('noteCount').textContent = lines.length;
  let t = '[마녀산장 카드 도감 코멘트] 카드 ' + lines.length + '장\n' + (lines.length ? lines.join('\n') : '(카드 코멘트 없음)');
  if (overall.trim()) t += '\n\n[전체 의견]\n' + overall.trim();
  out.textContent = t;
  return t;
}
document.querySelectorAll('.note').forEach(ta => {
  ta.value = notes[ta.dataset.id] || '';
  ta.closest('.tile').classList.toggle('has-note', !!ta.value.trim());
  ta.addEventListener('focus', () => { hide(); grow(ta); });
  ta.addEventListener('blur', () => { ta.style.height = ''; });
  ta.addEventListener('keydown', e => e.stopPropagation());
  ta.addEventListener('input', () => {
    const v = ta.value; if (v.trim()) notes[ta.dataset.id] = v; else delete notes[ta.dataset.id];
    ta.closest('.tile').classList.toggle('has-note', !!v.trim()); grow(ta); saveNotes(); render();
  });
});
ov.value = overall;
ov.addEventListener('input', () => { overall = ov.value; saveNotes(); render(); });
async function copy() {
  const t = render();
  try { await navigator.clipboard.writeText(t); toast.textContent = '복사했습니다. 대화창에 붙여 주세요.'; }
  catch (e) { const r = document.createRange(); r.selectNodeContents(out); const sel = getSelection(); sel.removeAllRanges(); sel.addRange(r); toast.textContent = '자동 복사가 막혀 내용을 선택해 두었습니다. Ctrl+C로 복사해 주세요.'; }
}
document.getElementById('copyTop').addEventListener('click', () => { copy(); document.getElementById('report').scrollIntoView({ block: 'start' }); });
document.getElementById('copyBottom').addEventListener('click', copy);
document.getElementById('clearAll').addEventListener('click', () => {
  if (!confirm('적은 코멘트를 모두 지울까요?')) return;
  notes = {}; overall = ''; ov.value = ''; saveNotes();
  document.querySelectorAll('.note').forEach(ta => { ta.value = ''; ta.closest('.tile').classList.remove('has-note'); });
  render(); filter();
});
render();
</script>
</body></html>
"""

if __name__ == "__main__":
    main()
