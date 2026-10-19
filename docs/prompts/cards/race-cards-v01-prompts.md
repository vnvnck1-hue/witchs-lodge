# 종족·언데드·화합 카드 v01 · 실제 생성 프롬프트

내장 image_gen만 사용. 모든 호출 transparent_background=true. 참고 시트는 원본 비율 유지 배열이며 원본 초상은 변경하지 않음.

## dream_journal · v01

채택: False · 이유: Initial generation

- `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
- `godot/assets/cards/graz_whistle.png`
- `output/race-cards-v01/references/fairy.png`

```text
Use case: stylized-concept. Produce ONE final Korean game card by adapting the supplied approved role card. 1024x1536 upright 2:3 RGBA, gently rounded RECTANGULAR card, transparent outside corners, opaque printed card stock.
INPUT1: APPROVED role/frame reference, preserve purple stock, tapered black ink waves, cream panels, painterly printed texture and frame skeleton. INPUT2: current game same-role card, use its smaller typography and roomy spacing. Remaining inputs: racial appearance or mood references, never copy their text.
ROLE: EQUIPMENT/RELIC tall shield-shaped art window, lower tip ends by y1110. No race badge.
WORLD: medieval-based fantasy, familiar fantasy adaptations retaining medieval everyday life/materials and atmosphere. Winter conifer forest/lodge region, lavender snow and warm amber lantern/campfire.
ILLUSTRATION: - **꿈 기록장(장비, 마녀용):** 잎사귀 표지에 씨앗 매듭 끈을 두른 작은 수첩, 펼친 장에서 희미한 별빛이 피어오른다. 방패형 창에 세로로.
RACE/MOOD: pale green, small winged fairies, leaf/seed/thistle forms, seed motifs. Motifs subtle inside artwork; never add a race badge except character/summon.
LAYOUT IS CRITICAL: generous cream title area extends to y325; reserve x110..914,y72..236 for TWO lines even for a short title. Title brush letters about 70px, visually restrained, do NOT copy oversized title from INPUT1. Classification separate at center y285, about 38px. All illustration/frame points and badges end by y1110. One large continuous cream rules panel x55..970,y1120..1495, with clean undecorated FOUR-line capacity x110..914,y1185..1445. Body ink letters about 40px; two rules centered near y1270 and1330. Keep blank margin, no artwork/ornament/divider in text areas. Clear silhouettes at hand size.
Replace all text with these EXACT strings, preserving spelling, spaces, punctuation and spaced middle dots:
TITLE: 꿈 기록장
CLASSIFICATION: 장비 · 마녀 장신구 · 요정
RULE LINE 1: 마녀가 지닙니다.
RULE LINE 2: 아침에 뽑을 카드를 골라 받습니다.
No additional words or numbers or stats or prices or placeholder text. No readable writing inside illustration. For corpse, print card title 시체 but no personal character name. Entire card fully visible, no mockup or external shadow.
```

가공 전 원본: `art/cards/race-cards-v01/drafts/dream_journal-v01.png`

## dream_journal · v02

채택: False · 이유: Layout guide correction: two-line title reserve, classification and rules positions.

- `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
- `godot/assets/cards/graz_whistle.png`
- `output/race-cards-v01/references/fairy.png`
- `art/cards/race-cards-v01/dream_journal.png`
- `output/race-cards-v01/layout-guides/dream_journal.png`

