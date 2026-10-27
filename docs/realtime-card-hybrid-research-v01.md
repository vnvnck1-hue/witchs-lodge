# 실시간 전투 × 카드 — 유사 게임 리서치 (v01)

작성 2026-10-26 · 상태: **리서치 문서(결정 아님)** · Claude · 기준 기획: [코어 방향 §0·§7](core-direction-kingdom-sts-v01.md), [용병 키트 v04](mercenary-unique-kit-v04.md), [하루 구조 재편 §7.0](day-turn-structure-v01.md) · 이전 조사: [유사 코어 게임 리서치(10-20)](similar-games-research.md)

사용자 문제의식(2026-10-26): **실시간 전투와 카드게임을 섞으려는 게 조금 버겁다. 비슷한 게임에서 힌트를 얻고 싶다.**

조사 범위: 웹 검색(상점 설명·리뷰·위키·보도). 직접 플레이 검증은 아니다. 각 항목 끝에 **[검색 확인]**(이번에 출처로 확인)과 **[일반 지식]**(널리 알려진 내용, 이번에 따로 확인하지 않음)을 표시했다.

---

## 0. 한 장 요약

**지금 기획의 밤은 한 화면에 주의를 끄는 층이 다섯 개다.**

1. 용병 최대 5명의 오토배틀(위치·체력)
2. 용병마다 차오르는 **기세** → 자동 스킬
3. **마력**(3 · 초당 0.5 · 최대 10)과 손패 5장
4. 전투 중 **용병이 만들어 손패에 넣는 카드**(언제 생길지 모름)
5. 카드의 **대상 지정**(시야 안 지점 / 특정 용병 / 적)

여기에 인물마다 패시브·스킬·카드 1~2장, 종족 시너지까지 얹힌다.

조사해 보니 **실시간과 카드를 섞어 성공한 게임은 거의 모두 이 다섯 층 중 두세 개를 일부러 빼거나 멈춰 세운다.** 빼는 방법은 크게 여섯 갈래다(§2). 마녀산장에 가장 잘 맞는 힌트는:

| 순위 | 힌트 | 출처 게임 | 무엇이 가벼워지나 |
| --- | --- | --- | --- |
| 1 | **게이지가 차면 시간이 멈추고 카드를 고르는 "박자형 밤"** | 록맨 에그제(커스텀 게이지), Lost in Random | 층 3·4·5를 실시간에서 꺼냄. 오토배틀은 그대로 실시간 |
| 2 | **카드 = 소수의 고정 버튼(쿨다운)**, 손패·드로우를 없앰 | 킹덤 러시, Majesty, Hero's Hour, Book of Demons | 층 3·4가 사라짐. 덱빌딩 대신 "용병 구성 = 버튼 구성" |
| 3 | **전투 중 입력을 아예 없애고 판단을 저녁 정비로** | TFT, The Bazaar, Despot's Game | 층 3·4·5 전부. 대신 "구경만 한다"는 비판 위험 |
| 4 | **실시간을 버리고 "카운터 턴제"로** | Wildfrost, Into the Breach | 전부 턴으로. 오토배틀 감성은 카운터로 흉내 |

**추천: 1번을 먼저 시험한다.** 지금 결정(오토배틀 · 용병이 카드를 만든다 · 시작 손패 5장 · 마력)을 거의 그대로 살리면서, 버거움의 원인인 "보면서 동시에 고르기"만 떼어 낸다. 근거와 구체안은 §4.

---

## 1. 왜 버거운가 — 장르 지도에서 우리 위치

실시간 × 카드 게임을 **"전투 중 플레이어가 무엇을 하는가"**와 **"전장에서 스스로 움직이는 것이 얼마나 많은가"** 두 축으로 놓으면:

| | 전장의 자율 유닛 적음(내가 낸 것만 움직임) | 전장의 자율 유닛 많음(자기 판단으로 싸움) |
| --- | --- | --- |
| **전투 중 입력 많음(손패·드로우·자원)** | 클래시 로얄, Ratropolis, Overdungeon, Cards and Towers, 워크래프트 럼블 | **← 마녀산장 v04가 여기** (선례 드묾) |
| **전투 중 입력 적음(버튼 몇 개)** | 킹덤 러시(타워 + 주문 2개) | Majesty, Hero's Hour, 명일방주(스킬 수동 발동) |
| **전투 중 입력 없음** | — | TFT, HS 전장, The Bazaar, Despot's Game, Backpack Battles, Mechabellum |

