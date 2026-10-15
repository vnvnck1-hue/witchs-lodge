// 주 임팩트 하나만 남기는 편집기. edit_server.mjs 가 /edit 에서 실행한다.
// 1) 1ms 프레임 피크 엔벨로프(dB)를 구하고, 직전 15ms 대비 9dB 이상 솟는 지점을 임팩트로 본다(60ms 안은 귀에 한 번으로 들리므로 하나로 합침).
// 2) 가장 큰 임팩트를 주 임팩트로 고르고, 상황별 앞 여유(pre)와 최대 길이(len)로 자른다.
// 3) 주 임팩트 뒤에 다른 임팩트가 오면 그 직전에서 끊고, 끝부분을 부드럽게 줄인다.
// 4) 상황별 목표 피크로 맞춰 48kHz 모노 16bit WAV 로 저장한다.
const SR = 48000;
const RULES = {
  hover:   { pre: 0.004, len: 0.12, peak: -12 },
  pickup:  { pre: 0.030, len: 0.18, peak: -6 },
  target:  { pre: 0.004, len: 0.30, peak: -9 },
  draw:    { pre: 0.050, len: 0.28, peak: -4 },
  play:    { pre: 0.010, len: 0.40, peak: -3 },
  cancel:  { pre: 0.030, len: 0.22, peak: -6 },
  deny:    { pre: 0.004, len: 0.22, peak: -5 },
  consume: { pre: 0.010, len: 0.55, peak: -6 },
  stash:   { pre: 0.020, len: 0.30, peak: -5 },
  shuffle: { pre: 0.010, len: 0.28, peak: -6 },
  inspect: { pre: 0.030, len: 0.30, peak: -5 },
};
const FRAME = SR / 1000; // 1ms
const db = (x) => 20 * Math.log10(Math.max(x, 1e-6));

function envelope(x) {
  const n = Math.floor(x.length / FRAME), e = new Float32Array(n);
  for (let f = 0; f < n; f++) { let m = 0; for (let i = f * FRAME; i < (f + 1) * FRAME; i++) { const a = Math.abs(x[i]); if (a > m) m = a; } e[f] = db(m); }
  return e;
}
function impacts(x) {
  const e = envelope(x); let top = -120; for (const v of e) top = Math.max(top, v);
  const hits = [];
  for (let f = 15; f < e.length; f++) {
    let lo = 0; for (let k = f - 15; k < f; k++) lo = Math.min(lo, e[k]);
    let mn = Infinity; for (let k = f - 15; k < f; k++) mn = Math.min(mn, e[k]);
    if (e[f] - mn >= 9 && e[f] > top - 18) {
      const last = hits[hits.length - 1];
      if (last && f - last.end <= 60) { last.end = f; continue; }
      hits.push({ onset: f, end: f });
    }
  }
  // 각 임팩트의 피크(온셋 뒤 20ms 안 최대)
  for (const h of hits) { h.peak = h.onset; for (let k = h.onset; k < Math.min(e.length, h.onset + 20); k++) if (e[k] > e[h.peak]) h.peak = k; h.level = e[h.peak]; }
  // 첫 소리가 무음에서 바로 시작하면 위 규칙에 안 걸릴 수 있어 0~15ms 구간도 확인
  if (!hits.length) { let p = 0; for (let k = 0; k < e.length; k++) if (e[k] > e[p]) p = k; hits.push({ onset: Math.max(0, p - 5), end: p, peak: p, level: e[p] }); }
  return { e, top, hits };
}

