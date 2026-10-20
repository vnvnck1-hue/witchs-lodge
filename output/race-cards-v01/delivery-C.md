# C 갈래 언데드 카드 납품 · 2026-10-20

최종 완료: 요청된 8장 전부 납품. 보존 원본·게임용·손패용 총 24개 PNG, 격리 임포트 텍스처 16/16 통과. `verification-C.json`의 `passed=true`, `complete=true`, `missing_ids=[]`, `below_standard_ids=[]`. 아래는 작업 중 기록이며, 동일 id가 여러 번 나오면 마지막 채택 버전이 최종본이다.

| id | 최종 채택 | 재생성 | 이유 |
| --- | --- | --- | --- |
| rise_up | v02 | 1회 | 최종 시트 비교 후 제목·분류·설명 크기 통일 |
| bone_barricade | v01 | 없음 | 첫 생성본 채택 |
| soul_jar | v02 | 1회 | 최종 시트 비교 후 제목·설명 크기 통일 |
| ghoul_feast | v02 | 1회 | 과대한 글씨 축소 |
| death_march | v02 | 1회 | 과대한 제목·설명 축소 |
| bone_hounds | v04 | 3회 | 제목·분류 위치, 배지의 설명 영역 침범, 붓글씨 마감 순서로 교정 |
| black_rumor | v02 | 1회 | 과대한 글씨 축소·분류 띠 내림 |
| ledger_of_dead | v01 | 없음 | 첫 생성본 채택 |

내장 `image_gen` 16회 사용. 매 호출에 해당 역할 승인 PNG와 같은 역할 게임 카드를 실제 입력했으며, 언데드 분위기·기존 납품본·배치 도식은 각 생성 JSON과 프롬프트 기록에 명시했다. 가공 전 16개 생성본은 모두 `art/cards/race-cards-v01/drafts/<id>-vNN.png`에 보존했다. 코드 후처리는 RGB·인쇄 글자를 바꾸지 않고 카드지 알파·라운드 모서리를 정규화했으며 손패를 1/4 균등 축소했다.

최종 시각 검수: 언데드 10장(기존 2장 포함)과 승인 6종의 비율 유지 시트를 256×384 크기로 비교했다. 한 손·흰 뼈 방책·푸른 병·구부린 구울·해골 행렬·개 두 마리·까마귀 창가·검은 장부의 실루엣이 구별된다. 제목·분류·설명은 카탈로그와 직접 대조했으며 피·살점·상처·고어는 없다. 기준 미달 id 없음. 기존 `sacrifice_dagger`·`corpse`의 원본·게임용·손패용 6개는 기존 소유 해시와 일치한다.

참고: 한국어가 인쇄된 PNG 납품이며, 다국어 동적 텍스트 구현은 포함하지 않는다. 격리 검증 로그의 원본 PNG 읽기 경고는 검증 코드가 비교용 원본을 읽을 때 발생한 것이며 텍스처 16/16 해시 검증은 통과했다. 최종 게임 임포트와 EXE는 요청대로 Claude 담당이다.

기존 납품 sacrifice_dagger·corpse는 보존. 아래 카드는 한 장씩 원본·게임용·손패용·격리 임포트까지 마친 후 기록한다. 공용 요청서·기록, 게임 임포트/실행파일·코드·카탈로그는 수정하지 않았다. 커밋 없음.

## rise_up

- 파일: `art/cards/race-cards-v01/rise_up.png`, `godot/assets/cards/rise_up.png`, `godot/assets/cards/hand/rise_up.png`.
- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 `art/cards/race-cards-v01/drafts/rise_up-v01.png`.
- 첫 생성본 채택, 재생성 없음. Exact Korean, raised skeletal hand clearly distinct; same skill frame and delivered typography; no gore.
- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.
- `import-C` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.
- 기준 미달: 없음. 현황은 `verification-C.json`, 비교 시트는 `godot/screenshots/race-cards/sheet-undead.png`.

## bone_barricade

- 파일: `art/cards/race-cards-v01/bone_barricade.png`, `godot/assets/cards/bone_barricade.png`, `godot/assets/cards/hand/bone_barricade.png`.
- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 `art/cards/race-cards-v01/drafts/bone_barricade-v01.png`.
- 첫 생성본 채택, 재생성 없음. Exact Korean; white bone-and-stake barricade distinct from stone and scrap facilities; wide facility title board and clear rules reserve; no gore.
- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.
- `import-C` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.
- 기준 미달: 없음. 현황은 `verification-C.json`, 비교 시트는 `godot/screenshots/race-cards/sheet-undead.png`.

## soul_jar

- 파일: `art/cards/race-cards-v01/soul_jar.png`, `godot/assets/cards/soul_jar.png`, `godot/assets/cards/hand/soul_jar.png`.
- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 `art/cards/race-cards-v01/drafts/soul_jar-v01.png`.
- 첫 생성본 채택, 재생성 없음. Exact Korean; sealed glass soul bottle, correct bottle resource icon, continuous rules panel, no gore.
- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.
- `import-C` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.
- 기준 미달: 없음. 현황은 `verification-C.json`, 비교 시트는 `godot/screenshots/race-cards/sheet-undead.png`.

