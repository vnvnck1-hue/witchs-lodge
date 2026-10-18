// 마녀산장 위키 생성기.
//  - 수치·목록: godot/scripts/config.gd, chapter_data.gd, guest_profiles.gd, assets/cards/catalog.json, godot/README.md 조작표에서 읽는다.
//  - 서술: wiki/src/pages/**/*.md (위키용 마크다운 + {{매크로}}).
//  - 결과: wiki/dist/index.html + dist/img/*. 이미지는 sharp로 원본 에셋에서 줄인다.
"use strict";
const fs = require("fs"), path = require("path"), cp = require("child_process");
const { marked } = require("marked");
const { parseConsts } = require("./gd.js");

const ROOT = path.resolve(__dirname, "..", "..");
const SRC = __dirname, PAGES_DIR = path.join(SRC, "pages"), DIST = path.join(ROOT, "wiki", "dist"), IMG = path.join(DIST, "img");
const GODOT = path.join(ROOT, "godot");
const REPO_URL = "https://github.com/vnvnck1-hue/witchs-lodge";
const rd = f => fs.readFileSync(f, "utf8");
const pid = s => s.replace(/ /g, "_");

/* ---------- 데이터 ---------- */
const cfg = parseConsts(rd(path.join(GODOT, "scripts/config.gd")));
const ch = parseConsts(rd(path.join(GODOT, "scripts/game/chapter_data.gd")));
const gp = parseConsts(rd(path.join(GODOT, "scripts/ui/guest_profiles.gd")));
const catalogRaw = JSON.parse(rd(path.join(GODOT, "assets/cards/catalog.json")));
const CARDS = (Array.isArray(catalogRaw) ? catalogRaw : (catalogRaw.cards || Object.values(catalogRaw))).map(c => ({
  id: c.id, name: c.name, category: c.category || "", kind: c.kind, rules: c.printed_rules || [], desc: c.description || "",
  acq: c.acquisition || "", targets: c.target_tags || [], stack: !!c.stackable,
  hand: c.hand_texture ? c.hand_texture.replace("res://", "") : null,
}));
const cardById = Object.fromEntries(CARDS.map(c => [c.id, c]));
const KIND_LABEL = { structure: "설치물", livestock: "가축", resource: "자원", summon: "소환", spell: "주문", invite: "초대", contract: "용병 계약", treasure: "보물", relic: "유물", draw: "드로우", corruption: "침식" };
const KIND_ORDER = ["contract", "resource", "livestock", "structure", "spell", "summon", "invite", "draw", "treasure", "relic", "corruption"];
const TAG_LABEL = { walkable_ground: "이동 가능한 지면", pasture: "목장", thorn_plant: "가시 씨앗·방책", lodge_trade: "산장(교역)", damaged_lodge: "손상된 산장", enemy: "적", defense_point: "방어 지점", harvestable_tree: "벌목 가능한 나무", player: "마녀", lodge: "산장" };
const GUESTS = gp.CATALOG.map(g => Object.assign({}, g, { job: gp.JOBS[g.person] || null, portrait: g.portrait.replace("res://", "") }));
const JOB_CARD = { warrior: "브람", hunter: "올라프", lumberjack: "토르빈", gatherer: "미라" };

// README 조작표
function controlsTable() {
  const lines = rd(path.join(GODOT, "README.md")).split(/\r?\n/);
  const i = lines.findIndex(l => /^\|\s*입력\s*\|\s*동작\s*\|/.test(l));
  if (i < 0) return [];
  const rows = [];
  for (let k = i + 2; k < lines.length && lines[k].startsWith("|"); k++) {
    const cells = lines[k].split("|").slice(1, -1).map(s => s.trim());
    if (cells.length >= 2) rows.push(cells);
  }
  return rows;
}
const CONTROLS = controlsTable();

