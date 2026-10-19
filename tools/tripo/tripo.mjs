#!/usr/bin/env node
// Tripo3D API(v3) 직접 호출 + 마녀산장 게임 적용 CLI. 의존성 없음(Node 18+ 내장 fetch).
// 전체 절차: docs/tripo-pipeline.md
//
// API 키: 환경변수 TRIPO_API_KEY, 없으면 %USERPROFILE%\.tripo\api_key 파일(저장소 밖)에서 읽는다.
// 키는 절대 저장소에 넣지 않는다. 국제판 키 기준 기본 주소는 https://openapi.tripo3d.ai (TRIPO_BASE_URL 로 변경).
//
// ── 원스톱(생성 → 임포트 → 배치 → 헤드리스 검증 [→ 실행파일]) ──────────────────────────
//   node tools/tripo/tripo.mjs make stone-well --text "mossy stone well with wooden roof" \
//        --height 1.8 --group lodge_west --kind rock [--label "돌 우물"] [--export]
//   node tools/tripo/tripo.mjs make stone-well --image art/concepts/well.png --height 1.8
//   node tools/tripo/tripo.mjs make stone-well --from output/tripo/stone-well --height 1.8   (이미 받은 GLB 재사용)
//
// ── 단계별 ─────────────────────────────────────────────────────────────────────────
//   balance | status <task_id> | fetch <task_id> --name foo
//   text  "<prompt>" --name foo          image <png> --name foo
//   multiview <front> [left] [back] [right] --name foo   ('-' 로 생략, front 필수·2장 이상)
//   ingest foo --height 1.8 [--id tripo_foo] [--label ..] [--yaw 0] [--frost 0.3] [--max-tex 1024]
//   place  (godot/art_sources/tripo/placements.json → forest_layout.json)
//   verify (godot/tools/verify_tripo_props.gd)
//
// 생성 옵션: --preset prop|character|raw (기본 prop: 프로젝트 화풍 문구·면 수·PBR 끔)
//           --model v3.1-20260211  --face-limit 8000  --no-texture  --pbr  --quad  --smart-low-poly
//           --texture-quality detailed  --negative "..."  --seed N  --out <dir>  --no-wait  --dry-run
// 결과: output/tripo/<name>/ 에 request.json·task.json·model_url.glb·미리보기.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const BASE = process.env.TRIPO_BASE_URL || "https://openapi.tripo3d.ai";
const DEFAULT_MODEL = "v3.1-20260211";
const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const GODOT = path.join(ROOT, ".tools", "Godot-4.7.2.exe");
const PLACEMENTS = path.join(ROOT, "godot", "art_sources", "tripo", "placements.json");

// 프로젝트 아트 방향(docs/art-direction.md): 중세 기반 판타지, 살짝 과장한 두꺼운 실루엣, 큰 색면·드문 붓질, 낮은 무늬 밀도.
const PRESETS = {
  prop: {
    suffix: "medieval-based fantasy, stylized hand-painted game prop, chunky slightly exaggerated silhouette, " +
      "thick rounded edges, large flat color areas with sparse painterly brush strokes, low detail density, " +
      "single object standing upright, no ground plane, no pedestal",
    negative: "photorealistic, realistic scan, fine cracks, dense noise texture, tiny details, text, logo, ground plane, base platform",
    options: { face_limit: 6000, pbr: false },
  },
  character: {
    suffix: "medieval-based fantasy, stylized hand-painted game character, 2-3 head tall chibi proportions, " +
      "large flat color areas, sparse painterly brush strokes, A-pose, full body, no base",
    negative: "photorealistic, realistic scan, fine details, text, logo, base platform",
    options: { face_limit: 10000, pbr: false },
  },
  raw: { suffix: "", negative: "", options: {} },
};

function loadKey() {
  let key = (process.env.TRIPO_API_KEY || "").trim();
  if (!key) {
    const f = path.join(os.homedir(), ".tripo", "api_key");
    if (fs.existsSync(f)) key = fs.readFileSync(f, "utf8").trim();
  }
  if (!key) {
    console.error("TRIPO_API_KEY 가 없습니다. 환경변수로 설정하거나 %USERPROFILE%\\.tripo\\api_key 파일에 넣어 주세요.");
    process.exit(2);
  }
  if (!key.startsWith("tsk_")) console.warn("경고: Tripo API 키는 보통 'tsk_' 로 시작합니다.");
  return key;
}

function parseArgs(argv) {
  const pos = [], opt = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (!a.startsWith("--")) { pos.push(a); continue; }
    const k = a.slice(2);
    const next = argv[i + 1];
    if (next !== undefined && !next.startsWith("--")) { opt[k] = next; i++; } else opt[k] = true;
  }
  return { pos, opt };
}

