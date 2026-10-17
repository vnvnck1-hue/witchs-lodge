# Codex에게 요청하는 에셋 작업 — 볼륨 확장 카드 12종 정식 원화 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-17 · 기획: [볼륨 확장 계획](../game-volume-expansion-plan.md) · 카드 기준: [카드 디자인 가이드](../card-design-guide.md)

## 배경

볼륨 확장(E1~E3)에서 카탈로그에 등록한 카드 12종이 아직 `tools/build_expansion_placeholder_cards.py`가 만든 **임시 카드("원화 준비 중", 단색 원+첫 글자)** 로 게임에 나온다. 이 12종을 기존 카드와 같은 v02 역할 포맷의 정식 원화로 교체한다.

## 역할 분담

- **Codex 책임:** 12종의 카드 원화 생성(내장 image_gen), 라운드 처리·크기 정규화·패키징, 검증, 문서화.
- **Claude 책임:** 카탈로그(`placeholder` 표시 제거)·게임 코드·배포 PCK. 경로·파일명만 맞으면 게임에 바로 보인다.
- **수정 금지:** `godot/scripts/**`, `godot/assets/cards/catalog.json`, `godot/scenes/**`, `godot/shaders/**`, `build/**`. Claude·다른 세션이 동시에 고치고 있다. 다른 작업의 변경을 되돌리지 말 것. 커밋하지 말 것(사용자가 정리한다). 승인 기준 PNG(`art/concepts/cards/roles-individual-v02/`)와 기존 26종 카드 PNG는 수정하지 않는다.

## 반드시 따를 기존 기준

먼저 읽기: `CLAUDE.md`, `docs/card-design-guide.md`(전부), `docs/card-role-format-rollout-v02.md`(직전 전체 교체 방식·검증), `docs/handoff/codex-pocket-cards-v01.md`, `art/cards/README.md`, `art/cards/manifest.json`, `art/cards/role-format-v02/generation-plan.json`, `godot/tools/package_card_assets.gd`, `godot/tools/verify_card_assets.gd`.

- **역할별 승인 PNG를 image_gen의 실제 참고 입력으로 사용**한다(가이드 §2·§6). 아래 표의 "포맷" 열이 쓸 역할이다. 같은 역할의 기존 게임 카드(예: 스킬 → `frost_rune.png`, `poison_mushroom.png` / 자원 → `timber.png` / 유물 → `moonlit_charm.png` / 시설 → `ward_lantern.png` / 사건 → `treasure_chest.png`)도 화풍 일관성용으로 함께 참고한다.
- 시대 배경: 중세 기반, 일반적인 판타지 문법으로 각색 가능. 복식·도구·소품은 중세 생활감.
- 1024×1536(2:3), 제목 2줄·설명 4줄 안전 영역, 글칸 안 장식 금지, 원화에 수치 금지. 인쇄 문구는 아래 표 그대로(철자·띄어쓰기·가운뎃점 ` · ` 포함).
- 산출물 경로: 원본 `art/cards/role-format-v02/<id>.png`(그리고 기존 관례대로 `art/cards/rounded/<id>.png`가 쓰이면 동일하게), 게임용 `godot/assets/cards/<id>.png`(RGBA 1024×1536, 바깥 투명 라운드), 손패용 `godot/assets/cards/hand/<id>.png`(RGBA 256×384). **임시 PNG를 같은 경로에 덮어쓴다.** 덮어쓰기 전 임시본은 `output/expansion-cards-v01/before/`에 보존.
- `godot/tools/package_card_assets.gd`의 `IDS`와 `godot/tools/verify_card_assets.gd`에 12종을 추가하고 개수 기대값(현재 27)을 39로 갱신해 검증한다(이 두 도구 파일은 Codex가 수정해도 된다). `verify_card_assets.gd`에 12종의 인쇄 문구 대조 표를 추가한다.
- Godot 실행 파일: `.tools/Godot-4.7.2.exe`. 임포트: `.tools/Godot-4.7.2.exe --headless --path godot --import`.

## 카드 12종 (인쇄 문구는 이 글자 그대로)

