// 2026-10-17 누락 효과음 보고 페이지: 새로 만든 소리(godot/assets/audio/sfx-*-el-01.mp3)와
// 그 자리에 대신 나던 이전 소리를 나란히 둔다. 검토 페이지 틀은 audio-game-sfx-v01 것을 그대로 쓴다.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const BASE = path.resolve(HERE, "../audio-game-sfx-v01");
const AUDIO = path.resolve(HERE, "../../godot/assets/audio");
const P = JSON.parse(fs.readFileSync(path.join(HERE, "prompts.json"), "utf8"));
const R = JSON.parse(fs.readFileSync(path.join(HERE, "redo.json"), "utf8"));
const verify = fs.readFileSync(path.join(HERE, "verification.txt"), "utf8").trim();
const esc = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;");
const audio = {}, auto = {};
const add = (f) => { audio[f] = fs.readFileSync(path.join(AUDIO, f)).toString("base64"); return f; };
const groups = P.groups.map((g) => ({
  key: g.key, name: g.name,
  items: g.items.map((it) => {
    const clips = [];
    if (it.fallback) clips.push({ file: add(`sfx-${it.fallback}.wav`), label: `이전 대체 소리 (${it.fallback})` });
    clips.push({ file: add(`sfx-${it.key.replace(/_/g, "-")}-el-01.mp3`), label: R.by_user[it.key] === "다시 만들기" ? "1차 새 소리 (다시 만들기 요청)" : "새 소리" });
    auto[it.key] = clips.length;
    // 2026-10-17 사용자 검토 반영: 양 소리로 되돌린 항목은 이전 대체 소리가 게임 적용, 다시 만든 항목은 새 후보 4개를 붙인다
    if (it.key === "animal_hurt") auto[it.key] = 1;
    if (R[it.key]) {
      const addRaw = (f) => { audio[f] = fs.readFileSync(path.join(HERE, "raw-redo", f)).toString("base64"); return f; };
      const seen = {}; R[it.key].candidates.forEach((c) => { seen[c.round] = (seen[c.round] || 0) + 1; clips.push({ file: addRaw(c.file), label: `${c.round}차 후보 ${seen[c.round]}${c.round === 2 ? " (바삭함)" : ""}` }); });
      auto[it.key] = clips.length - R[it.key].candidates.length + R[it.key].pick;
    }
    return { key: it.key, name: it.name, raw: true, duration: it.duration,
      when: `${it.when} · <code>${it.where}</code> · 파일 피크 ${it.file_peak_db}dB → 게임 음량 ${it.volume_db}dB${it.key === "thorn_hit" ? ' <b style="color:var(--bad)">· 너무 작음, 다시 만들기 권장</b>' : ""}${it.key === "animal_hurt" ? ' <b style="color:var(--frost)">· 검토: 양 소리로 되돌림</b>' : ""}${R[it.key] ? ` <b style="color:var(--frost)">· 검토: 두 번 다시 만듦 → 3차 후보 ${R[it.key].pick - 4} 적용, 음량 ${R[it.key].volume_db}dB</b>` : ""}<br><span style="font-family:var(--font-mono);font-size:11.5px;opacity:.75">prompt: ${esc(it.prompt)}${R[it.key] ? [...new Set(R[it.key].candidates.map((c) => c.prompt))].map((s) => "<br>다시 만든 prompt: " + esc(s)).join("") : ""}</span>`, clips };
  }),
}));
const intro = `<h1>게임에 없던 효과음 12개, 검토 반영했습니다</h1>
    <p><b>확인 방법.</b> <code>selected.json</code>에 등록된 101개는 모두 코드에서 쓰이고 있었습니다. 그래서 반대로 게임 동작 중 <b>소리가 아예 없거나</b> 다른 소리를 <b>빌려 쓰던</b> 곳을 찾았습니다(가시 방책 전체, 상자·유물·마법서, 토끼·사슴이 양 울음을 쓰던 것, 화살이 마법탄 명중음을 쓰던 것, 생고기 먹기).</p>
    <p><b>만든 방법.</b> 로그인된 브라우저 세션으로 <code>eleven_text_to_sound_v2</code>를 불러 소리마다 1개씩 생성했습니다(MP3 44.1kHz 128kbps, 길이 0.5~2초 지정, 프롬프트 영향도 45~50%). 다듬기 없이 원본 그대로 게임에 들어가므로 이 페이지도 <b>원본 그대로</b> 재생합니다. 빌려 쓰던 자리는 <b>이전 대체 소리</b>를 앞에 두어 비교할 수 있습니다. 새 파일을 지우거나 선택에서 빼면 게임은 자동으로 이전 소리로 돌아갑니다(<code>play_or</code>).</p>
    <p><b>음량 맞춤.</b> 기존 효과음은 게임에서 피크 약 -13dB로 납니다(파일 -4dB × 음량 -9dB). 새 소리도 파일 피크를 재서 같은 수준이 되게 <code>volume_db</code>를 정했습니다(자주 나는 가시 공격만 -16dB). <b style="color:var(--bad)">가시 방책 피격</b>은 파일 자체가 피크 -28dB로 작아 최대 음량(0dB)으로도 다른 소리보다 15dB쯤 작습니다. 다시 만드는 게 좋습니다. 이 페이지는 음량 보정 없이 파일 그대로 재생합니다.</p>
    <p><b>검토 반영 (2026-10-17).</b> 그대로 유지 10개. <b>토끼·사슴 쓰러짐</b>은 고르신 대로 이전 양 소리(<code>sfx-sheep_hurt.wav</code>, -9dB)로 되돌렸습니다. <b>생고기 먹기</b>는 프롬프트를 바꿔(한 번 크게 베어 무는 만화풍 소리) 2차 후보 4개를 만들었는데, 바삭하거나 사과를 먹는 소리 같다는 의견을 받았습니다. 그래서 <b>3차</b>로 "익힌 고기를 이로 뜯는 부드럽고 촉촉한 소리, 씹는 소리, 바삭함 없음"(사과·과자 소리는 빼도록 지정)으로 후보 4개를 다시 만들었습니다. 바삭한 느낌을 수치로 보려고 고음 비율을 쟀고, 그 값이 가장 낮고 따로 끊기는 소리가 2번인 <b>3차 후보 2</b>를 게임에 넣었습니다(-13dB). 수치로 고른 것이라 들어 보고 다른 후보가 낫다면 <b>이걸로</b>로 바꿔 주세요.</p>
    <p><b>새 후보는 아직 아무도 듣지 않았습니다.</b> 파형을 눌러 들어 보고, 별로인 항목만 <b>다시 만들기</b> 또는 <b>빼기</b>, 이전 소리가 낫다면 그쪽 <b>이걸로</b>를 누른 뒤 <b>결과 복사</b>로 붙여 주세요.</p>
    <div class="legend"><span><i class="chip raw">원본 그대로</i> 게임에서 나는 그대로 재생(다듬지 않음)</span></div>
    <details class="verify"><summary>헤드리스 검증 결과</summary><pre>${esc(verify)}</pre></details>
    <nav class="nav" id="nav"></nav>`;
