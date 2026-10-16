// 소리를 듣지 않고 고르는 수치 기준(사용자가 "알아서 골라 달라"고 한 경우).
// 원샷(임팩트·앞뒤 정리): 원본 피크 음량(너무 작으면 감점), 주 타격 앞의 잡음 바닥(낮을수록 좋음),
//   원본 타격 수(요청에 가깝게 한 번일수록 좋음), 다듬은 뒤 남은 꼬리의 안정성.
// 반복음·BGM: 처음과 끝의 음량 차이(이음매)와 100ms 단위 음량 흔들림이 작을수록 좋음.
const SR = SFX_EDIT.SR;
const log = (t) => (document.getElementById("log").textContent = t);
const db = (x) => 20 * Math.log10(Math.max(x, 1e-6));
function rms(x, a, b) { let s = 0; a = Math.max(0, a); b = Math.min(x.length, b); for (let i = a; i < b; i++) s += x[i] * x[i]; return Math.sqrt(s / Math.max(1, b - a)); }
function mono(buf) { const x = new Float32Array(buf.length); for (let c = 0; c < buf.numberOfChannels; c++) { const d = buf.getChannelData(c); for (let i = 0; i < d.length; i++) x[i] += d[i] / buf.numberOfChannels; } return x; }
function oneShotScore(x) {
  const { e, top, hits } = SFX_EDIT.impacts(x);
  const main = hits.reduce((p, q) => (q.level > p.level ? q : p));
  let floor = 0, n = 0; for (let f = Math.max(0, main.onset - 60); f < main.onset - 3; f++) { floor += e[f]; n++; }
  const noise = n ? floor / n : -90; // 타격 앞 평균(dB)
  const s = { top: +top.toFixed(1), noise: +noise.toFixed(1), hits: hits.length };
  s.score = (top < -24 ? -3 : top < -15 ? -1 : 0) + Math.min(3, (top - noise) / 15) - 0.6 * (hits.length - 1);
  return s;
}
function loopScore(x, sr) {
  const w = Math.round(0.1 * sr), lv = [];
  for (let i = 0; i + w <= x.length; i += w) lv.push(db(rms(x, i, i + w)));
  const mean = lv.reduce((a, b) => a + b, 0) / lv.length;
  const sd = Math.sqrt(lv.reduce((a, b) => a + (b - mean) ** 2, 0) / lv.length);
  const seam = Math.abs(db(rms(x, 0, w)) - db(rms(x, x.length - w, x.length)));
  const s = { mean: +mean.toFixed(1), sd: +sd.toFixed(2), seam: +seam.toFixed(2) };
  s.score = -sd - seam * 0.7 + (mean < -40 ? -3 : 0);
  return s;
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
  // 다시 만들기 차례(REDO): meta-redo.json 의 새 후보만 놓고 고른다
  const meta = window.REDO ? (await (await fetch("/meta-redo.json")).json()).map((m) => ({ ...m, file: "../raw-redo/" + m.file })) : await (await fetch("/meta.json")).json();
  const ctx = new OfflineAudioContext(1, 1, SR);
  const keys = [...new Set(meta.map((m) => m.key))];
  const picks = [];
  for (const key of keys) {
    const cands = meta.filter((m) => m.key === key).sort((a, b) => a.pos - b.pos);
    const mode = SFX_EDIT.rule(key, cands[0].duration).mode;
    const scored = [];
    for (const m of cands) {
      const buf = await ctx.decodeAudioData(await (await fetch("/raw/" + m.file)).arrayBuffer());
      const x = mono(buf);
      const r = SFX_EDIT.edit(Float32Array.from(x), key, m.duration);
      const s = mode === "loop" ? loopScore(x, buf.sampleRate) : oneShotScore(x);
      scored.push({ pos: m.pos, ...s, y: r.y, after: r.after, seconds: +(r.y.length / SR).toFixed(3) });
    }
    const best = scored.reduce((p, q) => (q.score > p.score ? q : p));
    await fetch(`/save/${key}.wav`, { method: "POST", body: wav(best.y) });
    picks.push({ key, mode, pick: best.pos, seconds: best.seconds, impacts_after: best.after, candidates: scored.map(({ y, ...rest }) => ({ ...rest, score: +rest.score.toFixed(2) })) });
    log(`${picks.length} / ${keys.length}`);
  }
  // BGM: 같은 반복성 기준으로 2곡 중 하나(그대로 MP3 사용)
  const music = await (await fetch("/music-list")).json();
  const MUSIC = window.REDO ? { bgm_day: /^bgm_day-0\d/, bgm_combat: /^bgm_combat-1\d/ } : { bgm_evening: /^bgm_evening-0\d/, bgm_combat: /^bgm_combat-0\d/ };
  for (const key of Object.keys(MUSIC)) {
    const scored = [];
    for (const f of music.filter((f) => MUSIC[key].test(f))) {
      const buf = await new OfflineAudioContext(1, 1, 44100).decodeAudioData(await (await fetch("/music/" + f)).arrayBuffer());
      scored.push({ file: f, pos: +f.slice(-6, -4), ...loopScore(mono(buf), buf.sampleRate), seconds: +buf.duration.toFixed(1) });
    }
    const best = scored.reduce((p, q) => (q.score > p.score ? q : p));
    picks.push({ key, mode: "music", pick: best.pos, file: best.file, seconds: best.seconds, candidates: scored.map((s) => ({ ...s, score: +s.score.toFixed(2) })) });
  }
  await fetch(window.REDO ? "/save/picks-redo.json" : "/save/picks.json", { method: "POST", body: JSON.stringify(picks, null, 1) });
  log("done " + picks.length);
})();
