# Codex에게 요청하는 에셋 작업 — 용병 직업·야생 동물·유물 (v01)

요청자: Claude (게임 구현 담당) · 2026-10-15 · 기획: [용병 직업 분화 기획서](../mercenary-jobs-design.md)

## 역할 분담

- **Codex 책임:** 아래 카드 원화 13종, 아이콘 11종, 3D 모델 2종, 상자 연출 이미지 2장의 생성·후처리·패키징·검증·문서화.
- **Claude 책임:** 게임 규칙·AI·카드 판정·`godot/assets/cards/catalog.json`·UI 구현. 에셋이 없는 동안은 코드 블록아웃과 공용 뒷면으로 대체해 두었으므로, 납품되면 경로만 맞으면 바로 보인다.
- **수정 금지:** `godot/scripts/**`, `godot/assets/cards/catalog.json`, `godot/scenes/main.tscn`, `godot/shaders/**`. Claude가 동시에 고치고 있다. 다른 작업의 변경을 되돌리지 말 것. 커밋하지 말 것(사용자가 정리한다).

## 반드시 따를 기존 기준

먼저 읽기: `art/cards/README.md`, `docs/prompts/cards/production-rounded-v02-prompts.md`, `docs/handoff/codex-new-cards-v01.md`(이전 요청과 완료 방식), `art/cards/manifest.json`, `godot/tools/package_card_assets.gd`, `godot/tools/verify_card_assets.gd`, 기존 카드 `godot/assets/cards/*.png` 9종, 자연물 키트 `godot/assets/nature/*.glb`와 `docs/nature-prop-kit.md`(3D 스타일 기준).

- 카드: 기존 아홉 카드와 **같은 프레임·같은 비대칭 S자 포맷·같은 붓터치 원화 스타일·같은 한글 서체 느낌**. 네 모서리 둥글게, 바깥 투명. 시험 수치는 그림에 넣지 않는다.
- 산출물 경로(카드): `art/cards/rounded/<id>.png`, `godot/assets/cards/<id>.png`(RGBA 1024×1536), `godot/assets/cards/hand/<id>.png`(RGBA 256×384).
- `package_card_assets.gd`·`verify_card_assets.gd`에 새 ID 13개를 추가해 총 22종+뒷면을 검증(이 두 도구 파일은 Codex가 수정해도 된다). `axe_mercenary`는 더 이상 쓰지 않지만 파일은 지우지 말 것.
- `art/cards/manifest.json`, `art/cards/README.md` 표, 프롬프트 기록 `docs/prompts/cards/jobs-update-v01-prompts.md`, `godot/assets/cards/verification.json`, 갤러리 `godot/screenshots/cards/asset-gallery.png`(22종) 갱신.
- Godot 실행 파일: `.tools/Godot-4.7.2.exe`.

## A. 카드 13종 (인쇄 문구는 이 글자 그대로)

| id | 카드 이름 | 분류 띠 | 인쇄 문구 (2줄) |
|---|---|---|---|
| `lumberjack` | 나무꾼 | 용병 · 벌목 계약 | 나무에 사용하면 벌목합니다. / 목재를 들고 있다가 건네줍니다. |
| `hunter` | 사냥꾼 | 용병 · 사냥 계약 | 낮에는 토끼와 사슴을 사냥합니다. / 밤에는 활로 산장을 지킵니다. |
| `warrior` | 전투용병 | 용병 · 전투 계약 | 산장 주변을 정찰합니다. / 적이 오면 검으로 맞섭니다. |
| `gatherer` | 채집가 | 용병 · 채집 계약 | 낮에 숲을 탐색하고 돌아옵니다. / 쓸모 있는 것을 주워 옵니다. |
| `raw_meat` | 생고기 | 자원 · 사냥 재료 | 사냥과 채집으로 얻습니다. / 판매하거나 마녀가 먹습니다. |
| `rabbit_pelt` | 토끼 가죽 | 자원 · 사냥 재료 | 토끼를 사냥하면 얻습니다. / 산장에서 판매할 수 있습니다. |
| `treasure_chest` | 보물상자 | 보물 · 숲의 발견 | 땅에 놓으면 상자가 열립니다. / 유물 셋 중 하나를 고릅니다. |
| `relic_unknown` | ? | 유물 · 미공개 | (문구 없음 — 큰 물음표만) |
| `moonlit_charm` | 달빛 부적 | 유물 · 마녀의 힘 | 마녀의 마법탄이 강해집니다. / 더 멀리 닿습니다. |
| `hearth_ember` | 화로의 온기석 | 유물 · 산장의 온기 | 산장 곁의 아군이 회복합니다. / 아침마다 산장이 아물어 갑니다. |
| `old_tree_heart` | 고목의 심장 | 유물 · 숲의 축복 | 벌목이 빨라집니다. / 목재를 더 많이 얻습니다. |
| `wolf_fang_pendant` | 늑대 송곳니 목걸이 | 유물 · 사냥의 본능 | 사냥꾼과 전투용병이 강해집니다. / 사냥감에서 더 얻습니다. |
| `frost_queen_tear` | 서리 여왕의 눈물 | 유물 · 겨울의 저주 | 모든 적이 느려집니다. / 아침마다 서리 룬을 얻습니다. |

