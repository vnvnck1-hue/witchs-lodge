// 종족 손님 35명 목소리 v02: ElevenLabs 공식 API로 생성 → 받아쓰기(STT)로 소리 구간 확인 → 게임용 WAV로 다듬기.
// API 키는 환경 변수 ELEVENLABS_API_KEY 또는 %USERPROFILE%\.elevenlabs\api_key 파일에서만 읽는다(저장소에 적지 않는다).
//
//   node gen_voices.mjs check            키 연결·플랜·잔여 크레딧
//   node gen_voices.mjs voices           쓸 수 있는 목소리 목록 → voices.json
//   node gen_voices.mjs tts [id...]      cast.json 의 voice_id 로 4개씩 생성 → raw/<id>-0N.wav (PCM)
//   node gen_voices.mjs edit [id...]     STT 단어 시각으로 다듬기 → edited/<id>-0N.wav, meta.json 의 clips 갱신
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const API = "https://api.elevenlabs.io";
const keyFile = path.join(os.homedir(), ".elevenlabs", "api_key");
const KEY = (process.env.ELEVENLABS_API_KEY || (fs.existsSync(keyFile) ? fs.readFileSync(keyFile, "utf8") : "")).trim();
if (!KEY) { console.error("API 키가 없습니다: ELEVENLABS_API_KEY 또는 " + keyFile); process.exit(1); }
const H = { "xi-api-key": KEY };
const CAST = JSON.parse(fs.readFileSync(path.join(HERE, "cast.json"), "utf8"));
const META_PATH = path.join(HERE, "meta.json");
const meta = fs.existsSync(META_PATH) ? JSON.parse(fs.readFileSync(META_PATH, "utf8")) : { clips: {} };
const RAW = path.join(HERE, "raw"), EDITED = path.join(HERE, "edited");
const sleep = (ms) => new Promise((z) => setTimeout(z, ms));

async function call(url, init, label) {
  for (let attempt = 0; attempt < 5; attempt++) {
    const r = await fetch(API + url, init);
    if (r.ok) return r;
    const msg = (await r.text()).slice(0, 300);
    if (r.status === 429 || r.status >= 500) { await sleep(3000 * (attempt + 1)); continue; }
    throw new Error(`${label} ${r.status}: ${msg}`);
  }
  throw new Error(`${label}: 재시도 초과`);
}

async function credits() {
  // 키에 user_read 권한이 없으면 크레딧은 건너뛴다
  const r = await fetch(API + "/v1/user/subscription", { headers: H });
  if (!r.ok) return { tier: "?(user_read 권한 없음)", used: 0, limit: 0 };
  const j = await r.json();
  return { tier: j.tier, used: j.character_count, limit: j.character_limit };
}

// ── WAV ──────────────────────────────────────────────
function wav(samples, rate) {
  const b = Buffer.alloc(44 + samples.length * 2);
  b.write("RIFF", 0); b.writeUInt32LE(36 + samples.length * 2, 4); b.write("WAVE", 8); b.write("fmt ", 12);
  b.writeUInt32LE(16, 16); b.writeUInt16LE(1, 20); b.writeUInt16LE(1, 22); b.writeUInt32LE(rate, 24);
  b.writeUInt32LE(rate * 2, 28); b.writeUInt16LE(2, 32); b.writeUInt16LE(16, 34); b.write("data", 36); b.writeUInt32LE(samples.length * 2, 40);
  for (let i = 0; i < samples.length; i++) b.writeInt16LE(Math.max(-32768, Math.min(32767, Math.round(samples[i] * 32767))), 44 + i * 2);
  return b;
}
function readWav(file) {
  const b = fs.readFileSync(file);
  const rate = b.readUInt32LE(24), n = b.readUInt32LE(40) / 2, s = new Float32Array(n);
  for (let i = 0; i < n; i++) s[i] = b.readInt16LE(44 + i * 2) / 32768;
  return { rate, s };
}