/* ---------- git 역사 ---------- */
function gitLog(paths, limit = 12) {
  try {
    const out = cp.execFileSync("git", ["log", `-n${limit}`, "--date=short", "--format=%ad\t%s", "--", ...paths], { cwd: ROOT, encoding: "utf8" });
    return out.split("\n").filter(Boolean).map(l => { const [d, s] = l.split("\t"); return [d, s]; });
  } catch (e) { return []; }
}
const DATA_SOURCES = ["godot/scripts/config.gd", "godot/scripts/game/chapter_data.gd", "godot/assets/cards/catalog.json", "godot/scripts/ui/guest_profiles.gd"];

/* ---------- 이미지 ---------- */
let sharp = null; try { sharp = require("sharp"); } catch (e) { }
const imageJobs = [];
function img(srcRel, outName, width, mode) { if (!imageJobs.some(j => j.out === outName)) imageJobs.push({ src: path.join(ROOT, srcRel), out: outName, width, mode }); return outName; }
function cardImg(c) { return c.hand && fs.existsSync(path.join(GODOT, c.hand)) ? img("godot/" + c.hand, `card_${c.id}.jpg`, 240, "card") : null; }
CARDS.forEach(cardImg);
GUESTS.forEach(g => img("godot/" + g.portrait, `guest_${g.id}.png`, 300, "png"));
const SHOTS = {
  "01-travelers-arrival.jpg": "art/concepts/gameplay/01-travelers-arrival.png", "02-lodge-expansion.jpg": "art/concepts/gameplay/02-lodge-expansion.png",
  "03-forest-encounter.jpg": "art/concepts/gameplay/03-forest-encounter.png", "04-dragon-gold-defense.jpg": "art/concepts/gameplay/04-dragon-gold-defense.png",
  "prototype-reference.jpg": "art/concepts/environment/04-prototype-reference-simplified.png", "ingame-close-1.jpg": "godot/screenshots/spider/ingame-close-1.png",
  "asset-sheet.jpg": "godot/screenshots/ftue/asset-sheet.png", "shot-day-hud.jpg": "godot/screenshots/lodge-layout/01-day-follow-hud.png",
  "shot-night-overview.jpg": "godot/screenshots/lodge-layout/03-night-overview.png", "shot-altar.jpg": "godot/screenshots/chapter/03-altar.png",
  "shot-enemy-kinds.jpg": "godot/screenshots/chapter/05-enemy-kinds.png", "shot-market.jpg": "godot/screenshots/chapter/02-market.png",
  "shot-dawn-reward.jpg": "godot/screenshots/chapter/01-dawn-reward.png", "shot-chest.jpg": "godot/screenshots/jobs/jobs_chest.png",
  "shot-pocket.jpg": "godot/screenshots/pocket-gallery/00-gallery-open.png", "shot-jobs-day.jpg": "godot/screenshots/jobs/jobs_day.png",
};
Object.entries(SHOTS).forEach(([o, s]) => fs.existsSync(path.join(ROOT, s)) && img(s, o, 900, "jpg"));
async function buildImages() {
  fs.mkdirSync(IMG, { recursive: true });
  if (!sharp) { console.warn("sharp 없음: 이미지를 다시 만들지 않습니다 (npm install 필요)"); return; }
  let made = 0;
  for (const j of imageJobs) {
    const out = path.join(IMG, j.out);
    if (!fs.existsSync(j.src)) continue;
    if (fs.existsSync(out) && fs.statSync(out).mtimeMs >= fs.statSync(j.src).mtimeMs) continue;
    let s = sharp(j.src).resize({ width: j.width });
    if (j.mode === "card") s = s.flatten({ background: "#261c34" }).jpeg({ quality: 82 });
    else if (j.mode === "jpg") s = s.flatten({ background: "#000" }).jpeg({ quality: 82 });
    else s = s.png({ compressionLevel: 9 });
    await s.toFile(out); made++;
  }
  console.log(`이미지 ${made}개 생성, ${imageJobs.length}개 사용`);
}

