# Codex에게 요청하는 에셋 작업 — 종족별 직업 계약 카드 20장 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-18 · 기획: [종족 시스템 1차](../races-guests-v01.md) §3(인물 표)·§7, [카드 디자인 가이드](../card-design-guide.md)

## 목적

손님을 고용하면 그 사람의 직업 계약 카드(전투용병·사냥꾼·나무꾼·채집가)를 받는다. 지금은 어느 종족을 고용해도 **인간 카드 그림**이 나온다. 드워프·요정·고블린·수인·오크 5종족 × 4직업 = **20장**의 카드를 만들어, 고용한 손님의 종족과 실제 인물이 카드에 보이게 한다. 게임 코드는 이미 경로만 맞으면 해당 종족 카드를 쓰고, 파일이 없으면 기존 인간 카드로 대체한다.

## 역할 분담

- **Codex 책임:** 카드 20장(원본·게임용·손패용)의 생성·후처리·검증·문서화.
- **Claude 책임:** 카드 선택 코드(`scripts/ui/card_catalog.gd` `race_texture`), 카탈로그, 검증 스크립트.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/assets/cards/catalog.json`, `godot/project.godot`, 기존 `godot/assets/cards/*.png`(인간 직업 카드 포함 기존 카드는 덮어쓰지 말 것), `docs/races-guests-v01.md`. 다른 작업의 변경을 되돌리지 말 것. **커밋하지 말 것.** 다른 세션이 손패 UI(`hand_workbench`)를 동시에 작업 중이다.

## 반드시 따를 기존 기준

먼저 읽기: [카드 디자인 가이드](../card-design-guide.md)(특히 §2 인물 역할, §4 안전 영역, §6 절차, §7 검수), [역할 포맷 적용 기록](../card-role-format-rollout-v02.md), 아트 가이드 `docs/art-direction.md`, 전역 지침 `CLAUDE.md`(중세 기반 판타지).

**실제 이미지 참고 입력(필수, 매 장):**

1. **같은 직업의 현재 게임 카드** — `godot/assets/cards/warrior.png` / `hunter.png` / `lumberjack.png` / `gatherer.png`. **프레임·패널·먹선·글자 배치·인쇄 문구·하단 종족 배지의 위치와 모양을 그대로** 따른다. 바뀌는 것은 원화창의 인물·배경과 배지의 종족 아이콘·종족명뿐이다.
2. **인물 역할 승인 카드** — `art/concepts/cards/roles-individual-v02/01-character-nib.png`(고블린 배지 표현의 기준).
3. **그 인물의 손님 포트레이트(정체성 기준)** — `godot/assets/portraits/guest_<id>_cutout.png`. 얼굴·피부색·체형·머리·복장·소품·종족 특징을 유지한다(카드 화풍으로 같은 사람임이 바로 알아보이게).

공통 요건:

- **RGBA 1024×1536(2:3), 네 모서리 라운드, 모서리 바깥 투명.** 손패용은 같은 그림을 **RGBA 256×384**로 축소.
- 인쇄 문구(제목·분류·설명 2줄)는 아래 표의 직업별 문구를 **한 글자도 바꾸지 않고** 기존 인간 카드와 같은 위치·크기·서체 느낌으로. 제목 2줄·설명 4줄 안전 영역을 비워 둔다(§4).
- 하단 배지: 원형 메달 안에 **종족 아이콘** + 아래 둥근 이름표에 **종족명**(드워프 / 요정 / 고블린 / 수인 / 오크). 아이콘은 단순 실루엣 — 드워프=망치, 요정=씨앗(새싹), 고블린=고블린 얼굴(니브 카드와 같은 표현), 수인=발자국, 오크=엄니. 같은 종족 4장의 배지는 동일하게.
- 원화: 그 인물이 **직업 행동**을 하는 상반신~허리 구도(전투용병=무기와 방패로 산장 앞을 지킴, 사냥꾼=활·창으로 사냥, 나무꾼=도끼·톱으로 벌목, 채집가=바구니·주머니로 숲에서 채집). 배경은 겨울 숲·산장 주변, 종족 보조색을 포인트로(드워프 구리·암석, 요정 연두·은빛, 고블린 이끼·구리, 수인 호박·크림, 오크 붉은 흙·뼈).
- 요정은 작은 존재다: 소품(도토리·잎·버섯)의 비례로 크기를 암시하되 카드 원화창은 인물이 꽉 차게.
- 수치·가격·새 효과를 그림에 넣지 않는다. 글자는 지정 문구와 종족명뿐.

## 인쇄 문구(직업별, 이 글자 그대로)

| 직업 id | 제목 | 분류 | 설명 1줄 | 설명 2줄 |
| --- | --- | --- | --- | --- |
| `warrior` | 전투용병 | 용병 · 전투 계약 | 산장 주변을 정찰합니다. | 적이 오면 검으로 맞섭니다. |
| `hunter` | 사냥꾼 | 용병 · 사냥 계약 | 낮에는 토끼와 사슴을 사냥합니다. | 밤에는 활로 산장을 지킵니다. |
| `lumberjack` | 나무꾼 | 용병 · 벌목 계약 | 나무에 사용하면 벌목합니다. | 목재를 들고 있다가 건네줍니다. |
| `gatherer` | 채집가 | 용병 · 채집 계약 | 낮에 숲을 탐색하고 돌아옵니다. | 쓸모 있는 것을 주워 옵니다. |

## 카드 20장 — 종족 · 직업 · 인물

인물의 성격·외형 상세는 `docs/handoff/codex-race-portraits-v01.md`의 Subject 표와 포트레이트를 따른다.

| 종족(race) | warrior | hunter | lumberjack | gatherer |
| --- | --- | --- | --- | --- |
| 드워프 `dwarf` | 하랄 `harald` — 둥근 철테 방패·사슬갑옷, 벽을 두드리는 신중함 | 브륀힐드 `brynhild` — 석궁, 붉은 땋은 머리, 호탕한 웃음 | 토르그림 `thorgrim` — 도끼와 자, 나무결을 살피는 눈 | 두르가 `durga` — 이끼 바구니·광석 주머니, 투덜대는 노파 |
| 요정 `fairy` | 티슬 `thistle` — 엉겅퀴 가시 창, 도토리 투구, 격식 | 틸리아 `tilia` — 나뭇가지 활·솔잎 화살, 장난스러운 윙크 | 라르크 `larch` — 작은 톱·가지치기 가위, 엄격한 정원사 | 페른 `fern` — 씨앗 주머니·큰 민들레 씨, 수줍음 |
| 고블린 `goblin` | 그라즈 `graz` — 냄비 투구·짝짝이 고물 갑옷, 허세 | 피클 `pikl` — 덫·끈 뭉치, 매듭으로 셈 | 러스크 `rusk` — 등에 톱 세 자루, 톱을 아끼는 웃음 | 타크 `tak` — 주머니투성이 외투, 반짝이는 것 수집 |
| 수인 `beastfolk` | 파르그 `fargh` — 회색 늑대, 양손검, 찢긴 귀 | 사야 `saya` — 삵(스라소니), 짧은 활, 녹색 두건 | 우르소 `urso` — 갈색 곰, 벌목 도끼·꿀단지 | 모미 `momi` — 회갈색 토끼, 약초 바구니, 겁 많은 눈 |
| 오크 `orc` | 가로크 `garok` — 호위대장, 맹세 목걸이, 넓은 칼 | 크라냐 `kranya` — 투창, 땋은 머리에 짐승 이빨 | 모가 `moga` — 거구, 양날 도끼, 나무 부적 | 샤가 `shaga` — 견습 주술사, 뿌리·버섯 꾸러미, 재 문양 |

## 산출물 경로

| 용도 | 경로 |
| --- | --- |
| 생성 원본(보존) | `art/cards/races-v01/<race>-<job>.png` (+ 미채택 초안은 `art/cards/races-v01/drafts/`) |
| 게임용 | `godot/assets/cards/races/<race>/<job>.png` — RGBA 1024×1536 |
| 손패용 | `godot/assets/cards/races/<race>/hand/<job>.png` — RGBA 256×384 |
| 프롬프트 기록 | `docs/prompts/cards/race-job-cards-v01-prompts.md` (장마다 실제 프롬프트·참고 입력·재생성 이유) |
| 미리보기 시트 | `godot/screenshots/race-job-cards/sheet.png` — 행=종족 5, 열=직업 4, 기존 인간 4장을 첫 행에 함께 |
| 검증 기록 | `output/race-job-cards-v01/verification.json` — 파일별 크기·채널·모서리 알파·SHA-256·`passed` |

예: `godot/assets/cards/races/orc/warrior.png`, `godot/assets/cards/races/orc/hand/warrior.png`.

납품 후 `.tools/Godot-4.7.2.exe --headless --path godot --import` 를 실행해 `.import` 파일을 만든다(이미지 전용 격리 프로젝트 방식도 허용, 수정 금지 경로에 파일이 생기지 않게).

## 완료 기준

1. 20장 × (게임용 + 손패용)이 위 경로·규격으로 존재. 모서리 바깥 투명.
2. 같은 직업의 인간 카드와 프레임·글자 배치·배지 위치가 일치하고, 인쇄 문구가 표와 정확히 같다(원본 크기로 직접 확인, 오탈자 0).
3. 각 카드의 인물이 해당 손님 포트레이트와 같은 사람으로 보이고, 종족 배지 아이콘·종족명이 맞다.
4. 중세 판타지 재료, 글자 안전 영역 침범 없음, 미리보기 시트로 20장 일관성 확인.
5. `--import` 종료 코드 0, 검증 JSON `passed=true`.
6. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절(파일 목록, 재생성한 카드와 이유, 남은 문제)을 붙이고 마지막 메시지에 같은 요약. 기준 미달 카드는 숨기지 말고 id별로 적는다.

## Codex 납품 결과 · 2026-10-18

종족별 직업 계약 카드 20장 제작·검증·문서화를 완료했다.

- 생성 원본·게임용·손패용 각 20장과 프롬프트·미리보기 시트를 납품했다. 최초 생성 20회와 재생성 7회 모두 지정된 참고 이미지 3종을 실제 입력으로 사용했다.
- 게임용 1024×1536·손패용 256×384 모두 RGBA·투명 라운드 모서리 검사를 통과했다. 문구 픽셀과 종족별 배지 동일성을 확인했고, 검증 JSON은 `passed=true`다.
- Godot import 종료 코드 0·텍스처 검증 40/40·최종 Windows export 종료 코드 0이다. 루트 `WitchsLodge.exe`를 갱신하고 내장 텍스처 40개의 바이트 동일성도 확인했다.
- 요정 4장(작은 체구·소품), 파르그(양손검 경계 행동), 크라냐(투창), 모가(양날 도끼)를 재생성했다. 최종 미충족·누락 id와 남은 카드 문제는 없다.
- 수정 금지 경로를 직접 편집하거나 커밋하지 않았다. 병행 세션의 변경은 보존했다.

### 파일 목록

[전체 비교 시트](../../godot/screenshots/race-job-cards/sheet.png) · [실제 프롬프트·참고 입력·수정 이력](../prompts/cards/race-job-cards-v01-prompts.md) · [최종 실행파일](../../WitchsLodge.exe)

| 종족 | 직업 · 인물 | 생성 원본 | 1024×1536 | 256×384 |
| --- | --- | --- | --- | --- |
| dwarf | warrior · harald | [원본](../../art/cards/races-v01/dwarf-warrior.png) | [게임용](../../godot/assets/cards/races/dwarf/warrior.png) | [손패용](../../godot/assets/cards/races/dwarf/hand/warrior.png) |
| dwarf | hunter · brynhild | [원본](../../art/cards/races-v01/dwarf-hunter.png) | [게임용](../../godot/assets/cards/races/dwarf/hunter.png) | [손패용](../../godot/assets/cards/races/dwarf/hand/hunter.png) |
| dwarf | lumberjack · thorgrim | [원본](../../art/cards/races-v01/dwarf-lumberjack.png) | [게임용](../../godot/assets/cards/races/dwarf/lumberjack.png) | [손패용](../../godot/assets/cards/races/dwarf/hand/lumberjack.png) |
| dwarf | gatherer · durga | [원본](../../art/cards/races-v01/dwarf-gatherer.png) | [게임용](../../godot/assets/cards/races/dwarf/gatherer.png) | [손패용](../../godot/assets/cards/races/dwarf/hand/gatherer.png) |
| fairy | warrior · thistle | [원본](../../art/cards/races-v01/fairy-warrior.png) | [게임용](../../godot/assets/cards/races/fairy/warrior.png) | [손패용](../../godot/assets/cards/races/fairy/hand/warrior.png) |
| fairy | hunter · tilia | [원본](../../art/cards/races-v01/fairy-hunter.png) | [게임용](../../godot/assets/cards/races/fairy/hunter.png) | [손패용](../../godot/assets/cards/races/fairy/hand/hunter.png) |
| fairy | lumberjack · larch | [원본](../../art/cards/races-v01/fairy-lumberjack.png) | [게임용](../../godot/assets/cards/races/fairy/lumberjack.png) | [손패용](../../godot/assets/cards/races/fairy/hand/lumberjack.png) |
| fairy | gatherer · fern | [원본](../../art/cards/races-v01/fairy-gatherer.png) | [게임용](../../godot/assets/cards/races/fairy/gatherer.png) | [손패용](../../godot/assets/cards/races/fairy/hand/gatherer.png) |
| goblin | warrior · graz | [원본](../../art/cards/races-v01/goblin-warrior.png) | [게임용](../../godot/assets/cards/races/goblin/warrior.png) | [손패용](../../godot/assets/cards/races/goblin/hand/warrior.png) |
| goblin | hunter · pikl | [원본](../../art/cards/races-v01/goblin-hunter.png) | [게임용](../../godot/assets/cards/races/goblin/hunter.png) | [손패용](../../godot/assets/cards/races/goblin/hand/hunter.png) |
| goblin | lumberjack · rusk | [원본](../../art/cards/races-v01/goblin-lumberjack.png) | [게임용](../../godot/assets/cards/races/goblin/lumberjack.png) | [손패용](../../godot/assets/cards/races/goblin/hand/lumberjack.png) |
| goblin | gatherer · tak | [원본](../../art/cards/races-v01/goblin-gatherer.png) | [게임용](../../godot/assets/cards/races/goblin/gatherer.png) | [손패용](../../godot/assets/cards/races/goblin/hand/gatherer.png) |
| beastfolk | warrior · fargh | [원본](../../art/cards/races-v01/beastfolk-warrior.png) | [게임용](../../godot/assets/cards/races/beastfolk/warrior.png) | [손패용](../../godot/assets/cards/races/beastfolk/hand/warrior.png) |
| beastfolk | hunter · saya | [원본](../../art/cards/races-v01/beastfolk-hunter.png) | [게임용](../../godot/assets/cards/races/beastfolk/hunter.png) | [손패용](../../godot/assets/cards/races/beastfolk/hand/hunter.png) |
| beastfolk | lumberjack · urso | [원본](../../art/cards/races-v01/beastfolk-lumberjack.png) | [게임용](../../godot/assets/cards/races/beastfolk/lumberjack.png) | [손패용](../../godot/assets/cards/races/beastfolk/hand/lumberjack.png) |
| beastfolk | gatherer · momi | [원본](../../art/cards/races-v01/beastfolk-gatherer.png) | [게임용](../../godot/assets/cards/races/beastfolk/gatherer.png) | [손패용](../../godot/assets/cards/races/beastfolk/hand/gatherer.png) |
| orc | warrior · garok | [원본](../../art/cards/races-v01/orc-warrior.png) | [게임용](../../godot/assets/cards/races/orc/warrior.png) | [손패용](../../godot/assets/cards/races/orc/hand/warrior.png) |
| orc | hunter · kranya | [원본](../../art/cards/races-v01/orc-hunter.png) | [게임용](../../godot/assets/cards/races/orc/hunter.png) | [손패용](../../godot/assets/cards/races/orc/hand/hunter.png) |
| orc | lumberjack · moga | [원본](../../art/cards/races-v01/orc-lumberjack.png) | [게임용](../../godot/assets/cards/races/orc/lumberjack.png) | [손패용](../../godot/assets/cards/races/orc/hand/lumberjack.png) |
| orc | gatherer · shaga | [원본](../../art/cards/races-v01/orc-gatherer.png) | [게임용](../../godot/assets/cards/races/orc/gatherer.png) | [손패용](../../godot/assets/cards/races/orc/hand/gatherer.png) |

### 제작·검수 근거

- [생성 매니페스트](../../output/race-job-cards-v01/generation-manifest.json): 20개 인물의 입력 순서·실제 프롬프트·27회 생성 파일·시각 검수 기록. 필수 입력은 매번 같은 직업의 기존 게임 카드, 승인 니브 카드, 해당 인물 포트레이트다. [입력 검증](../../output/race-job-cards-v01/reference-verification.json)은 **27/27, passed=true**이며 세 입력의 경로와 SHA-256을 보존했다.
- [검증 JSON](../../output/race-job-cards-v01/verification.json): 원본·게임용·손패용의 크기·채널·모서리 알파·SHA-256을 기록했다. 각 묶음의 고유 파일은 20개씩이다. 생성 원본은 바이트 그대로 보존한 후처리 전 아카이브다. 배포용 40장은 카드 내부를 불투명으로 정규화하고 네 모서리 바깥만 투명하게 마감했다.
- 기존 직업 카드의 연결된 크림 패널 외곽과 그 안 글자를 함께 복원했다. 제목·분류·두 설명 줄을 원본 크기로 직접 대조하고 RGB 픽셀 해시 일치도 확인했다(비교 시 알파는 255로 정규화). 사각 글자 패치에서 발견한 합성 경계는 전체 패널 외곽 마스크로 수정했고 최종 확대본에서 해소를 확인했다. 인물의 얼굴·피부/털·머리·날개/귀·복장·소품과 직업 행동은 포트레이트와 대조했다.
- 종족마다 전투용병 생성 원본의 작은 배지를 같은 마스크로 네 장에 공용 적용했다. 드워프=망치, 요정=새싹, 고블린=니브형 고블린 얼굴, 수인=발자국, 오크=엄니다. 각 종족의 배지 픽셀 해시는 네 장 모두 하나다.
- 중세 판타지의 재료와 겨울 숲·산장 주변을 유지했다. 요정은 큰 도토리·잎·버섯과의 비례로 작은 체구를 표현했다. 제목 2줄·설명 4줄 여백을 유지하며 장식 침범·가격·수치·새 효과·추가 인물 이름은 없다. 시트는 **인간 4장 첫 행 + 종족별 5행, 직업별 4열**이다.
- [Godot import 결과](../../output/race-job-cards-v01/godot-import-result.json)·[텍스처 검사](../../output/race-job-cards-v01/godot-import-verification.json): 이미지 전용 격리 프로젝트에서 import·로드 검증 후 같은 `res://assets/cards/races/` 경로의 `.import` 40개와 CTEX/MD5 캐시를 게임에 반영했다. 엔진의 `fix_alpha_edges` 보정을 적용한 소스와 로드 텍스처의 RGBA 해시가 **40/40** 같다. 검증 대상 PNG의 파일 SHA-256도 최종 40장과 결합해 확인했다.
- [최종 export 결과](../../output/race-job-cards-v01/godot-export-result.json)·[실행파일 검사](../../output/race-job-cards-v01/executable-verification.json): 루트 `WitchsLodge.exe` **502,463,000바이트**, PE MZ·내장 PCK 형식 4·40개 카드 경로를 확인했다. PCK 안 CTEX 40개의 실제 바이트 SHA-256이 최종 검증 캐시와 일치한다. 별도 게임 실행파일·PCK·런처는 만들지 않았다.
- 최초 export는 PCK 기록 오류, 다음 시도는 임시 파일 이름 변경 오류로 실패했다. 프로젝트 격리 복사본과 [Godot의 자체 포함 편집기 모드](https://docs.godotengine.org/en/4.4/classes/class_editorpaths.html)를 사용해 캐시·설정 출력을 작업 폴더 안으로 옮겼으며, 최종 재시도는 **종료 코드 0**이다. 초기·중간 실패 로그는 `output/race-job-cards-v01/godot-export-initial-*`, `godot-export-second-*`에 보존했다. 인증서 읽기 및 import 중 사용자 설정 저장 관련 환경 메시지도 원본 로그에 남겼다.
- [작업 범위 기록](../../output/race-job-cards-v01/scope-verification.json): 작업 중 다른 세션이 수정한 보호 경로 12개를 관찰했으며 되돌리지 않았다. 최종 내보내기 전 현재 공유 프로젝트의 변경분을 격리 복사본에 갱신했다. 기존 인간 직업 카드 4장은 작업 시작 해시와 모두 같다. 직접 작성한 경로는 이 카드 세트·프롬프트·검증·시트·본 납품 절·루트 실행파일과 새 카드 import 캐시뿐이다. 손패 UI 코드를 직접 수정하지 않았고 커밋하지 않았다.
- [임시 작업 폴더 정리](../../output/race-job-cards-v01/cleanup.json): 격리 import/export 프로젝트와 임시 편집기·템플릿 복사본을 제거했다. 최종 PNG·초안·검증·로그·재실행 스크립트는 보존했다.

### 재생성 이력과 남은 문제

| 카드 id | 인물 | 재생성 | 이유 |
| --- | --- | --- | --- |
| fairy-warrior | thistle | v01 → v02 | 머리 크기의 도토리와 어깨 높이 버섯으로 작은 체구 보강, 씨껍질 방패·엉겅퀴 창 유지 |
| fairy-hunter | tilia | v01 → v02 | 큰 도토리·잎을 추가해 작은 체구 명확화, 나뭇가지 활과 윙크 유지 |
| fairy-lumberjack | larch | v01 → v02 | 큰 잎·도토리·버섯 곁에서 가지를 톱질하는 비례 보강 |
| fairy-gatherer | fern | v01 → v02 | 작은 체구 보강, 큰 민들레 씨와 씨앗 주머니 복원 |
| beastfolk-warrior | fargh | v01 → v02 | 칼집·팔짱 자세에서 양손검을 뽑아 양손으로 쥔 경계 자세로 수정 |
| orc-hunter | kranya | v01 → v02 | 활 대신 포트레이트의 투창을 던지는 사냥 자세로 수정 |
| orc-lumberjack | moga | v01 → v02 | 도끼의 두 날이 모두 보이는 양날 도끼로 수정 |

미채택 원본 7장은 [drafts](../../art/cards/races-v01/drafts/)에 보존했다. **최종 미충족·누락 id: 없음. 남은 카드 문제: 없음.** 이번 확인 범위는 PNG·Godot 텍스처 import·실행파일 내장 텍스처이며 게임 선택 코드·카탈로그·손패 UI 구현은 수정하지 않았다.

재실행 도구: [후처리·규격/문구/배지 검사와 시트](../../output/race-job-cards-v01/process-assets.ps1), [격리 import](../../output/race-job-cards-v01/import-assets.ps1), [엔진 텍스처 검사](../../output/race-job-cards-v01/verify-import.gd), [격리 export](../../output/race-job-cards-v01/export-game.ps1), [실행파일 내장 텍스처 검사](../../output/race-job-cards-v01/verify-executable.ps1).

