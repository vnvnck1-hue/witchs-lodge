# 마녀산장 — 무료 BGM 적용 v01

작성일: 2026-10-17. [리서치](../../docs/bgm-free-sources-research.md)·[청취 목록](listen-checklist.md)에서 사용자가 고른 4곡을 내려받아 낮·밤 전투 BGM 슬롯에 넣었다.
원본은 `raw/`, 출처·라이선스는 [sources.json](sources.json), 크레딧 문구는 [docs/credits.md](../../docs/credits.md).

## 적용 곡

| 슬롯 | 게임 파일 | 곡 | 작가 | 라이선스 | 길이 | 원본 RMS | trim_db |
|---|---|---|---|---|---|---|---|
| `bgm_field` 낮 | `bgm-day-21.mp3` | Medieval: Minstrel Dance | RandomMind (OGA) | CC0 | 2:19 | -15.6 dB | -4.7 |
| `bgm_field` 낮 | `bgm-day-22.mp3` | Medieval: Harvest Season | RandomMind (OGA) | CC0 | 3:34 | -14.0 dB | -6.3 |
| `bgm_combat` 밤 전투 | `bgm-combat-21.mp3` | Medieval: Battle | RandomMind (OGA) | CC0 | 1:19 | -16.8 dB | -2.7 |
| `bgm_combat` 밤 전투 | `bgm-combat-22.mp3` | Dentaneosuchus Hunt | Kevin MacLeod (incompetech) | **CC BY 4.0 — 크레딧 필수** | 4:07 | -17.8 dB | -1.7 |

- 낮 곡은 기존 `field-chill-02.wav`·`bgm-day-02.mp3` 대신 위 두 곡을 **새 날마다 무작위**로(기존 믹서 동작). 저녁 곡 `bgm-evening-01.mp3` 은 그대로.
- 전투 곡은 기존 `bgm-combat-12.mp3` 대신 위 두 곡을 **전투가 시작될 때마다 직전과 다른 곡으로 무작위** 선택해 처음부터 튼다(`sound_bank.gd` `_pick_random_deck` 추가).
- 기존 파일은 지우지 않고 `godot/assets/audio`·`build/audio` 에 남겨 두었다(선택만 바뀜).

## 음량 맞춤

브라우저 `OfflineAudioContext.decodeAudioData` 로 디코딩해 모노 RMS를 재고(이전 v01 과 같은 방식), 기존 곡의 실효 레벨에 맞췄다.
- 낮 기준: `field-chill-02.wav` -20.2 dB(보정 0) / `bgm-day-02.mp3` -17.3 dB(보정 -3.2) → 실효 약 -20.3 dB.
- 전투 기준: `bgm-combat-12.mp3` -16.4 dB(보정 -3.1) → 실효 약 -19.5 dB(낮보다 약 1 dB 큼, 기존 의도 유지).
- 피크는 네 곡 모두 -0.2 ~ -1.7 dB 로 클리핑 없음. Harvest Season 은 시작·끝 음량 차가 1.9 dB 로 작아 끝→처음 겹침이 자연스럽고, 나머지는 조용히 끝나므로 믹서의 4초 겹침으로 이어진다.

## 검증 (헤드리스)

- `tools/verify_bgm_free_sources.gd` **28/28** — 파일 존재·두 selected.json 일치·trim_db·디코딩 길이·sources.json 출처·크레딧 문서.
- `tools/verify_bgm_mix.gd` **20/20** — 새 보정값, 전투 곡 2개 무작위(40회 모두 등장, 직전과 다른 곡, 매번 처음부터) 항목 추가.
- `tools/verify_game_sfx.gd` **86/86** — 압축 플레이에서 밤 웨이브 전투 BGM 전환 유지.
- `tools/verify_audio_review.gd` — 첫 실행에서 "second approved variant rotates"(마법탄 효과음 0.15초 타이머 항목, BGM 과 무관) 1개가 실패했으나 이어진 2회 재실행은 모두 통과. 타이밍 플레이크로 본다.

## 실행판

`build/audio/` 는 실행파일이 외부에서 읽으므로 곡·선택은 바로 반영된다. 전투 곡 무작위 선택은 pck 안의 믹서 코드라 **pck 를 다시 내보내야 실행판에 들어간다**(다른 세션 작업 중이라 이번에는 내보내지 않음).
