// 임팩트 기준 편집 서버 (localhost 전용).
// 브라우저가 raw/*.ogg 를 디코딩해 주 임팩트 하나만 남기도록 잘라 WAV 로 되돌려 보내면 edited/ 에 저장한다.
// 실행: node edit_server.mjs → http://localhost:5179/edit 열기
import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(HERE, "edited");
fs.mkdirSync(OUT, { recursive: true });

http.createServer((req, res) => {
  const url = decodeURIComponent((req.url || "").split("?")[0]);
  if (req.method === "GET" && url === "/edit") {
    res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
    return res.end(`<title>impact edit</title><pre id=log>loading</pre><script src="/edit.js"></script>`);
  }
  if (req.method === "GET" && url === "/edit.js") {
    res.writeHead(200, { "content-type": "text/javascript; charset=utf-8" });
    return res.end(fs.readFileSync(path.join(HERE, "impact_edit.js")));
  }
  if (req.method === "GET" && url === "/meta.json") {
    res.writeHead(200, { "content-type": "application/json" });
    return res.end(fs.readFileSync(path.join(HERE, "meta.json")));
  }
  if (req.method === "GET" && /^\/raw\/[\w.-]+$/.test(url)) {
    res.writeHead(200, { "content-type": "audio/ogg" });
    return res.end(fs.readFileSync(path.join(HERE, url)));
  }
  if (req.method === "POST" && /^\/save\/[\w.-]+$/.test(url)) {
    const chunks = [];
    req.on("data", (c) => chunks.push(c));
    req.on("end", () => {
      fs.writeFileSync(path.join(OUT, url.slice(6)), Buffer.concat(chunks));
      res.writeHead(200); res.end("ok");
    });
    return;
  }
  res.writeHead(404); res.end();
}).listen(5179, "127.0.0.1", () => console.log("edit server 5179"));