### 원화 내용

- **나무꾼:** 털모자와 두꺼운 체크 외투의 건장한 남자(토르빈 느낌, 수염), 어깨에 큰 도끼, 등에 묶은 통나무 다발. 눈 덮인 소나무 밑동과 나무 조각.
- **사냥꾼:** 가죽 후드와 모피 어깨의 사냥꾼(올라프 느낌), 긴 활을 당기는 자세, 허리에 화살통과 작은 토끼 가죽. 뒤로 눈 숲 사이 사슴 실루엣.
- **전투용병:** 가죽 갑옷과 둥근 방패의 전사(브람 느낌), 검을 세우고 산장 앞 눈밭에 선 모습. 멀리 산장 창문 불빛.
- **채집가:** 약초상 미라의 분위기(기존 초상 `godot/assets/portraits/guest_mira_cutout.png` 참고), 등에 바구니, 손에 등불과 버섯·나뭇가지. 숲길을 걷는 모습.
- **생고기:** 넓은 잎 위의 선홍색 고기 두 덩이, 눈 한 줌과 작은 뼈. 붓터치 톤 유지, 잔혹하지 않게.
- **토끼 가죽:** 펼친 회갈색 토끼 가죽, 한쪽 귀 모양이 남아 있음, 가죽끈으로 묶은 매듭. 눈밭 위.
- **보물상자:** 눈에 반쯤 묻힌 낡은 참나무 상자, 철 테두리와 달 문양 자물쇠, 틈새로 새는 금빛. 이끼와 서리.
- **?(미공개 유물):** 어두운 보라 안개 위에 금빛으로 빛나는 큰 물음표 하나. 중앙에 크게, 다른 요소 없이. 보물상자가 열릴 때 3장이 뒤집힌 채 나오는 카드다.
- **달빛 부적:** 은사슬에 매달린 초승달 모양 부적, 중앙 보라 보석, 달빛 광채. 마녀의 손이 살짝.
- **화로의 온기석:** 손바닥만 한 둥근 돌 속에서 호박색 불씨가 맥동, 돌 표면에 룬. 따뜻한 빛이 눈을 녹인다.
- **고목의 심장:** 고목 뿌리에 감싸인 초록빛 나무 심장(옹이가 심장 모양), 작은 새싹과 잎. 수액이 빛남.
- **늑대 송곳니 목걸이:** 가죽끈에 꿴 큰 송곳니 셋과 작은 구슬, 눈밭 위, 뒤로 흐릿한 늑대 발자국.
- **서리 여왕의 눈물:** 눈물 모양의 푸른 얼음 결정, 안에 작은 눈송이, 주변에 서리 결정이 자라고 차가운 김이 오름.

## B. 아이콘 11종 (말풍선·유물칸용)

- 경로: `godot/assets/ui/icons/<id>.png`, RGBA **96×96**, 바깥 투명, 단순한 실루엣 + 두꺼운 먹선(작게 축소돼도 읽혀야 한다).
- `icon_timber`(통나무 셋 묶음), `icon_raw_meat`, `icon_rabbit_pelt`, `icon_treasure_chest`, `icon_relic_unknown`(물음표), `icon_moonlit_charm`, `icon_hearth_ember`, `icon_old_tree_heart`, `icon_wolf_fang_pendant`, `icon_frost_queen_tear`, `icon_arrow`(화살 하나, 사냥꾼 상태 표시용).
- 같은 세트로 보이도록 선 두께·채도 통일. 기존 `godot/assets/ui/moon_runes/` 아이콘 톤을 참고.

