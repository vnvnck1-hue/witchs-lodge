# 고블린 카드 v01 · 실제 생성 프롬프트

2026-10-19 · 내장 `image_gen` 사용. 매 호출 `transparent_background=true`.

매 호출에 역할 승인 PNG, 같은 역할의 게임 카드 1~2장, 고블린 외형 참고 시트를 실제 이미지 입력으로 전달했다. 외형 시트는 다음 6개를 비율 유지 축소·배열한 자료이며, 개별 원화의 색·형태를 바꾸지 않았다.

- `art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png`
- `godot/assets/portraits/guest_graz_cutout.png`
- `godot/assets/portraits/guest_tak_cutout.png`
- `godot/assets/portraits/guest_pikl_cutout.png`
- `godot/assets/portraits/guest_rusk_cutout.png`
- `godot/assets/portraits/guest_mala_cutout.png`

도구의 참고 이미지 최대 5장 제한에 맞춰 외형 자료만 시트로 묶었다. 프레임 기준은 항상 첫 번째 승인 개별 PNG다. 후반 수정에서는 원화 대상과 배치/마름모 도식을 추가하고 같은 역할의 게임 참고를 1장으로 줄여 입력 상한을 지켰다. 도식은 글자 크기·위치·원화창 하단 설명용 보조 입력이며 납품 원화로 사용하지 않았다.

## goblin_gang · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정. 인물 종족 배지 누락 보완.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/01-character-nib.png`
2. `godot/assets/cards/warrior.png`
3. `godot/assets/cards/forest_monster.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: character; preserve large arched portrait window; a single small goblin badge entirely above y=1120. SUBJECT: Three or four small happy goblins cluster and run toward viewer, mismatched pot helmets, wooden sticks and ladles as silly weapons, fill arched portrait window, night forest edge lit by lanterns.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "사촌 패거리"; category: "고블린 · 졸개 소환"; rules line 1: "밤에 땅에 놓으면 졸개가 몰려옵니다."; rules line 2: "졸개는 새벽에 돌아갑니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_gang-v01.png`
SHA-256: `a0313b9ebd034356eeb806ac4d4e79a81b5e40bdf83fb803e1f9b4f94cf838f4`

## goblin_firecracker · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `godot/assets/cards/vine_snare.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: skill; preserve thick black diamond art window with thin cream inner line; lower tip ends by y=1100, no species badge. SUBJECT: A large round wooden powder keg with copper hoops and rivets, lit fuse, seconds before bursting with bright fiery stars and billowing smoke, centered in diamond. Cheerful fantasy firecracker, handmade medieval materials.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "고블린 폭죽"; category: "고블린 · 도박 폭발"; rules line 1: "밤에 던지면 크게 터집니다."; rules line 2: "가끔 아군도 그을립니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_firecracker-v01.png`
SHA-256: `6e75d7877f99f419e5324a54d516e17e257f476c739027b53553620c2ae11e69`

## dud_bomb · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `godot/assets/cards/vine_snare.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: skill; preserve thick black diamond art window with thin cream inner line; lower tip ends by y=1100, no species badge. SUBJECT: A SMALL squat battered wooden keg with copper hoops, half split open pathetically, only a weak puff of grey smoke and a few tiny dizzy stars. Clear small silhouette, subdued and shabby, companion to large explosive firecracker, no huge fireball.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "불발탄"; category: "고블린 · 기절"; rules line 1: "밤에 던지면 좁게 터집니다."; rules line 2: "맞은 적이 잠깐 기절합니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/dud_bomb-v01.png`
SHA-256: `281019e539f52bf5f0ed08b329f45a08ca96ca130b69861237c3c7d5283c0b49`

## goblin_rush · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `godot/assets/cards/vine_snare.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: skill; preserve thick black diamond art window with thin cream inner line; lower tip ends by y=1100, no species badge. SUBJECT: A crowd of little big-eared goblin minions all rush in one direction toward right across snowy forest, ragtag pot helmets, wooden sticks, tossed snow and dust show motion, no graphic speed lines. Clear group silhouette.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "떼거리 돌격"; category: "고블린 · 졸개 돌진"; rules line 1: "졸개 전원이 한 곳으로 돌진합니다."; rules line 2: "졸개가 많을수록 셉니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_rush-v01.png`
SHA-256: `7898b181bd7306377f0698baeb92b21c0de9d9eb7a887503fcc47478f9c2bf48`

## shiny_lure · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `godot/assets/cards/vine_snare.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: skill; preserve thick black diamond art window with thin cream inner line; lower tip ends by y=1100, no species badge. SUBJECT: Glass marbles, buttons and copper coins crudely tied into one sparkling lump with string, lying on snow emitting warm golden gleams. Large readable central lump in diamond, no modern materials.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "반짝이 미끼"; category: "고블린 · 어그로 끌기"; rules line 1: "밤에 던지면 적이 몰려듭니다."; rules line 2: "끝나면 터져 눈부시게 합니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/shiny_lure-v01.png`
SHA-256: `cc219c038bf899619dbd37577df59e888c1e5ece1c2c3a08a7742624ecc95117`

## junk_barricade · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/05-facility-forest-altar.png`
2. `godot/assets/cards/ward_lantern.png`
3. `godot/assets/cards/sleeping_thorn_seed.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: facility; preserve low roof point, broad rectangular title panel, architectural side posts, solid lower compartment with continuous cream rules panel; no post, stone or step inside text safe area. SUBJECT: A crooked makeshift fence of mismatched nailed wooden planks, cooking pot lids and rusty hinges, charmingly flimsy on snow in front of woodland lodge. No text or digits on planks.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "고물 방책"; category: "고블린 · 임시 시설"; rules line 1: "목재 1로 바로 세웁니다."; rules line 2: "2일 뒤 새벽에 무너집니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/junk_barricade-v01.png`
SHA-256: `769d2cfe3cab55b5b9bead3ebb4d1deea09b59013e01e839f248d1027b4acbbf`

