// 빈 소리 v02(P1·P2 30종) 검토 페이지 game-sfx-v02.html: raw/*.mp3 후보 4개씩 + 편집 규칙(페이지에서 실시간 다듬기).
// 수치로 고른 후보(picks.json)를 '게임 적용'으로 표시한다(이미 게임에 들어감).
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const P = JSON.parse(fs.readFileSync(path.join(HERE, "prompts.json"), "utf8"));
const meta = JSON.parse(fs.readFileSync(path.join(HERE, "meta.json"), "utf8"));
const picks = JSON.parse(fs.readFileSync(path.join(HERE, "picks.json"), "utf8"));
const when = {
  prologue_page: "프롤로그(모션 코믹스) 다음 컷으로 넘어갈 때",
  boss_roar: "빈 굴의 주인이 나타날 때, 그리고 거미를 불러내는 울부짖음",
  boss_attack: "보스가 산장·마녀를 칠 때", boss_die: "보스를 쓰러뜨렸을 때",
  wolf_transform: "보름달 카드로 마녀가 늑대로 변할 때", wolf_claw: "늑대 Q 할퀴기가 적중할 때", wolf_pounce: "늑대 E 덮치기가 착지할 때",
  wolf_bite: "늑대 평타(물기)", wolf_revert: "새벽에 늑대가 마녀로 돌아올 때", wolf_blood_drink: "늑대의 피 카드를 마녀에게 쓸 때",
  moon_cast: "초승달·상현달·보름달 카드를 쓸 때", vine_bind: "덩굴 덫·가시 속박으로 적을 묶을 때",
  firefly_release: "반딧불이 떼 카드를 놓을 때", firefly_disperse: "밤 전투가 끝나 반딧불이가 흩어질 때", card_burn: "모닥불에 카드를 태울 때",
  fire_stoke: "모닥불에 목재를 넣거나 꺼진 불을 다시 피울 때", stew_cook: "모닥불에 생고기를 놓아 스튜를 끓일 때",
  corruption_gain: "적이 주머니에 침식 카드를 넣을 때", altar_awaken: "제단 문양이 깨어날 때(해금)와 제단을 복구할 때",
  ritual_done: "제단 의식을 마쳤을 때, 축복 카드(수의·붉은 잔·털가죽)를 쓸 때", purify: "이끼 붕대로 침식 카드를 정화했을 때",
  letter_send: "숙박 초대장을 산장에 쓸 때", timber_stack: "감시탑 공터에 목재를 적립할 때(다 모이면 더미 소리 추가)",
  bow_shot: "사냥꾼이 활을 쏠 때", cultist_spawn: "침식된 자가 나타날 때", cultist_hurt: "침식된 자가 맞을 때", cultist_die: "침식된 자가 쓰러질 때",
  brute_spawn: "공성 괴물이 나타날 때", brute_hurt: "공성 괴물이 맞을 때", brute_die: "공성 괴물이 쓰러질 때",
};
const audio = {};
const groups = P.groups.map(([gkey, gname, items]) => ({
  key: gkey, name: gname,
  items: items.map(([key, name, , duration]) => ({ key, name, when: when[key] || "", duration,
    clips: meta.filter((m) => m.key === key).sort((a, b) => a.pos - b.pos).map((m) => {
      audio[m.file] = fs.readFileSync(path.join(HERE, "raw", m.file)).toString("base64");
      return { file: m.file };
    }) })),
}));
// 2026-10-19 사용자 요청: 카드 태우기 다시(화악! 타들어감) + 산장 관리 메뉴 손님 생활 앰비언스 추가 → 맨 앞 그룹. P1의 카드 태우기는 이전 소리로 이 그룹에 둔다.
const redoMeta = JSON.parse(fs.readFileSync(path.join(HERE, "meta-redo.json"), "utf8"));
const redoPicks = JSON.parse(fs.readFileSync(path.join(HERE, "picks-redo.json"), "utf8"));
const P1 = groups.find((g) => g.key === "p1");
const oldBurn = P1.items.find((i) => i.key === "card_burn");
P1.items = P1.items.filter((i) => i.key !== "card_burn");
const oldPick = picks.find((p) => p.key === "card_burn").pick;
const rclips = (key) => redoMeta.filter((m) => m.key === key).sort((a, b) => a.pos - b.pos).map((m) => { audio["r-" + m.file] = fs.readFileSync(path.join(HERE, "raw-redo", m.file)).toString("base64"); return { file: "r-" + m.file, label: key === "lodge_ambience" ? (m.pos <= 4 ? "1차 후보 " + m.pos + " (조용한 실내)" : m.pos <= 8 ? "2차 후보 " + (m.pos - 4) + " (로비)" : m.pos <= 12 ? "3차 후보 " + (m.pos - 8) + " (큰 선술집 군중)" : "4차 후보 " + (m.pos - 12) + " (10명 남짓 소규모)") : "새 후보 " + m.pos }; });
const autoRedo = {};
for (const p of redoPicks) if (p.pick) autoRedo[p.key] = p.key === "card_burn" ? p.pick + 1 : p.pick;
autoRedo.lodge_laugh = 1;
autoRedo.gust = 1 + redoPicks.find((p) => p.key === "gust").pick;
audio["prev-sfx-gust.wav"] = fs.readFileSync(path.join(HERE, "previous", "sfx-gust.wav")).toString("base64");
autoRedo.lodge_laugh_small = 1;
autoRedo.lodge_ambience_mix = 1;
audio["preview_lodge_mix.wav"] = fs.readFileSync(path.join(HERE, "edited", "preview_lodge_mix.wav")).toString("base64");
autoRedo.lodge_toast = 2;
groups.unshift({ key: "redo", name: "다시 만들기 · 추가", items: [
  { key: "gust", name: "돌풍·눈보라 — 다시 (자연스러운 겨울 바람)", when: "낮에는 가끔, 밤 전투에는 자주·강하게 부는 돌풍에 맞춰. 밤이 시작될 때 큰 눈보라 한 번", duration: 3, clips: [{ file: "prev-sfx-gust.wav", label: "이전 게임 소리" }, ...rclips("gust")] },
  { key: "card_burn", name: "카드 태우기 — 다시 (화악! 타들어감)", when: when.card_burn, duration: 1.3, clips: [{ ...oldBurn.clips[oldPick - 1], label: "이전 게임 소리" }, ...rclips("card_burn")] },
  { key: "lodge_ambience_mix", name: "▶ 산장 관리 메뉴 — 실제로 들리는 모습 미리듣기 (30초 믹스)", when: "게임과 같은 음량·규칙으로 섞은 예시: 고른 바탕음(1차 후보 1) + 웃음·건배가 3~8초마다 무작위. 게임에서는 매번 순서가 달라짐", duration: 30, clips: [{ file: "preview_lodge_mix.wav", label: "믹스 미리듣기" }] },
  { key: "lodge_ambience", name: "산장 관리 메뉴 — 바탕음 (사용자 선택: 1차 후보 1 · 조용한 실내)", when: "산장 관리 메뉴가 열려 있는 동안 반복(1.2초에 걸쳐 들어오고 닫으면 0.6초에 빠짐). 바깥 소리는 실내처럼 먹먹해짐", duration: 22, clips: rclips("lodge_ambience") },
  { key: "lodge_laugh_small", name: "산장 관리 메뉴 — 둘이 나누는 짧은 웃음 (새로 · 무작위로 섞임)", when: "메뉴가 열린 동안 3~8초마다 둘이 웃음 45% · 단체 웃음 25% · 건배 30%. 1·3·4·6번을 번갈아 씀(2·5번은 영어 Yeah가 들려 뺌)", duration: 2, clips: rclips("lodge_laugh_small") },
  { key: "lodge_laugh", name: "산장 관리 메뉴 — 손님 웃음 (무작위로 섞임)", when: "메뉴가 열린 동안 3~8초마다 무작위(단체 웃음 25%). 4개 모두 번갈아 씀", duration: 3, clips: rclips("lodge_laugh") },
  { key: "lodge_toast", name: "산장 관리 메뉴 — 건배·잔 부딪힘 (무작위로 섞임)", when: "웃음과 같은 방식. 2~4번을 번갈아 씀(1번은 비명처럼 들려 뺌)", duration: 2.5, clips: rclips("lodge_toast") },
] });

