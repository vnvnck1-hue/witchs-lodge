// 2차: 사용자가 고른 2번(v3 · 지치고 허스키) 말투를 유지하면서 더 중후하고 무게감 있게. → raw-r2/<id>.mp3, meta-r2.json
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const KEY = fs.readFileSync(path.join(os.homedir(), ".elevenlabs", "api_key"), "utf8").trim();
const LINE = "오는 길에 내 목소리를 들었소.\n숲 안쪽에서 나를 부르더군.\n이런 일도 흔한가?";
const spoken = LINE.replace(/\n/g, " ");
const V = { Callum: "N2lVS1w4EtoT3dr4eOWO", Brian: "nPczCjzI2devNBz1zQrb", Bill: "pqHfZKP75CvOlQylNhV4", Adam: "pNInz6obpgDQGcFmaJgB", Roger: "CwhRBWXzGAHq8TQ4Fs17" };
const heavy = "[tired, husky, deep and heavy voice, slow, grave] ";
const jobs = [
  { id: "r2-callum-a", voice: "Callum", text: heavy + spoken, stability: 0.5 },
  { id: "r2-callum-b", voice: "Callum", text: "[weary, low and gravelly, speaking slowly with weight] " + spoken, stability: 0.5 },
  { id: "r2-brian", voice: "Brian", text: heavy + spoken, stability: 0.5 },
  { id: "r2-bill", voice: "Bill", text: heavy + spoken, stability: 0.5 },
  { id: "r2-adam", voice: "Adam", text: heavy + spoken, stability: 0.5 },
  { id: "r2-roger", voice: "Roger", text: heavy + spoken, stability: 0.5 },
];
fs.mkdirSync(path.join(HERE, "raw-r2"), { recursive: true });
const meta = { line: LINE, base: "1차 2번(bram-v3-b) 말투", items: [] };
for (const j of jobs) {
  const r = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${V[j.voice]}?output_format=mp3_44100_128`, {
    method: "POST", headers: { "xi-api-key": KEY, "content-type": "application/json" },
    body: JSON.stringify({ text: j.text, model_id: "eleven_v3", voice_settings: { stability: j.stability } }),
  });
  if (!r.ok) { console.log(j.id, "FAIL", r.status, (await r.text()).slice(0, 200)); continue; }
  fs.writeFileSync(path.join(HERE, "raw-r2", j.id + ".mp3"), Buffer.from(await r.arrayBuffer()));
  meta.items.push({ id: j.id, dir: "raw-r2", model: "eleven_v3", voice: j.voice, text: j.text, voice_settings: { stability: j.stability } });
  console.log(j.id, "ok", r.headers.get("character-cost") || "");
}
fs.writeFileSync(path.join(HERE, "meta-r2.json"), JSON.stringify(meta, null, 2));