```text
Edit INPUT4. Preserve its illustration, ink-brush style, exact Korean wording, and EQUIPMENT/RELIC tall shield-shaped art window, lower tip ends by y1110. No race badge. INPUT1 is approved frame, INPUT2 current game style, INPUT3 fairy portraits. INPUT5 is ONLY a precise TYPOGRAPHY/LAYOUT GUIDE, not a style reference. Match INPUT5 text size/centers and clear panel heights, but retain INPUT4 painted cream paper and tapering brush letters, never render diagram rectangles or sans-serif text.
Current classification is TOO HIGH, interfering with a second title line. SHRINK title to guide size (~70px) centered y150, MOVE CLASSIFICATION DOWN to center y285. Extend cream top panel bottom to y330. Empty title rectangle x110..914 y72..236 must have room for 2 lines. The artwork starts y340. Rescale/reframe the illustration between y340 and y1100, preserving proportions. Frame tip and all art end by y1110. Continuous cream lower panel begins y1120; x110..914 y1185..1445 has no decorative ink at all. Rules about 40px at y1270 and y1330, exactly matching guide placement. Keep generous unused blank space.
Exact TITLE "꿈 기록장", CLASSIFICATION "장비 · 마녀 장신구 · 요정", RULE1 "마녀가 지닙니다.", RULE2 "아침에 뽑을 카드를 골라 받습니다.". No added writing or numbers. 
1024x1536 full mildly rounded rectangular RGBA card; transparent only outside corners, opaque stock. Medieval-based fantasy with medieval daily life and atmosphere.
```

가공 전 원본: `art/cards/race-cards-v01/drafts/dream_journal-v02.png`

## dream_journal · v03

채택: True · 이유: Explicit category downshift after v02 left it too high.

- `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
- `godot/assets/cards/graz_whistle.png`
- `output/race-cards-v01/references/fairy.png`
- `art/cards/race-cards-v01/dream_journal.png`
- `output/race-cards-v01/layout-guides/dream_journal.png`

```text
Edit INPUT4. Preserve its illustration, ink-brush style, exact Korean wording, and EQUIPMENT/RELIC tall shield-shaped art window, lower tip ends by y1110. No race badge. INPUT1 is approved frame, INPUT2 current game style, INPUT3 fairy portraits. INPUT5 is ONLY a precise TYPOGRAPHY/LAYOUT GUIDE, not a style reference. Match INPUT5 text size/centers and clear panel heights, but retain INPUT4 painted cream paper and tapering brush letters, never render diagram rectangles or sans-serif text.
Current classification is TOO HIGH, interfering with a second title line. SHRINK title to guide size (~70px) centered y150, MOVE CLASSIFICATION DOWN to center y285. Extend cream top panel bottom to y330. Empty title rectangle x110..914 y72..236 must have room for 2 lines. The artwork starts y340. Rescale/reframe the illustration between y340 and y1100, preserving proportions. Frame tip and all art end by y1110. Continuous cream lower panel begins y1120; x110..914 y1185..1445 has no decorative ink at all. Rules about 40px at y1270 and y1330, exactly matching guide placement. Keep generous unused blank space.
Exact TITLE "꿈 기록장", CLASSIFICATION "장비 · 마녀 장신구 · 요정", RULE1 "마녀가 지닙니다.", RULE2 "아침에 뽑을 카드를 골라 받습니다.". No added writing or numbers. 
1024x1536 full mildly rounded rectangular RGBA card; transparent only outside corners, opaque stock. Medieval-based fantasy with medieval daily life and atmosphere.
Essential single visible change: move the category text DOWN by 65px. Increase top cream panel height by 65px. Leave a large blank gap below the title for its second line. Keep the rest of the card unchanged.
```

가공 전 원본: `art/cards/race-cards-v01/drafts/dream_journal-v03.png`

## fae_swap · v01

채택: False · 이유: Title and rules oversized; category above required band.

- `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
- `godot/assets/cards/frost_rune.png`
- `output/race-cards-v01/references/fairy.png`

