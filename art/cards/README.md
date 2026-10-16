# 마녀산장 카드 에셋

## 현재 실사용 — 역할별 승인 포맷 v02 전체 적용

2026-10-16 · 사용 중인 앞면 25종 + 보존용 도끼 용병 + 공용 뒷면, **27장 전체를 새 포맷으로 교체**했다. 원본 27장과 게임용·손패용 PNG 54개를 갱신했으며 기존 이름·분류·효과는 유지했다. [전체 카드별 PNG·검수·배포 기록](../../docs/card-role-format-rollout-v02.md) · [갤러리](../../godot/screenshots/cards/asset-gallery.png) · [납품 manifest](role-format-v02/delivery-manifest.json) · [내장 image_gen 실제 프롬프트](role-format-v02/generation-plan.json).

`rounded/`와 `godot/assets/cards/`가 현재 게임 소스다. 새 생성 원본은 `role-format-v02/`, 교체 전 파일은 `output/role-format-v02/before/`에 보관했다. 아래의 과거 납품 당시 수량·보존·미교체 설명은 해당 시점의 기록이다.

**신규 카드 제작 기준(2026-10-16):** 원화 생성·재제작 전에 [카드 디자인 가이드](../../docs/card-design-guide.md)를 읽고 해당 역할의 승인 개별 PNG를 실제 참고 입력으로 사용한다. 인물·스킬·자원·장비/유물·시설·사건의 포맷과 다국어 이름·설명 여백을 유지한다. 최신 시각 참조는 `art/concepts/cards/roles-individual-v02/`이며 이번 전체 교체에도 같은 기준을 사용했다.

## 이전 납품 — 마녀의 주머니 카드 v01

2026-10-16 · [요청서](../../docs/handoff/codex-pocket-cards-v01.md)의 카드 2종과 아이콘 1종. 내장 image_gen으로 원화·한글·투명 라운드 외곽을 제작했다. [실제 프롬프트·수정 이력](../../docs/prompts/cards/pocket-cards-v01-prompts.md) · [확대 검수](pocket-cards-v01-review.md).

| 신규 카드 | 원화 | 게임용 1024×1536 | 손패용 256×384 |
| --- | --- | --- | --- |
| 독버섯 (`poison_mushroom`) | [PNG](rounded/poison_mushroom.png) | [PNG](../../godot/assets/cards/poison_mushroom.png) | [PNG](../../godot/assets/cards/hand/poison_mushroom.png) |
| 오래된 마법서적 (`old_spellbook`) | [PNG](rounded/old_spellbook.png) | [PNG](../../godot/assets/cards/old_spellbook.png) | [PNG](../../godot/assets/cards/hand/old_spellbook.png) |

아이콘: [icon_discard.png](../../godot/assets/ui/icons/icon_discard.png), RGBA 96×96, 투명 바깥, 옆으로 쌓인 카드와 먼지. [생성 master](../ui/pocket-cards-v01/icon_discard.png) · [밝고 어두운 배경 검수](../../output/pocket-cards-v01/icon-proof.png).

현재 전체 검사·갤러리는 기존 22장 + 별도 숲 카드 3장 + 새 카드 2장 = **앞면 26종 + 공용 뒷면 1종, 총 27장/배포 PNG 54개**를 포함한다. 기존 카드 PNG는 재작성하지 않는다. `package_card_assets.gd`에 ID 선택 인자를 추가해 이번 두 카드만 크롭·Lanczos 정규화한다. 숲 카드 3종은 원래 `package_occult_card_assets.gd`의 알파 기준(모서리 ≤16/255, 중앙 ≥230/255)을 유지해 검사한다. 그 외 기존 카드와 새 두 카드는 엄격한 모서리·중앙·외곽 검사를 적용한다.

[카드 검증 JSON](../../godot/assets/cards/verification.json) · [전체 갤러리](../../godot/screenshots/cards/asset-gallery.png) · [7개 납품 PNG·해시](../../output/pocket-cards-v01/delivery-manifest.json) · [UI 검사](../../output/pocket-cards-v01/asset-verification.json).

최종 검증 결과는 카드 27장/배포 PNG 54개와 신규 원화·배포 PNG 6개 및 아이콘 1개 모두 통과(실패 0)다. 최종 제목·분류·본문을 원본 픽셀 확대 시트에서 직접 확인해 오탈자 없음. 동시 작업에서 새 카드 카탈로그 등록이 반영되어 최종 `catalog_integration_complete=true`, `pending_catalog_ids=[]`다.

