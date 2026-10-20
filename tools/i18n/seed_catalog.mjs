// 카드 카탈로그(catalog.json ↔ catalog_en.json)의 이름·분류·설명 줄·이름표를 한→영 사전으로 뽑는다.
// UI 번역 사전(godot/assets/i18n/en.json)과 번역 작업의 용어집으로 쓴다.
// 사용: node tools/i18n/seed_catalog.mjs  → tools/i18n/catalog_seed.json
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const read = (p) => JSON.parse(fs.readFileSync(path.join(ROOT, p), 'utf8'));
const ko = read('godot/assets/cards/catalog.json');
const en = read('godot/assets/cards/catalog_en.json');

const out = {};
const put = (k, v) => { if (typeof k === 'string' && typeof v === 'string' && k && v && !(k in out)) out[k] = v; };
for (const c of ko.cards) {
  const e = en.cards[c.id];
  if (!e) continue;
  put(c.name, e.name);
  put(c.category, e.category);
  const kr = Array.isArray(c.printed_rules) ? c.printed_rules : [c.printed_rules];
  const er = Array.isArray(e.printed_rules) ? e.printed_rules : [e.printed_rules];
  if (kr.length === er.length) kr.forEach((l, i) => put(l, er[i]));
  put(kr.join('\n'), er.join('\n'));
}
for (const [k, v] of Object.entries(en.badges ?? {})) put(k, v);
fs.writeFileSync(path.join(ROOT, 'tools/i18n/catalog_seed.json'), JSON.stringify(out, null, 1));
console.log(`catalog seed ${Object.keys(out).length}`);
