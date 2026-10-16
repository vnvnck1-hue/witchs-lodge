# 마녀산장 — 게임 효과음·BGM 후보 v01

작성일: 2026-10-15. ElevenLabs **Starter(유료, 상업 이용 가능)** 계정으로 생성. 사운드 목록 v01([체크 목록](../sound-checklist-v01/sound-checklist.html))에서 고른 84개(효과음 82 + BGM 2).

- 효과음: `eleven_text_to_sound_v2`, 프롬프트 영향도 30%, 항목별 길이 지정(0.5~8초), 반복음 5종은 loop. 항목당 후보 4개 → `raw/<key>-0N.ogg` (Ogg Opus 48kHz) 328개. 프롬프트·길이 [prompts.json](prompts.json), 파일별 기록 ID [meta.json](meta.json).
- BGM: Eleven Music, 60초, 저녁·전투 각 2곡 → `music/<key>-0N.mp3`.
- 사용 크레딧: 효과음 1,455 + BGM 약 3,600 (잔여 약 30,100 / 35,292).
- 시청 페이지 [game-sfx.html](game-sfx.html): 다듬은 소리와 원본을 비교하며 후보 선택. 다시 만들기: `node build_page.mjs`.
- 다듬기 규칙 [edit_rules.js](edit_rules.js) (페이지에서 실시간 적용, 게임용 WAV 출력에도 같은 코드 사용 예정):
  - **임팩트 1개**(240개): 가장 큰 타격 하나만 남김, 0.08~0.6초(UI 0.25초 이하). 평균 0.84초 → 0.31초, 원본 121개가 여러 타격이었고 다듬은 뒤 전부 1개.
  - **앞뒤만 정리**(68개): 승리·패배·웨이브 시작·새벽·붕괴·돌풍 등 연출음은 흐름 유지, 무음만 정리(최대 3초).
  - **반복음**(20개): 등불·곤충 날갯짓·위험 지역·모닥불·용 날갯짓은 손대지 않음.
- 공식 API 스크립트 [eleven_api.mjs](eleven_api.mjs): 환경 변수 `ELEVENLABS_API_KEY`가 있으면 브라우저 없이 생성해 바로 저장. 이번 생성은 로그인된 브라우저 세션으로 했다.

## 게임 적용 (2026-10-15)

사용자가 "알아서 골라 적용"을 요청해 수치 기준으로 항목마다 하나를 골라 84개 모두 연결했다([picks.json](picks.json), 규칙 [pick.js](pick.js)). 듣고 고른 것이 아니다.
- 원샷: 원본 피크가 너무 작지 않고(-15dB 미만 감점), 타격 앞 잡음 바닥이 낮고, 원본 타격 수가 적은 후보. 반복음·BGM: 처음·끝 음량 차(이음매)와 100ms 음량 흔들림이 작은 후보.
- 다듬은 WAV(48kHz 모노) `edited/<key>.wav` → `godot/assets/audio/sfx-<key>.wav`·`build/audio/`, BGM `bgm-evening-0N.mp3`·`bgm-combat-0N.mp3`. `selected.json`에 98개 이벤트(마법탄 발사는 기존 `magic_bolt` 이벤트에 연결).
- 코드: `scripts/audio/sfx.gd`(어디서든 `Sfx.play`·`Sfx.loop`), `sound_bank.gd`(selected.json의 모든 이벤트 허용, 전투 BGM 크로스페이드, 거리·상태 기반 반복음, 정지 중 UI 소리 허용, 모든 버튼 클릭·오버·불가 자동 연결, 알림음은 0.25초 동안 다른 사건 소리가 없을 때만).
- 검증: `godot/tools/verify_game_sfx.gd` — 실제 게임 장면 압축 플레이에서 84/84 재생, 전투 BGM 혼합 1.00 → [game-verification.json](game-verification.json). 기존 검사 갱신 후 통과(카드 효과음, 오디오 13/13, 카드 코어 52/52 ×3).
- 실행판 `build/WitchsLodge.pck` 재출력, 이전 판 `WitchsLodge-before-game-sfx.pck`.

