// 게임 스크립트(.gd)에서 한글이 든 문자열 리터럴을 모아 번역 대상 목록을 만든다.
// 사용: node tools/i18n/extract.mjs  → tools/i18n/strings.json ([{ko, where}]) 과 누락 목록 출력
// 이미 godot/assets/i18n/en.json 에 있는 문자열은 "missing" 에서 빠진다.
import fs from 'node:fs';
import path from 'node:path';

import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const BS = String.fromCharCode(92);   // 역슬래시
const CR = String.fromCharCode(13);   // CRLF 파일의 
const GODOT = path.join(ROOT, 'godot');
const SKIP_DIRS = ['tools', 'addons', '.godot'];
const HANGUL = /[\uac00-\ud7a3\u3131-\u318e]/;

function walk(dir, out) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) { if (!SKIP_DIRS.includes(e.name)) walk(p, out); }
    else if (e.name.endsWith('.gd') || e.name.endsWith('.tscn')) out.push(p);
  }
  return out;
}

// GDScript 문자열 리터럴 토크나이저(주석 건너뜀). "..." '...' """...""" 를 지원한다.
function literals(src) {
  const res = [];
  let i = 0, line = 1;
  while (i < src.length) {
    const c = src[i];
    if (c === '\n') { line++; i++; continue; }
    if (c === '#') { while (i < src.length && src[i] !== '\n') i++; continue; }
    if (c === '"' || c === "'") {
      const triple = src.startsWith(c.repeat(3), i);
      const q = triple ? c.repeat(3) : c;
      const startLine = line;
      // 앞이 & ^ r 접두면 StringName/NodePath/raw — 내용은 동일하게 취급
      i += q.length;
      let s = '';
      while (i < src.length && !src.startsWith(q, i)) {
        if (src[i] === BS && i + 1 < src.length) {
          const n = src[i + 1];
          s += n === 'n' ? '\n' : n === 't' ? '\t' : n === '"' ? '"' : n === "'" ? "'" : n === BS ? BS : BS + n;
          i += 2; continue;
        }
        if (src[i] === '\n') line++;   // GDScript 4 는 일반 문자열 안의 줄바꿈도 허용한다
        s += src[i++];
      }
      i += q.length;
      res.push({ s: s.replaceAll(CR, ''), line: startLine });   // CRLF 파일의 여러 줄 문자열
      continue;
    }
    i++;
  }
  return res;
}

const found = new Map();
for (const f of walk(path.join(GODOT, 'scripts'), walk(path.join(GODOT, 'scenes'), []))) {
  const src = fs.readFileSync(f, 'utf8');
  const rel = path.relative(GODOT, f).split(path.sep).join('/');
  const lits = f.endsWith('.tscn')
    ? src.split('\n').filter(l => /^(text|tooltip_text|placeholder_text|title) = "/.test(l)).flatMap(l => literals(l.slice(l.indexOf('"'))))
    : literals(src);
  for (const { s, line } of lits) {
    if (!HANGUL.test(s)) continue;
    if (!found.has(s)) found.set(s, `${rel}:${line}`);
  }
}

// 카드 카탈로그 한글 이름·분류·이름표도 UI(툴팁·로그)에 나온다
const cat = JSON.parse(fs.readFileSync(path.join(GODOT, 'assets/cards/catalog.json'), 'utf8'));
const cards = Array.isArray(cat) ? cat : (cat.cards ?? Object.values(cat));
for (const c of cards) for (const k of ['name', 'category', 'badge', 'printed_rules', 'description', 'acquisition']) {
  const v = c?.[k]; if (typeof v === 'string' && HANGUL.test(v) && !found.has(v)) found.set(v, `catalog:${c.id}.${k}`);
}

const list = [...found].map(([ko, where]) => ({ ko, where }));
fs.writeFileSync(path.join(ROOT, 'tools/i18n/strings.json'), JSON.stringify(list, null, 1));
const enPath = path.join(GODOT, 'assets/i18n/en.json');
const have = fs.existsSync(enPath) ? JSON.parse(fs.readFileSync(enPath, 'utf8')) : {};
const missing = list.filter(x => !(x.ko in have));
fs.writeFileSync(path.join(ROOT, 'tools/i18n/missing.json'), JSON.stringify(missing, null, 1));
console.log(`strings ${list.length}, translated ${list.length - missing.length}, missing ${missing.length}`);
