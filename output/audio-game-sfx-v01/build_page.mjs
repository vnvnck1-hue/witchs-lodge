// raw/*.ogg 와 편집 규칙을 한 HTML 에 넣어 game-sfx.html 을 만든다(편집은 페이지에서 실시간으로).
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const P = JSON.parse(fs.readFileSync(path.join(HERE, "prompts.json"), "utf8"));
const meta = JSON.parse(fs.readFileSync(path.join(HERE, "meta.json"), "utf8"));
// '언제' 설명은 사운드 체크 목록 페이지의 문구를 그대로 쓴다
const checklist = fs.readFileSync(path.resolve(HERE, "../sound-checklist-v01/sound-checklist.html"), "utf8");
const when = {};
for (const m of checklist.matchAll(/\["(\w+)", "[^"]*", "((?:[^"\\]|\\.)*)"/g)) when[m[1]] = m[2].replace(/\\"/g, "\"");
const audio = {};
const groups = P.groups.map(([gkey, gname, items]) => ({
  key: gkey, name: gname,
  items: items.map(([key, name, , duration]) => {
    const clips = meta.filter((m) => m.key === key).sort((a, b) => a.pos - b.pos).map((m) => {
      audio[m.file] = fs.readFileSync(path.join(HERE, "raw", m.file)).toString("base64");
      return { file: m.file };
    });
    return { key, name, when: when[key] || "", duration, clips };
  }),
}));
// BGM: music/<key>-0N.mp3 를 그대로 넣는다(편집 없음)
groups.push({ key: "bgm", name: "BGM", items: P.music.map(([key, name]) => {
  const files = fs.readdirSync(path.join(HERE, "music")).filter((f) => f.startsWith(key + "-") && f.endsWith(".mp3")).sort();
  for (const f of files) audio[f] = fs.readFileSync(path.join(HERE, "music", f)).toString("base64");
  return { key, name, when: when[key] || "", duration: 60, music: true, clips: files.map((f) => ({ file: f })) };
}) });
const tpl = fs.readFileSync(path.join(HERE, "page.template.html"), "utf8");
const edit = fs.readFileSync(path.join(HERE, "edit_rules.js"), "utf8");
const html = tpl.replace("/*__EDIT__*/", () => edit).replace("/*__DATA__*/null", () => JSON.stringify({ groups, audio, auto: Object.fromEntries(JSON.parse(fs.readFileSync(path.join(HERE, "picks.json"), "utf8")).map((p) => [p.key, p.pick])) }));
fs.writeFileSync(path.join(HERE, "game-sfx.html"), html);
const missing = groups.flatMap((g) => g.items).filter((i) => !i.when || i.clips.length !== (i.music ? 2 : 4)).map((i) => i.key);
console.log(groups.length, "groups,", Object.keys(audio).length, "clips,", (html.length / 1048576).toFixed(2), "MB", missing.length ? "missing: " + missing : "");
