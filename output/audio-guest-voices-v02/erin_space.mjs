// 에린 카드 대사(Laura) 공간감 처리 + 선술집 소리 합성 테스트.
// 1) 원본(raw/)에서 소리가 실제로 사라질 때까지 남기고(단어 기준으로 자르면 늘인 끝소리가 잘림) 48kHz 모노로.
// 2) 공간감: 나무 선술집 실내 같은 잔향(Freeverb 계열: 콤 8 + 올패스 4, 초기 반사 15ms, 습음 고역 감쇠).
// 3) 합성 테스트: 게임의 선술집 바탕음·둘이 웃음·단체 웃음·건배(godot/assets/audio)와 섞은 짧은 장면.
// 출력: space/<id>.wav(공간감), mix/<name>.wav(합성), space.json(목록).
//   node erin_space.mjs
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ASSETS = path.resolve(HERE, "../../godot/assets/audio");
const SR = 48000;
const db = (x) => Math.pow(10, x / 20);

function readWav(file) {
  const b = fs.readFileSync(file);
  let o = 12, rate = 0, bits = 16, ch = 1, data = null;
  while (o + 8 <= b.length) {
    const id = b.toString("ascii", o, o + 4), len = b.readUInt32LE(o + 4);
    if (id === "fmt ") { ch = b.readUInt16LE(o + 10); rate = b.readUInt32LE(o + 12); bits = b.readUInt16LE(o + 22); }
    if (id === "data") { data = b.subarray(o + 8, o + 8 + len); break; }
    o += 8 + len + (len & 1);
  }
  const n = data.length / (bits / 8) / ch, s = new Float32Array(n);
  for (let i = 0; i < n; i++) { let v = 0; for (let c = 0; c < ch; c++) v += data.readInt16LE((i * ch + c) * 2) / 32768; s[i] = v / ch; }
  return rate === SR ? s : resample(s, rate);
}
function resample(s, rate) {
  const n = Math.floor(s.length * SR / rate), y = new Float32Array(n);
  for (let i = 0; i < n; i++) { const t = i * rate / SR, a = Math.floor(t), f = t - a; y[i] = (s[a] || 0) * (1 - f) + (s[a + 1] || 0) * f; }
  return y;
}
function writeWav(file, y) {
  const b = Buffer.alloc(44 + y.length * 2);
  b.write("RIFF", 0); b.writeUInt32LE(36 + y.length * 2, 4); b.write("WAVE", 8); b.write("fmt ", 12); b.writeUInt32LE(16, 16);
  b.writeUInt16LE(1, 20); b.writeUInt16LE(1, 22); b.writeUInt32LE(SR, 24); b.writeUInt32LE(SR * 2, 28); b.writeUInt16LE(2, 32); b.writeUInt16LE(16, 34);
  b.write("data", 36); b.writeUInt32LE(y.length * 2, 40);
  for (let i = 0; i < y.length; i++) b.writeInt16LE(Math.round(Math.max(-1, Math.min(1, y[i])) * 32767), 44 + i * 2);
  fs.mkdirSync(path.dirname(file), { recursive: true }); fs.writeFileSync(file, b);
}
const peak = (y) => { let p = 0; for (const v of y) p = Math.max(p, Math.abs(v)); return p; };
const norm = (y, d) => { const k = db(d) / Math.max(peak(y), 1e-9); return y.map((v) => v * k); };

// 소리 난 구간: 10ms RMS 가 최대치 -45dB 를 넘는 처음~끝(끝은 여운까지), 앞 10ms·끝 0.25s 페이드
function trimTail(s) {
  const w = Math.round(SR * 0.01), lv = [];
  for (let i = 0; i + w <= s.length; i += w) { let e = 0; for (let j = i; j < i + w; j++) e += s[j] * s[j]; lv.push(Math.sqrt(e / w)); }
  const top = Math.max(...lv), th = top * db(-45);
  let a = lv.findIndex((v) => v > th), b = lv.length - 1; while (b > a && lv[b] < th) b--;
  const y = s.slice(Math.max(0, (a - 2) * w), Math.min(s.length, (b + 3) * w));
  const fi = Math.round(SR * 0.01), fo = Math.round(SR * 0.25);
  for (let i = 0; i < y.length; i++) { let g = 1; if (i < fi) g *= i / fi; const r = y.length - 1 - i; if (r < fo) g *= Math.sin((r / fo) * Math.PI / 2) ** 2; y[i] *= g; }
  return y;
}

