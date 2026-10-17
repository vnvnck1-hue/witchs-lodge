#!/usr/bin/env node
// Tripo3D API(v3) 직접 호출 CLI. 의존성 없음(Node 18+ 내장 fetch).
//
// API 키: 환경변수 TRIPO_API_KEY, 없으면 %USERPROFILE%\.tripo\api_key 파일(저장소 밖)에서 읽는다.
// 키는 절대 저장소에 넣지 않는다.
//
// 사용 예 (프로젝트 루트 기준):
//   node tools/tripo/tripo.mjs balance
//   node tools/tripo/tripo.mjs text  "mossy medieval stone well, stylized" --name stone-well
//   node tools/tripo/tripo.mjs image art/concepts/foo.png --name foo
//   node tools/tripo/tripo.mjs multiview front.png left.png back.png right.png --name foo
//   node tools/tripo/tripo.mjs status <task_id>
//   node tools/tripo/tripo.mjs fetch  <task_id> --name foo     (완료된 작업 다시 받기)
//
// 공통 옵션: --model v3.1-20260211  --face-limit 8000  --no-texture  --no-pbr  --quad
//           --smart-low-poly  --texture-quality detailed  --negative "..."  --out <dir>  --no-wait
// 결과: output/tripo/<name>/ 에 GLB·미리보기·task.json 저장.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const BASE = process.env.TRIPO_BASE_URL || "https://openapi.tripo3d.ai";
const DEFAULT_MODEL = "v3.1-20260211";
const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");

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

async function api(method, p, { json, form } = {}) {
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
      throw new Error(`${method} ${p} → HTTP ${res.status}: ${typeof data === "string" ? data : JSON.stringify(data)}`);
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
  console.log(`업로드: ${file} → ${token}`);
  return token;
}

async function resolveImage(x) {
  if (!x || x === "-" || x === "none") return null;
  if (/^https?:\/\//.test(x) || /^file_/.test(x)) return x;
  return upload(path.resolve(x));
}

function genOptions(opt) {
  const p = { model: opt.model || DEFAULT_MODEL };
  if (opt.negative) p.negative_prompt = opt.negative;
  if (opt["face-limit"]) p.face_limit = Number(opt["face-limit"]);
  if (opt["no-texture"]) p.texture = false;
  if (opt["no-pbr"]) p.pbr = false;
  if (opt.quad) p.quad = true;
  if (opt["smart-low-poly"]) p.smart_low_poly = true;
  if (opt["texture-quality"]) p.texture_quality = opt["texture-quality"];
  if (opt["geometry-quality"]) p.geometry_quality = opt["geometry-quality"];
  if (opt["auto-size"]) p.auto_size = true;
  if (opt.seed) p.model_seed = Number(opt.seed);
  return p;
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
    if (["failed", "cancelled", "banned", "expired", "unknown"].includes(t.status)) {
      throw new Error(`작업 실패(${t.status}): ${t.error_msg || t.error_message || JSON.stringify(t)}`);
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
}

function outDirFor(opt, id) {
  return path.resolve(opt.out || path.join(ROOT, "output", "tripo", opt.name || id));
}

async function submit(p, payload, opt) {
  const d = await api("POST", p, { json: payload });
  const id = taskIdOf(d);
  console.log(`작업 생성: ${id}`);
  if (opt["no-wait"]) return;
  const t = await waitTask(id);
  await download(t, outDirFor(opt, id));
}

const { pos, opt } = parseArgs(process.argv.slice(2));
const cmd = pos.shift();
const KEY = cmd && cmd !== "help" ? loadKey() : "";

try {
  switch (cmd) {
    case "balance":
      console.log(JSON.stringify(await api("GET", "/v3/account/balance"), null, 2));
      break;
    case "text":
      if (!pos[0]) throw new Error("프롬프트가 필요합니다.");
      await submit("/v3/generation/text-to-model", { prompt: pos.join(" "), ...genOptions(opt) }, opt);
      break;
    case "image":
      if (!pos[0]) throw new Error("이미지 경로가 필요합니다.");
      await submit("/v3/generation/image-to-model", { input: await resolveImage(pos[0]), ...genOptions(opt) }, opt);
      break;
    case "multiview": {
      if (!pos[0]) throw new Error("front [left back right] 이미지가 필요합니다('-' 로 생략).");
      const inputs = [];
      for (let i = 0; i < 4; i++) inputs.push(await resolveImage(pos[i]));
      await submit("/v3/generation/multiview-to-model", { inputs, ...genOptions(opt) }, opt);
      break;
    }
    case "status":
      console.log(JSON.stringify(await getTask(pos[0]), null, 2));
      break;
    case "fetch": {
      const t = await waitTask(pos[0]);
      await download(t, outDirFor(opt, pos[0]));
      break;
    }
    default:
      console.log(fs.readFileSync(new URL(import.meta.url), "utf8").split("\n").filter((l) => l.startsWith("//")).map((l) => l.slice(3)).join("\n"));
  }
} catch (e) {
  console.error("오류:", e.message);
  process.exit(1);
}
