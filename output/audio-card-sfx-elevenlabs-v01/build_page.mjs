// raw/*.ogg (ElevenLabs Ogg Opus) 와 손패 카드 PNG 를 한 HTML 에 넣어 card-sfx-elevenlabs.html 을 만든다.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const CARDS = path.resolve(HERE, "../../godot/assets/cards/hand");
const meta = JSON.parse(fs.readFileSync(path.join(HERE, "meta.json"), "utf8"));
const report = JSON.parse(fs.readFileSync(path.join(HERE, "edited", "edit-report.json"), "utf8"));
const CATS = [
  ["draw", "카드 들어옴", "획득한 카드가 손패로 날아와 자리 잡을 때"],
  ["hover", "마우스 오버", "손패의 카드에 커서가 올라가 카드가 커질 때"],
  ["pickup", "카드 집어 들기", "카드를 눌러 드래그를 시작할 때"],
  ["target", "대상 위에 올림", "카드를 끌고 사용 가능한 대상(나무·적·산장) 위에 들어설 때"],
  ["play", "카드 사용 확정", "유효한 대상에 카드를 놓아 사용될 때"],
  ["cancel", "취소 · 손패로 복귀", "빈 곳에 놓거나 우클릭/Esc로 취소해 카드가 손패로 돌아갈 때"],
  ["deny", "사용 불가", "지금 쓸 수 없는 대상에 놓았거나 조건이 부족할 때"],
  ["consume", "카드 소멸", "계약이 끝나거나 카드가 소비되어 사라질 때"],
  ["stash", "창고 보관", "손패가 넘쳐 카드가 창고로 들어가거나 창고와 교환할 때"],
  ["shuffle", "손패 정렬", "카드가 들어오거나 빠져 손패가 다시 펼쳐질 때"],
  ["inspect", "카드 뒤집기 · 확대", "카드를 뒤집거나 상세 보기로 크게 펼칠 때"],
];
const esc = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;");
const audio = {};
const manifest = { categories: [] };
for (const [key, name, when] of CATS) {
  const items = meta.filter((m) => m.key === key).sort((a, b) => a.pos - b.pos);
  if (!items.length) continue;
  manifest.categories.push({
    key, name,
    when: `${when}<br><span style="font-family:var(--font-mono);font-size:11.5px;opacity:.75">prompt: ${esc(items[0].prompt)}</span>`,
    items: items.map((m) => {
      // 기본 재생은 임팩트 편집본(edited/*.wav), 비교용으로 원본(raw/*.ogg)도 넣는다
      const wav = m.file.replace(/.ogg$/, ".wav");
      const rep = report.find((x) => x.file === wav);
      audio[wav] = fs.readFileSync(path.join(HERE, "edited", wav)).toString("base64");
      audio[m.file] = fs.readFileSync(path.join(HERE, "raw", m.file)).toString("base64");
      return { id: `${key}-${m.pos}`, file: wav, orig: m.file, name: `후보 ${m.pos}`, desc: `원본 ${rep.orig_seconds.toFixed(1)}초 · 임팩트 ${rep.orig_impacts}개 → 1개`, seconds: rep.seconds };
    }),
  });
}
const cards = {};
for (const t of ["axe_mercenary", "wool", "timber", "forest_monster"]) cards[t] = "data:image/png;base64," + fs.readFileSync(path.join(CARDS, t + ".png")).toString("base64");
const tpl = fs.readFileSync(path.join(HERE, "page.template.html"), "utf8");
const html = tpl.replace("/*__DATA__*/null", () => JSON.stringify({ manifest, audio, cards }));
fs.writeFileSync(path.join(HERE, "card-sfx-elevenlabs.html"), html);

console.log(manifest.categories.length, "categories,", Object.keys(audio).length, "clips,", (html.length / 1048576).toFixed(2), "MB");
