// 카드 검토 페이지: cards.json(카드 컨셉, 모든 라운드) + hearthstone.json(하스스톤 리서치 초안) + heroines.json(아키타입 인물 카드 시안) + page.template.html → card-concepts.html
// 세 탭(카드 컨셉 / 하스스톤 리서치 / 인물 카드)으로 나뉘고, 결과 복사는 모든 탭의 판정·코멘트를 한꺼번에 담는다.
// 라운드를 더할 때는 cards.json 에 카드를 추가하고(round 증가, 새 카드는 isNew), 사용자 결정은 status 로 기록한 뒤 다시 실행한다.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const data = JSON.parse(fs.readFileSync(path.join(HERE, "cards.json"), "utf8"));
const hs = JSON.parse(fs.readFileSync(path.join(HERE, "hearthstone.json"), "utf8"));
const hr = JSON.parse(fs.readFileSync(path.join(HERE, "heroines.json"), "utf8"));
const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;");

// 데이터 점검: id 고유, 그룹 존재, 필수 칸
const ids = new Set(), groups = new Set(data.groups.map((g) => g.key));
for (const c of data.cards) {
  if (ids.has(c.id)) throw new Error("duplicate id " + c.id);
  ids.add(c.id);
  if (!groups.has(c.group)) throw new Error(`${c.id}: unknown group ${c.group}`);
  for (const k of ["name", "format", "effect", "role", "source", "round"]) if (c[k] === undefined || c[k] === "") throw new Error(`${c.id}: missing ${k}`);
}

for (const c of hs.cards) {
  if (ids.has(c.id)) throw new Error("duplicate id " + c.id);
  ids.add(c.id);
  for (const k of ["name", "rule", "ko", "p"]) if (!c[k]) throw new Error(`${c.id}: missing ${k}`);
  if (!hs.patternNames[c.p]) throw new Error(`${c.id}: unknown pattern ${c.p}`);
}

for (const c of hr.cards) {
  if (ids.has(c.id)) throw new Error("duplicate id " + c.id);
  ids.add(c.id);
  for (const k of ["name", "arch", "race", "quote", "printed", "facts", "stages", "lines", "art", "why"]) if (!c[k]) throw new Error(`${c.id}: missing ${k}`);
  if (c.printed.length !== 2 || c.stages.length !== 3) throw new Error(`${c.id}: printed 2줄 · stages 3단계여야 함`);
}

const latest = Math.max(...data.cards.map((c) => c.round));
const fresh = data.cards.filter((c) => c.round === latest && (c.isNew || c.revision));
const decided = data.cards.filter((c) => c.status);
const intro = `<h1>카드 컨셉 ${data.cards.length}장, 하나씩 판정해 주세요</h1>
    <p><b>${esc(data.rounds[latest] || latest + "라운드")}.</b> 이번 라운드에서 새로 올리거나 고친 카드는 <b>${fresh.length}장</b>(주황 <b>신규</b> 표시)이고, 이미 확정된 카드는 ${decided.length}장입니다. 효과와 수치는 모두 발상 초안이며, 기획 근거는 <code>docs/deck-archetypes-v01.md</code>입니다.</p>
    <p>카드마다 <b>승인 · 수정 필요 · 보류 · 제외</b> 중 하나를 누르고, 생각나는 건 코멘트 칸에 적어 주세요. 같은 버튼을 다시 누르면 판정이 풀립니다. 선택과 코멘트는 이 브라우저에 저장되니 나눠서 봐도 됩니다. 위의 <b>보기</b>로 미검토 카드나 신규 카드만 추릴 수 있습니다.</p>
    <p>다 보신 뒤 <b>결과 복사</b>를 눌러 대화창에 붙여 주세요. 승인은 확정 목록에 넣고, 수정 필요는 코멘트대로 고친 판을, 전체 의견에 적은 요청은 새 카드로 다음 라운드에 올립니다.</p>`;

let tpl = fs.readFileSync(path.join(HERE, "page.template.html"), "utf8");
tpl = tpl.replace("<!--__INTRO__-->", () => intro).replace("/*__DATA__*/null", () => JSON.stringify(data)).replace("/*__HS__*/null", () => JSON.stringify(hs)).replace("/*__HR__*/null", () => JSON.stringify(hr));
if (tpl.includes("__INTRO__") || tpl.includes("/*__DATA__*/") || tpl.includes("/*__HS__*/") || tpl.includes("/*__HR__*/")) throw new Error("template patch failed");
fs.writeFileSync(path.join(HERE, "card-concepts.html"), tpl);
const per = {};
for (const c of data.cards) per[c.group] = (per[c.group] || 0) + 1;
console.log(`heroines ${hr.cards.length} + hearthstone ${hs.cards.length} + ${data.cards.length} cards (round ${latest}: ${fresh.length} new/revised, ${decided.length} decided)`, per);
