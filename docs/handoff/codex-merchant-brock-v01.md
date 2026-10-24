# Codex에게 요청하는 에셋 작업 — 떠돌이 행상 브로크 초상 + 상점 UI 소재 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-24 · 기획: [떠돌이 행상 상점](../merchant-shop-v01.md)

## 사용자 요청 (그대로)

> 이제 상인 캐릭터를 하나 만들어서 추가하고 싶어. 이 캐릭터는 3일에 한번씩 산장에 방문하도록 해주고, 낮 중간쯤에 혼자 방문하게 해줘.
> 상인이 방문하면 상점이 열리고, 총 5개의 카드를 상인이 보여줘. 이 카드들은 기본적으로 랜덤으로 등장하며 (인물카드는 등장하지 않음) 가치에 따라 가격이 정해지도록 해줘.
> 필요한 에셋이 있으면 코덱스에게 요청해.

## 인물 — 브로크 (Brock)

- **오소리 수인(beastfolk) 떠돌이 행상.** 사흘마다 같은 숲길을 도는 중년 남성. 장사꾼답게 셈이 빠르지만 정직하고, 숲의 소문보다 물건 값을 먼저 말하는 실리파. 말투는 느긋하고 능청스럽다.
- 외형: 흑백 줄무늬가 또렷한 오소리 얼굴(검은 바탕에 이마에서 코끝까지 흰 줄, 눈가 검은 띠), 작고 둥근 귀, 단단하고 넓은 체격, 짧고 굵은 앞발 같은 손. 작은 둥근 안경(쇠테)을 코끝에 걸침.
- 복식(중세 기반 판타지 행상): 짙은 겨자색 누빈 조끼 위에 해진 고동색 여행 망토, 목에 붉은 체크 아닌 **무지 적갈색 목도리**, 허리에 동전 주머니 여러 개와 작은 놋쇠 저울, 등에 **나무 지게(배낭 틀)** — 묶은 꾸러미·말린 약초 다발·작은 등불이 매달려 있다(초상에서는 어깨 너머로 지게 윗부분과 등불이 보이는 정도).
- 표정: 반쯤 웃는 능청스러운 얼굴, 한 손으로 카드 한 장(뒷면만, 무늬·글자 없음)을 부채처럼 슬쩍 내미는 "보고 가시겠소?" 동작.
- 기존 수인 손님과 구별: 루카(여우·호박색 망토)·파르그(늑대)와 겹치지 않게 **흑백 오소리 얼굴 + 겨자/고동 색면 + 지게**가 실루엣을 만든다.

## 요청 에셋

| # | 용도 | 경로 | 규격 |
| --- | --- | --- | --- |
| A | 손님 초상(도착 소개·말풍선 메달·관리창·상점 화면 왼쪽) | `godot/assets/portraits/guest_brock_cutout.png` | RGBA **1122×1402**, 진짜 투명 배경, 상반신(가슴~허리 위) 3/4 회전, 머리 위 여백 |
| B | 상점 좌판(카드 5장이 그 위에 서는 나무 진열대) | `godot/assets/ui/merchant/stall_board.png` | RGBA **1800×360**, 투명 배경. 가로로 긴 낡은 나무 판대 앞에 짙은 천(남보라 또는 적갈색)이 드리워진 행상 좌판. 가운데는 비교적 평평·단순해서 위에 카드가 올라가도 읽혀야 함 |
| C | 가격표(카드 아래 가격 글자를 게임이 씀) | `godot/assets/ui/merchant/price_tag.png` | RGBA **240×96**, 투명 배경. 끈 구멍이 있는 작은 양피지 꼬리표, 왼쪽에 놋쇠 동전 하나, **오른쪽 2/3는 비어 있는 밝은 종이**(글자 자리) |
| D | 상점 간판(제목 글자를 게임이 씀) | `godot/assets/ui/merchant/sign_board.png` | RGBA **900×180**, 투명 배경. 두 줄 쇠사슬에 매달린 나무 간판, 가장자리만 장식(쇠 모서리·작은 오소리 발자국 낙인 정도), **가운데 넓게 비어 있음** |

### 공통 규칙

