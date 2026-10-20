// 술 주정뱅이 에린 목소리 검토 페이지 erin-voice.html: 지금 게임 목소리(Lily)와 2차 후보(가녀리고 여림, 취해 톤 살짝 올라감) 3종.
// 목소리마다 한 칸, 칸마다 감탄사 4개. 이미 다듬은 WAV라 '원본 그대로'(raw, 한 번만 재생)로 들려준다.
// 틀은 ../audio-game-sfx-v02 의 검토 페이지(page.template.html + edit_rules.js).
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
const HERE = path.dirname(fileURLToPath(import.meta.url));
const KIT = path.resolve(HERE, "../audio-game-sfx-v02");
const cast = JSON.parse(fs.readFileSync(path.join(HERE, "cast.json"), "utf8"));
const m = JSON.parse(fs.readFileSync(path.join(HERE, "meta.json"), "utf8"));
const LINE = ["킥킥+딸꾹", "\"헤이~ 음~\"", "딸꾹+\"오~\"", "한숨+웃음"];
const audio = {}, auto = {};
const voices = [
  { id: "erin", title: "지금 게임 목소리 — Lily (1차, 벨벳 같은 여성)", applied: true },
  { id: "erin_jessica", title: "2차 후보 A — Jessica (밝고 따뜻한 젊은 여성)" },
  { id: "erin_sarah", title: "2차 후보 B — Sarah (젊은 여성)" },
  { id: "erin_laura", title: "2차 후보 C — Laura (젊고 경쾌한 여성)" },
];
const items = voices.map((v) => {
  const key = "voice_full_" + v.id;
  if (v.applied) auto[key] = 1;
  const clips = [1, 2, 3, 4].map((n) => {
    const f = `${v.id}-0${n}.wav`;
    audio[f] = fs.readFileSync(path.join(HERE, "edited", f)).toString("base64");
    const stt = (m.clips?.[`${v.id}-0${n}`] || {}).stt;
    return { file: f, label: `${n}. ${LINE[n - 1]}${stt ? " · " + stt : ""}` };
  });
  return { key, name: v.title, when: `읽힌 태그: ${cast.extra_tag[v.id]}`, duration: 1.6, clips };
});
let tpl = fs.readFileSync(path.join(KIT, "page.template.html"), "utf8");
tpl = tpl.replace(/<title>[^<]*<\/title>/, "<title>에린 목소리 검토</title>")
  .replace(/(<section class="intro">\s*)<h1>[\s\S]*?<\/h1>(\s*)<p>[\s\S]*?<\/p>/, `$1<h1>술 주정뱅이 에린 — 목소리 고르기</h1>$2<p>"더 가녀리고 여린, 취해서 톤이 조금 올라간" 느낌으로 기본 목소리 3종(Jessica · Sarah · Laura)에 같은 감탄사 4개를 읽혔습니다. 맨 위가 지금 게임에 들어간 Lily입니다. 칸마다 4개가 그 목소리 한 벌이며, 소리는 누를 때 <b>한 번만</b> 재생됩니다. 마음에 드는 목소리 칸에서 아무 후보나 <b>이걸로</b>를 누르면 그 목소리 4개 한 벌로 바꿉니다(특정 감탄사만 빼려면 그 번호를 말로 적어 주세요). 모두 별로면 <b>다시 만들기</b>를 누르고 <b>결과 복사</b>로 붙여 주세요.</p>`)
  .replace("/*__EDIT__*/", () => fs.readFileSync(path.join(KIT, "edit_rules.js"), "utf8"))
  .replace("/*__DATA__*/null", () => JSON.stringify({ groups: [{ key: "erin", name: "술 주정뱅이 에린", items }], audio, auto, store: "witchs-lodge-erin-voice-v02", reportTitle: "에린 목소리 고르기" }));
fs.writeFileSync(path.join(HERE, "erin-voice.html"), tpl);
console.log(items.length, "voices", Object.keys(audio).length, "clips", (tpl.length / 1024).toFixed(0), "KB");
