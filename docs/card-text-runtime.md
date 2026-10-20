# 카드 글자 런타임 렌더 (2026-10-20)

카드 PNG 에 그려져 있던 제목·분류·설명·종족 이름표를 모두 지우고, 게임이 카탈로그 문구를 **BM 을지로체**
실제 텍스트로 그린다(사용자 확정 2026-10-20: 확장성 — 번역·문구 수정·새 카드에 이미지 재생성이 필요 없게).

## 구조

| 역할 | 파일 |
| --- | --- |
| 글자 없는 카드 그림 | `godot/assets/cards/*.png`, `hand/`, `races/<race>/` (133장, 뒷면 제외) |
| 문구 | `godot/assets/cards/catalog.json` — `name`·`category`·`printed_rules` + 새 필드 `badge`(종족 이름표: 인간·가축·하수인) |
| 판 프로파일 | `godot/assets/cards/text_layout.json` — 카드별 제목판·설명판·이름표의 행마다 쓸 수 있는 가로 구간 |
| 글자 그리기 | [`scripts/ui/card_face.gd`](../godot/scripts/ui/card_face.gd) — 판 모양에 맞춰 줄 폭을 맞추고, 긴 제목은 2줄, 그래도 넘치면 축소 |
| 게임 연결 | [`scripts/ui/card_catalog.gd`](../godot/scripts/ui/card_catalog.gd) `_face()` — `texture()`·`race_texture()`·`variant_texture()` 가 글자를 구운 텍스처를 돌려준다 |
| 폰트 | `godot/assets/fonts/bm/BMEULJIROTTF.ttf` (배민 글꼴 패키지 11종을 같은 폴더에 둠) |

소비처(손패·제안·멀리건·상자·마법서 화면)는 바꾸지 않았다. `Catalog.texture()` 가 `AtlasTexture` 한 객체를 돌려주고,
SubViewport 에 CardFace 를 한 번 그린 뒤 그 객체의 `atlas` 를 구운 이미지로 바꾼다. 같은 그림·이름표는 한 번만 굽고 캐시한다.
헤드리스(검증 도구)에서는 렌더러가 없어 글자 없는 그림이 그대로 나온다.

종족별 계약 카드(`races/<race>/<job>.png`)의 이름표는 `races.gd` 의 종족 이름(드워프·고블린…)을 쓴다.

## 글자 크기

1024×1536 기준 제목 136px·분류 50px·설명 69px·이름표 55px — 나무꾼 원본의 글자 픽셀 높이에 맞춘 값(제목 123px, 설명 64px).
카드마다 판 모양이 달라 긴 제목은 2줄로 나누거나 줄인다. 전체 131장 가운데 기준의 90% 아래로 줄어든 것은
제목 50장·설명 20장·이름표 1장이며 가장 많이 줄어든 제목은 늑대 송곳니 목걸이(83px)·찌그러진 냄비 투구(87px)다.
카드별 실제 수치는 `output/card-text-strip-v01/faces/fit.json`, 원본과의 줄 높이 비교는 `text-size-compare.json`.

## 새 카드를 만들 때

- 원화는 **글자 없이** 생성한다(제목판·설명판은 비워 둔다). 기존 포맷으로 받은 카드는 [`tools/card_text_strip/`](../tools/card_text_strip/README.md) 로 지운다.
- 카탈로그에 `name`·`category`·`printed_rules`(2줄 권장, 최대 4줄)과 종족 이름표가 있으면 `badge` 를 넣는다.
- `python tools/card_text_strip/measure_plates.py` 로 판 프로파일을 다시 잰다(프로파일이 없는 카드는 나무꾼 기본 판을 쓴다).

## 검증·캡처

```text
.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_card_face.gd           # 폰트·그림·문구 축소율·캐시 (689 항목)
.tools/Godot-4.7.2.exe --path godot --script res://tools/capture_card_face.gd -- --out=../output/card-text-strip-v01/faces   # 131장 렌더(창 필요)
python tools/build_card_gallery.py --faces output/card-text-strip-v01/faces --before output/card-text-strip-v01/before    # 도감 HTML(원본 토글)
```