let KEY = "";
async function api(method, p, { json, form } = {}) {
  if (!KEY) KEY = loadKey();
  const headers = { Authorization: `Bearer ${KEY}`, Accept: "application/json" };
  let body;
  if (json) { headers["Content-Type"] = "application/json"; body = JSON.stringify(json); }
  if (form) body = form;
  const attempts = method === "GET" ? 4 : 1; // 생성 요청은 재시도하지 않음(중복 과금 방지)
  for (let n = 1; ; n++) {
    const res = await fetch(BASE + p, { method, headers, body });
    const text = await res.text();
    let data; try { data = JSON.parse(text); } catch { data = text; }
    if ([429, 502, 503, 504].includes(res.status) && n < attempts) { await sleep(1500 * n); continue; }
    const code = data && typeof data === "object" ? data.code : undefined;
    if (!res.ok || (code !== undefined && code !== 0) || data?.status === "error") {
      const hint = { 401: " (키 또는 지역 주소 확인: TRIPO_BASE_URL)", 403: " (크레딧 부족일 수 있음: balance)" }[res.status] || "";
      throw new Error(`${method} ${p} → HTTP ${res.status}${hint}: ${typeof data === "string" ? data : JSON.stringify(data)}`);
    }
    return data && typeof data === "object" && "data" in data ? data.data : data;
  }
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function upload(file) {
  const buf = fs.readFileSync(file);
  const ext = path.extname(file).slice(1).toLowerCase();
  const mime = { png: "image/png", jpg: "image/jpeg", jpeg: "image/jpeg", webp: "image/webp" }[ext] || "application/octet-stream";
  const form = new FormData();
  form.append("file", new Blob([buf], { type: mime }), path.basename(file));
  const d = await api("POST", "/v3/files", { form });
  const token = d.file_token || d.token || d.id;
  if (!token) throw new Error("업로드 응답에 file_token 이 없습니다: " + JSON.stringify(d));
  console.log(`업로드: ${path.relative(ROOT, file)} → ${token}`);
  return token;
}

async function resolveImage(x, dry) {
  if (!x || x === "-" || x === "none") return null;
  if (/^https?:\/\//.test(x) || /^file_/.test(x)) return x;
  const f = path.resolve(x);
  if (!fs.existsSync(f)) throw new Error("이미지가 없습니다: " + x);
  return dry ? `file_<${path.basename(f)}>` : upload(f);
}

function genOptions(opt) {
  const preset = PRESETS[opt.preset || "prop"];
  if (!preset) throw new Error(`알 수 없는 --preset ${opt.preset} (prop|character|raw)`);
  const p = { model: opt.model || DEFAULT_MODEL, ...preset.options };
  const negative = opt.negative || preset.negative;
  if (negative) p.negative_prompt = negative.slice(0, 255);
  if (opt["face-limit"]) p.face_limit = Number(opt["face-limit"]);
  if (opt["no-texture"]) p.texture = false;
  if (opt.pbr) p.pbr = true;
  if (opt["no-pbr"]) p.pbr = false;
  if (opt.quad) p.quad = true;
  if (opt["smart-low-poly"]) p.smart_low_poly = true;
  if (opt["texture-quality"]) p.texture_quality = opt["texture-quality"];
  if (opt["geometry-quality"]) p.geometry_quality = opt["geometry-quality"];
  if (opt["auto-size"]) p.auto_size = true;
  if (opt.seed) p.model_seed = Number(opt.seed);
  return p;
}

function styledPrompt(text, opt) {
  const suffix = PRESETS[opt.preset || "prop"].suffix;
  return (suffix ? `${text}, ${suffix}` : text).slice(0, 1024);
}

function taskIdOf(d) {
  const id = typeof d === "string" ? d : d?.task_id || d?.id || d?.task?.id;
  if (!id) throw new Error("작업 생성 응답에 task_id 가 없습니다: " + JSON.stringify(d));
  return id;
}

async function getTask(id) { return api("GET", `/v3/tasks/${id}`); }

async function waitTask(id) {
  const t0 = Date.now();
  let last = "";
  for (;;) {
    const t = await getTask(id);
    const line = `${t.status} ${t.progress ?? ""}%`;
    if (line !== last) { console.log(`[${Math.round((Date.now() - t0) / 1000)}s] ${id} ${line}`); last = line; }
    if (t.status === "success") return t;
    if (!["queued", "running"].includes(t.status)) {   // 모르는 상태는 실패로 본다(v3 권장)
      throw new Error(`작업 실패(${t.status} ${t.error_code ?? ""}): ${t.error_message || t.error_msg || JSON.stringify(t)}`);
    }
    await sleep(4000);
  }
}

// output 안의 http URL 을 모두 찾아 받는다(필드명이 버전마다 달라도 동작).
function collectUrls(obj, prefix = "", acc = []) {
  if (!obj || typeof obj !== "object") return acc;
  for (const [k, v] of Object.entries(obj)) {
    const key = prefix ? `${prefix}.${k}` : k;
    if (typeof v === "string" && /^https?:\/\//.test(v)) acc.push([key, v]);
    else if (v && typeof v === "object") collectUrls(v, key, acc);
  }
  return acc;
}

async function download(task, outDir) {
  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(path.join(outDir, "task.json"), JSON.stringify(task, null, 2));
  const seen = new Map();
  for (const [key, url] of collectUrls(task.output || task.result || {})) {
    if (seen.has(url)) continue;
    const ext = (new URL(url).pathname.match(/\.([a-z0-9]+)$/i)?.[1] || "bin").toLowerCase();
    const file = path.join(outDir, `${key.replace(/[^\w.-]+/g, "_")}.${ext}`);
    const res = await fetch(url); // 서명 URL: API 키를 보내지 않는다
    if (!res.ok) { console.warn(`받기 실패 ${key}: HTTP ${res.status}`); continue; }
    fs.writeFileSync(file, Buffer.from(await res.arrayBuffer()));
    seen.set(url, file);
    console.log(`저장: ${path.relative(ROOT, file)}`);
  }
  if (!seen.size) console.warn("output 에서 받을 URL 을 찾지 못했습니다. task.json 을 확인하세요.");
  if (task.credits_consumed !== undefined) console.log(`소모 크레딧: ${task.credits_consumed}`);
  return outDir;
}

function outDirFor(opt, id) {
  return path.resolve(opt.out || path.join(ROOT, "output", "tripo", opt.name || id));
}

async function submit(endpoint, payload, opt) {
  const outDir = outDirFor(opt, `task-${new Date().toISOString().slice(0, 19).replace(/\D/g, "")}`);
  if (opt["dry-run"]) {
    console.log(`[dry-run] POST ${BASE}${endpoint}\n${JSON.stringify(payload, null, 2)}`);
    return null;
  }
  fs.mkdirSync(outDir, { recursive: true });
  const d = await api("POST", endpoint, { json: payload });
  const id = taskIdOf(d);
  fs.writeFileSync(path.join(outDir, "request.json"),
    JSON.stringify({ endpoint, payload, task_id: id, created: new Date().toISOString() }, null, 2));
  console.log(`작업 생성: ${id}`);
  if (opt["no-wait"]) return null;
  const t = await waitTask(id);
  return download(t, outDir);
}

async function generate(kind, args, opt) {
  const dry = !!opt["dry-run"];
  if (kind === "text") {
    if (!args[0]) throw new Error("프롬프트가 필요합니다.");
    return submit("/v3/generation/text-to-model", { prompt: styledPrompt(args.join(" "), opt), ...genOptions(opt) }, opt);
  }
  if (kind === "image") {
    if (!args[0]) throw new Error("이미지 경로가 필요합니다.");
    return submit("/v3/generation/image-to-model", { input: await resolveImage(args[0], dry), ...genOptions(opt) }, opt);
  }
  if (kind === "multiview") {
    const views = ["front", "left", "back", "right"];
    const inputs = [];
    for (let i = 0; i < 4; i++) {
      const v = await resolveImage(args[i], dry);
      if (v) inputs.push({ [views[i]]: v });
    }
    if (!inputs[0]?.front || inputs.length < 2) throw new Error("multiview 는 front 와 그 밖의 1장 이상이 필요합니다.");
    return submit("/v3/generation/multiview-to-model", { inputs, ...genOptions(opt) }, opt);
  }
}

// ── 게임 적용 단계(Godot 헤드리스) ───────────────────────────────────────────────
function godot(script, userArgs = []) {
  const args = ["--headless", "--path", path.join(ROOT, "godot"), "--script", script];
  if (userArgs.length) args.push("--", ...userArgs.map(String));
  const r = spawnSync(GODOT, args, { encoding: "utf8", maxBuffer: 64 << 20 });
  const out = (r.stdout || "") + (r.stderr || "");
  const lines = out.split(/\r?\n/).filter((l) => /^(PASS|FAIL|RESULT|TRIPO_|ERROR|SCRIPT ERROR|WARNING)/.test(l)
    && !l.includes("custom_samplers"));
  console.log(lines.join("\n"));
  if (r.status !== 0) throw new Error(`${script} 실패(종료 코드 ${r.status})`);
  return out;
}

const idOf = (name, opt) => opt.id || "tripo_" + name.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");

function findModel(dir) {
  const files = fs.readdirSync(dir).filter((f) => /\.(glb|gltf)$/i.test(f));
  const pick = files.find((f) => f.startsWith("model_url")) || files.find((f) => /pbr_model|^model/.test(f)) || files[0];
  if (!pick) throw new Error(`${path.relative(ROOT, dir)} 에 GLB 가 없습니다.`);
  return path.join(dir, pick);
}

function ingest(name, opt) {
  const dir = opt.from ? path.resolve(opt.from) : path.join(ROOT, "output", "tripo", name);
  const glb = fs.statSync(dir).isFile() ? dir : findModel(dir);
  if (!opt.height) throw new Error("--height <미터> 가 필요합니다(게임 안 실제 높이. 마녀 키 약 1.6m, 산장 문 약 2.2m).");
  const id = idOf(name, opt);
  godot("res://tools/tripo_ingest.gd", [glb, id, opt.height, opt.label || name, opt.yaw || 0, opt.frost ?? 0.3, opt["max-tex"] || 1024]);
  return id;
}

function addPlacement(id, opt) {
  const plan = fs.existsSync(PLACEMENTS) ? JSON.parse(fs.readFileSync(PLACEMENTS, "utf8")) : { props: [] };
  const item = { asset: id, group: opt.group, kind: opt.kind || "rock", scale: Number(opt.scale || 1) };
  if (opt.at) item.at = String(opt.at).split(",").map(Number);
  if (opt["place-yaw"] !== undefined) item.yaw = Number(opt["place-yaw"]);
  if (opt.clearance) item.clearance = Number(opt.clearance);
  const count = Number(opt.count || 1);
  plan.props = plan.props.filter((p) => !(p.asset === id && p.group === opt.group));   // 같은 군집 재지정은 교체
  for (let i = 0; i < count; i++) plan.props.push({ ...item });
  fs.mkdirSync(path.dirname(PLACEMENTS), { recursive: true });
  fs.writeFileSync(PLACEMENTS, JSON.stringify(plan, null, 2) + "\n");
  console.log(`배치 목록: ${id} ×${count} → ${opt.group} (${path.relative(ROOT, PLACEMENTS)})`);
}

function exportGame() {
  const r = spawnSync(GODOT, ["--headless", "--path", path.join(ROOT, "godot"), "--export-release", "Windows Desktop",
    path.join(ROOT, "WitchsLodge.exe")], { encoding: "utf8", maxBuffer: 64 << 20 });
  if (r.status !== 0) throw new Error("실행파일 내보내기 실패(게임이 켜져 있으면 끄고 다시)");
  console.log("실행파일 갱신: WitchsLodge.exe");
}

async function make(name, opt) {
  if (!name) throw new Error("make <name> 이 필요합니다.");
  opt.name = name;
  if (!opt.from) {
    let dir;
    if (opt.text) dir = await generate("text", [opt.text], opt);
    else if (opt.image) dir = await generate("image", [opt.image], opt);
    else if (opt.multiview) dir = await generate("multiview", String(opt.multiview).split(","), opt);
    else throw new Error("--text / --image / --multiview a,b,c,d / --from <폴더|GLB> 중 하나가 필요합니다.");
    if (!dir) return;   // dry-run · no-wait
    opt.from = dir;
  }
  const id = ingest(name, opt);
  if (opt.group) { addPlacement(id, opt); godot("res://tools/tripo_place.gd"); }
  godot("res://tools/verify_tripo_props.gd");
  if (opt.export) exportGame();
  console.log(`완료: ${id} → godot/scenes/props/nature/${id}.tscn`);
}

const { pos, opt } = parseArgs(process.argv.slice(2));
const cmd = pos.shift();
try {
  switch (cmd) {
    case "balance": console.log(JSON.stringify(await api("GET", "/v3/account/balance"), null, 2)); break;
    case "text": case "image": case "multiview": await generate(cmd, pos, opt); break;
    case "status": console.log(JSON.stringify(await getTask(pos[0]), null, 2)); break;
    case "fetch": await download(await waitTask(pos[0]), outDirFor(opt, pos[0])); break;
    case "ingest": ingest(pos[0], opt); break;
    case "place": godot("res://tools/tripo_place.gd"); break;
    case "verify": godot("res://tools/verify_tripo_props.gd"); break;
    case "make": await make(pos[0], opt); break;
    default:
      console.log(fs.readFileSync(new URL(import.meta.url), "utf8").split("\n").filter((l) => l.startsWith("//")).map((l) => l.slice(3)).join("\n"));
  }
} catch (e) {
  console.error("오류:", e.message);
  process.exit(1);
}
