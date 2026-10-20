# 캐릭터 3D 적용 프로세스 — 원화부터 게임까지

2026-10-19 시작. 사용자가 단계별로 직접 안내하는 캐릭터 3D 제작 절차를 기록한다. 첫 대상은 **고블린 니브**(여행자·행상인).
각 단계는 사용자 승인을 받은 뒤 다음으로 넘어간다. 안내받지 않은 단계는 "미정"으로 두고 추측으로 채우지 않는다.

| 역할 | 담당 |
| --- | --- |
| 원화(2D) | Codex — 요청서는 `docs/handoff/codex-*.md`, Claude 가 Codex CLI 로 직접 요청 |
| 3D 모델 생성 | Tripo — 웹 앱(구독 크레딧)을 Claude 가 Chrome 으로 조작. API 크레딧은 쓰지 않는다(사용자 결정 2026-10-19) |
| 게임 적용 | Claude — Godot 임포트·연결·헤드리스 검증·실행파일 |
| 승인 | 사용자 — 단계마다 |

## 1단계 · 모델링용 3/4뷰 원화 시안 2개 (Codex) → 사용자 승인

- 그 캐릭터가 **게임에서 이미 쓰는 원화가 있으면 그것을 기준**으로, 3D 모델링에 쓸 **3/4뷰(반측면) 전신 원화 시안 2개**를 Codex 에게 요청한다.
- 정체성(얼굴·색·의상·소품)은 기존 원화를 따르고, 게임 비례(2~3등신 SD)·모델링에 맞는 자세·투명 배경으로 바꾼다.
- 결과를 사용자에게 보여 주고 **한 개를 승인받는다.** 승인 전에는 다음 단계로 가지 않는다. 반려되면 피드백·레퍼런스를 기록하고 버전을 올려(v02…) 다시 요청한다.
- **화풍 기준(사용자 지정 2026-10-19):** 카드·초상의 세밀한 일러스트가 아니라 [장난감 같은 단순 SD 레퍼런스](../art/references/characters/stylized-toy-chibi-ref-01.png) 수준으로 크게 스타일라이징·단순화한다.
- 산출물: `art/concepts/characters/<id>-model-v01/` (시안 PNG 2장 + `generation.md` 실제 프롬프트·검수).

### 니브 기록

- 기준 원화: `art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png`(카드 원화), `godot/assets/portraits/guest_nib_cutout.png`(게임 초상).
- 요청서: [codex-goblin-nib-model-3q-v01.md](handoff/codex-goblin-nib-model-3q-v01.md)
- v01: 2026-10-19 Codex 시안 2장(`art/concepts/characters/goblin-nib-model-v01/`, A 원화 충실·B 게임 단순화, 생성 약 20분). **둘 다 반려** —
  사용자 피드백: "지금보다 훨씬 더 스타일라이징되고 단순화된 버전으로". 레퍼런스 [stylized-toy-chibi-ref-01.png](../art/references/characters/stylized-toy-chibi-ref-01.png)
  (장난감·점토 같은 단순 덩어리, 약 2등신, 점 눈, 뭉툭한 손, 큰 색면, 장식 최소).
- v02: 2026-10-19 레퍼런스 화풍으로 재요청 — [codex-goblin-nib-model-3q-v02.md](handoff/codex-goblin-nib-model-3q-v02.md) → 시안 2장 납품(`art/concepts/characters/goblin-nib-model-v02/`, A 배낭·담요·등불 / B 보따리·짧은 망토 목도리, 1536×1536, 알파 정리·원본 `raw/` 보존, 생성 약 8분).
- v02 선택 정정(2026-10-19): A 승인을 취소하고 **B 를 베이스로**, 보따리 대신 A 의 **배낭·말린 담요·등불**로 바꾸라는 지시.
- v03: 2026-10-19 [codex-goblin-nib-model-3q-v03.md](handoff/codex-goblin-nib-model-3q-v03.md) — B 수정본 1장 납품([`nib-3q-v03.png`](../art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png), 1536×1536, 알파 정리·원본 `raw/` 보존).
- **승인: 2026-10-19 사용자가 v03 승인** → 니브 기준 원화 [`nib-3q-v03.png`](../art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png).

### 플레이어 마녀(북쪽의 마녀) 기록

- 기준 원화가 두 갈래: HUD 초상 `godot/assets/ui/ftue/witch_portrait.png`(두건·갈색 웨이브 머리·등불, 설정서 §2.3 과 일치)와
  현재 3D 모델 시트 `art/model-sheets/starter/02-witch-player.png`(뾰족 모자·연보라 머리). 그래서 시안 A=초상 기반, B=모델 시트 기반으로 나눴다.