```text
Use case: stylized-concept. Make one finished Korean fantasy game card, 1024x1536 portrait 2:3, true RGBA, mildly rounded four corners and transparent outside corners. Adapt input 1, the APPROVED skill card: preserve purple stock, black variable-width ink waves, cream title/rules panels and the black diamond artwork frame with fine cream inner line. Input 2 is current game skill card for painterly print texture. Input 3 is a sheet of all seven fairy portraits: use their small winged leaf/seed/thistle fairy identity, pale green accent and subtle seed motifs ONLY inside artwork. Never add a race badge to a skill card.
Set the artwork in a medieval-based fantasy world, keeping medieval everyday materials and atmosphere with familiar fantasy adaptations, snowy conifer forest and warm lantern light. Replace illustration with a tiny fairy's TWO hands exchanging a hovering acorn and rusty iron button; glowing seeds scatter between them with a single wisp of dark violet smoke. Action at diamond center.
Critical layout at 1024x1536: title reserve x110..914 y72..236 for TWO lines, title approximately 70px and centered, not oversized; classification separate at y267..307 approximately 38px. Diamond top BELOW classification at y340, sides around y700, bottom ends no lower than y1090. One continuous cream rules panel x55..970 y1120..1495; clean text safe area x110..914 y1185..1445 for FOUR lines, even though these rules use two sentences. Body approximately 40px, centered within width, with generous unused space. No art, ornament, badge, line or diamond point may intrude into either text safe area.
Replace ALL old text with this exact Korean only:
TITLE: 요정의 맞바꿈
CLASSIFICATION: 요정 · 덱 조작
RULE LINE 1: 손패 한 장을 다른 계열 카드로 바꿉니다.
RULE LINE 2: 가끔 침식 카드가 옵니다.
No numbers, costs, statistics, placeholder text, extra effects or any other lettering. Preserve exact spelling, spaces, punctuation and spaced middle dots. Large clear silhouette and painterly ink, not photorealism. Entire rectangular card fully visible; no mockup, no surrounding shadow.
```

가공 전 원본: `art/cards/race-cards-v01/drafts/fae_swap-v01.png`

## fae_swap · v02

채택: True · 이유: Reduce title and rules lettering; expand title area and lower classification.

- `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
- `godot/assets/cards/goblin_firecracker.png`
- `output/race-cards-v01/references/fairy.png`
- `C:\Users\vnvnc\.codex\generated_images\01a1547c-32d9-7102-b3e4-a8dfa41bef37\exec-3fde5345-cec7-4d67-90bf-c8db6b3c8f94.png`

```text
Edit input4 (요정의 맞바꿈) to fix ONLY typography sizing and layout spacing, preserving illustration and Korean spelling. Input1 approved skill frame; input2 current skill for correct enlarged title panel and lowered classification; input3 fairy appearance references. Match input2's panel heights. 
Reduce title lettering to 65% of its current size, center in x110..914,y72..236. Enlarge cream title panel downward to y325. Move classification down to center y285, 38px letters. Reserve ample space for a future two-line title.
Move diamond TOP to (512,340), LEFT (132,720), RIGHT (892,720), BOTTOM (512,1100); keep all frame and art above y1120. Preserve action, acorn, button, hands and fairy accents.
Reduce body lettering to 75% of current size, center the two rules at y1270 and y1330, entirely within x110..914. Bottom cream panel must have four-line capacity x110..914,y1185..1445, with zero decoration inside it. Keep lively tapering Korean ink brush lettering, not generic sans-serif.
Exact title: 요정의 맞바꿈
Exact category: 요정 · 덱 조작
Exact rules: 손패 한 장을 다른 계열 카드로 바꿉니다.
가끔 침식 카드가 옵니다.
No other text, no badge, numbers or stats. Medieval-based fantasy keeping medieval everyday atmosphere, 1024x1536 RGBA, mild rounded corners transparent outside.
```

가공 전 원본: `art/cards/race-cards-v01/drafts/fae_swap-v02.png`

## fae_swap · v03

채택: False · 이유: Layout guide correction: title reserve and lower classification.

- `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
- `godot/assets/cards/goblin_firecracker.png`
- `output/race-cards-v01/references/fairy.png`
- `art/cards/race-cards-v01/fae_swap.png`
- `output/race-cards-v01/layout-guides/fae_swap.png`

