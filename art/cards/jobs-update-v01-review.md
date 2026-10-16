# 용병 직업·야생 동물·유물 v01 최종 검수

2026-10-15 · 최종 배포 PNG의 제목·분류·본문을 1:1 크롭 시트 네 장과 개별 원화에서 직접 확대 대조했다. 아래 전 항목의 오탈자를 발견하지 않았다. 미공개 유물은 큰 물음표와 지정 제목/분류만 있고 본문은 비어 있다.

| ID | 제목 / 분류 | 인쇄 본문 1 | 인쇄 본문 2 | 결과 |
| --- | --- | --- | --- | --- |
| `lumberjack` | 나무꾼 / 용병 · 벌목 계약 | 나무에 사용하면 벌목합니다. | 목재를 들고 있다가 건네줍니다. | 확대 대조 통과 |
| `hunter` | 사냥꾼 / 용병 · 사냥 계약 | 낮에는 토끼와 사슴을 사냥합니다. | 밤에는 활로 산장을 지킵니다. | 확대 대조 통과 |
| `warrior` | 전투용병 / 용병 · 전투 계약 | 산장 주변을 정찰합니다. | 적이 오면 검으로 맞섭니다. | 확대 대조 통과 |
| `gatherer` | 채집가 / 용병 · 채집 계약 | 낮에 숲을 탐색하고 돌아옵니다. | 쓸모 있는 것을 주워 옵니다. | 확대 대조 통과 |
| `raw_meat` | 생고기 / 자원 · 사냥 재료 | 사냥과 채집으로 얻습니다. | 판매하거나 마녀가 먹습니다. | 확대 대조 통과 |
| `rabbit_pelt` | 토끼 가죽 / 자원 · 사냥 재료 | 토끼를 사냥하면 얻습니다. | 산장에서 판매할 수 있습니다. | 확대 대조 통과 |
| `treasure_chest` | 보물상자 / 보물 · 숲의 발견 | 땅에 놓으면 상자가 열립니다. | 유물 셋 중 하나를 고릅니다. | 확대 대조 통과 |
| `relic_unknown` | ? / 유물 · 미공개 | 없음 | 없음 | 확대 대조 통과 |
| `moonlit_charm` | 달빛 부적 / 유물 · 마녀의 힘 | 마녀의 마법탄이 강해집니다. | 더 멀리 닿습니다. | 확대 대조 통과 |
| `hearth_ember` | 화로의 온기석 / 유물 · 산장의 온기 | 산장 곁의 아군이 회복합니다. | 아침마다 산장이 아물어 갑니다. | 확대 대조 통과 |
| `old_tree_heart` | 고목의 심장 / 유물 · 숲의 축복 | 벌목이 빨라집니다. | 목재를 더 많이 얻습니다. | 확대 대조 통과 |
| `wolf_fang_pendant` | 늑대 송곳니 목걸이 / 유물 · 사냥의 본능 | 사냥꾼과 전투용병이 강해집니다. | 사냥감에서 더 얻습니다. | 확대 대조 통과 |
| `frost_queen_tear` | 서리 여왕의 눈물 / 유물 · 겨울의 저주 | 모든 적이 느려집니다. | 아침마다 서리 룬을 얻습니다. | 확대 대조 통과 |

## 검사 증거

- [문구 시트 01](../../godot/screenshots/cards/jobs-update-v01-text-proof-01.png): 나무꾼·사냥꾼·전투용병·채집가.
- [문구 시트 02](../../godot/screenshots/cards/jobs-update-v01-text-proof-02.png): 생고기·토끼 가죽·보물상자·미공개 유물.
- [문구 시트 03](../../godot/screenshots/cards/jobs-update-v01-text-proof-03.png): 달빛 부적·화로의 온기석·고목의 심장·늑대 송곳니 목걸이.
- [문구 시트 04](../../godot/screenshots/cards/jobs-update-v01-text-proof-04.png): 서리 여왕의 눈물.
- [22장 갤러리](../../godot/screenshots/cards/asset-gallery.png): 실제 Godot 임포트 텍스처, 밝음/어두움 패널, 카드별 손패 크기. 잘림 없이 4열 6행을 확인했다.
- [카드 검사](../../godot/assets/cards/verification.json): passed=true, 실패 0. 배포 44 PNG의 RGBA·크기·투명 모서리·불투명 중앙/외곽·텍스처 로딩을 통과했다. 신규 13종의 카탈로그 인쇄 문구 일치와 없는 ID의 뒷면 대체도 통과했다.
- [UI·동물 검사](../../output/jobs-update-v01/asset-verification.json): passed=true, 실패 0. 아이콘 11개와 상자 2개의 크기·RGBA·알파·로딩, GLB 2개와 tscn 2개의 노드·치수·공유 재질·피벗 동작 확인.
- [아이콘 축소 확인](../../output/jobs-update-v01/icon-proof.png): 96px 실물과 144px 비교에서 실루엣·선·채도 일관성을 확인했다.
- [Godot idle](../../output/jobs-update-v01/wildlife-godot-idle.png)와 [머리 숙임](../../output/jobs-update-v01/wildlife-godot-grazing.png): Forward+에서 재질·비율·피벗 움직임 확인.
- [Blender 검사](../../output/jobs-update-v01/wildlife-blender-verification.json): 토끼 0.45×0.35m(길이×높이), 사슴 1.5×1.6m(길이×뿔 포함 높이), 어깨 약 1.10m. 각각 2메시, 비매니폴드 엣지/퇴화 면 0, 텍스처 0.

## 수량과 동시 작업 범위

요청서의 기존 9장은 뒷면을 포함한다. 기존 카드 앞면 8종 + 새 앞면 13종 = 앞면 21종이며, 뒷면 1장을 더한 갤러리/검사 대상은 총 22장이다. 따라서 “22종+뒷면”은 산술상 1장 차이가 있어 실제 ID 목록으로 범위를 명시했다. axe_mercenary는 보존·검증했다.

동시에 추가된 sleeping_thorn_seed·black_sheep·black_wool은 이번 13종 요청 밖의 다른 작업이다. 파일과 카탈로그를 변경하지 않고 별도 catalog IDs로 보고한다. 이번 에셋 담당은 godot/scripts/**, cards/catalog.json, scenes/main.tscn, shaders/**를 쓰지 않았다. 이 경로의 동시 변경은 되돌리지 않았다. 커밋하지 않았다.

Godot 4.7.2 --headless --editor --import는 종료 코드 0이며 모델 임포트 오류가 없다. 시스템 인증서 저장소 읽기 오류는 기존과 같이 로그에 남지만 로컬 파일의 패키징·임포트·검증·렌더는 모두 정상 완료했다. 게임 규칙 검증 및 PCK 재내보내기는 이 에셋 납품에서 수행하지 않았다.
