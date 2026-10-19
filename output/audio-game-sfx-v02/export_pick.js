// 지정한 후보 하나를 다듬어 edited/<key>.wav 로 저장한다(사용자가 직접 고른 경우).
// pick_server 의 /export?k=<key>&f=<raw-redo 파일> 로 연다.
(async () => {
  const q = new URLSearchParams(location.search);
  const key = q.get("k"), file = q.get("f"), dur = +(q.get("d") || 1), out = q.get("o") || key; // o: 저장 이름(한 이벤트에 여러 파일)
  const ctx = new OfflineAudioContext(1, 1, SFX_EDIT.SR);
  const buf = await ctx.decodeAudioData(await (await fetch("/raw-redo/" + file)).arrayBuffer());
  const x = new Float32Array(buf.length);
  for (let c = 0; c < buf.numberOfChannels; c++) { const d = buf.getChannelData(c); for (let i = 0; i < d.length; i++) x[i] += d[i] / buf.numberOfChannels; }
  const r = SFX_EDIT.edit(x, key, dur);
  const y = r.y, SR = SFX_EDIT.SR;
  const b = new ArrayBuffer(44 + y.length * 2), v = new DataView(b);
  const s = (o, t) => { for (let i = 0; i < t.length; i++) v.setUint8(o + i, t.charCodeAt(i)); };
  s(0, "RIFF"); v.setUint32(4, 36 + y.length * 2, true); s(8, "WAVE"); s(12, "fmt "); v.setUint32(16, 16, true);
  v.setUint16(20, 1, true); v.setUint16(22, 1, true); v.setUint32(24, SR, true); v.setUint32(28, SR * 2, true);
  v.setUint16(32, 2, true); v.setUint16(34, 16, true); s(36, "data"); v.setUint32(40, y.length * 2, true);
  for (let i = 0; i < y.length; i++) v.setInt16(44 + i * 2, Math.max(-1, Math.min(1, y[i])) * 32767, true);
  await fetch(`/save/${out}.wav`, { method: "POST", body: b });
  document.getElementById("log").textContent = `done ${key} ${file} ${(y.length / SR).toFixed(3)}s hits=${r.after}`;
})();