/* ---------- HTML 조각 ---------- */
const esc = s => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
function link(title, text) { return `<a href="#${pid(title)}">${text || title}</a>`; }
function cl(id, text) { const c = cardById[id]; return c ? link("카드:" + c.name, text || c.name) : esc(text || id); }
function cardThumb(c, w) { return c && cardImg(c) ? `<img class="card-mini" src="img/card_${c.id}.jpg" alt="${esc(c.name)}" loading="lazy" style="width:${w || 44}px">` : ""; }
function thumb(src, cap, side, w) { w = +w || 300; return `<div class="thumb ${side || "tright"}"><div class="thumbinner" style="width:${w + 6}px"><a href="img/${src}" target="_blank" rel="noopener"><img src="img/${src}" width="${w}" alt="${esc(cap.replace(/<[^>]+>/g, ""))}" loading="lazy"></a><div class="thumbcaption"><div class="magnify"></div>${cap}</div></div></div>`; }
function wt(head, rows, o = {}) { return `<div class="table-wrap"><table class="wikitable">${o.caption ? `<caption>${o.caption}</caption>` : ""}<tr>${head.map(h => `<th>${h}</th>`).join("")}</tr>${rows.map(r => `<tr>${r.map((v, i) => `<td${o.num && o.num.includes(i) ? ' class="num"' : ""}>${v}</td>`).join("")}</tr>`).join("")}</table></div>`; }
function ambox(kind, ico, text) { return `<div class="ambox ${kind}"><span class="ico">${ico}</span><div><p>${text}</p></div></div>`; }
const fmt = v => typeof v === "number" ? (Number.isInteger(v) ? String(v) : String(+v.toFixed(2))) : String(v);
function get(obj, dotted) { return dotted.split(".").reduce((o, k) => (o == null ? undefined : o[k]), obj); }
function costStr(c) { return [c.gold ? `${c.gold}G` : "", c.timber ? `목재 ${c.timber}` : ""].filter(Boolean).join(" + "); }
function mdInline(s) { return marked.parseInline(s); }