카탈로그·게임 구현은 요청서의 Claude 범위다. 검증은 새 PNG와 Godot 로딩을 직접 확인하며, 아직 등록되지 않은 ID는 `pending_catalog_ids`로 분리한다. 카탈로그 등록이 있으면 제목·분류·인쇄 문구도 요청서와 대조한다.

재현:

```powershell
& "$PSHOME/powershell.exe" -NoProfile -ExecutionPolicy Bypass -File godot/art_sources/run_pocket_asset_pipeline.ps1
```

이번 에셋 작업에서는 스크립트·카탈로그·씬·셰이더·`verify_pocket*.gd`에 쓰지 않았고 동시 작업 변경을 보존한다. 커밋하지 않는다.

---

## 이전 납품 — 용병 직업·야생 동물·유물 v01


### 당시 납품 기록

2026-10-15 · [요청서](../../docs/handoff/codex-jobs-update-v01.md)의 새 카드 13종, 아이콘 11종, 동물 GLB/tscn 각 2종, 상자 이미지 2장과 Blender 원본을 납품했다. [전체 57개 경로](../../output/jobs-update-v01/delivery.md) · [SHA-256 목록](../../output/jobs-update-v01/delivery-manifest.json) · [확대 검수](jobs-update-v01-review.md) · [실제 프롬프트](../../docs/prompts/cards/jobs-update-v01-prompts.md).

![현재 전체 카드 갤러리](../../godot/screenshots/cards/asset-gallery.png)

기존 **앞면 8종 + 새 앞면 13종 + 공용 뒷면 = 총 22장**이다. 요청서의 “기존 9종”은 뒷면을 포함하므로 “22종+뒷면”과 1장 차이가 있으며, 위의 실제 ID 수량으로 검증했다. 사용 중단된 도끼 용병도 보존한다. 동시에 추가된 숲 확장 카드 3종은 별도 작업으로 보존하고 이번 갤러리/검사 범위에 넣지 않았다.

| 신규 에셋 | 원화 | 게임용 1024×1536 | 손패용 256×384 |
| --- | --- | --- | --- |
| 나무꾼 (`lumberjack`) | [PNG](rounded/lumberjack.png) | [PNG](../../godot/assets/cards/lumberjack.png) | [PNG](../../godot/assets/cards/hand/lumberjack.png) |
| 사냥꾼 (`hunter`) | [PNG](rounded/hunter.png) | [PNG](../../godot/assets/cards/hunter.png) | [PNG](../../godot/assets/cards/hand/hunter.png) |
| 전투용병 (`warrior`) | [PNG](rounded/warrior.png) | [PNG](../../godot/assets/cards/warrior.png) | [PNG](../../godot/assets/cards/hand/warrior.png) |
| 채집가 (`gatherer`) | [PNG](rounded/gatherer.png) | [PNG](../../godot/assets/cards/gatherer.png) | [PNG](../../godot/assets/cards/hand/gatherer.png) |
| 생고기 (`raw_meat`) | [PNG](rounded/raw_meat.png) | [PNG](../../godot/assets/cards/raw_meat.png) | [PNG](../../godot/assets/cards/hand/raw_meat.png) |
| 토끼 가죽 (`rabbit_pelt`) | [PNG](rounded/rabbit_pelt.png) | [PNG](../../godot/assets/cards/rabbit_pelt.png) | [PNG](../../godot/assets/cards/hand/rabbit_pelt.png) |
| 보물상자 (`treasure_chest`) | [PNG](rounded/treasure_chest.png) | [PNG](../../godot/assets/cards/treasure_chest.png) | [PNG](../../godot/assets/cards/hand/treasure_chest.png) |
| ? (`relic_unknown`) | [PNG](rounded/relic_unknown.png) | [PNG](../../godot/assets/cards/relic_unknown.png) | [PNG](../../godot/assets/cards/hand/relic_unknown.png) |
| 달빛 부적 (`moonlit_charm`) | [PNG](rounded/moonlit_charm.png) | [PNG](../../godot/assets/cards/moonlit_charm.png) | [PNG](../../godot/assets/cards/hand/moonlit_charm.png) |
| 화로의 온기석 (`hearth_ember`) | [PNG](rounded/hearth_ember.png) | [PNG](../../godot/assets/cards/hearth_ember.png) | [PNG](../../godot/assets/cards/hand/hearth_ember.png) |
| 고목의 심장 (`old_tree_heart`) | [PNG](rounded/old_tree_heart.png) | [PNG](../../godot/assets/cards/old_tree_heart.png) | [PNG](../../godot/assets/cards/hand/old_tree_heart.png) |
| 늑대 송곳니 목걸이 (`wolf_fang_pendant`) | [PNG](rounded/wolf_fang_pendant.png) | [PNG](../../godot/assets/cards/wolf_fang_pendant.png) | [PNG](../../godot/assets/cards/hand/wolf_fang_pendant.png) |
| 서리 여왕의 눈물 (`frost_queen_tear`) | [PNG](rounded/frost_queen_tear.png) | [PNG](../../godot/assets/cards/frost_queen_tear.png) | [PNG](../../godot/assets/cards/hand/frost_queen_tear.png) |

