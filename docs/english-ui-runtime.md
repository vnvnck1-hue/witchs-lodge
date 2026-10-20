# 게임 전체 영문판 — F8 한국어 ↔ English (2026-10-20)

사용자 요청("인게임에 모든 폰트가 영어로 되도록 나머지 부분도"). 카드 앞면만 바뀌던 F8([card-text-runtime.md](card-text-runtime.md) "카드 언어")이
이제 **HUD·메뉴·툴팁·대사·알림·3D 글자·HUD 이미지에 박힌 글자까지** 같은 언어와 글꼴로 바꾼다.

## 구조

| 부분 | 파일 | 하는 일 |
|---|---|---|
| 언어 전환 | `scripts/ui/game_language.gd` | `apply("en")`: 번역 사전을 TranslationServer 에 붙이고 locale `en`, UI 글꼴·엔진 대체 글꼴(`ThemeDB.fallback_font`)·엔진 기본 테마 글꼴을 Alegreya 로. `apply("ko")`: 사전을 떼고(대체 locale 이 en 이라 붙여 두면 한국어에서도 옮겨짐) 원래 글꼴로. `release()`: 장면을 떠날 때 엔진 전역에서 번역기·글꼴을 뗀다 — 영어 상태로 종료하면 엔진 정리 중 해제된 스크립트 객체를 건드려 종료 순간 튕겼다 |
| F8 | `scripts/ui/card_language.gd` | `_ready` 에서 저장된 언어로 `GameLanguage.apply`, `_exit_tree` 에서 `release`, F8 마다 카드 + 게임 전체 전환. 값은 그대로 `user://settings.cfg` `[cards] lang` |
| 번역기 | `scripts/ui/i18n_translation.gd` | 원문 한국어를 키로 쓰는 사전 `assets/i18n/en.json` 을 읽는 Translation. ① 통째 ② `"  ·  "` `" · "` `" — "` `"  "` 로 이은 문장은 조각마다(모든 조각이 옮겨질 때) ③ 서식 원문(`"%d골드"`) 정규식 맞춤 → 값만 옮김 ④ 앞뒤 공백·여러 줄·괄호로 감싼 문장 ⑤ 남은 한글은 낱말·구절 치환. 사전을 읽을 때 앞뒤 구분자를 뗀 조각(`" · 추적"` → `"추적"`)과 여러 줄 문장의 각 줄도 항목으로 더한다. 결과 캐시 |
| UI 글꼴 | `scripts/ui/moon/moon_skin.gd` `font()` | 돌려주는 FontVariation 은 그대로, 안쪽 `base_font` 만 맑은 고딕(→Noto Sans KR) ↔ Alegreya(wght 500/700, 한글 폴백)로 바뀌어 이미 붙인 override 도 그 자리에서 바뀐다 |
| 직접 그리는 글자 | `hud.gd`·`party_frame.gd`·`card_hand.gd` | `draw_string` 은 auto translate 를 거치지 않아 `tr()` 로 감쌌다 |
| HUD 이미지 글자 | `scripts/ui/moon/moon_text_cover.gd`, `tools/build_ui_notext.gd` | player_status(마녀·산장)·objective(오늘의 할 일)·storage(창고)·lodge_button(산장 관리)은 글자가 그림에 박혀 있다. 글자 영역을 가로 보간으로 지운 사본(`assets/ui/moon_runes/notext/`)에서 그 영역만 잘라 덮고 영문 Label 을 올린다. 한국어일 때는 숨는다 |

게임 코드는 지금처럼 한국어 문자열을 넣으면 된다. Label·Button·RichTextLabel·Label3D·툴팁은 그릴 때 번역되고, 로직이 비교하는 값(`text`)은 바뀌지 않는다.

## 번역 사전 만들기·고치기 (프로젝트 루트)

```text
node tools/i18n/extract.mjs        # 스크립트·씬의 한글 문자열 리터럴 + 카드 카탈로그 → tools/i18n/strings.json, missing.json
node tools/i18n/seed_catalog.mjs   # catalog.json ↔ catalog_en.json 용어(카드 이름·분류·이름표) → catalog_seed.json
node tools/i18n/merge.mjs          # out/*.json + catalog_seed + overrides.json → godot/assets/i18n/en.json, 서식 자리표시자 검사
```

