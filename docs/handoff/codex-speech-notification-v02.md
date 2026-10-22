# Codex에게 요청하는 에셋 작업 — 말 걸기 말풍선 v02 · 시안과 똑같이

요청자: Claude (게임 구현 담당) · 2026-10-22 · 이전: [v01 말풍선](codex-speech-notification-v01.md), [메달 틀](codex-speech-medal-frame-v01.md)

## 사용자 피드백

v01 말풍선(`godot/assets/ui/moon_runes/common/speech_plain.png`, `speech_tail_left.png`)을 게임에 넣어 보여 드렸더니:

> 말풍선도 컨셉 시안과 다르니까 컨셉 시안과 똑같이 다시 해주고 (…) 무조건 비주얼적으로는 모든 부분이 컨셉 시안과 최대한 동일해야해.

v01은 **평평한 단색 크림 면 + 가는 균일 선**이라 시안의 양피지 질감·먹선·테두리 빛이 모두 빠졌다. 이번에는 **시안 그림 자체를 편집 입력으로 써서** 같은 물건을 만든다. "비슷한 느낌"이 아니라 **나란히 놓았을 때 같은 그림**이어야 한다.

## 목표 시안

- 전체: `docs/handoff/refs/speech-notification-concept-crop2x.png` (시안 왼쪽 알림 2배)
- 말풍선만: `docs/handoff/refs/speech-bubble-concept-crop3x.png` (3배)
- 화살표만: `docs/handoff/refs/speech-chevron-concept-crop6x.png` (6배)
- 원본: `output/guest-speech-simplified-v02/03-speech-only.png` (1774×887)

시안 말풍선의 특징을 그대로 옮긴다:

1. **양피지 종이**: 따뜻한 크림색 바탕에 결·얼룩이 보이는 종이 질감. 가장자리로 갈수록 살짝 어두워지는 비네트(안쪽 그림자). 균일한 단색 금지.
2. **먹선**: 짙은 자두색 선 약 3~4px(시안 1배 기준). 선 바깥에 **옅은 보라 빛 번짐(부드러운 외곽 글로우)** 이 가늘게 있다.
3. **모양**: 모서리 반지름이 작은(약 12px) 가로로 긴 사각형. 위·아래 변이 아주 살짝 안쪽으로 눌린 듯한 손그림 느낌.
4. **꼬리**: 왼쪽 변 세로 가운데에서 왼쪽으로 뻗는 작은 삼각 꼬리. 같은 종이·같은 먹선.
5. **화살표**: 오른쪽 끝의 가는 꺾쇠 `>` 모양(두께 약 3px, 높이 약 22px). 지금 게임이 쓰는 두꺼운 화살표 아이콘과 다르다.

## 만들 것

| 파일 | 크기 | 내용 |
| --- | --- | --- |
| `godot/assets/ui/moon_runes/common/speech_paper.png` | 768×256 RGBA | 말풍선 **몸통만**(꼬리 없음). 9분할. 시안 말풍선을 편집 입력으로 하여 가로로 늘린 것 |
| `godot/assets/ui/moon_runes/common/speech_paper_tail.png` | 96×96 RGBA | **왼쪽을 가리키는 꼬리**. 오른쪽 x 60~96 구간은 먹선 없이 종이 면만(몸통 왼쪽 선 위에 겹친다) |
| `godot/assets/ui/moon_runes/common/speech_chevron.png` | 64×64 RGBA | 시안의 가는 꺾쇠 `>` 하나. 먹선 색. 바깥 투명 |

### 몸통 9분할 조건

- 네 모서리와 네 변의 먹선·글로우·비네트는 각 변에서 **40px 안쪽**까지. 가운데(가로 40~728, 세로 40~216)는 종이 질감만 있는 면이어야 하며, **가로로 2배·세로 1.5배 늘려도 늘어난 티가 나지 않을 만큼** 결이 균일하고 잔잔해야 한다. 가운데에 큰 얼룩·접힘·방향성 있는 무늬 금지.
- 글자 없음. 바깥은 진짜 투명(alpha 0). 글로우는 먹선 바로 바깥 6px 안에서 끝나고 그 밖은 alpha 0.

### 색

시안에서 직접 뽑는다(v01 때 뽑은 종이 `#F6E0BA`, 먹선 `#3A223D` 근처). 종이의 가운데는 밝고 가장자리는 몇 단계 어둡다.

## 검수 시트 — 반드시 만든다

`art/ui/speech-notification-v02/sheet.png`: 위 줄에 **시안 말풍선 발췌(3배)**, 아래 줄에 **새 몸통+꼬리+꺾쇠를 같은 크기로 합성한 것**(글자 자리는 비움). 둘이 같은 물건으로 보이지 않으면 다시 만든다. 밝은 눈밭 배경(`godot/screenshots/speech-notification/1-graz-full.png`의 알림 자리 배경) 위에도 한 번 합성한다.

## 역할 분담

- **Codex 책임:** PNG 3장 생성·후처리(알파, 9분할 평탄화, 꼬리 접합부)·검수 시트·프롬프트 기록·README.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/assets/cards/**`, `godot/assets/ui/moon_runes/extension_v01/**`, `godot/assets/ui/moon_runes/approved/**`, v01 산출물(`speech_plain.png`, `speech_tail_left.png`, `medal_frame.png`, `art/ui/speech-notification-v01/`), 루트 `WitchsLodge.exe`, 다른 `docs/` 문서. 커밋하지 말 것. Godot 임포트·내보내기는 Claude가 한다.

## 산출물

| 용도 | 경로 |
| --- | --- |
| 게임용 PNG 3장 | 위 표의 세 경로 |
| 초안·생성 원본 | `art/ui/speech-notification-v02/drafts/` |
| 검수 시트 | `art/ui/speech-notification-v02/sheet.png` |
| 프롬프트·설명 | `art/ui/speech-notification-v02/prompts.md`, `README.md` |

## 완료 기준

1. 세 PNG가 지정 크기·RGBA, 바깥 alpha 0, 글자 없음.
2. 검수 시트에서 시안 발췌와 새 합성이 **같은 그림**으로 보인다(종이 질감·비네트·먹선 두께·보라 글로우·꼬리·꺾쇠 모두).
3. 몸통을 가로 2배·세로 1.5배로 늘린 합성에서 늘어난 티가 없다.
4. 꼬리를 몸통에 겹쳤을 때 먹선이 하나로 이어진다.
