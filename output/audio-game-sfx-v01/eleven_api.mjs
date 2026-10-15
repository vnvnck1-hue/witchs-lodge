// ElevenLabs 공식 API로 효과음·음악을 생성해 바로 파일로 저장한다.
// API 키는 환경 변수 ELEVENLABS_API_KEY 에서만 읽는다(코드·파일에 키를 적지 않는다).
//
// 사용:
//   node eleven_api.mjs check                         키 연결·잔여 크레딧 확인
//   node eleven_api.mjs sfx <key> [후보수=4]           prompts.json 의 해당 항목 효과음 생성 → raw/<key>-0N.mp3
//   node eleven_api.mjs sfx-all [후보수=4]             아직 raw/ 에 없는 모든 효과음 생성
//   node eleven_api.mjs music <key> [초=60] [후보수=2]  prompts.json music 항목 생성 → music/<key>-0N.mp3
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const KEY = process.env.ELEVENLABS_API_KEY;
const API = "https://api.elevenlabs.io";
const P = JSON.parse(fs.readFileSync(path.join(HERE, "prompts.json"), "utf8"));

if (!KEY) {
  console.error("ELEVENLABS_API_KEY 환경 변수가 없습니다. setx 로 넣은 뒤 새 터미널에서 실행하세요.");
  process.exit(1);
}
const H = { "xi-api-key": KEY };

function jobs() {
  const out = [];
  for (const [, , items] of P.groups) for (const [k, name, t, d] of items) {
    const loop = t.startsWith("LOOP: ");
    out.push({ key: k, name, text: (loop ? t.slice(6) + " " + P.loop_style : t + " " + P.style), duration: d, loop });
  }
  return out;
}

async function credits() {
  const r = await fetch(`${API}/v1/user/subscription`, { headers: H });
  if (!r.ok) throw new Error(`구독 정보 ${r.status}: ${(await r.text()).slice(0, 200)}`);
  const j = await r.json();
  return { used: j.character_count, limit: j.character_limit, tier: j.tier };
}

async function sfx(job, n, dir) {
  fs.mkdirSync(dir, { recursive: true });
  for (let i = 1; i <= n; i++) {
    const file = path.join(dir, `${job.key}-${String(i).padStart(2, "0")}.mp3`);
    if (fs.existsSync(file)) continue;
    for (let attempt = 0; attempt < 4; attempt++) {
      const r = await fetch(`${API}/v1/sound-generation?output_format=mp3_44100_128`, {
        method: "POST",
        headers: { ...H, "Content-Type": "application/json" },
        body: JSON.stringify({ text: job.text, duration_seconds: job.duration, prompt_influence: 0.3, loop: job.loop, model_id: "eleven_text_to_sound_v2" }),
      });
      if (r.ok) { fs.writeFileSync(file, Buffer.from(await r.arrayBuffer())); console.log("saved", path.relative(HERE, file)); break; }
      const msg = (await r.text()).slice(0, 200);
      if (r.status === 429 || r.status >= 500) { await new Promise((z) => setTimeout(z, 3000 * (attempt + 1))); continue; }
      throw new Error(`${job.key} ${r.status}: ${msg}`);
    }
  }
}

async function music(key, seconds, n) {
  const m = P.music.find((x) => x[0] === key);
  if (!m) throw new Error("music 항목 없음: " + key);
  const dir = path.join(HERE, "music");
  fs.mkdirSync(dir, { recursive: true });
  for (let i = 1; i <= n; i++) {
    const file = path.join(dir, `${key}-${String(i).padStart(2, "0")}.mp3`);
    if (fs.existsSync(file)) continue;
    const r = await fetch(`${API}/v1/music?output_format=mp3_44100_128`, {
      method: "POST",
      headers: { ...H, "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: m[2], music_length_ms: seconds * 1000 }),
    });
    if (!r.ok) throw new Error(`${key} ${r.status}: ${(await r.text()).slice(0, 300)}`);
    fs.writeFileSync(file, Buffer.from(await r.arrayBuffer()));
    console.log("saved", path.relative(HERE, file));
  }
}

const [cmd, a, b, c] = process.argv.slice(2);
const before = await credits();
console.log(`플랜 ${before.tier} · 사용 ${before.used} / ${before.limit}`);
if (cmd === "sfx") await sfx(jobs().find((j) => j.key === a) ?? (() => { throw new Error("항목 없음: " + a); })(), Number(b || 4), path.join(HERE, "api-raw"));
else if (cmd === "sfx-all") { for (const j of jobs()) await sfx(j, Number(a || 4), path.join(HERE, "api-raw")); }
else if (cmd === "music") await music(a, Number(b || 60), Number(c || 2));
else if (cmd !== "check") console.log("명령: check | sfx <key> [n] | sfx-all [n] | music <key> [초] [n]");
if (cmd && cmd !== "check") { const after = await credits(); console.log(`이번 사용 크레딧: ${after.used - before.used}`); }
