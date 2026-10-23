# 에린 대화 창 초상 모션 — 셰이더 아이들링과 등장 가슴 모핑 (2026-10-22)

사용자 요청: 에린과의 대화 창에서 에린이 본(bone) 애니메이션처럼 조금씩 아이들링하고, 대화를 시작하며 일러스트가 등장할 때
가슴 모핑이 부드럽게 흔들리게. 뼈·메시 없이 한 장 투명 초상(`assets/portraits/guest_erin_cutout.png`)을 **셰이더의 UV 비틀기**로 움직인다.

## 동작

| 요소 | 방식 | 크기 |
|---|---|---|
| 숨쉬기 | 발끝 고정, 상체가 약 3.5초 주기로 살짝 떠올랐다 내려앉고 몸통 폭이 가슴 높이에서 조금 넓어진다 | 세로 0.45% UV(600px 초상에서 약 3px) |
| 몸 흔들림 | 두 주기(0.53·0.91 rad/s)를 섞은 좌우 흔들림. 높이의 제곱에 비례해 머리 쪽이 가장 크다 | 최대 0.8% UV |
| 고개 | 머리 타원 마스크 안에서 숨에 맞춰 끄덕이고 느리게 기운다 | 0.25~0.35% UV |
| 가슴 숨 | 가슴 타원 마스크 안이 숨에 따라 중심에서 바깥으로 아주 조금 부푼다 | 1.5% 반경 |
| **등장 모핑** | 초상이 나타나기 시작하는 순간(`appear`=0)부터 감쇠 진동 `exp(-2.4t)·sin(9.5t)`: 세로로 흔들리며 중심에서 퍼졌다 돌아온다. 약 1.5초 뒤 거의 멈춤 | 최대 1.8% UV(약 11px) |

**상하 부유 제거(2026-10-22, 사용자 요청):** 아이들링이 켜진 초상(에린)은 대화 창 전체가 2px 폭으로 위아래로 떠다니던 기존 움직임(`sin(clock*0.7)*2`)을 끈다. 몸이 셰이더로 직접 숨쉬므로 초상 자체는 제자리에 있다. 아이들링이 없는 다른 손님은 기존 부유를 그대로 둔다. → 2026-10-23 모든 손님 부유 삭제([전 손님 초상 모션](portrait-motion-all.md)).

**등장 스케일 트윈(2026-10-22, 사용자 요청):** 초상이 나타날 때 **발끝(하단 중앙)을 피벗**으로 0.92배에서 시작해 ease-out-back(최대 약 +0.7% 넘었다 돌아옴)으로 0.63초 동안 대화창 배율까지 커진다. 시작 순간은 가슴 모핑 진동(`appear`=0)과 같다. 기존 14px 세로 미끄럼은 스케일로 대체했고 가로 22px 미끄럼과 알파 페이드는 유지. 대화창 배율(`dialogue_portrait_scale` 1.06, 위쪽 기준)의 최종 모습이 바뀌지 않도록 하단 피벗일 때 위치를 높이×(배율−1)만큼 내려 보정한다(`portrait_pivot_shift`). 모든 손님 초상에 적용.

모든 변위는 smootherstep 타원 마스크로 이어져 찢어지지 않고, 발끝(`pivot` y=1)은 움직이지 않는다. 변위가 0인 손님은 이전과 픽셀 단위로 같다.

## 파일

- `godot/shaders/guest_portrait_motion.gdshader`: 위 동작. uniform `motion_time`(시계)·`appear`(등장 뒤 시간, 음수면 없음)·`idle_amount`·`chest_amount`·
  `head_center`·`head_radius`·`chest_center`·`chest_radius`·`chest_freq`·`chest_decay`·`chest_swing`. `vertex()` 가 modulate 를 varying 으로 넘겨 등장 알파·종족색이 그대로 유지된다.
- `godot/scripts/ui/guest_arrival.gd`: 대화 창(presentation_only)과 도착 소개(compact) 초상 둘 다에 재질을 건다. `_show_guest` 에서 프로필의
  `portrait_motion` 을 실어 `appear` 를 −1 로 되돌리고, `_animate_guest` 가 매 프레임 `motion_time = clock`, `appear = phase_time − 0.06`(초상 알파가 올라오기 시작하는 시각)을 넣는다.
  같은 인물과 대화를 이어갈 때는 `update_dialogue` 만 불리므로 등장 흔들림은 대화를 **처음 열 때 한 번**이다.
