// 로컬 미리보기: wiki/dist 를 8766 포트로 서빙한다. (npm run serve)
"use strict";
const http = require("http"), fs = require("fs"), path = require("path");
const DIST = path.join(__dirname, "..", "dist");
const PORT = +(process.env.PORT || process.argv[2] || 8766);
const TYPES = { ".html": "text/html; charset=utf-8", ".jpg": "image/jpeg", ".png": "image/png", ".js": "text/javascript", ".css": "text/css" };
http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split("?")[0].split("#")[0]);
  if (p.endsWith("/")) p += "index.html";
  const f = path.join(DIST, p);
  fs.readFile(f, (e, d) => {
    if (e) { res.writeHead(404); res.end("404"); return; }
    res.writeHead(200, { "Content-Type": TYPES[path.extname(f)] || "application/octet-stream" });
    res.end(d);
  });
}).listen(PORT, () => console.log(`http://localhost:${PORT}`));
