# 마녀산장 — 빈 소리 v02 (P1·P2 30종)

작성일: 2026-10-19. 요청: [빈 소리 조사](../audio-audit-v02/missing-sounds.html)의 P1·P2 전부 제작·적용(프롤로그 음악은 목록에서 뺌). 인물 대사 풀더빙은 하지 않기로 함.

- 생성: ElevenLabs 공식 API `eleven_text_to_sound_v2`, 소리마다 후보 4개 → `raw/<key>-0N.mp3` (`node gen.mjs [후보수] [key...]`, 키는 `%USERPROFILE%\.elevenlabs\api_key`). 약 1,450크레딧.
- 프롬프트: [prompts.json](prompts.json) — 중세 기반 판타지 공통 문구(`style`).
- 다듬기·선택: v01과 같은 [edit_rules.js](edit_rules.js)(새 키를 trim/swell 목록에 추가), `node pick_server.mjs` → `http://localhost:5180/pick` → `edited/<key>.wav`, [picks.json](picks.json).
- 게임 적용: `godot/assets/audio/sfx-<key>.wav`, `selected.json` 에 30개 이벤트(타격 -9dB, 연출음 -8dB, 컷 넘김 -10dB). 모든 호출은 `play_or(새 소리, 예전 소리)`.
  - 적 종류별: `monster.gd` `KIND_SFX`(보스·침식된 자·공성 괴물) / 늑대: `player.gd` / 활: `ally.gd _shoot` / 반딧불 흩어짐: `firefly_swarm.gd`
  - 카드 효과: `card_use_resolver.gd`(태우기·장작·스튜·정화·초대장·목재 적립·덩굴·반딧불·축복·늑대의 피·달) / 침식·제단·의식: `chapter_director.gd` / 프롤로그 컷: `prologue.gd _start_cut`
  - 코드만 고친 것: 시장 구매 소리 `gold_reward` → `gold_spend`.
- 검증: `godot/tools/verify_sfx_v02.gd` 32/32 → [verification.txt](verification.txt). 기존 `verify_bgm_mix` 20/20, `verify_guest_voices` 54/54.
  - `verify_game_sfx` 81/86: 등불 3종·merc_die·grave_rise 실패는 이번 수정을 되돌려도 똑같이 나와 이전부터 있던 문제(다른 세션의 규칙 변경 추정).
  - `verify_card_sfx`: '손패 가득 찰 때까지 서리 룬 추가' 반복이 끝나지 않아 시간 초과 — 카드 보관 규칙 변경 영향 추정, 이번 작업과 무관.
- 검토 페이지: [game-sfx-v02.html](game-sfx-v02.html) (`node build_page.mjs`).
- 실행파일: 루트 `WitchsLodge.exe` 재출력(2026-10-19 15:04).

## 추가 요청 (2026-10-19)

- **카드 태우기 다시**: "화악! 하고 타들어가는 느낌" → [prompts-redo.json](prompts-redo.json), `REDO=1 node gen.mjs 4` → `raw-redo/`, `meta-redo.json`, 수치 선택 `/pick-redo` → [picks-redo.json](picks-redo.json). 새 후보 1(0.93초) 적용.
- **산장 관리 메뉴 손님 생활 앰비언스(lodge_ambience)**: 20초 반복음 4개 생성(API `loop: true`), 이음매가 가장 고른 1번 적용, -12dB.
  - `sound_bank.gd _room_ambience`: 메뉴가 열려 '방' 모드가 켜지면 1.2초에 걸쳐 들어오고 닫으면 0.6초에 빠짐. 게임이 멈춘 동안에도 재생(PROCESS_MODE_ALWAYS, 트윈 PAUSE_PROCESS).
  - 검증 `verify_sfx_v02.gd` 35/35(열림 재생·정지 중 음량·닫힘 멈춤 3항목 추가). 이 추가 생성 약 850크레딧.
