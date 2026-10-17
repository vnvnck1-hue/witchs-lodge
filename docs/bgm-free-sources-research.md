# 무료 상업용 Medieval Fantasy BGM 리서치

조사일: 2026-10-17. 목적: 마녀산장의 BGM 슬롯(`bgm_field` 낮 / `bgm_evening` 저녁 / `bgm_combat` 밤 전투, [sound_bank.gd](../godot/scripts/audio/sound_bank.gd))에
넣을 수 있는 **무료 + 상업 이용 가능** Medieval Fantasy 음악 출처를 온라인에서 찾고 라이선스를 각 페이지에서 직접 확인한 기록.
현재 BGM은 ElevenLabs(Starter 유료, 상업 가능)로 만든 곡([audio-game-sfx-v01](../output/audio-game-sfx-v01/README.md))이며, 이 문서는 그 대체·보강 후보다.

## 결론 요약

| 등급 | 조건 | 추천 출처 |
|---|---|---|
| **A. CC0 (크레딧 불필요, 가장 안전)** | 그대로 써도 됨 | OpenGameArt **RandomMind "Medieval:" 시리즈**, itch.io **alkakrab Medieval Vol.2**(작가가 댓글로 CC0 확인) |
| **B. CC BY 4.0 (크레딧 필수)** | 게임 크레딧 화면에 표기 | Alexandr Zhelanov, Kevin MacLeod(incompetech), Scott Buckley, Alexander Nakarada(creatorchords), Eric Matyas(soundimage), Olivér Kovács |
| **C. 독자 무료 라이선스 (크레딧 불필요, 단독 재배포 금지)** | 게임 안에 포함만 가능 | **Pixabay Music** |
| **보류** | 라이선스 문구 없음 / 조건 불명 | lisetteamago, alkakrab Ambient 팩, Fesliyan(상업은 기부 필요), rustedstudio(AI 보조 태그) |

가장 빠른 길: **A등급 RandomMind 곡으로 낮·저녁·전투 3슬롯을 전부 채울 수 있다**(태번·탐험·수확·전투·승리·패배가 한 작가, 한 라이선스, 루프 WAV 제공).
전투 곡의 다양성이 필요하면 B등급 Zhelanov "Tiny Swords Duel"을 크레딧과 함께 추가한다.

## A. CC0 — 크레딧 불필요

### A1. RandomMind — OpenGameArt "Medieval:" 시리즈 (CC0 1.0)

작가 페이지: <https://opengameart.org/users/randommind>. 각 곡 페이지에서 `License(s): CC0` 와 "Credits are appreciated but not required" 를 확인했다.