- **글자·숫자·기호 금지(모든 PNG).** 상점 제목·가격·카드 이름은 게임이 BM 을지로체로 그린다(사용자 확정 2026-10-20 카드 글자 규칙과 같은 원칙).
- 중세 기반 판타지(`CLAUDE.md`), 기존 초상·카드의 화풍: 검은 먹선, 큰 명암 색면, 페인터리 질감, 따뜻한 호박빛 + 차가운 라벤더 림라이트. 사실적·애니메이션풍 금지.
- A 초상은 기존 손님 초상과 나란히 놓여도 같은 묶음으로 보여야 한다. 신체·소품이 캔버스 가장자리에 잘리지 않게(옷 맨 아래만 잘려도 됨). 머리털 가장자리에 색 번짐(halo) 없게.
- B·C·D 는 UI 소재이므로 그림자·빛 방향이 단순하고, 반투명 가장자리가 깨끗해야 한다. 어두운 게임 화면(남보라 반투명 막) 위에 놓인다.

## 참고 입력 (실제 이미지 입력으로 사용)

- 화풍 1순위: `godot/assets/portraits/guest_luka_cutout.png`(여우 수인), `godot/assets/portraits/guest_fargh_cutout.png`(늑대 수인), `godot/assets/portraits/guest_bram_cutout.png`(승인 브람 v02 화풍).
- 상인 분위기: `godot/assets/portraits/guest_nib_cutout.png`(고블린 행상), `godot/assets/portraits/guest_sera_cutout.png`(교역상) — **이 둘과 다른 인물**이어야 한다.
- UI 재질 참고: `godot/assets/ui/chest_closed.png`(나무·쇠 재질), `godot/assets/ui/hand_workbench/` 의 나무 판 소재.
- 기준 문서: `CLAUDE.md`, `docs/art-direction.md`, `docs/races-guests-v01.md`(수인 손님), `godot/assets/portraits/README.md`.

## 역할 분담·수정 금지