## C. 3D 모델 2종 (GLB)

- 경로: `godot/assets/nature/rabbit.glb`, `godot/assets/nature/deer.glb` + 각각 `godot/scenes/props/nature/rabbit.tscn`, `deer.tscn`(기존 프랍 tscn과 같은 방식으로 감쌈).
- 스타일: `godot/assets/nature/*.glb`의 자연물 키트와 같은 **로우폴리 툰**(평면 색, 텍스처 없음 또는 단색 팔레트), 기존 양 모델(`docs/modeling-handoff.md`의 양 기준)과 같은 비율감.
- 크기: 토끼 몸길이 0.45m·높이 0.35m, 사슴 몸길이 1.5m·어깨 높이 1.1m(뿔 포함 1.6m). 원점은 발밑 중앙, +Z가 정면, 1단위=1m.
- 노드 구성: 루트 아래 `Body`(몸통·다리), `Body/Head`(머리) 노드가 있어야 한다. 코드가 `Body`를 위아래로 흔들고 `Head`를 숙여 풀 뜯는 모션을 만든다(애니메이션 트랙 불필요).
- 색: 토끼 회갈색 + 흰 배, 사슴 적갈색 + 흰 꼬리·배, 뿔 상아색.
- Blender 원본은 `godot/art_sources/wildlife.blend`에 둔다.

## D. 상자 연출 이미지 2장

- `godot/assets/ui/chest_closed.png`, `godot/assets/ui/chest_open.png`, RGBA **512×512**, 바깥 투명. 카드 `treasure_chest` 원화의 상자와 같은 상자. 열린 상자는 뚜껑이 뒤로 젖혀지고 안에서 금빛이 솟는다. 화면 중앙에 커다랗게 띄운 뒤 3장의 ? 카드가 튀어나오는 연출에 쓴다.

## 완료 기준

1. 카드 13종 × (원화·1024×1536·256×384) = 39개 PNG, 아이콘 11개, GLB 2개 + tscn 2개, 상자 이미지 2개가 위 경로에 있음.
2. `verify_card_assets.gd`가 22종+뒷면 통과, `verification.json` 기록, 갤러리 갱신.
3. GLB는 Godot 4.7.2에서 import 오류 없이 열리고 `Body`·`Head` 노드가 있음(헤드리스로 `--import` 후 확인).
4. README·manifest·프롬프트 문서 갱신.
5. 마지막 메시지에 생성 파일 목록과 검증 결과 요약, 인쇄 문구 오탈자를 확대해 확인한 결과.

## Codex 납품 결과 · 2026-10-15

- 카드 13종 × 3 PNG = 39개, 아이콘 11개, 동물 GLB/tscn 각 2개, 상자 이미지 2개와 wildlife.blend 원본을 납품했다. [정확한 57개 경로](../../output/jobs-update-v01/delivery.md) · [파일별 SHA-256](../../output/jobs-update-v01/delivery-manifest.json).
- [카드 검증](../../godot/assets/cards/verification.json) passed=true / 실패 0. 기존 9장은 뒷면을 포함하므로 실제 합계는 앞면 21종 + 공용 뒷면 = 총 22장, 배포 PNG 44개다. 사용 중단 axe_mercenary도 보존·검증했다. 동시 추가된 요청 밖 카드 3종은 별도 ID로 보고하고 변경하지 않았다.
- [UI·동물 검증](../../output/jobs-update-v01/asset-verification.json) passed=true / 실패 0. Godot 4.7.2 헤드리스 임포트, Body/Head 경로와 실제 치수·공유 재질·피벗 동작 통과. Blender 비매니폴드 엣지/퇴화 면 0.
- [22장 갤러리](../../godot/screenshots/cards/asset-gallery.png), README·manifest·[프롬프트](../prompts/cards/jobs-update-v01-prompts.md)·[3D 메모](../wildlife-assets-v01.md)를 갱신했다.
- 최종 PNG의 제목·분류·본문을 확대 시트 4장으로 대조해 오탈자 없음. [직접 검수 기록](../../art/cards/jobs-update-v01-review.md).
- 이 작업에서 수정 금지 경로에 쓰지 않았고 다른 작업의 변경을 되돌리지 않았다. 커밋하지 않았다. 시스템 인증서 저장소 읽기 오류만 기존과 같이 로그에 남으며, 에셋 임포트/검증/렌더는 정상 완료했다.
