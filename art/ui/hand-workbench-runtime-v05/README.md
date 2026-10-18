# 생성 소품을 승인 시안 배치에 맞춘 실제 적용 v05

2026-10-18 · 사용자 지시: 생성한 에셋으로 최종 승인 시안에 맞춰 게임에 적용한다.

runtime-v03·v04는 승인 시안 PNG 자체를 잘라 붙였다(v03 다각형 마스크, v04 정밀 알파 PNG + 셰이더). 이번 버전은 그 방식을 대체한다. 실제 소품 그림은 내장 image_gen으로 만든 투명 소품 시트 [witch-props-sheet.png](../hand-workbench-runtime-v02/witch-props-sheet.png)(게임 복사본 `godot/assets/ui/hand_workbench/witch-props-v02.png`)를 쓴다. 위치·크기·방향은 승인 시안 [lowered-cards-props-behind.png](../hand-workbench-v04/lowered-cards-props-behind.png)을 따른다. runtime-v02에서 폐기한 개별 크기 조정·색보정 셰이더는 쓰지 않는다. 색은 시트 원본 그대로다.

## 굽기 — `godot/tools/bake_hand_props.gd`

시트에서 소품 7개를 잘라 시안 구도에 맞게 돌린 뒤 `godot/assets/ui/hand_workbench/props-v05/<이름>.png`로 저장한다(밉맵 켬).

| 소품 | 시안에 맞춘 처리 |
|---|---|
| SpellbookAndCandle | 그대로 (촛불 왼쪽·책 오른쪽이 이미 시안과 같음) |
| PotionsAndHerbs | 좌우 반전 — 작은 보라 병 왼쪽, 큰 청색 병·수정 오른쪽 |
| InkAndQuill | 병과 깃펜을 분리, 깃펜만 38° 세우고 0.82배로 줄인 뒤 병을 덮고 좌우 반전 — 병 오른쪽 아래, 깃펜 왼쪽 위 |
| DriedHerbs | 10° 기울임 (라벤더 쪽 아래) |
| RolledParchment | −6° 기울임 (오른쪽 끝 위) |
| IngredientPouch, MoonCharm | 그대로 |

시트 전체에 깔린 알파 0.06 미만 잡티는 지우고 실제 경계로 자른다.

## 배치 — `godot/scripts/ui/moon/hand_workbench.gd`

시안 좌표계 부모(`ApprovedArtCoordinates`) 하나에 모든 소품을 둔다. 0.55배, 시안 카드 바닥 y=499 → 실제 손패 바닥 y=772로 맞추는 방식은 v03과 같다. 각 소품은 시안에서 그 소품이 차지한 실루엣 경계 칸(`SPECS`)에 들어간다. 비율을 유지하고 바닥과 가운데를 맞춘다. 손패 수·확대·드래그와 무관하게 고정이고, 입력을 받지 않으며, CardHand보다 먼저 그려져 카드에 가려진다.

## 검수

- 헤드리스: `tools/verify_hand_workbench.gd` — 텍스처·투명 배경·깃펜/약병 방향·노드 순서·입력 무시·시안 칸 정렬·카드 후순위 그리기·3장/8장 위치 동일·화면 안 배치 **RESULT 27/27**.
- 실제 렌더(헤드리스로는 시안과의 시각적 일치를 볼 수 없어 캡처): `output/hand-workbench-runtime-v05/`. [approved-vs-game.png](../../../output/hand-workbench-runtime-v05/approved-vs-game.png)에서 승인 시안과 실제 3장·8장 화면을 같은 배율로 비교했다. 3장·8장·확대·드래그·1280×720·3440×1440 캡처와 `layout-snapshots.json`이 같은 폴더에 있다.
- 시안과 다른 점: 시안의 소품 밑에 깔린 어두운 잎 무더기는 생성 시트에 없어서 넣지 않았다. 시작 카드 구성은 현재 게임 데이터를 따른다.

루트 `WitchsLodge.exe`를 다시 내보냈다(종료 코드 0, `output/hand-workbench-runtime-v05/export.log`).