```text
Edit INPUT4. Preserve its illustration, ink-brush style, exact Korean wording, and SKILL diamond black frame with fine cream inner stroke. Diamond top (512,340), left (132,720), right (892,720), bottom (512,1100), no race badge. INPUT1 is approved frame, INPUT2 current game style, INPUT3 fairy portraits. INPUT5 is ONLY a precise TYPOGRAPHY/LAYOUT GUIDE, not a style reference. Match INPUT5 text size/centers and clear panel heights, but retain INPUT4 painted cream paper and tapering brush letters, never render diagram rectangles or sans-serif text.
Current classification is TOO HIGH, interfering with a second title line. SHRINK title to guide size (~70px) centered y150, MOVE CLASSIFICATION DOWN to center y285. Extend cream top panel bottom to y330. Empty title rectangle x110..914 y72..236 must have room for 2 lines. The artwork starts y340. Rescale/reframe the illustration between y340 and y1100, preserving proportions. Frame tip and all art end by y1110. Continuous cream lower panel begins y1120; x110..914 y1185..1445 has no decorative ink at all. Rules about 40px at y1270 and y1330, exactly matching guide placement. Keep generous unused blank space.
Exact TITLE "요정의 맞바꿈", CLASSIFICATION "요정 · 덱 조작", RULE1 "손패 한 장을 다른 계열 카드로 바꿉니다.", RULE2 "가끔 침식 카드가 옵니다.". No added writing or numbers. 
1024x1536 full mildly rounded rectangular RGBA card; transparent only outside corners, opaque stock. Medieval-based fantasy with medieval daily life and atmosphere.
MOST IMPORTANT visible change: classification must move DOWN by 70 pixels from input4. Leave a big blank cream gap between title and category. The top cream panel must visibly grow downward, taking space from the picture. This is the purpose of this edit.
```

가공 전 원본: `art/cards/race-cards-v01/drafts/fae_swap-v03.png`

## forest_promise · v01

채택: False · 이유: Initial generation

- `art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`
- `godot/assets/cards/guest_invitation.png`
- `output/race-cards-v01/references/fairy.png`

```text
Use case: stylized-concept. Edit INPUT2 into ONE new final Korean game card, replacing ONLY its subject and text, KEEP its spacious panel proportions. INPUT1 is the mandatory approved frame skeleton reference. 1024x1536 upright 2:3 RGBA, gently rounded RECTANGULAR card, transparent outside corners, opaque printed card stock.
INPUT1: APPROVED role/frame reference, preserve purple stock, tapered black ink waves, cream panels, painterly printed texture and frame skeleton. INPUT2: current game same-role card, use its smaller typography and roomy spacing. Remaining inputs: racial appearance or mood references, never copy their text.
ROLE: EVENT broad scene window, restrained folded banner accents outside title, one uninterrupted lower cream panel. NO central arrows, branching motif, V-notch or split rules boxes.
WORLD: medieval-based fantasy, familiar fantasy adaptations retaining medieval everyday life/materials and atmosphere. Winter conifer forest/lodge region, lavender snow and warm amber lantern/campfire.
ILLUSTRATION: - **숲의 약속(사건):** 눈 덮인 숲 공터에서 요정이 도끼 박힌 그루터기 앞에 서서 손가락을 걸어 약속을 청하는 장면, 뒤편에 빛나는 고목. 넓은 장면창.
RACE/MOOD: pale green, small winged fairies, leaf/seed/thistle forms, seed motifs. Motifs subtle inside artwork; never add a race badge except character/summon.
LAYOUT IS CRITICAL: generous cream title area extends to y325; reserve x110..914,y72..236 for TWO lines even for a short title. Title brush letters about 70px, visually restrained, do NOT copy oversized title from INPUT1. Classification separate at center y285, about 38px. All illustration/frame points and badges end by y1110. One large continuous cream rules panel x55..970,y1120..1495, with clean undecorated FOUR-line capacity x110..914,y1185..1445. Body ink letters about 40px; two rules centered near y1270 and1330. Keep blank margin, no artwork/ornament/divider in text areas. Clear silhouettes at hand size.
Replace all text with these EXACT strings, preserving spelling, spaces, punctuation and spaced middle dots:
TITLE: 숲의 약속
CLASSIFICATION: 사건 · 요정
RULE LINE 1: 약속하면 숲의 선물을 받습니다.
RULE LINE 2: 대신 다음날은 나무를 베지 못합니다.
No additional words or numbers or stats or prices or placeholder text. No readable writing inside illustration. For corpse, print card title 시체 but no personal character name. Entire card fully visible, no mockup or external shadow.
```

