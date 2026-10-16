# Codex에게 요청하는 에셋 작업 — 마녀의 주머니 드로우 카드 2종 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-16 · 기획: [세계관·지역과 계절·마녀의 주머니](../region-season-pocket-design.md) §6

## 역할 분담

- **Codex 책임:** 아래 카드 원화 2종의 생성·라운드 처리·패키징·검증·문서화, 버림패 아이콘 1종.
- **Claude 책임:** 주머니(덱)·드로우·버림패 규칙, 카드 판정, `godot/assets/cards/catalog.json`, UI 구현. 에셋이 없는 동안은 공용 뒷면으로 대체해 두었으므로, 납품되면 경로만 맞으면 바로 보인다.
- **수정 금지:** `godot/scripts/**`, `godot/assets/cards/catalog.json`, `godot/scenes/**`, `godot/shaders/**`, `godot/tools/verify_pocket*.gd`. Claude가 동시에 고치고 있다. 다른 작업의 변경을 되돌리지 말 것. 커밋하지 말 것(사용자가 정리한다).

## 반드시 따를 기존 기준

먼저 읽기: `art/cards/README.md`, `docs/prompts/cards/production-rounded-v02-prompts.md`, `docs/handoff/codex-jobs-update-v01.md`(직전 요청과 완료 방식), `art/cards/manifest.json`, `godot/tools/package_card_assets.gd`, `godot/tools/verify_card_assets.gd`, 기존 카드 `godot/assets/cards/*.png`(특히 `gatherer.png`, `black_wool.png`, `frost_rune.png`).

- 카드: 기존 카드와 **같은 프레임·같은 비대칭 S자 포맷·같은 붓터치 원화 스타일·같은 한글 서체 느낌**. 네 모서리 둥글게, 바깥 투명. 시험 수치(체력 비용 등)는 그림에 넣지 않는다.
- 산출물 경로(카드): `art/cards/rounded/<id>.png`, `godot/assets/cards/<id>.png`(RGBA 1024×1536), `godot/assets/cards/hand/<id>.png`(RGBA 256×384).
- `package_card_assets.gd`·`verify_card_assets.gd`에 새 ID 2개를 추가해 검증(이 두 도구 파일은 Codex가 수정해도 된다).
- `art/cards/manifest.json`, `art/cards/README.md` 표, 프롬프트 기록 `docs/prompts/cards/pocket-cards-v01-prompts.md`, `godot/assets/cards/verification.json`, 갤러리 `godot/screenshots/cards/asset-gallery.png` 갱신.
- Godot 실행 파일: `.tools/Godot-4.7.2.exe`.

## A. 카드 2종 (인쇄 문구는 이 글자 그대로)

| id | 카드 이름 | 분류 띠 | 인쇄 문구 (2줄) |
|---|---|---|---|
| `poison_mushroom` | 독버섯 | 재료 · 숲의 독 | 마녀의 체력을 깎습니다. / 대신 주머니에서 한 장을 뽑습니다. |
| `old_spellbook` | 오래된 마법서적 | 주문 · 마녀의 서적 | 주머니의 카드 세 장을 펼칩니다. / 그중 한 장을 골라 뽑습니다. |

### 원화 내용

- **독버섯:** 눈 덮인 낙엽 위에 돋은 보라빛 갓의 독버섯 두세 송이. 갓에 연노랑 반점, 밑동에서 옅은 보라 독기가 김처럼 오른다. 작은 뼈 하나와 서리 낀 이끼. 기존 `black_wool`·`frost_rune`처럼 어둡고 차가운 톤. 잔혹하지 않게.
- **오래된 마법서적:** 낡은 가죽 표지에 달 문양이 찍힌 두꺼운 마법서가 반쯤 펼쳐져 있고, 펼친 페이지에서 보라·금빛 빛과 함께 **작은 카드 세 장**이 부채꼴로 떠오른다. 촛불 하나, 산장 나무 탁자, 창밖 눈. 따뜻한 금빛 + 보라.

## B. 아이콘 1종

- `godot/assets/ui/icons/icon_discard.png`, RGBA 96×96, 바깥 투명. **옆으로 뉘어 쌓인 카드 더미에 작은 재/먼지가 흩어지는** 단순 실루엣 + 두꺼운 먹선. 기존 `godot/assets/ui/icons/icon_*.png`와 같은 선 두께·채도.

## 완료 기준

1. 2종 × (원화·1024×1536·256×384) = 6개 PNG와 아이콘 1개가 위 경로에 있음.
2. 검증 도구가 기존 전부 + 새 2종을 통과하고 `verification.json`에 기록.
3. 갤러리 PNG 갱신, README·manifest·프롬프트 문서 갱신.
4. 마지막 메시지에 생성 파일 목록과 검증 결과를 요약. 인쇄 문구 오탈자가 없는지 직접 확대해서 확인한 결과도 적는다.


## Codex 납품 결과 · 2026-10-16

- 카드 2종 원화·게임용·손패용 PNG 6개와 `icon_discard.png` 1개를 지정 경로에 납품했다. 추가 아이콘 master도 보존했다. [전체 파일 목록](../../output/pocket-cards-v01/delivery.md) · [7개 PNG SHA-256·치수·알파](../../output/pocket-cards-v01/delivery-manifest.json).
- [전체 카드 검증](../../godot/assets/cards/verification.json) `passed=true`, 실패 0. 기존 22장 + 숲 3장 + 새 2장 = **앞면 26종+공용 뒷면, 총 27장/배포 PNG 54개**를 검증했다. 기존 숲 3장은 종전 납품 알파 기준을 보존해 검사하며, 다른 24장에는 기존 엄격한 외곽 검사를 적용한다.
- [신규 원화/배포 PNG·아이콘 검증](../../output/pocket-cards-v01/asset-verification.json) `passed=true`, 실패 0. Godot 4.7.2 패키징·아이콘 축소·헤드리스 임포트·검증·갤러리 렌더 종료 코드 0.
- [갤러리](../../godot/screenshots/cards/asset-gallery.png), README·manifest·[실제 프롬프트](../prompts/cards/pocket-cards-v01-prompts.md)를 갱신했다. 최종 배포 PNG의 제목·분류·두 줄 본문을 [1:1 픽셀 확대 시트](../../godot/screenshots/cards/pocket-cards-v01-text-proof.png)에서 직접 대조해 **오탈자 없음**을 확인했다. [검수 기록](../../art/cards/pocket-cards-v01-review.md).
- 동시 게임 작업에서 새 ID가 카탈로그에 등록되어 카탈로그 문구 대조와 로딩도 통과했다. 이 에셋 작업에서 수정 금지 경로에 쓰지 않았고 동시 변경을 되돌리지 않았다. 기존 원화·게임용 PNG 50개 해시 일치. 커밋하지 않았다. [범위 확인](../../output/pocket-cards-v01/scope-audit.json).
