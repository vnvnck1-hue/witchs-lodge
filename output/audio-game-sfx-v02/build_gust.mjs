// 돌풍·눈보라 후보 고르기 페이지 gust-review.html: 이전 게임 소리 + 1차 1번 + 3차(5~8) + 4차(9~12, 9번 게임 적용).
// 4초 원본을 자르지 않고 들려주려고 페이지 다듬기 키를 반복음(gust_full = 손대지 않음)으로 둔다.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
const HERE = path.dirname(fileURLToPath(import.meta.url));
const audio = {};
const add = (dir, f, label) => { audio[f] = fs.readFileSync(path.join(HERE, dir, f)).toString("base64"); return { file: f, label }; };
const clips = [
  add("previous", "sfx-gust.wav", "이전 게임 소리 (처음 것)"),
  add("raw-redo", "gust-01.mp3", "1차 후보 1 (전에 고르신 것)"),
  ...[5, 6, 7, 8].map((n) => add("raw-redo", `gust-0${n}.mp3`, `3차 후보 ${n - 4} (잔잔한 눈보라)`)),
  ...[9, 10, 11, 12].map((n) => add("raw-redo", `gust-0${n}.mp3`, `4차 후보 ${n - 8} (음정 없는 쏴아)`)),
];
const groups = [{ key: "gust", name: "돌풍·눈보라", items: [{ key: "gust_full", name: "돌풍·눈보라 — 잔잔한 눈보라", when: "낮에는 가끔, 밤 전투에는 자주·강하게 부는 돌풍에 맞춰 나옴. 같은 소리를 약한 돌풍 때 아주 작게(-24dB) 앰비언트로도 씀", duration: 4, clips }] }];
let tpl = fs.readFileSync(path.join(HERE, "page.template.html"), "utf8");
tpl = tpl.replace(/<title>[^<]*<\/title>/, "<title>마녀산장 눈보라 고르기</title>")
  .replace(/(<section class="intro">\s*)<h1>[\s\S]*?<\/h1>(\s*)<p>[\s\S]*?<\/p>/, `$1<h1>눈보라(돌풍) 소리 후보 10개, 하나를 골라 주세요</h1>$2<p>맨 앞은 처음 게임 소리, 그다음은 전에 고르신 1차 1번, 이어서 이번에 만든 3차(잔잔한 눈보라)와 4차(음정 없이 쏴아 하는 눈발)입니다. 4차 1번(<b>게임 적용</b>)이 지금 게임에 들어가 있습니다. 모두 원본 그대로 들려줍니다. 처음에는 <b>게임 소리만 보기</b>로 열리니 체크를 끄고 전부 들어 보세요. 마음에 드는 후보에서 <b>이걸로</b>, 모두 별로면 <b>다시 만들기</b>를 누른 뒤 <b>결과 복사</b>로 붙여 주세요.</p>`)
  .replace("/*__EDIT__*/", () => fs.readFileSync(path.join(HERE, "edit_rules.js"), "utf8"))
  .replace("/*__DATA__*/null", () => JSON.stringify({ groups, audio, auto: { gust_full: 7 }, store: "witchs-lodge-gust-review-v01", reportTitle: "마녀산장 눈보라 고르기" }));
fs.writeFileSync(path.join(HERE, "gust-review.html"), tpl);
console.log(clips.length, "clips", (tpl.length / 1048576).toFixed(2), "MB", tpl.includes("후보 10개") ? "intro ok" : "INTRO MISS");