/* ---------- 표 매크로 ---------- */
const TABLES = {
  enemies: () => wt(["종류", "체력", "속도", "피해 / 간격", "사거리", "산장 피해", "비고"], Object.entries(cfg.ENEMY_KINDS).map(([k, e]) => [
    `<b id="enemy_${k}">${esc(e.name)}</b>`, e.hp != null ? `${fmt(e.hp)}(고정)` : `${fmt(e.hp_mult)}배`, fmt(e.speed), `${fmt(e.damage)} / ${fmt(e.interval)}초`, `${fmt(e.reach)}m${e.reach >= 3 ? "(원거리)" : ""}`, `${fmt(e.lodge_mult || 1)}배`,
    [e.ignore_units ? "아군 무시" : "", e.big ? "큰 몸집" : "", e.scale && e.scale !== 1 ? `크기 ${fmt(e.scale)}배` : "", k === "boss" ? `피해 상한 ${fmt(cfg.BOSS_HIT_CAP)}, ${fmt(cfg.BOSS_ROAR_INTERVAL)}초마다 ${cfg.BOSS_ROAR_SPAWN}마리 소환, 전리품 ${cl(cfg.BOSS_TROPHY)}` : ""].filter(Boolean).join(", ") || "—"]), { caption: "config.gd ENEMY_KINDS" }),
  nights: () => wt(["규칙", "설명"], Object.values(ch.NIGHT_RULES).map(n => [`<span class="night-tag">${esc(n.name)}</span>`, esc(n.desc)])),
  days: () => {
    const KN = { cultist: "침", insect: "곤", brute: "공", boss: "보스" };
    return wt(["일", "밤", "기준 체력", "양 목표", "출현(순서별 인원)", "비고"], ch.CHAPTER_1.days.map((d, i) => [String(i + 1), `<span class="night-tag">${esc(ch.NIGHT_RULES[d.night].name)}</span>`, fmt(d.hp), String(d.sheep),
      d.groups.map(g => g[2] ? (g[2] === "boss" ? "보스" : g[1] + KN[g[2]]) : String(g[1])).join("+"),
      [d.unlock === "altar" ? "제단 해금" : "", d.reward ? "새벽 보상" : "", d.market ? "장날" : "", d.night === "boss" ? esc(ch.CHAPTER_1.boss_name) : ""].filter(Boolean).join(" · ") || "—"]), { num: [0, 2, 3] });
  },
  market: () => wt(["", "카드", "가격"], Object.entries(ch.MARKET_PRICES).sort((a, b) => a[1] - b[1]).map(([id, p]) => [cardThumb(cardById[id]), cl(id), p + "G"]), { num: [2] }),
  relics: () => wt(["", "유물", "효과"], cfg.RELICS.map(id => [cardThumb(cardById[id]), cl(id, cfg.RELIC_NAMES[id]), esc(cfg.RELIC_DESC[id])])),
  rituals: () => wt(["의식", "공물", "첫 완성 권능", "반복 시 축복"], Object.values(cfg.RITUALS).map(r => [esc(r.name), Object.entries(r.cost).map(([k, v]) => k === "sheep" ? `어른 양 ${v}마리` : `${cardById[k] ? cl(k) : k} ${v}`).join(", "), cl(r.power), esc(r.desc.split("축복:").pop().trim())])),
  build_costs: () => wt(["항목", "비용", "효과"], [
    ["증축", costStr(cfg.BUILD_COSTS.extension[0]), `정원 ${cfg.BASE_CAPACITY} → ${cfg.EXT_CAPACITY}`],
    ["목장 확장", cfg.BUILD_COSTS.pasture.map(costStr).join(" / "), cfg.PASTURE_LEVELS.map(p => p.cap).join(" → ") + "마리"],
    ["묘지 확장", cfg.BUILD_COSTS.graves.map(costStr).join(" / "), cfg.GRAVE_LEVELS.join(" → ") + "칸"],
    ["수리", `${cfg.COST_REPAIR}G`, `체력 +${fmt(cfg.REPAIR_AMOUNT)}`], ["목재 수리", `목재 ${cfg.TIMBER_REPAIR_COST}`, `체력 +${fmt(cfg.TIMBER_REPAIR_AMOUNT)} (낮에만. 밤에는 ${cl("winter_firewood")})`],
    ["마녀 회복", `${cfg.COST_HEAL}G`, `체력 +${fmt(cfg.HEAL_AMOUNT)}`], ["양 재구입", `${cfg.COST_SHEEP}G`, "빈자리에 양 1마리"], ["계약 해지", `환급 ${cfg.CONTRACT_REFUND}G`, "용병·미사용 계약 제거"]]),
  sale_prices: () => Object.entries(cfg.SALE_PRICES).map(([k, v]) => `${cl(k)} ${v}G`).join(" · "),
  controls: () => wt(["입력", "동작"], CONTROLS.map(r => r.map(mdInline))),
  guests: () => wt(["초상", "인물", "직업", "고용", "첫인상"], GUESTS.map(g => [`${link(g.person, `<img src="img/guest_${g.id}.png" alt="${esc(g.person)}" class="portrait-img" style="width:56px">`)}`, link(g.person, `<b>${esc(g.person)}</b>`), esc(g.role), g.job ? cl(g.job) : "—", esc(g.tag)])),
  jobs: () => wt(["직업", "카드", "고용 인물", "체력", "전투"], cfg.JOB_CARDS.map(j => [esc(cfg.JOB_NAMES[j]), cl(j), link(JOB_CARD[j]), fmt(cfg.JOB_HP[j]),
    j === "hunter" ? `원거리(활 ${fmt(cfg.HUNTER_RANGE)}m), 피해 ${fmt(cfg.HUNTER_DAMAGE)} / ${fmt(cfg.HUNTER_INTERVAL)}초` : j === "warrior" ? `근접 ${fmt(cfg.ALLY_MELEE)}m, 피해 ${fmt(cfg.WARRIOR_DAMAGE)} / ${fmt(cfg.WARRIOR_INTERVAL)}초` : "안 함"])),
  gather_table: () => wt(["결과", "확률"], cfg.GATHER_TABLE.map(r => [r[0] ? cl(r[0]) : "빈손", Math.round(r[1] * 100) + "%"]), { num: [1] }),
  animals: () => wt(["동물", "체력", "속도", "동시 최대"], [["토끼", fmt(cfg.RABBIT_HP), fmt(cfg.RABBIT_SPEED), String(cfg.RABBIT_MAX)], ["사슴", fmt(cfg.DEER_HP), fmt(cfg.DEER_SPEED), String(cfg.DEER_MAX)]]),
  waves: () => wt(["밤", "적 수", "기준 체력", "양 목표"], cfg.WAVES.map((w, i) => [String(i + 1), String(w.count), fmt(w.hp), String(w.sheep)]), { num: [0, 1, 2, 3] }),
  cards_by_kind: () => KIND_ORDER.map(k => [k, CARDS.filter(c => c.kind === k)]).filter(g => g[1].length).map(([k, cs]) => `<h3 id="종류_${k}">${KIND_LABEL[k]} (${cs.length})</h3>` + wt(["", "이름", "분류", "획득", "사용 대상", "중첩"], cs.map(c => [link("카드:" + c.name, cardThumb(c)), cl(c.id, `<b>${esc(c.name)}</b>`), esc(c.category), esc(c.acq), c.targets.map(t => TAG_LABEL[t] || t).join(", ") || "—", c.stack ? "수량" : "1장"]))).join(""),
  gallery: () => `<ul class="gallery">${CARDS.filter(c => c.id !== "relic_unknown" && cardImg(c)).map(c => `<li class="gallerybox"><div class="thumbnail">${link("카드:" + c.name, `<img src="img/card_${c.id}.jpg" alt="${esc(c.name)}" loading="lazy">`)}</div><div class="gallerytext">${cl(c.id)}</div></li>`).join("")}</ul>`,
  reward_pool: () => ch.REWARD_POOL.map(id => cl(id)).join(" · "),
  starter_cards: () => cfg.STARTER_CARDS.map(([id, n]) => cl(id) + (n > 1 ? ` ×${n}` : "")).join(" · "),
  guest_arrivals: () => cfg.GUEST_ARRIVALS.map(fmt).join("·") + "초",
};

