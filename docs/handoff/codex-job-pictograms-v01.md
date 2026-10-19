# Codex에게 요청하는 에셋 작업 — 용병 직업 픽토그램 4종 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-19 · 기획: [장착 장비 · 용병 초상 메달](../equipment-and-party-frames-v01.md) §2

## 배경

메인 화면 오른쪽 가장자리에 고용한 용병의 **둥근 초상 메달**이 세로로 늘어선다. 메달 왼쪽 위에 작은 원형 배지로 직업을 표시하는데, 지금은 "전·사·벌·채" 글자다. 사용자 요청(2026-10-19): **글자 대신 직업 픽토그램**으로 바꾼다.
게임 코드는 아래 경로에 그림이 있으면 그림을, 없으면 글자를 그린다. 배지 원(직업 색 바탕 + 금빛 테)은 게임이 그리고, 픽토그램은 그 원 **안쪽에 얹는 그림**이다.

## 역할 분담

- **Codex 책임:** 픽토그램 4개의 생성·후처리·검증·문서화.
- **Claude 책임:** 게임 코드·검증 스크립트·실행파일 내보내기.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/tools/**`, `godot/assets/cards/**`, `godot/project.godot`, 루트 `WitchsLodge.exe`, 기존 `godot/assets/ui/**` 파일(이번 4개 외). 다른 작업의 변경을 되돌리지 말 것. **커밋하지 말 것.** Claude와 다른 세션이 같은 저장소에서 동시에 작업 중이다.

## 반드시 따를 기준

먼저 읽기: 전역 지침 `CLAUDE.md`(중세 기반 판타지), 아트 가이드 `docs/art-direction.md`.

**실제 이미지 참고 입력(필수):**

1. 기존 UI 아이콘 — `godot/assets/ui/icons/icon_timber.png`, `icon_raw_meat.png`, `icon_moonlit_charm.png` (선 굵기·색감)
2. 직업 계약 카드 — `godot/assets/cards/hand/warrior.png`, `hunter.png`, `lumberjack.png`, `gatherer.png` (직업의 도구·분위기)
3. 현재 화면 — `godot/screenshots/party-frames/medallion-right-hover.png` (배지 크기·배경 대비 확인용: 메달 왼쪽 위 작은 원)

## 픽토그램 4종

| 파일 | 직업 | 그림 |
| --- | --- | --- |
| `godot/assets/ui/jobs/warrior.png` | 전투용병 | 곧게 선 장검 한 자루 + 둥근 나무 방패(검이 방패 앞을 비스듬히 지남) |
| `godot/assets/ui/jobs/hunter.png` | 사냥꾼 | 당긴 장궁과 화살 한 대(화살촉이 오른쪽 위) |
| `godot/assets/ui/jobs/lumberjack.png` | 나무꾼 | 외날 도끼 한 자루(자루 비스듬히, 날이 크게) |
| `godot/assets/ui/jobs/gatherer.png` | 채집가 | 엮은 바구니에 버섯·약초 잎이 솟은 모양 |

공통 요건:

- **RGBA 128×128, 배경 완전 투명.** 원·테두리·바탕을 그리지 않는다(게임이 그린다). 그림은 가운데에 두고 바깥 여백 약 10px.
- **실루엣이 굵고 단순할 것** — 게임에서 약 20px로 줄어든다. 20px로 축소해도 네 직업이 한눈에 구별되어야 한다. 가는 선·작은 장식·그라데이션 디테일 금지.
- 색: **크림색 본체**(약 `#FCE7B0`) + **짙은 먹선 외곽**(약 `#2A1A12`, 128px 기준 5~7px). 강조 색은 최대 하나(도끼날·화살촉의 은빛, 버섯의 붉은 갓 정도). 어두운 남보라·주황·초록·연보라 배지 바탕 어디 위에서도 읽혀야 한다.
- 글자·숫자 금지. 중세 기반 판타지의 도구(총·현대 물건 금지).
- 네 개가 같은 선 굵기·같은 화풍·같은 크기감으로 한 벌이어야 한다.

## 산출물 경로

| 용도 | 경로 |
| --- | --- |
| 게임용 | `godot/assets/ui/jobs/{warrior,hunter,lumberjack,gatherer}.png` — RGBA 128×128 |
| 생성 원본·초안 | `art/ui/job-pictograms-v01/` (+ `drafts/`) |
| 프롬프트 기록 | `docs/prompts/ui/job-pictograms-v01-prompts.md` |
| 미리보기 시트 | `godot/screenshots/party-frames/job-pictograms-sheet.png` — 128px 원본 4개 + **20px 축소본 4개를 네 직업 배지 색 원 위에 얹은 모습**(전투 `#FF8573`, 사냥 `#8CEBB3`, 벌목 `#FFC766`, 채집 `#C7B8FF`를 35% 어둡게 한 바탕) |
| 검증 기록 | `output/job-pictograms-v01/verification.json` — 파일별 크기·채널·네 모서리 알파 0·SHA-256·`passed` |

납품 후 `.tools/Godot-4.7.2.exe --headless --path godot --import` 를 실행해 `.import` 파일을 만든다. 실행파일은 내보내지 않는다.

## 완료 기준

1. 4개 파일이 위 경로·규격(RGBA 128×128, 투명 배경)으로 존재.
2. 20px 축소본에서도 네 직업이 구별된다(미리보기 시트로 직접 확인).
3. 같은 선 굵기·화풍의 한 벌, 글자 없음, 중세 판타지 도구.
4. `--import` 종료 코드 0, 검증 JSON `passed=true`.
5. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절(파일 목록, 재생성한 것과 이유, 남은 문제)을 붙이고 마지막 메시지에 같은 요약.

## Codex 납품 결과 · 2026-10-19

**픽토그램 4종 납품 완료.** 내장 `image_gen.imagegen`으로 직업별 이미지를 생성했고, 요청서의 참고 이미지 8장을 모두 실제 이미지 입력으로 사용했다. 호출당 5장 제한에 맞춰 공통 UI 아이콘 3장 + 해당 직업 계약 카드 1장 + 현재 화면 1장을 각 호출에 전달했다. 처음 8장을 한 번에 전달한 요청은 도구의 인자 검사에서 거절되어 생성되지 않았다. 외부 API·CLI 생성은 사용하지 않았다.

### 파일 목록

| 용도 | 납품 파일 |
| --- | --- |
| 전투용병 | [warrior.png](../../godot/assets/ui/jobs/warrior.png) — 장검 + 둥근 나무 방패 |
| 사냥꾼 | [hunter.png](../../godot/assets/ui/jobs/hunter.png) — 당긴 장궁 + 오른쪽 위 화살촉 |
| 나무꾼 | [lumberjack.png](../../godot/assets/ui/jobs/lumberjack.png) — 비스듬한 자루 + 큰 외날 도끼 |
| 채집가 | [gatherer.png](../../godot/assets/ui/jobs/gatherer.png) — 버섯·약초 잎이 솟은 바구니 |
| 임포트 메타데이터 | 위 PNG와 같은 경로의 `warrior.png.import`, `hunter.png.import`, `lumberjack.png.import`, `gatherer.png.import` |
| 생성 원본 4장 | [원본 폴더](../../art/ui/job-pictograms-v01/)의 `warrior-generated.png`, `hunter-generated.png`, `lumberjack-generated.png`, `gatherer-generated.png` — 1280×1280 원본 보존 |
| 후처리 재현 | [prepare-delivery.ps1](../../art/ui/job-pictograms-v01/prepare-delivery.ps1) — 색면 정리·리사이즈·미리보기 및 규격 검사 |
| 실제 프롬프트·입력 목록 | [job-pictograms-v01-prompts.md](../prompts/ui/job-pictograms-v01-prompts.md) |
| 128px·20px 미리보기 | [job-pictograms-sheet.png](../../godot/screenshots/party-frames/job-pictograms-sheet.png) |
| 검증 JSON | [verification.json](../../output/job-pictograms-v01/verification.json) — **`passed=true`** |
| 원본 해시 | [source-manifest.json](../../output/job-pictograms-v01/source-manifest.json) |
| 임포트 로그 | [표준 출력](../../output/job-pictograms-v01/godot-import.log), [표준 오류](../../output/job-pictograms-v01/godot-import.stderr.log), [종료 코드](../../output/job-pictograms-v01/godot-import-exit-code.txt) |

### 후처리·검수

- 최종 4장 모두 **PNG RGBA 128×128**, 네 모서리와 전체 바깥 테두리의 알파가 0이다. PNG의 실제 색상 유형 6(RGBA), 크기, SHA-256을 검증 JSON에 기록했다.
- 생성 원본의 알파를 보존하고 미세한 색 변화를 크림색 `#FCE7B0`·먹선 `#2A1A12`·직업별 최대 한 가지 강조색으로 단순화했다. 긴 변 108px로 균등 축소 후 중앙에 배치했다. 사방 약 10px 이상 투명 여백을 확보했고, 별도 원·테·바탕은 게임 PNG에 넣지 않았다.
- 미리보기 시트를 직접 열어 **20px에서 검/방패·활·외날 도끼·버섯 바구니가 구별됨**을 확인했다. 각 직업의 지정 배지색을 35% 어둡게 한 바탕, 네 배지색 교차 배치, 어두운 남보라 바탕을 함께 점검했다. 글자·숫자 없이 같은 먹선 화풍과 중세 판타지 도구로 구성했다.
- `.tools/Godot-4.7.2.exe --headless --path godot --import` **종료 코드 0**. 4개 `.import`와 각 `.ctex` 캐시가 존재한다. 사용자 설정 디렉터리 권한 오류를 피하기 위해 최종 임포트 프로세스의 `APPDATA`·`LOCALAPPDATA`만 `output/job-pictograms-v01/runtime-data/` 아래로 지정했다.

### 재생성·남은 문제·작업 범위

- **재생성 없음.** 각 직업의 첫 생성 결과를 채택하고, 규격·팔레트·여백 후처리만 했다. 폐기 시안은 없다.
- **에셋 납품의 미해결 문제 없음.** 최종 임포트 표준 오류에 `Failed to read the root certificate store.` 환경 경고가 남아 있다. 임포트 종료 코드는 0이며 4개 텍스처 캐시 생성에 영향이 없었다.
- 수정 금지 경로를 직접 수정하지 않았고 **커밋·실행파일 내보내기를 하지 않았다.** 루트 `WitchsLodge.exe`와 기존 UI 에셋의 해시는 유지됐다.
- 동시 작업 중인 `godot/scripts/ui/party_frame.gd`, `godot/tools/capture_party_frames.gd`, `godot/tools/equipment_check.gd`의 변경은 임포트 전부터 관측됐으며 그대로 보존했다. 보호 경로 1,297개 중 이 3개 외 1,294개는 시작 시점과 같은 SHA-256이다. 관측 목록은 `output/job-pictograms-v01/protected-changes-before-import.json` 및 `protected-changes-after-import.json`에 보존했다.
