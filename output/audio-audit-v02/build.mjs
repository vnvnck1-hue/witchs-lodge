// 소리 빈 곳 전수조사 결과(2026-10-19)를 체크 가능한 페이지 missing-sounds.html 로 만든다. 소리는 만들지 않는다.
import fs from "node:fs";
const P = [
  ["P1 · 핵심 순간인데 무음이거나 남의 소리를 빌려 씀", [
    ["prologue", "프롤로그(모션 코믹스)", "효과음 없음 (ui/prologue.gd) — 음악은 목록에서 뺌(2026-10-19)", "컷 넘김 소리 1"],
    ["boss", "보스의 밤 — 빈 굴의 주인", "등장·공격·처치 모두 일반 괴물 소리(mon_big 등), 음악도 일반 전투곡", "보스 등장 포효 · 보스 공격 · 보스 쓰러짐 (+보스 BGM 선택)"],
    ["wolf", "늑대 변신(보름달·늑대의 피)", "변신=적의 큰 소리(mon_big), 할퀴기·덮치기·물기=적 공격음, 해제=회복음", "변신 · 할퀴기 · 덮치기 · 물기 · 되돌아옴"],
    ["wolf_blood", "늑대의 피 마시기", "공용 카드 소리만", "마시고 괴로워하는 소리"],
    ["moon", "달 카드(초승·반달·보름) 사용", "공용 카드 소리만", "달빛 마법 발동"],
    ["vine", "덩굴 덫 · 가시 속박", "적을 묶어도 공용 카드 소리만", "덩굴·가시가 휘감는 소리"],
    ["firefly", "반딧불이 떼", "놓을 때·흩어질 때 무음", "반딧불 퍼짐 · 흩어짐"],
    ["burn", "카드 태우기", "태울 때 소리 없음(뽑으면 드로우음만)", "카드가 불붙어 사라지는 소리"],
  ]],
  ["P2 · 자주 하는 행동인데 공용 카드 소리로만 끝남", [
    ["campfire_fuel", "모닥불에 장작 넣기·다시 피우기", "공용 카드 소리", "장작 던짐 + 불 확 붙음"],
    ["cook_stew", "고기 스튜 끓이기", "공용 카드 소리", "냄비 보글"],
    ["corruption", "침식 카드가 들어옴", "카드 거절 소리로 대체", "불길한 저주 소리"],
    ["altar", "제단 해금·복구·의식·축복", "해금 무음, 나머지는 유물 획득음 빌려 씀", "제단 문양 깨어남 · 의식 완료"],
    ["moss", "이끼 붕대(정화)", "회복음만 — 정화 느낌 없음", "정화 반짝임"],
    ["invite", "초대장 보내기", "공용 카드 소리", "편지 날려 보냄"],
    ["tower_deposit", "감시탑 목재 적립", "공용 카드 소리", "목재 쌓는 소리 (적립 완료 시 강조)"],
    ["bow", "사냥꾼 활 쏘기", "맞는 소리만 있고 시위 소리 없음", "활 시위·화살 날아감"],
    ["lodge_ambience", "산장 관리 메뉴 — 손님 생활 앰비언스", "메뉴를 열면 바깥 소리만 먹먹해지고 실내 소리는 없음 (2026-10-19 추가 요청)", "손님들이 생활하는 실내 반복음"],
    ["enemy_kinds", "적 종류별 목소리", "침식된 자·공성 괴물이 서리 거미와 같은 소리", "침식된 자 · 공성 괴물 등장/피격/쓰러짐"],
  ]],
  ["P3 · 분위기와 작은 알림", [
    ["guest_leave", "손님 떠남", "무음", "문 닫고 떠나는 발소리"],
    ["wait_urgent", "기다림 게이지 촉박", "무음", "짧은 재촉 알림"],
    ["objective", "오늘의 할 일 완료", "무음", "작은 완료 표시음"],
    ["wildlife", "낮 숲의 토끼·사슴 기척", "도망·피격만 있음", "가까이 있을 때 기척 앰비언트"],
    ["explore", "탐험 — 랜드마크 발견·안개 걷힘", "무음", "발견 알림"],
    ["tutorial", "튜토리얼 단계 완료", "무음(제안 창만 소리)", "단계 완료음"],
  ]],
];
const fix = [
  "시장에서 살 때 '돈 받는 소리'(gold_reward)가 남 — 소리 새로 만들 필요 없이 '돈 쓰는 소리'로 바꾸면 됨 (chapter_director.gd buy)",
  "늑대 변신에 '적의 큰 소리', 늑대 공격에 '적 공격음'을 쓰고 있어 마녀가 적처럼 들림 — 위 P1 늑대 항목과 함께 처리",
];
const skip = ["지팡이 마력", "새끼양 다 자람", "숙박비 전용음", "인물 대사 풀더빙(2026-10-19 하지 않기로)", "프롤로그 음악(2026-10-19 목록에서 뺌)"];
const esc = (s) => s.replace(/[&<>]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;" })[c]);
let n = 0;
const sec = P.map(([h, rows]) => `<section><h2>${esc(h)}</h2><ul>${rows.map(([id, name, now, need]) => `<li><label><input type=checkbox data-name="${esc(name)}" data-need="${esc(need)}"><span class=no>${++n}</span><span class=b><b>${esc(name)}</b><span class=now>지금: ${esc(now)}</span><span class=need>필요: ${esc(need)}</span></span></label></li>`).join("")}</ul></section>`).join("");
fs.writeFileSync("missing-sounds.html", `<!doctype html><meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1"><title>마녀산장 빈 소리 조사</title>
<style>:root{--bg:#f6f1e7;--fg:#2b2620;--mut:#7a6e5f;--card:#fffaf0;--line:#e3d8c4;--acc:#7a4b2a}
@media (prefers-color-scheme:dark){:root{--bg:#1d1a16;--fg:#ece3d3;--mut:#a89a85;--card:#26221c;--line:#3a332a;--acc:#d9a571}}
body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.6 "Noto Serif KR",serif;padding:24px 16px 90px}main{max-width:760px;margin:auto}
h1{font-size:22px;margin:0}h2{font-size:16px;color:var(--acc);margin:24px 0 8px}.sub{color:var(--mut);font-size:13px}
ul{list-style:none;padding:0;margin:0;display:grid;gap:8px}li label{display:flex;gap:10px;background:var(--card);border:1px solid var(--line);border-radius:8px;padding:10px 12px;cursor:pointer}
.no{color:var(--mut);min-width:1.5em;font-variant-numeric:tabular-nums}.b{display:flex;flex-direction:column;min-width:0}.now{color:var(--mut);font-size:13px}.need{font-size:13px}
input{accent-color:var(--acc);margin-top:5px}.plain li{background:none;border:0;padding:2px 0;color:var(--mut);font-size:14px}
.bar{position:fixed;left:0;right:0;bottom:0;background:var(--card);border-top:1px solid var(--line);padding:10px 16px calc(10px + env(safe-area-inset-bottom,0px));display:flex;gap:10px;align-items:center;justify-content:center}
.bar button{font:inherit;background:var(--acc);color:var(--bg);border:0;border-radius:6px;padding:6px 14px;cursor:pointer}</style>
<main><h1>마녀산장 — 아직 소리가 없는 곳</h1><div class=sub>2026-10-19 코드 전수조사 · 소리 이벤트 152개 중 쓰이지 않는 것 0개 · 만들 것을 체크한 뒤 아래 버튼으로 복사해 보내 주세요</div>
${sec}
<h2>소리 없이 코드만 고치면 되는 것</h2><ul class=plain>${fix.map((x) => `<li>· ${esc(x)}</li>`).join("")}</ul>
<h2>이번 조사에서 뺀 것(이전에 제외)</h2><ul class=plain>${skip.map((x) => `<li>· ${esc(x)}</li>`).join("")}</ul></main>
<div class=bar><span id=c class=sub>0개 선택</span><button id=cp>선택 복사</button></div>
<script>const bx=[...document.querySelectorAll("input[type=checkbox]")],c=document.getElementById("c");
bx.forEach(b=>b.addEventListener("change",()=>c.textContent=bx.filter(x=>x.checked).length+"개 선택"));
document.getElementById("cp").onclick=async()=>{const t="마녀산장 빈 소리 v02 [만들기]\n"+bx.filter(x=>x.checked).map(x=>"- "+x.dataset.name+" — "+x.dataset.need).join("\n");
try{await navigator.clipboard.writeText(t);c.textContent="복사했어요"}catch(e){prompt("복사",t)}}</script>`);
console.log("items", n);