## pikl_traps · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/05-facility-forest-altar.png`
2. `godot/assets/cards/ward_lantern.png`
3. `godot/assets/cards/sleeping_thorn_seed.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: facility; preserve low roof point, broad rectangular title panel, architectural side posts, solid lower compartment with continuous cream rules panel; no post, stone or step inside text safe area. SUBJECT: Exactly THREE small iron toothed traps laid out on snow with a bundled string bearing counting knots, coiled ropes. Pikl's improvised medieval handiwork, no creatures caught, no gore.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "피클의 덫 꾸러미"; category: "고블린 · 덫 설치"; rules line 1: "땅에 작은 덫 셋을 깝니다."; rules line 2: "밟은 적이 잠깐 멈춥니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/pikl_traps-v01.png`
SHA-256: `eb30f066fc5030e20a1835c5e5ed2c8d8dbca47a8f25be095501319f036902e0`

## junk_sack · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정. 잘못 복제된 목재 표식을 카드 주제 표식으로 교체.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/03-resource-timber.png`
2. `godot/assets/cards/timber.png`
3. `godot/assets/cards/rabbit_pelt.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: resource; preserve simple rectangular art window, single small resource icon at art/rules junction above y=1120, continuous single rules panel without extra horizontal stripes. SUBJECT: One bulging burlap sack, opening overflows with scraps of wood, leather, buttons and a spool of thread. Warm amber light against winter woodland, handmade moss green patches, tiny copper rivets.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "잡동사니 자루"; category: "고블린 · 자원 꾸러미"; rules line 1: "낮에 열면 자원이 나옵니다."; rules line 2: "가끔 쓸모없는 고물도 섞입니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/junk_sack-v01.png`
SHA-256: `ee5a660674edac504fbb6c1ddb1376e5ec5adcae6914920e45a50a922456942b`

## scrap · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정. 잘못 복제된 목재 표식을 카드 주제 표식으로 교체.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/03-resource-timber.png`
2. `godot/assets/cards/timber.png`
3. `godot/assets/cards/rabbit_pelt.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: resource; preserve simple rectangular art window, single small resource icon at art/rules junction above y=1120, continuous single rules panel without extra horizontal stripes. SUBJECT: A small handful of useless medieval metal junk: dented spoon, broken hinge, pierced cooking pot fragments on snowy wooden doorstep. NOT treasure, no gems. Rust and copper tones, clearly open heap distinct from a sack.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "고물"; category: "고블린 · 판매용"; rules line 1: "산장에 놓으면 팝니다."; rules line 2: "1개 4G.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/scrap-v01.png`
SHA-256: `87b39d1f6bba3fd4d5aff704d71a08d63736b6cf0de446e8b85a40672ed03974`

## graz_whistle · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `godot/assets/cards/rusty_longsword.png`
3. `godot/assets/cards/rowan_charm.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: equipment; preserve tall shield shaped art window, shield tip ends by y=1100, continuous cream rules panel. SUBJECT: A single aged bone and copper whistle hanging vertically by braided leather cord, one tiny copper coin charm, large central object inside shield window. Warm lodge background and indigo snow beyond.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "그라즈의 호루라기"; category: "장비 · 장신구 · 고블린"; rules line 1: "용병에게 걸어 줍니다."; rules line 2: "고블린이 불면 졸개가 옵니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/graz_whistle-v01.png`
SHA-256: `64e991e2b85e4d9bd28dd8a9e4cdeba151e156739d185fb74f672f1218191a5f`

## pot_helmet · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `godot/assets/cards/rusty_longsword.png`
3. `godot/assets/cards/rowan_charm.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: equipment; preserve tall shield shaped art window, shield tip ends by y=1100, continuous cream rules panel. SUBJECT: A dented iron cooking pot repurposed as goblin helmet, broad readable pot silhouette, hammered repair marks and copper rivets, handles positioned as ear openings, dangling leather chin strap. Display object, no wearer.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "찌그러진 냄비 투구"; category: "장비 · 방어구 · 고블린"; rules line 1: "용병에게 씌웁니다."; rules line 2: "맞을수록 닳고, 고블린은 고쳐 씁니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/pot_helmet-v01.png`
SHA-256: `c66d63b6e2211c3e25bc54bc44e7203d440aa6c7ae77be4595625fa213b0828f`

## mala_coin_scale · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `godot/assets/cards/rusty_longsword.png`
3. `godot/assets/cards/rowan_charm.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: equipment; preserve tall shield shaped art window, shield tip ends by y=1100, continuous cream rules panel. SUBJECT: Small brass TWO PAN balance scale standing on purple velvet, a few copper coins in one pan. Large distinct T shaped silhouette centered in shield, handmade patina. No monocle.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "말라의 동전 저울"; category: "장비 · 장신구 · 고블린"; rules line 1: "용병에게 쥐여 줍니다."; rules line 2: "처치할 때 골드를 더 얻습니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/mala_coin_scale-v01.png`
SHA-256: `5ed7f040a5eaa6fece4a6a3c3811f8561d013690bacaaf2fb651fb8188d9238c`

## mala_monocle · v01

채택: False · 사유: 제목·분류·본문 크기와 배치 여백 보완을 위해 layout-v02로 수정.

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `godot/assets/cards/rusty_longsword.png`
3. `godot/assets/cards/rowan_charm.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`

