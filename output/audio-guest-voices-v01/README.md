# 마녀산장 — 손님 인물 목소리 v01

작성일: 2026-10-17. 요청: 대화 이벤트가 열릴 때 알림음 대신, 심즈처럼 인물에 어울리는 짧은 의성어 목소리("아하~ 으흠~").

- 생성: ElevenLabs **eleven_v3 음성 모델**(로그인 브라우저 세션). 인물마다 기본 제공 목소리 하나를 고정하고 감정 태그 + 감탄사만 읽힘. 인물당 4개 × 7명 = 28개 → `raw/<id>-0N.mp3`. 배역·문구 [meta.json](meta.json).
  - 브람 Callum(허스키 중년) · 올라프 Adam(단호·굵음) · 토르빈 Brian(깊고 낮음) · 미라 Jessica(밝고 따뜻) · 네리 Laura(활발·엉뚱) · 오스윈 George(차분한 영국식 노신사) · 세라 Matilda(경쾌·똑 부러짐)
- 다듬기: STT(`scribe_v1`)로 단어 시각을 받아 소리 난 구간만 남기고 사이 쉼을 0.1초로 줄임, 최대 1.6초, 피크 -3dB, 끝 60ms 페이드 → `edited/<id>-0N.wav`(44.1kHz 16bit 모노). STT 결과로 실제 단어가 없는지 확인했고 오스윈 4번의 "yes"는 잘라 냄.
- 게임 적용: `godot/assets/audio/voice-<id>-0N.wav`, `selected.json` 에 `voice_<id>`(파일 4개 번갈아, -10dB).
  - `SoundBank.voice(profile, fallback)` — 인물 id(`character_id`/`id`)로 목소리를 내고, 없으면 fallback.
  - `guest_interactions.gd`: 대화 열기(`talk_open` 대신), 대답·마무리 대사가 뜰 때. 버튼 클릭음(`talk_next`)과 닫기 소리는 그대로.
  - `guest_arrival.gd`: 도착 카드에 첫인사가 뜰 때(카드 소리 `guest_card` 와 함께).
- 검증: `godot/tools/verify_guest_voices.gd` 18/18 → [verification.txt](verification.txt).
- 보고 페이지 [guest-voices.html](guest-voices.html) (`node build_page.mjs`, 틀 [../audio-review-kit](../audio-review-kit/README.md), 소리별 코멘트 칸). 아직 아무도 들어 보지 않았다.
- 실행판(2026-10-17 16:06): 이전 판을 `build/WitchsLodge-before-guest-voices.pck` 로 남기고 `build/WitchsLodge.pck` 재출력(같은 시점의 챕터 확장 E0~E3 작업 포함). `build/audio` 에 새 소리 39개와 `selected.json` 복사. 내보낸 pck 로 `verify_guest_voices` 18/18, `verify_new_sfx` 21/21, 챕터 검사 63/63(1회는 붉은 만찬 축복 1건이 시점에 따라 실패).