실제 렌더는 폰트 외형·배치를 화면으로만 판단할 수 있어 창을 띄운다(끝나면 자동 종료).
전환 전 원본 PNG 는 `output/card-text-strip-v01/before/` 에 보존했다.

## 카드 언어 — F8 한국어 ↔ English (2026-10-20)

사용자 요청으로 [영문 폰트 리서치](english-font-research-v01.md)의 **A안**을 적용하고, F8 로 언제든 카드 언어를 바꾸게 했다.

| 칸 | 한국어 | English |
| --- | --- | --- |
| 제목 | BM 을지로체 136px | **Fraunces** Black (wght 900·SOFT 100·WONK 1·opsz 72) 128px |
| 분류 | 〃 50px | **Alegreya SC** Bold 46px (제목을 줄여도 75% 아래로는 줄이지 않음) |
| 설명 | 〃 69px | **Alegreya** Bold (wght 700) 66px |
| 종족 이름표 | 〃 55px | Alegreya ExtraBold (wght 800) 52px — 작은 대문자는 판에 비해 넓어 일반 글자 |

- 영문 문구: `godot/assets/cards/catalog_en.json` — 카드 id 별 `name`·`category`·`printed_rules`, 이름표 번역 `badges`(인간 → Human 등).
  없는 칸은 한글로 두고, 영문 폰트의 fallback 인 을지로체로 그린다. 새 카드를 추가하면 여기에도 영문을 넣는다(검증이 한글이 남은 카드를 FAIL 로 잡는다).
- 폰트: `godot/assets/fonts/en/` — `Fraunces-VF.ttf`·`Alegreya-VF.ttf`·`AlegreyaSC-Bold.ttf` + 각 `OFL-*.txt` (google/fonts 저장소 원본 그대로, SIL OFL 1.1).
- 전환: [`scripts/ui/card_language.gd`](../godot/scripts/ui/card_language.gd) 를 게임(`main.gd`)·타이틀(`title_screen.gd`)에 붙였다. 일시 정지·메뉴 중에도 동작하고
  `Catalog.rebake_faces()` 가 이미 구운 앞면을 같은 텍스처 객체에 8장씩 다시 굽는다(손패·제안 화면이 그 자리에서 바뀐다).
  값은 `user://settings.cfg` `[cards] lang`, 이번 실행만은 `-- --card-lang=en`. HUD·메뉴·툴팁·대사도 함께 바뀐다 — [english-ui-runtime.md](english-ui-runtime.md).
- 영문은 문장이 길어 한 줄 제목만 들어간다(2줄로 나누면 분류 줄과 함께 판 높이를 넘는다). 긴 이름은 기준의 45% 까지 줄인다(가장 작은 것: Sleeping Thorn Seed·Heart of the Old Tree 49%).
- 검증: `verify_card_face.gd` 에 영문 항목 추가(1056 항목) — 폰트·축·fallback, 카드 전체 영문 완비, 칸에 들어감, 종족 이름표, F8 전환·저장·복귀.
  렌더: `capture_card_face.gd -- --card-lang=en --out=../output/card-text-en-v01/faces`, 실제 게임 F8 전환 캡처 `capture_card_text_ingame.gd`(`screenshots/card-face/ingame_en.png`) —
  폰트 외형과 게임 안 다시 굽기는 헤드리스로 볼 수 없어 창을 띄웠다.

## 라이선스 메모

배민 글꼴은 공식 이용 약관(무료·상업 사용 가능, 글꼴 자체 판매 금지)을 출시 전에 다시 확인하고 크레딧에 표기한다.
영문 폰트(Fraunces·Alegreya·Alegreya SC)는 SIL OFL 1.1 — 게임에 포함해 판매 가능, 폰트만 따로 판매 금지, 저작권 표기와 라이선스 전문 동봉([크레딧](credits.md)).
