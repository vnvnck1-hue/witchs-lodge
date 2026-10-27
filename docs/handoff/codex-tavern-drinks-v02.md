# Codex에게 요청하는 에셋 작업 — 에린의 새 술 카드 3장 + 전투 연출 텍스처 3장 (v02)

요청자: Claude (게임 구현 담당) · 2026-10-27 · 카드 기준: [카드 디자인 가이드](../card-design-guide.md) · 글자 규칙: [카드 글자 런타임](../card-text-runtime.md) · 기존 주점 카드: [tavern-cards-v01](../tavern-cards-v01.md)

## 사용자 요청 (그대로)

> 술주정뱅이 에린에서 나오는 술 카드 세개 더 추가해줘
>
> 1. 광역기 스킬 카드. 지면에 사용하면 불타는 장판을 만드는 술 카드
> 2. 광역기 스킬 카드. 지면에 사용하면 적이 2초간 얼어붙어서 완전한 얼음이 되어버린다.
> 3. 트레이드오프 카드. 카드 이름은 [건배!] 이며, 에린이 술잔을 치켜들며 즐거워하는 카드 이미지. 모든 용병이 술에 취해 5초동안 공격속도와 공격력이 오른다. 단, 5초가 지나면 2초동안 용병들이 전투불능 상태가 되고 각자의 자리에서 바닥에 오바이트를 한다.
>
> 1,2번 카드는 너가 적당한 이름과 적당한 카드 이미지를 사용해줘. 필요한 에셋들은 모두 코덱스에게 요청해줘

## 만들 카드 (원화에는 글자를 넣지 말 것 — 게임이 그린다)

| id | 역할 포맷 · 편집 대상 | 게임이 그릴 글자 |
| --- | --- | --- |
| `dragon_breath` | **스킬** 마름모 — 승인 원본 [따뜻한 환대](../../art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png), 편집 대상 `godot/assets/cards/resin_torch.png` | 제목 `용의 숨결` · 분류 `주점 · 불 지르는 술` · 설명 `땅에 던지면 불바다가 번집니다.` / `그 위의 적은 계속 불탑니다.` |
| `frost_giant_spirit` | **스킬** 마름모 — 같은 승인 원본, 편집 대상 `godot/assets/cards/frost_rune.png` | 제목 `서리 거인의 독주` · 분류 `주점 · 얼리는 술` · 설명 `땅에 던지면 주변 적이` / `2초 동안 통째로 얼어붙습니다.` |
| `cheers` | **사건** 장면창 — 승인 원본 [금지된 수확제](../../art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png), 편집 대상 `godot/assets/cards/drunk_rant.png`(에린이 나오는 주점 사건 카드) | 제목 `건배!` · 분류 `주점 · 건배하는 술` · 설명 `모든 용병이 5초 동안 더 빠르고 세게 싸웁니다.` / `그 뒤 2초 동안 주저앉아 게워 냅니다.` |

### 그림 내용

1. **용의 숨결 (`dragon_breath`)** — 마름모 가운데에 주둥이가 용머리 모양으로 조각된 **두꺼운 갈색 도기 술병**(마개 대신 헝겊 심지에 불이 붙어 있음)이 기울어져 있고, 병에서 쏟아진 술이 눈 덮인 땅 위에 **넓게 번진 주황·진홍 불바다 웅덩이**로 타오른다. 불꽃 혀는 낮고 넓게(장판 느낌). 술병 실루엣과 불 웅덩이가 손패 256×384 에서도 한눈에 읽혀야 한다. 사람·용 전체·글자 금지.
2. **서리 거인의 독주 (`frost_giant_spirit`)** — 마름모 가운데에 **서리가 하얗게 낀 푸른 유리 술병**(거인의 투박한 손자국 모양 각인, 굵은 밧줄 손잡이). 병 입구에서 흘러내린 술이 땅에 닿은 자리부터 **뾰족한 얼음 결정 무더기가 사방으로 솟고**, 그 안에 **늑대 실루엣 하나가 통째로 투명한 얼음 덩어리 속에 갇혀** 있다(몬스터가 '완전한 얼음'이 된다는 것을 보여줌). 차가운 청록·하늘색·흰색. 사람·글자 금지.
3. **건배! (`cheers`)** — **술 주정뱅이 에린**이 주인공. 에린의 얼굴·머리색·복장은 `godot/assets/cards/drunken_erin.png` 와 `art/cards/tavern-v01/drafts/drunken_erin_v02.png` 를 **실제 이미지 참고 입력**으로 써서 같은 인물로 유지한다(금발, 발그레한 볼). 장면: 산장 주점의 따뜻한 등불 아래 에린이 **거품이 넘치는 나무 맥주잔을 머리 위로 높이 치켜들고** 눈을 감은 채 활짝 웃으며 즐거워한다. 거품·맥주 방울이 튀고, 배경에 다른 용병들의 잔(손과 잔만, 얼굴 없이) 두세 개가 함께 부딪히는 모습. 유쾌하고 사랑스럽게. 구토 장면은 그리지 않는다. 노출·과한 성적 표현 금지, 글자 금지.

