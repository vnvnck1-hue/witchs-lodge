// 브라우저에서 생성된 ElevenLabs 결과를 이 폴더의 raw/ 로 받기 위한 임시 수신 서버 (localhost 전용)
import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const RAW = path.join(HERE, "raw");
fs.mkdirSync(RAW, { recursive: true });
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "content-type",
  "Access-Control-Allow-Private-Network": "true",
};
http.createServer((req, res) => {
  if (req.method === "OPTIONS") { res.writeHead(204, cors); return res.end(); }
  if (req.method === "GET" && req.url === "/relay") {
    // 다른 탭에서 postMessage 로 {name, b64} 를 받으면 같은 출처 /save 로 저장한다
    res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
    return res.end(`<title>relay</title><pre id=l>ready</pre><script>
      addEventListener("message", async (e) => {
        const { name, b64 } = e.data || {}; if (!name) return;
        const bin = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
        const r = await fetch("/save/" + encodeURIComponent(name), { method: "POST", body: bin });
        document.getElementById("l").textContent += "\\n" + name + " " + r.status;
        e.source && e.source.postMessage({ saved: name, status: r.status }, "*");
      });</script>`);
  }
  const name = decodeURIComponent((req.url || "").replace(/^\/save\//, ""));
  if (req.method !== "POST" || !/^[\w.-]+$/.test(name)) { res.writeHead(400, cors); return res.end("bad"); }
  const chunks = [];
  req.on("data", (c) => chunks.push(c));
  req.on("end", () => {
    const buf = Buffer.concat(chunks);
    fs.writeFileSync(path.join(RAW, name), buf);
    console.log("saved", name, buf.length);
    res.writeHead(200, cors); res.end("ok");
  });
}).listen(5178, "127.0.0.1", () => console.log("listening 5178"));
