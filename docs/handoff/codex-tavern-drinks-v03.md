# Codex에게 요청하는 에셋 작업 — 술 카드 2장 재제작: 기존 술 카드 포맷으로 (v03)

요청자: Claude (게임 구현 담당) · 2026-10-27 · 앞선 요청: [v02](codex-tavern-drinks-v02.md) · 카드 기준: [카드 디자인 가이드](../card-design-guide.md) · 글자 규칙: [카드 글자 런타임](../card-text-runtime.md)

## 사용자 요청 (그대로)

> 용의 숨결과 서리거인은 술 카드이기때문에, 기존 술카드들이 가지고 있는 술 이미지 포멧을 사용해야해. 술이 제대로 보여야해
> 다시 요청해

v02 에서 `dragon_breath`·`frost_giant_spirit` 를 스킬(마름모) 포맷으로 만든 것이 반려됐다. **건배!(`cheers`)와 VFX 텍스처 3장은 그대로 둔다(다시 만들지 말 것).**

## 기존 술 카드 포맷 (반드시 따를 것)

실제 이미지 참고 입력: `godot/assets/cards/fire_ale.png`, `godot/assets/cards/wisp_spirit.png`, `godot/assets/cards/golden_mead.png`, `godot/assets/cards/dew_of_forgetting.png`.

- 위 크림 이름판 · **둥근 모서리 사각 그림창** · 그림창 아래 가운데 **작은 타원 배지**(안에 같은 술병의 미니 아이콘) · 아래 하나로 이어진 크림 설명판 · 보라 바탕과 검은 웨이브 테두리.
- 그림창 안: **술병(또는 술잔) 하나가 주인공**으로 창 폭의 55~70% 크기, 살짝 기울어져 술이 병 입구에서 넘쳐 흐르며 소용돌이친다. 배경은 그 술의 색으로 물든 마법 소용돌이·연기·튀는 방울. 사람·풍경·괴물은 넣지 않는다(술이 주인공).
- 가장 쉬운 방법: `godot/assets/cards/wisp_spirit.png`(또는 `fire_ale.png`)를 편집 대상으로 삼아 **그림창 안과 배지 안 미니 아이콘만** 새로 그려 합성. 프레임·이름판·설명판·배지 테두리 픽셀은 그대로 둔다.

## 만들 카드 (원화에 글자 금지 — 게임이 그린다)

| id | 그림 내용 | 게임이 그릴 글자 |
| --- | --- | --- |
| `dragon_breath` 용의 숨결 | 주둥이가 **용머리 모양으로 조각된 두꺼운 적갈색 도기 술병**. 병 목에 감긴 헝겊 심지에 불이 붙어 있고, 기울어진 병 입구에서 **불붙은 주황·진홍 화주가 용의 숨처럼 넘쳐흘러** 불꽃 소용돌이를 그린다. 배경은 진홍·주황·검붉은 불 연기 소용돌이와 불티. 배지 안: 같은 용머리 도기 병 미니 아이콘. | 제목 `용의 숨결` · 분류 `주점 · 불 지르는 술` · 설명 `땅에 던지면 불바다가 번집니다.` / `그 위의 적은 계속 불탑니다.` |
| `frost_giant_spirit` 서리 거인의 독주 | **하얗게 서리 낀 두꺼운 푸른 유리 술병**(거인의 투박한 손자국 각인, 굵은 밧줄 손잡이, 얼음 결정 마개). 기울어진 병 입구에서 **차가운 청록 독주가 흘러나오며 공중에서 바로 뾰족한 얼음 결정으로 얼어붙는다**. 배경은 하늘색·청록·흰 서리 소용돌이와 눈송이. 배지 안: 같은 푸른 병 미니 아이콘. | 제목 `서리 거인의 독주` · 분류 `주점 · 얼리는 술` · 설명 `땅에 던지면 주변 적이` / `2초 동안 통째로 얼어붙습니다.` |

공통: 기존 술 카드 4장과 같은 화풍(수채·먹선, 큰 색면, 또렷한 윤곽, 반짝이는 유리·액체 표현). 손패 256×384 에서도 "불 술병"·"얼음 술병"이 한눈에 읽혀야 한다. 기존 술병(불꽃 에일 나무잔·도깨비불 푸른 병·꿀술 둥근 병·이슬주 각진 병)과 실루엣이 겹치지 않게.

## 반드시 지킬 것

1. **글자·숫자·기호 금지.** 제목판·분류줄·설명판은 비워 둔다.
2. 그림·배지 장식이 제목 안전 영역(x=110..914, y=72..236)과 설명 안전 영역(x=110..914, y=1185..1445)을 침범하지 않는다. 배지 위치·크기는 기존 술 카드와 같게.
3. RGBA **1024×1536**, 네 모서리 라운드·바깥 투명. 손패용은 **RGBA 256×384** 축소.
4. 중세 기반 판타지 기준(프로젝트 CLAUDE.md).

## 역할 분담·수정 금지