| id | 포맷 | 카드 이름 | 분류 띠 | 인쇄 문구 (2줄) |
|---|---|---|---|---|
| `moss_bandage` | 스킬 | 이끼 붕대 | 숲 카드 · 회복과 정화 | 마녀에게 놓아 체력을 돌봅니다. / 침식 카드 한 장을 정화합니다. |
| `resin_torch` | 스킬 | 송진 횃불 | 숲 카드 · 지속 불길 | 밤에 땅이나 적에게 던집니다. / 잠시 동안 불길이 적을 태웁니다. |
| `firefly_swarm` | 시설 | 반딧불이 떼 | 숲 카드 · 시야 | 땅에 풀어 안개를 걷어 냅니다. / 오늘 밤 전투가 끝나면 흩어집니다. |
| `vine_snare` | 스킬 | 덩굴 덫 | 숲 카드 · 속박 | 밤에 땅이나 적에게 놓습니다. / 주변 적을 덩굴로 묶습니다. |
| `winter_firewood` | 자원 | 겨울 장작 | 숲 카드 · 산장 보강 | 산장에 놓아 벽을 보강합니다. / 밤에도 쓸 수 있습니다. |
| `shroud_cloth` | 스킬 | 수의 | 권능 · 수의의 의식 | 오늘 밤 마녀와 아군이 / 치명타를 한 번 버팁니다. |
| `thorn_bind` | 스킬 | 가시 속박 | 권능 · 가시의 봉헌 | 밤에 땅이나 적에게 놓습니다. / 넓은 범위의 적을 가시로 묶습니다. |
| `red_chalice` | 장비·유물 | 붉은 잔 | 권능 · 붉은 만찬 | 마녀에게 놓습니다. / 오늘 밤 마법탄이 체력을 되돌립니다. |
| `hibernation_pelt` | 장비·유물 | 겨울잠 털가죽 | 전리품 · 빈 굴의 주인 | 산장에 덮습니다. / 오늘 밤 산장이 받는 피해가 절반입니다. |
| `corrupt_prayer` | 사건 | 침식된 기도문 | 침식 · 쓸 수 없음 | 사용할 수 없습니다. / 손패 한 칸을 차지합니다. |
| `poison_spore` | 사건 | 독 포자 | 침식 · 쓸 수 없음 | 사용할 수 없습니다. / 손패에 있으면 새벽마다 체력을 잃습니다. |
| `cursed_whisper` | 사건 | 저주의 속삭임 | 침식 · 쓸 수 없음 | 사용할 수 없습니다. / 손패에 있으면 아침 드로우를 막습니다. |

### 원화 내용 (겨울 숲·산장 지역, 중세 판타지)

- **이끼 붕대:** 마녀의 손이 초록 이끼를 덧댄 리넨 붕대를 감는 장면. 약초 몇 줄기, 은은한 초록 치유빛과 그에 밀려 흩어지는 보랏빛 침식 얼룩.
- **송진 횃불:** 송진을 먹인 천을 감은 거친 나무 횃불이 밤 눈밭 위로 던져져 주황 불꽃·불티를 흩뿌린다. 송진 방울이 녹아 떨어진다.
- **반딧불이 떼:** 코르크 마개를 뺀 낡은 유리병에서 반딧불이 떼가 금빛으로 쏟아져 나와 짙은 안개를 걷어 내는 밤 숲. 시설 포맷의 지붕·기둥은 글칸 밖.
- **덩굴 덫:** 눈 덮인 숲 바닥에서 가시 없는 굵은 초록 덩굴이 솟아 그림자 같은 괴물의 발목을 휘감는다. 잔혹하지 않게.
- **겨울 장작:** 단단히 쪼갠 장작 더미를 가죽 끈으로 묶어 산장 통나무 벽에 기대어 둔 모습. 서리, 약간의 눈. 목재(`timber`)와 구별되도록 쪼갠 단면·끈·겨울 보관 느낌.
- **수의:** 제단 촛불 앞에 놓인 은빛 자수가 들어간 흰 수의(얇은 천)가 은은히 빛나며 마녀를 감싸듯 펄럭인다. 엄숙하지만 섬뜩하지 않게.
- **가시 속박:** 땅에서 검붉은 가시 덩굴이 원형으로 크게 솟아 여러 그림자 괴물을 묶는 강한 마법. 가시의 봉헌(제단 의식)의 권능이므로 보랏빛 룬 원이 함께 빛난다.
- **붉은 잔:** 장식된 은·금 성배에 진홍 액체가 담겨 은은한 붉은 빛과 김이 오른다. 방패형 창 안에 세로로. 피를 직접 묘사하지 말고 포도주처럼.
- **겨울잠 털가죽:** 거대한 짐승(빈 굴의 주인)의 두껍고 회갈색인 털가죽이 산장 지붕·벽 위에 덮인 모습 또는 걸린 전리품. 서리 낀 털, 큰 발톱 하나 정도.
- **침식된 기도문:** 촛불을 든 침식된 자들이 산장 벽에 새긴 뒤틀린 보라 룬 기도문 양피지. 검보라 얼룩이 번지고 글자가 읽히지 않게 뭉개진다. 전체적으로 채도 낮고 어둡게.
- **독 포자:** 맹독 곤충이 남긴 녹·보라빛 포자 구름이 산장 창틀·손패 위로 내려앉는 장면. 작은 곤충 날개 실루엣.
- **저주의 속삭임:** 어둠 속 거대한 짐승의 울부짖음이 보라 연기 같은 속삭임 문양으로 흘러 잠든 산장 창문을 감싼다. 아침 햇살이 가려진 느낌.

