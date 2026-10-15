# 마녀산장 — 카드 효과음 ElevenLabs 후보 v01

작성일: 2026-10-15. ElevenLabs 효과음 생성기(`eleven_text_to_sound_v2`), 프롬프트 영향도 30%, 길이 자동, 반복 꺼짐, 자동 개선 꺼짐. 생성 1회당 후보 4개.

- 카드 상황 11가지 × 4개 = **44개** (`raw/card-<상황>-el-0N.ogg`, Ogg Opus 48kHz).
- `play`·`draw` 8개는 비로그인 체험으로, 나머지 9개 상황 36개는 계정 로그인 후 생성했다(1,800 크레딧 사용, 결제 없음).
- 프롬프트: [prompts.md](prompts.md). 파일별 프롬프트·기록 ID·길이: [meta.json](meta.json).
- 시청 페이지 [card-sfx-elevenlabs.html](card-sfx-elevenlabs.html) — 손패 시험대에서 카드를 직접 만지며 비교. 다시 만들기: `node build_page.mjs`.
- 원본은 무음·꼬리 다듬기 전이다(오버·대상 2초, 소멸 5초 등). 고른 뒤 길이를 다듬고 Godot용(WAV 또는 OGG Vorbis)으로 변환한다. Godot 4는 Ogg Opus를 직접 읽지 못한다.
- `pack.json`, `pack-anon.json`은 브라우저에서 한 번에 옮기기 위한 묶음 파일이다.

## 임팩트 편집본 (2026-10-15)

- `edited/card-<상황>-el-0N.wav` — 48kHz 모노 16bit, 가장 큰 임팩트 하나만 남기고 자른 버전. Godot에 바로 쓸 수 있다.
- 규칙: [impact_edit.js](impact_edit.js) (1ms 엔벨로프, 15ms 대비 9dB 상승 = 임팩트, 60ms 안은 하나로 합침). 상황별 최대 길이: 오버 0.12 · 집기 0.18 · 들어옴 0.28 · 취소/불가 0.22 · 대상/정렬/뒤집기/창고 0.28~0.30 · 사용 0.40 · 소멸 0.55초.
- 결과: [edited/edit-report.json](edited/edit-report.json). 44개 모두 임팩트 1개, 평균 길이 1.73초 → 0.24초.
- 재실행: `node edit_server.mjs` 후 브라우저로 `http://localhost:5179/edit` 열기 → `node build_page.mjs`.

## 게임 적용 (2026-10-15)

사용자 선택 9종을 `godot/assets/audio/`와 `build/audio/`에 복사하고 `selected.json`에 등록했다. 마우스 오버·카드 소멸은 선택하지 않아 소리 없음.

| 이벤트 | 파일 | 음량 | 울리는 곳 |
| --- | --- | --- | --- |
| `card_draw` | card-draw-el-02.wav | -10dB | 새 카드가 출처에서 날아오기 시작 (`card_hand._start_reveal`) |
| `card_inspect` | card-inspect-el-04.wav | -11dB | 공개 위치에서 크게 펼쳐지는 순간 (`_reveal_arrived`) |
| `card_pickup` | card-pickup-el-03.wav | -12dB | 드래그 시작 (`begin_drag`) |
| `card_target` | card-target-el-04.wav | -12dB | 끄는 중 유효 대상에 처음 닿거나 다른 유효 대상으로 옮김 (`_update_drag`) |
| `card_play` | card-play-el-01.wav | -9dB | 사용 확정·양털 판매 (기존 호출 그대로, ElevenLabs MP3 3종 대체) |
| `card_cancel` | card-cancel-el-01.wav | -12dB | 손패 위에 놓기·우클릭·Esc (`_cancel_by_player`) |
| `card_deny` | card-deny-el-01.wav | -10dB | 놓았지만 사용 실패 (`_end_drag`) |
| `card_stash` | card-stash-el-01.wav | -11dB | 손패 → 창고 (`_send_to_storage`) |
| `card_shuffle` | card-shuffle-el-02.wav | -12dB | 창고 → 손패로 돌아와 손패가 다시 펼쳐짐 (`_sync`) |

- `card_` 이벤트는 낮 창고·판매 창이 게임을 멈춘 상태에서도 울린다(그 밖의 효과음은 기존대로 정지 중 무음).
- 검증: `godot/tools/verify_card_sfx.gd` 13항목 통과 → [game-verification.json](game-verification.json). 기존 `verify_audio_review.gd` 13항목 통과.
- 실행판: `build/WitchsLodge.pck` 재출력, 이전 판은 `build/WitchsLodge-before-card-sfx.pck`.
- 참고: 적용 당일 `verify_card_core.gd`가 일시 정지 상태로 진행되며 8항목 실패한 실행이 있었다(소리 적용 전 코드에서도 동일). 이후 재현되지 않았고, 검사를 보강해 3회 연속 52/52 통과 — [구현 기록 §4](../../docs/card-core-c0-implementation.md).

## 라이선스 주의 (2026-10-15 확인)

이 폴더의 효과음은 모두 ElevenLabs **Free 요금제**(play·draw 8개는 비로그인 체험)로 생성했다. ElevenLabs 이용약관 §1(c)(i)(2026-10-09 개정)에 따르면 무료 이용은 **비상업 목적만** 허용된다. 프로토타입·내부 테스트에는 쓸 수 있지만, 판매·수익화·외부 공개 출시 전에는 유료 플랜(Starter 이상)에서 같은 프롬프트로 다시 생성하거나 다른 음원으로 바꿔야 한다. 이전 `output/audio-elevenlabs-v01`(card-play·magic-bolt·gold-reward·dragon-arrival)도 같은 계정이면 동일하다.
