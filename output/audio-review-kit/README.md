# 소리 보고 페이지 기본 틀

2026-10-17 사용자 요청으로 **소리 작업 보고의 기본 형식**이 됐다. 새 소리 작업은 이 틀로 HTML 보고 페이지를 만든다.

- `page.template.html`: `../audio-game-sfx-v01/page.template.html`(검토 페이지) 기반. 추가된 것:
  - `<meta charset="utf-8">` — 정적 서버(`card-gallery` 미리보기)에서 한글이 깨지지 않게.
  - 항목에 `raw: true` 를 주면 다듬기 없이 파일 그대로 재생(칩 "원본 그대로").
  - **소리마다 코멘트 칸**. 적은 내용은 `[코멘트 n]` 으로 **결과 복사**에 함께 담기고, 브라우저에 저장된다(`<store>:notes`).
  - `.verify`(접는 검증 결과), `code` 스타일.
- `edit_rules.js`: 같은 폴더 복사본(임팩트·앞뒤 정리·반복음 다듬기 규칙).
- 쓰는 법: 각 작업 폴더의 `build_page.mjs` 가 이 틀을 읽어 제목·`<section class="intro">`·`/*__DATA__*/` 를 바꿔 끼운다. 예: [../audio-guest-voices-v01/build_page.mjs](../audio-guest-voices-v01/build_page.mjs).
  - DATA: `{ groups: [{key, name, items: [{key, name, when, duration, raw?, music?, clips: [{file, label}]}]}], audio: {file: base64}, auto: {itemKey: 게임 적용 후보 번호}, store, reportTitle }`
- 확인: 저장소 `output/` 정적 서버(`.claude/launch.json` 의 `card-gallery`, 8765)로 연다.
