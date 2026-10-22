# Codex에게 요청하는 에셋 작업 — 손님 말 걸기 알림 초상 메달 틀 PNG v01

요청자: Claude (게임 구현 담당) · 2026-10-22 · 앞선 작업: [말풍선 2종](codex-speech-notification-v01.md)

## 사용자 피드백

말풍선 알림을 시안대로 구현해 보여 드렸더니:

> 컨셉 이미지랑 다르게, 인물 주변 테두리 틀이 그림이 아니고 그냥 게이지네? 시안컨셉은 그렇지 않잖아

→ 지금은 초상 둘레를 코드로 그린 단색 고리(어두운 받침 + 금색 가는 선)뿐이다. 시안처럼 **리벳이 박힌 나무·놋쇠 둥근 틀 그림**이 필요하다.
게임은 이 틀 그림을 둥근 초상 위에 얹고, 틀의 띠를 따라 '떠나기까지 남은 시간' 호를 그린다(호는 코드가 그린다).

## 만들 것

| 파일 | 크기 | 내용 |
| --- | --- | --- |
| `godot/assets/ui/moon_runes/common/medal_frame.png` | 512×512 RGBA | 둥근 초상 메달 **틀만**. 가운데(초상 자리)와 바깥은 **진짜 투명** |

### 틀 모양 — 시안을 그대로 따른다

참고 `docs/handoff/refs/speech-medal-concept-crop3x.png`(시안 메달 3배 확대)와 원본 `output/guest-speech-simplified-v02/03-speech-only.png` 왼쪽의 메달.

- **바깥 지름 = 그림 한 변의 96%**(약 492px, 중심 256,256). 띠 두께는 바깥 지름의 약 **11%**(약 54px). 그 안쪽은 전부 투명.
- 띠는 **따뜻한 갈색 나무결 + 놋쇠 금속 테**: 바깥 가장자리와 안쪽 가장자리에 밝은 놋쇠(황동) 선, 그 사이에 결이 보이는 어두운 갈색 나무 띠. 둘레를 따라 **작은 둥근 리벳 12~16개**가 일정 간격으로 박혀 있다(시안처럼).
- 안쪽 가장자리(초상과 만나는 곳)는 **짙은 먹선 2~3px**로 또렷하게 닫는다. 바깥 가장자리에도 가는 먹선.
- 위쪽 왼쪽에서 빛이 오고 아래쪽 오른쪽이 어두워지는 **가벼운 명암**. 사진 같은 반사·렌즈 하이라이트는 금지. 카드 화풍(검은 먹선·큰 색면·절제된 질감)을 지킨다.
- 글자·장식 보석·리본·배경·그림자(드롭섀도) 없음. 바깥은 alpha 0.
- 띠는 **회전 대칭**이어야 한다(리벳 간격 균일, 위아래 구분되는 장식 없음). 게임이 이 위에 호를 그리므로 띠 가운데 1/2 영역에는 리벳 외의 큰 무늬를 두지 않는다.

### 색 기준

시안에서 직접 뽑는다. 대략 나무 띠 `#6B3E22`~`#8A5530`, 놋쇠 선 `#C98E3E`~`#E6B860`, 먹선 `#2A1A2E`. 게임 팔레트는 [아트 가이드](../art-direction.md).

## 참고 입력

| 파일 | 쓰임 |
| --- | --- |
| `docs/handoff/refs/speech-medal-concept-crop3x.png` | **목표 틀 모양**(시안 확대) |
| `output/guest-speech-simplified-v02/03-speech-only.png` | 시안 원본(색·비율) |
| `godot/screenshots/speech-notification/4-graz-low-crop2x.png` | 지금 게임 모습(틀이 단색 고리인 상태). 이 둘레에 틀이 얹힌다 |
| `godot/assets/ui/moon_runes/common/speech_plain.png` | 같은 알림의 말풍선. 먹선 톤을 맞춘다 |

## 역할 분담

- **Codex 책임:** PNG 생성·후처리(가운데·바깥 알파 정리, 원형 정중앙 맞춤)·초안 보관·프롬프트 기록·README.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/assets/cards/**`, `godot/assets/ui/moon_runes/extension_v01/**`, `godot/assets/ui/moon_runes/approved/**`, `godot/assets/ui/moon_runes/common/speech_*.png`, 루트 `WitchsLodge.exe`, 다른 `docs/` 문서. 커밋하지 말 것. Godot 임포트·내보내기는 Claude가 한다.

## 산출물

| 용도 | 경로 |
| --- | --- |
| 게임용 PNG | `godot/assets/ui/moon_runes/common/medal_frame.png` |
| 초안·생성 원본 | `art/ui/speech-notification-v01/frame-drafts/` |
| 미리보기 | `art/ui/speech-notification-v01/frame-sheet.png` — 틀 단독(어두운 배경·밝은 배경) + 틀을 `godot/assets/portraits/guest_graz_cutout.png`의 둥글게 자른 얼굴 위에 얹은 합성 예 |
| 프롬프트·설명 | `art/ui/speech-notification-v01/frame-prompts.md`, `README.md`에 절 추가 |

## 완료 기준

1. 512×512 RGBA, 중심 (256,256), 바깥 지름 약 492px, 띠 약 54px, 띠 안팎은 alpha 0.
2. 시안 메달 틀과 나란히 놓았을 때 같은 물건으로 보인다(나무결 띠 + 놋쇠 테 + 리벳).
3. 회전 대칭이고 띠 가운데 영역에 큰 무늬가 없다.
4. 글자·그림자·배경 없음.
