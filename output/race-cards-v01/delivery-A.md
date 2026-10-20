# 갈래 A 납품 결과 · 2026-10-20

내장 image_gen 사용. 카드별 원본·게임용·손패용 저장 후 이미지 전용 import-A에서 검증. 게임 임포트·사이드카 반영·EXE 내보내기·커밋은 수행하지 않음. 승인 역할 PNG와 같은 역할 게임 카드 및 종족 초상 시트를 매 호출에 실제 입력. 전체 진행 상태는 verification-A.json 참조. sheet-orc.png에는 완성된 오크 8장과 승인 역할 예시 4장을 비율 유지 배치했다. 전투 식량은 사용량 한도로 미생성.

## 최종 상태 — 부분 납품 8/9

- 완료: `war_drum`, `feast_table`, `blood_oath`, `bone_throw`, `victory_roar`, `ancestor_path`, `ash_sigil`, `spit_roast`. 원본·게임용·손패용 **24개 PNG**. 카드별 상세 파일 목록은 아래에 기록.
- 미완료/기준 미충족: **`battle_ration`**. 내장 image_gen 호출이 HTTP 429 `usage_limit_reached`로 거부되어 이미지가 생성되지 않았다. 세 PNG를 만들지 않았으며 임시 그림을 대신 납품하지 않았다. 실제 시도 프롬프트와 오류는 `generation-A-battle_ration-v01.json`에 보존. 다음 작업은 이 카드부터 시작하면 된다.
- 검증: 완료 24개 파일의 크기·RGBA·모서리 알파·SHA-256, 생성본 RGB 보존, 원본/게임용 동일성, 손패 균등 축소 통과. 이미지 전용 `import-A`의 최종 임포트/검증 종료 코드 모두 **0**, 텍스처 **16/16**의 규격·알파·픽셀 해시 통과. 최종 재확인에서 파일 변경 없음. `verification-A.json`의 `passed=true`는 완료 8장 범위이며, `complete=false`, `missing_ids=["battle_ration"]`로 전체 미완료를 구분한다.
- 시각 검수: 원본 크기와 `reviews-A/<id>.png`에서 제목·분류·두 문장을 카탈로그 JSON과 대조. `sheet-orc.png`에서 역할 골격·손패 크기 실루엣·작은 글자 및 분류 띠 일관성 확인. 새 PNG의 RGB·그림·글자는 후처리로 바꾸지 않았으며 알파와 축소만 수행. 다국어 동적 텍스트 검증은 이번 PNG 납품 범위 밖이다.
- 생성 이력: 성공 **16회**, 사용량 거절 **1회**. 가공 전 성공 원본 16개를 `art/cards/race-cards-v01/drafts/A-<id>-vNN.png`에 보존.
- 재생성: `war_drum` **4회**(과대 제목/본문, 분류 상향·과도 하향, 마름모 설명 침범 미채택; v05 채택), `blood_oath` **1회**(제목 축소·분류 하향; v02), `bone_throw` **2회**(글자 크기와 사건 분류 높이; v03), `victory_roar` **1회**(제목만 축소; v02). `feast_table`, `ancestor_path`, `ash_sigil`, `spit_roast`는 첫 생성 채택.
- 기록: [프롬프트](../../docs/prompts/cards/race-cards-v01-prompts-A.md), [검증 JSON](verification-A.json), [미리보기](../../godot/screenshots/race-cards/sheet-orc.png), [격리 임포트](import-A/). 기존 갈래 A 프롬프트 내용은 유지하고 이번 시도들을 이어 썼다.
- 병렬 작업 경계: 지정 9개 id 외 카드·공용 기록·요청서·기획서·게임 코드·catalog·scenes를 수정하지 않았다. 게임 경로에는 PNG만 저장했고 격리 캐시나 `.import`를 복사하지 않았다. Claude가 최종 게임 임포트와 실행파일을 갱신한다. 로컬 Godot의 루트 인증서 저장소 오류와 검수용 원본 이미지 읽기 경고는 격리 임포트/검증 통과에 영향이 없었다.

## war_drum · v05

- 원본: art/cards/race-cards-v01/war_drum.png
- 게임용: godot/assets/cards/war_drum.png
- 손패용: godot/assets/cards/hand/war_drum.png
- 규격: RGBA 1024×1536 / 손패 RGBA 256×384, 모서리 바깥 투명, 원본·게임용 동일. RGB 보존 및 균등 축소 검증.
- 선정 사유: 기존 납품에 사용된 글자 축소·분류 하향 지시 적용
- 검수: 제목·분류·본문 원본에서 대조. dream_journal 수준의 작은 글자·빈 여백, 북과 뼈 북채 구별. 마름모 끝은 설명 안전 영역 위 종료.
- 격리 임포트 종료 코드: 0 / 텍스처 검증: 0. 기준 통과: True.

## feast_table · v01

- 원본: art/cards/race-cards-v01/feast_table.png
- 게임용: godot/assets/cards/feast_table.png
- 손패용: godot/assets/cards/hand/feast_table.png
- 규격: RGBA 1024×1536 / 손패 RGBA 256×384, 모서리 바깥 투명, 원본·게임용 동일. RGB 보존 및 균등 축소 검증.
- 선정 사유: 첫 생성 채택: dark_ale의 작은 글자·분류 높이와 자원 골격 일치
- 검수: 잔칫상/오크 · 함께 먹기/두 문장 직접 대조. 긴 상·큰 솥·그릇의 구도, 엄니 천, 솥 자원 표식. 설명 안전 영역에 장식 없음.
- 격리 임포트 종료 코드: 0 / 텍스처 검증: 0. 기준 통과: True.

