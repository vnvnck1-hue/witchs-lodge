# 마녀산장 — 누락 효과음 v01

작성일: 2026-10-17. ElevenLabs(로그인된 브라우저 세션, `eleven_text_to_sound_v2`, MP3 44.1kHz 128kbps)로 생성.

- 조사: `selected.json` 의 101개 이벤트는 모두 코드에서 쓰이고 있었다. 대신 게임 동작 중 소리가 없거나 다른 소리를 빌려 쓰던 12곳을 찾았다.
- 생성: 소리마다 1개씩, 길이 0.5~2초, 프롬프트 영향도 45~50%. 프롬프트·위치·음량은 [prompts.json](prompts.json).
- 게임 적용: `godot/assets/audio/sfx-<key>-el-01.mp3` 12개, `selected.json` 에 등록. 다듬기 없이 원본 그대로, 파일 피크를 재서 게임 피크 약 -13dB(기존 효과음 수준)로 음량을 맞춤. `thorn_hit` 는 파일 피크 -28dB 라 0dB 로도 작음 → 다시 만들기 권장.
- 코드: `SoundBank.play_or(event, fallback)` / `Sfx.play_or` — 새 소리가 선택에 없으면 예전 소리로 대신. 가시 방책(`thorn_seed.gd`)에 심기·공격·봉헌·피격·소멸, 상자·유물·마법서, 야생동물 도망·쓰러짐, 화살 명중, 생고기 먹기 연결.
- 검증: `godot/tools/verify_new_sfx.gd` 19/19 → [verification.txt](verification.txt).
- 보고 페이지 [missing-sfx.html](missing-sfx.html) (`node build_page.mjs`, 틀은 `../audio-game-sfx-v01/page.template.html`). 아직 아무도 들어 보지 않았다.
- 실행판 `build/` 는 아직 갱신하지 않았다(새 코드는 pck 재출력, 새 파일은 `build/audio` 복사가 필요).

## 사용자 검토 반영 (2026-10-17)

- 그대로 유지 10개.
- 토끼·사슴 쓰러짐(`animal_hurt`): 고른 대로 이전 양 소리 `sfx-sheep_hurt.wav`(-9dB)로 되돌림. 새 파일 `sfx-animal-hurt-el-01.mp3` 는 남겨 두었지만 쓰지 않는다.
- 생고기 먹기(`eat_meat`) 다시 만들기: 프롬프트 2종 × 2 = 후보 4개 → `raw-redo/eat_meat-0N.mp3`, 기록 [redo.json](redo.json). 타격 수가 가장 적은 후보 4를 `godot/assets/audio/sfx-eat-meat-el-02.mp3`(-13dB)로 적용. 듣고 고른 것이 아니다.
- `verify_new_sfx.gd` 에 위 두 선택을 확인하는 항목을 더해 21/21.
- 생고기 먹기 3차(2026-10-17): 2차가 "바삭하거나 사과 먹는 것 같다"는 의견 → 고기를 이로 뜯고 씹는 소리, 바삭함 없음으로 프롬프트 2종 × 2 = `raw-redo/eat_meat-05~08.mp3`. 고음 비율(bright)이 가장 낮은 `eat_meat-06` 을 `sfx-eat-meat-el-03.mp3`(-13dB)로 적용. 듣고 고른 것이 아니다. 검증 21/21.
- 실행판 반영(2026-10-17 16:06): `build/WitchsLodge.pck` 재출력·`build/audio` 갱신 — 자세한 내용은 [../audio-guest-voices-v01/README.md](../audio-guest-voices-v01/README.md).
