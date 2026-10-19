// 손님 대사 한 줄을 ElevenLabs TTS로 여러 모델·설정 후보로 만든다. 키는 %USERPROFILE%\.elevenlabs\api_key 에서만 읽고 출력하지 않는다.
// 사용: node tts.mjs  → raw/<id>.mp3, meta.json
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const KEY = fs.readFileSync(path.join(os.homedir(), ".elevenlabs", "api_key"), "utf8").trim();
const VOICE = "N2lVS1w4EtoT3dr4eOWO"; // Callum — 브람 고정 목소리
const LINE = "오는 길에 내 목소리를 들었소.\n숲 안쪽에서 나를 부르더군.\n이런 일도 흔한가?";
const spoken = LINE.replace(/\n/g, " ");
const jobs = [
  { id: "bram-v3-a", model: "eleven_v3", text: "[low, uneasy] " + spoken, vs: { stability: 0.5 } },
  { id: "bram-v3-b", model: "eleven_v3", text: "[tired, husky, quietly unsettled] " + spoken, vs: { stability: 0.5 } },
  { id: "bram-v3-c", model: "eleven_v3", text: "[whispering, wary] 오는 길에 내 목소리를 들었소... 숲 안쪽에서 나를 부르더군. [pause] 이런 일도 흔한가?", vs: { stability: 0.5 } },
  { id: "bram-ml2-a", model: "eleven_multilingual_v2", text: spoken, vs: { stability: 0.45, similarity_boost: 0.8, style: 0.3 } },
  { id: "bram-ml2-b", model: "eleven_multilingual_v2", text: spoken, vs: { stability: 0.65, similarity_boost: 0.8, style: 0.1 } },
];
const meta = { line: LINE, voice: "Callum (N2lVS1w4EtoT3dr4eOWO)", items: [] };
for (const j of jobs) {
  const r = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${VOICE}?output_format=mp3_44100_128`, {
    method: "POST", headers: { "xi-api-key": KEY, "content-type": "application/json" },
    body: JSON.stringify({ text: j.text, model_id: j.model, voice_settings: j.vs }),
  });
  if (!r.ok) { console.log(j.id, "FAIL", r.status, (await r.text()).slice(0, 200)); continue; }
  fs.writeFileSync(path.join(HERE, "raw", j.id + ".mp3"), Buffer.from(await r.arrayBuffer()));
  meta.items.push({ id: j.id, model: j.model, text: j.text, voice_settings: j.vs });
  console.log(j.id, "ok", r.headers.get("character-cost") || "");
}
fs.writeFileSync(path.join(HERE, "meta.json"), JSON.stringify(meta, null, 2));
