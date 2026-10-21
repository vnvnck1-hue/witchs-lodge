# 손패 고민 시간 — 손패에 손을 올리면 세상이 천천히 멈춘다 (2026-10-21)

사용자 요청: "손패에 마우스를 올려놓으면 게임이 1초 동안 천천히 느려지다가 완전히 멈추게. 카드를 쓸지 고민할 시간을 주고 싶다.
불편할 수 있으니 완전히 멈추는 대신 시간이 거의 흐르지 않는 것처럼 매우 느려지는 프리셋도 하나."

## 동작

- 손패 카드 위에 마우스를 올리거나(hover) 카드를 끌고 있는(drag) 동안, 세상의 시간이 **1초에 걸쳐** 천천히 늦어진다.
  속도 곡선은 smoothstep — 올린 직후에는 거의 평소 속도고 0.5초에 절반, 1초에 목표 속도에 닿는다.
- 손을 떼면(호버 해제·카드 사용·취소) **0.35초** 만에 평소 속도로 돌아온다.
- 프리셋 세 가지. 일시정지 메뉴 '화면 설정 ▾' 의 **손패 고민 시간** 선택이나 **F12** 로 바꾸고, `user://settings.cfg` `[cards] hand_time` 에 저장된다.

| id | 이름 | 목표 속도 | 느낌 |
|---|---|---|---|
| `freeze` (기본) | 멈춤 | 0 | 완전 정지. 화살·괴물·낮밤이 그대로 선다 |
| `crawl` | 거의 멈춤 | 1/40 (0.025) | 시간이 거의 흐르지 않는 듯 — 화살이 허공에 걸린 채 아주 조금씩 나아간다 |
| `off` | 끔 | 1 | 예전처럼 시간을 건드리지 않는다 |

- 일시정지 메뉴·주머니·판매 창이 열리거나 판이 끝나면 즉시 평소 속도로 놓아 다른 정지 장치(`get_tree().paused`)와 겹치지 않는다.
- 촬영 도구가 `Engine.time_scale` 을 3배로 돌리는 중이면 그 위에 곱하고, 놓을 때 그 값으로 돌려준다.

## 구현 — `scripts/ui/hand_focus_time.gd`

- 세상은 `Engine.time_scale` 로 늦춘다(액터 `_process`·물리·애니메이션·파티클·세상 쪽 트윈·타이머가 모두 함께 늦어진다).
  모듈은 `main.gd` 가 `HandFocusTime` 노드로 두고 `hand = hud.card_hand` 를 잇는다. `PROCESS_MODE_ALWAYS`.
- **UI 는 실제 시간으로 움직인다.** `Engine.time_scale` 은 `PROCESS_MODE_ALWAYS` 노드의 delta 도 줄이므로, 손패가 멈춘 세상 위에서도
  가볍게 반응하도록 UI 쪽 `_process` 는 `HandTime.ui_delta(delta)` 를 쓴다(늦추는 동안엔 `Time.get_ticks_usec` 로 잰 실제 경과 시간, 평소엔 받은 delta 그대로).
  적용: 손패 `card_hand.gd`, 카드 고르기 들어 올림 `card_lift.gd`, 카드 연출 `card_fx.gd`(날아감·타 없어짐), 대화 옆 카드 `card_spotlight.gd`,
  소리 페이드 `sound_bank.gd`, 카메라 줌·따라가기 `player_camera.gd`.
- UI 트윈은 `create_tween().set_ignore_time_scale(true)`(손패 배지 펄스, 카드 연출 빛·수량 글자, HUD 알림·유물 등장, 스포트라이트 덮개),
  UI 타이머는 `create_timer(…, ignore_time_scale = true)`(타오름 빛 지연). 카드 재·연출 타이머는 이미 그렇게 돼 있었다.
- `spider_visual.gd` 는 delta 로 나누는 계산이 있어 완전 정지(delta 0) 프레임을 건너뛴다. 나머지 delta 나눗셈은 모두 `maxf(delta, …)` 로 보호돼 있다.
- 영문판 문구는 `assets/i18n/en.json`·`tools/i18n/overrides.json` 에 추가(Hand focus time · Freeze · Near freeze · Off).

## 검증

```text
.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_hand_focus_time.gd
```

- 단위: 프리셋 값, 0.05초엔 거의 평소 속도·0.5초엔 절반·1초에 0, 단조 감소, 유지, `ui_delta` 가 실제 시간, 손 뗀 뒤 0.35초 복귀,
  드래그 중에도 늦춤, 거의 멈춤 1/40, 끔, 창·판 종료·일시정지 예외, 다른 도구의 3배 위에 곱함, F12 순환, 저장.
- 소스: 보정 코드가 각 UI 스크립트에 들어 있는지, 영문 사전 문구.
- 실제 장면(`main.tscn` 헤드리스): 손패 카드 호버 강제 → 0.3초쯤 느려지는 중 → 1초 뒤 `Engine.time_scale` 0 → 멈춘 동안 카드가 들린 채 제자리 →
  손 떼면 1.0 → 일시정지 메뉴를 열면 즉시 1.0. 물리 프레임은 멈추므로 `process_frame` 으로 센다.
- 실제 화면 느낌(느려지는 곡선이 눈에 어떻게 보이는지)은 헤드리스로 알 수 없어 게임 실행파일로 확인한다.
