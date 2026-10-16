# 카드 소모 연출 업그레이드 — 보랏빛 에디티브 글로우 · 검은 재 (2026-10-16)

카드를 사용해 타 없어질 때(드래그로 놓아 사용, 스택 일부 소모의 복제본 모두) 두 층을 더했다.

## 무엇이 바뀌었나

- **보랏빛 에디티브 글로우** — `shaders/card_burn_glow.gdshader`(`render_mode blend_add`). 카드 그림 위에 겹치는 별도 사각형
  (`CardView.burn_glow`)으로, 카드 표면 셰이더와 **같은 연소선**을 따라 잔광을 더한다. 선 위(남은 카드)는 넓게, 선 아래(탄 쪽)는
  좁은 숯불처럼 남고, 아직 타지 않은 카드 전체에는 아주 옅은 열기 덧빛이 깔린다. 카드 윤곽을 네 단계로 넓힌 마스크로 카드 밖
  (폭의 30%)까지 부드럽게 번진다. 끝나갈 때(진행 86% 이후) 함께 거둔다.
- **검은 재** — `CardView._spawn_ash()` 의 `CPUParticles2D`. 연소선 바로 아래 가로 띠에서 조각이 떨어져 나와 위로 떠오르며 좌우로
  흩어지고 회전한다. 막 떨어진 순간만 잠깐 보랏빛 잉걸이었다가 바로 검게 식는다. 카드가 먼저 지워져도 재가 끝까지 날리도록
  **카드의 형제 노드**로 붙이고, 소모가 끝나면 발생만 멈춘 뒤 수명(약 1.8초)이 지나면 지운다.
- 노이즈·연소선 계산을 `shaders/card_burn_noise.gdshaderinc` 로 빼서 카드 표면(`card_burn`)과 글로우 층이 같은 선을 쓴다.
  Godot 셰이더 include 의 함수 매개변수는 uniform 이름과 겹치면 컴파일 오류(`Redefinition`)가 나므로 `k_` 접두사를 쓴다.

조정값: 글로우 세기 `glow_strength`(0.42)·번짐 폭 `glow_width`·열기 `heat_tint`, 재 수량 `CardView.ASH_AMOUNT`(36)·수명 `ASH_LIFETIME`(1.15초).

## 검증

- 헤드리스 `tools/verify_card_burn.gd` 18항목: include·블렌드 모드·연소선 여유 상수 일치, 실제 사용 경로에서 글로우 층 표시·
  사각형 크기·progress 동기화, 재의 생성 위치가 아래→위로 이동·카드 변환 추종·카드 소멸 뒤 잔존·수명 뒤 삭제, 복제본 소모 경로.
- 실제 렌더 `tools/capture_card_burn.gd` (헤드리스로 확인 불가한 셰이더 컴파일·화면 결과만): `godot/screenshots/card-burn/`.
  첫 캡처에서 include 매개변수 충돌 컴파일 오류와, 접선 가속이 가로 발생 사각형에서 세로 방향이 되어 재 절반이 아래로 떨어지는 문제를 찾아 고쳤다.

```text
.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_burn.gd
.tools/Godot-4.7.2.exe --path godot --script res://tools/capture_card_burn.gd -- --out=screenshots/card-burn
```
