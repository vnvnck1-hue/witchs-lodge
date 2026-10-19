// 앰비언스 후보마다 STT(scribe_v1, 소리 사건 태그)로 웃음·환호·잔 소리 같은 사건과 말소리 단어 수를 센다. → amb-events.json
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
const HERE = path.dirname(fileURLToPath(import.meta.url));
const KEY = fs.readFileSync(path.join(os.homedir(), ".elevenlabs", "api_key"), "utf8").trim();
const meta = JSON.parse(fs.readFileSync(path.join(HERE, "meta-redo.json"), "utf8")).filter((m) => m.key === (process.argv[2] || "lodge_ambience"));
const out = {};
for (const m of meta) {
  const fd = new FormData();
  fd.append("model_id", "scribe_v1");
  fd.append("tag_audio_events", "true");
  fd.append("file", new Blob([fs.readFileSync(path.join(HERE, "raw-redo", m.file))], { type: "audio/mpeg" }), m.file);
  const j = await (await fetch("https://api.elevenlabs.io/v1/speech-to-text", { method: "POST", headers: { "xi-api-key": KEY }, body: fd })).json();
  const w = j.words || [];
  const events = w.filter((x) => x.type === "audio_event").map((x) => x.text);
  out[m.pos] = { words: w.filter((x) => x.type === "word").length, laughs: events.filter((e) => /laugh|chuckl|giggl/i.test(e)).length, events };
  console.log(m.pos, JSON.stringify(out[m.pos]).slice(0, 220));
}
fs.writeFileSync(path.join(HERE, `amb-events-${process.argv[2] || "lodge_ambience"}.json`), JSON.stringify(out, null, 1));