// 나무 선술집 잔향(Freeverb 계열, 모노). room 0~1, damp 0~1, wet 비율, 꼬리 tail 초를 덧붙인다.
function reverb(x, { room = 0.6, damp = 0.45, wet = 0.24, pre = 0.015, tail = 1.3, tone = 5200 } = {}) {
  const n = x.length + Math.round(tail * SR), y = new Float32Array(n), w = new Float32Array(n);
  const scale = SR / 44100, combs = [1116, 1188, 1277, 1356, 1422, 1491, 1557, 1617].map((d) => Math.round(d * scale));
  const aps = [556, 441, 341, 225].map((d) => Math.round(d * scale)), fb = 0.7 + room * 0.28, P = Math.round(pre * SR);
  const inp = (i) => (i - P >= 0 && i - P < x.length ? x[i - P] * 0.015 : 0);
  for (const d of combs) {
    const buf = new Float32Array(d); let k = 0, lp = 0;
    for (let i = 0; i < n; i++) { const out = buf[k]; lp = out * (1 - damp) + lp * damp; buf[k] = inp(i) + lp * fb; w[i] += out; k = (k + 1) % d; }
  }
  for (const d of aps) {
    const buf = new Float32Array(d); let k = 0;
    for (let i = 0; i < n; i++) { const b = buf[k], o = -w[i] + b; buf[k] = w[i] + b * 0.5; w[i] = o; k = (k + 1) % d; }
  }
  // 습음 고역 감쇠(나무 벽): 1차 저역통과
  const a = Math.exp(-2 * Math.PI * tone / SR); let z = 0;
  for (let i = 0; i < n; i++) { z = w[i] * (1 - a) + z * a; w[i] = z; }
  const k = (peak(x) / Math.max(peak(w), 1e-9)) * wet * 2.2;
  for (let i = 0; i < n; i++) y[i] = (i < x.length ? x[i] : 0) * (1 - wet * 0.5) + w[i] * k;
  // 꼬리 끝 0.3s 페이드
  const fo = Math.round(SR * 0.3); for (let i = 0; i < fo; i++) y[n - 1 - i] *= i / fo;
  return y;
}

const voices = [
  { id: "erin_hype2_laura-02", label: "히끅! 아껴 마셔~! (목록 유지)", keep: true },
  { id: "erin_hype2_laura-03", label: "내 비밀 주머니이~!! (목록 유지)", keep: true },
];
const tails = JSON.parse(fs.readFileSync(path.join(HERE, "erin-tail-stt-kor.json"), "utf8"));
for (const [id, t] of Object.entries(tails)) if (t.ok) voices.push({ id, label: "아껴 마셔~ 긴 여운 (" + id.replace("erin_", "").replace("_laura", "") + ")", tailNew: true });

const list = { space: [], mix: [] };
const voiced = {};
for (const v of voices) {
  const dry = norm(trimTail(readWav(path.join(HERE, "raw", v.id + ".wav"))), -3);
  const wetY = norm(reverb(dry), -3);
  writeWav(path.join(HERE, "space", v.id + "-dry.wav"), dry);
  writeWav(path.join(HERE, "space", v.id + ".wav"), wetY);
  voiced[v.id] = wetY;
  list.space.push({ ...v, dry: "space/" + v.id + "-dry.wav", wet: "space/" + v.id + ".wav", drySec: +(dry.length / SR).toFixed(2), wetSec: +(wetY.length / SR).toFixed(2) });
  console.log(v.id, (dry.length / SR).toFixed(2) + "s →", (wetY.length / SR).toFixed(2) + "s");
}

// ── 합성 테스트: 게임 음량 비율(바탕 0dB·웃음 -13·건배 -14, 목소리 -10)을 그대로 맞춰 섞고 전체 정점 -3dB
const bed = readWav(path.join(ASSETS, "sfx-lodge_ambience.wav"));
const sm = readWav(path.join(ASSETS, "sfx-lodge_laugh_small-01.wav"));
const grp = readWav(path.join(ASSETS, "sfx-lodge_laugh-02.wav"));
const toast = readWav(path.join(ASSETS, "sfx-lodge_toast-03.wav"));
function scene(name, label, parts, len) {
  const n = Math.round(len * SR), y = new Float32Array(n);
  for (const [src, at, gainDb] of parts) { const s = Math.round(at * SR), g = db(gainDb); for (let i = 0; i < src.length && s + i < n; i++) y[s + i] += src[i] * g; }
  const off = Math.floor(Math.random() * Math.max(1, bed.length - n));
  for (let i = 0; i < n; i++) y[i] += bed[(off + i) % bed.length] * db(-6);
  const F = Math.round(SR * 0.4); for (let i = 0; i < F; i++) { y[i] *= i / F; y[n - 1 - i] *= i / F; }
  writeWav(path.join(HERE, "mix", name + ".wav"), norm(y, -3));
  list.mix.push({ name, label, file: "mix/" + name + ".wav", sec: len });
  console.log("mix", name);
}
const save = voiced["erin_hype2_laura-02"], pocket = voiced["erin_hype2_laura-03"];
const longOne = voices.find((v) => v.tailNew) ? voiced[voices.find((v) => v.tailNew).id] : save;
const V = -4; // 목소리를 바탕보다 또렷하게(게임에서 목소리 -10dB, 바탕 0dB 이지만 바탕은 원래 작게 녹음돼 있음)
scene("mix-save-bed", "아껴 마셔~ + 선술집 바탕음", [[save, 0.6, V]], 3.6);
scene("mix-save-laugh", "아껴 마셔~ + 바탕음 + 둘이 웃음(받아 주는 손님)", [[save, 0.5, V], [sm, 0.5 + save.length / SR - 0.5, -10]], 4.4);
scene("mix-long-toast", "긴 여운 아껴 마셔~ + 바탕음 + 건배", [[toast, 0.2, -12], [longOne, 0.9, V]], 4.6);
scene("mix-pocket-group", "내 비밀 주머니~ + 바탕음 + 단체 웃음", [[pocket, 0.5, V], [grp, 0.5 + pocket.length / SR - 0.4, -12]], 4.6);
fs.writeFileSync(path.join(HERE, "space.json"), JSON.stringify(list, null, 1));