- 화풍·비례는 **승인된 니브 v03 을 1순위 입력**으로 맞춘다(같은 게임에 나란히 서므로). 표정은 성격대로 차분·담담하게.
- 게임은 기존 지팡이 모델을 손에 붙이고 지팡이 끝 효과를 쓰므로 **빈손 A자**로 그리고, 등불은 허리에 단다.
- v01: 2026-10-19 요청 — [codex-witch-north-model-3q-v01.md](handoff/codex-witch-north-model-3q-v01.md) → 시안 2장 납품(`art/concepts/characters/witch-north-model-v01/`, A 두건·갈색 웨이브 머리·크림 원피스 / B 뾰족 모자·연보라 단발·보라 코트, 둘 다 빈손 A자·허리 등불, 1536×1536, 알파 정리).
- **승인: 2026-10-19 사용자가 A 시안 승인** → 마녀 기준 원화 [`witch-3q-a-v01.png`](../art/concepts/characters/witch-north-model-v01/witch-3q-a-v01.png) (두건 달린 보라 망토·갈색 웨이브 머리·크림 원피스·허리 등불).

### 나머지 다섯 종족 대표 기록 (2026-10-20)

- 사용자 지시: "이 프로세스를 기반으로 나머지 종족 캐릭터들 만들자. 우선 원화 먼저 모두 준비" + "원화가 내 승인이 나야 다음 시작" — **원화 승인 전에는 Tripo 를 시작하지 않는다.**
- 범위(Claude 판단): 인간·드워프·요정·수인·오크에서 종족마다 처음 만나는 고용 손님(전투용병) 1명 — 브람·하랄·티슬·파르그(늑대)·가로크.
  니브 → 공용 고블린처럼 전용 모델을 만든 뒤 종족 공용 모델로 재활용한다. Tripo 크레딧 남은 약 995 로 5명 × 160 = 800 이 맞는다.
- 시안 A = 초상 충실(갑옷·무기는 등/허리), B = 종족 공용 겸용(갑옷·무기를 덜어 낸 여행복). 빈손 A자, 니브 v03·마녀 A 를 화풍 1·2순위 입력.
- 요청서: 공통 [codex-race-models-3q-common-v01.md](handoff/codex-race-models-3q-common-v01.md) + 인물별
  [브람](handoff/codex-human-bram-model-3q-v01.md) · [하랄](handoff/codex-dwarf-harald-model-3q-v01.md) · [티슬](handoff/codex-fairy-thistle-model-3q-v01.md) ·
  [파르그](handoff/codex-beastfolk-fargh-model-3q-v01.md) · [가로크](handoff/codex-orc-garok-model-3q-v01.md). 5건 동시 요청.
- v01 납품(2026-10-20): 5명 × A·B = 10장, 모두 1536×1536 투명 PNG, 원본 `raw/`·`generation.md` 보존(`art/concepts/characters/<race>-<id>-model-v01/`).
  비교판 [race-models-v01-contact.png](../art/concepts/characters/race-models-v01-contact.png).
- **v01 반려(사용자 2026-10-20):** ① "특정 캐릭터 전용 모델링은 지금 필요 없어, 각 종족 공용만" ② "니브랑 비교했을 때 등신 비율이 안 맞아, 같은 등신 비율로".
  → v01 은 머리가 작고 다리가 길었다. **종족 공용 모델 원화는 니브 v03 과 같은 등신(머리 ≈ 전체 키의 45%)으로, 체격 차이는 키가 아니라 폭으로** 준다.
- v02: [codex-race-common-models-3q-v02.md](handoff/codex-race-common-models-3q-v02.md) — 종족당 공용 1장(`art/concepts/characters/<race>-common-model-v02/`), v01 B 를 정체성 참고로, 개인 특징(흉터·장신구·무기) 제거. 5건 동시 요청.
  → 납품 5장. 알파 기준 전체 높이 니브 1,112px 와 **1,112~1,113px 로 일치**(요정은 더듬이·날개 포함 1,179), 발 위치 같음.
  비교판 [race-common-v02-contact.png](../art/concepts/characters/race-common-v02-contact.png).
- **2026-10-20 사용자 "좋아. 원화들 모두 잘 저장해줘. 다음번에 이어서 작업할 거야"** — v02 5장으로 진행. 작업은 여기서 멈춤.

| 종족 | 기준 원화 (v02) | 다음 단계 |
| --- | --- | --- |
| 인간 `human_common` | [human-common-3q-v02.png](../art/concepts/characters/human-common-model-v02/human-common-3q-v02.png) | Tripo |
| 드워프 `dwarf_common` | [dwarf-common-3q-v02.png](../art/concepts/characters/dwarf-common-model-v02/dwarf-common-3q-v02.png) | Tripo |
| 요정 `fairy_common` | [fairy-common-3q-v02.png](../art/concepts/characters/fairy-common-model-v02/fairy-common-3q-v02.png) | Tripo(날개·더듬이는 묶음 분리 대상) |
| 수인 `beastfolk_common` | [beastfolk-common-3q-v02.png](../art/concepts/characters/beastfolk-common-model-v02/beastfolk-common-3q-v02.png) | Tripo |
| 오크 `orc_common` | [orc-common-3q-v02.png](../art/concepts/characters/orc-common-model-v02/orc-common-3q-v02.png) | Tripo |

- **다음에 이어서 할 때 먼저 확인할 것:** Claude 가 짚은 두 가지에 대한 사용자 답은 아직 없다 — 수인 주둥이가 거의 없어 "늑대 귀 단 사람"처럼 보임, 오크 귀가 뾰족해 고블린과 닮음.
  Tripo 로 넘어가기 전에 이 둘을 고칠지(v03) 그대로 갈지 한 번 묻는다.
