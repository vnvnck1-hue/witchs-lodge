# 마녀산장 — 종족 손님 목소리 v02

작성일: 2026-10-18. 요청: 새 종족 손님(드워프·요정·고블린·수인·오크 35명)에게 v01(인간 7명)처럼 짧은 의성어 목소리. 조사 근거 [../../docs/sound-gap-list-v01.md](../../docs/sound-gap-list-v01.md) §1.

- 생성: ElevenLabs **eleven_v3** 공식 API(사용자가 만든 API 키, `%USERPROFILE%\.elevenlabs\api_key` — 저장소 밖). 인물마다 기본 목소리 하나를 고정하고 종족 태그 + 인물 태그 + 감정 태그 + 감탄사만 읽힘. 인물당 4개 × 35명 = 140개 → `raw/<id>-0N.wav`(PCM 24kHz — 이 플랜은 44.1kHz PCM 불가). 배역·문구 [cast.json](cast.json), 스크립트 [gen_voices.mjs](gen_voices.mjs).
  - 기본 목소리가 21개뿐이라 몇 개는 둘이 같이 씀(예: Bella — 시그뉘·니벨·에쉬카). 종족 태그로 구분: 드워프 `gruff, stocky` · 요정 `tiny, airy, high-pitched` · 고블린 `quick, nasal, scratchy` · 오크 `deep, booming`, 수인은 인물별(늑대·곰·토끼·올빼미·오소리).
- 다듬기: **이번 키에 STT 권한이 없어** v01의 받아쓰기 대신 음량 구간(20ms RMS, 최대치 -35dB 초과)으로 소리 난 부분만 남김. 쉼 0.1초, 최대 1.6초, 피크 -3dB, 끝 60ms 페이드, 0.35초 미만은 뒤에 무음을 붙임 → `edited/<id>-0N.wav`(24kHz 16bit 모노). 실제 단어를 말했는지는 기계로 확인하지 못함(원본 길이는 모두 2.6초 이하).
- 게임 적용: `godot/assets/audio/voice-<id>-0N.wav` 140개, `selected.json`에 `voice_<id>` 35개(파일 4개 번갈아, -10dB). 코드 변경 없음 — `SoundBank.voice()`가 이미 인물 id로 찾는다.
- 검증: `godot/tools/verify_guest_voices.gd`를 42명 전원 목소리 확인으로 바꿈 → 54/54 [verification.txt](verification.txt).
- 보고 페이지 [race-voices.html](race-voices.html) (`node build_page.mjs`, 틀 [../audio-review-kit](../audio-review-kit/README.md), 소리별 코멘트 칸). 사용자 승인(2026-10-18): 140개 모두 그대로 적용.
- 실행판(2026-10-18 21:00): 루트 `WitchsLodge.exe` 재내보내기(첫 시도는 임시 파일 이름 바꾸기 실패 → 남은 `WitchsLodge.tmp` 지우고 재시도 성공). 내보낸 exe 안에서 목소리를 따로 재생해 보지는 않았다.

## 술 주정뱅이 에린 (2026-10-20)

- 새 특별 손님 `erin`(사람, 떠돌이 술꾼 금발 미인, 늘 취해 있음 — `guest_profiles.gd`, 주점 카드 v1). 일반 손님 목록 밖이라 v02 42명 검증에 안 들어감.
- 목소리 **Lily**(사람 손님 중 미사용, 요정 윌로우·수인 셀렌과 같은 기본 목소리) + 인물 태그 `[tipsy young woman, slurring]`, stability 0(창의). 감탄사 4개: 킥킥+딸꾹 / "Heyyy~ mm-hmm~" / 딸꾹질+"Ooh~" / 한숨+웃음 → `node gen_voices.mjs tts erin` · `edit erin`(STT 단어 시각으로 다듬기, 0.94~1.46초).
- 게임: `voice-erin-01~04.wav`, `selected.json` `voice_erin`(-10dB). 코드 변경 없음(`SoundBank.voice()`가 인물 id로 찾음).
- 검증 `verify_guest_voices.gd` 에 에린 2항목 추가 → 56/56. 실행판 재출력(10-20 15:00). 검토 페이지 [erin-voice.html](erin-voice.html) (`node build_erin.mjs`).
- **2차(같은 날)**: "더 가녀리고 여린, 취해서 톤이 조금 올라간" → 태그 `[soft, delicate, frail young woman, a little tipsy, voice slightly raised]` 로 Jessica·Sarah·Laura 후보(`erin_jessica/sarah/laura`, 감탄사 4개씩).
- **부르는 듯한 추임새**: 처음엔 "주모~! 여기 한 잔 더~!" 같은 실제 대사로 만들었다가, 사용자 지적(대사 말고 다른 음성처럼 추임새만)에 따라 `old-order/` 로 치우고 말 없이 "Heyyy~!" · "Oi~ oi~!" · "Yoo-hoo~!" 로 4목소리 다시 생성(`erin_order_<목소리>`, 0.5~1.3초, 기본 1.6초 제한).
- **고르기 페이지 [erin-pick.html](erin-pick.html)** (`node build_erin_pick.mjs`): 후보 28개를 목소리별로, 여러 개 체크(게임에서 무작위로 돌려 씀)·소리별/전체 코멘트·결과 복사, 한 번만 재생. 게임에는 아직 1차 Lily 4개.
- 검토 틀(`../audio-game-sfx-v02/edit_rules.js`·`page.template.html`)에 '원본 그대로(raw)' 모드 추가 — 반복 재생 없이 한 번만. gust-review·erin-voice 페이지가 반복 재생되던 문제 수정.
- **사용자 선택 적용(10-20 15:22, [erin-pick.html](erin-pick.html) 결과)**:
  - `voice_erin` = 8개를 **무작위**(무게 모두 1, `sound_bank._pick_variant`)로: Jessica 딸꾹+"오~"(erin_jessica-03) · Sarah 킥킥+딸꾹(erin_sarah-01) · Sarah "헤이~"(erin_order_sarah-01) · Sarah "유~후~"(erin_order_sarah-03) · Laura 킥킥+딸꾹(erin_laura-01) · Laura "헤이~ 음~"(erin_laura-02) · Laura 한숨+웃음(erin_laura-04) · Laura "어이~ 어이~"(erin_order_laura-02) → `voice-erin-01~08.wav`(1차 Lily 4개는 게임에서 뺌).
  - `erin_card` = Jessica 손 흔드는 "유~후~"(erin_order_jessica-03) → `sfx-erin_card.wav`: **술 주정뱅이 에린 카드 사용 전용**(`tavern_cards.gd commit` 의 `drunken_erin`).
  - **술주정 카드**(`drunk_rant`) 사용 시 `voice_erin` 8개 중 무작위(전용음 제외). 공용 `card_play` 는 그대로 함께.
  - 검증 `verify_guest_voices` 59/59(에린 8개·무작위·카드 2종 사용음), `verify_sfx_v02` 42/42, 실행판 재출력.
