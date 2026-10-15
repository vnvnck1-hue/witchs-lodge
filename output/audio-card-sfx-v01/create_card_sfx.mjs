// 마녀산장 카드 효과음 후보 합성기 v01
// 외부 의존성 없음. node create_card_sfx.mjs → wav/*.wav 와 manifest.json 생성.
// 모든 소리는 결정적 난수(시드 고정)로 합성하므로 다시 실행해도 같은 파일이 나온다.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const SR = 44100;
const HERE = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(HERE, "wav");

// ---------- 기본 도구 ----------
let seed = 1;
const rand = () => { seed = (seed * 1664525 + 1013904223) >>> 0; return seed / 4294967296; };
const reseed = (s) => { seed = s >>> 0 || 1; };
const N = (sec) => Math.max(1, Math.round(sec * SR));
const buf = (sec) => new Float32Array(N(sec));
const clamp = (x, a, b) => Math.min(b, Math.max(a, x));
const lerp = (a, b, t) => a + (b - a) * t;
const mtof = (m) => 440 * Math.pow(2, (m - 69) / 12);

function white(sec) { const b = buf(sec); for (let i = 0; i < b.length; i++) b[i] = rand() * 2 - 1; return b; }
function pink(sec) {
  const b = buf(sec); let b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
  for (let i = 0; i < b.length; i++) {
    const w = rand() * 2 - 1;
    b0 = 0.99886 * b0 + w * 0.0555179; b1 = 0.99332 * b1 + w * 0.0750759; b2 = 0.969 * b2 + w * 0.153852;
    b3 = 0.8665 * b3 + w * 0.3104856; b4 = 0.55 * b4 + w * 0.5329522; b5 = -0.7616 * b5 - w * 0.016898;
    b[i] = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362) * 0.11; b6 = w * 0.115926;
  }
  return b;
}

// RBJ 바이쿼드. f, q 는 숫자 또는 t(0..1) → 값 함수. 32샘플마다 계수 갱신.
function filt(x, type, f, q = 0.707, gainDb = 0) {
  const y = new Float32Array(x.length);
  let x1 = 0, x2 = 0, y1 = 0, y2 = 0, b0, b1, b2, a1, a2;
  const fv = typeof f === "function" ? f : () => f;
  const qv = typeof q === "function" ? q : () => q;
  for (let i = 0; i < x.length; i++) {
    if (i % 32 === 0) {
      const t = i / x.length;
      const w0 = 2 * Math.PI * clamp(fv(t), 20, SR * 0.45) / SR;
      const cs = Math.cos(w0), sn = Math.sin(w0), al = sn / (2 * qv(t));
      const A = Math.pow(10, gainDb / 40);
      let c;
      if (type === "lp") c = [(1 - cs) / 2, 1 - cs, (1 - cs) / 2, 1 + al, -2 * cs, 1 - al];
      else if (type === "hp") c = [(1 + cs) / 2, -(1 + cs), (1 + cs) / 2, 1 + al, -2 * cs, 1 - al];
      else if (type === "bp") c = [al, 0, -al, 1 + al, -2 * cs, 1 - al];
      else if (type === "peak") c = [1 + al * A, -2 * cs, 1 - al * A, 1 + al / A, -2 * cs, 1 - al / A];
      [b0, b1, b2, a1, a2] = [c[0] / c[3], c[1] / c[3], c[2] / c[3], c[4] / c[3], c[5] / c[3]];
    }
    const o = b0 * x[i] + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2;
    x2 = x1; x1 = x[i]; y2 = y1; y1 = o; y[i] = o;
  }
  return y;
}

// 엔벨로프: 선형 어택 후 지수 감쇠(decay = -60dB까지 걸리는 초)
function envAD(x, attack, decay, hold = 0) {
  for (let i = 0; i < x.length; i++) {
    const t = i / SR; let g;
    if (t < attack) g = t / attack;
    else if (t < attack + hold) g = 1;
    else g = Math.exp(-6.9 * (t - attack - hold) / decay);
    x[i] *= g;
  }
  return x;
}
// 임의 모양 엔벨로프: 점 목록 [[초, 값], ...] 사이를 부드럽게 보간
function envPts(x, pts) {
  let k = 0;
  for (let i = 0; i < x.length; i++) {
    const t = i / SR;
    while (k < pts.length - 2 && t > pts[k + 1][0]) k++;
    const [t0, v0] = pts[k], [t1, v1] = pts[Math.min(k + 1, pts.length - 1)];
    const u = t1 > t0 ? clamp((t - t0) / (t1 - t0), 0, 1) : 1;
    const s = u * u * (3 - 2 * u);
    x[i] *= t > pts[pts.length - 1][0] ? pts[pts.length - 1][1] : lerp(v0, v1, s);
  }
  return x;
}

