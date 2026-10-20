# B 갈래 납품 결과 · 2026-10-20

인간 6 · 화합 3 · 중립 2, 이번 요청 11장 전부 완료. 시작 시 해당 11장의 보존 원본은 없었으며 기존 납품 15장은 제작하거나 수정하지 않았다.

- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 총 33개 최종 PNG. 라운드 바깥 투명. 원본=게임용, 생성 RGB 보존, 손패 정확한 1/4 균등 축소.
- 제목·분류·설명 두 문장을 catalog_entries.json과 대조하고 원본 크기로 직접 검수했다. 역할 승인 PNG·현재 게임 카드·기존 납품본을 매 호출 실제 참고 입력으로 사용했다. 인간 카드는 기존 인간 외형 시트도 입력했다.
- 내장 image_gen 15회, 채택 11개·미채택 4개 모두 drafts에 보존. 마을 민병 v04, 통역사의 펜 v02, 나머지 v01 채택.
- 격리 프로젝트 `output/race-cards-v01/import-B/`에서만 임포트. 최종 --import 종료 코드 0, 텍스처 22/22 규격·알파·픽셀 해시 검증 통과. 최종 `verification-B.json`: passed=true, complete=true, delivered_count=11, missing_ids=[].
- 기준 미달 id: 없음. 게임 프로젝트에는 대상 22개 PNG만 저장. 게임 --import·임포트 캐시 복사·실행파일 갱신·커밋은 하지 않았다. 금지 코드·카탈로그·기획 문서·공용 기록은 수정하지 않았다.

## 파일 목록

| id | 원본 | 게임용 | 손패용 |
| --- | --- | --- | --- |
| `introduction_letter` | [PNG](../../art/cards/race-cards-v01/introduction_letter.png) | [PNG](../../godot/assets/cards/introduction_letter.png) | [PNG](../../godot/assets/cards/hand/introduction_letter.png) |
| `guild_writ` | [PNG](../../art/cards/race-cards-v01/guild_writ.png) | [PNG](../../godot/assets/cards/guild_writ.png) | [PNG](../../godot/assets/cards/hand/guild_writ.png) |
| `village_militia` | [PNG](../../art/cards/race-cards-v01/village_militia.png) | [PNG](../../godot/assets/cards/village_militia.png) | [PNG](../../godot/assets/cards/hand/village_militia.png) |
| `old_records` | [PNG](../../art/cards/race-cards-v01/old_records.png) | [PNG](../../godot/assets/cards/old_records.png) | [PNG](../../godot/assets/cards/hand/old_records.png) |
| `pilgrim_blessing` | [PNG](../../art/cards/race-cards-v01/pilgrim_blessing.png) | [PNG](../../godot/assets/cards/pilgrim_blessing.png) | [PNG](../../godot/assets/cards/hand/pilgrim_blessing.png) |
| `merchant_wagon` | [PNG](../../art/cards/race-cards-v01/merchant_wagon.png) | [PNG](../../godot/assets/cards/merchant_wagon.png) | [PNG](../../godot/assets/cards/hand/merchant_wagon.png) |
| `crest_banner` | [PNG](../../art/cards/race-cards-v01/crest_banner.png) | [PNG](../../godot/assets/cards/crest_banner.png) | [PNG](../../godot/assets/cards/hand/crest_banner.png) |
| `interpreter_pen` | [PNG](../../art/cards/race-cards-v01/interpreter_pen.png) | [PNG](../../godot/assets/cards/interpreter_pen.png) | [PNG](../../godot/assets/cards/hand/interpreter_pen.png) |
| `lodge_festival` | [PNG](../../art/cards/race-cards-v01/lodge_festival.png) | [PNG](../../godot/assets/cards/lodge_festival.png) | [PNG](../../godot/assets/cards/hand/lodge_festival.png) |
| `stranger_gift` | [PNG](../../art/cards/race-cards-v01/stranger_gift.png) | [PNG](../../godot/assets/cards/stranger_gift.png) | [PNG](../../godot/assets/cards/hand/stranger_gift.png) |
| `lodge_cleanup` | [PNG](../../art/cards/race-cards-v01/lodge_cleanup.png) | [PNG](../../godot/assets/cards/lodge_cleanup.png) | [PNG](../../godot/assets/cards/hand/lodge_cleanup.png) |

## 재생성

- `village_militia`: 3회 수정. v01 창 누락·작은 본문, v02 과대 글자·높은 창끝, v03 사건 접힘 탭을 교정했다. v04에서 글자·인물 아치 프레임·등불 배지·창/쇠스랑 및 글 영역을 확인했다.
- `interpreter_pen`: 1회 수정. 분류 띠를 아래로 내려 기존 장비 납품본과 맞춘 v02 채택. 그림·문구·글자 크기 유지.
- 나머지 9장: 첫 생성본 채택. 생성 이력은 `generation-B-<id>-vNN.json`, 가공 전 원본은 `art/cards/race-cards-v01/drafts/<id>-B-vNN.png`.

## 미리보기·기록

- [인간 6장](../../godot/screenshots/race-cards/sheet-human.png), [화합 3장](../../godot/screenshots/race-cards/sheet-harmony.png), [중립 2장](../../godot/screenshots/race-cards/sheet-neutral.png). 승인 역할 PNG와 256×384 동일 비율로 함께 배치해 확인했다.
- [실제 프롬프트 전체](../../docs/prompts/cards/race-cards-v01-prompts-B.md), [검증 JSON](verification-B.json), [격리 텍스처 검증](import-B/texture-verification.json), [최종 임포트 로그](import-B/import-lodge_cleanup.log).
- `complete-B.ps1`은 카드별 저장·축소·격리 임포트·검증용이다. 기존 카드가 있으면 기본 실행은 중단하며, `-Resume`은 PNG를 다시 쓰지 않고 시트·격리 임포트·검증만 갱신한다. Windows PowerShell용 UTF-8 BOM으로 저장했다.
- 한국어가 인쇄된 PNG 납품이다. 다국어 동적 텍스트 구현·번역 길이 검증은 이 작업 범위 밖이다.