- 인물 전용 v01 시안 10장(`<race>-<id>-model-v01/`)은 반려됐지만 참고용으로 보존한다(인물 전용은 "지금은 필요 없음").
- Tripo 크레딧: 마지막 기록 995 → 5종족 × 160 = 800 예상.

## 2단계 · Tripo 웹에서 3D 모델 생성 (스마트 메시)

- 승인 원화 한 장을 Tripo Studio(웹, 구독 크레딧)의 이미지→3D 에 넣어 모델을 만든다. Claude 가 Chrome(Claude in Chrome, 사용자 로그인 세션)으로 직접 조작한다.
- 사용자 지시(2026-10-19): **스마트 메시(Smart Mesh)로, 폴리 수는 적당한 수준**. 이 단계는 **모델 생성까지만** 하고 게임 적용은 하지 않는다.
- 결과는 Tripo 미리보기로 확인해 사용자에게 보여 준다.
- **토폴로지는 Triangle(삼각형)로 한다 (사용자 지시 2026-10-19).** 캐릭터는 애니메이션을 위해 생성 뒤 파츠(머리·팔·다리·등짐 등)를 나눠야 하는데, Quad 로 만들면 파츠 분리에 맞지 않는다.
  설정 위치: Smart Mesh → General Settings → Topology → Triangle, Polycount 칸.
- **폴리 수 기준 (사용자 지시 2026-10-19): 니브 정도의 단순한 2등신 캐릭터는 Triangle 3,000~4,000.** 니브는 6,000(결과 6,303)으로 만들었고, 다음 캐릭터부터 이 기준을 쓴다.
- **텍스처:** 메시 생성 뒤 뷰어 하단 **Texture(20 크레딧)** 로 입힌다. 이미지 입력으로 만든 메시는 그 원화를 그대로 텍스처 기준으로 쓴다.
- **파츠 분리 (사용자 지시 2026-10-19):** 캐릭터처럼 복잡한 애니메이션이 필요한 모델은 텍스처 뒤 **Segment → Start Segmenting(40 크레딧)** 까지 반드시 적용한다. 단계는 **Simple**(마녀부터; 니브 때 Balanced 는 37개로 과도했다).
  단순한 프랍·흔들림 정도의 연출만 필요한 모델은 생략할 수 있다.

### 니브 기록

- 시도 1 (2026-10-19, 100 크레딧): P2.0 · **Quad** · 폴리 6,000 으로 생성 시작 — 사용자가 중단 지시. 파츠 분리를 위해 Triangle 이어야 했음.
  작업 `a9c0333f-1d2c-4f8f-9c0e-7ad0d23eb5b4`. 사용하지 않는다.
- 시도 2 (2026-10-19, 100 크레딧): P2.0 · Smart Mesh · **Triangle · 폴리 6,000**(사용자 지시 "절반 수준") → 결과 **면 6,303 · 정점 3,293**, 텍스처 없음(텍스처는 별도 20 크레딧). 생성 약 1분.
  작업 `e2eadc07-dea2-4ff1-9ce0-ecccc9069596`. 미리보기 캡처 [`output/tripo/goblin-nib/smartmesh-tri6000-front-v01.png`](../output/tripo/goblin-nib/smartmesh-tri6000-front-v01.png). 사용자 확인 — 이 메시로 진행.
- 텍스처 (2026-10-19, 20 크레딧): 하단 Texture 버튼 한 번으로 입력 원화 기준 텍스처 생성, 약 100초, 설정 창 없이 바로 시작됨. 면 6,303 유지 · 정점 4,527(UV 이음매). 캡처 [`output/tripo/goblin-nib/textured-v01.png`](../output/tripo/goblin-nib/textured-v01.png). 완료 뒤 화면이 Segmentation(파츠 분리, Balanced 8~15 파츠 · 40 크레딧) 으로 넘어감 — 실행하지 않음. 남은 크레딧 1,195.
- 파츠 분리 (2026-10-19, 40 크레딧): Segment → Balanced → Start Segmenting, 약 1분 반. 결과 **파츠 37개**(`tripo_part_0`~`36`) — Balanced 안내(6~15)보다 훨씬 많음. 면 6,303 유지 · 정점 4,720.
  캡처 [`output/tripo/goblin-nib/segment-balanced-v01.png`](../output/tripo/goblin-nib/segment-balanced-v01.png). 아직 Save 하지 않음(사용자 확인 대기). 화면 하단에 Merge(파츠 합치기)·Save·Export 가 있다. 남은 크레딧 1,155.