// 사인 오실레이터. f: 숫자 또는 t(초) → Hz
function sine(sec, f, phase = 0) {
  const b = buf(sec); const fv = typeof f === "function" ? f : () => f; let p = phase;
  for (let i = 0; i < b.length; i++) { b[i] = Math.sin(p); p += 2 * Math.PI * fv(i / SR) / SR; }
  return b;
}
function saw(sec, f) {
  const b = buf(sec); const fv = typeof f === "function" ? f : () => f; let p = rand();
  for (let i = 0; i < b.length; i++) { b[i] = 2 * p - 1; p += fv(i / SR) / SR; p -= Math.floor(p); }
  return b;
}
function square(sec, f) { const s = sine(sec, f); for (let i = 0; i < s.length; i++) s[i] = Math.tanh(s[i] * 6); return s; }

// 모달 타격(나무·금속): 비정수 배음 감쇠 사인 합
function modal(sec, f0, ratios, decays, amps, bright = 1) {
  const b = buf(sec);
  ratios.forEach((r, j) => {
    const f = f0 * r, d = decays[j] ?? decays[decays.length - 1], a = (amps[j] ?? 0.3) * Math.pow(bright, j);
    const ph = rand() * 6.28;
    for (let i = 0; i < b.length; i++) b[i] += a * Math.sin(ph + 2 * Math.PI * f * i / SR) * Math.exp(-6.9 * i / SR / d);
  });
  return b;
}
const WOOD = { r: [1, 2.57, 4.21, 6.65], d: [0.09, 0.05, 0.03, 0.02], a: [1, 0.5, 0.3, 0.15] };
const GLASS = { r: [1, 2.756, 5.404, 8.933], d: [0.8, 0.45, 0.25, 0.12], a: [1, 0.45, 0.25, 0.12] };
const METAL = { r: [1, 1.594, 2.136, 2.296, 2.653, 3.156], d: [1.1, 0.8, 0.6, 0.5, 0.4, 0.3], a: [1, 0.7, 0.5, 0.45, 0.35, 0.25] };

function knock(f0, dur = 0.25, bright = 1, decayMul = 1) {
  const m = modal(dur, f0, WOOD.r, WOOD.d.map((d) => d * decayMul), WOOD.a, bright);
  const c = envAD(filt(white(0.012), "bp", f0 * 3, 1.2), 0.0005, 0.01);
  return mix(m, c, 0, 0.6);
}
function bell(f0, dur = 1.2, decayMul = 1, bright = 1) {
  const b = modal(dur, f0, GLASS.r, GLASS.d.map((d) => d * decayMul), GLASS.a, bright);
  return envAD(b, 0.002, dur * 2);
}
function glint(f0, dur = 0.35) { // 짧고 밝은 반짝임
  return mix(envAD(sine(dur, f0), 0.001, dur * 0.8), envAD(sine(dur, f0 * 2.01), 0.001, dur * 0.4), 0, 0.35);
}

// 숨결 바람(휙): 대역통과 노이즈의 중심 주파수를 움직인다
function whoosh(sec, fFrom, fTo, q = 1.2, shape = [[0, 0], [0.5, 1], [1, 0]], usePink = false) {
  const n = usePink ? pink(sec) : white(sec);
  const y = filt(n, "bp", (t) => fFrom * Math.pow(fTo / fFrom, t), q);
  return envPts(y, shape.map(([u, v]) => [u * sec, v]));
}
// 종이 마찰 질감: 고역 노이즈에 빠른 진폭 흔들림(섬유 결)
function paperGrain(sec, fc = 3500, q = 0.8, rate = 180) {
  const n = filt(white(sec), "bp", fc, q); let g = 0;
  for (let i = 0; i < n.length; i++) { if (i % Math.round(SR / rate) === 0) g = 0.35 + rand() * 0.65; n[i] *= g; }
  return n;
}
function thump(f0 = 110, dur = 0.18, drop = 0.6) { // 저역 몸통
  const s = sine(dur, (t) => f0 * (1 + drop * Math.exp(-t * 40)));
  return envAD(s, 0.002, dur);
}
function slap(dur = 0.06, fc = 1800) { // 종이가 면에 닿는 '탁'
  return envAD(filt(white(dur), "bp", fc, 0.7), 0.0008, dur);
}
function crackle(sec, density = 300, fc = 3000) {
  const b = buf(sec);
  for (let i = 0; i < b.length; i++) if (rand() < density / SR) {
    const a = (rand() * 0.8 + 0.2) * (rand() < 0.5 ? -1 : 1), len = 20 + Math.floor(rand() * 60);
    for (let k = 0; k < len && i + k < b.length; k++) b[i + k] += a * Math.exp(-k / (len / 4)) * (rand() * 2 - 1);
  }
  return filt(b, "hp", fc * 0.4, 0.7);
}
function sparkles(sec, count, fLo, fHi, spread = 1, desc = false, decay = 0.25) {
  const b = buf(sec);
  for (let k = 0; k < count; k++) {
    const u = count > 1 ? k / (count - 1) : 0;
    const t0 = (desc ? u : u) * sec * 0.6 * spread + rand() * 0.02;
    const f = desc ? lerp(fHi, fLo, u) * (0.95 + rand() * 0.1) : lerp(fLo, fHi, u) * (0.95 + rand() * 0.1);
    const g = glint(f, decay);
    for (let i = 0; i < g.length; i++) { const j = N(t0) + i; if (j < b.length) b[j] += g[i] * (0.5 + 0.5 * rand()); }
  }
  return b;
}

