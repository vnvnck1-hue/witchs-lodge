# 승인 원화와 실제 손패 동기화 수정

**후속 수정:** 생성 소품을 시안 배치에 맞추는 방식으로 대체했다. 현재 구현은 [runtime-v05](../hand-workbench-runtime-v05/README.md)를 따른다.

2026-10-18 · 사용자가 기존 적용의 원화 불일치를 지적한 뒤 수정.

이전 runtime-v02는 소품을 새로 생성하고, 개별 크기·간격·색을 따로 조정해 승인 원화와 달라졌다. 이 버전은 그 방식을 폐기한다. 승인한 v04 PNG 자체를 게임 텍스처로 복사하고 소품 외곽만 네이티브 UI 다각형으로 마스킹해 표시한다. 카드 아래에 가려져 있던 약초·두루마리만 동일 배열의 v03 승인 원본에서 가져온다. **새로 생성한 소품 시트나 추가 색보정 셰이더는 사용하지 않는다.** 원화 내부의 원본 색·명암·종이 무늬·약병 방향을 직접 사용한다.

- 승인 v04: `art/ui/hand-workbench-v04/lowered-cards-props-behind.png`
- 게임 복사본: `godot/assets/ui/hand_workbench/approved/layout-v04.png`
- 승인 v03: `art/ui/hand-workbench-v03/fixed-width-three-and-eight.png`
- 게임 복사본: `godot/assets/ui/hand_workbench/approved/layout-v03.png`

원화의 좌표를 공유하는 부모 하나에 모든 소품을 두고 0.55배로 균등 축소한다. 이 배율은 원화의 8장 부채꼴 폭 약 1130px과 실제 손패 폭 약 622px을 맞춘 값이다. 원화에서 떨어진 간격·각 소품의 상대 크기는 그대로 유지한다. 원화 카드 바닥 y=499를 실제 손패 바닥 y=772에 연결한다. 기존 카드 크기·부채꼴·원화·문구는 변경하지 않는다.

실제 캡처와 원화 비교: `output/hand-workbench-runtime-v03/approved-vs-game.png`. 3장·8장·확대·드래그와 화면 비율별 캡처도 같은 폴더에 저장한다. `layout-snapshots.json`에서 손패 수에 따른 소품 좌표 불변과 카드의 후순위 그리기를 확인한다.

앞으로 이 장식을 수정할 때 승인 원본과 같은 배율의 실제 손패를 나란히 비교한다. 단순히 카드 수와 좌표가 고정되는 동작만 확인하고 원화 싱크 검수를 완료한 것으로 보고하지 않는다.

루트 `WitchsLodge.exe`를 다시 내보냈다(종료 코드 0). 내장 게임 데이터를 `--main-pack`으로 실행해 `output/hand-workbench-runtime-v03/packaged/`의 실제 화면도 확인했다. 배포 데이터에서도 3장·8장 소품 위치 동일과 카드 후순위 그리기를 확인했다. 두 승인 PNG와 게임 복사본의 SHA-256도 각각 동일하다.