공통: 중세 기반 판타지 수채·먹선 화풍, 큰 색면, 또렷한 먹선(기존 카드와 같은 화풍). 참고 카드: `godot/assets/cards/fire_ale.png`, `godot/assets/cards/frost_rune.png`, `godot/assets/cards/resin_torch.png`.

## 전투 연출 텍스처 (게임 안 바닥·얼음 표현용)

| 경로 | 규격 | 내용 |
| --- | --- | --- |
| `godot/assets/vfx/tavern/fire_pool.png` | RGBA 512×512, 바깥 투명 | 위에서 내려다본 **둥근 불바다 웅덩이**. 가운데 노랑·주황, 가장자리 진홍→투명으로 불규칙하게 번지는 불꽃 가장자리. 바닥에 납작하게 깔리는 데칼로 쓴다(게임이 회전·깜빡임을 준다). 카드와 같은 수채·먹선 톤, 사진풍 금지. |
| `godot/assets/vfx/tavern/ice_block.png` | RGBA 512×512, **가로·세로 이어 붙여도 이음새가 없는(tileable)** 불투명~반투명 | 몬스터를 감싸는 **얼음 덩어리 표면** 질감. 하늘색·청록 바탕에 흰 금·서리 결, 굵지 않은 먹선 몇 줄. 알파 160~230 사이의 반투명으로 속이 살짝 비친다. 상자·구 메시에 감아 쓴다. |
| `godot/assets/vfx/tavern/vomit_puddle.png` | RGBA 256×256, 바깥 투명 | 위에서 본 **작은 토사물 웅덩이** 데칼. 귀엽고 만화적으로(연노랑·연두 색면에 거품 방울 몇 개, 먹선 윤곽). 역겹거나 사실적이지 않게. |

## 반드시 지킬 것

1. **카드 글자는 이미지가 아니라 게임이 그린다(사용자 확정 2026-10-20).** 제목판·분류줄·설명판은 **비워 둔다**. 글자·숫자·기호 금지.
2. 각 역할의 승인 원본(위 표)을 **실제 이미지 참고 입력**으로 쓰고, 표의 편집 대상 카드(글자 없는 게임용 판)를 바탕으로 **그림 창 안만** 새로 그려 합성해 프레임·이름판·설명판 골격을 기존 카드와 같게 유지한다. 마름모 아래 꼭짓점·장식이 설명 안전 영역(x=110..914, y=1185..1445)과 제목 안전 영역(x=110..914, y=72..236)을 침범하지 않는다.
3. 카드: RGBA **1024×1536**, 네 모서리 라운드·모서리 바깥 투명. 손패용은 같은 그림을 **RGBA 256×384** 로 축소.
4. 사람(에린 제외)·현대 물건 금지, 중세 기반 판타지 기준(프로젝트 CLAUDE.md).

## 역할 분담·수정 금지