모든 카드 소스/배포 파일은 RGBA PNG다. 보라색 물리 프레임, 비대칭 검은 S자, 크림색 패널, 한글 붓글씨와 겨울 숲 붓터치를 유지한다. 그림·글씨·모서리 수정은 내장 image_gen으로 수행했고, 코드로는 크롭·Lanczos 크기 정규화만 했다. 가격·체력·공격력·지속시간 수치를 인쇄하지 않았다.

- 아이콘: `godot/assets/ui/icons/icon_{timber,raw_meat,rabbit_pelt,treasure_chest,relic_unknown,moonlit_charm,hearth_ember,old_tree_heart,wolf_fang_pendant,frost_queen_tear,arrow}.png`, RGBA 96×96. [실물/확대 확인](../../output/jobs-update-v01/icon-proof.png).
- 상자: [닫힘](../../godot/assets/ui/chest_closed.png) / [열림](../../godot/assets/ui/chest_open.png), RGBA 512×512. 보물상자 카드와 같은 둥근 참나무·철띠·달 문양 자물쇠.
- 동물: [rabbit.glb](../../godot/assets/nature/rabbit.glb), [deer.glb](../../godot/assets/nature/deer.glb), 각각 같은 이름의 [자연물 래퍼 폴더](../../godot/scenes/props/nature/). [wildlife.blend](../../godot/art_sources/wildlife.blend), [3D 납품 메모](../../docs/wildlife-assets-v01.md).
- 원화 master: `art/ui/jobs-update-v01/*.png` 13개. 생성 알파를 유지한 축소만 수행했다.

[카드 검증](../../godot/assets/cards/verification.json)은 **22장/배포 PNG 44개 통과**, [UI·동물 검증](../../output/jobs-update-v01/asset-verification.json)은 **UI PNG 13개 + GLB/tscn 4개 통과**다. Godot 4.7.2 헤드리스 임포트와 실제 갤러리·Forward+ 동물 렌더를 완료했다. 최종 배포 카드의 제목·분류·두 줄 문구를 원본 픽셀 확대 시트에서 대조했고 **오탈자 없음**을 확인했다. 미공개 유물의 본문은 비워 두었다.

현재 작업 재현은 아래 순서다. Blender 재제작은 `build_wildlife.py`를 먼저 실행한다.

```powershell
python godot/art_sources/package_jobs_ui.py
# 프로세스 범위에서만 실행 정책을 지정한다.
& "$PSHOME/powershell.exe" -NoProfile -ExecutionPolicy Bypass -File godot/art_sources/run_jobs_asset_pipeline.ps1
python godot/art_sources/record_jobs_assets.py
python godot/art_sources/write_jobs_asset_docs.py
```

게임 규칙·AI·UI 연결·카탈로그·main.tscn·shaders는 이 에셋 작업에서 수정하지 않았다. 이 범위에 생긴 동시 작업의 변경은 보존했다. 커밋하지 않았다.

---

## 이전/별도 납품 기록

아래 숲 확장 3종과 최초 카드 납품 설명은 이력으로 보존한다. 아래의 이전 재생성 명령과 8종/18개 검사 수치는 당시 기록이며, 현재 재생성은 위 v01 절차를 사용한다.


2026-10-15 · 내장 image_gen 생성/수정 · 기존 8종 + 숲 확장 2종 + 공용 뒷면

## 숲 확장 카드 v01

**잠자는 가시 씨앗·목장의 검은 양**을 기존 보라색 프레임·검은 S자 곡선·크림색 패널·한글 붓글씨와 같은 세트로 제작했다. 후속 게임 적용에서 생산물 **검은 털** 카드를 추가하고 카탈로그·시작 지급·설치·생산·수확·공물 강화까지 연결했다. [사용법과 검증](../../docs/occult-cards-runtime.md).