let tpl = fs.readFileSync(path.join(BASE, "page.template.html"), "utf8");
tpl = tpl.replace("<title>마녀산장 게임 효과음</title>", '<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n<title>마녀산장 누락 효과음</title>')
  .replace('<div class="bar-title">마녀산장 게임 효과음</div>', '<div class="bar-title">마녀산장 누락 효과음</div>')
  .replace('<input id="only" type="checkbox" checked>', '<input id="only" type="checkbox">')
  .replace(/(<section class="intro">)[\s\S]*?(<\/section>)/, `$1\n    ${intro}\n  $2`)
  .replace(".chip.loop, .chip.music { color: var(--muted); }", ".chip.loop, .chip.music { color: var(--muted); }\n.chip.raw { color: var(--good); }\n.verify { font-size: 13px; color: var(--muted); }\n.verify summary { cursor: pointer; }\n.verify pre { margin: 8px 0 0; background: var(--bg); border: 1px solid var(--line); border-radius: 10px; padding: 12px; font-family: var(--font-mono); font-size: 12px; white-space: pre-wrap; overflow-x: auto; }\n.intro code, .when code { font-family: var(--font-mono); font-size: 12.5px; }")
  .replace('music: "음악 60초" };', 'music: "음악 60초", raw: "원본 그대로" };')
  .replace('const modeOf = (item) => item.music ? "music" :', 'const modeOf = (item) => item.raw ? "raw" : item.music ? "music" :')
  .replace("if (item.music) return (clips[c.file] = { orig: buf, edited: buf, info: { mode: \"music\", before: 0, after: 0 } });",
    "if (item.music || item.raw) return (clips[c.file] = { orig: buf, edited: buf, info: { mode: item.raw ? \"raw\" : \"music\", before: 0, after: 0 } });")
  .replace("/*__EDIT__*/", () => fs.readFileSync(path.join(BASE, "edit_rules.js"), "utf8"))
  .replace("/*__DATA__*/null", () => JSON.stringify({ groups, audio, auto, store: "witchs-lodge-missing-sfx-v03", reportTitle: "마녀산장 누락 효과음 v03" }));
for (const must of ['raw: "원본 그대로"', 'item.raw ? "raw"', "item.music || item.raw", "누락 효과음</div>"]) if (!tpl.includes(must)) throw new Error("template patch failed: " + must);
fs.writeFileSync(path.join(HERE, "missing-sfx.html"), tpl);
console.log(groups.flatMap((g) => g.items).length, "items,", Object.keys(audio).length, "clips,", (tpl.length / 1048576).toFixed(2), "MB");
