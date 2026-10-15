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
