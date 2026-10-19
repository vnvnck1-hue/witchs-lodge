# Codex에게 요청하는 에셋 작업 — 장비 카드 5장 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-19 · 기획: [장비·파티 프레임](../equipment-and-party-frames-v01.md) · 카드 기준: [카드 디자인 가이드](../card-design-guide.md)

## 배경

마녀와 용병이 무기·방어구·장신구 칸에 장비를 낀다. 장비 5종은 게임에 이미 들어가 있지만, 지금 카드 그림은 카드 뒷면 위에 이름·효과만 적은 **임시 카드**("임시 카드 — 원화 대기")다. 이번 작업으로 정식 원화를 만들어 **같은 경로에 덮어쓴다.** 게임 코드는 경로만 맞으면 그림을 그대로 쓴다.

## 역할 분담

- **Codex 책임:** 카드 5장(원본·게임용·손패용)의 생성·후처리·검증·문서화.
- **Claude 책임:** 게임 코드·카탈로그·검증 스크립트·실행파일 내보내기.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/tools/**`, `godot/assets/cards/catalog.json`, `godot/project.godot`, 이번 5장 외 기존 `godot/assets/cards/**/*.png`, `docs/equipment-and-party-frames-v01.md`, 루트 `WitchsLodge.exe`(Claude가 내보낸다). 다른 작업의 변경을 되돌리지 말 것. **커밋하지 말 것.** Claude와 다른 세션이 같은 저장소에서 동시에 작업 중이다.
- **덮어쓸 대상(이번 5장만):** `godot/assets/cards/<id>.png`, `godot/assets/cards/hand/<id>.png` — 현재 파일은 임시판이다. 덮어쓰기 전에 `art/cards/equipment-v01/placeholder-backup/`에 사본을 남긴다.

## 반드시 따를 기존 기준

먼저 읽기: [카드 디자인 가이드](../card-design-guide.md)(특히 §2 역할별 포맷 중 **장비·유물**, §4 안전 영역, §6 절차, §7 검수), [역할 포맷 적용 기록](../card-role-format-rollout-v02.md), [늑대의 피 카드 요청서](codex-wolf-blood-cards-v01.md)(가장 최근의 같은 종류 작업과 납품 방식), 아트 가이드 `docs/art-direction.md`, 전역 지침 `CLAUDE.md`(중세 기반 판타지).

**실제 이미지 참고 입력(필수, 매 장):**

1. **장비·유물 승인 PNG** — `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`. 세로로 긴 물건을 담는 **방패형 원화창**, 프레임·패널·먹선·글자 배치를 그대로 따른다. 방패 아래 끝이 설명란을 침범하지 않는다.
2. **같은 역할의 현재 게임 카드** — `godot/assets/cards/moonlit_charm.png`, `wolf_fang_pendant.png`, `old_spellbook.png`. 화풍·질감 일관성용.

공통 요건:

- **RGBA 1024×1536(2:3), 네 모서리 라운드, 모서리 바깥 투명.** 손패용은 같은 그림을 **RGBA 256×384**로 축소.
- 인쇄 문구(제목·분류 띠·설명 2줄)는 아래 표 **그대로**(철자·띄어쓰기·가운뎃점 ` · ` 포함). 제목 2줄·설명 4줄 안전 영역을 비워 둔다(§4). 글칸 안 장식 금지, 원화에 수치(+30%, 0.4 등) 금지.
- **"임시 카드 — 원화 대기" 같은 문구를 넣지 않는다.**
- 중세 기반 판타지. 겨울 숲·산장 지역. 물건 하나를 방패형 창 중앙에 크게, 배경은 산장 안이나 겨울 숲의 분위기로 절제한다.

## 카드 5장 (인쇄 문구는 이 글자 그대로)

| id | 포맷 | 카드 이름 | 분류 띠 | 인쇄 문구 (2줄) |
|---|---|---|---|---|
| `rusty_longsword` | 장비·유물 | 녹슨 장검 | 장비 · 무기 | 용병에게 쥐여 줍니다. / 공격이 강해집니다. |
| `oak_staff` | 장비·유물 | 참나무 지팡이 | 장비 · 무기 | 마녀가 손에 쥡니다. / 마법탄이 강해집니다. |
| `quilted_gambeson` | 장비·유물 | 누빈 솜옷 | 장비 · 방어구 | 누구에게나 입힙니다. / 체력이 늘고 덜 다칩니다. |
| `traveler_boots` | 장비·유물 | 나그네 장화 | 장비 · 장신구 | 누구에게나 신깁니다. / 더 빨리 걷습니다. |
| `rowan_charm` | 장비·유물 | 마가목 부적 | 장비 · 장신구 | 누구에게나 걸어 줍니다. / 상처가 천천히 아뭅니다. |

### 원화 내용

- **녹슨 장검:** 오래 쓰여 날 곳곳에 녹이 핀 중세 장검. 가죽을 감은 자루, 십자형 가드. 여전히 날은 서 있어 쓸 만해 보인다. 나무 무기걸이나 눈 위 바위에 세워진 모습. 세로로 긴 칼이 방패창에 꼭 맞게.
- **참나무 지팡이:** 마디진 참나무 가지를 깎은 마녀의 지팡이. 머리 쪽에 도토리·참나무 잎이 남아 있고 끝에 은은한 보랏빛 마력이 맺힌다. 노끈·작은 뼈 장식 정도.
- **누빈 솜옷:** 마름모 누빔이 있는 두툼한 중세 갬비슨(누빈 천 갑옷). 바랜 겨울 색 천, 가죽 끈 여밈. 나무 옷걸이나 산장 벽 고리에 걸린 모습.
- **나그네 장화:** 먼 길을 걸어 해지고 진흙·눈이 묻은 가죽 장화 한 켤레. 접힌 목, 꿰맨 자국, 발목의 가죽 끈. 길가 이정표나 문턱 옆.
- **마가목 부적:** 붉은 마가목 열매 송이와 나뭇가지를 붉은 실로 십자로 묶은 민속 부적. 따뜻한 빛이 살짝. 끈에 매달려 늘어진 모습.

다섯 장은 같은 장비 포맷·같은 화풍으로 한 묶음임이 보이게 하되, 물건 실루엣이 손패 크기(256×384)에서도 한눈에 구별되어야 한다.

## 산출물 경로

| 용도 | 경로 |
| --- | --- |
| 생성 원본(보존) | `art/cards/equipment-v01/<id>.png` (+ 미채택 초안은 `art/cards/equipment-v01/drafts/`) |
| 임시판 백업 | `art/cards/equipment-v01/placeholder-backup/<id>.png`, `.../hand/<id>.png` |
| 게임용 | `godot/assets/cards/<id>.png` — RGBA 1024×1536 |
| 손패용 | `godot/assets/cards/hand/<id>.png` — RGBA 256×384 |
| 프롬프트 기록 | `docs/prompts/cards/equipment-v01-prompts.md` (장마다 실제 프롬프트·참고 입력·재생성 이유) |
| 미리보기 시트 | `godot/screenshots/equipment-cards/sheet.png` — 카드 5장 + 참고한 기존 카드(moonlit_charm·wolf_fang_pendant) |
| 검증 기록 | `output/equipment-v01/verification.json` — 파일별 크기·채널·모서리 알파·SHA-256·`passed` |

납품 후 `.tools/Godot-4.7.2.exe --headless --path godot --import` 를 실행해 `.import`·텍스처 캐시를 갱신한다(이미지 전용 격리 프로젝트 방식도 허용, 수정 금지 경로에 파일이 생기지 않게). 실행파일은 내보내지 않는다.

## 완료 기준

1. 카드 5장 × (게임용 + 손패용)이 위 경로·규격으로 존재. 모서리 바깥 투명. 임시판 백업 존재.
2. 장비·유물 승인 PNG와 방패형 창·프레임·글자 배치가 일치하고, 인쇄 문구가 표와 정확히 같다(원본 크기로 직접 확인, 오탈자 0).
3. 다섯 장이 한 묶음으로 보이면서 물건 실루엣으로 구별된다.
4. 중세 판타지 재료, 글자 안전 영역 침범 없음, 수치·임시 문구 없음, 미리보기 시트로 일관성 확인.
5. `--import` 종료 코드 0, 검증 JSON `passed=true`.
6. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절(파일 목록, 재생성한 카드와 이유, 남은 문제)을 붙이고 마지막 메시지에 같은 요약. 기준 미달은 숨기지 말고 id별로 적는다.

## Codex 납품 결과 · 2026-10-19

- **납품:** `rusty_longsword`, `oak_staff`, `quilted_gambeson`, `traveler_boots`, `rowan_charm` 5종의 원본·게임용 **RGBA 1024×1536**, 손패용 **RGBA 256×384**, 총 **15개 PNG**를 지정 경로에 저장했다. 네 모서리는 라운드이며 바깥은 투명하다. 교체 전 임시판 **10개**는 `art/cards/equipment-v01/placeholder-backup/`과 그 아래 `hand/`에 보존했다.
- **실제 참고·재생성:** 내장 `image_gen`만 사용했다. 승인 장비·유물 PNG와 기존 `moonlit_charm.png`, `wolf_fang_pendant.png`, `old_spellbook.png`를 **8회 모든 호출에 실제 이미지 입력으로 전달**했다. `rusty_longsword`는 큰 글자와 부족한 여백 때문에 **2회 재생성/수정**, `oak_staff`는 같은 이유로 **1회 수정**했다. 나머지 3종은 첫 생성본을 채택했다. 가공 전 생성본 8개와 미채택 초안도 `drafts/`에 보존했다. RGB·인쇄 글자는 바꾸지 않고 카드지 알파만 정규화했으며 손패는 균등 축소했다.
- **검증:** 원본 크기에서 제목·분류·두 줄 문구를 요청서와 직접 대조해 **5종 모두 오탈자·누락 없음**으로 확인했다. 방패형 창, 제목 2줄·설명 4줄 여백, 중세 판타지 소재와 손패 실루엣을 비교 시트로 확인했다. 이미지 전용 격리 프로젝트의 Godot **`--import` 종료 코드 0**, 임포트 텍스처 규격·알파·픽셀 해시 **10/10 통과**, 납품 15개·백업 10개 규격 및 파일별 SHA-256 기록 **`passed=true`**. 새 카드 10개의 `.import`와 해당 텍스처 캐시를 게임 프로젝트에 반영했다.
- **기록:** [미리보기 시트](../../godot/screenshots/equipment-cards/sheet.png), [실제 프롬프트·참고 입력·수정 이유](../prompts/cards/equipment-v01-prompts.md), [검증 JSON](../../output/equipment-v01/verification.json), [가공 전 생성본과 호출 기록](../../output/equipment-v01/generation-results.json).
- **작업 경계:** 수정 금지 경로에 직접 쓰거나 다른 세션의 변경을 되돌리지 않았다. 보호 파일 862개와 비교해 동시 작업 중 발생한 변경 13개(코드·씬·기획서·EXE 포함)를 관찰 기록에만 남기고 보존했다. **커밋·EXE 내보내기는 하지 않았다.**
- **남은 문제:** 5종 모두 납품 기준 미달 사항 없음. Godot 로그의 루트 인증서 저장소 경고와 검증용 원본 이미지 읽기 경고는 로컬 임포트·텍스처 검증 통과에 영향이 없었다. 한국어가 인쇄된 PNG 납품이며, 다국어 동적 텍스트 구현·다른 언어의 넘침 검증은 이번 범위에 포함하지 않는다.

### 파일 목록

아래 각 id에 대해 같은 이름의 PNG를 세 경로에 납품했다.

| id | 보존 원본 | 게임용 | 손패용 |
| --- | --- | --- | --- |
| `rusty_longsword` | [PNG](../../art/cards/equipment-v01/rusty_longsword.png) | [PNG](../../godot/assets/cards/rusty_longsword.png) | [PNG](../../godot/assets/cards/hand/rusty_longsword.png) |
| `oak_staff` | [PNG](../../art/cards/equipment-v01/oak_staff.png) | [PNG](../../godot/assets/cards/oak_staff.png) | [PNG](../../godot/assets/cards/hand/oak_staff.png) |
| `quilted_gambeson` | [PNG](../../art/cards/equipment-v01/quilted_gambeson.png) | [PNG](../../godot/assets/cards/quilted_gambeson.png) | [PNG](../../godot/assets/cards/hand/quilted_gambeson.png) |
| `traveler_boots` | [PNG](../../art/cards/equipment-v01/traveler_boots.png) | [PNG](../../godot/assets/cards/traveler_boots.png) | [PNG](../../godot/assets/cards/hand/traveler_boots.png) |
| `rowan_charm` | [PNG](../../art/cards/equipment-v01/rowan_charm.png) | [PNG](../../godot/assets/cards/rowan_charm.png) | [PNG](../../godot/assets/cards/hand/rowan_charm.png) |
