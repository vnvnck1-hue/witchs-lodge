# 롤식 전투 조작 v01 (2026-10-18)

사용자 요청: "롤처럼 마우스와 키보드를 이용해서 공격하는 동작을 그대로 구현해줘. 그리고 적에 마우스오버해서 타겟을 고를 때 타겟된 적을 붉은 외곽라인으로 강조해서 시인성을 살려줘."

## 조작

| 입력 | 동작 |
| --- | --- |
| 우클릭 땅 | 이동. 평타 대상·공격 이동·선딜을 모두 해제 |
| 우클릭 적 | 그 적을 평타 대상으로 지정 → 사거리(`relics.bolt_range()`, 기본 4m)까지 다가가 멈춰 서서 평타를 계속. 적이 움직이면 0.2초마다 경로 갱신 |
| 우클릭 털 난 양(낮) | 수확(좌클릭과 동일) |
| A → 좌클릭 | 공격 이동. 그 지점으로 가며 사거리+1m 안의 가장 가까운 적을 잡아 공격, 처치하면 목적지로 다시 간다. 클릭 지점 커서 아래 적이 있으면 그 적을 우선 대상으로 |
| A 대기 중 우클릭 / Esc | A 취소(우클릭은 그대로 이동/대상 지정). Esc는 일시 정지를 열지 않고 A만 취소 |
| S | 정지: 이동·평타 대상·공격 이동·선딜 취소 |
| Space | 카메라를 마녀에게 복귀(산장뷰 F4 상태에서도 추적으로 돌아옴). 이전 C 키 기능 |
| C | 공격 사거리 고리 켜기/끄기. A 대기 중에는 붉은 고리로 자동 표시 |
| 방향키 | 키보드 이동(이동·평타 명령 취소) |

## 평타 규칙(롤 기준)

- **서 있을 때만 자동 대상**: 이동 명령이 없을 때 사거리·시야 안 가장 가까운 적을 스스로 잡는다(사거리 밖으로 나가면 놓고 쫓지 않음). 이동 명령 중에는 쏘지 않는다. 이전의 "걸으면서 자동 사격"은 없어졌다.
- **선딜 0.22초**(`player.ATTACK_WINDUP`): 지팡이를 들어 올리는 동안 이동 명령이 오면 평타가 취소되고 쿨다운도 쓰지 않는다.
- **후딜 0.14초**(`ATTACK_BACKSWING`): 발사 뒤 자세. 이동 명령으로 바로 끊을 수 있어 "쏘고 → 우클릭 이동 → 다시 적 우클릭"의 무빙 평타가 된다.
- **주기**: 선딜 포함 `Cfg.BOLT_INTERVAL`(1초). 피해·흡혈·유물 배율은 기존 그대로.
- 공격 이동 중 잡은 적이 사거리+4m 밖으로 달아나면 놓고 목적지로 돌아간다.

## 시인성

- 적 마우스오버: 공격 커서(붉은 조준 고리) + **밝은 붉은 외곽선**(2.6px).
- 공격 대상: **진한 붉은 외곽선**(4.2px, 약하게 맥동) + 몸 가장자리의 옅은 붉은 덧칠. 커서가 떠나도 대상인 동안 유지.
- 구현: `shaders/target_outline.gdshader` — 뒷면만 그리는 껍질을 클립 공간에서 화면 픽셀 두께로 밀어낸다(카메라 줌과 무관한 두께). `scripts/visual/enemy_outline.gd` 가 적 `visual` 아래 모든 MeshInstance3D 의 `material_overlay` 에 건다. 오버레이라서 서리 거미의 IK 다리·스킨 메시도 그대로 따라간다.
- 선택 판정은 화면 공간: 적 발밑~머리(hp_offset) 선분까지의 거리가 max(30px, 선분 길이의 45%) 이내인 가장 가까운 적. UI 위에 커서가 있으면 판정하지 않는다.

## 기존 조작과의 관계(결정)

- **좌클릭은 UI·상호작용 전용**: 카드 드래그, 털 난 양 수확, 손님 고용, 산장·제단 열기, 작은 지도 이동은 그대로. **땅 좌클릭 이동은 제거**(롤과 같음).
- **WASD 이동 제거, 방향키 이동 유지**: A(공격 이동)·S(정지)가 WASD와 겹치므로 롤 방식을 우선했다. W·D도 함께 비워 둔다(이후 스킬 키 후보).
- 카드 드래그 중 우클릭은 기존대로 손패가 드래그 취소로 처리한다(이동 명령으로 가로채지 않음).
- H(산장 정문으로 이동)·F4(산장뷰)·휠 줌·Esc 일시 정지는 그대로.

## 파일

- `godot/scripts/game/lol_controls.gd` — 입력·호버·커서·외곽선 동기화·사거리 고리
- `godot/scripts/actors/player.gd` — `command_attack / command_attack_move / command_stop`, `_update_attack`(선딜·후딜·추적)
- `godot/scripts/visual/enemy_outline.gd`, `godot/shaders/target_outline.gdshader`
- `godot/scripts/main.gd` — 컨트롤 노드 생성·입력 위임, 땅 좌클릭 이동 제거, 이동 키 바인딩

## 검증

- 헤드리스: `.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_lol_controls.gd` → 43/43 (실제 입력 이벤트로 우클릭·A·S·Space·C·Esc, 선딜 취소, 후딜 무빙, 공격 이동 처치 후 재개, 커서 아래 적 우선, 외곽선 상태 전환, 카드 드래그 중 우클릭 양보).
- 렌더 캡처(셰이더 컴파일·실제 색·두께는 헤드리스로 확인 불가): `.tools/Godot-4.7.2.exe --path godot --resolution 1600x900 --script res://tools/capture_lol_outline.gd` → `godot/screenshots/lol_controls/outline-day.png`, `outline-night.png`.
- 기존 검증 조정: `verify_guest_arrival.gd` 키보드 이동 항목은 S 대신 ↓ 키, `verify_exploration.gd` 확장 지역 클릭 이동은 우클릭으로.
- 회귀(2026-10-18): verify_wool_chain 23/23, verify_outside_click 25/25, verify_exploration 통과, verify_guest_events 통과. 이번 변경과 무관한 기존 실패: verify_first_session `[4] 첫 밤을 넘긴다`(마녀는 밤 내내 제자리에서 사거리 안 적을 쏨 — 예전 코드와 같은 행동, 산장 함락은 밸런스 문제), verify_guest_arrival 레이아웃·초상·손패 위치 3항목, verify_guest_click_lamb 패널 넘김 1항목.