// ── 생성 ─────────────────────────────────────────────
// 실제로 읽히는 문장: 종족 태그 + 인물 태그 + 감탄사
export function spoken(id, i) {
  const c = CAST.cast[id];
  return [CAST.race_tag?.[c.race], CAST.extra_tag?.[id], c.lines[i]].filter(Boolean).join(" ");
}
const FORMATS =[["pcm_44100", 44100], ["pcm_24000", 24000]];
async function tts(id) {
  const c = CAST.cast[id];
  if (!c.voice_id) throw new Error(id + ": voice_id 없음");
  fs.mkdirSync(RAW, { recursive: true });
  for (let i = 0; i < c.lines.length; i++) {
    const file = path.join(RAW, `${id}-0${i + 1}.wav`);
    if (fs.existsSync(file)) continue;
    let done = false;
    for (const [fmt, rate] of FORMATS) {
      // eleven_v3 의 stability 는 0(창의)·0.5(자연)·1(안정) 중 하나만 받는다
      const stab = c.stability <= 0.35 ? 0 : c.stability >= 0.7 ? 1 : 0.5;
      const r = await fetch(`${API}/v1/text-to-speech/${c.voice_id}?output_format=${fmt}`, {
        method: "POST", headers: { ...H, "Content-Type": "application/json" },
        body: JSON.stringify({ text: spoken(id, i), model_id: "eleven_v3", voice_settings: { stability: stab } }),
      });
      if (r.ok) {
        const pcm = Buffer.from(await r.arrayBuffer()), s = new Float32Array(pcm.length >> 1);
        for (let k = 0; k < s.length; k++) s[k] = pcm.readInt16LE(k * 2) / 32768;
        fs.writeFileSync(file, wav(s, rate));
        console.log("saved", path.relative(HERE, file), fmt);
        done = true; break;
      }
      const msg = (await r.text()).slice(0, 200);
      if (r.status === 429 || r.status >= 500) { await sleep(4000); continue; }
      if (fmt === FORMATS[FORMATS.length - 1][0]) throw new Error(`${id}-0${i + 1} ${r.status}: ${msg}`);
    }
    if (!done) throw new Error(`${id}-0${i + 1}: 생성 실패`);
  }
}

