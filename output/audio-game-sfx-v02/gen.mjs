// prompts.json 의 효과음을 ElevenLabs 공식 API로 후보 N개씩 생성 → raw/<key>-0N.mp3, meta.json.
// 키는 %USERPROFILE%\.elevenlabs\api_key 에서만 읽고 출력하지 않는다. 이미 있는 파일은 건너뛴다.
// 사용: node gen.mjs [후보수=4] [key...]
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const KEY = fs.readFileSync(path.join(os.homedir(), ".elevenlabs", "api_key"), "utf8").trim();
// REDO=1 이면 prompts-redo.json → raw-redo/, meta-redo.json (다시 만들기·추가 소리)
const REDO = process.env.REDO === "1";
const RAW = REDO ? "raw-redo" : "raw";
const P = JSON.parse(fs.readFileSync(path.join(HERE, REDO ? "prompts-redo.json" : "prompts.json"), "utf8"));
fs.mkdirSync(path.join(HERE, RAW), { recursive: true });
const N = +(process.argv[2] || 4), only = process.argv.slice(3);
const metaPath = path.join(HERE, REDO ? "meta-redo.json" : "meta.json");
const meta = fs.existsSync(metaPath) ? JSON.parse(fs.readFileSync(metaPath, "utf8")) : [];
let cost = 0;
for (const [, , items] of P.groups) for (const [key, , text, duration] of items) {
  const loop = text.startsWith("LOOP: "), prompt = loop ? text.slice(6) : text;
  if (only.length && !only.includes(key)) continue;
  for (let pos = 1; pos <= N; pos++) {
    const file = `${key}-0${pos}.mp3`;
    if (fs.existsSync(path.join(HERE, RAW, file))) continue;
    for (let t = 0; t < 4; t++) {
      const r = await fetch("https://api.elevenlabs.io/v1/sound-generation?output_format=mp3_44100_128", {
        method: "POST", headers: { "xi-api-key": KEY, "content-type": "application/json" },
        body: JSON.stringify({ text: prompt + " " + (loop && P.loop_style ? P.loop_style : P.style), duration_seconds: duration, prompt_influence: +(process.env.INFLUENCE || 0.3), loop, model_id: "eleven_text_to_sound_v2" }),
      });
      if (r.status === 429) { await new Promise((s) => setTimeout(s, 3000)); continue; }
      if (!r.ok) { console.log(file, "FAIL", r.status, (await r.text()).slice(0, 200)); break; }
      fs.writeFileSync(path.join(HERE, RAW, file), Buffer.from(await r.arrayBuffer()));
      cost += +(r.headers.get("character-cost") || 0);
      meta.push({ key, pos, file, duration, loop, prompt });
      fs.writeFileSync(metaPath, JSON.stringify(meta, null, 1));
      break;
    }
  }
  console.log(key, "done, credits so far", cost);
}