- 파츠 합치기 시도 (2026-10-19, 사용자 지시 "적당한 수준으로 머지"): 37개를 애니메이션 단위 7개로 묶는 안을 만들었다.
  | 묶음 | 파츠 |
  | --- | --- |
  | 머리(얼굴·머리카락·귀·눈·귀걸이) | 0, 7, 10, 11, 13, 18, 20, 21, 23, 24, 26, 34, 35 |
  | 몸통(셔츠·조끼·목도리·벨트·버클·멜빵) | 2, 9, 12, 14, 15, 17, 19, 22, 25, 27, 30, 31, 32, 36 |
  | 화면 왼쪽 팔(캐릭터 오른팔) | 5, 8 |
  | 화면 오른쪽 팔(캐릭터 왼팔) | 6, 16 |
  | 화면 왼쪽 다리 / 오른쪽 다리 | 4 / 3 |
  | 등짐(배낭·담요·등불) | 1, 28, 29, 33 |
  - Merge UI 관찰: 목록에서 Ctrl+클릭으로 여러 개를 골라도 Merge 가 꺼져 있고, **3D 뷰에서 Ctrl+클릭으로 2개 이상** 골라야 켜진다. 눌러도 목록 항목 수(37)는 그대로이고
    색만 같아지며, 다시 클릭하면 원래 파츠 단위로 선택된다. 실제로 합쳐지는지(Save 후 반영인지) 확인하지 못해 중단. 작은 파츠는 3D 뷰에서 집기 어렵다.
  - **결정(사용자 2026-10-19): Tripo 에서는 합치지 않고 그대로 Save·Export, 묶음은 Godot 임포트 때 한다.**
  - 확인된 사실: Undo 를 눌렀지만 시험 Merge 두 번(part_0 머리카락·part_20 오른눈 → part_13 얼굴)은 Save 에 반영되어 **35개**로 저장됐다. 둘 다 머리 묶음이라 결과에는 영향 없음.
- Export (2026-10-19, 크레딧 차감 없음): Export → GLB · 텍스처 2k · **Pack UV 켜기**. Pack UV 를 끄면 파츠마다 재질·텍스처가 따로(35장) 나오고, 켜면 재질 1개·텍스처 1장(2048 JPEG)이 된다.
  저장 위치 `godot/art_sources/characters/goblin_nib/nib_tripo_segmented_packuv.glb`(Pack UV 끈 판은 `nib_tripo_segmented.glb` 로 보존).

### 플레이어 마녀 기록 (2026-10-19)

- 사용자 지시: "프로세스대로 Tripo 웹에서 Smart Mesh·Triangle·폴리 3~4천으로 생성하고 텍스처까지".
- 생성(100 크레딧): HD Model 이 기본 선택이라 **Smart Mesh 탭으로 바꾸고**, Topology 도 Quad 로 돌아가 있어 **Triangle 로 다시 고른 뒤** 폴리 3,500 → 결과 **면 3,834 · 정점 1,948**, 약 1분.
  작업 `89e195ed-1fd3-4c4d-87fd-3143e649276b`. 캡처 [`output/tripo/witch-north/smartmesh-tri3500-front-v01.png`](../output/tripo/witch-north/smartmesh-tri3500-front-v01.png).
  → **매번 생성 전에 탭(Smart Mesh)·Topology(Triangle)·폴리 수를 눈으로 확인한다**(설정이 저장되지 않을 때가 있다).
- 텍스처(20 크레딧): 약 100초, 면 유지 · 정점 4,682. 이번에는 Segmentation 화면으로 넘어가지 않았다. 캡처 [`output/tripo/witch-north/textured-v01.png`](../output/tripo/witch-north/textured-v01.png). 남은 크레딧 1,035.
- 파츠 분리(40 크레딧, 사용자 지시 "이전에 너무 세밀하게 쪼개 과도했으니 적게"): Segment → **Simple(3~8 파츠 안내)** → 결과 **13개**(니브 Balanced 37개의 약 1/3), 약 1분 반.
  큰 머리(두건·머리카락·얼굴 한 덩어리)·로브 몸통·양팔·양다리 + 작은 조각(버클·멜빵·망토 고리·등불 3조각). Save 완료(Merge 는 쓰지 않음). 남은 크레딧 995.
  캡처 [`output/tripo/witch-north/segment-simple-v01.png`](../output/tripo/witch-north/segment-simple-v01.png).
  → **캐릭터 파츠 분리 기준을 Simple 로 바꾼다**(사용자 판단 2026-10-19: Balanced 는 과도). 머리·몸통·팔·다리가 따로 나오면 애니메이션 묶음으로 충분하다.
- Export(크레딧 차감 없음): GLB · 2k · Pack UV(설정이 기억돼 켜져 있었다) → `godot/art_sources/characters/witch_north/witch_tripo_segmented_packuv.glb`(1.0MB, 재질 1·텍스처 1).

## 3단계 · Godot 임포트 — 파츠를 애니메이션 묶음으로

- 묶음 정의는 캐릭터마다 `godot/art_sources/characters/<id>/parts.json` 에 둔다(묶음 → 부모 묶음 · 피벗 종류 · 파츠 번호).
  파츠 번호는 GLB 노드 이름 `tripo_part_<번호>`. **Tripo 화면 색으로 추측하지 말고 GLB 의 파츠별 실제 경계로 정한다** — 앞에서 보면 등짐 일부가 몸통·팔에 겹쳐 보여 처음 추측 8개가 틀렸다(뒤쪽 z<-0.1 은 등짐).
- 실행: `.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/tripo_character_ingest.gd -- res://art_sources/characters/<id>/parts.json`
  → `assets/characters/<id>/`(묶음별 메시·공유 텍스처 1024·툰 재질·report.json), `scenes/characters/<id>.tscn`(루트 발 아래 중심 → 묶음 피벗 Node3D → Mesh).
  모든 파츠가 정확히 한 묶음에 들어가지 않으면 실패한다.