| 카드 | 원화 1024×1536 | 게임용 1024×1536 | 손패용 256×384 |
| --- | --- | --- | --- |
| 잠자는 가시 씨앗 | [PNG](rounded/sleeping_thorn_seed.png) | [PNG](../../godot/assets/cards/sleeping_thorn_seed.png) | [PNG](../../godot/assets/cards/hand/sleeping_thorn_seed.png) |
| 목장의 검은 양 | [PNG](rounded/black_sheep.png) | [PNG](../../godot/assets/cards/black_sheep.png) | [PNG](../../godot/assets/cards/hand/black_sheep.png) |
| 검은 털 | [PNG](rounded/black_wool.png) | [PNG](../../godot/assets/cards/black_wool.png) | [PNG](../../godot/assets/cards/hand/black_wool.png) |

원화는 생성본 그대로 복사했고 게임용은 RGBA PNG로 저장, 손패용은 Godot Lanczos로 축소했다. 그림·글씨·생성 알파를 수정하지 않았다. 9개 PNG의 크기·알파·해시 검사는 [검증 목록](occult-cards-v01.json)에 기록했으며 모두 통과했다. [두 카드 생성 프롬프트](../../docs/prompts/cards/occult-cards-v01-prompts.md)와 [검은 털 프롬프트](../../docs/prompts/cards/black-wool-v01-prompt.md)도 보존한다. 재패키징은 `godot/tools/package_occult_card_assets.gd`를 사용한다.

아래 갤러리와 기존 8종·공용 뒷면의 납품 기록은 숲 확장 카드 추가 전 자료다.

![카드 전체 미리보기](../../godot/screenshots/cards/asset-gallery.png)

기존 도끼 용병·양털·목재·숲의 괴물에 **서리 룬·수호 등불·숙박 초대장·새끼양**을 추가했다. 보라색 물리 프레임, 검은 비대칭 S자 곡선, 크림색 제목/설명 패널, 굵은 한글 붓글씨와 겨울 숲의 붓터치 질감을 공유한다. 네 모서리는 살짝 둥글고 카드 밖은 투명 알파다. 배경색과 그림자는 PNG에 합성하지 않았다.

| 에셋 | 원화 | 게임용 1024×1536 | 손패용 256×384 |
| --- | --- | --- | --- |
| 도끼 용병 | [PNG](rounded/axe_mercenary.png) | [PNG](../../godot/assets/cards/axe_mercenary.png) | [PNG](../../godot/assets/cards/hand/axe_mercenary.png) |
| 양털 | [PNG](rounded/wool.png) | [PNG](../../godot/assets/cards/wool.png) | [PNG](../../godot/assets/cards/hand/wool.png) |
| 목재 | [PNG](rounded/timber.png) | [PNG](../../godot/assets/cards/timber.png) | [PNG](../../godot/assets/cards/hand/timber.png) |
| 숲의 괴물 | [PNG](rounded/forest_monster.png) | [PNG](../../godot/assets/cards/forest_monster.png) | [PNG](../../godot/assets/cards/hand/forest_monster.png) |
| 서리 룬 | [PNG](rounded/frost_rune.png) | [PNG](../../godot/assets/cards/frost_rune.png) | [PNG](../../godot/assets/cards/hand/frost_rune.png) |
| 수호 등불 | [PNG](rounded/ward_lantern.png) | [PNG](../../godot/assets/cards/ward_lantern.png) | [PNG](../../godot/assets/cards/hand/ward_lantern.png) |
| 숙박 초대장 | [PNG](rounded/guest_invitation.png) | [PNG](../../godot/assets/cards/guest_invitation.png) | [PNG](../../godot/assets/cards/hand/guest_invitation.png) |
| 새끼양 | [PNG](rounded/lamb.png) | [PNG](../../godot/assets/cards/lamb.png) | [PNG](../../godot/assets/cards/hand/lamb.png) |
| 공용 뒷면 | [PNG](rounded/card_back.png) | [PNG](../../godot/assets/cards/card_back.png) | [PNG](../../godot/assets/cards/hand/card_back.png) |

원화 9개, 배포 PNG 18개는 모두 RGBA·세로 2:3이다. 신규 납품은 위 네 카드의 원화·게임용·손패용 **12개 PNG**다. 원화는 생성 PNG를 그대로 복사했다. Godot 패키징은 불투명 카드 본체 기준 크롭과 Lanczos 리사이즈만 수행하며, 생성 알파를 유지한다. 코드로 그림·한글·라운드 마스크를 그리지 않는다.