- `godot/scripts/ui/guest_profiles.gd` 에린 SPECIALS 항목: `"portrait_motion": {"idle": 1.0, "chest": 1.0, "head_center": (0.55, 0.16), "head_radius": 0.17, "chest_center": (0.40, 0.36), "chest_radius": (0.15, 0.11)}`.
  좌표는 원화 UV(1122×1402). 다른 손님은 2026-10-23부터 종족·성격표로 아이들링한다([전 손님 초상 모션](portrait-motion-all.md)). 이 키를 직접 쓰면 표보다 우선.

## 검증

- 헤드리스 `tools/verify_portrait_motion.gd` **31/31**(상하 부유 제거 2항목, 등장 스케일 트윈 6항목: 하단 피벗·작게 시작·발끝 높이 고정·살짝 넘었다 복귀·최종 배율·머리 위치 불변 포함): 셰이더 파일·uniform, 대화 창·도착 초상 재질, 에린 프로필 값 적재(idle 1·chest 1·chest_center),
  등장 시간이 열린 직후 0.1초대에서 시작해 매 프레임 늘어남, 시계 진행, 대사를 넘겨도 등장 시간이 이어짐(재진동 없음), 일반 손님(브람)은 0.
- 실제 렌더 `tools/capture_portrait_motion.gd` → `godot/screenshots/erin-portrait-motion/` **4/4**: 셰이더가 실제로 컴파일되어 초상이 그려짐(헤드리스 더미 렌더러로는 컴파일 오류를 볼 수 없어 창을 띄움),
  등장 0.12~6초의 초상 컷 8장, 가슴 영역 3배 확대 컷(`chest-zoom-t*.png`), 0.28↔0.62초 차이 이미지(`diff-0.28-0.62.png`, 8배 증폭).
- 셰이더 컴파일러 경고 `custom_samplers`(card_view.gd)는 기존 카드 셰이더의 것으로 이 작업과 무관.

## 조정 포인트

- 더 크게/작게: 프로필 `"chest": 1.5` 처럼 세기만 바꾸거나 `chest_swing`(변위)·`chest_decay`(얼마나 빨리 멈추는지)·`chest_freq`(빠르기)를 프로필 키로 넘긴다.
- 아이들링만 쓰고 싶은 손님: `"chest": 0.0`.

## 대화 포트레이트 밑단 마감 (2026-10-22)

사용자 요청에 따라 원본 일러스트를 재생성하거나 편집하지 않고, 대화창에서만 `rounded_hem` 알파 마스크로 치마의 직선 절단을 완만한 곡선과 작은 비대칭 요철로 정리했다. 경계 약 1px의 안티앨리어싱 외에는 페이드·색보정·블러를 추가하지 않는다. RGB 샘플링과 기존 모션은 그대로다.

에린 프로필의 `dialogue_portrait_scale: 1.06`으로 대화창 표시 크기를 가로·세로 6% 확대한다. 상단 중심을 기준으로 균등 확대하며 원본 PNG의 크기는 바꾸지 않는다. `dialogue_portrait_rounded_hem: true`도 대화창 전용이다. 다른 인물로 바뀌면 배율 1·마스크 꺼짐으로 복구된다.

- 원본 `guest_erin_cutout.png` SHA-256(변경 전후 동일): `683F5088D95540A5668421B85C5E11089B39E3B95BA61258EB86938072EDD4D7`.
- `tools/capture_erin_hem.gd` 실제 GPU 렌더: 상단 85% 변경 픽셀 0개, 맨 아래 행 불투명 픽셀 0개, 다른 인물 전환 시 설정 복구 통과.
- [수정 전](../output/erin-portrait-hem/01-before.png) · [수정 후](../output/erin-portrait-hem/02-after.png) · [960×540](../output/erin-portrait-hem/03-after-960.png) · [원본 크기 마감 검토](../output/erin-portrait-hem/native-hem.png).
- 기존 초상 모션 검증 23/23 통과.
- 루트 `WitchsLodge.exe` 단일 파일을 다시 내보냈다. [내장 데이터 검사](../output/erin-portrait-hem/packed-check.log)에서 마감 켜짐·배율 1.06·포트레이트 디코딩 픽셀의 원본 일치를 확인했다.
