// 손님 인물 목소리 보고 페이지: 인물마다 한 묶음, 목소리 4개를 소리마다 한 줄씩(소리별 선택·코멘트).
// 틀은 ../audio-review-kit/page.template.html (소리별 코멘트 칸 포함 기본 보고 형식).
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const KIT = path.resolve(HERE, "../audio-review-kit");
const AUDIO = path.resolve(HERE, "../../godot/assets/audio");
const meta = JSON.parse(fs.readFileSync(path.join(HERE, "meta.json"), "utf8"));
const verify = fs.readFileSync(path.join(HERE, "verification.txt"), "utf8").trim();
const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;");
const PEOPLE = [
  ["bram", "브람", "전투용병 · 경계 어린 첫인사", "Callum — 허스키한 중년 남성"],
  ["olaf", "올라프", "사냥꾼 · 무뚝뚝한 안도", "Adam — 단호하고 굵은 남성"],
  ["torbin", "토르빈", "나무꾼 · 말수 적은 경계", "Brian — 깊고 낮은 남성"],
  ["mira", "미라", "채집가 · 따뜻한 잠자리를 찾아", "Jessica — 밝고 따뜻한 젊은 여성"],
  ["neri", "네리", "숲길 전령 · 겁을 감춘 호기심", "Laura — 엉뚱하고 활발한 젊은 여성"],
  ["oswin", "오스윈", "유적 기록가 · 조용한 탐구심", "George — 차분한 영국식 노신사"],
  ["sera", "세라", "떠돌이 교역상 · 실속 있는 친절", "Matilda — 경쾌하고 똑 부러진 여성"],
];
const audio = {}, auto = {};
const add = (f) => { audio[f] = fs.readFileSync(path.join(AUDIO, f)).toString("base64"); return f; };
const groups = [{ key: "before", name: "비교: 이전 대화 알림음", items: [{ key: "talk_open", name: "이전 대화 알림음 (talk_open)", raw: true, duration: 1,
  when: "지금까지 대화가 열릴 때 나던 소리. 이제는 목소리가 없는 인물일 때만 대신 납니다(대화를 닫을 때는 그대로).", clips: [{ file: add("sfx-talk_open.wav"), label: "이전 소리" }] }] }];
auto.talk_open = 1;
for (const [id, person, role, voice] of PEOPLE) {
  const cast = meta.cast[id];
  groups.push({ key: id, name: `${person}`, items: cast.lines.map((line, i) => {
    const k = `${id}-0${i + 1}`, c = meta.clips[k];
    auto[`voice_${id}_${i + 1}`] = 1;
    return { key: `voice_${id}_${i + 1}`, name: `${person} ${i + 1} · “${esc(c.kept)}”`, raw: true, duration: c.len,
      when: `${role} · ${voice}<br><span style="font-family:var(--font-mono);font-size:11.5px;opacity:.75">eleven_v3 text: ${esc(line)} · 받아쓰기(STT): ${esc(c.text)}${c.cut ? " · 1.6초에서 자름" : ""}</span>`,
      clips: [{ file: add(`voice-${k}.wav`), label: `목소리 ${i + 1}` }] };
  }) });
}
const intro = `<h1>손님 일곱 명에게 목소리를 붙였습니다</h1>
    <p><b>바뀐 점.</b> 대화가 열릴 때 나던 알림음(<code>talk_open</code>) 대신, 심즈처럼 그 인물의 짧은 목소리(“흐음”, “아하!”, “오호?”)가 납니다. 대화가 열릴 때뿐 아니라 <b>인물 대사가 바뀔 때마다</b>(대답·마무리), 그리고 <b>손님 도착 카드</b>에 첫인사가 뜰 때도 납니다. 인물마다 4개가 번갈아 나와 같은 소리만 반복되지 않습니다. 버튼을 누를 때 나는 짧은 클릭음은 그대로 둡니다.</p>
    <p><b>만든 방법.</b> 인물마다 목소리가 한결같도록 효과음 대신 ElevenLabs <b>음성 모델(eleven_v3)</b>에 인물별 고정 목소리를 정해 감정 태그와 감탄사만 읽혔습니다(예: <code>[suspicious] Hmm.</code>). 받아쓰기(STT)로 실제 단어를 말하지 않는지 확인했고, 소리 난 부분만 남겨 쉼을 0.1초로 줄였습니다(최대 1.6초, 피크 -3dB, 게임 음량 -10dB). 오스윈 4번의 “yes”는 단어라 잘라 냈습니다. 이 페이지는 게임에서 나는 그대로 재생합니다.</p>
    <p><b>아직 아무도 듣지 않았습니다.</b> 인물과 어울리지 않는 소리는 <b>다시 만들기</b>나 <b>빼기</b>를 누르고, 바라는 느낌은 소리마다 있는 <b>코멘트</b> 칸에 적어 주세요(예: “더 늙고 쉰 목소리”, “너무 밝음”). <b>결과 복사</b>를 누르면 선택과 코멘트가 함께 복사됩니다.</p>
    <div class="legend"><span><i class="chip raw">원본 그대로</i> 게임에서 나는 그대로 재생</span></div>
    <details class="verify"><summary>헤드리스 검증 결과</summary><pre>${esc(verify)}</pre></details>
    <nav class="nav" id="nav"></nav>`;
let tpl = fs.readFileSync(path.join(KIT, "page.template.html"), "utf8");
tpl = tpl.replace("<title>마녀산장 게임 효과음</title>", "<title>마녀산장 손님 목소리</title>")
  .replace('<div class="bar-title">마녀산장 게임 효과음</div>', '<div class="bar-title">마녀산장 손님 목소리</div>')
  .replace('<input id="only" type="checkbox" checked>', '<input id="only" type="checkbox">')
  .replace(/(<section class="intro">)[\s\S]*?(<\/section>)/, `$1\n    ${intro}\n  $2`)
  .replace("/*__EDIT__*/", () => fs.readFileSync(path.join(KIT, "edit_rules.js"), "utf8"))
  .replace("/*__DATA__*/null", () => JSON.stringify({ groups, audio, auto, store: "witchs-lodge-guest-voices-v01", reportTitle: "마녀산장 손님 목소리 v01" }));
for (const must of ["손님 목소리</title>", "손님 목소리</div>", "aria-label=\"${item.name} 코멘트\""]) if (!tpl.includes(must)) throw new Error("template patch failed: " + must);
fs.writeFileSync(path.join(HERE, "guest-voices.html"), tpl);
console.log(groups.flatMap((g) => g.items).length, "items,", Object.keys(audio).length, "clips,", (tpl.length / 1048576).toFixed(2), "MB");