```text
Use case: stylized-concept. Asset type: final illustrated Korean game card. Create ONE complete upright 1024x1536 RGBA card, true 2:3, rounded rectangular corners with genuinely transparent outside. Recreate image 1 APPROVED role frame/layout, change subject and all printed text only. Images 2-3 reference current game style and restrained letter sizes; image 4 is a contact sheet of ALL SIX goblin appearance references ONLY, never copy their alternate frame. Purple stock, bold tapering black ink waves, cream panels, painterly printed fantasy illustration, strong clear large color shapes. Medieval-based fantasy, familiar fantasy adaptations preserving medieval daily life and atmosphere. Winter forest/lodge region. Playful shabby cute goblin craftsmanship, moss-green and copper with subtle coins/rivets INSIDE artwork, frame retains approved purple. ROLE: equipment; preserve tall shield shaped art window, shield tip ends by y=1100, continuous cream rules panel. SUBJECT: One round gold-rimmed monocle and fine curling chain on purple velvet, bright reflection on glass lens, large distinct circular silhouette in shield. No balance scale, no wearer.. CRITICAL TYPE LAYOUT: Title field x110..914 y72..236 must retain space for TWO lines even for short name: use restrained 62-70px Korean brush lettering, do NOT enlarge to fill. Category centered around y285, 34-38px. Art between y335..1100. Continuous clean cream description panel x55..970 y1120..1495. Rules safe area x110..914 y1185..1445 reserved for at least FOUR 60px-spaced lines: print the requested TWO lines at y1230 and y1310, around 40-46px, leaving ample blank cream above and below. Longest line must fit within 804px. No ornaments, icons, stones, dividers or frame tips in these safe areas. Exact Korean text including spaces, middle dot surrounded by spaces, punctuation. No other words, digits, stat numbers, placeholder labels, watermark. Requested digits in rules must be retained. No horror, gore, modern tech. Text (verbatim), title: "말라의 외알 안경"; category: "장비 · 장신구 · 고블린"; rules line 1: "용병에게 씌웁니다."; rules line 2: "처치한 적의 재화를 더 잘 찾습니다.". Print no slash.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/mala_monocle-v01.png`
SHA-256: `aa314f53ce39193fbb1dc9fd25aa13390496344b2bb34b825f22ce2b2449aeb5`

## dud_bomb · layout-v02

채택: False · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완; 분류 위치 추가 보완본 선택

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `godot/assets/cards/vine_snare.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/dud_bomb-v01.png`

```text
Edit image 5 (dud_bomb card). Image 1 is its required APPROVED skill frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and skill art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "불발탄" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "고블린 · 기절" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved skill aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"밤에 던지면 좁게 터집니다."
"맞은 적이 잠깐 기절합니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. 
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/dud_bomb-layout-v02.png`
SHA-256: `54bc2fd0048f2fee929284893863083a6e24032d0c05a31667fdbe1207e3ff54`

## goblin_firecracker · layout-v02

채택: False · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완; 분류 위치 추가 보완본 선택

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `godot/assets/cards/vine_snare.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/goblin_firecracker-v01.png`

```text
Edit image 5 (goblin_firecracker card). Image 1 is its required APPROVED skill frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and skill art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "고블린 폭죽" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "고블린 · 도박 폭발" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved skill aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"밤에 던지면 크게 터집니다."
"가끔 아군도 그을립니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. 
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_firecracker-layout-v02.png`
SHA-256: `70a7bb57a273d7be5cd06494751c0ee7aef6d70ec5f3eb18d8af427ba4470621`

## goblin_gang · layout-v02

채택: False · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완; 종족/자원 표식 정정; 분류 위치 추가 보완본 선택

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/01-character-nib.png`
2. `godot/assets/cards/warrior.png`
3. `godot/assets/cards/forest_monster.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/goblin_gang-v01.png`

```text
Edit image 5 (goblin_gang card). Image 1 is its required APPROVED character frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and character art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "사촌 패거리" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "고블린 · 졸개 소환" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved character aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"밤에 땅에 놓으면 졸개가 몰려옵니다."
"졸개는 새벽에 돌아갑니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. Restore ONE SMALL goblin face badge at the lower artwork junction, contained within y1020..1110; no duplicate label below it.
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_gang-layout-v02.png`
SHA-256: `2c32490d02b524ada21542274f68f29bc1dac1d16e4df8741468915d85ffa89e`

## goblin_rush · layout-v02

채택: False · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완; 분류 위치 추가 보완본 선택

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `godot/assets/cards/vine_snare.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/goblin_rush-v01.png`

```text
Edit image 5 (goblin_rush card). Image 1 is its required APPROVED skill frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and skill art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "떼거리 돌격" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "고블린 · 졸개 돌진" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved skill aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"졸개 전원이 한 곳으로 돌진합니다."
"졸개가 많을수록 셉니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. 
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_rush-layout-v02.png`
SHA-256: `e67ba5ac9fe0449c0cdf3079b80a5ef232522c8ec64c2dca62357585a392216f`

## graz_whistle · layout-v02

채택: True · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `godot/assets/cards/rusty_longsword.png`
3. `godot/assets/cards/rowan_charm.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/graz_whistle-v01.png`

```text
Edit image 5 (graz_whistle card). Image 1 is its required APPROVED equipment frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and equipment art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "그라즈의 호루라기" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "장비 · 장신구 · 고블린" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved equipment aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"용병에게 걸어 줍니다."
"고블린이 불면 졸개가 옵니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. 
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/graz_whistle-layout-v02.png`
SHA-256: `9a72c9a122c6404cef7de9b81d282f11b9ce6b0b99d1ab02534fa5b1f66ab27e`

## junk_barricade · layout-v02

채택: True · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/05-facility-forest-altar.png`
2. `godot/assets/cards/ward_lantern.png`
3. `godot/assets/cards/sleeping_thorn_seed.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/junk_barricade-v01.png`

```text
Edit image 5 (junk_barricade card). Image 1 is its required APPROVED facility frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and facility art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "고물 방책" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "고블린 · 임시 시설" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved facility aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"목재 1로 바로 세웁니다."
"2일 뒤 새벽에 무너집니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. 
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/junk_barricade-layout-v02.png`
SHA-256: `73490ff2550f527db2979cb2200baaf137a61415715ca4d812978484328351db`

## junk_sack · layout-v02