가격·체력·공격력·지속시간 같은 시험 수치를 그림에 넣지 않았다. 새끼양의 “이틀 뒤”는 요청서에서 지정한 인쇄 문구다. 상세 수치·설명·그림자는 런타임 UI에서 처리한다.

## Godot에서 사용

게임에는 `res://assets/cards/<id>.png`와 `res://assets/cards/hand/<id>.png`를 사용한다. `scripts/ui/card_catalog.gd`의 `texture(id)`와 `texture(id, true)`로 불러온다. 텍스처는 조명·색보정을 적용하지 않고 비율을 유지해 표시한다. 카탈로그·게임 로직·씬은 Claude 작업 범위이며 이번 에셋 작업에서 수정하지 않았다.

## 제작 기록

- [신규 카드 요청서](../../docs/handoff/codex-new-cards-v01.md)
- [기존 4종 프롬프트](../../docs/prompts/cards/production-rounded-v02-prompts.md)
- [신규 4종 프롬프트와 최종 채택 기록](../../docs/prompts/cards/new-cards-v01-prompts.md)
- [파일 목록·SHA-256·이미지 메타데이터](manifest.json)
- [최종 확대 검수 기록](new-cards-v01-review.md)
- [신규 카드 인쇄 문구 원본 크기 모음](../../godot/screenshots/cards/new-cards-v01-text-proof.png)

이전 승인 원본과 시안은 `art/concepts/cards/`에 보존한다. 현재 원화는 `art/cards/rounded/`, 배포 파일은 `godot/assets/cards/`에 둔다.

## 재생성과 확인

Windows GUI 실행 파일은 PowerShell에서 다음 명령을 순서대로 완료하기 전에 반환할 수 있으므로, `Start-Process -Wait`로 각 단계가 끝난 뒤 다음 단계를 실행한다.

```powershell
$cardExe = (Resolve-Path '.tools/Godot-4.7.2.exe').Path
$cardLogDir = (Resolve-Path 'godot/art_sources').Path
# 제한된 환경에서는 에디터의 사용자 캐시도 프로젝트 output 아래에 둔다.
New-Item -ItemType Directory -Force output/new-cards-v01-runtime/roaming,output/new-cards-v01-runtime/local | Out-Null
$env:APPDATA = (Resolve-Path output/new-cards-v01-runtime/roaming).Path
$env:LOCALAPPDATA = (Resolve-Path output/new-cards-v01-runtime/local).Path
$cardJobs = @(
    @('--headless','--script','res://tools/package_card_assets.gd'),
    @('--headless','--editor','--import'),
    @('--headless','--script','res://tools/verify_card_assets.gd'),
    @('--script','res://tools/preview_card_assets.gd','--rendering-method','gl_compatibility'),
    @('--headless','--script','res://tools/update_card_manifest.gd')
)
foreach ($cardJob in $cardJobs) {
    $cardArgs = @('--path','godot','--log-file',('"' + $cardLogDir + '/card-rebuild.log"')) + $cardJob
    $cardProcess = Start-Process -FilePath $cardExe -ArgumentList $cardArgs -Wait -PassThru -WindowStyle Hidden
    if ($cardProcess.ExitCode -ne 0) { throw "Card pipeline failed: $cardJob" }
}
```

## 납품 검증 결과

- [PNG·카탈로그·Godot 로딩 검사](../../godot/assets/cards/verification.json): **8종+공용 뒷면, 배포 PNG 18개 통과**. 크기·RGBA·투명 모서리·중앙/외곽 불투명도·텍스처 로딩·ID·신규 문구와 카탈로그 일치를 확인한다. 현재 카탈로그의 없는 카드 ID에 대한 뒷면 대체도 검사한다.
- [갤러리](../../godot/screenshots/cards/asset-gallery.png): 실제 임포트된 8종과 뒷면을 밝고 어두운 패널에 3×3으로 렌더했다. 각 칸 오른쪽에 손패 PNG를 표시한다.
- 신규 4종 최종 게임용 PNG의 제목·분류·두 줄 본문을 확대해서 요청서와 직접 대조했다. 오탈자를 발견하지 않았다.
- [기존 배포 포함 검사](export-verification.json)는 **2026-10-13 기존 4종+뒷면의 기록**이다. 이번 신규 4종의 PCK 내보내기 검증은 수행하지 않았다.
- Godot 실행 시 시스템 인증서 저장소 읽기 오류가 로그에 남는다. 로컬 PNG 패키징·임포트·텍스처 검증·갤러리 생성은 정상 완료했다.
