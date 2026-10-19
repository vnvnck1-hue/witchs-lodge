// 후보마다 STT(scribe_v1)로 받아써 발음을 확인하고, 길이와 함께 듣기 페이지 lines.html 을 만든다.
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const KEY = fs.readFileSync(path.join(os.homedir(), ".elevenlabs", "api_key"), "utf8").trim();
const meta = JSON.parse(fs.readFileSync(path.join(HERE, "meta.json"), "utf8"));
const label = { "bram-v3-a": "v3 · 낮고 불안하게", "bram-v3-b": "v3 · 지치고 허스키하게", "bram-v3-c": "v3 · 속삭이듯 경계하며(쉼 포함)", "bram-ml2-a": "Multilingual v2 · 표현 조금", "bram-ml2-b": "Multilingual v2 · 차분·안정" };
for (const it of meta.items) {
  if (it.stt) continue;
  const buf = fs.readFileSync(path.join(HERE, "raw", it.id + ".mp3"));
  const fd = new FormData();
  fd.append("model_id", "scribe_v1");
  fd.append("language_code", "kor");
  fd.append("file", new Blob([buf], { type: "audio/mpeg" }), it.id + ".mp3");
  const r = await fetch("https://api.elevenlabs.io/v1/speech-to-text", { method: "POST", headers: { "xi-api-key": KEY }, body: fd });
  const j = await r.json();
  it.stt = j.text;
  const w = (j.words || []).filter((x) => x.type === "word");
  it.seconds = w.length ? +w[w.length - 1].end.toFixed(2) : null;
  console.log(it.id, it.seconds + "s", it.stt);
}
fs.writeFileSync(path.join(HERE, "meta.json"), JSON.stringify(meta, null, 2));
const esc = (s) => String(s).replace(/[&<>]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;" })[c]);
const rows = meta.items.map((it, i) => `<li><div class=h><b>${i + 1}</b><span>${esc(label[it.id] || it.id)}</span><small>${it.seconds ?? "?"}초</small></div>
<audio controls preload=auto src="data:audio/mpeg;base64,${fs.readFileSync(path.join(HERE, "raw", it.id + ".mp3")).toString("base64")}"></audio>
<p class=stt>받아쓰기: ${esc(it.stt || "")}</p><p class=tx>${esc(it.text)}</p></li>`).join("\n");
fs.writeFileSync(path.join(HERE, "lines.html"), `<!doctype html><meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1"><title>브람 대사 후보</title>
<style>:root{--bg:#f6f1e7;--fg:#2b2620;--mut:#7a6e5f;--card:#fffaf0;--line:#e3d8c4;--acc:#7a4b2a}
@media (prefers-color-scheme:dark){:root{--bg:#1d1a16;--fg:#ece3d3;--mut:#a89a85;--card:#26221c;--line:#3a332a;--acc:#d9a571}}
body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.6 "Noto Serif KR",serif;padding:24px 16px}main{max-width:720px;margin:auto}
h1{font-size:22px;margin:0 0 4px}.q{white-space:pre-line;border-left:3px solid var(--acc);padding:6px 12px;margin:12px 0 20px;font-size:17px}
ul{list-style:none;padding:0;display:grid;gap:12px}li{background:var(--card);border:1px solid var(--line);border-radius:8px;padding:12px 14px}
.h{display:flex;gap:10px;align-items:baseline}.h b{color:var(--acc)}.h small{margin-left:auto;color:var(--mut)}audio{width:100%;margin:8px 0 4px}
.stt{margin:0;font-size:14px}.tx{margin:2px 0 0;font-size:12px;color:var(--mut);font-family:ui-monospace,monospace}</style>
<main><h1>브람 — 첫 대화 대사 후보</h1><div style="color:var(--mut)">목소리: Callum(브람 고정) · 숲길의 목소리</div>
<div class=q>${esc(meta.line)}</div><ul>${rows}</ul></main>`);
console.log("page", fs.statSync(path.join(HERE, "lines.html")).size);