// 섞기: dst 의 at초 위치에 src 를 gain 만큼 더한다(필요하면 길이 확장)
function mix(dst, src, at = 0, gain = 1) {
  const off = N(at), len = Math.max(dst.length, off + src.length);
  const o = new Float32Array(len); o.set(dst);
  for (let i = 0; i < src.length; i++) o[off + i] += src[i] * gain;
  return o;
}
function gain(x, g) { for (let i = 0; i < x.length; i++) x[i] *= g; return x; }
function sat(x, drive = 1.5) { const k = Math.tanh(drive); for (let i = 0; i < x.length; i++) x[i] = Math.tanh(x[i] * drive) / k; return x; }
function reverse(x) { return Float32Array.from(x).reverse(); }

// 간단한 Schroeder 잔향(4 콤 + 2 올패스)
function reverb(x, wet = 0.25, size = 1, tail = 0.8, damp = 0.35) {
  const out = new Float32Array(x.length + N(tail));
  const xin = new Float32Array(out.length); xin.set(x);
  const combs = [1116, 1188, 1277, 1356].map((d) => Math.round(d * size));
  const fb = 0.78; const wetBus = new Float32Array(out.length);
  for (const d of combs) {
    const line = new Float32Array(d); let idx = 0, lp = 0;
    for (let i = 0; i < out.length; i++) {
      const y = line[idx]; lp = y * (1 - damp) + lp * damp;
      line[idx] = xin[i] + lp * fb; idx = (idx + 1) % d; wetBus[i] += y * 0.25;
    }
  }
  let s = wetBus;
  for (const d of [225, 556]) {
    const line = new Float32Array(d); let idx = 0; const o = new Float32Array(s.length);
    for (let i = 0; i < s.length; i++) { const bv = line[idx]; const v = s[i] + bv * 0.5; line[idx] = v; o[i] = bv - v * 0.5; idx = (idx + 1) % d; }
    s = o;
  }
  for (let i = 0; i < out.length; i++) out[i] = xin[i] * (1 - wet * 0.5) + s[i] * wet;
  return out;
}

// 마무리: DC 제거, 끝 무음 잘라냄, 짧은 페이드, 목표 피크로 정규화
function finish(x, peakDb = -3) {
  x = filt(x, "hp", 30, 0.707);
  let end = x.length; const thr = 0.0006 * Math.max(...x.map(Math.abs));
  while (end > 1 && Math.abs(x[end - 1]) < thr) end--;
  x = x.slice(0, Math.min(x.length, end + N(0.01)));
  const fi = N(0.0015), fo = Math.min(N(0.02), x.length);
  for (let i = 0; i < fi && i < x.length; i++) x[i] *= i / fi;
  for (let i = 0; i < fo; i++) x[x.length - 1 - i] *= i / fo;
  let pk = 0; for (const v of x) pk = Math.max(pk, Math.abs(v));
  const g = pk > 0 ? Math.pow(10, peakDb / 20) / pk : 1;
  for (let i = 0; i < x.length; i++) x[i] *= g;
  return x;
}

function writeWav(file, x) {
  const data = Buffer.alloc(x.length * 2);
  for (let i = 0; i < x.length; i++) data.writeInt16LE(Math.round(clamp(x[i], -1, 1) * 32767), i * 2);
  const h = Buffer.alloc(44);
  h.write("RIFF", 0); h.writeUInt32LE(36 + data.length, 4); h.write("WAVE", 8); h.write("fmt ", 12);
  h.writeUInt32LE(16, 16); h.writeUInt16LE(1, 20); h.writeUInt16LE(1, 22); h.writeUInt32LE(SR, 24);
  h.writeUInt32LE(SR * 2, 28); h.writeUInt16LE(2, 32); h.writeUInt16LE(16, 34); h.write("data", 36); h.writeUInt32LE(data.length, 40);
  fs.writeFileSync(file, Buffer.concat([h, data]));
}

