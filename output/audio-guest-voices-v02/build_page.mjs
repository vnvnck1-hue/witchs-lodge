// 종족 손님 목소리 v02 보고 페이지: 인물마다 한 묶음, 목소리 4개를 소리마다 한 줄씩(소리별 선택·코멘트).
// 틀은 ../audio-review-kit/page.template.html (v01 손님 목소리 보고와 같은 형식).
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const KIT = path.resolve(HERE, "../audio-review-kit");
const AUDIO = path.resolve(HERE, "../../godot/assets/audio");
const CAST = JSON.parse(fs.readFileSync(path.join(HERE, "cast.json"), "utf8"));
const meta = JSON.parse(fs.readFileSync(path.join(HERE, "meta.json"), "utf8"));
const verify = fs.readFileSync(path.join(HERE, "verification.txt"), "utf8").trim();
const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;");
const RACE = { dwarf: "드워프", fairy: "요정", goblin: "고블린", beastfolk: "수인", orc: "오크" };
// 이름·역할은 게임 데이터(guest_profiles.gd)에서 읽는다
const src = fs.readFileSync(path.resolve(HERE, "../../godot/scripts/ui/guest_profiles.gd"), "utf8");
const info = {};
for (const m of src.matchAll(/\{"id": "([a-z]+)", "person": "([^"]+)", "race": "[a-z]+", "role": "([^"]+)"[^\n]*\n\s*"tag": "([^"]+)"/g)) info[m[1]] = { person: m[2], role: m[3], tag: m[4] };
const spoken = (id, i) => [CAST.race_tag?.[CAST.cast[id].race], CAST.extra_tag?.[id], CAST.cast[id].lines[i]].filter(Boolean).join(" ");

const audio = {}, auto = {};
const add = (f) => { audio[f] = fs.readFileSync(path.join(AUDIO, f)).toString("base64"); return f; };
const groups = [{ key: "before", name: "비교: 인간 손님 목소리(v01)", items: [["bram", "브람"], ["mira", "미라"]].map(([id, n]) => ({
  key: `ref_${id}`, name: `${n} 1 (기존)`, raw: true, duration: 1, when: "이미 게임에 들어가 있는 인간 손님 목소리. 크기·느낌 비교용입니다.",
  clips: [{ file: add(`voice-${id}-01.wav`), label: "기존" }] })) }];
for (const [id, c] of Object.entries(CAST.cast)) {
  const p = info[id] || { person: id, role: "", tag: "" };
  groups.push({ key: id, name: `${RACE[c.race]} · ${p.person}`, items: c.lines.map((_, i) => {
    const k = `${id}-0${i + 1}`, clip = meta.clips[k];
    auto[`voice_${id}_${i + 1}`] = 1;
    return { key: `voice_${id}_${i + 1}`, name: `${p.person} ${i + 1}`, raw: true, duration: clip.len,
      when: `${p.role} · ${esc(p.tag)} · 목소리 ${c.voice_name} (${esc(c.voice)})<br><span style="font-family:var(--font-mono);font-size:11.5px;opacity:.75">eleven_v3 text: ${esc(spoken(id, i))} · ${clip.len}s${clip.cut ? " · 1.6초에서 자름" : ""}</span>`,
      clips: [{ file: add(`voice-${k}.wav`), label: `목소리 ${i + 1}` }] };
  }) });
}
const intro = `<h1>종족 손님 35명에게 목소리를 붙였습니다</h1>
    <p><b>바뀐 점.</b> 지금까지 목소리가 있던 손님은 인간 일곱 명뿐이라, 드워프·요정·고블린·수인·오크 손님은 <b>도착 카드와 대화 대사에서 아무 소리도 나지 않았습니다</b>(대화 열기만 알림음으로 대신). 이제 42명 모두 인물마다 짧은 목소리 4개가 번갈아 납니다. 붙는 곳은 v01과 같습니다 — 도착 카드 첫인사, 대화 열기, 대답·마무리 대사.</p>
    <p><b>만든 방법.</b> v01과 같이 ElevenLabs <b>eleven_v3</b>에 인물별 고정 목소리를 정해 감정 태그와 감탄사만 읽혔습니다. 기본 목소리가 21개뿐이라(노파·아이 목소리 없음) 종족 태그(예: <code>[tiny, airy, high-pitched fairy voice]</code>, <code>[deep, booming orc voice]</code>)와 인물 태그(두르가·울마 노파, 우르소 곰, 셀렌 올빼미 등)를 앞에 붙여 구분했습니다. 몇 목소리는 두 인물이 같이 씁니다(목록은 각 줄 설명).</p>
    <p><b>v01과 다른 점.</b> 이번 API 키에 받아쓰기(STT) 권한이 없어 <b>실제 단어를 말했는지 기계로 확인하지 못했습니다.</b> 대신 음량이 있는 구간만 남겨 쉼을 0.1초로 줄였고(최대 1.6초, 피크 -3dB, 끝 60ms 페이드, 게임 음량 -10dB), 원본 길이가 모두 2.6초 이하라 태그를 소리 내 읽은 경우는 없어 보입니다. 이 플랜은 24kHz로만 받을 수 있어 v01(44.1kHz)보다 고음이 조금 덜합니다.</p>
    <p><b>아직 아무도 듣지 않았습니다.</b> 어울리지 않는 소리는 <b>다시 만들기</b>나 <b>빼기</b>를 누르고, 바라는 느낌은 소리마다 있는 <b>코멘트</b> 칸에 적어 주세요(예: "더 작고 높게", "단어처럼 들림"). <b>결과 복사</b>를 누르면 선택과 코멘트가 함께 복사됩니다.</p>
    <div class="legend"><span><i class="chip raw">원본 그대로</i> 게임에서 나는 그대로 재생</span></div>
    <details class="verify"><summary>헤드리스 검증 결과</summary><pre>${esc(verify)}</pre></details>
    <nav class="nav" id="nav"></nav>`;
let tpl = fs.readFileSync(path.join(KIT, "page.template.html"), "utf8");
tpl = tpl.replace("<title>마녀산장 게임 효과음</title>", "<title>마녀산장 종족 손님 목소리</title>")
  .replace('<div class="bar-title">마녀산장 게임 효과음</div>', '<div class="bar-title">마녀산장 종족 손님 목소리</div>')
  .replace('<input id="only" type="checkbox" checked>', '<input id="only" type="checkbox">')
  .replace(/(<section class="intro">)[\s\S]*?(<\/section>)/, `$1\n    ${intro}\n  $2`)
  .replace("/*__EDIT__*/", () => fs.readFileSync(path.join(KIT, "edit_rules.js"), "utf8"))
  .replace("/*__DATA__*/null", () => JSON.stringify({ groups, audio, auto, store: "witchs-lodge-guest-voices-v02", reportTitle: "마녀산장 종족 손님 목소리 v02" }));
for (const must of ["손님 목소리</title>", "손님 목소리</div>", "aria-label=\"${item.name} 코멘트\""]) if (!tpl.includes(must)) throw new Error("template patch failed: " + must);
fs.writeFileSync(path.join(HERE, "race-voices.html"), tpl);
console.log(groups.flatMap((g) => g.items).length, "items,", Object.keys(audio).length, "clips,", (tpl.length / 1048576).toFixed(2), "MB,", Object.keys(info).length, "profiles parsed");