- **Codex 책임:** 위 2장의 생성·합성·축소·검증·기록.
- **Claude 책임:** 게임 코드·카탈로그·판 프로파일(`text_layout.json`)·검증·실행파일·커밋.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/tools/**`, `godot/assets/cards/catalog.json`, `godot/assets/cards/catalog_en.json`, `godot/assets/cards/text_layout.json`, `godot/assets/cards/packaging.json`, `godot/project.godot`, **`cheers.png`·`hand/cheers.png`·`godot/assets/vfx/**` 포함** 다른 모든 PNG, 루트 `WitchsLodge.exe`. **커밋 금지.** `git stash`·`git checkout`·`git reset` 금지. Claude 가 같은 저장소에서 동시에 작업 중이다.

## 산출물 경로

| 용도 | 경로 |
| --- | --- |
| 최종 원본 | `art/cards/tavern-v07/<id>.png` 덮어쓰기. 반려된 v02 마름모판은 `art/cards/tavern-v07/drafts/<id>_skill-format-rejected.png` 로 옮겨 보존 |
| 게임용 · 손패용 | `godot/assets/cards/<id>.png`(1024×1536) · `godot/assets/cards/hand/<id>.png`(256×384) 덮어쓰기 |
| 프롬프트 기록 | `docs/prompts/cards/tavern-v07-prompts.md` 에 `## v03 재제작` 절 추가 |
| 미리보기 시트 | `godot/screenshots/tavern-v07/drink-format-sheet.png` — 새 2장 + `fire_ale`·`wisp_spirit`·`golden_mead`·`dew_of_forgetting` 나란히, 손패 크기 줄 포함 |
| 검증 기록 | `output/tavern-v07/verification-v03.json` — 크기·채널·모서리 알파·프레임(그림창·배지 밖) 픽셀이 편집 대상과 같은지·SHA-256·`passed` |

## 완료 기준

1. 2장 × (게임용 + 손패용) 교체. 글자 없음, 모서리 바깥 투명.
2. 기존 술 카드 4장과 나란히 놓으면 같은 포맷(둥근 사각 창 + 미니 병 배지)으로 보이고, 술병과 넘치는 술이 주인공이다.
3. 검증 JSON `passed=true`, 미리보기 시트 저장.
4. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절을 붙이고 마지막 메시지에 같은 요약. 기준 미달은 숨기지 말 것.

## Codex 납품 결과 · 2026-10-27

- **완료:** `dragon_breath`·`frost_giant_spirit` 두 장만 내장 `image_gen`으로 다시 만들고, `wisp_spirit`의 **둥근 사각 그림창 + 미니 병 배지** 포맷에 합성했다. 용머리 적갈색 도기병·불붙은 헝겊 심지·넘치는 화주, 손자국이 각인된 서리 낀 푸른 유리병·밧줄 손잡이·얼음 마개·공중에서 결정으로 변하는 청록 독주를 표현했다. 사람·풍경·괴물 없이 술병이 주인공이다.
- **최종 원본:** [dragon_breath](../../art/cards/tavern-v07/dragon_breath.png) · [frost_giant_spirit](../../art/cards/tavern-v07/frost_giant_spirit.png).
- **게임용:** [dragon_breath](../../godot/assets/cards/dragon_breath.png) · [frost_giant_spirit](../../godot/assets/cards/frost_giant_spirit.png), 각각 RGBA **1024×1536**.
- **손패용:** [dragon_breath](../../godot/assets/cards/hand/dragon_breath.png) · [frost_giant_spirit](../../godot/assets/cards/hand/frost_giant_spirit.png), 각각 RGBA **256×384**.
- **반려판 보존:** [dragon_breath_skill-format-rejected.png](../../art/cards/tavern-v07/drafts/dragon_breath_skill-format-rejected.png) · [frost_giant_spirit_skill-format-rejected.png](../../art/cards/tavern-v07/drafts/frost_giant_spirit_skill-format-rejected.png). 이전 v02 검증 기록의 SHA-256과 일치한다.
- **미리보기:** [drink-format-sheet.png](../../godot/screenshots/tavern-v07/drink-format-sheet.png). 새 두 장과 기존 술 네 장을 나란히 배치하고 실제 256×384 손패 크기 줄도 포함했다.
- **생성 프롬프트:** [tavern-v07-prompts.md · v03 재제작](../prompts/cards/tavern-v07-prompts.md#v03-재제작)에 실제 입력과 합성·축소 절차를 추가했다. 생성 원본은 `art/cards/tavern-v07/drafts/<id>_drink-generated-v03.png`에 보관했다.
- **검증:** [verification-v03.json](../../output/tavern-v07/verification-v03.json) **`passed=true`**. 원본·게임용·손패용 6개 파일의 크기·RGBA·SHA-256, 네 모서리 알파 0, 원본과 게임용 바이트 일치, 반려판 보존을 확인했다. 그림창·배지 **안쪽 밖의 모든 RGBA 픽셀 차이 0**, 제목·설명 안전 영역 차이 0, 편집 대상 대비 전체 알파 차이 0이다. 제목·분류·설명은 미인쇄이며 256×384 가독성과 화풍·병 배지는 육안 검수했다.
- **수정 금지 준수:** 보호 대상 **2,872개 파일**을 작업 전후 SHA-256으로 대조해 **변경 0개**를 확인했다. `cheers`·손패 `cheers`·기존 VFX·다른 기존 카드 PNG·게임 코드·카탈로그·판 프로파일·프로젝트 설정·루트 실행파일을 수정하지 않았다. 커밋 및 `git stash`·`git checkout`·`git reset`도 하지 않았다.
- **인계:** 게임 내 글자 배치·런타임 검증·실행파일 내보내기·커밋은 요청서대로 Claude 담당이다. 이번 납품에서는 수행하지 않았다. 그림·글자 미인쇄·화풍 검수는 육안 판단이며 OCR이나 게임 내 렌더 검증을 통과했다고 주장하지 않는다.
