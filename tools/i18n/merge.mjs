// 번역 결과(tools/i18n/out/*.json)와 카드 카탈로그 용어(catalog_seed.json)를 합쳐 게임이 읽는 사전
// godot/assets/i18n/en.json 을 만든다. 서식 자리표시자(%d %s %.1f …)의 종류·순서가 원문과 다르면 실패로 알린다.
// 사용: node tools/i18n/extract.mjs && node tools/i18n/seed_catalog.mjs && node tools/i18n/merge.mjs
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const I18N = path.join(ROOT, 'tools/i18n');
const read = (p) => JSON.parse(fs.readFileSync(p, 'utf8'));
const SPEC = /%(%|[-+0#]*\d*(?:\.\d+)?[dsfxXc])/g;
const specs = (s) => [...s.matchAll(SPEC)].map(m => m[1]).filter(x => x !== '%').map(x => x.slice(-1) === 's' || x.slice(-1) === 'c' ? 's' : 'n');

const dict = {};
// 사람이 고친 값(overrides.json)이 가장 우선, 그다음 카드 카탈로그, 그다음 번역 결과
const outDir = path.join(I18N, 'out');
for (const f of fs.readdirSync(outDir).filter(f => f.endsWith('.json')).sort()) Object.assign(dict, read(path.join(outDir, f)));
Object.assign(dict, read(path.join(I18N, 'catalog_seed.json')));
const ov = path.join(I18N, 'overrides.json');
if (fs.existsSync(ov)) Object.assign(dict, read(ov));

// 손님 이름은 guest_profiles.gd 의 id 를 영문 표기로 삼는다(번역 덩어리마다 표기가 달라진 것을 맞춘다).
const profiles = fs.readFileSync(path.join(ROOT, 'godot/scripts/ui/guest_profiles.gd'), 'utf8');
const NAME_VARIANTS = { Nivel: ['Nibel'], Nib: ['Niv'], Larch: ['Lark'], Tass: ['Tas'], Thorgrim: ['Torgrim'], Fargh: ['Parg', 'Farg'] };
for (const m of profiles.matchAll(/"id": "(\w+)", "person": "([^"]+)"/g)) {
  const en = m[1][0].toUpperCase() + m[1].slice(1);
  dict[m[2]] = en;
  for (const v of NAME_VARIANTS[en] ?? []) {
    const re = new RegExp(`\\b${v}\\b`, 'g');
    for (const ko of Object.keys(dict)) if (ko.includes(m[2]) && typeof dict[ko] === 'string') dict[ko] = dict[ko].replace(re, en);
  }
}

// 줄 끝 CR 은 게임이 읽을 때 지운다(i18n_translation.gd) — 사전도 CR 없이 둔다
const CR = String.fromCharCode(13);
for (const k of Object.keys(dict)) if (k.includes(CR) || (typeof dict[k] === 'string' && dict[k].includes(CR))) { const v = dict[k]; delete dict[k]; dict[k.replaceAll(CR, '')] = typeof v === 'string' ? v.replaceAll(CR, '') : v; }

const strings = read(path.join(I18N, 'strings.json'));
const missing = strings.filter(x => !(x.ko in dict));
const bad = [];
for (const [ko, en] of Object.entries(dict)) {
  if (typeof en !== 'string') { bad.push([ko, en, 'not string']); continue; }
  const a = specs(ko).join(''), b = specs(en).join('');
  if (a !== b) bad.push([ko, en, `spec ${a} vs ${b}`]);
}
const sorted = Object.fromEntries(Object.entries(dict).sort(([a], [b]) => a < b ? -1 : a > b ? 1 : 0));
fs.mkdirSync(path.join(ROOT, 'godot/assets/i18n'), { recursive: true });
fs.writeFileSync(path.join(ROOT, 'godot/assets/i18n/en.json'), JSON.stringify(sorted, null, 1));
console.log(`entries ${Object.keys(dict).length}, source strings ${strings.length}, missing ${missing.length}, spec mismatch ${bad.length}`);
for (const m of missing.slice(0, 20)) console.log('MISSING', JSON.stringify(m));
for (const b of bad.slice(0, 40)) console.log('SPEC', JSON.stringify(b));
process.exitCode = missing.length || bad.length ? 1 : 0;