채택: True · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완; 종족/자원 표식 정정

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/03-resource-timber.png`
2. `godot/assets/cards/timber.png`
3. `godot/assets/cards/rabbit_pelt.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/junk_sack-v01.png`

```text
Edit image 5 (junk_sack card). Image 1 is its required APPROVED resource frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and resource art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "잡동사니 자루" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "고블린 · 자원 꾸러미" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved resource aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"낮에 열면 자원이 나옵니다."
"가끔 쓸모없는 고물도 섞입니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. Replace the incorrectly copied TIMBER LOG icon with ONE SMALL burlap sack icon inside the same small resource badge above y1120. No logs icon.
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/junk_sack-layout-v02.png`
SHA-256: `47b82eeb963dd0c82002ef3b4e628b19192b969557d754dc840c43ad55270493`

## mala_coin_scale · layout-v02

채택: True · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `godot/assets/cards/rusty_longsword.png`
3. `godot/assets/cards/rowan_charm.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/mala_coin_scale-v01.png`

```text
Edit image 5 (mala_coin_scale card). Image 1 is its required APPROVED equipment frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and equipment art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "말라의 동전 저울" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "장비 · 장신구 · 고블린" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved equipment aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"용병에게 쥐여 줍니다."
"처치할 때 골드를 더 얻습니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. 
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/mala_coin_scale-layout-v02.png`
SHA-256: `d78c1ef37d7165b6f99a9368f4fffe1e93331e98cec38112bf475db96d1b69ec`

## mala_monocle · layout-v02

채택: True · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `godot/assets/cards/rusty_longsword.png`
3. `godot/assets/cards/rowan_charm.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/mala_monocle-v01.png`

```text
Edit image 5 (mala_monocle card). Image 1 is its required APPROVED equipment frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and equipment art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "말라의 외알 안경" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "장비 · 장신구 · 고블린" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved equipment aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"용병에게 씌웁니다."
"처치한 적의 재화를 더 잘 찾습니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. 
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/mala_monocle-layout-v02.png`
SHA-256: `ed234faea6d25d0447b32b2865d7238a65d0a60093e71d511ee83648a6f5dad4`

## pikl_traps · layout-v02

채택: True · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/05-facility-forest-altar.png`
2. `godot/assets/cards/ward_lantern.png`
3. `godot/assets/cards/sleeping_thorn_seed.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/pikl_traps-v01.png`

```text
Edit image 5 (pikl_traps card). Image 1 is its required APPROVED facility frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and facility art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "피클의 덫 꾸러미" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "고블린 · 덫 설치" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved facility aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"땅에 작은 덫 셋을 깝니다."
"밟은 적이 잠깐 멈춥니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. 
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/pikl_traps-layout-v02.png`
SHA-256: `24ff463ed71098a13fb3e12951118d2a3b15d0f19146efced2cb93e84bcc88bb`

## pot_helmet · layout-v02

채택: True · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `godot/assets/cards/rusty_longsword.png`
3. `godot/assets/cards/rowan_charm.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/pot_helmet-v01.png`

```text
Edit image 5 (pot_helmet card). Image 1 is its required APPROVED equipment frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and equipment art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "찌그러진 냄비 투구" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "장비 · 방어구 · 고블린" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved equipment aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"용병에게 씌웁니다."
"맞을수록 닳고, 고블린은 고쳐 씁니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. 
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/pot_helmet-layout-v02.png`
SHA-256: `9362ef2319f531d9b0a7082e5be4feccc66102d81c126f7dfbc8dde4d4310292`

## scrap · layout-v02

채택: True · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완; 종족/자원 표식 정정

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/03-resource-timber.png`
2. `godot/assets/cards/timber.png`
3. `godot/assets/cards/rabbit_pelt.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/scrap-v01.png`

```text
Edit image 5 (scrap card). Image 1 is its required APPROVED resource frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and resource art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "고물" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "고블린 · 판매용" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved resource aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"산장에 놓으면 팝니다."
"1개 4G."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. Replace the incorrectly copied TIMBER LOG icon with ONE SMALL bent spoon and hinge icon inside the same small resource badge above y1120. No logs icon.
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/scrap-layout-v02.png`
SHA-256: `06f07219665514a56fa776d5b205a36d7c9ed465111f47f52a1aa658dba2d99b`

## shiny_lure · layout-v02

채택: False · 사유: 제목 2줄·설명 4줄 여백 및 분류 위치 보완; 분류 위치 추가 보완본 선택

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `godot/assets/cards/vine_snare.png`
4. `output/goblin-cards-v01/goblin-appearance-reference.png`
5. `art/cards/goblin-v01/drafts/shiny_lure-v01.png`

```text
Edit image 5 (shiny_lure card). Image 1 is its required APPROVED skill frame reference; images 2-3 are current game style references; image 4 contains all six goblin appearance references. Keep the subject, medieval winter setting, playful moss/copper details, purple stock and tapered black ink, and skill art-window SHAPE. The current lettering is TOO LARGE and category TOO HIGH. Make this production layout correction visibly:
1. Reduce the title's visible glyph height to 65px (about TWO THIRDS current size). Title "반짝이 미끼" centered at x512,y125. Enlarge cream title panel downward to y330. The ENTIRE rectangular title field x110..914,y72..236 stays clean cream, room for TWO lines, no frame curves or decorations inside. Keep title on one line; do not fill this blank area.
2. Move category "고블린 · 어그로 끌기" DOWN to y270..306, height 36px. Never at y210. It must be a separate row BELOW the title's two-line reserve.
3. Artwork starts y340 and ends by y1110. Keep the approved skill aperture silhouette, adjust art into this window without stretching. All tips, posts and badges must end ABOVE y1120.
4. Bottom rules safe field x110..914,y1185..1445 is uninterrupted cream reserved for FOUR 60px-spaced lines. Reduce rules glyph height to 43px, line spacing 60px, print only these TWO centered lines around y1275 and y1335:
"밤에 던지면 적이 몰려듭니다."
"끝나면 터져 눈부시게 합니다."
Keep exact spaces, punctuation and middle dot spacing in every text. Do not add a slash. Leave substantially MORE whitespace than image 5. 
Single complete 1024x1536 RGBA card, rounded RECTANGULAR silhouette filled edge to edge, transparent outside rounded corners ONLY, opaque interior. Preserve original subject identity and same role as image1. Medieval-based fantasy with familiar adaptations preserving medieval daily life, no modern objects, no extra text, numbers or stats beyond exact requested text.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/shiny_lure-layout-v02.png`
SHA-256: `89da9f1b054d818c36200c5a4296bdd7919d6e0d1a620d140853f5d279c5300e`

## dud_bomb · typography-v03

채택: False · 사유: 분류가 제목 2줄 안전 영역에 남아 있어 배치 도식으로 제목 크기·분류 위치 재교정; 원화창 하단 안전 여백 복구본 선택

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/dud_bomb-layout-v02.png`
5. `output/goblin-cards-v01/layout-guides/dud_bomb.png`

