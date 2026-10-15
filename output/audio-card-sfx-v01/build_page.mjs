// 후보 WAV 와 손패 카드 PNG 를 한 HTML 에 넣어 card-sfx-audition.html 을 만든다.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const CARDS = path.resolve(HERE, "../../godot/assets/cards/hand");
const manifest = JSON.parse(fs.readFileSync(path.join(HERE, "manifest.json"), "utf8"));
const audio = {};
for (const c of manifest.categories) for (const it of c.items) audio[it.file] = fs.readFileSync(path.join(HERE, "wav", it.file)).toString("base64");
const cards = {};
for (const t of ["axe_mercenary", "wool", "timber", "forest_monster"]) cards[t] = "data:image/png;base64," + fs.readFileSync(path.join(CARDS, t + ".png")).toString("base64");
const tpl = fs.readFileSync(path.join(HERE, "page.template.html"), "utf8");
const html = tpl.replace("/*__DATA__*/null", () => JSON.stringify({ manifest, audio, cards }));
fs.writeFileSync(path.join(HERE, "card-sfx-audition.html"), html);
console.log("card-sfx-audition.html", (html.length / 1048576).toFixed(2), "MB");