## 다시 만들기 1차 (2026-10-16)

검토 결과 다시 만들기 5개에 따라 ElevenLabs(Starter, 로그인 브라우저 세션)로 생성. 사용 약 3,700 크레딧(누적 8,851 / 35,292).
- 효과음 4개 × 새 후보 4: `raw-redo/<key>-rN.ogg` — 이동 지점 찍기, 돌풍·눈보라, 새벽·낮 시작(닭 울음소리), 웨이브 시작. 기록 [meta-redo.json](meta-redo.json).
- BGM(판타지 어쿠스틱·태번 포크 스타일, 하스스톤류 분위기를 악기 묘사로 지정): 낮 칠 `music/bgm_day-01·02.mp3`(새 항목), 밤 전투 `music/bgm_combat-11·12.mp3`(전투 BGM 다시).
- 검토 페이지 [sfx-redo.html](sfx-redo.html) (`node build_redo.mjs`): 항목마다 지금 게임 소리 + 새 후보. 아직 게임에는 반영하지 않음(선택 대기).
- `godot/tools/verify_game_sfx.gd`를 프로젝트 규칙(PASS/FAIL, RESULT n/m, 실패 시 종료 코드 1)에 맞추고, 직업 카드(나무꾼·전사) 도입 뒤에도 매번 같은 결과가 나오게 고정 → 86/86 2회 연속.
- 적용(2026-10-16): 새 후보 중 수치 기준으로 골라([picks-redo.json](picks-redo.json)) 게임에 넣음 — 이동 지점 2, 돌풍 2, 새벽(닭) 2, 웨이브 시작 3, 낮 BGM `bgm-day-02.mp3`(bgm_field, 기존 field-chill 대신), 전투 BGM `bgm-combat-11.mp3`. `godot/assets/audio`·`build/audio` 와 두 `selected.json` 갱신. 실행판은 외부 `build/audio` 를 읽어 재출력 없이 반영된다(다른 세션의 카드 작업이 진행 중이라 pck 는 다시 내보내지 않음). `verify_game_sfx` 86/86, `verify_audio_review` 통과.

## 사용자 선택 반영·BGM 믹싱 (2026-10-16)

- 직접 고른 결과 반영: 이동 지점 찍기 → 새 후보 1, 웨이브 시작 → 새 후보 2, 전투 BGM → `bgm-combat-12.mp3`. 돌풍·새벽(닭)·낮 BGM 새 곡은 유지. 기록 [picks-redo.json](picks-redo.json)(`by: user`).
- 낮 BGM(`bgm_field`)은 기존 `field-chill-02.wav` 와 새 `bgm-day-02.mp3` 중 하나를 **새 날마다 무작위**로(낮 곡이 들리지 않는 밤 동안 바꿈).
- 음량 맞춤: `selected.json` 의 `trim_db`(파일별 보정)로 평균 레벨을 낮 기존곡(-20dB RMS) 기준에 맞춤 — 새 낮곡 -3.2, 저녁곡 -0.9, 전투곡 -3.1(전투는 약 1.5dB 크게).
- 전환 다듬기(`sound_bank.gd`): 사인·코사인 동등 전력 크로스페이드(겹치는 동안 총 음량 유지), 전투 진입 6초·퇴장 10초, 낮↔저녁은 진행도를 시간으로 따라가 새벽에 저녁곡이 끊기지 않음(최소 8초), 전투곡은 시작할 때마다 처음부터, 곡 끝→처음은 플레이어 두 개로 4초 겹쳐 이음.
- 검증 [godot/tools/verify_bgm_mix.gd](../../godot/tools/verify_bgm_mix.gd) 16/16, `verify_game_sfx` 86/86, `verify_audio_review`·`verify_card_sfx` 통과. 실행판은 `build/audio` 로 소리 파일을 읽지만 믹싱 코드는 pck 안에 있으므로 **새 믹싱은 pck 를 다시 내보내야 실행판에 들어간다**(다른 세션의 카드 작업이 진행 중이라 이번에는 내보내지 않음).
