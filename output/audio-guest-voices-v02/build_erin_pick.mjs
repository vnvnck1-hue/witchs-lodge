// 술 주정뱅이 에린 목소리 고르기 페이지 erin-pick.html
// 지금까지 만든 후보(감탄사 1차 Lily·2차 Jessica/Sarah/Laura, 술을 시키려 누군가 부르는 듯한 말 없는 추임새 4목소리)를 목소리별로 모아
// 여러 개를 체크해 고르고(게임에서는 고른 것들을 무작위로 돌려 씀) 소리마다·전체 코멘트를 남긴다.
// 소리는 누를 때 한 번만 재생. 선택·코멘트는 브라우저에 저장되고 '결과 복사'로 보낸다.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const meta = JSON.parse(fs.readFileSync(path.join(HERE, "meta.json"), "utf8"));
const INTERJ = ["킥킥+딸꾹", "\"헤이~ 음~\"", "딸꾹+\"오~\"", "한숨+웃음"];
const ORDER = ["부르는 \"헤이~!\"", "혀 꼬부라진 \"어이~ 어이~\"", "손 흔드는 \"유~후~\""];
const voices = [
  { name: "Lily", note: "벨벳 같은 여성 · 지금 게임 목소리", sets: [["erin", "감탄사 (1차)", INTERJ, true], ["erin_order_lily", "부르는 듯한 추임새", ORDER]] },
  { name: "Jessica", note: "밝고 따뜻한 젊은 여성 · 가녀리게", sets: [["erin_jessica", "감탄사 (2차)", INTERJ], ["erin_order_jessica", "부르는 듯한 추임새", ORDER]] },
  { name: "Sarah", note: "젊은 여성 · 가녀리게", sets: [["erin_sarah", "감탄사 (2차)", INTERJ], ["erin_order_sarah", "부르는 듯한 추임새", ORDER]] },
  { name: "Laura", note: "젊고 경쾌한 여성 · 가녀리게", sets: [["erin_laura", "감탄사 (2차)", INTERJ], ["erin_order_laura", "부르는 듯한 추임새", ORDER]] },
];
const audio = {};
const data = voices.map((v) => ({
  name: v.name, note: v.note,
  sets: v.sets.map(([id, title, labels, inGame]) => ({
    title, inGame: !!inGame,
    clips: labels.map((label, i) => {
      const f = `${id}-0${i + 1}`;
      audio[f] = fs.readFileSync(path.join(HERE, "edited", f + ".wav")).toString("base64");
      const c = meta.clips?.[f] || {};
      return { id: f, label, stt: c.stt || "", sec: c.seconds ?? c.duration ?? null };
    }),
  })),
}));

const html = `<title>에린 목소리 고르기</title>
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
    <h1>술 주정뱅이 에린 — 쓸 목소리 고르기</h1>
    <p>지금까지 만든 후보 ${Object.keys(audio).length}개입니다. 목소리 4종(Lily·Jessica·Sarah·Laura)마다 짧은 감탄사와 술을 시키려 누군가를 <b>부르는 듯한 추임새</b>(말 없이 \"헤이~\"·\"어이~\"·\"유후~\")가 있습니다. 동그란 버튼을 누르면 <b>한 번만</b> 재생됩니다. 게임에 쓸 것을 <b>여러 개 체크</b>하면 대화 때 그중에서 무작위로 돌려 씁니다(목소리를 섞어 골라도 됩니다). 소리마다, 그리고 맨 아래에 전체 코멘트를 남길 수 있습니다. 다 고르면 <b>결과 복사</b>로 붙여 주세요.</p>
  </section>
  <div id="list"></div>
  <section class="voice all"><h2>전체 코멘트</h2><textarea id="all-note" placeholder="목소리 톤, 추가로 만들었으면 하는 추임새 등"></textarea></section>
  <pre id="out" hidden></pre>
</main>
<div class="bar"><div class="bar-in"><span class="count" id="count">0개 선택</span><button class="ghost" id="clear">선택 지우기</button><button id="copy">결과 복사</button></div></div>
<script>
const DATA = ${JSON.stringify(data)};
const AUDIO = ${JSON.stringify(audio)};
const KEY = "witchs-lodge-erin-pick-v02";
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
  const lines = ["에린 목소리 고르기", "", "[게임에 쓰기 " + picked.length + "개 — 무작위로 돌려 씀]"];
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
fs.writeFileSync(path.join(HERE, "erin-pick.html"), html);
console.log(Object.keys(audio).length, "clips", (html.length / 1024).toFixed(0), "KB");