- 실행판 재출력, 검토 페이지 맨 위 "다시 만들기 · 추가" 그룹.
- **앰비언스 2차(같은 날)**: "식기 부딪힘·손님 떠드는 소리·발소리, 난롯가 로비에서 먹고 마시는 느낌"으로 다시 → 프롬프트 강화(450자 제한 안), `prompt_influence 0.5`, 22초, 후보 5~8. 선택은 `/pick-redo?key=lodge_ambience&min=5`(새 후보만, 다른 항목 유지) → 5번 적용. 약 880크레딧. 검증 35/35, 실행판 재출력.
- **앰비언스 3차(같은 날)**: "선술집 느낌이 안 나고 웃고 떠드는 소리가 없다".
  - 원인: 공통 문구의 '눈 덮인 숲'(STT가 1·2차 일부를 '눈 위 걷는 소리'로 인식), 'no clear words' 표현, 반복음 자동 선택이 고른 음량(=밋밋함)을 선호.
  - 바꾼 점: 반복음 전용 문구 `loop_style`, 선술집 군중 프롬프트(`prompt_influence 0.7`) → 후보 9~12, STT 소리 사건 태그로 '군중 소리' 인식(9·11·12) 중 음량 최대·이음매 최소인 12번을 직접 선택(`amb_events.mjs`).
  - 한 덩어리 앰비언스에는 웃음이 잡히지 않아(STT 웃음 0) 웃음 4개(`lodge_laugh`, 모두 STT 웃음 인식)·건배 3개(`lodge_toast` 2~4, 1번은 비명으로 인식돼 뺌)를 따로 만들고, `sound_bank._room_life_timer` 가 메뉴가 열린 동안 3~8초마다 무작위(웃음 65%)로 얹는다(정지 중에도 동작, 닫으면 멈춤).
  - 음량: 바탕 -9dB, 웃음 -13dB, 건배 -14dB. 검토 페이지 맨 위에 같은 규칙의 30초 믹스 미리듣기(`edited/preview_lodge_mix.wav`).
  - 약 1,100크레딧. 검증 37/37, 실행판 재출력(15:31).
- **앰비언스 4차(같은 날)**: "사람이 너무 많다, 10명 정도 소규모 선술집으로" → 후보 13~16(테이블 두세 곳의 대화·가끔 웃음·잔·발소리·난롯불, `prompt_influence 0.7`). STT는 대부분 '난롯불'로 인식 → 대역 측정(말소리 900Hz 대역 비율)·이음매로 14번 선택(이음매 0.57dB, 말소리 대역 -4.4dB로 가장 뚜렷). 조용한 구간이 많아 게임 음량 -3dB. 웃음·건배 무작위 섞기는 그대로. 약 880크레딧. 검증 37/37, 실행판 재출력(15:37), 미리듣기 믹스 갱신.
- **둘이 나누는 짧은 웃음(같은 날)**: "웃음이 너무 단체" → `lodge_laugh_small` 6개 생성(모두 STT 웃음), 2·5번은 영어 "Yeah"가 들려 빼고 1·3·4·6번(1.8~2.0초) 사용, -13dB. 섞는 비율 `ROOM_LIFE`: 둘이 웃음 45% · 단체 웃음 25% · 건배 30%. 120크레딧. 검증 38/38, 실행판 재출력, 미리듣기 믹스 갱신.
  - 주의: `/pick`(일반 모드)를 열면 30종을 다시 골라 `edited/`·`picks.json` 을 덮는다 → 이번에 한 번 열려 `edited/card_burn.wav` 를 게임 파일로 복구함(선택 결과는 같음). 앞으로 다듬기 스크립트는 `/pick-redo?key=...` 에서 돌린다.

## 사용자 검토 적용 (2026-10-19 15:59)

- 유지 21개, 바꾸기 14개: 늑대 할퀴기 4·덮치기 3·물기 1·돌아옴 3·피 마시기 4, 달 카드 1, 덩굴 1, 반딧불 흩어짐 2, 장작 2, 스튜 4, 침식 4, 의식·축복 1, 활 2 → [picks.json](picks.json) `by: user`(이전 수치 선택은 `auto_pick`).
- 산장 메뉴 바탕음: 1차 후보 1(조용한 실내) → 4차 14번보다 3.7dB 조용해 게임 음량 -3 → 0dB로 체감 크기 맞춤. 웃음·건배 무작위 섞기는 그대로. 미리듣기 믹스 갱신.
- 검증 38/38, 실행판 재출력.