가공 전 원본: `art/cards/race-cards-v01/drafts/forest_promise-v01.png`

## forest_promise · v02

채택: True · 이유: Layout guide correction: title reserve and lower classification.

- `art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`
- `godot/assets/cards/guest_invitation.png`
- `output/race-cards-v01/references/fairy.png`
- `art/cards/race-cards-v01/forest_promise.png`
- `output/race-cards-v01/layout-guides/forest_promise.png`

```text
Edit INPUT4. Preserve its illustration, ink-brush style, exact Korean wording, and EVENT broad scene window, restrained folded banner accents outside title, one uninterrupted lower cream panel. NO central arrows, branching motif, V-notch or split rules boxes. INPUT1 is approved frame, INPUT2 current game style, INPUT3 fairy portraits. INPUT5 is ONLY a precise TYPOGRAPHY/LAYOUT GUIDE, not a style reference. Match INPUT5 text size/centers and clear panel heights, but retain INPUT4 painted cream paper and tapering brush letters, never render diagram rectangles or sans-serif text.
Current classification is TOO HIGH, interfering with a second title line. SHRINK title to guide size (~70px) centered y150, MOVE CLASSIFICATION DOWN to center y285. Extend cream top panel bottom to y330. Empty title rectangle x110..914 y72..236 must have room for 2 lines. The artwork starts y340. Rescale/reframe the illustration between y340 and y1100, preserving proportions. Frame tip and all art end by y1110. Continuous cream lower panel begins y1120; x110..914 y1185..1445 has no decorative ink at all. Rules about 40px at y1270 and y1330, exactly matching guide placement. Keep generous unused blank space.
Exact TITLE "숲의 약속", CLASSIFICATION "사건 · 요정", RULE1 "약속하면 숲의 선물을 받습니다.", RULE2 "대신 다음날은 나무를 베지 못합니다.". No added writing or numbers. Fairy's raised hand should offer only the little finger for a pinky promise, with index/middle/ring fingers folded, not a horns gesture.
1024x1536 full mildly rounded rectangular RGBA card; transparent only outside corners, opaque stock. Medieval-based fantasy with medieval daily life and atmosphere.
MOST IMPORTANT visible change: classification must move DOWN by 70 pixels from input4. Leave a big blank cream gap between title and category. The top cream panel must visibly grow downward, taking space from the picture. This is the purpose of this edit.
```

가공 전 원본: `art/cards/race-cards-v01/drafts/forest_promise-v02.png`

## thistle_oath · v01

채택: False · 이유: Initial generation