/* ---------- 매크로 ---------- */
const NOTES = {
  dev: () => ambox("notice", "🛠", `이 문서는 <b>개발 중인 프로토타입</b>(Godot 4.7.2)을 다룹니다. 수치는 게임 데이터(<code>config.gd</code>·<code>chapter_data.gd</code>·<code>catalog.json</code>)에서 <b>자동으로 읽어</b> 넣은 현재 값이며 플레이테스트로 바뀝니다.`),
  plan: () => ambox("content", "📜", "이 문서의 일부는 <b>기획 단계</b>의 내용입니다. 사용자 확정 방향과 아직 미정인 세부를 구분해 적었으며, 게임에 구현되지 않은 항목은 그렇게 표시했습니다."),
};
function expandMacros(md, ctx) {
  // {{infobox ... }} 여러 줄
  md = md.replace(/\{\{infobox\n([\s\S]*?)\n\}\}/g, (_, body) => {
    const rows = body.split("\n").map(l => l.trim()).filter(Boolean).map(l => { const i = l.indexOf(":"); return [l.slice(0, i).trim(), l.slice(i + 1).trim()]; });
    let cap = "", imgRow = "", cls = "";
    const cells = [];
    for (const [k, v] of rows) {
      if (k === "caption") cap = v; else if (k === "class") cls = v;
      else if (k === "image") { const [f, c] = v.split("|"); imgRow = `<tr><td class="image" colspan="2"><img src="img/${f}" alt="${esc(cap)}">${c ? `<div class="caption">${expandInline(c)}</div>` : ""}</td></tr>`; }
      else cells.push(`<tr><th>${esc(k)}</th><td>${expandInline(v)}</td></tr>`);
    }
    return `<table class="infobox ${cls}"><caption>${expandInline(cap)}</caption>${imgRow}${cells.join("")}</table>`;
  });
  return expandInline(md);
}
function expandInline(s) {
  // 백틱 코드 스팬과 {{{리터럴}}}은 매크로를 펼치지 않는다.
  const lit = [];
  const keep = x => { lit.push(x); return "@@LIT" + (lit.length - 1) + "@@"; };
  s = s.replace(/\{\{\{([^}]*)\}\}\}/g, (_, x) => keep("{{" + x + "}}")).replace(/`[^`\n]+`/g, m => keep(m));
  s = s
    .replace(/\{\{thumb\|([^|}]+)\|([^|}]*)(?:\|([^|}]*))?(?:\|([^|}]*))?\}\}/g, (_, f, cap, side, w) => thumb(f.trim(), mdInline(cap), side, w))
    .replace(/\{\{card\|([^|}]+)(?:\|([^}]*))?\}\}/g, (_, id, t) => cl(id.trim(), t))
    .replace(/\{\{cfg\|([^}|]+)(?:\|([^}]*))?\}\}/g, (_, k, suf) => { const v = get(cfg, k.trim()); return v == null ? `<span class="new">cfg.${esc(k)}?</span>` : fmt(v) + (suf || ""); })
    .replace(/\{\{ch\|([^}|]+)(?:\|([^}]*))?\}\}/g, (_, k, suf) => { const v = get(ch, k.trim()); return v == null ? `<span class="new">ch.${esc(k)}?</span>` : fmt(v) + (suf || ""); })
    .replace(/\{\{table\|(\w+)\}\}/g, (_, n) => TABLES[n] ? TABLES[n]() : `<span class="new">table ${n}?</span>`)
    .replace(/\{\{note\|(\w+)\}\}/g, (_, n) => NOTES[n] ? NOTES[n]() : "")
    .replace(/\{\{count\}\}/g, "__PAGECOUNT__").replace(/\{\{cardcount\}\}/g, String(CARDS.length))
    .replace(/\{\{recent\|(\d+)\}\}/g, (_, n) => `__RECENT_${n}__`)
    .replace(/\[\[([^\]|]+)\|([^\]]+)\]\]/g, (_, t, x) => link(t.trim(), x.trim()))
    .replace(/\[\[([^\]]+)\]\]/g, (_, t) => link(t.trim()));
  return s.replace(/@@LIT(\d+)@@/g, (_, i) => lit[+i]);
}

/* ---------- 문서 ---------- */
const PAGES = {};
function frontmatter(text) {
  const m = text.match(/^---\n([\s\S]*?)\n---\n?/); if (!m) return [{}, text];
  const fm = {}; m[1].split("\n").forEach(l => { const i = l.indexOf(":"); if (i > 0) fm[l.slice(0, i).trim()] = l.slice(i + 1).trim(); });
  return [fm, text.slice(m[0].length)];
}
function addPage(title, html, opts = {}) {
  PAGES[pid(title)] = Object.assign({ title, html, cats: [], revs: [], sub: null, noToc: false, src: null, srcPath: null }, opts);
}
function readMd(file) { return frontmatter(rd(file)); }
function mdToHtml(md) { return marked.parse(expandMacros(md), { gfm: true, breaks: false }).replace(/<table>/g, "<div class=\"table-wrap\"><table class=\"wikitable\">").replace(/<\/table>/g, "</table></div>"); }

// 1) 서술 문서
const mdFiles = fs.readdirSync(PAGES_DIR).filter(f => f.endsWith(".md"));
for (const f of mdFiles) {
  const [fm, body] = readMd(path.join(PAGES_DIR, f));
  const title = fm.title || f.replace(/\.md$/, "");
  const rel = path.relative(ROOT, path.join(PAGES_DIR, f)).replace(/\\/g, "/");
  addPage(title, mdToHtml(body), { cats: fm.cats ? fm.cats.split(",").map(s => s.trim()) : [], sub: fm.sub != null ? fm.sub : null, noToc: fm.toc === "false", src: body, srcPath: rel, revs: gitLog([rel]) });
}
// 2) 카드 문서(카탈로그에서 생성, cards/<id>.md 가 있으면 비고로 붙인다)
for (const c of CARDS) {
  const extraFile = path.join(PAGES_DIR, "cards", c.id + ".md");
  const extra = fs.existsSync(extraFile) ? mdToHtml(readMd(extraFile)[1]) : "";
  const price = ch.MARKET_PRICES[c.id];
  const html = `<div class="hatnote">카드 목록 전체는 ${link("카드")} 문서를 참고하십시오.</div>