```text
Edit image4 (dud_bomb illustrated skill card). Image1 is approved SKILL diamond frame; image2 same-role game style; image3 all goblin appearance references; image5 is a POSITION/SCALE DIAGRAM only. Keep image4's beautiful original artwork, materials, painterly ink texture, purple/black/cream frame, and thick black diamond with thin cream inner line. Do NOT use the diagram's plain rectangles or blank artwork. Its only purpose is TYPOGRAPHIC PLACEMENT.
Move the category DOWN: it is currently around y225, but must sit at y285 as in diagram image5. Enlarge the top cream title panel DOWN to y330. Keep small title centered at y125, visible glyph height 60-65px and width proportional, in expressive BLACK BRUSH lettering matching image1, NOT the diagram's sans-serif face. A tall EMPTY CREAM GAP between title and category reserves the SECOND TITLE LINE; copy the diagram's spacing exactly. Do not place category in this gap. Main art starts below y340, diamond lower point ends by y1110. Keep all artwork, sparks and drifting snow ABOVE y1120, outside the rules area.
Bottom cream panel is continuous; two exact rules lines at y1275 and y1335, 43-48px expressive brush lettering, four-line reserve x110..914 y1185..1445. No extra labels or symbols, no species badge on a skill.
Verbatim title: "불발탄". Category: "고블린 · 기절". Rules line1: "밤에 던지면 좁게 터집니다.". Rules line2: "맞은 적이 잠깐 기절합니다.". Preserve spaces, middle dots and full stops. All text is brush-ink as image1 with the DIAGRAM'S SIZE AND POSITION. Single complete upright 1024x1536 RGBA, rounded rectangular card, transparent outside corners only, opaque interior. Medieval-based fantasy winter lodge region, familiar fantasy adaptations preserving medieval daily life and atmosphere.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/dud_bomb-typography-v03.png`
SHA-256: `27ee0f35f940782e2bbf83cf5d34fd6fd840bfcf2abcb999f7552bc0675ece9e`

## goblin_firecracker · typography-v03

채택: False · 사유: 분류가 제목 2줄 안전 영역에 남아 있어 배치 도식으로 제목 크기·분류 위치 재교정; 원화창 하단 안전 여백 복구본 선택

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/goblin_firecracker-layout-v02.png`
5. `output/goblin-cards-v01/layout-guides/goblin_firecracker.png`

```text
Edit image4 (goblin_firecracker illustrated skill card). Image1 is approved SKILL diamond frame; image2 same-role game style; image3 all goblin appearance references; image5 is a POSITION/SCALE DIAGRAM only. Keep image4's beautiful original artwork, materials, painterly ink texture, purple/black/cream frame, and thick black diamond with thin cream inner line. Do NOT use the diagram's plain rectangles or blank artwork. Its only purpose is TYPOGRAPHIC PLACEMENT.
Move the category DOWN: it is currently around y225, but must sit at y285 as in diagram image5. Enlarge the top cream title panel DOWN to y330. Keep small title centered at y125, visible glyph height 60-65px and width proportional, in expressive BLACK BRUSH lettering matching image1, NOT the diagram's sans-serif face. A tall EMPTY CREAM GAP between title and category reserves the SECOND TITLE LINE; copy the diagram's spacing exactly. Do not place category in this gap. Main art starts below y340, diamond lower point ends by y1110. Keep all artwork, sparks and drifting snow ABOVE y1120, outside the rules area.
Bottom cream panel is continuous; two exact rules lines at y1275 and y1335, 43-48px expressive brush lettering, four-line reserve x110..914 y1185..1445. No extra labels or symbols, no species badge on a skill.
Verbatim title: "고블린 폭죽". Category: "고블린 · 도박 폭발". Rules line1: "밤에 던지면 크게 터집니다.". Rules line2: "가끔 아군도 그을립니다.". Preserve spaces, middle dots and full stops. All text is brush-ink as image1 with the DIAGRAM'S SIZE AND POSITION. Single complete upright 1024x1536 RGBA, rounded rectangular card, transparent outside corners only, opaque interior. Medieval-based fantasy winter lodge region, familiar fantasy adaptations preserving medieval daily life and atmosphere.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_firecracker-typography-v03.png`
SHA-256: `bdf0c39773fdb83bfc24c64a99e29fd9c65d361efa84b36c987b871591feb838`

## goblin_gang · typography-v03

채택: False · 사유: 분류가 제목 2줄 안전 영역에 남아 있어 배치 도식으로 제목 크기·분류 위치 재교정; 작은 산세리프 제목을 먹선 화풍으로 재보완

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/01-character-nib.png`
2. `godot/assets/cards/warrior.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/goblin_gang-layout-v02.png`
5. `output/goblin-cards-v01/layout-guides/goblin_gang.png`

```text
Edit image 4, the illustrated goblin gang card. Keep its artwork and frame role. Image1 APPROVED character arch frame; image2 current warrior style; image3 all goblin appearance references. Image5 is a TYPOGRAPHIC POSITION AND SCALE DIAGRAM: follow its exact text size and position and the generous empty line between title and category, but NEVER render the diagram's plain rectangles/blank art. Use the same painterly purple/black ink/cream frame and original cheerful four-goblin artwork from image4.
REQUIRED VISIBLE CHANGE: the category row is currently at y225 and must move DOWN to y285. The top cream title panel must grow DOWN to y330. Title becomes MUCH SMALLER, same visible scale as image5, centered near y125. A conspicuous tall blank cream gap must separate the small title from the lowered category, allowing a second title line. Do not copy image4's title/category placement. Retain tiny goblin badge near y1050 above rules. Keep art below y340 and above y1110, preserve arched portrait window. Keep cream bottom panel and exact two rules but match image5 smaller lettering and positions. All ink waves outside x110..914 in title/rules panels. No added artwork or ornaments in text spaces.
Verbatim title: "사촌 패거리". Category: "고블린 · 졸개 소환". Rules: "밤에 땅에 놓으면 졸개가 몰려옵니다." then "졸개는 새벽에 돌아갑니다.". Preserve every word and space. Single complete 1024x1536 RGBA, round rectangular corners, transparent outside corners only. Medieval-based fantasy, preserving medieval daily life and atmosphere.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_gang-typography-v03.png`
SHA-256: `7f401abaaa65f11bcefc6c90002a75a154ee1f29df0bfa72dfd408cb8fb1bf51`

## goblin_rush · typography-v03

채택: False · 사유: 분류가 제목 2줄 안전 영역에 남아 있어 배치 도식으로 제목 크기·분류 위치 재교정; 원화창 하단 안전 여백 복구본 선택

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/goblin_rush-layout-v02.png`
5. `output/goblin-cards-v01/layout-guides/goblin_rush.png`

