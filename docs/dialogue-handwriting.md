# 대사 필기 연출 — 종이에 펜으로 적듯 (v01, 2026-10-22)

손님 대사(중앙 대화창·도착 소개)가 한 글자씩 **펜으로 적히듯** 나타나고, 적는 동안 **펜촉이 종이를 긁는 소리**가 난다.

## 화면

- 대사 줄마다 셰이더 [handwriting_reveal.gdshader](../godot/shaders/handwriting_reveal.gdshader)가 펜 끝(`reveal_x`)보다 왼쪽만 보여 준다.
  경계는 위가 조금 먼저 적히는 비스듬한 선(`slant`)에 번짐(`soft`)이 있어 획을 긋는 느낌이 난다.
- 막 적힌 자리(약 48px)는 **젖은 잉크**(금빛 `wet_color`)로 빛나다 원래 글자색으로 마른다. 줄을 다 쓰면 0.6초에 걸쳐 마른다.
- 리듬은 [handwriting.gd](../godot/scripts/ui/handwriting.gd)가 미리 짠다. 한글 한 음절 약 0.05초(±22%), 영문·숫자 0.032초,
  띄어쓰기에서 펜을 들고(0.07초, 소리 없음), `, . ! ? …` 뒤 0.2초 숨, 다음 줄로 옮길 때 0.24초. 같은 문장은 늘 같은 리듬(문장 해시 시드).
  예: 29자 두 줄 대사 ≈ 2.1초.
- 시작 시각: 대화창은 패널·이름이 자리 잡은 뒤 0.94초, 도착 소개 0.32초, 같은 인물의 다음 대사는 0.12초 뒤.

## 조작

- 적는 중에 **다음 버튼·Enter·Space**(대화창) 또는 **패널 클릭**(도착 소개)을 누르면 남은 글을 한 번에 마저 적는다. 한 번 더 눌러야 넘어간다.
- 도착 소개는 다 적은 뒤 최소 1.6초 읽을 틈을 두고 산장으로 날아간다.

## 소리

- 이벤트 `quill_scratch`([selected.json](../godot/assets/audio/selected.json), -17dB, Sfx 버스 → 효과음 음량 설정을 따름).
- 반복음을 깔고 **획 압력**(획 가운데에서 가장 세고 글자 사이에서 살짝 끊김, 공백·쉼에서는 0)을 빠르게 따라 크기를 올리고 내린다(오름 22/초, 내림 12/초). 줄마다 재생 위치·높이(0.94~1.08)를 무작위로.
- 지금 파일 `sfx-quill_scratch.wav`는 **자체 합성**(외부 녹음 없음, 라이선스 문제 없음): 대역 통과 잡음(3.3kHz 긁힘 + 7.2kHz 종이 결) + 2~6ms 섬유 결 진폭 + 초당 약 30번 펜촉 걸림. 2.4초, 이음매 겹침.
  다시 만들기: `.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/gen_quill_scratch.gd`
- **실녹음으로 바꾸기**: 아래 후보를 받아 1~3초의 고른 긁힘 구간을 잘라 `godot/assets/audio/`에 두고 `selected.json`의 `quill_scratch.files`만 바꾸면 된다(코드 수정 없음). CC0 가 아니면 [credits.md](credits.md)에 표기를 추가한다.

## 무료 라이선스 효과음 조사 (2026-10-22)

| 후보 | 라이선스 | 표기 | 메모 |
| --- | --- | --- | --- |
| [Quill pen writing on hard paper various speed — marcoman89 (Freesound #194905)](https://freesound.org/people/marcoman89/sounds/194905/) | **CC0** | 불필요 | **1순위.** 실제 깃펜·딱딱한 종이 녹음, WAV 48kHz/16bit, 1분 38초(느리게→빠르게). 고른 구간을 잘라 쓰기 좋다 |
| [Quill and Parchment — Nickh69 (Freesound #507864)](https://freesound.org/people/Nickh69/sounds/507864/) | CC0(검색 필터 기준) | 불필요 | 양피지 위 깃펜, 약 28초. 받기 전 페이지 라이선스 재확인 |
| [Ink Quill Writing on Parchment ASMR — brktkrgll (Freesound #856167)](https://freesound.org/people/brktkrgll/sounds/856167/) | CC0 | 불필요 | 6초 MP3. 작성자가 **ElevenLabs로 생성**했다고 밝힘(실녹음 아님) |
| [Pencil Sounds — AntumDeluge (OpenGameArt)](https://opengameart.org/node/132692) | CC0 | 불필요 | 연필 쓰기·지우기 2개(FLAC/OGG). 깃펜보다 사각거림이 가볍다 |
| [Sonniss GDC Game Audio Bundle](https://gamefromscratch.com/sonniss-27-5gb-sound-effect-giveaway-at-gdc-2024/) | 로열티 프리 | 불필요 | 수 GB 묶음, 상업 이용·무제한 프로젝트. 2024판부터 AI 학습 금지 조항. 필기음 포함 여부는 받아서 확인해야 함 |
| [Mixkit — Write 효과음](https://mixkit.co/free-sound-effects/write/) | Mixkit License | 불필요(약관 확인) | "Writing with a pen on paper" 등 1~2초 13개. 효과음 단독 재배포 금지 등 자체 약관 |
| [Floraphonic Pencil Write and Draw Foley](https://floraphonic.itch.io/pencil-write-and-draw-foley) | 상업 이용 가능(유료 약 $5) | 선택 | WAV 35개. 무료는 아님 |
| ElevenLabs 효과음 생성 | 유료(Starter 이상) 상업 이용 가능 | 무료 플랜은 표기 필요 | 프로젝트가 이미 Starter로 효과음을 만들어 왔다([output/audio-game-sfx-v01](../output/audio-game-sfx-v01/README.md)). 크레딧 사용 |

Freesound 파일은 로그인해야 받을 수 있다. 받기·교체는 사용자 확인 뒤 진행한다.

## 검증

- 헤드리스 [verify_dialogue_handwriting.gd](../godot/tools/verify_dialogue_handwriting.gd) 30/30 — 리듬(공백 펜 들기·쉼표 숨·줄 이동), 펜 끝 전진·완성·마름, 대화창 줄 셰이더, 마저 적기, 소리 압력 추종·정지, 다음 대사 새로 적기.
- [verify_guest_events.gd](../godot/tools/verify_guest_events.gd)에 "적는 중 다음 = 마저 적기" 확인을 넣고 이후 진행은 실제처럼 Space로 마저 적고 넘어가게 맞췄다.
- 실제 렌더 캡처 [capture_dialogue_handwriting.gd](../godot/tools/capture_dialogue_handwriting.gd) → `godot/screenshots/dialogue-handwriting/` — 이유: 셰이더 컴파일과 젖은 잉크 색·경계 번짐은 헤드리스 더미 렌더러로 볼 수 없다.