침식 3종은 같은 사건 포맷이되 **어둡고 탁한 보라·검정 톤**으로 다른 카드와 한눈에 구별되게 한다(프레임 골격은 사건 승인 PNG 그대로).

## 완료 기준

1. 12종 × (원본·1024×1536·256×384) = 36개 PNG가 위 경로에 있고, 모두 RGBA·외곽 투명·라운드.
2. `godot/tools/verify_card_assets.gd`가 기존 전부 + 12종을 통과(`RESULT`/종료 코드 0)하고 `godot/assets/cards/verification.json`에 기록.
3. 갤러리 `godot/screenshots/cards/asset-gallery.png` 갱신, `art/cards/README.md`·`art/cards/manifest.json` 갱신, 실제 프롬프트 기록 `docs/prompts/cards/expansion-cards-v01-prompts.md`.
4. 최종 PNG의 제목·분류·본문을 확대해 원문과 직접 대조(오탈자·글자 깨짐 없음)하고 결과를 `art/cards/expansion-cards-v01-review.md`에 기록. 깨진 한글이 있으면 재생성.
5. 이 문서 끝에 "Codex 납품 결과" 절을 추가하고, 마지막 메시지에 생성 파일 목록·검증 결과를 요약.

## Codex 납품 결과

2026-10-17 · 요청된 12종 전부를 내장 image_gen으로 정식 제작하여 임시 PNG를 같은 경로에 덮어썼다. 모든 생성·수정 호출에 해당 역할의 승인 PNG를 실제 참고 입력으로 사용했다. 첫 생성에는 같은 역할의 기존 게임 카드도 화풍 참고로 함께 제공했다. 커밋하지 않았다.

- **납품:** `art/cards/role-format-v02/<id>.png` 12개, `godot/assets/cards/<id>.png` 12개, `godot/assets/cards/hand/<id>.png` 12개로 요청 PNG **36개**를 납품했다. 관례에 맞춰 `art/cards/rounded/<id>.png` 사본 12개도 갱신했다. 원본·게임용은 RGBA 1024×1536, 손패용은 RGBA 256×384이며 투명 라운드 외곽 검사를 통과했다. [전체 파일 목록](../../output/expansion-cards-v01/delivery.md) · [48개 경로의 치수·알파·SHA-256](../../output/expansion-cards-v01/delivery-manifest.json).
- **검증:** `package_card_assets.gd`에 12개 ID를 추가하고 `verify_card_assets.gd`에 12종의 제목·분류·본문 대조 표와 39장 기대값을 반영했다. Godot 4.7.2 패키징·헤드리스 임포트·전체 검증·갤러리 렌더 모두 종료 코드 **0**. 최종 **RESULT 1334/1334**, **실패 0**, **앞면 38종+공용 뒷면=39장 / 배포 PNG 78개**, `verification.json`의 `passed=true`다. [전체 검증](../../godot/assets/cards/verification.json) · [검증 로그](../../output/expansion-cards-v01/card-verify.log).
- **시각 검수:** 최종 배포 PNG의 제목 12개·분류 12개·본문 24문장을 1:1 픽셀 확대 시트로 원문과 직접 대조해 오탈자·깨진 한글·문구 누락 없음으로 기록했다. 긴 둘째 문장은 의미와 글자를 유지한 채 줄바꿈했다. 역할별 승인 프레임, 중세 판타지 소품과 겨울 숲/산장, 글칸 여백과 장식 침범 여부를 확인했다. [검수 기록과 카드별 확대 시트](../../art/cards/expansion-cards-v01-review.md).
- **기록:** [갤러리](../../godot/screenshots/cards/asset-gallery.png)를 1840×5390으로 갱신했다. 실제 임포트 텍스처를 밝고 어두운 배경과 손패 크기로 렌더하여 알파 합성과 축소 가독성을 확인했다. [README](../../art/cards/README.md)·[manifest](../../art/cards/manifest.json)·[실제 프롬프트와 수정 이력](../prompts/cards/expansion-cards-v01-prompts.md)·[생성 파일 선택 이력](../../output/expansion-cards-v01/generation-results.json)을 저장했다. 재현 스크립트는 `tools/run_expansion_card_pipeline.ps1`, 추가 납품 검사는 `tools/record_expansion_cards.py finalize`다.
- **보존·역할 분담:** 교체 전 임시본 24개와 기존 문서·도구·갤러리는 `output/expansion-cards-v01/before/`에 보존했다. 승인 자료와 기존 카드 PNG **118개 경로**의 SHA-256이 시작 시점과 일치한다. 이 작업에서 수정 금지 경로에 쓰지 않았고 카탈로그도 시작 시점과 바이트 단위로 같다. 작업 중 게임 스크립트 3개와 배포 EXE/PCK의 별도 변경을 관측해 보존했으며 되돌리지 않았다(세부 경로는 납품 manifest). 카탈로그 placeholder 제거·게임 코드·배포 PCK는 요청서대로 Claude 범위다.
