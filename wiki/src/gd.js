// GDScript 상수 리터럴을 JS 값으로 읽는다. `const NAME := <식>` 만 다루며, 식은 JS 문법과 거의 같다.
// Color()/Rect2()/Vector3() 는 문자열로, 다른 상수 참조는 앞서 읽은 값으로 평가한다.
"use strict";

function stripComments(src) {
  let out = "", inStr = false, q = "";
  for (let i = 0; i < src.length; i++) {
    const c = src[i];
    if (inStr) { out += c; if (c === "\\") { out += src[++i] || ""; } else if (c === q) inStr = false; continue; }
    if (c === '"' || c === "'") { inStr = true; q = c; out += c; continue; }
    if (c === "#") { while (i < src.length && src[i] !== "\n") i++; out += "\n"; continue; }
    out += c;
  }
  return out;
}

// 괄호 균형을 맞춰 식의 끝을 찾는다.
function readExpr(src, start) {
  let depth = 0, i = start, inStr = false, q = "";
  for (; i < src.length; i++) {
    const c = src[i];
    if (inStr) { if (c === "\\") i++; else if (c === q) inStr = false; continue; }
    if (c === '"' || c === "'") { inStr = true; q = c; continue; }
    if ("([{".includes(c)) depth++;
    else if (")]}".includes(c)) depth--;
    else if (c === "\n" && depth <= 0) break;
  }
  return src.slice(start, i).trim();
}

function parseConsts(text, env = {}) {
  const src = stripComments(text);
  const out = Object.assign({}, env);
  const re = /^const\s+([A-Za-z_]\w*)\s*(?::\s*[\w.]+)?\s*:?=\s*/gm;
  let m;
  while ((m = re.exec(src))) {
    const name = m[1];
    const expr = readExpr(src, m.index + m[0].length);
    if (/preload\(/.test(expr)) continue;
    const js = expr
      .replace(/\bColor\(/g, "__f('Color',").replace(/\bRect2\(/g, "__f('Rect2',").replace(/\bVector[23]\(/g, "__f('Vector',")
      .replace(/\bCfg\./g, "").replace(/\btrue\b/g, "true").replace(/\bfalse\b/g, "false").replace(/\bnull\b/g, "null");
    const names = Object.keys(out);
    try {
      const fn = new Function(...names, "__f", `return (${js});`);
      out[name] = fn(...names.map(n => out[n]), (k, ...a) => `${k}(${a.join(", ")})`);
    } catch (e) {
      // 평가할 수 없는 식(함수 호출 등)은 건너뛴다.
    }
    re.lastIndex = m.index + m[0].length + expr.length;
  }
  return out;
}

module.exports = { parseConsts };