- **Codex 책임:** 위 4개 PNG 생성·투명 정리·규격 맞춤·검증·기록.
- **Claude 책임:** 게임 코드·프로필·상점 화면·검증 스크립트·`.import`·실행파일 내보내기·커밋. 파일이 없으면 게임은 익명 실루엣·단색 패널로 대신 그리므로, 납품 즉시 자동으로 바뀐다.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/assets/cards/**`, `godot/project.godot`, 다른 초상 PNG, 루트 `WitchsLodge.exe`. 다른 작업의 변경을 되돌리지 말 것. **커밋하지 말 것.** `git stash`·`git checkout`·`git reset` 금지. 다른 세션이 같은 저장소에서 동시에 작업 중이다.

## 산출물 경로 (위 표 외)

| 용도 | 경로 |
| --- | --- |
| 생성 원본·미채택 초안 | `art/portraits/merchant-brock-v01/`(원본·초안), `art/ui/merchant-v01/`(UI 원본·초안) |
| 프롬프트 기록 | `docs/prompts/merchant-brock-v01-prompts.md` — 실제로 쓴 프롬프트 전문·재생성 이유 |
| 미리보기 | `godot/screenshots/merchant/codex-sheet-v01.png` — 초상 + 기존 수인 초상 2장 나란히, 좌판 위에 카드 5장(기존 카드 PNG 아무거나)·가격표·간판을 어두운 배경에 얹은 합성 미리보기 |
| 검증 기록 | `output/merchant-brock-v01/verification.json` — 파일별 크기·채널·네 모서리 알파·투명 비율·SHA-256·`passed` |

## 완료 기준

1. 4개 PNG 가 위 규격(크기·RGBA·투명 배경)으로 존재하고, 글자·숫자가 없다.
2. 초상이 기존 손님 초상과 같은 화풍이며 오소리 수인 행상(흑백 얼굴·안경·지게·동전 주머니)이 한눈에 읽힌다.
3. 가격표·간판의 비어 있는 글자 자리가 충분히 넓고 밝아 게임 글자를 얹을 수 있다.
4. 검증 JSON `passed=true`, 미리보기 시트 저장.
5. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절(파일 목록, 재생성 이유, 남은 문제)을 붙이고 마지막 메시지에 같은 요약. 기준 미달은 숨기지 말고 항목별로 적는다.

## Codex 납품 결과 · 2026-10-24

요청한 PNG 4종을 내장 `image_gen`으로 제작했다. 위에 지정된 초상 5장과 UI 재질 PNG 2장을 실제 `referenced_image_paths` 입력으로 사용했으며, 초상 보정과 간판 재생성에도 해당 초안 PNG를 실제 이미지 입력했다.

### 납품 파일

| 구분 | 파일 | 규격·검수 |
| --- | --- | --- |
| A 초상 | [guest_brock_cutout.png](../../godot/assets/portraits/guest_brock_cutout.png) | 1122×1402, RGBA, 투명 비율 35.44% |
| B 좌판 | [stall_board.png](../../godot/assets/ui/merchant/stall_board.png) | 1800×360, RGBA, 투명 비율 16.54% |
| C 가격표 | [price_tag.png](../../godot/assets/ui/merchant/price_tag.png) | 240×96, RGBA, 투명 비율 45.86% |
| D 간판 | [sign_board.png](../../godot/assets/ui/merchant/sign_board.png) | 900×180, RGBA, 투명 비율 47.91% |
| 합성 미리보기 | [codex-sheet-v01.png](../../godot/screenshots/merchant/codex-sheet-v01.png) | 2400×2000. 브로크·루카·파르그 비교, 카드 5장·좌판·가격표·간판의 어두운 배경 합성 |
| 검증 기록 | [verification.json](../../output/merchant-brock-v01/verification.json) | `passed=true`. 파일별 크기·RGBA·모서리 알파·투명 비율·알파 경계·SHA-256, 빈 글자 영역과 시각 검수 기록 |
| 실제 프롬프트 | [merchant-brock-v01-prompts.md](../prompts/merchant-brock-v01-prompts.md) | 6회 호출 전문·실제 입력 PNG·재생성 이유·규격 처리 방식 |
| 초상 생성 원본·초안 | [merchant-brock-v01/](../../art/portraits/merchant-brock-v01/) | `brock-generated-v01.png` 미채택, `brock-generated-v02.png` 채택 |
| UI 생성 원본·초안 | [merchant-v01/](../../art/ui/merchant-v01/) | `stall-generated-v01.png`, `price-generated-v01.png`, `sign-generated-v01.png` 미채택, `sign-generated-v02.png` 채택 |
| 참고 파일 기준 해시 | [reference-baseline.json](../../output/merchant-brock-v01/reference-baseline.json) | 참고 PNG·프로젝트 설정·실행파일의 작업 중 기준 해시 |

### 재생성·마감 이유

- 초상은 첫 생성에서 생긴 해/꽃 모양 브로치 각인을 없애기 위해 1회 보정했다. 최종은 무늬 없는 놋쇠 잠금장치이며 카드 뒷면도 비어 있다.
- 간판은 첫 생성의 긴 쇠사슬과 높은 실루엣을 낮추고 가운데 글자 자리를 정돈하기 위해 1회 재생성했다. 발자국 낙인은 선택 장식이므로 공통 기호 금지 조건을 우선해 생략했다.
- 생성 배경의 알파 1/255 이하 미세 잔여 픽셀만 투명 처리했다. 그 외 생성 알파와 초상 크기·구도를 유지했으며 UI는 실루엣 기준 균등 배율로 지정 캔버스 안에 배치했다. 배경색 키잉·비균등 변형은 하지 않았다.

### 완료 기준 확인·남은 문제

1. PNG 4종 모두 지정 규격의 8비트 RGBA이며 네 모서리 알파는 모두 0, 비투명한 캔버스 테두리 픽셀은 0이다. 글자·숫자·기호가 없는 것을 직접 확인했다.
2. 초상의 흑백 오소리 얼굴·둥근 안경·지게·등불·동전 주머니·놋쇠 저울·무지 카드와 기존 수인 초상과의 화풍 일치를 확인했다. 신체·소품의 잘림이나 배경색 번짐은 발견하지 않았다.
3. 가격표 오른쪽과 간판 중앙에 밝은 빈 영역을 확보했다. 가격표 권장 글자 영역은 `(87,29,132,36)`, 간판은 `(135,77,630,50)`이며 BM 을지로체를 별도 레이어로 얹어 가독성을 확인했다. 좌표는 각 PNG의 `x,y,width,height`다.
4. 검증 JSON `passed=true`와 합성 시트를 저장했다. 시트의 제목·가격은 합성용 별도 레이어이며 PNG 4종에 포함되지 않는다. 기존 카드·폰트·참고 PNG는 읽기만 했다.
5. 에셋 기준 미달이나 남은 에셋 문제는 발견하지 않았다. 게임 실행·상점 동작·`.import`·실행파일 반영 검증은 요청서의 Claude 담당 범위로 남는다. 합성 시트는 게임 실행 캡처가 아니다.

Codex는 수정 금지 경로에 쓰지 않았고 Godot 실행·내보내기·커밋·stash·checkout·reset을 수행하지 않았다. 기존 변경을 되돌리지 않았다. 참고 PNG와 `project.godot`는 기준 해시와 일치했다. 루트 실행파일은 동시 작업 중 기준 해시와 달라진 것을 관찰했으며, Codex가 덮어쓰거나 복원하지 않았다.