우리가 있는 칸(**자율 유닛 많음 + 손패 입력 많음**)은 선례가 가장 적은 칸이다. 클래시 로얄 계열은 "내가 낸 카드만 전장에 있으니" 손패와 전장이 같은 대상을 본다. 오토배틀러 계열은 전장을 보는 동안 손이 비어 있다. 우리는 둘 다 요구한다 — 이게 버거움의 구조적 원인이다.

이전 리서치의 교훈도 같은 방향이다: **Griftlands — 카드 시스템을 두 개 이상 겹치면 학습 부담이 급격히 커진다**([유사 코어 리서치 §5](similar-games-research.md)). 지금은 "오토배틀 시스템"과 "카드 시스템"이 겹쳐 있다.

---

## 2. 해법 갈래 여섯 — 게임별 정리

### 갈래 A. 시간을 멈추고 카드를 고르는 "박자형"

**록맨 에그제(Mega Man Battle Network) 시리즈** — 캡콤, 2001~
- 전투는 실시간 액션. **커스텀 게이지가 약 8~10초에 걸쳐 차면** 버튼으로 전투를 멈추고 칩(카드) 선택 화면을 연다. 이 한 번이 "한 턴". 쓰지 않은 칩은 버려진다. 고르지 않고 넘기면(ADD) 다음 선택 폭이 넓어진다. 한 번에 고를 수 있는 칩은 같은 이름이나 같은 코드끼리로 제한.
- **배울 점:** 실시간의 박진감은 유지하면서 "고르기"는 멈춘 시간에 몰아서 한다. 고르는 순간과 쓰는 순간이 분리된다. 게이지 주기 자체가 드로우 리듬이다.
- [StrategyWiki](https://strategywiki.org/wiki/Mega_Man_Battle_Network/NetBattles) · [Giant Bomb](https://www.giantbomb.com/games/3030-8238/) · [Custom Gauge 위키](https://megaman.fandom.com/wiki/Custom_Gauge) **[검색 확인]**

**Lost in Random** — Zoink / EA, 2021
- 실시간 3인칭 전투. 적의 수정을 모으면 게이지가 차서 카드를 1장씩 뽑는다(최대 5장). **주사위를 굴리면 시간이 멈추고**, 나온 눈만큼 포인트로 카드를 낸다. 공격하거나 함정을 터뜨리면 시간이 다시 흐른다.
- 평: 신선하다는 호평, 그러나 **주사위가 낮게 나오면 쓸 게 없다**, 전투가 길게 늘어진다는 지적.
- **배울 점:** "모으는 시간(실시간)"과 "쓰는 시간(정지)"을 명확히 나눈다. 단, 정지 시점의 자원이 운에 좌우되면 불만이 된다 → 마력은 확정적으로 두는 게 낫다.
- [Kotaku](https://kotaku.com/lost-in-random-the-kotaku-review-1847734306) · [Gaming Trend](https://gamingtrend.com/reviews/lost-in-random-review-random-rules/) · [Gfinity 카드 사용법](https://www.Gfinityesports.Com/lost-in-random/how-to-use-cards/) **[검색 확인]**

**FF7 리메이크 ATB / 왕국의 마음 체인 오브 메모리즈 / Lost Kingdoms** **[일반 지식]**
- FF7R: ATB 게이지가 차면 명령 메뉴를 열 수 있고, 메뉴를 여는 동안 시간이 거의 멈춘다. 체인 오브 메모리즈·Lost Kingdoms(프롬 소프트웨어, 2002): 실시간 액션 중 카드 덱을 돌려 공격·소환. 둘 다 "카드 조작 난이도가 높다"는 평이 따라다닌 계열이다.

**Ratropolis** — Cassel Games(서울), 2019
- 실시간 덱빌딩 디펜스. 시간은 늘 흐르지만 **카드 구매 화면을 보는 동안에는 습격이 멈춘다.** 일시정지는 있으나 "멈춘 채 명령 내리기(액티브 퍼즈)"가 없다는 요청, 학습 곡선이 가파르고 UI·조작이 불편하다는 사용자 평, 무작위성이 크다는 불만.
- **배울 점:** 한국에서 이미 검증된 실시간 덱빌딩이지만 "실시간 + 손패"의 조작 부담은 여기서도 반복된 불만이다.
- [Game Informer](https://gameinformer.com/review/ratropolis/ratropolis-review-real-time-rategy) · [Gideon's Gaming](https://gideonsgaming.com/ratropolis-review-inspired-rodent-like-slays/) · [Steam 토론(액티브 퍼즈)](https://steamcommunity.com/app/1108370/discussions/0/2995422276367169779) · [Vaporlens 요약](https://vaporlens.app/app/1108370/ratropolis) **[검색 확인]**

**Void Salvage** — 2026-08 (상점 표기)
- "능동형 오토배틀러 + 전술적 일시정지(Real-Time with Pause)"를 내건 신작. 카드 게임인지는 분명하지 않다.
- [Steam](https://store.steampowered.com/app/4377950/Void_Salvage/) **[검색 확인 — 상세 미확인]**

> 우리에게 이미 있는 것: [손패 고민 시간](hand-focus-time.md) — 손패에 마우스를 올리면 1초에 걸쳐 세상이 멈춘다(기본 `freeze`). 즉 **조작 속도(APM) 부담은 이미 상당히 줄어 있다.** 남은 부담은 "언제 손패를 봐야 하는지 계속 신경 써야 하는 것", 즉 **주의 분산**이다. 갈래 A의 핵심은 멈추는 기능이 아니라 **멈추는 순간을 게임이 정해 준다**는 것이다.

### 갈래 B. 카드 대신 소수의 고정 버튼(쿨다운·마나)

**킹덤 러시 시리즈** — Ironhide, 2011~
- 타워는 자동으로 싸우고, 플레이어는 **영웅 1명 + 주문 2개**(지원군 10~15초, 불비 60~80초 쿨다운)를 직접 쓴다. 웨이브를 일찍 부르면 돈과 쿨다운 단축 보상. 불비를 언제 아끼느냐가 실제 판단이 된다.
- **배울 점:** 자율 유닛이 많은 전장에서 플레이어 버튼은 **2~3개면 충분히 바쁘다.** 무작위 손패 없이도 "언제 쓰나"의 판단이 생긴다.
- [Kingdom Rush 주문 위키](https://wikily.gg/kingdom-rush-6-genesis/spells) · [Call Reinforcements](https://wikily.gg/kingdom-rush/spells/call-reinforcements) **[검색 확인]**

**Majesty: The Fantasy Kingdom Sim** — Cyberlore, 2000 / Majesty 2, 2009
- 영웅은 **플레이어가 직접 조종할 수 없다.** 왕은 건물을 짓고 영웅을 고용하며, **현상금 깃발**(공격·탐험, 2편에 보호·공포)로 유도할 뿐. 영웅은 성격대로 움직이고 상점에서 장비를 산다. **주문은 왕이 직접 쓴다.**
- 평: 1편의 매력은 "영웅을 마음대로 못 하는 데서 오는 재미"였고, 2편이 통제를 늘리자 그 맛이 줄었다는 리뷰.
- **배울 점:** "산장 주인이 용병을 고용하고 간접 개입한다"는 지금 방향과 가장 닮은 고전. **간접 개입 수단을 깃발(어디로 가라) 하나와 주문 몇 개로 줄였다.** 2026년 신작 **Crown of Greed**가 Majesty를 표방한다.
- [TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/Videogame/Majesty) · [GameBanshee Majesty 2 리뷰](https://gamebanshee.com/a84) · [Giant Bomb](https://www.giantbomb.com/games/3030-21454/) · [Crown of Greed](https://store.steampowered.com/app/1697870/Crown_of%20Greed/) **[검색 확인]**

**Hero's Hour** — ThingOnItsOwn, 2021
- 히어로즈 오브 마이트 앤 매직풍 전략. 전투는 **실시간 자동 전투**이고, 플레이어는 **영웅의 마나로 주문을 쓰고 공격 명령**을 내려 흐름을 바꾼다. 주문서 UI가 대상이 될 유닛을 미리 강조해 준다.
- **배울 점:** "오토배틀 + 플레이어가 마나로 주문"이라는 우리 밤과 구조가 가장 가깝다. 다만 **주문서는 고정 목록**(덱·드로우 없음)이다. 대상 미리 보기 강조는 바로 가져올 만하다.
- [Steam/Epic 설명](https://store.epicgames.com/p/heros-hour-871285) · [Cubed3 리뷰](https://cubed3.com/review/6660/1/heros-hour-pc.html) · [v033 전투 업데이트](https://thingonitsown.itch.io/heros-hour/devlog/222862/combat-update-heros-hour-v033) **[검색 확인]**

**Book of Demons** — Thing Trunk, 2018
- 실시간 핵앤슬래시인데 **주문·아이템·스킬이 모두 카드**. 카드는 정해진 슬롯에 **장착**하고 마나로 쓴다(장착 아이템은 마나를 묶어 둠). 이동은 정해진 길만.
- 평: 전략은 "어떤 카드를 슬롯에 넣느냐"에 있다. 적이 몰리면 클릭 게임이 된다는 지적.
- **배울 점:** 카드의 수집·덱 구성 재미는 남기되 **전투 중에는 무작위로 뽑지 않는다.** 이동을 단순화해 손을 카드에 쓰게 했다.
- [RPGFan](https://rpgfan.com/review/book-of-demons) · [HonestGamers](https://www.honestgamers.com/13148/pc/book-of-demons/review.html) **[검색 확인]**

**명일방주(Arknights)** — Hypergryph, 2019 **[일부 검색 확인]**
- 실시간 타워 디펜스. 배치 비용(DP)은 초당 1씩 찬다. 오퍼레이터는 자동 공격하고, **SP가 차면 스킬을 쓴다(자동 발동 스킬과 수동 발동 스킬이 나뉨).** 결투가(Duelist) 계열은 적을 막고 있을 때만 SP가 찬다.
- **배울 점:** 우리 **기세**와 같은 구조가 이미 큰 시장에서 검증됨. 핵심은 **스킬마다 자동/수동을 나눠 플레이어가 신경 쓸 버튼 수를 제한**한 것. 일시정지 · 2배속도 표준 기능이다(일반 지식).
- [DP 위키](https://arknights.wiki.gg/wiki/Deployment_Point) · [Duelist](https://arknights.wiki.gg/wiki/Duelist) · [Advanced strategies](https://arknights.wiki.gg/wiki/Advanced_strategies)

### 갈래 C. 카드 = 전장에 나오는 유닛 그 자체(엘릭서형)

**클래시 로얄** — Supercell, 2016 **[일반 지식]**
- 덱 8장, **손패 4장**, 다음 카드 1장 미리 보임, 엘릭서(최대 10)가 일정하게 참. 카드를 내면 그게 곧 유닛이 되고, 낸 카드는 덱 맨 뒤로. 대상 지정은 "어디에 놓나" 하나뿐.
- **배울 점:** 손패 4장 + 다음 카드 공개가 실시간에서 감당 가능한 상한이라는 오래된 기준. **우리 마력 최대 10과 숫자가 같다.** 대신 전장의 자율 유닛은 모두 "내가 낸 것"이라 손패와 전장이 한 주제다.

**워크래프트 럼블** — Blizzard, 2023
- 골드가 시간에 따라 차고, 미니(유닛)를 배치. **리더**가 가장 강한 유닛이고 전장에 있는 동안 군대 전체에 영향(예: 비행 유닛 비용 감소). 광부로 금광을 먹어 수입을 늘림.
- **배울 점:** "리더 = 덱 방향"을 실시간 게임에서 한 줄로 해결. 우리 "용병이 곧 덱 아키타입"과 같은 생각.
- 상세 조사(리더 25명·특성·모드·적용안): [워크래프트 럼블 리서치 v01](warcraft-rumble-research-v01.md) (2026-10-27).
- [Warcraft Wiki](https://warcraft.wiki.gg/wiki/Warcraft_Rumble) · [Method.gg 리더 가이드](https://www.method.gg/guides/warcraft-rumble-best-starting-leader-minis-guide) · [MassivelyOP 첫인상](https://massivelyop.com/2023/11/17/first-impressions-warcraft-rumble-is-a-slick-but-shambolic-multiplayer-romp/) **[검색 확인]**

**Overdungeon** — Pocketpair, 2019 / **Cards and Towers** — FamilyDevs, 2025
- Overdungeon: 실시간 카드 배틀 + 타워 디펜스 + 로그라이크. 소환한 동물이 실시간으로 움직인다. 평: 중독성 있으나 콘텐츠·난이도·밸런스 부족.
- Cards and Towers: 실시간 타워 디펜스 덱빌더, 타워·유닛·아이템·액티브·파워 카드 200장 이상, **전투 중 같은 등급 카드 2장을 합쳐 더 강한 카드로.** 리뷰 수가 매우 적다(상업적으로 작음).
- [Overdungeon 공식](https://www.pocketpair.jp/overdungeon) · [Vaporlens](https://vaporlens.app/app/919370/overdungeon) · [Cards and Towers 출시](https://cogconnected.com/2025/07/cards-and-towers-brings-deckbuilding-and-tower-defense-together-out-now-on-steam/) · [indie.io](https://www.indie.io/news/master-the-wave-cards-and-towers-launches-today-on-steam) **[검색 확인]**

**Flowers and Deities** — Chill Winter Studio, 2026-08
- 오토배틀러/덱빌더 로그라이트. **피**가 자원 — 아군이든 적이든 유닛이 쓰러질 때마다 피 웅덩이가 차고, 그것으로 주문·소환을 한다. Steam 매우 긍정적(278).
- **배울 점:** 전투 중 자원이 **"전투가 격해질수록 저절로 차오른다"** — 우리 "용병이 싸우면서 카드를 만든다"와 같은 발상을 자원 하나로 단순하게 풀었다. 카드를 여러 종 만들어 주는 대신 **공용 자원 하나만 채워 준다**는 대안.
- [Steam](https://store.steampowered.com/app/3816000/) · [jeu.video 데모 리뷰](https://jeu.video/en/article/flowers-and-deities-review-steam-demo) · [Vaporlens](https://vaporlens.app/app/3816000/flowers_and_deities.md) **[검색 확인 — 전투 중 세부는 미확인]**

### 갈래 D. 전투 중 입력 없음 — 판단은 모두 준비 단계에

**TFT · HS 전장 · Super Auto Pets · Backpack Battles · Mechabellum** **[일반 지식]**
- 전투는 구경만. 상점·배치·아이템·증강체가 전부. 증강체(TFT)·주점 주문(HS 전장)이 "카드 같은 선택"을 준비 단계에 넣는다.

**The Bazaar** — Tempo(Reynad), 2024~
- HS 전장 + TFT를 섞은 비동기 PvP 오토배틀러. 아이템마다 **쿨다운이 있어 전투 중 자동으로 발동**하고, 아이템끼리 서로의 쿨다운을 늦추거나(Slow) 앞당긴다(Haste). 플레이어는 전투 중 아무것도 안 한다.
- **배울 점:** "카드가 전투 중 자동으로 발동"해도 **조합 설계만으로 깊이가 나온다.** 우리 고유 카드 중 일부를 "자동 시전 카드"로 돌릴 수 있다는 근거.
- [Mobalytics 리뷰](https://mobalytics.gg/gamebase/reviews/the-bazaar-review) · [PCGamesN Mak](https://www.pcgamesn.com/the-bazaar/mak-new-hero-season-1) · [아이템 DB](https://mobalytics.gg/the-bazaar/database/items-and-enchantments) **[검색 확인]**

**Despot's Game** — Konfa Games, 2021~22
- 로그라이크 오토배틀러. 방 사이에서 장비·음식·사람을 사고 배치, 전투는 손댈 수 없음. 방 이동에 음식이 들어 경로 판단이 생김.
- 평: **"게임의 대부분은 전투 사이의 자원 관리"**, "유닛을 사서 놓고 구경하는 게 전부라 몰입감이 부족하다"는 비판과 "반사 신경 없이 느긋하게 전략을 짤 수 있다"는 호평이 갈림.
- **배울 점:** 갈래 D를 고르면 **밤이 "구경"이 될 위험**이 실제로 있다. 우리 §3.3 강점 2번("밤에도 개입할 수단이 있다")을 잃는다.
- [Superjump](https://www.superjumpmagazine.com/despots-game-review/) · [But Why Tho?](https://butwhytho.net/2022/10/09/review-despots-game-dystopian-army-builder-brings-rogue-lite-to-auto-battlers-pc/) · [GamingOnLinux](https://gamingonlinux.com/2022/10/roguelike-tactical-auto-battler-despots-game-dystopian-army-builder-is-out-now) **[검색 확인]**

**클래시 미니** — Supercell, 2021~2024 종료
- 보드에 특수 능력 캐릭터를 놓고 자동 전투, **영웅 능력만 전투 중 직접 발동**. Supercell 기준 미달로 2024-04 종료. "그 핵심은 클래시 로얄에 남긴다"고 발표. 2023년 다운로드 약 70만(보도, 신뢰도 낮음).
- **배울 점:** 오토배틀 + 소수 수동 능력이라는 조합 자체는 대형사도 시장 기대를 넘기 어려웠다. 차별점(우리는 서사·운영)이 꼭 필요하다.
- [Game World Observer](https://gameworldobserver.com/2024/03/15/clash-mini-shutdown-supercell-no-new-games-in-five-years) · [PocketGamer.biz](https://www.pocketgamer.biz/news/83620/supercell-axes-clash-mini-as-bold-changes-get-underway-but-theres-still-hope/) **[검색 확인]**

### 갈래 E. 실시간을 버리고 "실시간처럼 보이는 턴제"

**Wildfrost** — Deadpan / Gaziter, 2023
- 턴제지만 **카드(유닛)마다 카운터가 있어 0이 되면 자동으로 행동**한다. 플레이어는 적 카운터를 보고 계획하고, 아군 카운터를 앞당기거나 적을 늦춘다. 개발 중 "모든 행동이 한 턴, 양쪽이 턴 타이머로 공격"하는 카운터 체계로 계속 돌아왔다고.
- **배울 점:** 우리 **기세 → 자동 스킬**을 턴 단위 카운터로 바꾸면 그대로 Wildfrost가 된다. 오토배틀의 "알아서 싸우는 맛"을 유지하면서 생각할 시간을 무한히 준다. 대신 3D 실시간 숲 전투의 박진감은 잃는다.
- [Steam](https://store.steampowered.com/app/1811990/) · [MCV 개발 인터뷰](https://mcvuk.com/?p=224506) · [Checkpoint Gaming](https://checkpointgaming.net/reviews/2023/04/wildfrost-review-dynamic-and-delightful/) **[검색 확인]**

**Into the Breach · 하스스톤 용병단 · Monster Train · Deck of Haunts** **[일반 지식 / 일부 검색]**
- Into the Breach: 적의 다음 행동을 모두 미리 보여 준다(예고). 판단을 퍼즐로 만든다.
- 하스스톤 용병단(2021~2023 종료): 용병마다 능력 3개 + 속도값으로 턴 순서. **실패 원인은 복잡도가 아니라 성장 노가다·과금**이었다는 평이 많다 — 게임 자체는 "단순하고 꽤 재미있다"(Destructoid). [Destructoid](https://www.destructoid.com/hearthstone-mercenaries-impressions-fun-bonus-unnecessary-monetization/) · [Inven Global](https://www.invenglobal.com/articles/15682/hearthstone-mercenaries-blizzards-flaws-and-arrogance) **[검색 확인]**
- Deck of Haunts: 낮 건설 / 밤 카드 방어를 턴제로([이전 리서치 §4](similar-games-research.md)).

### 갈래 F. 낮/밤 분리형 방어 — 구조 참고

**Thronefall** — Grizzly Games, 2023 EA → 2026-11 콘솔
- 낮에 짓고 밤에 왕이 직접 싸우는 미니멀 방어. **매 라운드 어느 방향에서 어떤 적이 몇 마리 오는지 미리 알려 준다.** "복잡해 보이지만 아니다"라는 평. 카드 없음.
- **배울 점:** 우리 저녁 정비의 "오늘 밤 확인"(습격 방향 예고)과 같은 장치가 단순함의 핵심. [The Sixth Axis](https://www.thesixthaxis.com/?p=442518) · [Digitec](https://www.digitec.ch/en/page/thronefall-a-fun-tactics-game-for-little-money-29122) **[검색 확인]**

**킹덤 · TavernHold · Deck of Haunts** — [킹덤 코어 리서치](kingdom-core-research.md), [이전 리서치 §4](similar-games-research.md) 참고.

---

## 3. 게임별 핵심 비교표

| 게임 | 전투 | 전장 자율 유닛 | 플레이어 전투 중 입력 | 손패/드로우 | 정지·감속 | 마녀산장 대응 |
| --- | --- | --- | --- | --- | --- | --- |
| 록맨 에그제 | 실시간 | 적만 | 칩 사용 + 이동 | 게이지마다 5장 중 선택 | **게이지 찰 때 정지** | 박자형 밤(§4 안 A) |
| Lost in Random | 실시간 | 적만 | 카드 + 액션 | 게이지로 1장씩, 최대 5 | **주사위 굴리면 정지** | 박자형 밤 |
| Ratropolis | 실시간 | 많음 | 카드 계속 | 드로우 계속 | 구매 화면만 정지 | 현재 v04에 가장 가까운 선례 |
| 클래시 로얄 | 실시간 | 내가 낸 것 | 카드 계속 | **손패 4 + 다음 1 공개** | 없음 | 손패 상한 기준 |
| 킹덤 러시 | 실시간 | 타워·병사 | 영웅 + **주문 2개** | 없음(쿨다운) | 일시정지 | 고정 버튼(안 B) |
| Majesty | 실시간 | **영웅 자율** | 깃발 + 주문 | 없음 | 일시정지 | 간접 지휘 + 고정 버튼 |
| Hero's Hour | 실시간 자동 | 전부 | **마나 주문 + 공격 명령** | 없음(주문서) | — | 우리 밤과 구조 최근접 |
| Book of Demons | 실시간 | 적만 | 카드 슬롯 | **장착형**(무작위 없음) | — | 고정 버튼(안 B) |
| 명일방주 | 실시간 | 배치한 것 | 배치 + **수동 스킬 일부** | 없음 | 일시정지·배속 | 기세 자동/수동 구분 |
| Flowers and Deities | 자동 | 전부 | 피로 주문·소환 | 덱빌더 | ? | 자원 하나로 단순화 |
| The Bazaar | 자동 | 전부 | **없음** | 없음(쿨다운 자동) | — | 자동 시전 카드(안 C) |
| Despot's Game | 자동 | 전부 | 없음 | 없음 | — | "구경" 위험 경고 |
| Wildfrost | 턴제 | 카운터로 자동 | 턴마다 카드 | 덱빌더 | 턴제 | 카운터 턴제(안 D) |

---

## 4. 마녀산장에 대한 제안

### 4.1 버거움을 둘로 나눠 본다

- **플레이어가 버거운 것:** 밤에 오토배틀을 보면서 동시에 손패·마력·생성 카드·대상을 챙겨야 함. → 갈래 A·B·D가 답한다.
- **기획자가 버거운 것:** 24명 × (패시브 + 스킬 + 카드 1~2장 + 생성 카드) + 6종족 시너지 + 마력 + 덱 순환 + 낮 턴제. 시스템 한 번 바꿀 때마다 검토할 표가 너무 많다. → 갈래 B·D(카드 층을 얇게)가 답한다.

### 4.2 세 가지 안

**안 A — 박자형 밤 (추천, 변경량 작음)** · 록맨 에그제 + Lost in Random
- 마력이 초당 차는 대신 **"부름 게이지"**(가칭, 8~10초에 1회)가 찬다. 차면 **세상이 멈추고(지금의 손패 고민 시간 `freeze`를 강제로 켬)** 손패에서 마력이 허락하는 만큼 카드를 낸 뒤 다시 흐른다.
- 실시간 구간에는 **손패를 쓸 수 없다**(또는 비싼 비용으로만). 그동안 용병은 알아서 싸우고, 기세 스킬이 터지고, **생성 카드는 손패에 쌓이기만 한다.**
- 바뀌는 것: 마력 충전 방식, 손패 사용 시점. **그대로인 것:** 오토배틀 · 기세 · 용병이 만드는 카드 · 시작 손패 5장 · 덱 순환 · v04 키트 전부.
- 효과: 플레이어 주의가 "보기 8초 → 고르기(멈춤) → 보기 8초"로 교대한다. 생성 카드가 "언제 생겼지?"가 아니라 "다음 박자에 쓸 거리"가 된다.
- 위험: 박자가 너무 잦으면 끊기는 느낌, 너무 뜸하면 개입감 부족. 헤드리스로 밤 길이 대비 박자 횟수를 잰다. 위급할 때를 위해 **"지금 부르기"**(게이지 미달 시 마력 페널티) 버튼을 둘 수 있다.

**안 B — 카드는 용병의 버튼으로 (변경량 중간)** · 킹덤 러시 + Hero's Hour + Book of Demons
- 밤에는 손패를 없앤다. 각 용병 초상 메달 위에 **그 용병의 고유 카드가 버튼으로 붙고**, 마력과 쿨다운으로 쓴다. 생성 카드는 그 용병 메달 위에 **충전 횟수(×2)** 로 표시.
- 덱빌딩은 "어떤 용병을 고용하고 그 카드를 어떻게 강화하나"로 옮긴다(낮 저녁 정비). 슬더슬식 덱 순환은 포기한다.
- 효과: 화면에서 볼 곳이 **"용병 메달 줄" 하나**로 모인다. 어떤 카드가 누구 것인지 설명이 필요 없다.
- 위험: 코어 결정 §1-3("사용한 카드는 슬더슬처럼 순환")과 Q4(시작 손패 5장)를 뒤집는다. 사용자 결정이 필요.

**안 C — 생성 카드만 자동 시전 (부분 처방)** · The Bazaar
- 용병이 만드는 생성 카드 14종 중 단순한 것(통나무 벽·약초 물·재의 부적 등)은 **손패로 오지 않고 그 자리에서 자동 발동**하거나, 손패에 와서 N초 안 쓰면 자동 발동.
- 효과: 층 4(언제 생길지 모르는 카드)가 크게 줄어든다. 손패에는 플레이어가 **고르는 맛이 있는 카드**만 남는다.
- 안 A와 같이 쓸 수 있다.

**(비교) 안 D — 밤도 턴제 카운터** · Wildfrost
- 가장 확실하게 가벼워지지만 실시간 3D 숲 전투라는 지금 자산을 크게 버린다. 안 A가 실패하면 검토.

**(비교) 안 E — 밤 입력 제거** · TFT·Despot's
- Despot's Game의 "구경만 한다" 비판 + 우리 강점(밤 개입)을 잃음. 비추천.

### 4.3 어느 안이든 바로 가져올 작은 것들

1. **손패 상한을 낮춘다** — 클래시 로얄 기준 4장 + 다음 1장 공개. 지금 표시 상한 8장(`HAND_VISIBLE`)은 실시간엔 많다.
2. **카드 대상은 한 종류로** — Hero's Hour처럼 대상을 미리 강조. 고유 카드가 "지점/용병/적" 세 가지 대상을 섞지 않게, 카드 틀에 대상 아이콘 하나.
3. **배속 버튼(1×/2×)과 일시정지** — 명일방주·킹덤 러시 표준. 오토배틀이 지루한 구간을 넘기게.
4. **습격 예고** — Thronefall처럼 저녁에 방향·종류·수를 보여 준다(이미 [하루 구조 §5](day-turn-structure-v01.md) "오늘 밤 확인"에 있음 → 우선순위 올림).
5. **기세 스킬은 전부 자동 유지** — 명일방주처럼 수동 스킬을 섞으면 버튼이 24개로 늘어난다. 플레이어 버튼은 카드뿐.
6. **처음엔 용병 2~3명, 고유 카드 3~4종으로 시작하는 튜토리얼 밤** — Majesty·킹덤 러시 모두 도구를 하나씩 연다.

### 4.4 다음 단계 제안

1. 안 A/B/C 중 방향을 사용자가 고른다(복수 가능: A + C 추천).
2. 고른 안을 [코어 방향](core-direction-kingdom-sts-v01.md) §0에 결정으로 올리고, 인간 4명 키트로 오토배틀 토대 시험에 같이 넣는다(§8 5단계).
3. 헤드리스로 "밤 1회당 플레이어가 결정하는 횟수"와 "동시에 손패에 있는 카드 수"를 기록해 안 사이를 숫자로 비교한다.

---

## 5. 조사 한계

- 대부분 상점 설명·리뷰·위키 기반이며 직접 플레이하지 않았다.
- 명일방주의 "배치 시 감속"은 검색으로 확인하지 못해 본문에서 뺐다.
- Flowers and Deities·Void Salvage·Grail 등 2026년 신작은 전투 중 조작의 세부를 확인하지 못했다.
- 클래시 로얄·TFT·HS 전장·Into the Breach·FF7R·체인 오브 메모리즈는 이번에 따로 출처를 찾지 않은 일반 지식이다.

## 6. 변경 기록

- 2026-10-26 v01: 사용자 요청("실시간 전투 + 카드가 버겁다, 유사 게임에서 힌트")으로 작성. 해법 6갈래, 게임 20여 종, 마녀산장 안 A~E.
