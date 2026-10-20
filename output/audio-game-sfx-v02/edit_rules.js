// 게임 효과음 편집 규칙. 시청 페이지(실시간 미리듣기)와 WAV 출력에 같은 코드를 쓴다.
// 모드: impact = 가장 큰 임팩트 하나만 남김, trim = 앞뒤 무음만 정리(팡파르·연출음), loop = 손대지 않음(반복음)
const SFX_EDIT = (() => {
  const SR = 48000, FRAME = 48;
  const LOOP = ["lantern_loop", "insect_buzz", "hazard_amb", "campfire", "dragon_wings", "lodge_ambience", "lodge_ambience_mix"];
  // 원본 그대로(검토 페이지에서 한 번만 재생, 정점만 맞춤): 이미 다듬은 목소리·자르지 않고 들을 원본
  const RAW = ["gust_full", "voice_full"];
  const TRIM = ["dawn", "night_warn", "wave_start", "wave_clear", "victory", "defeat", "gust", "room_build", "dragon_leave", "lodge_fall", "hazard_enter", "mon_big", "witch_heal", "witch_down", "merc_die", "tree_fall", "grave_rise", "boss_roar", "boss_die", "wolf_transform", "wolf_revert", "wolf_blood_drink", "moon_cast", "altar_awaken", "ritual_done", "brute_die", "brute_spawn", "cultist_spawn", "cultist_die", "stew_cook", "firefly_release", "firefly_disperse", "corruption_gain", "purify", "fire_stoke", "card_burn", "lodge_laugh", "lodge_toast", "lodge_laugh_small"];
  const UI = ["btn_click", "btn_hover", "btn_denied", "qty_tick", "move_click", "card_hover", "stack_gain", "talk_next", "panel_open", "panel_close", "toast_good", "toast_bad", "pause", "talk_open", "witch_step", "shear_loop"];
  // 휙 소리처럼 임팩트 앞의 상승부가 소리의 일부인 것: 앞 여유를 넉넉히
  const SWELL = ["bolt_cast", "dragon_fire", "mon_spawn", "merc_spawn", "minion_spawn", "guest_enter", "guest_card", "panel_open", "talk_open", "lantern_place", "frost_burst", "mon_attack", "ally_attack", "insect_aggro", "pause", "wolf_claw", "wolf_pounce", "letter_send", "vine_bind", "boss_attack", "prologue_page"];
  const db = (x) => 20 * Math.log10(Math.max(x, 1e-6));
  // 잘린 소리를 다시 잴 때 첫 15ms 비교 구간이 없으면 임팩트를 잘못 센다 → 앞에 20ms 무음을 붙여 잰다
  const PAD_F = 20;
  const pad = (y) => { const z = new Float32Array(y.length + PAD_F * FRAME); z.set(y, PAD_F * FRAME); return z; };
  const count = (y) => impacts(pad(y)).hits.length;

  function rule(key, duration) {
    if (LOOP.includes(key)) return { mode: "loop", peak: -10 };
    if (RAW.includes(key) || key.startsWith("voice_full")) return { mode: "raw", peak: -4 };
    if (TRIM.includes(key)) return { mode: "trim", peak: -4, len: Math.min(duration, 3.0) };
    const ui = UI.includes(key);
    return { mode: "impact", pre: SWELL.includes(key) ? 0.07 : 0.008, len: ui ? Math.min(0.25, duration) : Math.min(0.6, Math.max(0.3, duration * 0.6)), peak: ui ? -10 : -4 };
  }
  function env(x) {
    const n = Math.floor(x.length / FRAME), e = new Float32Array(n);
    for (let f = 0; f < n; f++) { let m = 0; for (let i = f * FRAME; i < (f + 1) * FRAME; i++) { const a = Math.abs(x[i]); if (a > m) m = a; } e[f] = db(m); }
    return e;
  }
  function impacts(x) {
    const e = env(x); let top = -120; for (const v of e) top = Math.max(top, v);
    const hits = [];
    for (let f = 15; f < e.length; f++) {
      let mn = Infinity; for (let k = f - 15; k < f; k++) mn = Math.min(mn, e[k]);
      if (e[f] - mn >= 9 && e[f] > top - 18) {
        const last = hits[hits.length - 1];
        if (last && f - last.end <= 60) { last.end = f; continue; }
        hits.push({ onset: f, end: f });
      }
    }
    for (const h of hits) { h.peak = h.onset; for (let k = h.onset; k < Math.min(e.length, h.onset + 20); k++) if (e[k] > e[h.peak]) h.peak = k; h.level = e[h.peak]; }
    if (!hits.length) { let p = 0; for (let k = 0; k < e.length; k++) if (e[k] > e[p]) p = k; hits.push({ onset: Math.max(0, p - 5), end: p, peak: p, level: e[p] }); }
    return { e, top, hits };
  }
  function normalize(y, peakDb) {
    let m = 0; for (const v of y) m = Math.max(m, Math.abs(v));
    const g = Math.pow(10, peakDb / 20) / (m || 1); for (let i = 0; i < y.length; i++) y[i] *= g; return y;
  }
  function fadeEdges(y, fin, fout) {
    for (let i = 0; i < fin && i < y.length; i++) y[i] *= Math.sin((i / fin) * Math.PI / 2) ** 2;
    for (let i = 0; i < fout && i < y.length; i++) y[y.length - 1 - i] *= Math.sin((i / fout) * Math.PI / 2) ** 2;
    return y;
  }
  function edit(x, key, duration) {
    const r = rule(key, duration);
    const before = count(x);
    if (r.mode === "raw") return { y: normalize(Float32Array.from(x), r.peak), mode: r.mode, before, after: count(x) };
    if (r.mode === "loop") return { y: normalize(Float32Array.from(x), r.peak), mode: r.mode, before, after: before };
    if (r.mode === "trim") {
      const { e, top } = impacts(x);
      let a = 0; while (a < e.length && e[a] < top - 45) a++;
      let b = e.length - 1; while (b > a && e[b] < top - 50) b--;
      const s = Math.max(0, (a - 3) * FRAME), t = Math.min(x.length, Math.min((b + 10) * FRAME, s + Math.round(r.len * SR)));
      const y = fadeEdges(x.slice(s, t), Math.round(0.003 * SR), Math.round(Math.min(0.25, (t - s) / SR * 0.3) * SR));
      return { y: normalize(y, r.peak), mode: r.mode, before, after: count(y) };
    }
    const { e, hits } = impacts(x);
    const main = hits.reduce((p, q) => (q.level > p.level ? q : p));
    // 앞 여유 안에 이전 임팩트가 있으면 그 꼬리 뒤에서 시작한다(임팩트 하나 우선)
    const prev = hits.filter((h) => h.end < main.onset).pop();
    let start = Math.max(0, main.onset * FRAME - Math.round(r.pre * SR));
    if (prev && prev.end * FRAME + Math.round(0.03 * SR) > start) start = Math.min(main.onset * FRAME - Math.round(0.004 * SR), prev.end * FRAME + Math.round(0.03 * SR));
    start = Math.max(0, start);
    let end = Math.min(x.length, start + Math.round(r.len * SR));
    const floor = Math.min(x.length, Math.max(start + Math.round(0.08 * SR), main.peak * FRAME + Math.round(0.04 * SR)));
    const minEnd = Math.min(end, Math.max(floor, main.peak * FRAME + Math.round(Math.max(0.06, r.len * 0.45) * SR)));
    // 뒤 임팩트가 오면 최소 길이보다 '임팩트 하나'를 우선해 그 직전에서 끊는다(바닥 0.08초)
    const next = hits.find((h) => h.onset > main.end && h.onset * FRAME < end);
    if (next) end = Math.max(floor, next.onset * FRAME - Math.round(0.004 * SR));
    end = Math.max(end, floor);
    for (let f = Math.max(main.peak + 10, Math.floor(minEnd / FRAME) - 20); f < Math.floor(end / FRAME) - 20; f++) {
      let quiet = true; for (let k = f; k < f + 20; k++) if (e[k] > main.level - 45) { quiet = false; break; }
      if (quiet) { end = (f + 20) * FRAME; break; }
    }
    end = Math.max(end, floor);
    // 임팩트가 원본 맨 끝에 붙어 있으면 뒤로 늘릴 수 없으니 0.08초 창을 앞쪽으로 잡는다
    if (end - start < Math.round(0.08 * SR)) start = Math.max(0, end - Math.round(0.08 * SR));
    let y = x.slice(start, end);
    const pk = Math.max(0, main.peak * FRAME - start);
    const fin = Math.max(Math.round(0.002 * SR), Math.min(pk, Math.round(r.pre * SR)));
    const shape = (arr, fromAt) => {
      for (let i = 0; i < arr.length; i++) {
        let g = 1;
        if (i < fin) g *= Math.sin((i / fin) * Math.PI / 2) ** 2;
        if (i > fromAt) g *= Math.cos(((i - fromAt) / (arr.length - fromAt)) * Math.PI / 2) ** 2;
        arr[i] *= g;
      }
      return arr;
    };
    const src = Float32Array.from(y);
    y = shape(y, pk + Math.round((y.length - pk) * 0.3));
    // 꼬리를 줄인 뒤에야 두 번째 타격이 도드라지는 경우가 있어, 모양을 잡은 뒤 다시 재서 그 직전에서 끊는다(0.08초 바닥)
    const again = impacts(pad(y)).hits.map((h) => ({ onset: h.onset - PAD_F }));
    const second = again.find((h) => h.onset * FRAME > pk + Math.round(0.02 * SR));
    const cut = second ? second.onset * FRAME - Math.round(0.004 * SR) : 0;
    if (again.length > 1 && second && cut > pk + Math.round(0.04 * SR) && cut >= Math.round(0.08 * SR)) {
      const z = src.slice(0, cut);
      y = shape(z, pk + Math.round((z.length - pk) * 0.3));
    }
    return { y: normalize(y, r.peak), mode: r.mode, before, after: count(y) };
  }
  return { SR, rule, edit, impacts };
})();
if (typeof module !== "undefined") module.exports = SFX_EDIT;
