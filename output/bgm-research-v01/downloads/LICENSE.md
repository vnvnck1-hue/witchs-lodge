# Epic Boss Battle [Seamlessly Looping]

- 파일: `Juhani Junkala - Epic Boss Battle [Seamlessly Looping].wav` (WAV, 44.1kHz 스테레오 16bit, 2분 3.4초, 21,773,152 바이트)
- 출처: https://opengameart.org/content/boss-battle-music (OpenGameArt, 올린 사람 SubspaceAudio, 작곡 Juhani Junkala — 파일 이름 기준)
- 원본 주소: https://opengameart.org/sites/default/files/Juhani%20Junkala%20-%20Epic%20Boss%20Battle%20%5BSeamlessly%20Looping%5D.wav
- 라이선스: **CC0 1.0 (퍼블릭 도메인)** — http://creativecommons.org/publicdomain/zero/1.0/ . 상업 사용·수정 가능, 크레딧 의무 없음(원하면 "Music: Juhani Junkala" 표기).
- 받은 날: 2026-10-23. 곡 설명: "Epic boss battle music inspired by God of War game series", 끊김 없이 반복(seamless loop).
- 용도 후보: 니벨라(서리 거미 보스) 보스전 BGM — 아직 게임 미적용.

## 게임 적용 (2026-10-23 14:20)

- `godot/assets/audio/bgm-boss-nivella.wav`, `selected.json` 의 `bgm_boss`(-8dB, 파일 보정 -8.5dB → 실효 평균 약 -17dB, 전투곡 -17.5~-18.9dB 와 맞춤, `seamless: true`).
- `sound_bank.gd`: 배경 곡에 `bgm_boss` 추가, `boss_mix`(들어갈 때 1.2초 `BOSS_IN`, 나갈 때 4초 `BOSS_OUT`, 같은 세기 사인/코사인 교차). 보스 곡이 켜지면 낮·저녁·전투 곡을 모두 그만큼 내린다. 들어갈 때마다 처음부터.
  - `seamless` 곡은 끝→처음을 4초 겹치지 않고 엔진 반복(WAV LOOP_FORWARD, 전체 길이)으로 돈다.
- `boss_room.gd wants_music()`: 둥지 안 + 보스 살아 있음 + 등장 연출(알아챔 NOTICE)부터. 둥지를 나가거나 보스가 쓰러지면 꺼짐.
- 검증 `godot/tools/verify_boss_bgm.gd` 12/12([../verify_boss_bgm.txt](../verify_boss_bgm.txt)), `verify_bgm_mix` 20/20, `verify_boss_room` 57/57, `verify_sfx_v02` 42/42. 크레딧: `docs/credits.md`.
