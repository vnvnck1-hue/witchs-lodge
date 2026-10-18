# Codex에게 요청하는 에셋 작업 — 늑대의 피 카드 4장 + 늑대 스킬 아이콘 2개 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-18 · 기획: [늑대의 피 이벤트](../wolf-blood-event-design.md) §3·§5 · 카드 기준: [카드 디자인 가이드](../card-design-guide.md)

## 배경

늑대 수인 손님 파르그가 검은 양 한 마리를 얻어먹고 마녀에게 **[늑대의 피]** 카드를 준다. 이 카드를 마녀에게 쓰면 **초승달·상현달·보름달** 카드 세 장이 주머니로 들어오고, 달 카드는 밤에 마녀에게 써서 공격 속도·이동 속도를 올리거나(보름달) 늑대로 변신한다. 늑대는 Q(할퀴기)·E(덮치기) 스킬을 쓴다. 게임 코드는 이미 경로만 맞으면 그림을 쓰고, 파일이 없으면 카드 뒷면·문자 아이콘으로 대체한다.

## 역할 분담

- **Codex 책임:** 카드 4장(원본·게임용·손패용)과 스킬 아이콘 2개의 생성·후처리·검증·문서화.
- **Claude 책임:** 게임 코드·카탈로그·검증 스크립트·실행파일 내보내기.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/assets/cards/catalog.json`, `godot/project.godot`, 기존 `godot/assets/cards/*.png`(이번 4장 외 기존 카드는 덮어쓰지 말 것), `docs/wolf-blood-event-design.md`, 루트 `WitchsLodge.exe`(이번에는 Claude가 내보낸다). 다른 작업의 변경을 되돌리지 말 것. **커밋하지 말 것.** Claude와 다른 세션이 같은 저장소에서 동시에 작업 중이다.

## 반드시 따를 기존 기준

먼저 읽기: [카드 디자인 가이드](../card-design-guide.md)(특히 §2 역할별 포맷, §4 안전 영역, §6 절차, §7 검수), [역할 포맷 적용 기록](../card-role-format-rollout-v02.md), [볼륨 확장 카드 요청서](codex-expansion-cards-v01.md)(가장 최근의 같은 종류 작업), 아트 가이드 `docs/art-direction.md`, 전역 지침 `CLAUDE.md`(중세 기반 판타지).

**실제 이미지 참고 입력(필수, 매 장):**

1. **역할별 승인 PNG** — `art/concepts/cards/roles-individual-v02/` 안의 해당 역할 카드(사건 / 스킬). 프레임·패널·먹선·글자 배치를 그대로 따른다.
2. **같은 역할의 현재 게임 카드** — 사건: `godot/assets/cards/treasure_chest.png`, 스킬: `godot/assets/cards/frost_rune.png`·`vine_snare.png`. 화풍 일관성용.
3. **파르그 포트레이트** — `godot/assets/portraits/guest_fargh_cutout.png`(늑대의 피 카드의 늑대 수인 손 묘사 참고: 회색 털, 찢긴 귀).

공통 요건:

- **RGBA 1024×1536(2:3), 네 모서리 라운드, 모서리 바깥 투명.** 손패용은 같은 그림을 **RGBA 256×384**로 축소.
- 인쇄 문구(제목·분류 띠·설명 2줄)는 아래 표 **그대로**(철자·띄어쓰기·가운뎃점 ` · ` 포함). 제목 2줄·설명 4줄 안전 영역을 비워 둔다(§4). 글칸 안 장식 금지, 원화에 수치·키 글자(Q/E) 금지.
- 중세 기반 판타지. 겨울 숲·산장 지역의 밤.

## 카드 4장 (인쇄 문구는 이 글자 그대로)

| id | 포맷 | 카드 이름 | 분류 띠 | 인쇄 문구 (2줄) |
|---|---|---|---|---|
| `wolf_blood` | 사건 | 늑대의 피 | 늑대 수인의 선물 · 변화 | 마녀에게 쓰면 잠시 고통스럽습니다. / 달의 힘 세 가지가 주머니에 들어옵니다. |
| `crescent_moon` | 스킬 | 초승달 | 늑대의 피 · 밤의 힘 | 밤에 마녀에게 씁니다. / 오늘 밤 공격 속도가 오릅니다. |
| `half_moon` | 스킬 | 상현달 | 늑대의 피 · 밤의 힘 | 밤에 마녀에게 씁니다. / 오늘 밤 공격과 이동이 빨라집니다. |
| `full_moon` | 스킬 | 보름달 | 늑대의 피 · 밤의 힘 | 밤에 마녀에게 씁니다. / 오늘 밤 늑대로 변신합니다. |

### 원화 내용

- **늑대의 피:** 회색 털에 찢긴 귀를 가진 늑대 수인의 손이 작은 가죽 주머니(또는 뼈 마개 유리병)에 담긴 짙은 붉은 액체를 마녀에게 건네는 장면. 배경은 산장 안 난롯불. 피를 직접 흘리는 묘사는 피하고 병 속 액체와 붉은 빛으로만. 사건 포맷(두루마리·불길한 사건의 틀은 승인 PNG 그대로).
- **초승달:** 겨울 밤하늘의 가는 초승달이 눈 덮인 숲 위에 떠 있고, 달빛을 받은 마녀의 실루엣(또는 지팡이 끝)이 은빛으로 빛난다. 손끝이 조금 날카로워진 암시 정도.
- **상현달:** 반달(상현)이 더 밝게 떠 있고, 마녀가 눈밭을 빠르게 달리는 잔상(은빛 궤적). 머리카락이 바람에 날리고 눈이 노랗게 빛난다.
- **보름달:** 커다란 보름달을 등지고 눈밭에 서 있는 회색 늑대(마녀가 변한 모습) — 보랏빛 마녀 모자나 지팡이 끈 같은 마녀의 흔적 하나를 남긴다. 눈은 보랏빛, 입김. 세 장은 같은 밤하늘·같은 화풍으로 한 묶음임이 보이게 하되, 달의 모양이 한눈에 구별되어야 한다.

세 달 카드는 같은 스킬 포맷(서리 룬·덩굴 덫과 같은 틀)이며, 분류 띠 "늑대의 피 · 밤의 힘"이 같다.

## 스킬 아이콘 2개

늑대로 변신한 밤에 화면 왼쪽 아래 스킬 바에 쓰는 원형 아이콘. 게임 코드는 128×128을 56px로 축소해 보여 준다.

| 파일 | 내용 |
|---|---|
| `godot/assets/ui/skills/wolf_claw.png` | 할퀴기 — 보랏빛 발톱 자국 세 줄이 부채꼴로 퍼지는 모양. 어두운 남보라 바탕 원, 얇은 금테 |
| `godot/assets/ui/skills/wolf_pounce.png` | 덮치기 — 앞으로 뛰어오르는 늑대 실루엣 + 송곳니. 같은 바탕·테두리 |

- RGBA **128×128**, 원 바깥 투명. 글자(Q/E) 없음 — 키 글자는 게임이 그린다.
- 화풍은 기존 `godot/assets/ui/icons/`의 아이콘을 참고해 선이 또렷한 수채·먹선 느낌으로.

## 산출물 경로

| 용도 | 경로 |
| --- | --- |
| 생성 원본(보존) | `art/cards/wolf-blood-v01/<id>.png` (+ 미채택 초안은 `art/cards/wolf-blood-v01/drafts/`) |
| 게임용 | `godot/assets/cards/<id>.png` — RGBA 1024×1536 |
| 손패용 | `godot/assets/cards/hand/<id>.png` — RGBA 256×384 |
| 아이콘 | `godot/assets/ui/skills/wolf_claw.png`, `wolf_pounce.png` — RGBA 128×128 |
| 프롬프트 기록 | `docs/prompts/cards/wolf-blood-v01-prompts.md` (장마다 실제 프롬프트·참고 입력·재생성 이유) |
| 미리보기 시트 | `godot/screenshots/wolf-blood-cards/sheet.png` — 카드 4장 + 아이콘 2개 + 참고한 기존 카드(treasure_chest·frost_rune) |
| 검증 기록 | `output/wolf-blood-v01/verification.json` — 파일별 크기·채널·모서리 알파·SHA-256·`passed` |

납품 후 `.tools/Godot-4.7.2.exe --headless --path godot --import` 를 실행해 `.import` 파일을 만든다(이미지 전용 격리 프로젝트 방식도 허용, 수정 금지 경로에 파일이 생기지 않게). 실행파일은 내보내지 않는다.

## 완료 기준

1. 카드 4장 × (게임용 + 손패용)과 아이콘 2개가 위 경로·규격으로 존재. 모서리 바깥 투명.
2. 같은 역할의 승인 PNG와 프레임·글자 배치가 일치하고, 인쇄 문구가 표와 정확히 같다(원본 크기로 직접 확인, 오탈자 0).
3. 세 달 카드가 한 묶음으로 보이면서 달 모양으로 구별되고, 보름달 카드의 늑대에 마녀의 흔적이 있다.
4. 중세 판타지 재료, 글자 안전 영역 침범 없음, 수치·키 글자 없음, 미리보기 시트로 일관성 확인.
5. `--import` 종료 코드 0, 검증 JSON `passed=true`.
6. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절(파일 목록, 재생성한 카드와 이유, 남은 문제)을 붙이고 마지막 메시지에 같은 요약. 기준 미달은 숨기지 말고 id별로 적는다.

## Codex 납품 결과 · 2026-10-18

- **납품:** `wolf_blood`, `crescent_moon`, `half_moon`, `full_moon` 4종의 원본·게임용 1024×1536·손패용 256×384 PNG 12개와 `wolf_claw.png`·`wolf_pounce.png` 128×128 아이콘 2개, 총 **14개 PNG**를 지정 경로에 저장했다. 모두 RGBA이며 카드 모서리 바깥·아이콘 원 바깥은 투명하다.
- **참고·재생성:** 내장 `image_gen`의 실제 이미지 입력으로 역할별 승인 PNG·동일 역할 기존 카드·파르그 포트레이트를 매 카드에 전달했다. 카드 4종 모두 제목 2줄·설명 4줄 여백을 보완하기 위해 한 차례 재생성했다. 아이콘은 기존 UI 아이콘을 실제 입력으로 사용했고 재생성하지 않았다. 초안과 가공 전 생성본도 보존했다.
- **검증:** 인쇄 문구를 원본 크기에서 직접 대조해 오탈자·누락 없음으로 확인했다. 격리 이미지 프로젝트의 Godot `--import` 종료 코드 **0**, 임포트 텍스처 **10/10** 통과, 파일별 규격·채널·모서리 알파·SHA-256 검증 **`passed=true`**. 새 PNG의 `.import`와 텍스처 캐시를 게임 경로에 복사했다.
- **기록:** [미리보기 시트](../../godot/screenshots/wolf-blood-cards/sheet.png), [검증 JSON](../../output/wolf-blood-v01/verification.json), [실제 프롬프트·참고 입력·재생성 이유](../prompts/cards/wolf-blood-v01-prompts.md)를 저장했다.
- **보존·남은 문제:** 수정 금지 경로에는 쓰지 않았고 커밋·EXE 내보내기도 하지 않았다. 기존 카드·승인 PNG·카탈로그·EXE의 해시가 시작 시점과 같다. 다른 세션의 스크립트 변경 7건을 관측해 보존했다. 납품 에셋의 남은 문제는 없다. Godot의 시스템 루트 인증서 저장소 경고는 로그에 남았으나 이미지 임포트·로드 검사는 모두 통과했다.

파일 목록:

| 용도 | 파일 |
| --- | --- |
| 원본 4개 | `art/cards/wolf-blood-v01/{wolf_blood,crescent_moon,half_moon,full_moon}.png` |
| 게임용 4개 | `godot/assets/cards/{wolf_blood,crescent_moon,half_moon,full_moon}.png` |
| 손패용 4개 | `godot/assets/cards/hand/{wolf_blood,crescent_moon,half_moon,full_moon}.png` |
| 스킬 아이콘 2개 | `godot/assets/ui/skills/wolf_claw.png`, `godot/assets/ui/skills/wolf_pounce.png` |
| 생성 이력 | `art/cards/wolf-blood-v01/drafts/`의 첫 생성 6개·레이아웃 보완 생성본 4개 |
| 시각 검수 | `output/wolf-blood-v01/visual-review.json`, `review-<id>.png` 4개 |
| 임포트·검증 | `output/wolf-blood-v01/import.log`, `texture-verify.log`, `import-result.json`, `verification.json` |
| 재현 기록 | `output/wolf-blood-v01/pipeline.py`, `run-import.ps1`, `generation-plan.json`, `repair-plan.json`, `generation-results.json`, `selected.json` |
