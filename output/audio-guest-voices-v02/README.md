# 마녀산장 — 종족 손님 목소리 v02

작성일: 2026-10-18. 요청: 새 종족 손님(드워프·요정·고블린·수인·오크 35명)에게 v01(인간 7명)처럼 짧은 의성어 목소리. 조사 근거 [../../docs/sound-gap-list-v01.md](../../docs/sound-gap-list-v01.md) §1.

- 생성: ElevenLabs **eleven_v3** 공식 API(사용자가 만든 API 키, `%USERPROFILE%\.elevenlabs\api_key` — 저장소 밖). 인물마다 기본 목소리 하나를 고정하고 종족 태그 + 인물 태그 + 감정 태그 + 감탄사만 읽힘. 인물당 4개 × 35명 = 140개 → `raw/<id>-0N.wav`(PCM 24kHz — 이 플랜은 44.1kHz PCM 불가). 배역·문구 [cast.json](cast.json), 스크립트 [gen_voices.mjs](gen_voices.mjs).
  - 기본 목소리가 21개뿐이라 몇 개는 둘이 같이 씀(예: Bella — 시그뉘·니벨·에쉬카). 종족 태그로 구분: 드워프 `gruff, stocky` · 요정 `tiny, airy, high-pitched` · 고블린 `quick, nasal, scratchy` · 오크 `deep, booming`, 수인은 인물별(늑대·곰·토끼·올빼미·오소리).
- 다듬기: **이번 키에 STT 권한이 없어** v01의 받아쓰기 대신 음량 구간(20ms RMS, 최대치 -35dB 초과)으로 소리 난 부분만 남김. 쉼 0.1초, 최대 1.6초, 피크 -3dB, 끝 60ms 페이드, 0.35초 미만은 뒤에 무음을 붙임 → `edited/<id>-0N.wav`(24kHz 16bit 모노). 실제 단어를 말했는지는 기계로 확인하지 못함(원본 길이는 모두 2.6초 이하).
- 게임 적용: `godot/assets/audio/voice-<id>-0N.wav` 140개, `selected.json`에 `voice_<id>` 35개(파일 4개 번갈아, -10dB). 코드 변경 없음 — `SoundBank.voice()`가 이미 인물 id로 찾는다.
- 검증: `godot/tools/verify_guest_voices.gd`를 42명 전원 목소리 확인으로 바꿈 → 54/54 [verification.txt](verification.txt).
- 보고 페이지 [race-voices.html](race-voices.html) (`node build_page.mjs`, 틀 [../audio-review-kit](../audio-review-kit/README.md), 소리별 코멘트 칸). 사용자 승인(2026-10-18): 140개 모두 그대로 적용.
- 실행판(2026-10-18 21:00): 루트 `WitchsLodge.exe` 재내보내기(첫 시도는 임시 파일 이름 바꾸기 실패 → 남은 `WitchsLodge.tmp` 지우고 재시도 성공). 내보낸 exe 안에서 목소리를 따로 재생해 보지는 않았다.
