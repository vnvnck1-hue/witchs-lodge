# 무료 상업용 영문 카드 폰트 리서치 v01

조사일: 2026-10-20. 목적: 카드 글자를 게임이 직접 그리게 바꾼 뒤([card-text-runtime.md](card-text-runtime.md)), 영문판 카드 제목·분류·본문·숫자에 쓸
**무료 + 상업 이용 가능** 영문 폰트를 고른다. 한글은 BM 을지로체 그대로 둔다.

시각 비교: [output/english-font-research-v01.html](../output/english-font-research-v01.html). 글자를 지운 실제 카드(채집가) 위에 7개 조합을 얹었고, 현재 한글판과 나란히 보여 준다.
Google Fonts를 불러오므로 인터넷이 필요하다.

## 결론

| 순위 | 제목 | 분류·본문 | 성격 |
|---|---|---|---|
| **추천 1** | **Fraunces Black** (SOFT 100, WONK 1, opsz 72) | **Alegreya** Bold / 분류는 **Alegreya SC** | 하스스톤 Belwe와 가장 닮은 무료 대안. 둥글고 굵어 을지로체·굵은 먹선 화풍과 무게가 맞는다 |
| 추천 2 | **Grenze** ExtraBold | Alegreya SemiBold | 중세 분위기가 가장 강하다. 폭이 좁아 긴 이름에 유리하다 |
| 대안 | Almendra Bold | Alegreya | 마녀·동화 캘리그래피 느낌. A안보다 가늘다 |
| 대안 | Texturina (한 가족) | Texturina | opsz 축으로 제목·본문을 한 폰트로 처리 |
| 대안 | Fraunces | Libre Franklin | 하스스톤의 Belwe + Franklin Gothic 구성. 가장 잘 읽히지만 중세 느낌은 약하다 |
| 메뉴·로고 | Cinzel Decorative | — | 대문자만 있어 카드 이름에는 딱딱하다. 분류 줄은 넘치기 쉽다 |
| 포인트 | Mystery Quest + Kurale | — | 장난스러운 마녀 동화풍. 사건·이벤트 카드 한정 |

**숫자(비용·공격·체력):** Fraunces Black. 키워드 강조는 Alegreya SC Black.
**로고·챕터 제목 후보:** Pirata One, Grenze Gotisch(B안 짝), Uncial Antiqua(요정·룬 포인트).
제외: MedievalSharp(흔하고 굵기 하나), Metamorphous(작은 크기에서 뭉개짐), IM Fell English(굵은 웨이트 없음), Henny Penny(과함).

권장 조합은 **A안 = Fraunces + Alegreya 가족**이다. 두 폰트 모두 굵기 축이 있는 가변 폰트라 파일 3개(Fraunces, Alegreya, Alegreya SC)로 제목·분류·본문·숫자·키워드를 모두 처리한다.

## 라이선스 확인

모든 후보는 Google Fonts 공식 저장소 <https://github.com/google/fonts> 의 `ofl/<폰트>/` 폴더에 있고, 각 `METADATA.pb` 의 `license: "OFL"` 을 직접 확인했다(2026-10-20).
예외: Luckiest Guy는 `apache/` 폴더(Apache 2.0)라 이번 표에서 뺐다.

| 폰트 | 디자이너 | 라이선스 | 굵기 |
|---|---|---|---|
| Fraunces | Undercase Type, Phaedra Charles, Flavia Zimbardi | OFL 1.1 | 가변 wght 100–900, SOFT, WONK, opsz |
| Alegreya / Alegreya SC | Juan Pablo del Peral, HT Fonts | OFL 1.1 | 가변 wght 400–900 / SC 400–900 |
| Grenze / Grenze Gotisch | Omnibus-Type | OFL 1.1 | 가변 wght |
| Almendra | Ana Sanfelippo | OFL 1.1 | 400, 700 |
| Texturina | Guillermo Torres, Omnibus-Type | OFL 1.1 | 가변 wght, opsz |
| Libre Franklin | Impallari Type | OFL 1.1 | 가변 wght |
| Cinzel / Cinzel Decorative | Natanael Gama | OFL 1.1 | 가변 / 400·700·900 |
| Mystery Quest | Sideshow | OFL 1.1 | 400 |
| Kurale | Eduardo Tunni | OFL 1.1 | 400 |
| Pirata One | Rodrigo Fuenzalida, Nicolas Massi | OFL 1.1 | 400 |
| Uncial Antiqua | Astigmatic | OFL 1.1 | 400 |

### SIL OFL 1.1로 게임에 넣을 때의 조건

- 상업 게임에 포함(번들)해 판매할 수 있다. 사용료·사전 허락이 필요 없다.
- **폰트 파일만 따로 판매하면 안 된다.**
- 폰트와 함께 저작권 표기와 OFL 전문을 배포해야 한다. 프로그램 안에 넣은 경우는 별도 파일이 아니어도 되지만,
  안전하게 크레딧 화면과 [credits.md](credits.md)에 폰트명·저작권자·라이선스를 적고 `OFL.txt` 를 함께 둔다.
- 폰트를 고쳐(글리프 추가·서브셋 등) 다시 배포하면 원래 이름(Reserved Font Name)을 쓸 수 없는 경우가 있다.
  Godot에 원본 TTF를 그대로 넣는 한 문제가 없다.

## Godot 적용 메모 (구현 전)

- 지금도 영문은 표시된다. BM 을지로체에 라틴 대·소문자·숫자 글리프가 들어 있음을 fontTools로 확인했다. 다만 한글 간판체의 라틴 글자라 판타지 카드 느낌은 약하다.
- 가변 폰트는 `FontVariation.variation_opentype` 로 축을 고정한다. 예: Fraunces `wght=900, SOFT=100, WONK=1, opsz=72`.
- 언어별로 제목·본문 폰트를 바꾸고, 한글이 섞일 때를 대비해 영문 폰트의 `fallbacks` 에 BM 을지로체를 둔다.
- 영문은 한글보다 획이 가늘어 같은 픽셀 높이에서 약해 보인다. 시안에서 본문은 Bold(700)가 한글판 무게에 가장 가까웠다. 실제 적용 때 `fit.json` 의 크기 맞춤을 영문 기준으로 다시 잰다.
- 받을 곳: `https://github.com/google/fonts/tree/main/ofl/fraunces`, `.../ofl/alegreya`, `.../ofl/alegreyasc` (각 폴더에 `OFL.txt` 포함). 아직 내려받지 않았다.

## 적용 결과 (2026-10-20)

사용자가 **A안**을 골라 게임에 적용했다. F8 로 카드 언어 한국어 ↔ English 전환, 카드 109장 영문 문구 `godot/assets/cards/catalog_en.json`.
이름표만 시안과 달리 작은 대문자 대신 Alegreya ExtraBold 를 쓴다(판이 좁아 Alegreya SC 는 너무 작아졌다). 구조·검증은 [card-text-runtime.md](card-text-runtime.md) 의 "카드 언어" 절.

참고: [SIL OFL FAQ](https://openfontlicense.org/ofl-faq/), [Belwe Roman(위키백과)](https://en.wikipedia.org/wiki/Belwe_Roman) — 하스스톤 카드 이름 폰트이며 디지털판(ITC·Elsner+Flake)은 상용이다.