let tpl = fs.readFileSync(path.join(HERE, "page.template.html"), "utf8");
const edit = fs.readFileSync(path.join(HERE, "edit_rules.js"), "utf8");
tpl = tpl.replace(/<title>[^<]*<\/title>/, "<title>마녀산장 빈 소리 v02</title>")
  .replace(/(<section class="intro">\s*)<h1>[\s\S]*?<\/h1>(\s*)<p>[\s\S]*?<\/p>/, `$1<h1>빈 소리 P1·P2 30종을 만들어 게임에 넣었습니다</h1>$2<p><b>맨 위 "다시 만들기 · 추가"</b>: 카드 태우기를 화악! 타오르는 느낌으로 다시 만들었고(맨 앞이 이전 소리), 산장 관리 메뉴 안의 손님 생활 소리는 바탕음(검토에서 고른 1차 후보 1 · 조용한 실내) 위에 둘이 나누는 짧은 웃음·단체 웃음·건배를 3~8초마다 무작위로 얹는 방식으로 바꿨습니다(이전 1·2차 바탕음 후보도 비교용으로 남김). 둘 다 고른 후보가 이미 게임에 들어가 있습니다. 조사에서 소리가 없거나 남의 소리를 빌려 쓰던 곳 중 P1·P2 전부(프롤로그 음악은 목록에서 뺌)를 ElevenLabs로 4개씩 만들었습니다. 이전처럼 수치 기준(잡음·음량·임팩트 수)으로 고른 후보를 <b>게임 적용</b>으로 표시했고 이미 게임에 들어가 있습니다. 소리는 임팩트 기준으로 다듬어 재생되고 <b>원본</b>으로 다듬기 전을 들을 수 있습니다. 처음에는 <b>게임 소리만 보기</b>로 열립니다. 다른 후보가 낫다면 체크를 끄고 <b>이걸로</b>, 모두 별로면 <b>다시 만들기</b>, 소리가 없는 게 낫다면 <b>소리 끄기</b>를 누른 뒤 <b>결과 복사</b>로 붙여 주세요.</p>`)
  .replace("/*__EDIT__*/", () => edit)
  .replace("/*__DATA__*/null", () => JSON.stringify({ groups, audio, auto: { ...Object.fromEntries(picks.map((p) => [p.key, p.pick])), ...autoRedo }, store: "witchs-lodge-sfx-v02-a", reportTitle: "마녀산장 빈 소리 v02 검토" }));
fs.writeFileSync(path.join(HERE, "game-sfx-v02.html"), tpl);
const bad = groups.flatMap((g) => g.items).filter((i) => !i.when || i.clips.length < (i.key === "lodge_ambience_mix" ? 1 : i.key === "lodge_toast" ? 4 : 4)).map((i) => i.key);
console.log(Object.keys(audio).length, "clips", (tpl.length / 1048576).toFixed(2), "MB", bad.length ? "missing: " + bad : "ok", tpl.includes("빈 소리 P1") ? "intro ok" : "INTRO NOT REPLACED");