- **Codex 책임:** 위 카드 3장 + 텍스처 3장의 생성·합성·축소·검증·기록.
- **Claude 책임:** 게임 코드·카탈로그·판 프로파일·검증 스크립트·실행파일 내보내기·커밋. 원화가 오기 전까지 게임은 임시 그림으로 동작한다(지금 임시 PNG 가 같은 경로에 있으면 덮어쓰기).
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/tools/**`, `godot/assets/cards/catalog.json`, `godot/assets/cards/catalog_en.json`, `godot/assets/cards/text_layout.json`, `godot/assets/cards/packaging.json`, `godot/project.godot`, 다른 모든 카드 PNG, 루트 `WitchsLodge.exe`. 다른 작업의 변경을 되돌리지 말 것. **커밋하지 말 것.** `git stash`·`git checkout`·`git reset` 금지. Claude 가 같은 저장소에서 동시에 작업 중이다.

## 산출물 경로

| 용도 | 경로 |
| --- | --- |
| 생성 원본·초안 | `art/cards/tavern-v07/<id>.png`, 미채택은 `art/cards/tavern-v07/drafts/` |
| 게임용 | `godot/assets/cards/<id>.png` — RGBA 1024×1536 |
| 손패용 | `godot/assets/cards/hand/<id>.png` — RGBA 256×384 |
| 텍스처 | 위 표의 `godot/assets/vfx/tavern/*.png` |
| 프롬프트 기록 | `docs/prompts/cards/tavern-v07-prompts.md` |
| 미리보기 시트 | `godot/screenshots/tavern-v07/card-sheet.png` — 새 카드 3장 + `fire_ale`·`drunk_rant` 나란히, 텍스처 3장 밝고 어두운 배경 |
| 검증 기록 | `output/tavern-v07/verification.json` — 크기·채널·모서리 알파·tileable 이음새 검사·SHA-256·`passed` |

`.import` 파일은 Claude 가 `--import` 로 다시 만든다.

## 완료 기준

1. 카드 게임용 + 손패용 6개, 텍스처 3개가 위 규격으로 저장됨. 카드 모서리 바깥 투명. 글자·숫자 없음.
2. 손패 크기에서도 불 술병·얼음 술병·건배하는 에린이 한눈에 읽힌다. 건배! 의 에린이 기존 에린 카드와 같은 인물로 보인다.
3. 스킬 2장은 마름모 골격, 건배! 는 사건 골격이 기존 카드와 같고 글 안전 영역이 비어 있다.
4. 검증 JSON `passed=true`, 미리보기 시트 저장.
5. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절(파일 목록, 재생성 이유, 남은 문제)을 붙이고 마지막 메시지에 같은 요약. 기준 미달은 숨기지 말고 적는다.


## Codex 납품 결과 · 2026-10-27

내장 `image_gen`으로 글자 없는 카드 원화 3종과 VFX 텍스처 3종을 제작하고, 기존 게임용 카드의 그림 창 안에 합성했다. 역할별 승인 PNG를 실제 참고 입력으로 사용했으며, 건배!는 요청된 에린 참고 PNG 두 장을 모두 입력했다. 커밋하지 않았다.

### 납품 파일

| 구분 | 파일 | 규격 |
| --- | --- | --- |
| 카드 원본 | `art/cards/tavern-v07/dragon_breath.png`, `frost_giant_spirit.png`, `cheers.png` | 각각 RGBA 1024×1536, 아래 게임용과 SHA-256 동일 |
| 게임용 | `godot/assets/cards/dragon_breath.png` | RGBA 1024×1536 |
| 게임용 | `godot/assets/cards/frost_giant_spirit.png` | RGBA 1024×1536 |
| 게임용 | `godot/assets/cards/cheers.png` | RGBA 1024×1536 |
| 손패용 | `godot/assets/cards/hand/dragon_breath.png` | RGBA 256×384 |
| 손패용 | `godot/assets/cards/hand/frost_giant_spirit.png` | RGBA 256×384 |
| 손패용 | `godot/assets/cards/hand/cheers.png` | RGBA 256×384 |
| VFX | `godot/assets/vfx/tavern/fire_pool.png` | RGBA 512×512, 바깥 투명 |
| VFX | `godot/assets/vfx/tavern/ice_block.png` | RGBA 512×512, 상하·좌우 반복 가능, 알파 171–229 |
| VFX | `godot/assets/vfx/tavern/vomit_puddle.png` | RGBA 256×256, 바깥 투명 |
| 생성 초안·원화 | `art/cards/tavern-v07/drafts/` | 첫 스킬 시안 2장, 보완 원화 2장, 사건 생성본 1장, VFX 생성본 3장 |
| 실제 프롬프트·참고 입력·합성 기록 | [tavern-v07-prompts.md](../prompts/cards/tavern-v07-prompts.md) | 내장 생성 8회와 보완 이유 |
| 비교 미리보기 | [card-sheet.png](../../godot/screenshots/tavern-v07/card-sheet.png) | 신규 카드 3장 + 기존 fire_ale·drunk_rant, VFX 3종의 밝고 어두운 배경 |
| 얼음 반복 미리보기 | [ice-tile-2x2.png](../../output/tavern-v07/ice-tile-2x2.png) | 2×2 반복 배치 |
| 검증 | [verification.json](../../output/tavern-v07/verification.json) | `passed=true`, 치수·RGBA·알파·안전 영역·이음새·SHA-256 |
| 재현용 작업 기록 | `output/tavern-v07/prepare-assets.ps1`, `measure-assets.ps1`, `*-art-mask.png`, `reference-snapshots/`, `protected-before.json`, `protected-after.json` | 에셋 준비·측정·참조·읽기 전용 해시 비교 기록 |

### 재생성·정리 이유

- 첫 스킬 시안의 술병·얼음이 마름모 테두리를 가렸고 용의 숨결의 불붙은 헝겊 심지가 불분명해, 스킬 2종은 프레임 없는 원화로 보완 생성했다. 술병·불 웅덩이·얼음 속 늑대가 작은 손패에서도 구분되도록 중앙 장면을 배치했다.
- 편집 대상의 기존 횃불·얼음이 가렸던 마름모 구간은 같은 스킬 포맷의 `frost_rune` 프레임으로 복원했다. 하단 우측은 가려지지 않은 좌측 대응 구간을 대칭 복사했다. 제목판·설명판은 편집 대상의 글자 없는 원본 픽셀을 보존했다.
- 카드 네 모서리는 둥근 외곽 밖을 완전 투명으로 정리했다. 반투명 원본의 RGB를 바꾸던 라이브러리 재그리기 변환을 제거하고, 원본 복제 후 그림 창만 합성했다.
- 얼음 표면은 알파를 요청 범위로 정규화하고 48px 가장자리 블렌딩으로 연결했다. 불·토사물의 실제 생성 알파는 보존했다.

### 검증 및 남은 문제

- 카드 원본·게임용·손패용 9개와 VFX 3개, 총 12개 PNG의 규격·채널·SHA-256을 기록했다. 카드 6개 배포본의 네 모서리 알파는 모두 0이다.
- 게임용 카드 3장의 제목 안전 영역·설명 안전 영역은 각각 원본과 픽셀 차이 **0**이다. 합성 마스크·프레임 복원·외곽 알파 정리 외의 픽셀 차이도 **0**이다. 카드에 글자·숫자를 인쇄하지 않았다.
- 불·토사물은 이미지 바깥 테두리 전체 알파 0이다. 얼음은 좌우·상하 가장자리의 RGBA 최대·평균 차이 **0**, 측정 알파 **171–229**로 기준을 통과했다. 2×2 반복과 밝고 어두운 배경을 시각 확인했다.
- 손패 크기의 주요 형태, 에린 동일 인물성, 사건·스킬 역할 골격과 빈 글판을 시각 검수했다. 문구·인물·화풍 검수는 시각 판단이며 OCR·얼굴 인식 결과로 표시하지 않았다.
- **현재 확인된 에셋 규격 미달 없음.** 실제 게임의 렌더링·효과·판 프로파일·런타임 글자 배치 검증, `.import` 재생성 및 실행파일 내보내기는 요청서대로 Claude 담당으로 남긴다.
- Codex는 수정 금지 경로·기존 다른 카드 PNG·루트 exe에 쓰지 않았으며, git stash·checkout·reset·커밋을 실행하지 않았다. 읽기 전용 보호 경로 1,700개 해시 비교 중 `godot/scripts/visual/vfx/tavern_drink_vfx.gd` 1건의 동시 작업 변경을 관찰했다. 이 파일은 Codex가 작성·수정하거나 되돌리지 않았다. 비교 기록을 그대로 보존했다.