- 검증: `.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_tripo_character.gd -- <id>` — 피벗·부모·파츠 배정·삼각형 보존·크기·텍스처·피벗 회전.
- 묶음 배정이 눈으로 맞는지만 창을 띄워 확인: `tools/capture_tripo_character.gd -- <id>` → `godot/screenshots/characters/<id>/textured.png`, `groups-posed.png`(묶음별 색 + 팔·머리·다리 회전).

### 니브 기록 (2026-10-19)

| 묶음 | 부모 | 피벗 | 파츠 | 삼각형 |
| --- | --- | --- | --- | --- |
| torso 몸통(셔츠·조끼·목도리·벨트·버클·멜빵) | 루트 | 허리(아래 중심) | 2, 9, 12, 14, 17, 19, 22, 36 | 1,100 |
| head 머리(얼굴·머리카락·귀·눈·귀걸이) | torso | 목(아래 중심) | 7, 10, 11, 13, 21, 23, 24, 26, 34, 35 | 2,292 |
| arm_r 오른팔(-X) / arm_l 왼팔(+X) | torso | 어깨 | 5 / 6 | 452 / 452 |
| leg_r 오른다리 / leg_l 왼다리 | 루트 | 엉덩이(위 중심) | 4 / 3 | 534 / 549 |
| backpack 등짐(배낭·담요·등불·옆 주머니) | torso | 앞쪽 위(등 닿는 곳) | 1, 8, 15, 16, 18, 25, 27, 28, 29, 30, 31, 32, 33 | 924 |

- 합계 6,303 삼각형(원본과 같음), 높이 1.0m(Tripo 원본 그대로 — 게임 배치 때 조정), 앞면 +Z.
- 헤드리스 검증 25/25. 캡처: [textured](../godot/screenshots/characters/goblin_nib/textured.png) · [묶음·포즈](../godot/screenshots/characters/goblin_nib/groups-posed.png)
  (창을 띄운 이유: 묶음 배정이 맞는지는 렌더로만 판단 가능).
- 아직 게임에는 배치하지 않았다(애니메이션·배치는 다음 단계).

### 플레이어 마녀 기록 (2026-10-19)

| 묶음 | 부모 | 피벗 | 파츠 | 삼각형 |
| --- | --- | --- | --- | --- |
| torso 로브 몸통·버클·망토 고리 | 루트 | 허리(아래 중심) | 1, 8, 11 | 836 |
| head 두건·머리카락·얼굴(한 파츠) | torso | **목 [0, 0.53, 0.05] 직접 지정** | 0 | 1,453 |
| arm_r 오른팔(-X) / arm_l 왼팔(+X) | torso | 어깨 | 2 / 5 | 331 / 329 |
| leg_r / leg_l | 루트 | 엉덩이(위 중심) | 3 / 6 | 242 / 242 |
| cape 등 뒤 망토 | torso | 위 중심(어깨) | 4 | 175 |
| lantern 허리 등불(고리·몸체 4조각) | torso | 위 중심(벨트 고리) | 7, 9, 10, 12 | 226 |

- 합계 3,834 삼각형(원본과 같음), 높이 1.0m(게임 배치 때 조정), 앞면 +Z. 헤드리스 `verify_tripo_character.gd -- witch_north` 27/27.
- **머리 피벗:** 머리 파츠에 가슴까지 내려오는 긴 머리카락이 붙어 있어 자동 'bottom' 피벗이 가슴 높이(y 0.39)로 잡혔다.
  `tripo_character_ingest.gd` 가 `"pivot": [x, y, z]` 직접 지정을 받도록 고치고 목 위치로 바꿨다(니브는 다시 임포트해도 같은 결과 25/25).
- 망토·등불은 걷기·서 있기 때 흔들림을 주려고 별도 묶음으로 뒀다(애니메이션은 다음 단계).
- 캡처(창: 묶음 배정은 눈으로만 확인 가능): [textured](../godot/screenshots/characters/witch_north/textured.png) · [묶음·포즈](../godot/screenshots/characters/witch_north/groups-posed.png).
- 아직 게임 플레이어 모델은 바꾸지 않았다.

## 4단계 · 성격·역할에 맞는 애니메이션 → 실제 게임 배치 (프로세스의 끝)

- 사용자 지시(2026-10-19): 게임 속 성격·역할·설정대로 **필요한 애니메이션을 수준에 맞게** 만들고 실제 게임에 배치한다.
- **수준:** 게임의 다른 손님은 몸 위아래 흔들림 하나뿐이다. 파츠 캐릭터는 묶음 피벗을 돌리는 **절차 애니메이션**으로 만든다(뼈·키프레임 없음, 코드 수치로 조정).
  공용 모듈 `scripts/visual/rig_anim.gd`(상태 walk·idle·greet·wave), 캐릭터별 연결·성격 값은 `scripts/visual/character_models.gd` 의 `CATALOG`.
