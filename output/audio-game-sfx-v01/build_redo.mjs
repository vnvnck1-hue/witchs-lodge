// 다시 만든 소리 검토 페이지: 항목마다 '지금 게임 소리'(raw/)와 새 후보(raw-redo/, music/)를 나란히 둔다.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const picks = JSON.parse(fs.readFileSync(path.join(HERE, "picks.json"), "utf8"));
// 2026-10-16: 다시 만든 후보 중 수치로 고른 것을 게임에 적용함 → 그 후보를 '게임 적용'으로 표시
const redoPicks = JSON.parse(fs.readFileSync(path.join(HERE, "picks-redo.json"), "utf8"));
const redoPick = (k) => redoPicks.find((p) => p.key === k).pick;
const redo = JSON.parse(fs.readFileSync(path.join(HERE, "meta-redo.json"), "utf8"));
const P = JSON.parse(fs.readFileSync(path.join(HERE, "prompts.json"), "utf8"));
const checklist = fs.readFileSync(path.resolve(HERE, "../sound-checklist-v01/sound-checklist.html"), "utf8");
const when = {};
for (const m of checklist.matchAll(/\["(\w+)", "[^"]*", "((?:[^"\\]|\\.)*)"/g)) when[m[1]] = m[2].replace(/\\"/g, "\"");
const nameOf = {};
for (const [, , items] of P.groups) for (const [k, n, , d] of items) nameOf[k] = [n, d];
const audio = {}, auto = {};
const add = (dir, f) => { audio[f] = fs.readFileSync(path.join(HERE, dir, f)).toString("base64"); return f; };
const note = { dawn: "닭 울음소리로 다시", gust: "", move_click: "", wave_start: "" };
const sfxItems = ["move_click", "gust", "dawn", "wave_start"].map((key) => {
  const cur = picks.find((p) => p.key === key).pick;
  const clips = [{ file: add("raw", `${key}-0${cur}.ogg`), label: "이전 게임 소리" }];
  for (const m of redo.filter((m) => m.key === key).sort((a, b) => a.pos - b.pos)) clips.push({ file: add("raw-redo", m.file), label: `새 후보 ${m.pos}` });
  auto[key] = 1 + redoPick(key);
  const [name, duration] = nameOf[key];
  return { key, name: name + (note[key] ? ` (${note[key]})` : ""), when: when[key] || "", duration: redo.find((m) => m.key === key).duration || duration, clips };
});
const curCombat = picks.find((p) => p.key === "bgm_combat").file;
const bgmItems = [
  { key: "bgm_day", name: "낮 BGM (새로 · 판타지 어쿠스틱 칠)", when: "낮 준비 시간에 흐르는 음악. 지금은 field-chill 이 흐름", duration: 60, music: true,
    clips: ["bgm_day-01.mp3", "bgm_day-02.mp3"].map((f, i) => ({ file: add("music", f), label: `새 후보 ${i + 1}` })) },
  { key: "bgm_combat", name: "전투 BGM (판타지 어쿠스틱 · 긴장감)", when: when.bgm_combat || "웨이브 동안 흐르는 음악", duration: 60, music: true,
    clips: [{ file: add("music", curCombat), label: "이전 게임 소리" }, ...["bgm_combat-11.mp3", "bgm_combat-12.mp3"].map((f, i) => ({ file: add("music", f), label: `새 후보 ${i + 1}` }))] },
];
auto.bgm_combat = 1 + (redoPick("bgm_combat") - 10);
auto.bgm_day = redoPick("bgm_day");
const groups = [{ key: "redo", name: "다시 만든 효과음", items: sfxItems }, { key: "bgm", name: "BGM", items: bgmItems }];
let tpl = fs.readFileSync(path.join(HERE, "page.template.html"), "utf8");
const edit = fs.readFileSync(path.join(HERE, "edit_rules.js"), "utf8");
tpl = tpl.replace("<title>마녀산장 게임 효과음</title>", "<title>마녀산장 소리 다시 만들기</title>")
  .replace(/<h1>[\s\S]*?<\/h1>/, "<h1>다시 만든 효과음 4개와 새 BGM, 지금 소리와 비교해 골라 주세요</h1>")
  .replace(/(<section class="intro">\s*<h1>[\s\S]*?<\/h1>\s*)<p>[\s\S]*?<\/p>/, `$1<p>검토에서 다시 만들기로 고르신 효과음 4개와 BGM입니다. 항목마다 맨 앞이 <b>이전 게임 소리</b>, 그 뒤가 ElevenLabs로 새로 만든 후보입니다(새벽·낮 시작은 닭 울음소리). 새 후보 중 수치 기준(잡음·음량·타격 수, BGM은 이음매·음량 고름)으로 고른 것을 <b>게임 적용</b>으로 표시했고 이미 게임에 넣었습니다(낮 BGM은 기존 field-chill 대신). 효과음은 앞서처럼 임팩트 기준으로 다듬어 재생되고 <b>원본</b>으로 다듬기 전을 들을 수 있습니다. BGM은 하스스톤 같은 판타지 어쿠스틱 분위기로 낮(칠)과 밤 전투(긴장감) 두 가지를 만들었습니다. 처음에는 <b>게임 소리만 보기</b>로 열립니다. 다른 후보가 낫다면 체크를 끄고 <b>이걸로</b>, 모두 별로면 <b>다시 만들기</b>를 누른 뒤 <b>결과 복사</b>로 붙여 주세요.</p>`)
  .replace("/*__EDIT__*/", () => edit)
  .replace("/*__DATA__*/null", () => JSON.stringify({ groups, audio, auto, store: "witchs-lodge-sfx-redo-v03", reportTitle: "마녀산장 소리 다시 만들기 v01" }));
fs.writeFileSync(path.join(HERE, "sfx-redo.html"), tpl);
console.log(groups.flatMap((g) => g.items).map((i) => i.key + ":" + i.clips.length).join(" "), (tpl.length / 1048576).toFixed(2), "MB");
