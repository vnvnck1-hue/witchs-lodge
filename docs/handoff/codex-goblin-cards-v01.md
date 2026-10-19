# Codex에게 요청하는 에셋 작업 — 고블린 카드 13장 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-19 · 기획: [덱 방향성 §4.1 고블린(1차 검수 완료)](../deck-archetypes-v01.md) · 적용 기록: [고블린 카드 v01](../goblin-cards-v01.md) · 카드 기준: [카드 디자인 가이드](../card-design-guide.md)

## 배경

고블린 용병을 많이 고용하면 고블린 용병이 이벤트를 일으켜 고블린 카드를 준다(종족 = 덱 방향). 고블린 카드 13장이 게임 코드·카탈로그에 이미 들어가 있지만 **카드 그림 파일이 없어 지금은 카드 뒷면으로 보인다.** 이번 작업으로 정식 원화를 만들어 아래 경로에 **새로 저장**한다. 게임 코드는 경로만 맞으면 그림을 그대로 쓴다.

## 역할 분담

- **Codex 책임:** 카드 13장(원본·게임용·손패용)의 생성·후처리·검증·문서화.
- **Claude 책임:** 게임 코드·카탈로그·검증 스크립트·실행파일 내보내기.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/tools/**`, `godot/assets/cards/catalog.json`, `godot/project.godot`, 이번 13장 외 기존 `godot/assets/cards/**/*.png`, `docs/` 의 기획 문서(이 요청서 끝의 납품 결과 절만 추가), 루트 `WitchsLodge.exe`(Claude가 내보낸다). 다른 작업의 변경을 되돌리지 말 것. **커밋하지 말 것.** Claude와 다른 세션들이 같은 저장소에서 동시에 작업 중이다.

## 반드시 따를 기존 기준

먼저 읽기: [카드 디자인 가이드](../card-design-guide.md)(§2 역할별 포맷, §4 안전 영역, §6 절차, §7 검수), [장비 카드 요청서](codex-equipment-cards-v01.md)(가장 최근의 같은 종류 작업과 납품 방식), [늑대의 피 카드 요청서](codex-wolf-blood-cards-v01.md), 아트 가이드 `docs/art-direction.md`, 전역 지침 `CLAUDE.md`(중세 기반 판타지).

**실제 이미지 참고 입력(필수, 매 장):**

1. **해당 역할의 승인 PNG** — `art/concepts/cards/roles-individual-v02/` 의 아래 표 "포맷" 열 파일. 원화창 형태·프레임·패널·먹선·글자 배치를 그대로 따른다.
   - 인물: `01-character-nib.png` · 스킬: `02-skill-warm-welcome.png` · 자원: `03-resource-timber.png` · 장비·유물: `04-relic-moonlit-charm.png` · 시설: `05-facility-forest-altar.png`
2. **같은 역할의 현재 게임 카드** 1~2장(화풍·질감 일관성): 스킬은 `godot/assets/cards/frost_rune.png`·`vine_snare.png`, 자원은 `timber.png`·`rabbit_pelt.png`, 장비는 `rusty_longsword.png`·`rowan_charm.png`, 시설은 `ward_lantern.png`·`sleeping_thorn_seed.png`, 인물은 `warrior.png`·`forest_monster.png`.
3. **고블린 외형 기준** — 고블린 손님 니브 원화 `art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png` 와 손님 초상 `godot/assets/portraits/guest_graz_cutout.png`·`guest_tak_cutout.png`·`guest_pikl_cutout.png`·`guest_rusk_cutout.png`·`guest_mala_cutout.png`(있는 것만). 큰 귀, 이끼·구리 색조, 짝짝이 고물 장비. 종족 카드라 고블린 보조색(이끼·구리)과 동전·리벳 모티프를 원화 안에 은근히 넣는다(프레임 자체는 승인 포맷 그대로).

공통 요건:

- **RGBA 1024×1536(2:3), 네 모서리 라운드, 모서리 바깥 투명.** 손패용은 같은 그림을 **RGBA 256×384**로 균등 축소.
- 인쇄 문구(제목·분류 띠·설명 2줄)는 아래 표 **그대로**(철자·띄어쓰기·가운뎃점 ` · ` 포함). 제목 2줄·설명 4줄 안전 영역을 비워 둔다. 글칸 안 장식 금지, 원화에 수치·숫자 금지(단, `고물` 카드의 인쇄 문구 "1개 4G."는 표 그대로 둔다).
- **"임시 카드" 같은 문구를 넣지 않는다.**
- 중세 기반 판타지. 겨울 숲·산장 지역. 고블린 특유의 장난스럽고 허술하지만 귀여운 손재주 느낌. 공포·잔혹 표현 없이.

## 카드 13장 (인쇄 문구는 이 글자 그대로)

| id | 포맷 | 카드 이름 | 분류 띠 | 인쇄 문구 (2줄) |
|---|---|---|---|---|
| `goblin_gang` | 인물 | 사촌 패거리 | 고블린 · 졸개 소환 | 밤에 땅에 놓으면 졸개가 몰려옵니다. / 졸개는 새벽에 돌아갑니다. |
| `goblin_firecracker` | 스킬 | 고블린 폭죽 | 고블린 · 도박 폭발 | 밤에 던지면 크게 터집니다. / 가끔 아군도 그을립니다. |
| `dud_bomb` | 스킬 | 불발탄 | 고블린 · 기절 | 밤에 던지면 좁게 터집니다. / 맞은 적이 잠깐 기절합니다. |
| `goblin_rush` | 스킬 | 떼거리 돌격 | 고블린 · 졸개 돌진 | 졸개 전원이 한 곳으로 돌진합니다. / 졸개가 많을수록 셉니다. |
| `shiny_lure` | 스킬 | 반짝이 미끼 | 고블린 · 어그로 끌기 | 밤에 던지면 적이 몰려듭니다. / 끝나면 터져 눈부시게 합니다. |
| `junk_barricade` | 시설 | 고물 방책 | 고블린 · 임시 시설 | 목재 1로 바로 세웁니다. / 2일 뒤 새벽에 무너집니다. |
| `pikl_traps` | 시설 | 피클의 덫 꾸러미 | 고블린 · 덫 설치 | 땅에 작은 덫 셋을 깝니다. / 밟은 적이 잠깐 멈춥니다. |
| `junk_sack` | 자원 | 잡동사니 자루 | 고블린 · 자원 꾸러미 | 낮에 열면 자원이 나옵니다. / 가끔 쓸모없는 고물도 섞입니다. |
| `scrap` | 자원 | 고물 | 고블린 · 판매용 | 산장에 놓으면 팝니다. / 1개 4G. |
| `graz_whistle` | 장비·유물 | 그라즈의 호루라기 | 장비 · 장신구 · 고블린 | 용병에게 걸어 줍니다. / 고블린이 불면 졸개가 옵니다. |
| `pot_helmet` | 장비·유물 | 찌그러진 냄비 투구 | 장비 · 방어구 · 고블린 | 용병에게 씌웁니다. / 맞을수록 닳고, 고블린은 고쳐 씁니다. |
| `mala_coin_scale` | 장비·유물 | 말라의 동전 저울 | 장비 · 장신구 · 고블린 | 용병에게 쥐여 줍니다. / 처치할 때 골드를 더 얻습니다. |
| `mala_monocle` | 장비·유물 | 말라의 외알 안경 | 장비 · 장신구 · 고블린 | 용병에게 씌웁니다. / 처치한 적의 재화를 더 잘 찾습니다. |

### 원화 내용

- **사촌 패거리(인물):** 작은 고블린 셋~넷이 엉겨 붙어 달려오는 모습. 짝짝이 냄비 투구, 나무 막대·국자 같은 엉성한 무기, 신난 표정. 아치형 초상창에 꽉 차게. 밤 숲 가장자리, 등불 빛.
- **고블린 폭죽(스킬):** 심지에 불붙은 둥근 나무통(구리 테·리벳)이 막 터지기 직전, 불꽃 별과 연기. 마름모 창 중앙.
- **불발탄(스킬):** 같은 계열의 작은 통이 피식 김만 내며 반쯤 터진 모습. 회색 연기, 작은 별 몇 개(기절 느낌). 폭죽과 짝으로 보이되 더 작고 초라하게.
- **떼거리 돌격(스킬):** 작은 고블린 졸개들이 한 방향으로 우르르 돌진하는 실루엣, 먼지와 눈보라. 속도선 대신 흩날리는 눈.
- **반짝이 미끼(스킬):** 유리구슬·단추·동전을 엉성하게 묶은 반짝이는 덩어리가 눈 위에서 빛을 뿜는다. 따뜻한 금빛.
- **고물 방책(시설):** 삐뚤빼뚤한 판자·냄비 뚜껑·녹슨 경첩을 못으로 이어 붙인 허술한 울타리. 산장 앞 눈밭. 지붕형 상단·단단한 하단 구획의 시설 포맷.
- **피클의 덫 꾸러미(시설):** 쇠이빨 덫 세 개와 셈 줄 매듭이 달린 끈 뭉치를 펼쳐 놓은 모습. 눈 위.
- **잡동사니 자루(자원):** 불룩한 삼베 자루 입구로 나뭇조각·가죽·단추·실타래가 삐져나온 모습.
- **고물(자원):** 찌그러진 숟가락·부러진 경첩·구멍 난 냄비 조각 등 쓸모없어 보이는 쇠붙이 한 줌.
- **그라즈의 호루라기(장비):** 낡은 뼈·구리 호루라기, 땋은 가죽 끈, 작은 동전 장식. 방패형 창에 세로로.
- **찌그러진 냄비 투구(장비):** 망치로 편 자국이 남은 찌그러진 쇠냄비 투구, 손잡이를 귀 구멍처럼 쓴 모양, 턱끈.
- **말라의 동전 저울(장비):** 작은 황동 접시 저울, 한쪽 접시에 동전 몇 닢. 벨벳 천 위.
- **말라의 외알 안경(장비):** 금테 외알 안경과 가는 사슬, 렌즈에 반사된 반짝임. 벨벳 천 위.

같은 포맷끼리 한 묶음으로 보이게 하고, 손패 크기(256×384)에서도 실루엣으로 서로 구별되어야 한다(특히 폭죽/불발탄, 동전 저울/외알 안경).

## 산출물 경로

| 용도 | 경로 |
| --- | --- |
| 생성 원본(보존) | `art/cards/goblin-v01/<id>.png` (+ 미채택 초안은 `art/cards/goblin-v01/drafts/`) |
| 게임용 | `godot/assets/cards/<id>.png` — RGBA 1024×1536 |
| 손패용 | `godot/assets/cards/hand/<id>.png` — RGBA 256×384 |
| 프롬프트 기록 | `docs/prompts/cards/goblin-v01-prompts.md` (장마다 실제 프롬프트·참고 입력·재생성 이유) |
| 미리보기 시트 | `godot/screenshots/goblin-cards/sheet.png` — 카드 13장 + 참고한 승인 PNG 몇 장 |
| 검증 기록 | `output/goblin-cards-v01/verification.json` — 파일별 크기·채널·모서리 알파·SHA-256·`passed` |

납품 후 `.tools/Godot-4.7.2.exe --headless --path godot --import` 를 실행해 `.import`·텍스처 캐시를 갱신한다(이미지 전용 격리 프로젝트 방식도 허용, 수정 금지 경로에 파일이 생기지 않게). 실행파일은 내보내지 않는다.

## 완료 기준

1. 카드 13장 × (게임용 + 손패용)이 위 경로·규격으로 존재. 모서리 바깥 투명.
2. 해당 역할 승인 PNG와 원화창·프레임·글자 배치가 일치하고, 인쇄 문구가 표와 정확히 같다(원본 크기로 직접 확인, 오탈자 0).
3. 같은 포맷끼리 한 묶음으로 보이면서 실루엣으로 구별된다. 고블린다움(이끼·구리, 동전·리벳, 허술한 손재주)이 보인다.
4. 중세 판타지 재료, 글자 안전 영역 침범 없음, 금지 수치·임시 문구 없음, 미리보기 시트로 일관성 확인.
5. `--import` 종료 코드 0, 검증 JSON `passed=true`.
6. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절(파일 목록, 재생성한 카드와 이유, 남은 문제)을 붙이고 마지막 메시지에 같은 요약. 기준 미달은 숨기지 말고 id별로 적는다.


## Codex 납품 결과 · 2026-10-19

- **납품:** 고블린 카드 13종의 보존 원본·게임용 **RGBA 1024×1536**, 손패용 **RGBA 256×384**, 총 **39개 PNG**를 아래 지정 경로에 저장했다. 네 모서리를 라운드 처리하고 바깥은 투명하게 만들었다. 손패는 동일 그림의 정확한 1/4 균등 축소다.
- **실제 참고:** 내장 `image_gen`으로 **37회 생성/수정**했다. 모든 호출에 해당 역할 승인 PNG, 같은 역할의 게임 카드 1~2장, 고블린 외형 참고 시트를 실제 이미지 입력으로 전달했다. 참고 입력 최대 5장 제한 때문에 니브 원화와 그라즈·탁·피클·러스크·말라 초상 6개를 비율 유지 비교 시트로 묶었다. 후반에는 배치·마름모 도식을 보조 입력으로 추가했다. 승인 PNG·현재 게임 참고·외형 원본은 수정하지 않았다.
- **재생성·선정:** 13종 모두 첫 생성본의 큰 글자·부족한 여백을 보완했다. `goblin_gang`은 작은 종족 배지를 복구하고 분류 위치·제목 먹선을 추가 조정해 **4회 수정**, 스킬 4종(`goblin_firecracker`, `dud_bomb`, `goblin_rush`, `shiny_lure`)은 분류 위치와 마름모 하단·눈/장화 침범을 정리해 **각 3회 수정**했다. 나머지 8종은 **각 1회 수정**했으며, `junk_sack`·`scrap`의 잘못 복제된 목재 표식은 각각 자루·쇠붙이 표식으로 교정했다. `goblin_gang`의 `brush-v04`는 제목·본문이 과대 확대돼 미채택했다. 가공 전 **37개 생성본과 미채택본 모두 `drafts/`에 보존**했다.
- **후처리:** 채택한 원화의 RGB·프레임·인쇄 글자는 그대로 유지하고 카드지 알파와 라운드 외곽만 정규화했다. 코드로 그림이나 글자를 덧그리거나 바꾸지 않았다.
- **검증:** 13종의 제목·분류·두 줄 인쇄 문구를 원본 크기 크롭에서 직접 대조해 오탈자·누락 없음으로 확인했다. 역할별 골격, 제목 2줄·설명 4줄 여백, 중세 판타지 재료와 손패 실루엣을 승인 PNG 5종 비교 시트로 확인했다. 최초 저장 시 39개 PNG 규격·채널·모서리 알파·SHA-256, 원본/게임용 동일성·RGB 보존·손패 균등 축소 검증을 통과했다. 현재는 아래 동시 변경 때문에 최상위 **`passed=false`**, 보존된 요청서 기준 납품 세트는 **`preserved_delivery_passed=true`**다. 이미지 전용 격리 프로젝트에서 Godot **`--import` 종료 코드 0**, 임포트 텍스처 규격·알파·픽셀 해시 **26/26 통과**. 해당 카드 26개의 `.import`와 텍스처 캐시만 게임 프로젝트로 반영했다.
- **기록:** [요청서 기준 납품 미리보기 시트](../../godot/screenshots/goblin-cards/sheet.png), [검증 JSON](../../output/goblin-cards-v01/verification.json), [실제 프롬프트·참고 입력·수정 사유](../prompts/cards/goblin-v01-prompts.md), [37회 생성 이력](../../output/goblin-cards-v01/generation-results.json), [원본 크기 시각 검수](../../output/goblin-cards-v01/visual-review.json), [임포트 로그](../../output/goblin-cards-v01/import.log).
- **작업 경계:** 금지 경로에는 직접 쓰지 않았으며 다른 변경을 되돌리지 않았다. 시작 시점 보호 파일 1065개와 비교해 다른 세션의 변경 21개를 관찰 기록으로만 남기고 보존했다(게임 코드·씬·카탈로그·기획 문서·EXE 포함). 이 요청서는 기존 본문을 유지하고 이 절만 추가했다. **커밋·실행파일 내보내기는 하지 않았다.**
- **남은 문제 · 동시 변경 보존:** 최종 검증 도중 다른 세션이 `junk_sack`·`scrap`의 게임용·손패용 4개를 교체했다. `junk_sack`은 납품 원화와 다른 그림이며, `scrap`은 제목이 요청서의 **고물**에서 **쇠붙이**로 바뀌고 원화도 달라졌다. 다른 변경을 되돌리지 말라는 지시에 따라 덮어쓰지 않았다. 따라서 현재 게임 경로는 이 요청서의 원본과 불일치하며, 해당 2종은 납품 기준 미달로 기록한다. 요청서 기준 13종은 `art/cards/goblin-v01/`, 최초 임포트 검증을 통과한 26개는 `output/goblin-cards-v01/import-project/assets/cards/`에 그대로 보존돼 있다. [현재 파일 관찰·해시](../../output/goblin-cards-v01/concurrent-conflicts.json), [요청서 원본/현재판 비교](../../output/goblin-cards-v01/concurrent-comparison.png). 나머지 11종은 기준 충족. Godot 루트 인증서 저장소 오류 로그·원본 이미지 읽기 경고는 최초 로컬 임포트·텍스처 검사 통과에 영향이 없었다.

### 파일 목록

| id | 보존 원본 | 게임용 | 손패용 |
| --- | --- | --- | --- |
| `goblin_gang` | [PNG](../../art/cards/goblin-v01/goblin_gang.png) | [PNG](../../godot/assets/cards/goblin_gang.png) | [PNG](../../godot/assets/cards/hand/goblin_gang.png) |
| `goblin_firecracker` | [PNG](../../art/cards/goblin-v01/goblin_firecracker.png) | [PNG](../../godot/assets/cards/goblin_firecracker.png) | [PNG](../../godot/assets/cards/hand/goblin_firecracker.png) |
| `dud_bomb` | [PNG](../../art/cards/goblin-v01/dud_bomb.png) | [PNG](../../godot/assets/cards/dud_bomb.png) | [PNG](../../godot/assets/cards/hand/dud_bomb.png) |
| `goblin_rush` | [PNG](../../art/cards/goblin-v01/goblin_rush.png) | [PNG](../../godot/assets/cards/goblin_rush.png) | [PNG](../../godot/assets/cards/hand/goblin_rush.png) |
| `shiny_lure` | [PNG](../../art/cards/goblin-v01/shiny_lure.png) | [PNG](../../godot/assets/cards/shiny_lure.png) | [PNG](../../godot/assets/cards/hand/shiny_lure.png) |
| `junk_barricade` | [PNG](../../art/cards/goblin-v01/junk_barricade.png) | [PNG](../../godot/assets/cards/junk_barricade.png) | [PNG](../../godot/assets/cards/hand/junk_barricade.png) |
| `pikl_traps` | [PNG](../../art/cards/goblin-v01/pikl_traps.png) | [PNG](../../godot/assets/cards/pikl_traps.png) | [PNG](../../godot/assets/cards/hand/pikl_traps.png) |
| `junk_sack` | [PNG](../../art/cards/goblin-v01/junk_sack.png) | [PNG](../../godot/assets/cards/junk_sack.png) | [PNG](../../godot/assets/cards/hand/junk_sack.png) |
| `scrap` | [PNG](../../art/cards/goblin-v01/scrap.png) | [PNG](../../godot/assets/cards/scrap.png) | [PNG](../../godot/assets/cards/hand/scrap.png) |
| `graz_whistle` | [PNG](../../art/cards/goblin-v01/graz_whistle.png) | [PNG](../../godot/assets/cards/graz_whistle.png) | [PNG](../../godot/assets/cards/hand/graz_whistle.png) |
| `pot_helmet` | [PNG](../../art/cards/goblin-v01/pot_helmet.png) | [PNG](../../godot/assets/cards/pot_helmet.png) | [PNG](../../godot/assets/cards/hand/pot_helmet.png) |
| `mala_coin_scale` | [PNG](../../art/cards/goblin-v01/mala_coin_scale.png) | [PNG](../../godot/assets/cards/mala_coin_scale.png) | [PNG](../../godot/assets/cards/hand/mala_coin_scale.png) |
| `mala_monocle` | [PNG](../../art/cards/goblin-v01/mala_monocle.png) | [PNG](../../godot/assets/cards/mala_monocle.png) | [PNG](../../godot/assets/cards/hand/mala_monocle.png) |

가공 전 생성본: `art/cards/goblin-v01/drafts/` · 보조 입력: `output/goblin-cards-v01/goblin-appearance-reference.png`, `layout-guides/`, `geometry-guides/` · 검증 재현 스크립트: `output/goblin-cards-v01/pipeline.py`, `run-import.ps1`.