```text
Edit image4 (goblin_rush illustrated skill card). Image1 is approved SKILL diamond frame; image2 same-role game style; image3 all goblin appearance references; image5 is a POSITION/SCALE DIAGRAM only. Keep image4's beautiful original artwork, materials, painterly ink texture, purple/black/cream frame, and thick black diamond with thin cream inner line. Do NOT use the diagram's plain rectangles or blank artwork. Its only purpose is TYPOGRAPHIC PLACEMENT.
Move the category DOWN: it is currently around y225, but must sit at y285 as in diagram image5. Enlarge the top cream title panel DOWN to y330. Keep small title centered at y125, visible glyph height 60-65px and width proportional, in expressive BLACK BRUSH lettering matching image1, NOT the diagram's sans-serif face. A tall EMPTY CREAM GAP between title and category reserves the SECOND TITLE LINE; copy the diagram's spacing exactly. Do not place category in this gap. Main art starts below y340, diamond lower point ends by y1110. Keep all artwork, sparks and drifting snow ABOVE y1120, outside the rules area.
Bottom cream panel is continuous; two exact rules lines at y1275 and y1335, 43-48px expressive brush lettering, four-line reserve x110..914 y1185..1445. No extra labels or symbols, no species badge on a skill.
Verbatim title: "떼거리 돌격". Category: "고블린 · 졸개 돌진". Rules line1: "졸개 전원이 한 곳으로 돌진합니다.". Rules line2: "졸개가 많을수록 셉니다.". Preserve spaces, middle dots and full stops. All text is brush-ink as image1 with the DIAGRAM'S SIZE AND POSITION. Single complete upright 1024x1536 RGBA, rounded rectangular card, transparent outside corners only, opaque interior. Medieval-based fantasy winter lodge region, familiar fantasy adaptations preserving medieval daily life and atmosphere.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_rush-typography-v03.png`
SHA-256: `8aff1d606671499d7517114e73db3d1d575ddd20a60a7b278bf4f19649a8998d`

## shiny_lure · typography-v03

채택: False · 사유: 분류가 제목 2줄 안전 영역에 남아 있어 배치 도식으로 제목 크기·분류 위치 재교정; 원화창 하단 안전 여백 복구본 선택

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/shiny_lure-layout-v02.png`
5. `output/goblin-cards-v01/layout-guides/shiny_lure.png`

```text
Edit image4 (shiny_lure illustrated skill card). Image1 is approved SKILL diamond frame; image2 same-role game style; image3 all goblin appearance references; image5 is a POSITION/SCALE DIAGRAM only. Keep image4's beautiful original artwork, materials, painterly ink texture, purple/black/cream frame, and thick black diamond with thin cream inner line. Do NOT use the diagram's plain rectangles or blank artwork. Its only purpose is TYPOGRAPHIC PLACEMENT.
Move the category DOWN: it is currently around y225, but must sit at y285 as in diagram image5. Enlarge the top cream title panel DOWN to y330. Keep small title centered at y125, visible glyph height 60-65px and width proportional, in expressive BLACK BRUSH lettering matching image1, NOT the diagram's sans-serif face. A tall EMPTY CREAM GAP between title and category reserves the SECOND TITLE LINE; copy the diagram's spacing exactly. Do not place category in this gap. Main art starts below y340, diamond lower point ends by y1110. Keep all artwork, sparks and drifting snow ABOVE y1120, outside the rules area.
Bottom cream panel is continuous; two exact rules lines at y1275 and y1335, 43-48px expressive brush lettering, four-line reserve x110..914 y1185..1445. No extra labels or symbols, no species badge on a skill.
Verbatim title: "반짝이 미끼". Category: "고블린 · 어그로 끌기". Rules line1: "밤에 던지면 적이 몰려듭니다.". Rules line2: "끝나면 터져 눈부시게 합니다.". Preserve spaces, middle dots and full stops. All text is brush-ink as image1 with the DIAGRAM'S SIZE AND POSITION. Single complete upright 1024x1536 RGBA, rounded rectangular card, transparent outside corners only, opaque interior. Medieval-based fantasy winter lodge region, familiar fantasy adaptations preserving medieval daily life and atmosphere.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/shiny_lure-typography-v03.png`
SHA-256: `44b5b2c14c08ed280ac81aa76878f8d7bf38b109ee13da54d322a5f52a4d1f9b`

## goblin_gang · brush-v04