// ── 다듬기 (v01 규칙) ────────────────────────────────
const GAP = 0.1, MAX = +(process.env.VOICE_MAX || 1.6), PAD = 0.03, FADE = 0.06, PEAK = Math.pow(10, -3 / 20);
async function stt(file) {
  const fd = new FormData();
  fd.append("model_id", "scribe_v1");
  fd.append("tag_audio_events", "true");
  fd.append("timestamps_granularity", "word");
  fd.append("file", new Blob([fs.readFileSync(file)], { type: "audio/wav" }), path.basename(file));
  return (await call("/v1/speech-to-text", { method: "POST", headers: H, body: fd }, "STT")).json();
}
function energySegs(s, rate) {
  // STT가 소리를 단어로 못 잡을 때(웃음·하품 등) 쓰는 대체: 20ms 창 RMS가 최대치의 -35dB 넘는 구간
  const w = Math.round(rate * 0.02), rms = [];
  for (let i = 0; i < s.length; i += w) { let e = 0; for (let k = i; k < Math.min(i + w, s.length); k++) e += s[k] * s[k]; rms.push(Math.sqrt(e / w)); }
  const th = Math.max(...rms) * Math.pow(10, -35 / 20), segs = [];
  let start = -1;
  rms.forEach((v, j) => { if (v > th && start < 0) start = j; if (v <= th && start >= 0) { segs.push([start * 0.02, j * 0.02]); start = -1; } });
  if (start >= 0) segs.push([start * 0.02, rms.length * 0.02]);
  return segs.filter(([a, b]) => b - a > 0.06);
}
function merge(segs) {
  const out = [];
  for (const [a, b] of segs.sort((x, y) => x[0] - y[0])) {
    if (out.length && a - out[out.length - 1][1] < 0.12) out[out.length - 1][1] = Math.max(out[out.length - 1][1], b);
    else out.push([a, b]);
  }
  return out;
}
async function edit(id) {
  fs.mkdirSync(EDITED, { recursive: true });
  for (let i = 1; i <= 4; i++) {
    const key = `${id}-0${i}`, file = path.join(RAW, key + ".wav");
    if (!fs.existsSync(file)) continue;
    const { rate, s } = readWav(file), dur = s.length / rate;
    // 키에 speech_to_text 권한이 없으면 음량 구간으로만 다듬는다(실제 단어 여부 확인 불가)
    let j = { words: [], text: "" };
    if (!edit.noStt) try { j = await stt(file); } catch (e) { if (!/speech_to_text/.test(e.message)) throw e; edit.noStt = true; console.log("STT 권한 없음 → 음량 기준으로 다듬음"); }
    const words = (j.words || []).filter((w) => w.type !== "spacing");
    let segs = merge(words.map((w) => [Math.max(0, w.start - PAD), Math.min(dur, w.end + PAD)]));
    const by = segs.length ? "stt" : "energy";
    if (!segs.length) segs = merge(energySegs(s, rate));
    const parts = [];
    let len = 0, cut = false;
    segs.forEach(([a, b], k) => {
      if (k > 0) { parts.push(new Float32Array(Math.round(GAP * rate))); len += GAP; }
      let piece = s.slice(Math.round(a * rate), Math.round(b * rate));
      if (len + piece.length / rate > MAX) { piece = piece.slice(0, Math.max(0, Math.round((MAX - len) * rate))); cut = true; }
      parts.push(piece); len += piece.length / rate;
    });
    let out = new Float32Array(parts.reduce((n, p) => n + p.length, 0)), o = 0;
    for (const p of parts) { out.set(p, o); o += p.length; }
    let peak = 0; for (const v of out) peak = Math.max(peak, Math.abs(v));
    const g = peak > 0 ? PEAK / peak : 1, f = Math.round(FADE * rate), f0 = Math.round(0.005 * rate);
    for (let k = 0; k < out.length; k++) {
      let e = g;
      if (k < f0) e *= k / f0;
      if (k > out.length - f) e *= (out.length - k) / f;
      out[k] *= e;
    }
    // 게임 검증 기준(0.3초 초과)에 맞게 아주 짧은 소리 뒤에 무음을 붙여 0.35초로
    if (out.length < 0.35 * rate) { const padded = new Float32Array(Math.round(0.35 * rate)); padded.set(out); out = padded; }
    fs.writeFileSync(path.join(EDITED, key + ".wav"), wav(out, rate));
    meta.clips[key] = { text: (j.text || "").trim(), events: words.filter((w) => w.type === "audio_event").map((w) => w.text),
      segs, by, len: +(out.length / rate).toFixed(2), cut, rate };
    console.log(key, by, meta.clips[key].len + "s", JSON.stringify(meta.clips[key].text));
  }
  fs.writeFileSync(META_PATH, JSON.stringify(meta, null, 2));
}

const [cmd, ...ids] = process.argv.slice(2);
const before = await credits();
console.log(`플랜 ${before.tier} · 사용 ${before.used} / ${before.limit}`);
const targets = ids.length ? ids : Object.keys(CAST.cast);
if (cmd === "voices") {
  const all = [];
  let token = "";
  do {
    const j = await (await call(`/v2/voices?page_size=100${token ? "&next_page_token=" + token : ""}`, { headers: H }, "목소리")).json();
    for (const v of j.voices) all.push({ id: v.voice_id, name: v.name, category: v.category, labels: v.labels, description: v.description });
    token = j.has_more ? j.next_page_token : "";
  } while (token);
  fs.writeFileSync(path.join(HERE, "voices.json"), JSON.stringify(all, null, 2));
  console.log(all.length, "voices");
  for (const v of all) console.log(v.id, v.name, v.category, JSON.stringify(v.labels));
} else if (cmd === "tts") { for (const id of targets) await tts(id); }
else if (cmd === "edit") { for (const id of targets) await edit(id); }
else if (cmd !== "check") console.log("명령: check | voices | tts [id...] | edit [id...]");
if (cmd && cmd !== "check") { const after = await credits(); console.log(`이번 사용 크레딧: ${after.used - before.used}`); }