- **연결 위치:** 손님 액터 `scripts/actors/traveler.gd` — 손님 `character_id` 가 `CATALOG` 에 있으면 전용 모델·애니메이션, 없으면 기존 공용 겨울 여행자 모델 그대로.
  손님 선택·숙박·지불 규칙은 바꾸지 않는다.
- 검증: `tools/verify_<캐릭터>_guest.gd`(헤드리스, 실제 main.tscn 에서 걷기→인사→입실→퇴실), 자세 확인만 창으로 `tools/capture_rig_poses.gd -- <손님 id>`·`tools/capture_nib_guest.gd`.
- 마지막에 `WitchsLodge.exe` 를 다시 내보낸다.

### 니브 기록 (2026-10-19)

니브: 고블린 **여행자·행상인**(고용 불가), 태그 "흥정으로 시작하는 인사", 첫인사 "숙박비요? 반값은 어때요?". 그래서 동작을 이렇게 정했다.

| 상태 | 언제 | 동작(성격 반영) |
| --- | --- | --- |
| walk | 숲길을 걸어올 때·떠날 때 | 짧은 다리로 잰걸음(걸음 주기 11, 사람 손님 9), 통통 튀는 몸, 앞으로 살짝 기울기, 무거운 등짐이 반 박자 늦게 출렁임 |
| greet | 문 앞 도착 1.4초 | 문을 등지고 마당 쪽으로 돌아서서 **한 손을 내밀어 손가락을 비비며(값 흥정)** 고개를 갸웃, 깡충 — 그 뒤 입실 |
| wave | 숙박 후 떠나기 시작 1.0초 | 걸으며 왼팔을 바깥 앞쪽으로 들어 흔든다(큰 귀·머리에 가리지 않는 각도) |
| idle | 멈춰 있을 때 | 숨쉬기, 두리번거리기 |

- 크기 (사용자 피드백 두 번): 0.82m(사람 손님보다 작게) → "마녀와 거의 비슷해야" 1.75m → "마녀보다 훨씬 크다, 더 작게" **1.3배(서 있을 때 약 1.3m, 걸을 때 튀어서 최대 1.45m)**.
  마녀는 모자 끝까지 1.84m지만 그 대부분이 뾰족한 모자라서, 머리가 큰 2등신 캐릭터를 같은 키로 맞추면 훨씬 커 보인다. **겉보기 덩치를 마녀와 맞추려면 키를 마녀의 약 70~80%로 둔다.**
  검증: 니브 키가 마녀의 60~85%. [마녀와 크기 비교](../godot/screenshots/characters/goblin_nib/ingame-size-vs-witch.png).
- 입김 효과: 기존 효과는 `Head` 노드에서 나오는데 파츠 캐릭터의 `Head` 는 목 관절이라 큰 얼굴을 덮었다. `character_models.gd` 의 `mouth` 위치에 `Mouth` 표식을 달고 `actor_vfx.gd` 가 그것을 먼저 쓰게 했다(다른 액터는 그대로).
- 헤드리스 `verify_nib_guest.gd` 15/15, `verify_tripo_character.gd` 25/25, 기존 손님 검증(도착·명단·이벤트) 통과.
  `verify_first_session.gd` 57/58 의 실패 1건(밤 진입 토스트 중복)은 니브 모델을 끈 상태에서도 같아 이번 변경과 무관하다.
- 캡처(창을 띄운 이유: 자세·타이밍은 눈으로만 판단): [근접 자세 시트](../godot/screenshots/characters/goblin_nib/poses-sheet.png), [실제 카메라](../godot/screenshots/characters/goblin_nib/ingame-sheet.png).
  처음 손 흔들기는 팔을 머리 위로 들어 큰 귀에 가려 보이지 않아, 바깥 비스듬히 앞으로 고쳤다.
- 게임에서 보이는 조건: 판의 종족 가중치로 고블린 여행자가 뽑힐 때(고블린 여행자 3명 중 1명). 고블린이 주요 종족인 판에서 자주 온다.
- `WitchsLodge.exe` 갱신(2026-10-19).

### 플레이어 마녀 기록 (2026-10-19)

사용자 지시: "마녀 성격과 플레이어 행동에 맞는 애니메이션을 만들어서 게임 플레이어에 적용". 북쪽의 마녀 = 침착한 원칙주의자·파수꾼(설정서 §2.3).

- **연결:** `Models.make_witch()` 가 `CharacterModels.make_player_witch()` 를 먼저 쓰고, 없으면 기존 칠한 모델로 돌아간다. 돌려주는 사전 모양(root·body·head·staff·tip)이 같아
  `player.gd` 의 기존 몸 흔들림·지팡이 회전·지팡이 끝 효과·늑대 변신(Body 숨김)·피격 깜빡임이 그대로 동작한다. 추가로 `rig`(팔다리 애니메이터)·`hand_r`(가위 쥘 손).
- **지팡이:** 기존 `witch_staff` 모델을 **왼손(arm_l) 손끝**에 쥐여 붙이고, 밑동이 땅에 닿게 내려 **세계 길이 약 1.5m(기존과 같음)**를 유지. 플레이어 코드의 지팡이 기울이기는 이제 손을 축으로 돈다.
- **가위:** 털 깎기 가위를 몸 대신 **오른손**에 붙였다.
- **크기:** 장면 1.0m × 1.12 × 플레이어 visual 1.3 ≈ **1.46m**(니브 1.3m 보다 조금 크게). `paint_brightness` 1.35(어두운 보라 두건이 눈밭 보라 공기 속에서 묻혀서; `parts.json` 옵션 추가).
- **애니메이션(`rig_anim.gd` 에 플레이어 상태 추가, 성격 값은 `character_models.gd`):**

