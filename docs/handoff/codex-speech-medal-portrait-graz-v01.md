# Codex에게 요청하는 에셋 작업 — 메달 전용 그라즈 초상 컷아웃 v01 · 시안 인물 그대로

요청자: Claude (게임 구현 담당) · 2026-10-23 · 관련: [말풍선 v02](codex-speech-notification-v02.md), [메달 틀](codex-speech-medal-frame-v01.md)

## 배경

왼쪽 손님 말 걸기 알림을 시안 `output/guest-speech-simplified-v02/03-speech-only.png`과 픽셀 단위로 맞추는 중이다.
틀·말풍선·글자·꺾쇠는 1px 이내로 맞췄고, 인물도 얼굴 크기·위치는 맞췄지만 **원화(`godot/assets/portraits/guest_graz_cutout.png`)와 시안 속 그라즈의 머리·투구·칼 비율이 달라서** 투구 꼭대기 높이와 칼끝 위치가 시안과 같아지지 않는다.
사용자 요구: "무조건 비주얼적으로는 모든 부분이 컨셉 시안과 최대한 동일해야 해."
→ **시안 메달 속 그라즈를 그대로 옮긴 메달 전용 컷아웃**을 만든다. 기존 `guest_graz_cutout.png`(도착 소개·관리창용)는 그대로 둔다.

## 만들 것

| 파일 | 크기 | 내용 |
| --- | --- | --- |
| `godot/assets/portraits/guest_graz_medal.png` | 1122×1402 RGBA | 시안 메달 속 그라즈(포즈·투구·칼·표정·옷) 그대로의 **투명 배경 상반신 컷아웃**. 둥근 틀은 넣지 않는다 |

### 반드시 지킬 것

- **편집 입력은 시안이다**: `docs/handoff/refs/speech-medal-concept-crop3x.png`(시안 메달 3배 확대)와 원본 `03-speech-only.png`. 시안의 그라즈를 **틀 밖으로 꺼내 전신 상반신으로 보완**한다 — 틀에 가려 안 보이던 어깨·팔·칼의 나머지 부분을 같은 화풍으로 그려 채운다. 얼굴·투구·칼 각도·표정·목도리는 시안과 같아야 한다.
- 같은 인물임을 확인하기 위해 기존 `guest_graz_cutout.png`를 함께 참고하되, **비율은 시안을 따른다**(시안이 머리와 투구가 더 크고 칼이 더 높이 들려 있다).
- 화풍은 승인 카드 화풍(검은 먹선·큰 명암 색면·페인터리 질감, `art/concepts/portraits/card-style-v01/bram-card-style-v02.png`)이며 시안도 같은 화풍이다.
- **배치 규격은 다른 컷아웃과 같다**: 1122×1402, 투명 배경, 머리(칼끝 포함) 위 여백은 그림 높이의 약 8%, 인물 가로 중심은 그림 가로 중심, 가슴~허리에서 아래가 잘려도 된다. 참고로 기존 그라즈 컷아웃은 불투명 영역이 x 104~1016, y 112~1280 이다.
- 글자·틀·그림자·배경 없음. 바깥은 진짜 투명(alpha 0), 머리카락·털 가장자리는 색 번짐(halo) 없이.

## 검수 시트 — 반드시 만든다

`art/portraits/graz-medal-v01/sheet.png`: 왼쪽에 시안 메달 발췌(3배), 오른쪽에 **새 컷아웃을 시안과 같은 둥근 틀 크기로 잘라 얹은 합성**(틀은 `godot/assets/ui/moon_runes/common/medal_frame.png` 사용, 아래는 원 안에서 자르고 칼끝·투구는 틀 위로 넘치게). 두 그림이 같은 인물·같은 구도로 보여야 한다. 또 새 컷아웃 전체(투명 배경, 체크무늬 위)를 한 칸 더.

## 역할 분담

- **Codex 책임:** 컷아웃 생성·후처리(알파·배치 규격)·검수 시트·프롬프트 기록·README.
- **수정 금지:** `godot/scripts/**`, `godot/scenes/**`, `godot/shaders/**`, `godot/assets/cards/**`, `godot/assets/ui/**`, 기존 `godot/assets/portraits/guest_*_cutout.png` 전부, 루트 `WitchsLodge.exe`, 다른 `docs/` 문서. 커밋하지 말 것. Godot 임포트·내보내기는 Claude가 한다.

## 산출물

| 용도 | 경로 |
| --- | --- |
| 게임용 PNG | `godot/assets/portraits/guest_graz_medal.png` |
| 초안·생성 원본 | `art/portraits/graz-medal-v01/drafts/` |
| 검수 시트 | `art/portraits/graz-medal-v01/sheet.png` |
| 프롬프트·설명 | `art/portraits/graz-medal-v01/prompts.md`, `README.md` |

## 완료 기준

1. 1122×1402 RGBA, 바깥 alpha 0, 틀·글자·배경 없음, 머리 위 여백 약 8%.
2. 검수 시트에서 시안 메달과 새 합성이 **같은 인물·같은 포즈·같은 비율**로 보인다(투구 크기, 칼 각도와 높이, 귀, 목도리).
3. 기존 그라즈 컷아웃과 같은 인물로 읽힌다.