채택: False · 사유: 배치 도식 적용본의 작은 산세리프 제목을 승인 화풍의 약65px 먹선 글자로 보완; 제목·본문이 과대 확대돼 미채택

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/01-character-nib.png`
2. `godot/assets/cards/warrior.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/goblin_gang-typography-v03.png`
5. `output/goblin-cards-v01/layout-guides/goblin_gang.png`

```text
Edit image4, ONLY the printed lettering style and title size. All panel outlines, title/category positions, goblin painting and badge stay as image4. Image1 APPROVED character card and image2 warrior show the required bold hand-brushed BLACK INK Korean lettering, with tapered irregular edges. Image3 goblin appearances. Image5 size/placement diagram only.
The title in image4 is too small, about 40px tall, and looks like a plain sans-serif font. Replace with expressive brush lettering "사촌 패거리", ENLARGED to visible glyph height 65px (about 1.6 times current title), centered x512,y125. Category remains near y285 and becomes 36-38px brush lettering "고블린 · 졸개 소환". Preserve the tall empty cream gap for a second title line. Rules centered y1275 and y1335 become 43px brush lettering: "밤에 땅에 놓으면 졸개가 몰려옵니다." and "졸개는 새벽에 돌아갑니다.". Keep every syllable, space and full stop. No other changes. Preserve room for four lines in bottom rules area. Entire artwork stays above y1120 and text safety x110..914 y1185..1445 remains clear.
Output one complete upright 1024x1536 RGBA card, round rectangular corners with transparent outside only, opaque interior. Medieval-based fantasy, preserving medieval daily life and atmosphere.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_gang-brush-v04.png`
SHA-256: `2f4801a8be0a418ab49cf6a8c99db33c38bc861c987b17f3ae3beffce054835c`

## dud_bomb · diamond-v04

채택: True · 사유: 제목판 확장으로 내려간 마름모 하단과 눈·장화가 설명 안전 영역에 닿아 원화창을 축소하고 아래 여백 복구

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/dud_bomb-typography-v03.png`
5. `output/goblin-cards-v01/geometry-guides/dud_bomb.png`

```text
Edit image4, ONLY the size/placement of the central artwork window and the top edge of the bottom cream panel. Keep its brush lettering, all wording, top title panel, lowered category, purple card and illustrated subject exactly. Image1 APPROVED diamond SKILL frame; image2 current same-role game style; image3 goblin appearance sheet. Image5 is a GEOMETRY GUIDE for where the diamond ends, not a style reference. Keep image4's painted style, never render plain diagram rectangles.
The diamond and illustration in image4 are TOO TALL and their bottom enters the text space. SHRINK the ENTIRE central picture with its diamond to a smaller 760×760 diamond footprint, maintaining subject proportions. Exact diamond vertices: TOP (512,340), LEFT (132,720), RIGHT (892,720), BOTTOM (512,1100). The BOTTOM TIP MUST MOVE UP about 100px compared with image4. The cream bottom panel expands UPWARD to y1110, a visibly larger blank cream margin above the rules. ALL artwork, snow, stars, goblin boots and thick diamond border end by y1110. Nothing at all may protrude below this edge. Below y1120 the center of the card is COMPLETELY CREAM, uninterrupted, no black point, shadow or bits of snow. Continuous clean text rectangle x110..914 y1185..1445 must be entirely available.
Preserve the two printed rules lines in the larger lower cream panel, centered y1275 and y1335: "밤에 던지면 좁게 터집니다." / "맞은 적이 잠깐 기절합니다.". Title "불발탄", category "고블린 · 기절", no extra slash or text. Single full upright 1024x1536 RGBA, slight rounded rectangle corners, transparent outside corners only. Bold tapering ink, medieval-based fantasy winter lodge region, familiar adaptations preserving medieval daily life and atmosphere.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/dud_bomb-diamond-v04.png`
SHA-256: `f7c29abc378a62b3f1dec25ff13eac83141eeaedbe966d4dc25cebb26628724c`

## goblin_firecracker · diamond-v04

채택: True · 사유: 제목판 확장으로 내려간 마름모 하단과 눈·장화가 설명 안전 영역에 닿아 원화창을 축소하고 아래 여백 복구

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/goblin_firecracker-typography-v03.png`
5. `output/goblin-cards-v01/geometry-guides/goblin_firecracker.png`

```text
Edit image4, ONLY the size/placement of the central artwork window and the top edge of the bottom cream panel. Keep its brush lettering, all wording, top title panel, lowered category, purple card and illustrated subject exactly. Image1 APPROVED diamond SKILL frame; image2 current same-role game style; image3 goblin appearance sheet. Image5 is a GEOMETRY GUIDE for where the diamond ends, not a style reference. Keep image4's painted style, never render plain diagram rectangles.
The diamond and illustration in image4 are TOO TALL and their bottom enters the text space. SHRINK the ENTIRE central picture with its diamond to a smaller 760×760 diamond footprint, maintaining subject proportions. Exact diamond vertices: TOP (512,340), LEFT (132,720), RIGHT (892,720), BOTTOM (512,1100). The BOTTOM TIP MUST MOVE UP about 100px compared with image4. The cream bottom panel expands UPWARD to y1110, a visibly larger blank cream margin above the rules. ALL artwork, snow, stars, goblin boots and thick diamond border end by y1110. Nothing at all may protrude below this edge. Below y1120 the center of the card is COMPLETELY CREAM, uninterrupted, no black point, shadow or bits of snow. Continuous clean text rectangle x110..914 y1185..1445 must be entirely available.
Preserve the two printed rules lines in the larger lower cream panel, centered y1275 and y1335: "밤에 던지면 크게 터집니다." / "가끔 아군도 그을립니다.". Title "고블린 폭죽", category "고블린 · 도박 폭발", no extra slash or text. Single full upright 1024x1536 RGBA, slight rounded rectangle corners, transparent outside corners only. Bold tapering ink, medieval-based fantasy winter lodge region, familiar adaptations preserving medieval daily life and atmosphere.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_firecracker-diamond-v04.png`
SHA-256: `a6fd89856ddf8379407c47112d6a7a2468987a90d615736cef3eb832bc22d0be`

## goblin_rush · diamond-v04

채택: True · 사유: 제목판 확장으로 내려간 마름모 하단과 눈·장화가 설명 안전 영역에 닿아 원화창을 축소하고 아래 여백 복구

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/goblin_rush-typography-v03.png`
5. `output/goblin-cards-v01/geometry-guides/goblin_rush.png`

