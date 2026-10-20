# 마법 카드 연출 — 휘기·말기·비틀기·360° 회전 (2026-10-20)

카드가 마법의 힘을 받은 듯 자유롭게 휘고, 말리고, 비틀리며 핑그르르 도는 연출. 이 작업 전에는 카드 연출이 평면 이동·2D 회전뿐이었다.

## 구조

| 파일 | 역할 |
|---|---|
| `godot/scripts/ui/card_surface.gd` | 카드 그림을 13×19 정점 격자 메시로 그린다(TextureRect 대체). 정점이 있어야 휠 수 있다. 아래 줄부터 그려 두루마리의 말린 부분이 뒤로 가려진다. |
| `godot/shaders/card_warp.gdshaderinc` | 정점 3D 변형 + 원근 투영. 앞/뒷면 판정(뒷면은 `assets/cards/hand/card_back.png`), 휜 면 명암·반사광, 마법 포일 광택. 모든 값이 0이면 원래 평평한 카드. `card_burn`·`card_burn_glow` 가 같이 쓴다. |
| `godot/scripts/ui/card_view.gd` | `step_warp()`: 속도·가속·둥실 떠다님·연출 동작을 합쳐 셰이더에 보낸다. `flourish(kind)`: 정해진 짧은 동작. |
| `godot/scripts/ui/card_hand.gd` | 손패 사건에 연출 동작을 건다. |

## 셰이더 값 (`warp_*`)

`yaw`(Y축 회전, π면 뒷면) · `pitch` · `bend`(x: 폭 방향, +볼록/−오목, y: 높이 방향) · `roll`(0..1 아래에서 위로 두루마리) · `twist`(위·아래가 반대로 도는 비틀림) · `flutter`(흐르는 물결) · `magic`(포일 광택).

## 사건별 연출

| 사건 | 동작 |
|---|---|
| 카드 획득·주머니에서 뽑기 | `draw`: 뒷면으로 튀어나와 1바퀴 반 핑그르르 돌며 앞면 공개, 비틀림·휨·광택. 공개 줄에서는 둥실 떠 일렁임 |
| 공개 후 손패로 | `land`: 살랑 흔들리며 자리 잡음 |
| 손패 마우스 올림 | `hover`: 오목하게 휘었다 펴짐 + 마우스가 누르는 쪽이 들어가는 3D 기울기(`HOVER_YAW`·`HOVER_PITCH`) + 은은한 일렁임 |
| 집어 들기 | `pickup`: 종이가 튕기듯 휘청 |
| 끌기 | 움직이는 쪽으로 몸을 돌리고, 빠를수록 휘고 펄럭이며, 급히 꺾으면 비틀린다(젤리 스프링 `WARP_K`·`WARP_Z`) |
| 취소·사용 실패·스택 일부 사용 | `return`: 한 바퀴 비틀어 돌며 손패로 |
| 사용(소모) | `use`: 한 바퀴 돌며 비틀리고 오목하게 감기면서 보랏빛 불꽃으로 타오름 |
| 주머니로 | `stash`: 두루마리처럼 말리며 비스듬히 돌아 빨려 듦 |
| 스택 획득 복제본 | `toss`: 날아가며 한 바퀴 |

수량 배지는 평평한 겹이라 카드가 옆·뒤로 돌거나 말리는 동안 감춘다.

## 검증

- 헤드리스: `.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_magic.gd` (18/18)
- 렌더 캡처(정점 변형·뒷면·명암은 헤드리스 더미 렌더러로 볼 수 없어 창 실행): `tools/capture_card_magic.gd` → `godot/screenshots/card-magic/` (`poses.png`, `_sheet_*.png`)
- 기존 `verify_card_burn`·`verify_card_core`·`verify_race_job_cards` 에 실패 항목이 있다. `verify_card_burn` 은 목재가 스택 카드가 되어 한 장 사용해도 카드가 소모되지 않기 때문(확인함). 나머지는 고용→계약 카드 흐름에서 실패하며 연출 코드와는 무관해 보이지만 따로 확인하지는 않았다.