## 돌풍·눈보라 다시 (2026-10-20)

- "어색하다, 더 자연스럽게" → `gust` 후보 4개(서서히 커져 소나무 사이를 훑고 눈발이 쓸리다 잦아듦, 휘파람 없음, 3초, `prompt_influence 0.5`), 120크레딧. 이전 게임 파일은 `previous/sfx-gust.wav`.
- 타격음이 아니라 임팩트 점수 대신 50ms 포락선으로 판단: STT 4개 모두 whooshing, 3번이 최대 상승 4.8dB(가장 부드러움)·정점 0.39·끝까지 잦아듦 → 적용(2.85초).
- `verify_game_sfx` gust 재생 확인(81/86, 실패 5개는 이전과 같은 기존 문제), 실행판 재출력(10-20 13:11).
- **사용자 선택 1번 + 보정(10-20)**: `gust` = 1번을 70Hz 고역통과·7kHz 저역통과, 사인 페이드 인 0.35s/아웃 0.9s, 정점 -4dB(2.76초).
  - **약한 앰비언트 `gust_soft`(새로)**: 같은 1번을 2.2kHz 저역통과·0.85배 재생(멀리서 넓게), 페이드 0.9s/1.6s, 게임 -24dB(3.29초). `weather_vfx._start_gust` 에서 세기 0.8 미만 돌풍(전에는 무음)일 때 재생 → 낮에 6~12초 간격 돌풍 중 약한 것만, 가끔 깔리는 바람. 알림음을 막지 않게 `AMBIENT` 에 포함.
  - 검증 `verify_sfx_v02` 40/40(돌풍 2항목 추가), 실행판 재출력.
- **잔잔한 눈보라로 새로(10-20)**: "그냥 다시 만들어줘, 잔잔한 눈보라" → 3차(5~8, "gentle calm snowstorm") 는 STT가 징글·휘파람·정적으로 인식하고 스펙트럼 평탄도 0.02~0.04(음정 성분 강함)라 버림. 4차(9~12, "soft low rushing air + snow hiss, breathy noise only, no tone") 평탄도 0.06~0.20 → 9번(0.167, 최대 상승 8.2dB) 적용. 보정은 앞뒤 무음 정리·끝 0.3s 페이드·정점 -4dB만(4.0초 전체, trim 모드의 3초 제한 대신). `gust_soft` 는 같은 파일을 필터 없이 -24dB(전용 파일 삭제). 320크레딧. 검증 40/40, 실행판 재출력(13:41).
- **눈보라 3종 최종(10-20, 사용자 선택 — [gust-review.html](gust-review.html) `node build_gust.mjs`)**: 1차 후보 1(gust-01 → `sfx-gust-a.wav`, 무게 1 ≈ 10%, 매우 가끔) · 3차 후보 3(gust-07 → `sfx-gust-b.wav`, 무게 4.5 ≈ 45%, 소리가 빽빽해 파일 보정 -5dB) · 4차 후보 1(gust-09 → `sfx-gust.wav`, 무게 4.5 ≈ 45%). 셋 다 앞뒤 무음 정리·끝 0.3s 페이드·정점 -4dB, 원본 길이 그대로.
  - `gust`(-9dB)와 약한 앰비언트 `gust_soft`(-24dB)가 같은 3종·비율을 씀.
  - `sound_bank.gd`: `selected.json` 의 `weights: {파일: 무게}` 를 읽어 원샷을 무게대로 무작위 선택(`_pick_variant`, 무게 없으면 기존처럼 순서대로), 원샷에도 파일별 `trim_db` 적용.
  - 검증 `verify_sfx_v02` 42/42(2,000번 뽑기 222·890·888), `verify_bgm_mix` 20/20, `verify_guest_voices` 54/54, 실행판 재출력(14:07).