// ---------- 카드 효과음 후보 ----------
// 각 후보: id, 이름, 성격 설명, 피크(dBFS), 합성 함수
const C = (m) => mtof(m);
const CATEGORIES = [
  {
    key: "draw", name: "카드 들어옴", when: "획득한 카드가 손패로 날아와 자리 잡을 때",
    items: [
      { name: "종이 슥-탁", desc: "가볍게 미끄러져 들어와 손패에 툭 놓임. 가장 무난한 기본형.", peak: -4, fn: () => {
        let x = whoosh(0.16, 900, 3800, 1.0, [[0, 0], [0.7, 1], [1, 0.3]]);
        x = mix(x, paperGrain(0.12, 4200, 0.9), 0.02, 0.35);
        x = mix(x, slap(0.05, 1600), 0.15, 0.9);
        return mix(x, thump(170, 0.07, 0.3), 0.15, 0.35);
      } },
      { name: "반짝 슬라이드", desc: "휙 소리에 세 음 상승 차임. 획득이 '보상'처럼 느껴짐.", peak: -4, fn: () => {
        let x = whoosh(0.18, 1200, 5000, 1.2, [[0, 0], [0.8, 1], [1, 0]]);
        [C(84), C(88), C(91)].forEach((f, i) => { x = mix(x, glint(f, 0.45), 0.1 + i * 0.055, 0.32); });
        x = mix(x, slap(0.04, 2200), 0.17, 0.5);
        return reverb(x, 0.3, 0.9, 0.6);
      } },
      { name: "산바람 휘익", desc: "숲 바람이 카드를 실어 오는 길고 부드러운 공기음.", peak: -5, fn: () => {
        let x = whoosh(0.34, 400, 2200, 0.9, [[0, 0], [0.55, 1], [1, 0]], true);
        x = mix(x, whoosh(0.3, 700, 3200, 2.5, [[0, 0], [0.6, 0.6], [1, 0]]), 0.03, 0.5);
        return mix(x, slap(0.035, 2600), 0.3, 0.45);
      } },
      { name: "나무 탁자 착지", desc: "짧은 휙 뒤에 산장 나무 탁자에 '톡'. 아늑한 산장 톤.", peak: -4, fn: () => {
        let x = whoosh(0.12, 1000, 3000, 1.0, [[0, 0], [0.8, 1], [1, 0]]);
        x = mix(x, knock(520, 0.22, 0.8), 0.11, 0.8);
        return mix(x, slap(0.04, 1400), 0.11, 0.5);
      } },
    ],
  },
  {
    key: "hover", name: "마우스 오버", when: "손패의 카드에 커서가 올라가 카드가 커질 때 (자주 들리므로 작고 짧게)",
    items: [
      { name: "종이 사각", desc: "아주 짧은 종이 결 소리. 거의 촉감만 남김.", peak: -14, fn: () => {
        return envPts(paperGrain(0.05, 5200, 1.1, 400), [[0, 0], [0.006, 1], [0.05, 0]]);
      } },
      { name: "말랑 톡", desc: "부드러운 거품이 터지는 듯한 '톡'. 귀엽고 둥근 느낌.", peak: -13, fn: () => {
        return envAD(sine(0.07, (t) => 620 + 520 * Math.exp(-t * 90)), 0.001, 0.06);
      } },
      { name: "작은 반짝", desc: "높은 유리 종 한 번. 마녀 마법의 기척.", peak: -10, fn: () => {
        return reverb(bell(C(96), 0.25, 0.3, 0.6), 0.2, 0.7, 0.3);
      } },
      { name: "나무 틱", desc: "작은 나무 조각 '틱'. 산장 UI 와 어울리는 건조한 클릭.", peak: -13, fn: () => {
        return knock(1500, 0.06, 0.6, 0.5);
      } },
    ],
  },
  {
    key: "pickup", name: "카드 집어 들기", when: "카드를 눌러 드래그를 시작할 때",
    items: [
      { name: "종이 들썩", desc: "카드가 손가락에 붙어 떠오르는 짧은 종이 소리.", peak: -5, fn: () => {
        let x = whoosh(0.1, 1500, 4500, 1.0, [[0, 0], [0.3, 1], [1, 0]]);
        return mix(x, paperGrain(0.06, 3800, 1.0, 300), 0, 0.5);
      } },
      { name: "톡 + 올라감", desc: "가벼운 팝과 짧은 상승음. 쥐었다는 확신이 분명함.", peak: -5, fn: () => {
        let x = envAD(sine(0.12, (t) => 380 * Math.pow(2.1, t / 0.12)), 0.003, 0.1);
        return mix(x, slap(0.025, 2500), 0, 0.5);
      } },
      { name: "마법 들어올림", desc: "공기가 감기며 카드가 떠오르는 반짝임. 마녀가 들어 올리는 느낌.", peak: -5, fn: () => {
        let x = whoosh(0.22, 800, 4000, 1.4, [[0, 0], [0.7, 1], [1, 0]]);
        [0, 1, 2].forEach((k) => { x = mix(x, envPts(sine(0.25, (t) => C(76 + k * 7) * Math.pow(1.5, t / 0.25)), [[0, 0], [0.12, 1], [0.25, 0]]), 0, 0.12); });
        return reverb(x, 0.2, 0.8, 0.35);
      } },
      { name: "카드 튕김", desc: "엄지로 카드 모서리를 튕기는 날카로운 '팅'. 빠르고 경쾌함.", peak: -6, fn: () => {
        let x = envAD(filt(white(0.04), "bp", 3200, 6), 0.0005, 0.035);
        return mix(x, envAD(filt(white(0.01), "hp", 5000), 0.0003, 0.008), 0, 0.6);
      } },
    ],
  },
  {
    key: "target", name: "대상 위에 올림", when: "카드를 끌고 사용 가능한 대상(나무·적·산장) 위에 들어설 때",
    items: [
      { name: "은은한 두 종", desc: "5도 화음의 작은 종 두 개. '여기 놓을 수 있음' 신호.", peak: -9, fn: () => {
        let x = bell(C(84), 0.5, 0.5, 0.7);
        x = mix(x, bell(C(91), 0.5, 0.5, 0.7), 0.04, 0.7);
        return reverb(x, 0.25, 0.8, 0.4);
      } },
      { name: "마법 허밍", desc: "짧게 부풀었다 사라지는 따뜻한 화음 패드.", peak: -10, fn: () => {
        let x = buf(0.3);
        [57, 64, 69, 73].forEach((m) => { x = mix(x, saw(0.3, C(m) * (1 + (rand() - 0.5) * 0.004)), 0, 0.25); });
        x = filt(x, "lp", (t) => 600 + 1800 * Math.sin(Math.PI * t), 1.2);
        return envPts(x, [[0, 0], [0.08, 1], [0.3, 0]]);
      } },
      { name: "반짝 한 점", desc: "아주 짧은 고음 한 방울. 자주 울려도 거슬리지 않음.", peak: -11, fn: () => {
        return mix(glint(C(100), 0.18), glint(C(107), 0.12), 0.02, 0.4);
      } },
      { name: "나무 노크 두 번", desc: "'똑똑'. 산장 문을 두드리듯 대상이 반응함.", peak: -9, fn: () => {
        return mix(knock(700, 0.12, 0.8), knock(760, 0.12, 0.8), 0.07, 0.8);
      } },
    ],
  },
  {
    key: "play", name: "카드 사용 확정", when: "유효한 대상에 카드를 놓아 사용될 때",
    items: [
      { name: "묵직한 내려놓기", desc: "탁! 종이와 탁자의 무게감. 깔끔하고 짧음.", peak: -3, fn: () => {
        let x = slap(0.08, 1200);
        x = mix(x, thump(95, 0.22, 0.8), 0, 0.9);
        x = mix(x, paperGrain(0.05, 3000), 0, 0.25);
        return reverb(sat(x, 1.3), 0.15, 0.6, 0.25);
      } },
      { name: "마법 발동", desc: "탁 + 위로 터지는 반짝임. 카드가 힘으로 바뀌는 순간.", peak: -3, fn: () => {
        let x = slap(0.05, 1500);
        x = mix(x, thump(130, 0.16, 0.6), 0, 0.6);
        x = mix(x, whoosh(0.25, 1500, 7000, 1.5, [[0, 0], [0.2, 1], [1, 0]]), 0.02, 0.5);
        x = mix(x, sparkles(0.45, 6, C(84), C(103), 0.6, false, 0.3), 0.03, 0.4);
        return reverb(x, 0.3, 1, 0.7);
      } },
      { name: "계약 도장", desc: "쿵 찍히는 도장과 맑은 '칭'. 용병 계약 체결 느낌.", peak: -3, fn: () => {
        let x = thump(80, 0.2, 1.2);
        x = mix(x, knock(260, 0.2, 0.6, 1.4), 0, 0.8);
        x = mix(x, slap(0.04, 900), 0, 0.6);
        x = mix(x, bell(C(88), 0.8, 0.7, 0.5), 0.07, 0.35);
        return reverb(sat(x, 1.4), 0.2, 0.8, 0.5);
      } },
      { name: "휙-펑", desc: "아래로 내리꽂는 바람 뒤 부드러운 마법 폭발.", peak: -3, fn: () => {
        let x = whoosh(0.14, 4000, 900, 1.2, [[0, 0.2], [0.8, 1], [1, 0]]);
        const pop = mix(thump(140, 0.25, 1.5), envAD(filt(white(0.25), "lp", (t) => 3000 * (1 - t) + 300, 0.8), 0.002, 0.2), 0, 0.6);
        x = mix(x, pop, 0.12, 1);
        return reverb(x, 0.25, 1.1, 0.6);
      } },
    ],
  },
  {
    key: "cancel", name: "취소 · 손패로 복귀", when: "빈 곳에 놓거나 우클릭/Esc로 취소해 카드가 손패로 돌아갈 때",
    items: [
      { name: "되감기 휙", desc: "들어올 때의 반대 방향 바람. 중립적인 '되돌림'.", peak: -6, fn: () => {
        return whoosh(0.18, 3500, 800, 1.0, [[0, 0], [0.3, 1], [1, 0]]);
      } },
      { name: "내려가는 블룹", desc: "둥근 음이 미끄러져 내려감. 실패가 아닌 '원위치'.", peak: -12, fn: () => {
        return envPts(sine(0.16, (t) => 720 * Math.pow(0.5, t / 0.16)), [[0, 0], [0.01, 1], [0.16, 0]]);
      } },
      { name: "종이 미끄러짐", desc: "손패 속으로 스르륵 밀려 들어가는 종이 소리.", peak: -7, fn: () => {
        let x = filt(paperGrain(0.24, 2600, 0.7, 160), "lp", 6000);
        x = envPts(x, [[0, 0], [0.05, 1], [0.24, 0]]);
        return mix(x, slap(0.03, 1800), 0.2, 0.4);
      } },
      { name: "흩어지는 반짝", desc: "모였던 마력이 내려가며 풀림. 마법 톤과 한 세트.", peak: -7, fn: () => {
        return reverb(sparkles(0.35, 5, C(79), C(96), 0.8, true, 0.2), 0.25, 0.8, 0.4);
      } },
    ],
  },
  {
    key: "deny", name: "사용 불가", when: "지금 쓸 수 없는 대상에 놓았거나 조건이 부족할 때",
    items: [
      { name: "둔탁한 두 번", desc: "낮은 나무 '둑둑'. 부드럽지만 분명한 거절.", peak: -5, fn: () => {
        return mix(knock(210, 0.14, 0.4), knock(190, 0.16, 0.4), 0.09, 0.9);
      } },
      { name: "낮은 부-부", desc: "게임에서 익숙한 짧은 버저 두 번. 가장 확실함.", peak: -13, fn: () => {
        const b = () => envPts(filt(square(0.08, 165), "lp", 900), [[0, 0], [0.005, 1], [0.065, 1], [0.08, 0]]);
        return mix(b(), b(), 0.11, 1);
      } },
      { name: "반음 하강", desc: "부드러운 두 음이 반음 내려감. 귀엽게 '안 돼'.", peak: -7, fn: () => {
        const n = (m) => envAD(mix(sine(0.18, C(m)), sine(0.18, C(m) * 2), 0, 0.2), 0.004, 0.16);
        return mix(n(76), n(75), 0.11, 1);
      } },
      { name: "먹먹한 덜컥", desc: "막힌 서랍이 걸리는 '덜컥'. 물리적으로 막힌 느낌.", peak: -5, fn: () => {
        let x = thump(70, 0.15, 0.5);
        x = mix(x, knock(330, 0.1, 0.3, 0.6), 0, 0.7);
        x = mix(x, crackle(0.06, 900, 2000), 0.005, 0.5);
        return sat(x, 1.6);
      } },
    ],
  },
  {
    key: "consume", name: "카드 소멸", when: "계약이 끝나거나 카드가 소비되어 사라질 때",
    items: [
      { name: "반짝이며 사라짐", desc: "작은 빛 알갱이가 내려가며 흩어짐.", peak: -6, fn: () => {
        let x = sparkles(0.6, 9, C(84), C(105), 0.9, true, 0.25);
        x = mix(x, whoosh(0.5, 6000, 2500, 1.5, [[0, 0], [0.2, 0.6], [1, 0]]), 0, 0.3);
        return reverb(x, 0.35, 1, 0.8);
      } },
      { name: "불꽃에 타오름", desc: "확 붙는 불길과 타닥거림. 계약서를 태우는 마녀.", peak: -5, fn: () => {
        let x = whoosh(0.5, 300, 1500, 0.7, [[0, 0], [0.15, 1], [1, 0]], true);
        x = mix(x, envPts(crackle(0.55, 120, 2500), [[0, 0], [0.1, 1], [0.55, 0]]), 0.03, 0.8);
        return x;
      } },
      { name: "먼지로 흩어짐", desc: "사각사각 부서지는 고운 가루. 조용하고 차분함.", peak: -8, fn: () => {
        let x = envPts(crackle(0.55, 1800, 6000), [[0, 0], [0.05, 1], [0.55, 0]]);
        return mix(x, whoosh(0.5, 5000, 9000, 1.0, [[0, 0], [0.2, 0.5], [1, 0]]), 0, 0.4);
      } },
      { name: "계약 종료 종", desc: "낮고 맑은 종 하나가 길게 울림. 한 명의 이야기가 끝남.", peak: -6, fn: () => {
        let x = bell(C(72), 1.4, 1.2, 0.6);
        x = mix(x, bell(C(79), 1.2, 1, 0.5), 0.01, 0.3);
        return reverb(x, 0.35, 1.2, 1.0);
      } },
    ],
  },
  {
    key: "stash", name: "창고 보관", when: "손패가 넘쳐 카드가 창고로 들어가거나 창고와 교환할 때",
    items: [
      { name: "나무 서랍", desc: "스르륵 밀고 '탁' 닫히는 서랍.", peak: -5, fn: () => {
        let x = envPts(filt(pink(0.22), "bp", 900, 1.5), [[0, 0], [0.05, 1], [0.2, 0.8], [0.22, 0]]);
        return mix(x, knock(300, 0.18, 0.5), 0.2, 1);
      } },
      { name: "상자 뚜껑 딸깍", desc: "뚜껑 닫힘 '툭'에 작은 걸쇠 '딸깍'.", peak: -5, fn: () => {
        let x = knock(240, 0.2, 0.5);
        return mix(x, mix(knock(2400, 0.04, 0.5, 0.4), knock(2900, 0.03, 0.5, 0.4), 0.025, 0.7), 0.1, 0.5);
      } },
      { name: "마법 가방", desc: "소용돌이치며 빨려 들어가는 휘릭 + 퐁.", peak: -5, fn: () => {
        let x = whoosh(0.25, 3000, 600, 3, [[0, 0], [0.7, 1], [1, 0]]);
        x = mix(x, envAD(sine(0.12, (t) => 300 + 600 * Math.exp(-t * 50)), 0.002, 0.1), 0.22, 0.8);
        return reverb(x, 0.2, 0.7, 0.3);
      } },
      { name: "카드 쌓기", desc: "카드 더미 위에 '탁탁탁' 정리해 올림.", peak: -6, fn: () => {
        let x = buf(0.01);
        [0, 0.06, 0.11].forEach((t, i) => { x = mix(x, slap(0.04, 1500 + i * 200), t, 1 - i * 0.15); });
        return mix(x, thump(160, 0.08, 0.2), 0.11, 0.3);
      } },
    ],
  },
  {
    key: "shuffle", name: "손패 정렬", when: "카드가 들어오거나 빠져 손패가 다시 펼쳐질 때",
    items: [
      { name: "리플 셔플", desc: "카드를 촤르륵 섞는 빠른 종이 연타.", peak: -6, fn: () => {
        let x = buf(0.45);
        for (let k = 0; k < 22; k++) x = mix(x, slap(0.018, 2400 + rand() * 1500), k * 0.017 + rand() * 0.004, 0.5 + 0.5 * Math.sin(Math.PI * k / 21));
        return mix(x, slap(0.05, 1300), 0.38, 0.8);
      } },
      { name: "부채 펼침", desc: "다섯 장이 차례로 '착착' 펼쳐짐. 짧고 정돈됨.", peak: -6, fn: () => {
        let x = buf(0.01);
        for (let k = 0; k < 5; k++) x = mix(x, slap(0.025, 1800 + k * 350), k * 0.035, 0.8);
        return x;
      } },
      { name: "스르륵 정리", desc: "두 번의 부드러운 미끄러짐. 배경에 묻히는 정돈 소리.", peak: -8, fn: () => {
        const s = () => envPts(paperGrain(0.12, 3000, 0.8, 200), [[0, 0], [0.04, 1], [0.12, 0]]);
        return mix(s(), s(), 0.09, 0.7);
      } },
      { name: "마법 정렬", desc: "작은 종 아르페지오에 종이 소리가 겹침.", peak: -7, fn: () => {
        let x = buf(0.01);
        [C(79), C(83), C(86), C(91)].forEach((f, k) => {
          x = mix(x, glint(f, 0.25), k * 0.045, 0.35);
          x = mix(x, slap(0.02, 2600), k * 0.045, 0.4);
        });
        return reverb(x, 0.25, 0.8, 0.4);
      } },
    ],
  },
  {
    key: "inspect", name: "카드 뒤집기 · 확대", when: "카드를 뒤집거나 상세 보기로 크게 펼칠 때",
    items: [
      { name: "종이 뒤집기", desc: "'훅' 하고 넘어가 '탁' 펼쳐짐.", peak: -5, fn: () => {
        let x = whoosh(0.12, 700, 2500, 0.9, [[0, 0], [0.7, 1], [1, 0.2]]);
        return mix(x, slap(0.035, 2000), 0.11, 0.8);
      } },
      { name: "확대 + 반짝", desc: "공기가 부풀며 카드가 앞으로 나오고 반짝.", peak: -6, fn: () => {
        let x = whoosh(0.2, 500, 2500, 0.8, [[0, 0], [0.85, 1], [1, 0]], true);
        return reverb(mix(x, glint(C(96), 0.3), 0.18, 0.4), 0.2, 0.8, 0.35);
      } },
      { name: "펄럭", desc: "카드가 공중에서 두 번 펄럭이며 돌아섬.", peak: -5, fn: () => {
        const f = (a) => mix(whoosh(0.07, 900, 2000, 1.0, [[0, 0], [0.6, 1], [1, 0]]), slap(0.02, 1700), 0.06, a);
        return mix(f(0.6), f(0.9), 0.08, 1);
      } },
      { name: "마법 공개", desc: "역재생 잔향이 빨려 들어와 차임이 '짠'.", peak: -5, fn: () => {
        const rv = reverse(reverb(bell(C(88), 0.4, 0.5), 0.9, 1.2, 0.5)).slice(-N(0.45));
        let x = envPts(rv, [[0, 0], [0.4, 1]]);
        x = mix(x, bell(C(88), 0.9, 0.7, 0.8), 0.43, 0.8);
        return mix(x, bell(C(95), 0.9, 0.6, 0.6), 0.43, 0.4);
      } },
    ],
  },
  {
    key: "acquire", name: "종류별 획득 강조", when: "카드 종류마다 '들어옴' 위에 얹는 짧은 시그니처",
    items: [
      { name: "도끼 용병", desc: "도끼날의 금속 '칭'과 묵직한 손. 계약된 일꾼.", peak: -4, fn: () => {
        let x = modal(0.9, 880, METAL.r, METAL.d.map((d) => d * 0.5), METAL.a);
        x = envAD(x, 0.001, 0.8);
        x = mix(x, thump(120, 0.15, 0.6), 0, 0.6);
        return reverb(mix(x, slap(0.03, 3500), 0, 0.5), 0.2, 0.9, 0.5);
      } },
      { name: "양털", desc: "폭신한 '퐁'과 부드러운 종. 몽글몽글한 수확.", peak: -5, fn: () => {
        let x = envPts(filt(pink(0.25), "lp", (t) => 1800 - 1400 * t, 0.7), [[0, 0], [0.03, 1], [0.25, 0]]);
        x = mix(x, envAD(sine(0.18, (t) => 260 + 200 * Math.exp(-t * 30)), 0.01, 0.15), 0, 0.5);
        return reverb(mix(x, bell(C(91), 0.6, 0.5, 0.5), 0.05, 0.25), 0.2, 0.8, 0.4);
      } },
      { name: "목재", desc: "통나무 두 개가 쌓이는 '통-통'.", peak: -4, fn: () => {
        let x = knock(180, 0.3, 0.7, 1.6);
        return mix(mix(x, knock(230, 0.3, 0.7, 1.6), 0.1, 0.85), thump(90, 0.12, 0.4), 0, 0.5);
      } },
      { name: "숲의 괴물", desc: "낮게 웅웅거리는 그르렁과 섬뜩한 단3도 종.", peak: -4, fn: () => {
        let x = mix(saw(0.7, (t) => 55 * (1 + 0.02 * Math.sin(t * 40))), saw(0.7, 55.6), 0, 0.8);
        x = filt(x, "lp", (t) => 220 + 500 * Math.sin(Math.PI * t), 3);
        x = envPts(sat(x, 2), [[0, 0], [0.12, 1], [0.7, 0]]);
        x = mix(x, bell(C(75), 0.9, 0.8, 0.5), 0.05, 0.25);
        return reverb(mix(x, bell(C(78), 0.9, 0.8, 0.5), 0.12, 0.2), 0.3, 1.2, 0.8);
      } },
    ],
  },
];

fs.mkdirSync(OUT, { recursive: true });
const manifest = { schema: 1, sample_rate: SR, channels: 1, bits: 16, created: "2026-10-15", categories: [] };
CATEGORIES.forEach((cat, ci) => {
  const entry = { key: cat.key, name: cat.name, when: cat.when, items: [] };
  cat.items.forEach((it, ii) => {
    reseed(1000 + ci * 37 + ii * 11);
    const x = finish(it.fn(), it.peak);
    const file = `card-${cat.key}-${String(ii + 1).padStart(2, "0")}.wav`;
    writeWav(path.join(OUT, file), x);
    entry.items.push({ id: `${cat.key}-${ii + 1}`, file, name: it.name, desc: it.desc, peak_db: it.peak, seconds: +(x.length / SR).toFixed(3) });
  });
  manifest.categories.push(entry);
});
fs.writeFileSync(path.join(HERE, "manifest.json"), JSON.stringify(manifest, null, 2));
const total = manifest.categories.reduce((s, c) => s + c.items.length, 0);
console.log(`${total} files →`, OUT);
for (const c of manifest.categories) console.log(c.key.padEnd(8), c.items.map((i) => `${i.seconds}s`).join("  "));