<table class="infobox card"><caption>${esc(c.name)}</caption>${cardImg(c) ? `<tr><td class="image" colspan="2"><img src="img/card_${c.id}.jpg" alt="${esc(c.name)} 카드 원화"><div class="caption">손패용 카드 원화</div></td></tr>` : ""}
<tr><th>분류</th><td>${esc(c.category)}</td></tr><tr><th>종류</th><td><a href="#카드#종류_${c.kind}">${KIND_LABEL[c.kind] || c.kind}</a></td></tr><tr><th>획득</th><td>${esc(c.acq)}</td></tr>
<tr><th>사용 대상</th><td>${c.targets.map(t => TAG_LABEL[t] || t).join("<br>") || "사용 불가"}</td></tr><tr><th>중첩</th><td>${c.stack ? "수량 표시" : "1장씩"}</td></tr><tr><th>내부 ID</th><td><code>${c.id}</code></td></tr></table>
<p><b>${esc(c.name)}</b>은(는) 마녀산장의 <a href="#카드#종류_${c.kind}">${KIND_LABEL[c.kind] || c.kind}</a> 카드다. ${esc(c.desc)}</p>
${c.rules.length ? `<h2>카드 문구</h2><blockquote>${c.rules.map(r => `<p>${esc(r)}</p>`).join("")}</blockquote>` : ""}
${extra ? `<h2>비고</h2>${extra}` : ""}
${price ? `<h2>장날</h2><p>${link("장날과 새벽 보상", "장날")}에 <b>${price}G</b>에 살 수 있다.${ch.REWARD_POOL.includes(c.id) ? " 새벽 보상 3장 중 하나로도 나온다." : ""}</p>` : ""}
<h2>같이 보기</h2><ul><li>같은 종류: ${CARDS.filter(x => x.kind === c.kind && x.id !== c.id).map(x => cl(x.id)).join(" · ") || "없음"}</li></ul>`;
  addPage("카드:" + c.name, html, { title: c.name, cats: ["카드", (KIND_LABEL[c.kind] || c.kind) + " 카드"].concat(c.acq.includes("시작 손패") ? ["시작 손패"] : []), revs: gitLog(["godot/assets/cards/catalog.json", `wiki/src/pages/cards/${c.id}.md`]), srcPath: `wiki/src/pages/cards/${c.id}.md`, src: fs.existsSync(extraFile) ? readMd(extraFile)[1] : "" });
}
// 3) 손님 문서(guest_profiles.gd 에서 생성, guests/<id>.md 가 있으면 인물 절로 붙인다)
for (const g of GUESTS) {
  const extraFile = path.join(PAGES_DIR, "guests", g.id + ".md");
  const extra = fs.existsSync(extraFile) ? mdToHtml(readMd(extraFile)[1]) : `<p>${esc(g.detail)}.</p>`;
  const html = `<table class="infobox"><caption>${esc(g.person)}</caption><tr><td class="image" colspan="2"><img src="img/guest_${g.id}.png" alt="${esc(g.person)} 초상" class="portrait-img"><div class="caption">게임 내 초상(배경 제거판)</div></td></tr>
