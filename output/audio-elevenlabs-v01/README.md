# 마녀산장 — ElevenLabs 효과음 후보 v01

작성일: 2026-10-14.

Godot 프로토타입의 마녀 자동 공격, 카드 드래그 사용, 숙박비·교역, 용 공물에 맞춰 4종을 생성하고 각 4개 후보, 총 16개 MP3를 다운로드했다. 게임 코드는 변경하지 않았다.

## 실제 생성 상태

| 효과음 | 지정 길이 | 후보 1 | 후보 2 | 후보 3 | 후보 4 | 용도 |
| --- | --- | --- | --- | --- | --- | --- |
| 마녀 마법탄 발사 | 0.7초 | [01](magic-bolt-01.mp3) | [02](magic-bolt-02.mp3) | [03](magic-bolt-03.mp3) | [04](magic-bolt-04.mp3) | 자동 공격 발사 |
| 카드 사용 | 0.5초 | [01](card-play-01.mp3) | [02](card-play-02.mp3) | [03](card-play-03.mp3) | [04](card-play-04.mp3) | 카드 사용 확정 |
| 골드 획득 | 1.0초 | [01](gold-reward-01.mp3) | [02](gold-reward-02.mp3) | [03](gold-reward-03.mp3) | [04](gold-reward-04.mp3) | 숙박비·양털 판매 수입 |
| 용 소환 | 4.0초 | [01](dragon-arrival-01.mp3) | [02](dragon-arrival-02.mp3) | [03](dragon-arrival-03.mp3) | [04](dragon-arrival-04.mp3) | 120G 공물로 용 등장 |

사이트: https://elevenlabs.io/sound-effects

작업·다운로드 화면: https://elevenlabs.io/app/sound-effects

로그인 완료 후 4종을 계정에서 생성했다. 생성 화면의 탐색 페이지 공유는 꺼짐, 반복 꺼짐, 프롬프트 영향도 30%, 프롬프트 자동 개선 꺼짐으로 사용했다. 기존 비로그인 마법탄·카드 체험 결과와 이번 파일은 별도 생성물이다. 물약 체험 결과는 이번 파일 묶음에 포함하지 않는다.

다운로드 메뉴는 `MP3 44.1kHz`로 표시되지만 실제 MPEG 헤더는 16개 모두 **48kHz, 스테레오**다. `inspect_mp3.py`로 모든 프레임이 끝까지 이어지고 잘린 프레임과 예기치 않은 바이트가 없는 것을 확인했다. SHA-256도 모두 다르다. 인코딩 프레임 패딩을 포함한 길이는 카드 0.552초, 마법탄 0.744초, 골드 1.056초, 용 4.056초다. 결과는 [audio-verification.json](audio-verification.json)에 있다. 이 검사는 청취·디코딩 음질 검사가 아니다.

후보의 최종 선택, 게임 내 음량 조절과 재생 연결은 아직 하지 않았다. 다운로드 원본은 무음 제거·음량 조절 없이 보존한다. 이 폴더의 JPG는 화면 기록이다.

## 계정 생성 기록

- [골드 획득](https://elevenlabs.io/app/sound-effects/history?id=B0jNmmazAKQBsGcvfzN4)
- [용 소환](https://elevenlabs.io/app/sound-effects/history?id=91DXgDGcUfCwMrRmO0Hk)
- [마법탄](https://elevenlabs.io/app/sound-effects/history?id=Nkr6JEUr1TRRlfb334Eg)
- [카드 사용](https://elevenlabs.io/app/sound-effects/history?id=Xigu6NVAwp5CngpSWPkj)

## 프롬프트

### 마녀 마법탄 — 생성 완료

```text
One short whimsical witch magic bolt cast for a stylized fantasy game: crisp airy whoosh, bright crystalline twinkle, tiny soft energy pop and a very short tail. Clean isolated dry sound, no speech, no music, no long reverb.
```

### 카드 사용 — 생성 완료

```text
One satisfying card-play UI sound for a cozy witch fantasy game: a quick thick parchment card flick and soft wooden tap, followed by a tiny magical sparkle confirming the action. Clean isolated dry sound, subtle and pleasant for frequent repetition, no speech, no music.
```

### 골드 획득 — 생성 완료

```text
One short gold reward sound for a cozy fantasy lodge game: three small gold coins clink into a leather pouch with a bright delicate uplifting magical ping. Clear and satisfying, clean isolated dry sound, no speech, no music, no casino sounds.
```

### 용 소환 — 생성 완료

```text
A single majestic guardian dragon arrival for a stylized fantasy game: a powerful pair of wing beats, a heavy landing on a wooden lodge roof, and one deep warm dragon roar. Magical and protective rather than terrifying. Clear ending, isolated sound effect, no speech, no music, no continuous background ambience.
```

## 후속 작업

후보를 청취·선정하고 필요하면 앞뒤 무음과 음량을 정리한 뒤 게임에 연결한다. 이번 요청에서는 게임 연결을 수행하지 않았다.

체험 페이지는 무료 계정의 상업 이용을 허용하지 않는다고 안내한다. 출시용 음원으로 사용할 경우 생성 당시 계정 플랜에 따른 이용 권리를 확인한다.