| 곡 | 분위기·태그 | 파일 | 추천 슬롯 |
|---|---|---|---|
| [Medieval: The Old Tower Inn](https://opengameart.org/content/medieval-the-old-tower-inn) | 태번·포크·업비트·평화 | MP3 2.5MB + **Loop WAV** 8.8MB | `bgm_field` 낮 |
| [Medieval: King's Feast](https://opengameart.org/content/medieval-kings-feast) | 태번·시장·축제 | MP3 5.2MB + **Loop WAV** 14.2MB | `bgm_field` 낮 (손님 많은 날) |
| [Medieval: Minstrel Dance](https://opengameart.org/content/medieval-minstrel-dance) | 류트·비올라, 춤·축제 | Loop WAV 포함 | `bgm_field` 낮 |
| [Medieval: The Bard's Tale](https://opengameart.org/content/medieval-the-bards-tale) | 류트·플루트, 잔잔 | Loop WAV 포함 | `bgm_evening` 저녁 |
| [Medieval: Exploration](https://opengameart.org/content/medieval-exploration) | 메뉴·탐험용, 차분 | MP3 9.4MB / WAV 62MB (루프 표기 없음) | 메뉴 / `bgm_evening` |
| [Medieval: Battle](https://opengameart.org/content/medieval-battle) | 전투·결투·업비트 | MP3 3.2MB / WAV 27.8MB (루프 표기 없음) | `bgm_combat` 밤 전투 |
| Medieval: Harvest Season / Market Day / Rejoicing | 수확·시장·축하 | 작가 페이지에서 확인 | 낮 변주, 웨이브 클리어 |
| Medieval: Victory Theme / Defeat Theme | 승리·패배 | 작가 페이지에서 확인 | `sfx-victory`·`sfx-defeat` 대체 징글 |
| [Chiptune] 버전 3곡 | 8비트 | — | 해당 없음 |

비고: 작가가 Patreon(<http://www.patreon.com/randommind>)을 운영한다. 크레딧은 선택이지만 넣는 편이 좋다.

### A2. alkakrab — "This Is Free Medieval Soundtrack" (itch.io)

<https://alkakrab.itch.io/free-medieval-soundtrack-no-copyright>
- 페이지 문구: "absolutely free for commercial use", "You don't need to credit me if you don't want". 댓글에서 "CC0인가요?" 질문에 작가가 **"Yes"** 라고 답함.
- 파일: `Medieval Vol. 2.zip` 354MB + `Loops Medieval Vol. 2.zip` 485MB(루프 버전 별도). 사람이 직접 만듦("No generative AI" 태그).
- 주의: 페이지 메타데이터에 정식 라이선스 표기가 아직 없다. 사용 시 댓글 답변을 스크린샷으로 보관할 것.

## B. CC BY 4.0 — 크레딧 필수 (크레딧 화면에 아래 형식으로 표기)

### B1. Alexandr Zhelanov — "Tiny Swords Duel" (CC BY 4.0)
<https://opengameart.org/content/tiny-swords-duel> — 루프 가능한 소규모 전투 곡, OGG 3.9MB. 표기: `Alexandr Zhelanov — https://www.youtube.com/c/AlexandrZhelanovsMusic`. 추천 슬롯: `bgm_combat` 두 번째 곡.

### B2. Kevin MacLeod — incompetech (CC BY 4.0)
<https://incompetech.com> — 무료 사용은 CC BY 4.0, 크레딧 불가능한 경우만 유료 Standard License. 공식 표기 형식:
```
"곡 제목" Kevin MacLeod (incompetech.com)
Licensed under Creative Commons: By Attribution 4.0
https://creativecommons.org/licenses/by/4.0/
```
Medieval/Celtic 후보(사이트 검색어 "medieval", "celtic", "folk"로 직접 찾을 것; 아래 곡명은 외부 모드 크레딧·기억에 의한 것으로 **이번 조사에서 페이지 확인은 안 함**): Achaidh Cheide, Angevin B, Ascending the Vale, Suonatore di Liuto, Minstrel Guild, Teller of the Tales.

### B3. Scott Buckley (CC BY 4.0)
<https://www.scottbuckley.com.au/library/> — "All music is licensed under Creative Commons Attribution 4.0". 판타지 후보: **Song Of The Forge**(드워프 전쟁 행진, 전투용), 현악 위주 Penumbra·Echoes Of Home(저녁용). 중세보다는 시네마틱 오케스트라 톤.

### B4. Alexander Nakarada — creatorchords.com (무료 = 크레딧 필수)
<https://creatorchords.com/> — 무료 다운로드는 "Attribution required", 유료($20~)는 크레딧 면제. Celtic/Fantasy 카테고리: Óró sé do bheatha abhaile, Siúil a Rúin, Norður 2019, Helheim, Ascendant. 과거 serpentsoundstudios.com 은 더 이상 그의 사이트가 아님(2026-10 확인: 무관한 블로그).

### B5. Eric Matyas — soundimage.org (크레딧 필수)
<https://soundimage.org/fantasy/> — 모든 곡 "Royalty-Free", 크레딧 표기 요구(형식: `"곡 제목" by Eric Matyas, www.soundimage.org`). AI 미사용 명시. 마녀산장에 맞는 곡: **Spell's a Brewin'**(고블린 요리, 장난스러움 1:21), **Misty Bog**(0:59)·**Bog Creatures On the Move**(1:08, 으스스), **Our Mountain_v003**(RPG 오프닝 1:19), **Netherplace**(마을 1:37), **Game Menu**(1:41). 루프 품질은 엔진에서 직접 확인 필요.

### B6. Olivér Kovács — "The Enchanted Land" (itch.io, 무료, 크레딧 + SNS 링크 조건)
<https://olivercomposer.itch.io/the-enchanted-land-fantasy-music-pack> — 16곡/35트랙, WAV 24bit, 거의 모든 곡 Loop+Ending 분리, Fight I·II·Boss Fight(드럼 유무 변주), Calm I~IV, The Queen of the Enchanted Forest, Dark Soundscape I·II, Win/Lose. 699MB. 조건: 작곡가 크레딧 + 제품 설명에 작가 SNS/웹사이트 1개 링크(작가 댓글). 정식 라이선스 문서는 없음.

### B7. rustedstudio — "The Lost Tales Of Aldaria" (CC BY 4.0) — 주의
<https://rustedstudio.itch.io/free-music-the-lost-tales-of-aldaria-11-calm-medieval-music-tracks> — 류트·하르당게르 피들 10곡+1, 루프 없음, **"AI Assisted" 태그**(보너스 곡 AI 보컬). AI 보조 음원을 피하려면 제외.

## C. 독자 무료 라이선스

### C1. Pixabay Music (Pixabay Content License)
<https://pixabay.com/music/search/medieval%20fantasy/> — 상업 이용 가능, 크레딧 불필요. **단독(Standalone) 재배포·판매 금지** → 게임 안에 포함은 되지만 OST 별도 배포는 불가. 검색 결과 상위: DeusLower "Fantasy Medieval Ambient"(3:39)·"Fantasy Medieval Mystery Ambient"(3:20)·"Fantasy Medieval Epic Music"(3:09), kaazoom "By the Rafters Glow"(태번 2:22), Forgotten-Hero-Records "Medieval Quiet Shore"(3:34), Tunetank "Medieval Happy/Festive/Waltz"(1:08~1:36). 라이선스는 CC가 아니므로 다운로드 시 라이선스 페이지 스크린샷을 보관한다.

## 보류·제외

- **lisetteamago "Free Medieval Fantasy Music"** — "Royalty free & YouTube safe"만 있고 상업 이용·라이선스 문구 없음. 작가에게 확인 전 사용 금지. (태번 곡 2개가 좋아 보이면 문의 가치 있음.)
- **alkakrab "Fantasy Medieval Ambient Music Pack"** — "free for commercial use" 문구는 있으나 라이선스 질문에 "Will think about it". Vol.2와 달리 CC0 확인 없음.
- **Fesliyan Studios** — 상업 프로젝트는 기부 필요, YouTube 라이브 제한. 제외.
- **Joel Steudler / ELV Games / apogio** — 유료($5~15). 품질은 높지만 "무료" 조건 밖.
- **CC BY-NC / CC BY-SA** 전부 제외(판매 게임 불가 / 공유조건).
- **free-stock-music.com "Medieval Fantasy" (MaxKoMusic)** — CC BY-SA 3.0 → 제외.

## 게임 적용 메모

1. 파일 규칙: `godot/assets/audio/bgm-<slot>-NN.mp3|ogg|wav` 와 `build/audio/` 양쪽에 두고 두 `selected.json` 의 `bgm_field`/`bgm_evening`/`bgm_combat` `files` 에 추가. 낮 곡은 여러 파일이면 새 날마다 무작위 선택됨.
2. 루프: 믹서가 곡 끝 4초 전 다음 회차를 겹치므로(`MUSIC_XF`) 루프 WAV가 아니어도 되지만, 루프 WAV는 `trim_db` 로 음량만 맞추면 된다. 음량 보정은 기존 `-8 dB` 기준에 맞춰 `trim_db` 조정.
3. 크레딧: B·C 등급을 쓰면 `docs/credits.md`(또는 정지 메뉴 크레딧 탭)에 위 형식대로 표기. CC0만 쓰면 생략 가능하나 작가명은 적는 편을 권장.
4. 검증: 추가 후 `verify_bgm_mix.gd`·`verify_game_sfx.gd` 헤드리스 통과 확인, `trim_db` 는 `verify_audio_review` 기준.
5. 다운로드한 압축 파일은 `output/bgm-free-v01/raw/` 같은 빈 폴더에 풀고, 각 곡 옆에 출처 URL·라이선스·확인일을 `sources.json` 으로 남긴다.

## 참고 링크 (검색 경유)

- 가이드: [gtstu — Free music for indie games](https://gtstu.com/free-royalty-free-music-indie-games/), [cinevva 2026 guide](https://app.cinevva.com/guides/free-sound-effects-music), [chosic medieval](https://www.chosic.com/free-music/medieval/)
- OGA 다크 앰비언트(CC0, 저녁·밤 보조): [Cathedral in the Forest](https://opengameart.org/content/cathedral-in-the-forest-ambient-loop), [Sirens in Darkness](https://opengameart.org/content/sirens-in-darkness)
- 기타 itch.io 무료: [fatalexit Medieval Melancholy (CC BY 4.0)](https://fatalexit.itch.io/medieval-melancholy-free-royalty-free-music-epic-fantasy-music), [Ivan Duch medieval](https://ivanduch.com/dnd-music/medieval-music/)

## 적용 기록 (2026-10-17)

사용자가 청취 후 고른 4곡을 적용했다 — 낮 `bgm_field`: Minstrel Dance·Harvest Season(RandomMind, CC0), 밤 전투 `bgm_combat`: Medieval: Battle(RandomMind, CC0)·Dentaneosuchus Hunt(Kevin MacLeod, **CC BY 4.0, 크레딧 필수** → [credits.md](credits.md)).
두 슬롯 모두 2곡 무작위(낮은 새 날마다, 전투는 시작마다 직전과 다른 곡). 파일·음량 보정·검증 기록은 [output/bgm-free-v01](../output/bgm-free-v01/README.md), 출처는 [sources.json](../output/bgm-free-v01/sources.json).