## ghoul_feast

- 파일: `art/cards/race-cards-v01/ghoul_feast.png`, `godot/assets/cards/ghoul_feast.png`, `godot/assets/cards/hand/ghoul_feast.png`.
- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 `art/cards/race-cards-v01/drafts/ghoul_feast-v02.png`.
- 채택 버전: v02. v02 selected after one regeneration: reduced oversized title/category/rules while retaining ghoul, empty/bone plates and approved skill frame. Exact Korean; no gore.
- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.
- `import-C` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.
- 기준 미달: 없음. 현황은 `verification-C.json`, 비교 시트는 `godot/screenshots/race-cards/sheet-undead.png`.

## death_march

- 파일: `art/cards/race-cards-v01/death_march.png`, `godot/assets/cards/death_march.png`, `godot/assets/cards/hand/death_march.png`.
- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 `art/cards/race-cards-v01/drafts/death_march-v02.png`.
- 채택 버전: v02. v02 selected after one regeneration: reduced oversized title and rules; preserved skeleton procession, single blank banner, moon and skill diamond. Exact Korean, no gore.
- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.
- `import-C` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.
- 기준 미달: 없음. 현황은 `verification-C.json`, 비교 시트는 `godot/screenshots/race-cards/sheet-undead.png`.

## bone_hounds

- 파일: `art/cards/race-cards-v01/bone_hounds.png`, `godot/assets/cards/bone_hounds.png`, `godot/assets/cards/hand/bone_hounds.png`.
- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 `art/cards/race-cards-v01/drafts/bone_hounds-v04.png`.
- 채택 버전: v04. v04 selected after three corrections: reduced title, lowered category, moved skull badge above rules reserve, restored ink brush text. Two distinct clean skeletal dogs; exact Korean, no gore.
- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.
- `import-C` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.
- 기준 미달: 없음. 현황은 `verification-C.json`, 비교 시트는 `godot/screenshots/race-cards/sheet-undead.png`.

## black_rumor

- 파일: `art/cards/race-cards-v01/black_rumor.png`, `godot/assets/cards/black_rumor.png`, `godot/assets/cards/hand/black_rumor.png`.
- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 `art/cards/race-cards-v01/drafts/black_rumor-v02.png`.
- 채택 버전: v02. v02 selected after one correction: smaller brush lettering and lower category band; ravens whispering outside lodge, unreadable leaflet, continuous event rules panel. Exact Korean, no gore.
- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.
- `import-C` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.
- 기준 미달: 없음. 현황은 `verification-C.json`, 비교 시트는 `godot/screenshots/race-cards/sheet-undead.png`.

## ledger_of_dead

- 파일: `art/cards/race-cards-v01/ledger_of_dead.png`, `godot/assets/cards/ledger_of_dead.png`, `godot/assets/cards/hand/ledger_of_dead.png`.
- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 `art/cards/race-cards-v01/drafts/ledger_of_dead-v01.png`.
- 채택 버전: v01. First attempt selected: black leather closed ledger with iron clasp, candle wax and raven quill; exact Korean, approved shield window and delivered text geometry; no gore.
- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.
- `import-C` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.
- 기준 미달: 없음. 현황은 `verification-C.json`, 비교 시트는 `godot/screenshots/race-cards/sheet-undead.png`.

## rise_up

- 파일: `art/cards/race-cards-v01/rise_up.png`, `godot/assets/cards/rise_up.png`, `godot/assets/cards/hand/rise_up.png`.
- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 `art/cards/race-cards-v01/drafts/rise_up-v02.png`.
- 채택 버전: v02. v02 selected after final sheet review: reduced title/category/rules to delivered brush scale; preserved skeletal hand artwork and skill diamond. Exact Korean, no gore.
- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.
- `import-C` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.
- 기준 미달: 없음. 현황은 `verification-C.json`, 비교 시트는 `godot/screenshots/race-cards/sheet-undead.png`.

## soul_jar

- 파일: `art/cards/race-cards-v01/soul_jar.png`, `godot/assets/cards/soul_jar.png`, `godot/assets/cards/hand/soul_jar.png`.
- 원본·게임용 RGBA 1024×1536, 손패 RGBA 256×384, 라운드 모서리 바깥 투명. 가공 전 생성본은 `art/cards/race-cards-v01/drafts/soul_jar-v02.png`.
- 채택 버전: v02. v02 selected after final sheet review: reduced title and rules to match delivered cards; preserved sealed glass bottle, blue soul flame and resource icon. Exact Korean, no gore.
- 검수: 카탈로그와 제목·분류·설명 2줄 직접 대조, 역할 프레임·글 여백·중세 판타지·비잔혹 표현 확인. 파일 규격·알파·SHA-256·원본/게임 동일성·RGB 보존·균등 축소 통과.
- `import-C` 격리 프로젝트 임포트 종료 0, 임포트 텍스처 크기·알파·픽셀 해시 통과. 게임 경로에는 PNG만 저장.
- 기준 미달: 없음. 현황은 `verification-C.json`, 비교 시트는 `godot/screenshots/race-cards/sheet-undead.png`.