<tr><th>종족</th><td>인간</td></tr><tr><th>직업</th><td>${esc(g.role)}</td></tr><tr><th>소개</th><td>${esc(g.detail)}</td></tr><tr><th>첫인상</th><td>${esc(g.tag)}</td></tr>
<tr><th>고용</th><td>${g.job ? `${cl(g.job)} 계약 ${cfg.CONTRACT_COST}G` : "고용 불가"}</td></tr><tr><th>내부 ID</th><td><code>guest_${g.id}</code></td></tr></table>
<p><b>${esc(g.person)}</b>은(는) 마녀산장의 ${link("손님")} ${GUESTS.length}명 중 한 명이다. ${esc(g.detail)}이며, 첫인상은 '${esc(g.tag)}'이다.</p>
<h2>인물</h2>${extra}
<h2>대사</h2><p>방문 횟수에 따라 첫인사와 재방문 인사가 바뀐다. 두 번째 대사는 숲의 소문이며 미스터리의 진실을 확정하지 않는다.</p>${g.lines.map((l, i) => `<blockquote><p><span class="diff-tag">${["첫 방문", "숲의 소문", "재방문"][i] || i + 1}</span><br>${esc(l).replace(/\n/g, "<br>")}</p></blockquote>`).join("")}
${g.job ? `<h2>계약 카드</h2><p>고용하면 ${cl(g.job)} 카드를 얻는다. 낮·밤 행동과 전투 수치는 ${link("용병 직업")} 문서에 있다.</p>` : `<h2>역할</h2><p>고용할 수 없는 손님은 숙박비(${cfg.GUEST_FEE}G)를 내고 대화로 숲의 소문을 전한다. 비전투 손님의 다른 활용은 미정이다.</p>`}
<h2>같이 보기</h2><ul><li>${link("손님")} · ${GUESTS.filter(x => x.id !== g.id).map(x => link(x.person)).join(" · ")}</li></ul>`;
  addPage(g.person, html, { cats: ["등장인물", "손님", g.job ? "고용 가능 손님" : "고용 불가 손님"], revs: gitLog(["godot/scripts/ui/guest_profiles.gd", `wiki/src/pages/guests/${g.id}.md`]), srcPath: `wiki/src/pages/guests/${g.id}.md`, src: fs.existsSync(extraFile) ? readMd(extraFile)[1] : "" });
}

/* ---------- 후처리: 빨간 링크, 자리표 ---------- */
const allRevs = []; Object.values(PAGES).forEach(p => p.revs.forEach(r => allRevs.push([r[0], p.title, r[1]])));
allRevs.sort((a, b) => b[0].localeCompare(a[0]));
const recentHtml = n => `<ul>${allRevs.slice(0, +n).map(([d, t, s]) => `<li><span class="rc-date">${d}</span> — ${link(t)} <span class="diff-tag">(${esc(s)})</span></li>`).join("")}</ul>`;
const pageCount = Object.keys(PAGES).length;
for (const p of Object.values(PAGES)) {
  p.html = p.html.replace(/__PAGECOUNT__/g, String(pageCount)).replace(/__RECENT_(\d+)__/g, (_, n) => recentHtml(n))
    .replace(/href="#([^"#]+)(#[^"]*)?"/g, (m, t, a) => { const key = decodeURIComponent(t); if (key.startsWith("특수:") || key.startsWith("검색:") || key.startsWith("편집:") || key.startsWith("역사:") || key.startsWith("토론:") || PAGES[key]) return m; return `href="#${t}${a || ""}" class="new" title="${esc(key.replace(/_/g, " "))} (아직 작성되지 않은 문서)"`; });
  if (!p.revs.length) p.revs = [[new Date().toISOString().slice(0, 10), "문서 생성"]];
}

/* ---------- 출력 ---------- */
(async () => {
  fs.mkdirSync(DIST, { recursive: true });
  await buildImages();
  const template = rd(path.join(SRC, "template.html"));
  const payload = { pages: PAGES, built: new Date().toISOString(), repo: REPO_URL, cardCount: CARDS.length, guestCount: GUESTS.length };
  const html = template.replace("/*WIKI_DATA*/null", JSON.stringify(payload).replace(/<\/script/g, "<\\/script"));
  fs.writeFileSync(path.join(DIST, "index.html"), html, "utf8");
  fs.writeFileSync(path.join(DIST, ".nojekyll"), "");
  console.log(`문서 ${pageCount}개 (카드 ${CARDS.length}, 손님 ${GUESTS.length}) → ${path.relative(ROOT, DIST)}/index.html (${(html.length / 1024).toFixed(0)}KB)`);
})();