## blood_oath · v02

- 원본: art/cards/race-cards-v01/blood_oath.png
- 게임용: godot/assets/cards/blood_oath.png
- 손패용: godot/assets/cards/hand/blood_oath.png
- 규격: RGBA 1024×1536 / 손패 RGBA 256×384, 모서리 바깥 투명, 원본·게임용 동일. RGB 보존 및 균등 축소 검증.
- 선정 사유: 제목 축소·분류 하향으로 꿈 기록장 수준의 빈 여백 확보
- 검수: 피의 맹세/오크 · 계약 변형/두 문장 대조. 붉은 물감 손자국과 끈의 큰 엄니, 피·상처 없음. 방패형과 작은 제목·하향 분류 및 설명 여백 확인.
- 격리 임포트 종료 코드: 0 / 텍스처 검증: 0. 기준 통과: True.

## bone_throw · v03

- 원본: art/cards/race-cards-v01/bone_throw.png
- 게임용: godot/assets/cards/bone_throw.png
- 손패용: godot/assets/cards/hand/bone_throw.png
- 규격: RGBA 1024×1536 / 손패 RGBA 256×384, 모서리 바깥 투명, 원본·게임용 동일. RGB 보존 및 균등 축소 검증.
- 선정 사유: 사건 납품 forest_promise와 분류 띠 높이 조정
- 검수: 뼈 던지기/사건 · 오크/두 문장 대조. 오크 노파·가죽 위 점뼈·모닥불, 적갈 의복과 엄니. 사건 포맷 및 단일 패널 유지, 분류 높이 forest_promise 수준. 제목과 본문은 요정 사건 카드와 같은 계열.
- 격리 임포트 종료 코드: 0 / 텍스처 검증: 0. 기준 통과: True.

## victory_roar · v02

- 원본: art/cards/race-cards-v01/victory_roar.png
- 게임용: godot/assets/cards/victory_roar.png
- 손패용: godot/assets/cards/hand/victory_roar.png
- 규격: RGBA 1024×1536 / 손패 RGBA 256×384, 모서리 바깥 투명, 원본·게임용 동일. RGB 보존 및 균등 축소 검증.
- 선정 사유: 제목 축소로 전쟁 북과 같은 작은 글자 크기 확보
- 검수: 승리의 함성/오크 · 처치 연쇄/두 문장 대조. 작은 제목·분류·본문은 전쟁 북과 일치. 포효 얼굴·엄니·입김으로 북과 구별, 마름모 끝 안전 영역 위 종료.
- 격리 임포트 종료 코드: 0 / 텍스처 검증: 0. 기준 통과: True.

## ancestor_path · v01

- 원본: art/cards/race-cards-v01/ancestor_path.png
- 게임용: godot/assets/cards/ancestor_path.png
- 손패용: godot/assets/cards/hand/ancestor_path.png
- 규격: RGBA 1024×1536 / 손패 RGBA 256×384, 모서리 바깥 투명, 원본·게임용 동일. RGB 보존 및 균등 축소 검증.
- 선정 사유: 첫 생성 채택: 사건 골격·분류 높이 및 새벽 능선 장면 일치
- 검수: 조상의 길/사건 · 오크/두 문장 대조. 돌무더기 눈길·오크 등짐 순례자 뒷모습·새벽빛으로 뼈 던지기의 모닥불과 구별. 제목과 설명 여백·넓은 사건 패널 유지.
- 격리 임포트 종료 코드: 0 / 텍스처 검증: 0. 기준 통과: True.

## ash_sigil · v01

- 원본: art/cards/race-cards-v01/ash_sigil.png
- 게임용: godot/assets/cards/ash_sigil.png
- 손패용: godot/assets/cards/hand/ash_sigil.png
- 규격: RGBA 1024×1536 / 손패 RGBA 256×384, 모서리 바깥 투명, 원본·게임용 동일. RGB 보존 및 균등 축소 검증.
- 선정 사유: 첫 생성 채택: 작은 글자·방패 골격 및 회색 가죽 부적 구별 성공
- 검수: 재로 그린 문양/장비 · 장신구 · 오크/두 문장 대조. 회색 가죽·재 엄니·아래 숯 조각, 붉은 엄니 카드와 실루엣·색 구별. 제목·설명 여백과 방패 끝 확인.
- 격리 임포트 종료 코드: 0 / 텍스처 검증: 0. 기준 통과: True.

## spit_roast · v01

- 원본: art/cards/race-cards-v01/spit_roast.png
- 게임용: godot/assets/cards/spit_roast.png
- 손패용: godot/assets/cards/hand/spit_roast.png
- 규격: RGBA 1024×1536 / 손패 RGBA 256×384, 모서리 바깥 투명, 원본·게임용 동일. RGB 보존 및 균등 축소 검증.
- 선정 사유: 첫 생성 채택: 솥·긴 상과 구별되는 꼬챙이 구이 및 자원 골격·작은 글자 일치
- 검수: 통구이/오크 · 잔치 요리/두 문장 대조. 꼬챙이 하나의 대각 세로 구도와 구운 고기·기름 불꽃, 생살·피 없음. 식탁·통과 실루엣 구별, 단일 자원 표식과 깨끗한 설명 여백.
- 격리 임포트 종료 코드: 0 / 텍스처 검증: 0. 기준 통과: True.