| 상태 | 언제(player.gd) | 동작 |
| --- | --- | --- |
| idle | 멈춤 | 숨쉬기, **천천히 넓게 주변을 살핀다**(파수꾼, 고개 22°·주기 느리게). 지팡이 팔은 살짝 앞 |
| walk | 이동 | 단정한 걸음(다리 22°, 팔 14°, 지팡이 팔 5°만), 흔들림 적게. **허리 등불이 반 박자 늦게 흔들리고 망토가 뒤로 날린다** |
| windup | 공격 선딜(`attack_windup`) | 지팡이 팔을 앞으로 들고(최대 -55°) 대상을 똑바로, 몸은 거의 그대로(침착) |
| cast | 발사 직후 0.3초(`_cast_t`) | 지팡이 팔을 짧게 내지르고 망토가 튄다 |
| work | 양털 깎기(`shearing`) | 오른손(가위)을 앞으로 내밀어 여닫고 고개를 숙인다 |
| hurt | 늑대의 피 괴로움(`suffering`) | 두 팔로 몸을 감싸고 고개를 숙인 채 떤다 |

- 공용 수치는 니브와 같은 모듈을 쓰되 기본값이 그대로라 니브 동작은 변하지 않았다(검증 15/15).
- **검증:** `verify_witch_player.gd` 18/18(모델 교체·지팡이 왼손·가위 오른손·키 1.47m·발 위치·지팡이 길이 1.52m·상태 6종·늑대 변신 숨김).
  기존: 늑대의 피 59/59, 달 런타임·주술 카드 통과, 양 시각 35/35(한 번 34/35 는 무작위 흔들림 — 재실행 3회 통과),
  첫 세션 57/58·카드 코어 스크립트 오류는 **기존 모델에서도 같아** 이번 변경과 무관.
- 캡처(창: 자세·화면 속 모습은 눈으로만): [근접 자세 시트](../godot/screenshots/characters/witch_north/poses-sheet.png), [실제 카메라](../godot/screenshots/characters/witch_north/ingame-sheet.png).
  높은 카메라에서는 두건 윗면이 주로 보이고, 시작할 때 마녀가 카메라 반대쪽(200°)을 보고 서 있다(기존 설정 유지).
- `WitchsLodge.exe` 갱신.

### 공용 고블린 손님 — 니브 재활용 (2026-10-19)

- 사용자 지시: 니브에서 등짐과 소품을 적절히 빼서 **평범한 고블린 손님**으로 재활용. 게임 적용 전에 캡처부터 확인받는다.
- 같은 원본 GLB 로 `art_sources/characters/goblin_common/parts.json` 을 만들고 `"drop"` 으로 뺄 파츠를 적었다(임포트 도구에 `drop` 지원 추가):
  등짐 전체 13조각(배낭·담요·등불·옆 주머니), 동전 귀걸이(24·26), 등짐 멜빵(17·22). 남은 묶음 6개(머리·몸통·양팔·양다리), 검증 23/23.
- 첫 캡처에서 **멜빵·등짐이 닿던 자리(어깨·등)에 갈색 자국**이 텍스처에 칠해져 남아 있었다(파츠는 빠져도 그 밑 옷에 그린 색).
  `clean_paint.py` 로 지웠다: ① 뺀 파츠 표면에서 3cm 안의 텍셀, ② 셔츠·조끼·목도리·소매 파츠 위의 갈색 텍셀(원래 갈색이 없는 옷 = 멜빵 그림),
  ③ 벨트 뒤의 밝은 주황(등불 빛 그림)을 같은 파츠의 가장 가까운 정상 텍셀 색으로 채움 → `paint_clean.png`, 임포트 옵션 `paint_override` 추가.
  벨트의 옅은 붉은 기까지 지워 남은 자국 없음(2026-10-19 재확인).
- 캡처: [니브·공용 고블린 앞·뒤 비교](../godot/screenshots/characters/goblin_common/compare.png).
- **니브와 구분되게 다시 꾸밈(사용자 피드백 2026-10-19 "아직 좀 비슷하네. 옷 컬러도 바꿔주고, 머리 스타일도"):**
  - 옷 색(`clean_paint.py` RESTYLE, 원래 명암은 유지): 보라 조끼 → **이끼 초록**, 빨간 목도리 → **구리 주황**, 흰 셔츠·소매 → **귀리색**, 갈색 머리 → **숯빛 검정**(고블린 종족 보조색 이끼·구리).
    얼굴·머리카락·눈이 한 파츠라 색만으로 고르면 얼굴까지 칠해져서, 텍셀의 3D 위치로 머리카락 쪽만 골랐다.
  - 머리 모양: 니브의 큰 앞머리 덩어리(11)와 정수리 털(35)을 빼고 **정수리 상투**(구형 + 구리색 끈)를 올렸다(임포트 옵션 `extras` 추가).
    앞머리에 가려 있던 얼굴 칠은 피부색으로 덮었다.
  - 검증 23/23(상투는 크기·텍스처 검사에서 제외), 니브 25/25·마녀 27/27 그대로.
  - **승인: 2026-10-19 사용자가 v2 공용 고블린(검은 상투·이끼 초록 조끼·구리 목도리·귀리색 셔츠) 확정.**