- `tools/i18n/out/00~08.json`: 처음 번역(문자열 2,546개, 덩어리 9개). 손으로 고친 값은 **`tools/i18n/overrides.json`** 에 넣는다(가장 우선).
- 새 한글 문구를 코드에 넣으면 `extract` → `missing.json` 에 뜬다. 영문을 `overrides.json` 에 더하고 `merge` 를 다시 돌린다.
- 손님 이름 영문은 `guest_profiles.gd` 의 `id` 를 대문자로 시작한 것(oswin → Oswin). merge 가 번역마다 달랐던 표기(Parg → Fargh 등)를 맞춘다.
- 서식 원문과 영문의 `%d %s %.1f` 종류·순서가 다르면 merge 가 실패로 알린다(인자가 순서대로 들어가므로 영문 어순도 그 순서에 맞춘다).
- 이름 + 조사를 이어 붙이는 코드는 서식 원문으로 바꾸거나 `overrides.json` 에 `"%s와 대화": "Chat with %s"` 처럼 서식 항목을 둔다.

## 검증

- 헤드리스 `tools/verify_i18n.gd`(24 항목): 사전 로드·값에 한글 없음, **scripts 의 한글 문자열 리터럴 2,618개가 모두 사전에 있음**(새 문구를 넣으면 여기서 FAIL),
  서식 문장 472개에 예시 값을 넣어 번역(한글·값 누락 없음), UI·엔진 글꼴 Alegreya + 한글 폴백, 타이틀·게임 화면에서 F8 과 같은 경로로 바꾼 뒤
  보이는 모든 글자에 한글 없음·**영문 글꼴 사용**(글꼴 체인을 실제 파일까지 따라가 `fonts/en/` 인지 확인), HUD 글자 덮개 4곳,
  8배속 8000 물리 프레임 플레이 중 뜬 글자, 한국어 복귀(원문·글꼴·덮개 숨김).
- 헤드리스 `tools/verify_i18n_screens.gd`(62 항목): 타이틀(설정·마녀 선택) → 새 이야기(프롤로그 자막 전 장·1일차 새벽·시작 손패·튜토리얼) →
  일시 정지·탐험 지도·산장 관리 탭 4개·창고·새벽 보상·장날·시작 손패·마법서·제단·보물상자·참고 카드·가운데 배너·게임 오버·챕터 완료를 차례로 열고,
  단계마다 **숨은 노드까지** 모든 글자(Label·Button·RichTextLabel·LineEdit·Label3D·툴팁)의 한글과 보이는 글자의 글꼴을 검사.
  카드 툴팁은 카탈로그 전 카드, 손님은 42명 전원의 소개·대화(선택지까지 넘김), 코드가 조각을 이어 붙여 만드는 문장 24가지(`+` 연결 68곳의 대표 모양)도 번역.
- Label3D 는 엔진 auto translate 로 옮겨짐을 확인(글자 폭이 언어 전환 즉시 바뀜).
- 렌더 캡처 `tools/capture_i18n.gd` → `godot/screenshots/i18n/`(title_en·game_en·dialogue_en·pause_en·game_en_later) — 글꼴 외형·HUD 이미지 덮개·글자 넘침은 헤드리스 더미 렌더러로 볼 수 없어 창을 띄웠다.
- 기존 `verify_card_face.gd` 1056/1056 그대로.

## 남은 것

- 번역은 자동 번역 후 서식·이름 일관성만 기계 검사했다. 문체·용어(예: 종족 고유명, 대사 말투)는 사람이 한 번 읽어 `overrides.json` 으로 다듬는다.
- 서식이 아닌 문자열을 코드에서 이어 붙여 만드는 새 문구는 낱말 치환으로 떨어져 어색할 수 있다. 검증이 한글을 잡으면 서식 항목을 더한다.
- 다른 세션이 한글 문구를 계속 추가한다(작업 중에도 에린 대화 52개·카드 질감 5개가 늘었다). 게임을 고친 뒤 `verify_i18n.gd` 의 리터럴 검사가 FAIL 이면 extract → overrides → merge.
- 영문 Alegreya 는 같은 크기에서 한글보다 가늘고 작아 보인다. 작은 글자(11~12px) 가독성은 실제 플레이에서 확인 후 크기 조정 후보.
- 글꼴·라이선스: Alegreya 는 카드에 이미 넣은 `assets/fonts/en/Alegreya-VF.ttf`(SIL OFL 1.1) 그대로 — 새 파일 없음.