- `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
- `godot/assets/cards/graz_whistle.png`
- `output/race-cards-v01/references/fairy.png`

```text
Use case: stylized-concept. Edit INPUT2 into ONE new final Korean game card, replacing ONLY its subject and text, KEEP its spacious panel proportions. INPUT1 is the mandatory approved frame skeleton reference. 1024x1536 upright 2:3 RGBA, gently rounded RECTANGULAR card, transparent outside corners, opaque printed card stock.
INPUT1: APPROVED role/frame reference, preserve purple stock, tapered black ink waves, cream panels, painterly printed texture and frame skeleton. INPUT2: current game same-role card, use its smaller typography and roomy spacing. Remaining inputs: racial appearance or mood references, never copy their text.
ROLE: EQUIPMENT/RELIC tall shield-shaped art window, lower tip ends by y1110. No race badge.
WORLD: medieval-based fantasy, familiar fantasy adaptations retaining medieval everyday life/materials and atmosphere. Winter conifer forest/lodge region, lavender snow and warm amber lantern/campfire.
ILLUSTRATION: - **엉겅퀴 맹세(장비):** 보라 엉겅퀴 꽃과 가시 줄기를 엮어 만든 팔찌·매듭 장신구, 가시 끝에 서리.
RACE/MOOD: pale green, small winged fairies, leaf/seed/thistle forms, seed motifs. Motifs subtle inside artwork; never add a race badge except character/summon.
LAYOUT IS CRITICAL: generous cream title area extends to y325; reserve x110..914,y72..236 for TWO lines even for a short title. Title brush letters about 70px, visually restrained, do NOT copy oversized title from INPUT1. Classification separate at center y285, about 38px. All illustration/frame points and badges end by y1110. One large continuous cream rules panel x55..970,y1120..1495, with clean undecorated FOUR-line capacity x110..914,y1185..1445. Body ink letters about 40px; two rules centered near y1270 and1330. Keep blank margin, no artwork/ornament/divider in text areas. Clear silhouettes at hand size.
Replace all text with these EXACT strings, preserving spelling, spaces, punctuation and spaced middle dots:
TITLE: 엉겅퀴 맹세
CLASSIFICATION: 장비 · 장신구 · 요정
RULE LINE 1: 용병에게 걸어 줍니다.
RULE LINE 2: 맞은 적이 잠시 느려집니다.
No additional words or numbers or stats or prices or placeholder text. No readable writing inside illustration. For corpse, print card title 시체 but no personal character name. Entire card fully visible, no mockup or external shadow.
```

가공 전 원본: `art/cards/race-cards-v01/drafts/thistle_oath-v01.png`

## thistle_oath · v02

채택: True · 이유: Layout guide correction: title reserve and lower classification.

- `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
- `godot/assets/cards/graz_whistle.png`
- `output/race-cards-v01/references/fairy.png`
- `art/cards/race-cards-v01/thistle_oath.png`
- `output/race-cards-v01/layout-guides/thistle_oath.png`

```text
Edit INPUT4. Preserve its illustration, ink-brush style, exact Korean wording, and EQUIPMENT/RELIC tall shield-shaped art window, lower tip ends by y1110. No race badge. INPUT1 is approved frame, INPUT2 current game style, INPUT3 fairy portraits. INPUT5 is ONLY a precise TYPOGRAPHY/LAYOUT GUIDE, not a style reference. Match INPUT5 text size/centers and clear panel heights, but retain INPUT4 painted cream paper and tapering brush letters, never render diagram rectangles or sans-serif text.
Current classification is TOO HIGH, interfering with a second title line. SHRINK title to guide size (~70px) centered y150, MOVE CLASSIFICATION DOWN to center y285. Extend cream top panel bottom to y330. Empty title rectangle x110..914 y72..236 must have room for 2 lines. The artwork starts y340. Rescale/reframe the illustration between y340 and y1100, preserving proportions. Frame tip and all art end by y1110. Continuous cream lower panel begins y1120; x110..914 y1185..1445 has no decorative ink at all. Rules about 40px at y1270 and y1330, exactly matching guide placement. Keep generous unused blank space.
Exact TITLE "엉겅퀴 맹세", CLASSIFICATION "장비 · 장신구 · 요정", RULE1 "용병에게 걸어 줍니다.", RULE2 "맞은 적이 잠시 느려집니다.". No added writing or numbers. 
1024x1536 full mildly rounded rectangular RGBA card; transparent only outside corners, opaque stock. Medieval-based fantasy with medieval daily life and atmosphere.
MOST IMPORTANT visible change: classification must move DOWN by 70 pixels from input4. Leave a big blank cream gap between title and category. The top cream panel must visibly grow downward, taking space from the picture. This is the purpose of this edit.
```

가공 전 원본: `art/cards/race-cards-v01/drafts/thistle_oath-v02.png`

후처리: RGB·그림·글자 변경 없이 카드지 알파와 40px 라운드 모서리만 정규화. 손패는 System.Drawing HighQualityBicubic으로 정확히 1/4 균등 축소. 모든 생성본을 drafts에 보존.
