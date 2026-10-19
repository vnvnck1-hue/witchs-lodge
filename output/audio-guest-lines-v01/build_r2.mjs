// 2차 후보를 받아써 확인하고 lines-r2.html 을 만든다. Callum 후보는 재생 속도(피치 함께 낮춤) 미리듣기 버튼을 붙인다.
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const KEY = fs.readFileSync(path.join(os.homedir(), ".elevenlabs", "api_key"), "utf8").trim();
const meta = JSON.parse(fs.readFileSync(path.join(HERE, "meta-r2.json"), "utf8"));
const label = { "r2-callum-a": "Callum(브람 목소리) · 중후·느리게", "r2-callum-b": "Callum(브람 목소리) · 낮고 거칠게", "r2-brian": "Brian · 깊고 울림 (토르빈과 같은 목소리)", "r2-bill": "Bill · 늙고 지혜로움 (하랄과 같은 목소리)", "r2-adam": "Adam · 단호·굵음 (올라프와 같은 목소리)", "r2-roger": "Roger · 느긋하고 울림 (아직 아무도 안 씀)" };
const items = [{ id: "bram-v3-b", dir: "raw", voice: "Callum", text: "(1차 2번 원본)", ref: true }, ...meta.items];
for (const it of items) {
  if (it.stt || it.ref) continue;
  const fd = new FormData();
  fd.append("model_id", "scribe_v1");
  fd.append("language_code", "kor");
  fd.append("file", new Blob([fs.readFileSync(path.join(HERE, it.dir, it.id + ".mp3"))], { type: "audio/mpeg" }), it.id + ".mp3");
  const j = await (await fetch("https://api.elevenlabs.io/v1/speech-to-text", { method: "POST", headers: { "xi-api-key": KEY }, body: fd })).json();
  it.stt = j.text;
  const w = (j.words || []).filter((x) => x.type === "word");
  it.seconds = w.length ? +w[w.length - 1].end.toFixed(2) : null;
  console.log(it.id, it.seconds + "s", it.stt);
}
fs.writeFileSync(path.join(HERE, "meta-r2.json"), JSON.stringify(meta, null, 2));
const m1 = JSON.parse(fs.readFileSync(path.join(HERE, "meta.json"), "utf8")).items.find((x) => x.id === "bram-v3-b");
Object.assign(items[0], { stt: m1.stt, seconds: m1.seconds });
const esc = (s) => String(s ?? "").replace(/[&<>]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;" })[c]);
const rows = items.map((it, i) => `<li${it.ref ? " class=ref" : ""}><div class=h><b>${it.ref ? "기준" : i}</b><span>${esc(it.ref ? "1차 2번 · Callum 지치고 허스키 (고른 것)" : label[it.id])}</span><small>${it.seconds ?? "?"}초</small></div>
<audio controls preload=auto src="data:audio/mpeg;base64,${fs.readFileSync(path.join(HERE, it.dir, it.id + ".mp3")).toString("base64")}"></audio>
${it.voice === "Callum" ? `<div class=rate>피치 낮춰 듣기: <button data-r=1 class=on>원래</button><button data-r=0.92>-1.4음 (0.92배)</button><button data-r=0.88>-2.2음 (0.88배)</button></div>` : ""}
<p class=stt>받아쓰기: ${esc(it.stt)}</p>${it.ref ? "" : `<p class=tx>${esc(it.text)}</p>`}</li>`).join("\n");
fs.writeFileSync(path.join(HERE, "lines-r2.html"), `<!doctype html><meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1"><title>브람 대사 2차</title>
<style>:root{--bg:#f6f1e7;--fg:#2b2620;--mut:#7a6e5f;--card:#fffaf0;--line:#e3d8c4;--acc:#7a4b2a}
@media (prefers-color-scheme:dark){:root{--bg:#1d1a16;--fg:#ece3d3;--mut:#a89a85;--card:#26221c;--line:#3a332a;--acc:#d9a571}}
body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.6 "Noto Serif KR",serif;padding:24px 16px}main{max-width:720px;margin:auto}
h1{font-size:22px;margin:0 0 4px}.q{white-space:pre-line;border-left:3px solid var(--acc);padding:6px 12px;margin:12px 0 8px;font-size:17px}.note{color:var(--mut);font-size:13px;margin:0 0 16px}
ul{list-style:none;padding:0;display:grid;gap:12px}li{background:var(--card);border:1px solid var(--line);border-radius:8px;padding:12px 14px}li.ref{border-style:dashed}
.h{display:flex;gap:10px;align-items:baseline}.h b{color:var(--acc)}.h small{margin-left:auto;color:var(--mut)}audio{width:100%;margin:8px 0 4px}
.rate{font-size:13px;color:var(--mut);display:flex;gap:6px;flex-wrap:wrap;align-items:center}.rate button{font:inherit;border:1px solid var(--line);background:var(--bg);color:var(--fg);border-radius:4px;padding:2px 8px;cursor:pointer}.rate button.on{border-color:var(--acc);color:var(--acc)}
.stt{margin:4px 0 0;font-size:14px}.tx{margin:2px 0 0;font-size:12px;color:var(--mut);font-family:ui-monospace,monospace}</style>
<main><h1>브람 — 더 중후하게 (2차)</h1><div style="color:var(--mut)">1차 2번 말투를 유지하고 무게감을 더함 · 모두 eleven_v3</div>
<div class=q>${esc(meta.line)}</div>
<p class=note>Callum 후보의 '피치 낮춰 듣기'는 재생 속도로 음높이를 함께 낮춘 미리듣기예요. 고르시면 같은 처리로 파일을 만들어 게임에 넣습니다. 다른 목소리를 고르면 브람의 감탄사 목소리도 함께 바꾸거나, 그 목소리를 쓰던 인물과 겹치게 돼요.</p>
<ul>${rows}</ul></main>
<script>document.querySelectorAll(".rate").forEach(g=>{const a=g.previousElementSibling;a.preservesPitch=false;g.addEventListener("click",e=>{const b=e.target.closest("button");if(!b)return;a.playbackRate=+b.dataset.r;g.querySelectorAll("button").forEach(x=>x.classList.toggle("on",x===b));a.currentTime=0;a.play()})})</script>`);
console.log("page", fs.statSync(path.join(HERE, "lines-r2.html")).size);
