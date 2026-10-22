# 손님 말 걸기 알림 · 시안 03 적용 v01

2026-10-22~23 · 사용자 선택 시안 `output/guest-speech-simplified-v02/03-speech-only.png`(원형 초상 메달 + 종이 말풍선 + 꺾쇠)대로 왼쪽 말 걸기 알림(`GuestSpeechNotification`)을 다시 만들었다. 이름 줄·대화 건수·기다림 막대·테두리 게이지는 없다(테두리 게이지는 사용자 요청으로 제거).

## 구성

- **초상 메달** `scripts/ui/speech_medal.gd`: 승인 틀 그림 `assets/ui/moon_runes/common/medal_frame.png`(코덱스, 리벳 박힌 나무·놋쇠 둥근 틀) 안에 손님 컷아웃을 넣는다. 초상은 두 조각으로 그린다 — 가름선(원 중심 위 0.55r) 아래는 틀 안쪽 원으로 잘라 틀 밑에, 위는 자르지 않고 틀 위에 얹어 투구·칼끝이 틀 밖으로 넘친다.
  - 일반 컷아웃: 머리 꼭대기·머리 폭을 재서(치켜든 무기 같은 가는 돌출 제외) 배율·위치를 정한다(`ZOOM`·`EYE_AT`).
  - **메달 전용 컷아웃 `*_medal.png`**(프로필 `medal_portrait`): 측정 없이 규격대로 — 불투명 상자를 가로 중심에, 꼭대기는 틀 바깥 테 3px 위, 높이는 원 지름의 1.45배. 그라즈는 시안 인물 그대로 그린 `assets/portraits/guest_graz_medal.png`를 쓴다([코덱스 요청](handoff/codex-speech-medal-portrait-graz-v01.md)). 파일이 없는 손님은 일반 컷아웃으로 돌아간다.
- **말풍선** (`guest_interactions.gd` `SpeechBubble`): 시안 그림을 편집 입력으로 복원한 양피지 `speech_paper.png`(768×256, 9분할, 1/3로 줄여 사용) + 왼쪽 꼬리 `speech_paper_tail.png` + 꺾쇠 `speech_chevron.png`([코덱스 v02](handoff/codex-speech-notification-v02.md)). 그림이 없으면 v01 → 평면 상자 순으로 대체. 글은 BM 을지로체 23pt, 글 길이에 따라 넓어지며 클릭 범위도 따라간다.
- 알림 전체가 클릭 대상이고 자식은 모두 마우스를 통과시킨다. 남은 시간은 메달의 `ratio` 값과 툴팁으로만 남아 기존 기다림 게이지 검증과 호환된다.

## 시안과의 수치 대조

`tools/measure_speech_notification.gd`가 시안 발췌(`docs/handoff/refs/speech-notification-concept-crop2x.png`)와 실제 캡처(`screenshots/speech-notification/2-graz-crop2x.png`)에서 같은 색 기준으로 틀·종이·글자·꺾쇠·피부를 찾아 치수를 비교한다. 2026-10-23 기준 틀 지름·말풍선 폭/높이/위치·꼬리·글자·꺾쇠 11항목은 모두 1 화면px 이내, 인물(틀 안 피부 상자)은 중심 0.02r 이내다. 금속 꼭대기 항목은 배경 눈밭이 섞여 참고용이다.

## 검증·캡처

- 헤드리스: `tools/verify_speech_notification.gd` 37항목(메달 배치·넘침·틀 그림·말풍선 크기/위치·클릭 범위·시간 값·대화 열고 닫기), 기존 `verify_wait_gauge.gd`·`verify_guest_events.gd` 통과.
- 실제 렌더 캡처 `tools/capture_speech_notification.gd` → `screenshots/speech-notification/`(헤드리스로 볼 수 없는 초상 크롭·틀 겹침·종이 질감·꼬리 이음새 확인). `3-concept-vs-game.png`가 시안/게임 비교.

## 제작 기록

- 말풍선 v01(평면, 폐기 아님·대체용): `art/ui/speech-notification-v01/`, v02: `art/ui/speech-notification-v02/`
- 메달 틀: `art/ui/speech-notification-v01/frame-*`
- 그라즈 메달 컷아웃: `art/portraits/graz-medal-v01/`
