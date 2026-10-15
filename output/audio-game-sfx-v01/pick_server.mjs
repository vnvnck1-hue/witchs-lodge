// 수치 기준 자동 선택 + 게임용 WAV 출력 서버 (localhost 전용).
// 실행: node pick_server.mjs → 브라우저로 http://localhost:5179/pick 열기
// 브라우저가 raw/*.ogg 를 디코딩해 edit_rules.js 로 다듬고, 후보마다 점수를 매겨 고른 뒤
// 고른 소리만 edited/<key>.wav (48kHz 모노 16bit) 로, 점수표는 picks.json 으로 되돌려 보낸다.
import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(HERE, "edited");
fs.mkdirSync(OUT, { recursive: true });
const types = { ".ogg": "audio/ogg", ".mp3": "audio/mpeg", ".js": "text/javascript; charset=utf-8", ".json": "application/json" };

http.createServer((req, res) => {
  const url = decodeURIComponent((req.url || "").split("?")[0]);
  if (req.method === "GET" && url === "/pick") {
    res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
    return res.end(`<title>pick</title><pre id=log>loading</pre><script src="/edit_rules.js"></script><script src="/pick.js"></script>`);
  }
  if (req.method === "GET" && /^\/(edit_rules\.js|pick\.js|meta\.json|prompts\.json|raw\/[\w.-]+|music\/[\w.-]+)$/.test(url)) {
    res.writeHead(200, { "content-type": types[path.extname(url)] || "application/octet-stream" });
    return res.end(fs.readFileSync(path.join(HERE, url)));
  }
  if (req.method === "GET" && url === "/music-list") {
    res.writeHead(200, { "content-type": "application/json" });
    return res.end(JSON.stringify(fs.readdirSync(path.join(HERE, "music")).filter((f) => f.endsWith(".mp3"))));
  }
  if (req.method === "POST" && /^\/save\/[\w.-]+$/.test(url)) {
    const chunks = [];
    req.on("data", (c) => chunks.push(c));
    req.on("end", () => { fs.writeFileSync(path.join(url === "/save/picks.json" ? HERE : OUT, url.slice(6)), Buffer.concat(chunks)); res.writeHead(200); res.end("ok"); });
    return;
  }
  res.writeHead(404); res.end();
}).listen(5179, "127.0.0.1", () => console.log("pick server 5179"));
