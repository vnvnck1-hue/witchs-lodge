# 마녀의 주머니 v01 — 납품 파일 목록

2026-10-16 · 내장 image_gen 생성/수정 · 커밋 없음.

## 요청한 PNG 7개

| 파일 | 규격 |
| --- | --- |
| `art/cards/rounded/poison_mushroom.png` | RGBA 1024×1536 원화 |
| `godot/assets/cards/poison_mushroom.png` | RGBA 1024×1536 게임용 |
| `godot/assets/cards/hand/poison_mushroom.png` | RGBA 256×384 손패 |
| `art/cards/rounded/old_spellbook.png` | RGBA 1024×1536 원화 |
| `godot/assets/cards/old_spellbook.png` | RGBA 1024×1536 게임용 |
| `godot/assets/cards/hand/old_spellbook.png` | RGBA 256×384 손패 |
| `godot/assets/ui/icons/icon_discard.png` | RGBA 96×96 아이콘 |

추가 생성 원본: `art/ui/pocket-cards-v01/icon_discard.png`, RGBA 1024×1024. 원본과 납품 7개의 SHA-256·치수·알파는 [delivery-manifest.json](delivery-manifest.json)에 있다.

## 검수·문서

- `godot/screenshots/cards/asset-gallery.png` 갱신 — 27장 전체, Godot 실제 텍스처 렌더.
- `godot/screenshots/cards/pocket-cards-v01-text-proof.png` 생성 — 최종 배포 PNG의 제목·본문 1:1 픽셀 확대 시트.
- `output/pocket-cards-v01/icon-proof.png` 생성 — 아이콘 실제 크기와 확대본, 밝고 어두운 바탕.
- `art/cards/README.md`, `art/cards/manifest.json` 갱신.
- `art/cards/pocket-cards-v01-review.md`, `docs/prompts/cards/pocket-cards-v01-prompts.md` 생성.
- `godot/assets/cards/packaging.json`, `godot/assets/cards/verification.json` 갱신.
- 이 폴더의 `generation-record.json`, `asset-verification.json`, `delivery-manifest.json`, `scope-audit.json` 생성. 단계별 실행 로그도 보존한다.

## 재현 도구

- 수정: `godot/tools/package_card_assets.gd` — 전체 ID 27개, 선택 ID만 재패키징하는 인자.
- 수정: `godot/tools/verify_card_assets.gd` — 27장 검사, 요청 문구와 카탈로그 대조, 기존 숲 카드 검사 기준 분리.
- 생성: `godot/tools/record_pocket_assets.gd` — 아이콘 Lanczos 축소, 메타데이터·해시·검수 시트.
- 생성: `godot/tools/preview_pocket_card_assets.gd` — 27장 전체 갤러리.
- 생성: `godot/art_sources/run_pocket_asset_pipeline.ps1` — 순차 패키징·임포트·검증·갤러리. Godot 자동 생성 `.uid`·PNG `.import` 메타데이터 포함.

## 결과

전체 카드 27장/배포 PNG 54개 통과, 새 카드 2종/PNG 6개와 아이콘 1개 통과, 실패 0. 새 두 카드의 카탈로그 등록·문구 대조도 통과. 제목·분류·본문을 최종 확대 시트에서 직접 대조해 오탈자 없음. 기존 카드 PNG는 보존했다. 수정 금지 경로의 동시 작업 변경을 되돌리지 않았고 이 작업에서는 해당 경로에 쓰지 않았다.
