// 에린 카드 대사 3차 erin-space.html: Laura 고정. 목록 유지 2개 + 긴 여운 "아껴 마셔~" 새 후보, 모두 공간감(선술집 잔향) 처리.
// 마른 원본과 비교할 수 있게 같이 싣고, 선술집 소리(바탕음·웃음·건배)와 섞은 합성 테스트도 싣는다. 만드는 법: node erin_space.mjs
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const L = JSON.parse(fs.readFileSync(path.join(HERE, "space.json"), "utf8"));
const stt = { ...JSON.parse(fs.readFileSync(path.join(HERE, "erin-hype-stt-kor.json"), "utf8")), ...JSON.parse(fs.readFileSync(path.join(HERE, "erin-tail-stt-kor.json"), "utf8")) };
const audio = {};
const put = (id, f) => { audio[id] = fs.readFileSync(path.join(HERE, f)).toString("base64"); return id; };
const clipsOf = (arr) => arr.flatMap((v) => [
  { id: put(v.id + "@space", v.wet), label: v.label + " — 공간감", stt: (stt[v.id] || {}).text || "", sec: v.wetSec },
  { id: put(v.id + "@dry", v.dry), label: v.label + " — 원본(비교용)", stt: (stt[v.id] || {}).text || "", sec: v.drySec },
]);
const data = [
  { name: "목록 유지", note: "고르신 2개 · Laura", sets: [{ title: "공간감 처리 / 원본 비교", inGame: false, clips: clipsOf(L.space.filter((v) => v.keep)) }] },
  { name: "아껴 마셔~ 긴 여운 (새로)", note: "끝을 길게 늘인 새 후보 · Laura", sets: [{ title: "공간감 처리 / 원본 비교", inGame: false, clips: clipsOf(L.space.filter((v) => v.tailNew)) }] },
  { name: "선술집 소리 합성 테스트", note: "게임의 선술집 바탕음·둘이 웃음·단체 웃음·건배와 섞은 장면", sets: [{ title: "합성 버전", inGame: false, clips: L.mix.map((m) => ({ id: put("mix@" + m.name, m.file), label: m.label, stt: "", sec: m.sec })) }] },
];
const html = `<title>에린 카드 대사 3차</title>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com"><link href="https://fonts.googleapis.com/css2?family=Gowun+Batang:wght@400;700&family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
<style>
:root { --bg:#f5efe4; --panel:#fffaf1; --ink:#2b2219; --muted:#7b6b58; --line:#e2d6c2; --accent:#8a3f2b; --accent-soft:#f1dcd2; --pick:#2f6b4f; --pick-soft:#dcefe4; color-scheme:light; }
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { --bg:#1c1814; --panel:#26201a; --ink:#efe4d4; --muted:#a8977f; --line:#3b3229; --accent:#e09a7c; --accent-soft:#3d2a22; --pick:#7cc7a0; --pick-soft:#1f3328; color-scheme:dark; } }
:root[data-theme="dark"] { --bg:#1c1814; --panel:#26201a; --ink:#efe4d4; --muted:#a8977f; --line:#3b3229; --accent:#e09a7c; --accent-soft:#3d2a22; --pick:#7cc7a0; --pick-soft:#1f3328; color-scheme:dark; }
* { box-sizing:border-box; }
body { margin:0; background:var(--bg); color:var(--ink); font:15px/1.6 "Noto Sans KR", system-ui, sans-serif; padding:24px 16px 110px; }
main { max-width:960px; margin:0 auto; display:grid; gap:20px; }
h1 { font-family:"Gowun Batang", serif; font-size:26px; margin:0; text-wrap:balance; }
.intro p { margin:6px 0 0; color:var(--muted); max-width:68ch; }
.voice { background:var(--panel); border:1px solid var(--line); border-radius:12px; padding:16px; display:grid; gap:14px; }
.voice h2 { margin:0; font-family:"Gowun Batang", serif; font-size:20px; display:flex; gap:10px; align-items:baseline; flex-wrap:wrap; }
.voice h2 small { font:13px "Noto Sans KR", sans-serif; color:var(--muted); }
.set h3 { margin:0 0 8px; font-size:13px; letter-spacing:.04em; color:var(--muted); font-weight:500; }
.set h3 .tag { color:var(--accent); background:var(--accent-soft); border-radius:4px; padding:1px 6px; margin-left:6px; }
.clips { display:grid; grid-template-columns:repeat(auto-fill, minmax(200px, 1fr)); gap:10px; }
.clip { border:1px solid var(--line); border-radius:10px; padding:10px; display:grid; gap:6px; min-width:0; background:var(--bg); }
.clip.on { border-color:var(--pick); background:var(--pick-soft); }
.row { display:flex; gap:8px; align-items:center; }
.play { flex:none; width:34px; height:34px; border-radius:50%; border:0; background:var(--accent); color:var(--panel); cursor:pointer; font-size:13px; }
.play.playing { background:var(--pick); }
.lab { min-width:0; }
.lab b { display:block; font-size:14px; font-weight:500; overflow-wrap:anywhere; }
.lab span { font-size:12px; color:var(--muted); overflow-wrap:anywhere; font-variant-numeric:tabular-nums; }
label.use { display:flex; gap:6px; align-items:center; font-size:13px; cursor:pointer; }
label.use input { accent-color:var(--pick); width:16px; height:16px; }
textarea { width:100%; min-height:34px; resize:vertical; font:13px "Noto Sans KR", sans-serif; color:var(--ink); background:var(--panel); border:1px solid var(--line); border-radius:6px; padding:5px 7px; }
.all textarea { min-height:70px; }
.bar { position:fixed; left:0; right:0; bottom:0; background:var(--panel); border-top:1px solid var(--line); padding:10px 16px calc(10px + env(safe-area-inset-bottom, 0px)); }
.bar-in { max-width:960px; margin:0 auto; display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
.bar .count { margin-right:auto; color:var(--muted); font-variant-numeric:tabular-nums; }
.bar button { font:inherit; border:0; border-radius:8px; padding:8px 16px; cursor:pointer; background:var(--accent); color:var(--panel); }
.bar button.ghost { background:transparent; color:var(--muted); border:1px solid var(--line); }
pre#out { white-space:pre-wrap; background:var(--panel); border:1px solid var(--line); border-radius:8px; padding:12px; font-size:12.5px; }
</style>
<main>
  <section class="intro">
    <h1>술 주정뱅이 에린 — 카드 대사 3차 (Laura · 공간감 · 합성)</h1>
    <p>Laura 목소리로 고정했습니다. 고르신 2개는 목록에 그대로 두고, <b>아껴 마셔~</b> 끝에 여운이 길게 남는 새 후보를 더 만들었습니다. 모두 스튜디오처럼 건조하던 소리에 <b>작은 나무 선술집 같은 잔향</b>(약 1초에 걸쳐 사라짐)을 입혔고, 비교용으로 원본도 함께 실었습니다. 맨 아래는 게임의 <b>선술집 바탕음·웃음·건배와 섞은 합성 테스트</b>입니다. 버튼은 <b>한 번만</b> 재생됩니다. 쓸 것을 여러 개 체크하고 코멘트를 남긴 뒤 <b>결과 복사</b>로 붙여 주세요.</p>
  </section>
  <div id="list"></div>
  <section class="voice all"><h2>전체 코멘트</h2><textarea id="all-note" placeholder="목소리 톤, 추가로 만들었으면 하는 추임새 등"></textarea></section>
  <pre id="out" hidden></pre>
</main>
<div class="bar"><div class="bar-in"><span class="count" id="count">0개 선택</span><button class="ghost" id="clear">선택 지우기</button><button id="copy">결과 복사</button></div></div>
<script>
const DATA = ${JSON.stringify(data)};
const AUDIO = ${JSON.stringify(audio)};
const KEY = "witchs-lodge-erin-space-v01";
let state = { use: {}, note: {}, all: "" };
try { const s = JSON.parse(localStorage.getItem(KEY) || "null"); if (s) state = Object.assign(state, s); } catch (e) {}
const save = () => { try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) {} };
const urls = {};
const url = (id) => urls[id] || (urls[id] = URL.createObjectURL(new Blob([Uint8Array.from(atob(AUDIO[id]), (c) => c.charCodeAt(0))], { type: "audio/wav" })));
let cur = null;
function play(id, btn) {
  if (cur) { cur.a.pause(); cur.btn.classList.remove("playing"); cur.btn.textContent = "▶"; }
  const a = new Audio(url(id)); a.loop = false;
  cur = { a, btn }; btn.classList.add("playing"); btn.textContent = "■";
  a.onended = () => { btn.classList.remove("playing"); btn.textContent = "▶"; if (cur && cur.a === a) cur = null; };
  a.play().catch(() => {});
}
const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
const list = document.getElementById("list");
const all = [];
for (const v of DATA) {
  const sec = document.createElement("section"); sec.className = "voice";
  sec.innerHTML = "<h2>" + esc(v.name) + " <small>" + esc(v.note) + "</small></h2>";
  for (const s of v.sets) {
    const box = document.createElement("div"); box.className = "set";
    box.innerHTML = "<h3>" + esc(s.title) + (s.inGame ? '<span class="tag">지금 게임에 들어감</span>' : "") + "</h3>";
    const grid = document.createElement("div"); grid.className = "clips";
    for (const c of s.clips) {
      all.push({ voice: v.name, set: s.title, ...c });
      const el = document.createElement("div"); el.className = "clip";
      el.innerHTML = '<div class="row"><button class="play" aria-label="재생">▶</button><div class="lab"><b>' + esc(c.label) + "</b><span>" + (c.sec ? c.sec + "초 · " : "") + "받아쓰기: " + esc(c.stt || "-") + '</span></div></div>'
        + '<label class="use"><input type="checkbox"> 게임에 쓰기</label><textarea placeholder="코멘트"></textarea>';
      const [btn] = el.getElementsByClassName("play");
      const cb = el.querySelector("input"), ta = el.querySelector("textarea");
      btn.onclick = () => play(c.id, btn);
      cb.checked = !!state.use[c.id]; el.classList.toggle("on", cb.checked);
      cb.onchange = () => { state.use[c.id] = cb.checked; el.classList.toggle("on", cb.checked); save(); count(); };
      ta.value = state.note[c.id] || ""; ta.oninput = () => { state.note[c.id] = ta.value; save(); };
      grid.appendChild(el);
    }
    box.appendChild(grid); sec.appendChild(box);
  }
  list.appendChild(sec);
}
const allNote = document.getElementById("all-note");
allNote.value = state.all || ""; allNote.oninput = () => { state.all = allNote.value; save(); };
function count() { document.getElementById("count").textContent = all.filter((c) => state.use[c.id]).length + "개 선택 (게임에서 무작위로 돌려 씀)"; }
count();
document.getElementById("clear").onclick = () => { state.use = {}; save(); document.querySelectorAll(".clip").forEach((el) => { el.classList.remove("on"); el.querySelector("input").checked = false; }); count(); };
function report() {
  const picked = all.filter((c) => state.use[c.id]);
  const lines = ["에린 카드 대사 3차 고르기", "", "[게임에 쓰기 " + picked.length + "개 — 무작위로 돌려 씀]"];
  for (const c of picked) lines.push("- " + c.voice + " / " + c.set + " / " + c.label + " (" + c.id + ")" + (state.note[c.id] ? " — 코멘트: " + state.note[c.id].trim() : ""));
  if (!picked.length) lines.push("- 없음");
  const notes = all.filter((c) => !state.use[c.id] && (state.note[c.id] || "").trim());
  if (notes.length) { lines.push("", "[고르지 않은 소리 코멘트]"); for (const c of notes) lines.push("- " + c.voice + " / " + c.set + " / " + c.label + " (" + c.id + "): " + state.note[c.id].trim()); }
  if ((state.all || "").trim()) lines.push("", "[전체 코멘트]", state.all.trim());
  return lines.join("\\n");
}
document.getElementById("copy").onclick = async () => {
  const t = report(), out = document.getElementById("out");
  out.textContent = t; out.hidden = false;
  try { await navigator.clipboard.writeText(t); document.getElementById("count").textContent = "복사했어요 — 대화창에 붙여 주세요"; }
  catch (e) { const r = document.createRange(); r.selectNodeContents(out); const s = getSelection(); s.removeAllRanges(); s.addRange(r); document.getElementById("count").textContent = "아래 글을 복사해 주세요"; }
  out.scrollIntoView({ behavior: "smooth" });
};
</script>
`;
fs.writeFileSync(path.join(HERE, "erin-space.html"), html);
console.log(Object.keys(audio).length, "clips", (html.length / 1024).toFixed(0), "KB");