function edit(x, rule) {
  const { e, top, hits } = impacts(x);
  const main = hits.reduce((a, b) => (b.level > a.level ? b : a));
  const start = Math.max(0, main.onset * FRAME - Math.round(rule.pre * SR));
  let end = Math.min(x.length, start + Math.round(rule.len * SR));
  const next = hits.find((h) => h.onset > main.end && h.onset * FRAME < end);
  // 최소 길이(최대 길이의 45%, 최소 90ms)는 지킨다. 그 안에 오는 뒤 임팩트는 페이드로 눌린다
  const minEnd = main.peak * FRAME + Math.round(Math.max(0.09, rule.len * 0.45) * SR);
  if (next) end = Math.min(end, Math.max(minEnd, next.onset * FRAME - Math.round(0.004 * SR)));
  // 주 임팩트 뒤로 -45dB 아래가 20ms 이어지면 거기서 끝
  for (let f = Math.max(main.peak + 10, Math.floor(minEnd / FRAME) - 20); f < Math.floor(end / FRAME) - 20; f++) {
    let quiet = true; for (let k = f; k < f + 20; k++) if (e[k] > main.level - 45) { quiet = false; break; }
    if (quiet) { end = f * FRAME + 20 * FRAME; break; }
  }
  const y = x.slice(start, end);
  const pk = main.peak * FRAME - start;
  const fadeIn = Math.max(Math.round(0.002 * SR), Math.min(pk, Math.round(rule.pre * SR)));
  const fadeFrom = pk + Math.round((y.length - pk) * 0.3);
  for (let i = 0; i < y.length; i++) {
    let g = 1;
    if (i < fadeIn) g *= Math.sin((i / fadeIn) * Math.PI / 2) ** 2;
    if (i > fadeFrom) { const u = (i - fadeFrom) / (y.length - fadeFrom); g *= Math.cos(u * Math.PI / 2) ** 2; }
    y[i] *= g;
  }
  let m = 0; for (const v of y) m = Math.max(m, Math.abs(v));
  const gain = Math.pow(10, rule.peak / 20) / (m || 1);
  for (let i = 0; i < y.length; i++) y[i] *= gain;
  return { y, info: { orig_seconds: +(x.length / SR).toFixed(3), orig_impacts: hits.length, main_ms: main.peak, start_ms: Math.round(start / FRAME), end_ms: Math.round(end / FRAME), cut_before_next: !!next } };
}

function wav(y) {
  const b = new ArrayBuffer(44 + y.length * 2), v = new DataView(b);
  const s = (o, t) => { for (let i = 0; i < t.length; i++) v.setUint8(o + i, t.charCodeAt(i)); };
  s(0, "RIFF"); v.setUint32(4, 36 + y.length * 2, true); s(8, "WAVE"); s(12, "fmt "); v.setUint32(16, 16, true);
  v.setUint16(20, 1, true); v.setUint16(22, 1, true); v.setUint32(24, SR, true); v.setUint32(28, SR * 2, true);
  v.setUint16(32, 2, true); v.setUint16(34, 16, true); s(36, "data"); v.setUint32(40, y.length * 2, true);
  for (let i = 0; i < y.length; i++) v.setInt16(44 + i * 2, Math.max(-1, Math.min(1, y[i])) * 32767, true);
  return b;
}

(async () => {
  const log = document.getElementById("log");
  const meta = await (await fetch("/meta.json")).json();
  const ctx = new OfflineAudioContext(2, 1, SR);
  const report = [];
  for (const m of meta) {
    const buf = await ctx.decodeAudioData(await (await fetch("/raw/" + m.file)).arrayBuffer());
    const x = new Float32Array(buf.length);
    for (let c = 0; c < buf.numberOfChannels; c++) { const d = buf.getChannelData(c); for (let i = 0; i < d.length; i++) x[i] += d[i] / buf.numberOfChannels; }
    const { y, info } = edit(x, RULES[m.key]);
    const after = impacts(y);
    const name = m.file.replace(/\.ogg$/, ".wav");
    await fetch("/save/" + name, { method: "POST", body: wav(y) });
    report.push({ file: name, key: m.key, pos: m.pos, ...info, seconds: +(y.length / SR).toFixed(3), impacts: after.hits.length });
    log.textContent = report.length + " / " + meta.length;
  }
  await fetch("/save/edit-report.json", { method: "POST", body: JSON.stringify(report, null, 1) });
  log.textContent = "done " + report.length;
  window.__report = report;
})();