- **게임 연결:** 손님 모델은 `CharacterModels.model_for(profile)` — 전용 모델(니브) → 종족 공용(`RACE_MODELS`: goblin → goblin_common) → 기존 공용 여행자 순.
  그래서 그라즈·피클·러스크·타크·그릭·말라가 손님으로 올 때 공용 고블린으로 걸어온다(1.3m, 니브보다 덜 튀는 걸음). **흥정 인사·손 흔들기는 니브만** — `greet_time` 이 없는 캐릭터는 다른 손님처럼 바로 입실.
  용병으로 고용된 뒤의 모습(ally)은 아직 기존 모델이다.
- 검증 `verify_nib_guest.gd` 17/17(니브 그대로 + 그라즈 공용 고블린·등짐 없음·인사 없이 입실 + 사람 손님 기존 모델), `verify_tripo_character.gd -- goblin_common` 23/23.
  [실제 카메라 — 니브와 공용 고블린](../godot/screenshots/characters/goblin_common/ingame-pair-crop.png).
- 실행파일: 다른 작업의 `goblin_cards.gd` 문법 오류가 18:21 에 고쳐진 뒤 2026-10-19 18:39 `WitchsLodge.exe` 를 내보냈다(손님 17/17, 마녀 18/18 — 마녀 걷기 검사는 상태를 마지막 값이 아니라 "보인 적 있는지"로 고침).

## 전체 요약 — 다음 캐릭터에 그대로 쓰는 순서 (2026-10-20 갱신)

1. **원화:** Codex 에 기존 원화 기준 **3/4뷰 전신 시안 2개** 요청(빈손 A자·투명 배경, 화풍은 장난감 같은 단순 SD 레퍼런스, 이미 승인된 캐릭터를 화풍 1순위 입력으로) → 사용자 승인. 반려되면 피드백을 적고 버전을 올린다.
2. **Tripo 웹(Chrome·구독 크레딧, API 는 쓰지 않음):** 생성 직전 **Smart Mesh 탭 · Topology Triangle · 폴리 3,000~4,000** 을 눈으로 확인 → 생성(100) → **Texture**(20) → **Segment Simple**(40) → **Save** → **Export GLB · 2k · Pack UV 켜기**. Merge 는 쓰지 않는다. 크레딧이 드는 클릭은 사용자 지시가 있을 때만.
3. **Godot 임포트:** `parts.json` 에 파츠를 **GLB 의 실제 경계로** 애니메이션 묶음(머리·몸통·양팔·양다리 + 흔들림 소품)에 배정 → `tripo_character_ingest.gd` → `verify_tripo_character.gd` → 묶음 색 캡처로 확인.
   자동 피벗이 어긋나면 `"pivot": [x,y,z]`, 어두운 옷은 `"paint_brightness"`.
4. **애니메이션·배치:** 성격·역할에 맞는 상태별 동작을 `character_models.gd` 의 style 값(필요하면 `rig_anim.gd` 상태 추가)으로 만들고 손님(`traveler.gd`)·플레이어(`Models.make_witch`) 등에 연결.
   **크기는 겉보기 덩치를 마녀(서 있는 키 약 1.46m)에 맞추되 머리 큰 2등신은 그보다 조금 작게**(니브 1.3m). 헤드리스 검증 → 자세·실제 카메라 캡처 → `WitchsLodge.exe`.
5. **재활용(선택):** 같은 원본으로 다른 인물·종족 공용 모델을 만들 때는 `"drop"`(소품 빼기)·`"extras"`(단순 형태 추가)·`"paint_override"` + `clean_paint.py`(뺀 소품 자국 지우기·옷/머리 색 바꾸기)를 쓴다.
   전용 모델이 없는 손님은 `RACE_MODELS` 의 종족 공용 모델로 나온다(고블린 → `goblin_common`). 인물 고유 동작(니브의 흥정 인사)은 공용 모델에 넣지 않는다.

### 지금까지 만든 캐릭터

| 캐릭터 | 쓰임 | 파츠 분리 | 면 수 | 묶음 |
| --- | --- | --- | --- | --- |
| 고블린 니브 `goblin_nib` | 손님(전용) — 잰걸음·흥정 인사·손 흔들기 | Balanced 37→35 | 6,303 | 7(등짐 포함) |
| 북쪽의 마녀 `witch_north` | 플레이어 — 걷기·공격 준비·발사·털 깎기·괴로움, 지팡이 왼손 | Simple 13 | 3,834 | 8(망토·등불 포함) |
| 공용 고블린 `goblin_common` | 니브 외 고블린 손님 6명 — 니브 원본 재활용, 검은 상투·이끼 초록 옷 | (니브 원본) | 니브에서 소품 제거 | 6 |