```text
Edit image4, ONLY the size/placement of the central artwork window and the top edge of the bottom cream panel. Keep its brush lettering, all wording, top title panel, lowered category, purple card and illustrated subject exactly. Image1 APPROVED diamond SKILL frame; image2 current same-role game style; image3 goblin appearance sheet. Image5 is a GEOMETRY GUIDE for where the diamond ends, not a style reference. Keep image4's painted style, never render plain diagram rectangles.
The diamond and illustration in image4 are TOO TALL and their bottom enters the text space. SHRINK the ENTIRE central picture with its diamond to a smaller 760×760 diamond footprint, maintaining subject proportions. Exact diamond vertices: TOP (512,340), LEFT (132,720), RIGHT (892,720), BOTTOM (512,1100). The BOTTOM TIP MUST MOVE UP about 100px compared with image4. The cream bottom panel expands UPWARD to y1110, a visibly larger blank cream margin above the rules. ALL artwork, snow, stars, goblin boots and thick diamond border end by y1110. Nothing at all may protrude below this edge. Below y1120 the center of the card is COMPLETELY CREAM, uninterrupted, no black point, shadow or bits of snow. Continuous clean text rectangle x110..914 y1185..1445 must be entirely available.
Preserve the two printed rules lines in the larger lower cream panel, centered y1275 and y1335: "졸개 전원이 한 곳으로 돌진합니다." / "졸개가 많을수록 셉니다.". Title "떼거리 돌격", category "고블린 · 졸개 돌진", no extra slash or text. Single full upright 1024x1536 RGBA, slight rounded rectangle corners, transparent outside corners only. Bold tapering ink, medieval-based fantasy winter lodge region, familiar adaptations preserving medieval daily life and atmosphere.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_rush-diamond-v04.png`
SHA-256: `df2f6e95a6c99476256e221a7b27e69aa3739808c60745c08ae7879cab846d5d`

## shiny_lure · diamond-v04

채택: True · 사유: 제목판 확장으로 내려간 마름모 하단과 눈·장화가 설명 안전 영역에 닿아 원화창을 축소하고 아래 여백 복구

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
2. `godot/assets/cards/frost_rune.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/shiny_lure-typography-v03.png`
5. `output/goblin-cards-v01/geometry-guides/shiny_lure.png`

```text
Edit image4, ONLY the size/placement of the central artwork window and the top edge of the bottom cream panel. Keep its brush lettering, all wording, top title panel, lowered category, purple card and illustrated subject exactly. Image1 APPROVED diamond SKILL frame; image2 current same-role game style; image3 goblin appearance sheet. Image5 is a GEOMETRY GUIDE for where the diamond ends, not a style reference. Keep image4's painted style, never render plain diagram rectangles.
The diamond and illustration in image4 are TOO TALL and their bottom enters the text space. SHRINK the ENTIRE central picture with its diamond to a smaller 760×760 diamond footprint, maintaining subject proportions. Exact diamond vertices: TOP (512,340), LEFT (132,720), RIGHT (892,720), BOTTOM (512,1100). The BOTTOM TIP MUST MOVE UP about 100px compared with image4. The cream bottom panel expands UPWARD to y1110, a visibly larger blank cream margin above the rules. ALL artwork, snow, stars, goblin boots and thick diamond border end by y1110. Nothing at all may protrude below this edge. Below y1120 the center of the card is COMPLETELY CREAM, uninterrupted, no black point, shadow or bits of snow. Continuous clean text rectangle x110..914 y1185..1445 must be entirely available.
Preserve the two printed rules lines in the larger lower cream panel, centered y1275 and y1335: "밤에 던지면 적이 몰려듭니다." / "끝나면 터져 눈부시게 합니다.". Title "반짝이 미끼", category "고블린 · 어그로 끌기", no extra slash or text. Single full upright 1024x1536 RGBA, slight rounded rectangle corners, transparent outside corners only. Bold tapering ink, medieval-based fantasy winter lodge region, familiar adaptations preserving medieval daily life and atmosphere.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/shiny_lure-diamond-v04.png`
SHA-256: `914e7bc18dd09a0de2aa279e0d47ab9a9d12195a4133a58a9a493c232bc31e93`

## goblin_gang · title-v05

채택: True · 사유: brush-v04가 제목·본문을 과대 확대해 미채택. typography-v03의 제목 한 영역만 먹선 글자로 보완

실제 참고 입력:
1. `art/concepts/cards/roles-individual-v02/01-character-nib.png`
2. `godot/assets/cards/warrior.png`
3. `output/goblin-cards-v01/goblin-appearance-reference.png`
4. `art/cards/goblin-v01/drafts/goblin_gang-typography-v03.png`

```text
Edit IMAGE4 only inside the small TITLE word area x250..775, y75..180. Change just the title "사촌 패거리" into moderately sized Korean brush lettering, visible glyph height about 60 pixels, centered x512 y125. Images1 and2 show the Korean brush style; image3 is goblin appearance reference. Everything else in image4 must stay unchanged, including the SMALL rules lettering, the low category row at y285, empty cream gap, arched artwork and goblin badge. DO NOT enlarge or restyle the category or the two rules lines. DO NOT change any frame or artwork. Single 1024x1536 RGBA card, rounded rectangular corners transparent outside, opaque inside. Medieval-based fantasy.
```

가공 전 생성본: `art/cards/goblin-v01/drafts/goblin_gang-title-v05.png`
SHA-256: `857cb337fe478899eeeeb274fa4a062c7fb49271f0b85d741c3cc68fa16a471a`

## 납품 후처리

모든 가공 전 생성본을 drafts에 보존했다. 선택본의 RGB·먹선·프레임·인쇄 글자는 변경하지 않았다. 약한 내부 반투명을 불투명 카드지로 정규화하고 40px 라운드 모서리의 바깥을 투명 처리했다. 손패는 LANCZOS로 정확히 1/4 균등 축소했다. 미리보기·원본 크기 글자 검수 이미지는 원화 수정 없이 축소·배열·크롭했다.

한국어 인쇄 PNG 납품이며 다국어 동적 텍스트 구현을 의미하지 않는다.
