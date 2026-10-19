# 장비 카드 v01 · 실제 생성 프롬프트와 참고 입력

2026-10-19 · 내장 `image_gen`만 사용. 매 호출 `transparent_background=true`, 아래 파일들을 `referenced_image_paths`의 실제 이미지 입력으로 전달했다.

이미지 순서는 각 호출의 목록 순서다. 승인 장비·유물 PNG와 기존 `moonlit_charm`, `wolf_fang_pendant`, `old_spellbook`을 8회 모두 전달했다. `old_spellbook`은 질감 참고이며 마름모 창은 사용하지 않았다.

## rusty_longsword · initial

채택: False · 사유: 제목·분류·본문이 커 제목 2줄과 설명 4줄 여백 보완 필요

실제 참고 입력:
1. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/moonlit_charm.png`
3. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/wolf_fang_pendant.png`
4. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/old_spellbook.png`

```text
Use case: stylized-concept.
Create a production finished single equipment card for Witch's Lodge by adapting the supplied APPROVED equipment/relic card. The four supplied images are real references: image 1 is the AUTHORITATIVE shield-window frame/layout reference (04-relic-moonlit-charm); images 2 and 3 are current moonlit_charm and wolf_fang_pendant for painterly ink texture, palette and printing consistency; image 4 old_spellbook is texture/style ONLY, never copy its diamond frame.
Preserve image 1's full rectangular purple card stock, black variable-width curved ink waves, thin cream/gold inner shield outline, broad cream top name panel and SINGLE continuous broad cream bottom rules panel. Use the same shield-shaped artwork aperture (broad at shoulders, curving to a low central point), not a diamond, oval or rectangular picture.
Canvas exactly upright 1024x1536 (2:3), whole card fills the canvas, four slightly rounded corners with genuinely transparent pixels OUTSIDE the card only. Card interior opaque, no drop shadow or surrounding border/background.
MANDATORY safe layout: title field x110..914,y72..236 is broad and reserved for TWO lines at ~70px font/76px leading even though this title is short. Center the one-line title at y135; use the reference's bold expressive Korean ink lettering, do NOT enlarge title to fill both lines. Category is a separate centered line at y267..307, font ~38px. Main artwork extends from y330 to y1110; shield bottom point ends by y1110. Bottom cream rules panel x55..970,y1120..1495, uninterrupted. Its safe field x110..914,y1185..1445 must fit FOUR lines at 48px font/60px leading; print the requested TWO rules lines centered around y1275 and y1335 with generous blank cream margin above/below. No ink waves, ornament, badges, divider, frame point, leaves or object intrude into title/rules safe fields. No extra labels.
Setting: medieval-based fantasy, familiar fantasy adaptations allowed while keeping medieval daily life, materials and atmosphere. Winter forest and rustic lodge region. One equipment subject large and readable in shield center, simplified quiet background. Thick tapered black outlines, large clear color masses, strong readable light/shadow, restrained painterly printed texture, purple/indigo/lavender with cream paper and warm amber highlights, coherent with supplied cards. No photorealism, no UI symbols, no additional effects or numbers, no stats, no Latin text, no placeholder wording or watermark.
Render ONLY the exact Korean title, category, two rules lines below, preserving every syllable, spacing, full stop, and spaced middle dot ' · '.
Subject: A single old medieval longsword, vertically upright and tall, point downward, leather-wrapped hilt, simple cross-shaped guard, patches of rusty ochre on steel blade but a visibly sharp usable edge. Resting against a wooden weapon rack inside the lodge, a small cold snowy window in a quiet background. Entire sword silhouette fits inside shield and dominates picture. No person.
Text (verbatim):
Title: 녹슨 장검
Category: 장비 · 무기
Rules line 1: 용병에게 쥐여 줍니다.
Rules line 2: 공격이 강해집니다.
```

가공 전 생성본: `art/cards/equipment-v01/drafts/rusty_longsword-initial.png`
SHA-256: `d0ef0c1a6420695ea30aa4f5aec2fba06493b3a1dc4f4789cecaab6a4c666741`

## rusty_longsword · layout-attempt

채택: False · 사유: 좌표 지시만으로 글자 크기·분류 위치 보완이 충분하지 않아 직접 편집

실제 참고 입력:
1. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/moonlit_charm.png`
3. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/wolf_fang_pendant.png`
4. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/old_spellbook.png`

```text
Use case: stylized-concept.
Create a production finished single equipment card for Witch's Lodge by adapting the supplied APPROVED equipment/relic card. The four supplied images are real references: image 1 is the AUTHORITATIVE shield-window frame/layout reference (04-relic-moonlit-charm); images 2 and 3 are current moonlit_charm and wolf_fang_pendant for painterly ink texture, palette and printing consistency; image 4 old_spellbook is texture/style ONLY, never copy its diamond frame.
Preserve image 1's full rectangular purple card stock, black variable-width curved ink waves, thin cream/gold inner shield outline, broad cream top name panel and SINGLE continuous broad cream bottom rules panel. Use the same shield-shaped artwork aperture (broad at shoulders, curving to a low central point), not a diamond, oval or rectangular picture.
Canvas exactly upright 1024x1536 (2:3), whole card fills the canvas, four slightly rounded corners with genuinely transparent pixels OUTSIDE the card only. Card interior opaque, no drop shadow or surrounding border/background.
MANDATORY safe layout: title field x110..914,y72..236 is broad and reserved for TWO lines at ~70px font/76px leading even though this title is short. Center the one-line title at y135; use the reference's bold expressive Korean ink lettering, do NOT enlarge title to fill both lines. Category is a separate centered line at y267..307, font ~38px. Main artwork extends from y330 to y1110; shield bottom point ends by y1110. Bottom cream rules panel x55..970,y1120..1495, uninterrupted. Its safe field x110..914,y1185..1445 must fit FOUR lines at 48px font/60px leading; print the requested TWO rules lines centered around y1275 and y1335 with generous blank cream margin above/below. No ink waves, ornament, badges, divider, frame point, leaves or object intrude into title/rules safe fields. No extra labels.
Setting: medieval-based fantasy, familiar fantasy adaptations allowed while keeping medieval daily life, materials and atmosphere. Winter forest and rustic lodge region. One equipment subject large and readable in shield center, simplified quiet background. Thick tapered black outlines, large clear color masses, strong readable light/shadow, restrained painterly printed texture, purple/indigo/lavender with cream paper and warm amber highlights, coherent with supplied cards. No photorealism, no UI symbols, no additional effects or numbers, no stats, no Latin text, no placeholder wording or watermark.
Render ONLY the exact Korean title, category, two rules lines below, preserving every syllable, spacing, full stop, and spaced middle dot ' · '.
Subject: A single old medieval longsword, vertically upright and tall, point downward, leather-wrapped hilt, simple cross-shaped guard, patches of rusty ochre on steel blade but a visibly sharp usable edge. Resting against a wooden weapon rack inside the lodge, a small cold snowy window in a quiet background. Entire sword silhouette fits inside shield and dominates picture. No person.
Text (verbatim):
Title: 녹슨 장검
Category: 장비 · 무기
Rules line 1: 용병에게 쥐여 줍니다.
Rules line 2: 공격이 강해집니다.
CRITICAL PRODUCTION LAYOUT OVERRIDE: The approved reference has oversized lettering; preserve its SHAPES but REDUCE the lettering. All short titles MUST be typeset at 70px and category at 38px, rules at 48px, never 90-110px. The title box top/bottom must enclose a clean rectangular two-line interior x110..914 y72..236, so extend the cream title panel down to y330 and keep its top inner edge above y60. Title one line at y125, category baseline near y296, generous blank cream space around title. Place two rule lines with 60px line spacing and approximately 48px font at y1275 and y1335. Both lines together occupy ONLY about 120px, not 200px. Rules panel starts at y1120, inner cream spans x110..914 and y1185..1445 with no interruptions. Shield tip stays above y1110. This careful whitespace is mandatory. Match approved frame curvature, only its panel heights/letter size adjust to these coordinates.
```

가공 전 생성본: `art/cards/equipment-v01/drafts/rusty_longsword-layout-attempt.png`
SHA-256: `e29b07a2d847baa4c785cc6c939d9ce7112026cbd23164ae6a505e7839d80998`

## rusty_longsword · final-generated

채택: True · 사유: 생성본 직접 편집으로 제목·본문 축소 및 상단 패널 확대

실제 참고 입력:
1. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/moonlit_charm.png`
3. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/wolf_fang_pendant.png`
4. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/old_spellbook.png`
5. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/cards/equipment-v01/drafts/rusty_longsword-layout-attempt.png`

```text
Edit image 5 (rusty sword equipment card). Images 1-4 are actual required references: image 1 approved equipment/relic shield frame is authoritative; 2 moonlit_charm and 3 wolf_fang_pendant style; 4 old_spellbook printing style ONLY, do not use diamond. Preserve sword art and same purple/black/cream SHIELD frame, but make these REQUIRED layout changes:
1. Title lettering "녹슨 장검" is MUCH TOO LARGE. Reduce its visible height from about 100px to 65px. Move the single title line center to (512,120).
2. Category EXACTLY "장비 · 무기" is TOO HIGH UP. Move it DOWN so it occupies y270..306 (38px font). Enlarge upper cream panel down to y330, keeping a wide two-line TITLE blank area x110..914,y72..236. NO sword pommel, border or ornament in this rectangular area.
3. Rules letters are TOO LARGE and spaced TOO FAR apart. Reduce both lines to 48px lettering; baseline spacing 60px. Exact line 1 "용병에게 쥐여 줍니다." centered around y1275; line 2 "공격이 강해집니다." centered around y1335. Leave all cream area x110..914,y1185..1445 clean for FOUR lines of text. No other lettering/decoration.
4. Keep the shield bottom above y1110. Keep the entire upright sword inside art window from y340..1110. Enclose the picture with same curved shield outline as image 1.
Medieval-based fantasy winter lodge, painterly print ink with thick tapered black outlines. Single full card exactly 1024x1536, slightly round four corners, outside corner TRANSPARENT, interior opaque. Do not change wording, add text, or add badges. The edit must visibly reduce the lettering size and give substantially more whitespace than image 5.
```

가공 전 생성본: `art/cards/equipment-v01/drafts/rusty_longsword-final-generated.png`
SHA-256: `2e3f522e1cc101c4e73432638f6ffa1d49cb2eccbf67dac708fe3cec4171558c`

## oak_staff · initial

채택: False · 사유: 제목과 분류가 붙어 제목 2줄 여백을 보완

실제 참고 입력:
1. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
2. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/moonlit_charm.png`
3. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/wolf_fang_pendant.png`
4. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/old_spellbook.png`
5. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/cards/equipment-v01/rusty_longsword.png`

```text
Use case: stylized-concept. Adapt IMAGE 5, the newly spaced equipment card, changing ONLY the equipment picture and exact printed wording. Image 1 is the required approved equipment/relic shield frame, images 2 moonlit_charm and 3 wolf_fang_pendant are actual current game texture/style references; image 4 old_spellbook is style ONLY (ignore its diamond). Image 5 supplies the production whitespace correction to image 1; copy its proportions, cream panel sizes, small lettering sizes and placements exactly. Do not copy image 5's sword or wording.
Single 1024x1536 upright 2:3 full card, slight rounded corners, transparent outside four corners ONLY, interior opaque. Same purple rectangular card, broad cream top panel, thick tapered black ink waves, cream/gold SHIELD artwork border, low point ending above y1110, single continuous spacious cream rules panel. Preserve roomy title field x110..914,y72..236 for TWO lines, category separate y267..307, and clean rules field x110..914,y1185..1445 for FOUR lines. Print SHORT title using 70px lettering, category 38px, rules 48px with 60px line spacing; DON'T enlarge type to fill spaces. No embellishments in these safe fields.
Subject to replace sword: One tall knotted oak-branch witch's staff, carved from a natural branch, vertical with a slight organic curve. A few unmistakable lobed oak leaves and acorns remain near the top. A restrained soft purple magical glow gathers at the tip; simple cord and tiny bone charm. Rustic lodge wood and a glimpse of snowy winter forest, subdued background. Whole staff within shield, no person.
Keep medieval-based fantasy winter lodge atmosphere, with familiar fantasy adaptation but medieval materials and daily life. Large clear item silhouette, controlled quiet background, bold tapered ink contours and painterly print texture matching all references, purple/indigo winter colors with warm amber accents. No numerical stats or extra labels; no placeholder or watermark.
ONLY EXACT TEXT (preserve spaces, full stops and spaced middle dot ' · '):
Title: 참나무 지팡이
Category: 장비 · 무기
Rules line 1: 마녀가 손에 쥡니다.
Rules line 2: 마법탄이 강해집니다.
Most important: preserve image 5's corrected spacious panels and smaller lettering, keep shield window. No additional words or badges.
```

가공 전 생성본: `art/cards/equipment-v01/drafts/oak_staff-initial.png`
SHA-256: `7a8f8b59b479b455a907ff16bd94abd8186a1403eb225887bd77ae4d089d5e3f`

## oak_staff · final-generated

채택: True · 사유: 제목·본문 축소, 분류 하향 및 상단 패널 확대

실제 참고 입력:
1. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/cards/equipment-v01/drafts/oak_staff-initial.png`
2. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
3. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/moonlit_charm.png`
4. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/wolf_fang_pendant.png`
5. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/old_spellbook.png`

```text
Edit ONLY the FIRST image, the oak staff card. Other four images are required real references: image 2 APPROVED equipment/relic shield layout, image 3 moonlit_charm and image 4 wolf_fang_pendant for current painterly print style, image 5 old_spellbook for texture ONLY, do not use its diamond.
Preserve the oak staff, oak leaves/acorns, subtle purple magic, medieval winter lodge picture and shield aperture, purple stock and tapered black ink waves. Correct only typography/panel spacing:
The top cream panel must become TALLER: its bottom edge at center must go DOWN from y285 to y330. The title "참나무 지팡이" is MUCH TOO LARGE. Reduce its visible lettering height to 65-70px (about 75% current size), center in the title field around y140. Keep the rectangular TWO-line title safe field x110..914,y72..236 free of category or borders. Move category EXACTLY "장비 · 무기" DOWN from y230 to y285, small 38px lettering. There must be a big blank cream gap between title and category. Keep curved cream top panel corners outside the safe field.
Rules also need to be smaller: EXACT first line "마녀가 손에 쥡니다.", second line "마법탄이 강해집니다." using 48px lettering with ~60px line spacing around y1275 and y1335. Do not enlarge letters to fill the wide panel. Keep clean cream field x110..914,y1185..1445 roomy enough for FOUR lines, no decoration or divider in it. Keep shield point above y1110.
Single full rectangular 1024x1536 upright card with slightly round corners, genuine TRANSPARENT pixels outside corners ONLY, opaque card interior. Preserve Korean wording perfectly, no extra text, numbers or icons.
```

가공 전 생성본: `art/cards/equipment-v01/drafts/oak_staff-final-generated.png`
SHA-256: `312cce67a2c01145f0dc9e44dd4c18b4432e942fd8a72e2b81d5ad348d6c6fcb`

## quilted_gambeson · final-generated

채택: True · 사유: 첫 생성 채택

실제 참고 입력:
1. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/cards/equipment-v01/rusty_longsword.png`
2. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
3. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/moonlit_charm.png`
4. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/wolf_fang_pendant.png`
5. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/old_spellbook.png`

```text
EDIT THE FIRST IMAGE (the rusty sword card), preserving its corrected spacious frame and SMALL type, replacing only the pictured item and exact lettering. Images 2-5 are actual reference inputs: 2 approved equipment/relic frame, 3 current moonlit_charm, 4 wolf_fang_pendant, 5 old_spellbook texture only, ignore its diamond. Preserve the FIRST image's shield-shaped window, purple card, black waves and broad cream panels. DO NOT use the old references' larger lettering.
Replace the sword scene with: A thick medieval gambeson padded cloth armor coat, with large clearly readable diamond quilting, faded winter blue-gray cloth, simple brown leather tie closures down the front. Sleeves and padded torso form a distinctive broad silhouette, hanging empty on a plain wooden hanger from a lodge wall hook. Soft amber light, restrained dark rustic wooden backdrop. No wearer, no metal plate armor.
Korean lettering EXACTLY: title "누빈 솜옷", separate category line "장비 · 방어구", rules line 1 "누구에게나 입힙니다.", rules line 2 "체력이 늘고 덜 다칩니다.".
IMPORTANT: make the top cream panel taller so its lower edge at center is y340 (22% of image height). Title is SMALL, 70px, centered near y130. Reserve x110..914,y72..236 entirely for the title's TWO-line space. Put category much LOWER at y285 with 38px lettering. This creates a conspicuous BLANK GAP between the title and category.
Bottom cream rules panel has same large dimensions as first image; exact two rules lines SMALL 48px with 60px line spacing near y1275 and y1335, leaving enough clean room for FOUR lines x110..914,y1185..1445.
No picture/frame/decoration intrudes into text areas. Shield tip above y1110. Medieval-based fantasy winter lodge, hand painted bold tapered ink printing texture. One full rectangular 1024x1536 (2:3) card, round four corners, genuine transparency ONLY outside corners, opaque interior. No stats or additional words.
```

가공 전 생성본: `art/cards/equipment-v01/drafts/quilted_gambeson-final-generated.png`
SHA-256: `cb969e712d439dcde802f8216aebf6888cc14dfaa2b009006200794c4abdc9df`

## traveler_boots · final-generated

채택: True · 사유: 첫 생성 채택

실제 참고 입력:
1. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/cards/equipment-v01/rusty_longsword.png`
2. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
3. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/moonlit_charm.png`
4. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/wolf_fang_pendant.png`
5. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/old_spellbook.png`

```text
EDIT THE FIRST IMAGE (the rusty sword card), preserving its corrected spacious frame and SMALL type, replacing only the pictured item and exact lettering. Images 2-5 are actual reference inputs: 2 approved equipment/relic frame, 3 current moonlit_charm, 4 wolf_fang_pendant, 5 old_spellbook texture only, ignore its diamond. Preserve the FIRST image's shield-shaped window, purple card, black waves and broad cream panels. DO NOT use the old references' larger lettering.
Replace the sword scene with: ONE PAIR of worn medieval leather travel boots as a single equipment subject, thick broad toes, folded cuffs, visible few hand-stitched repairs and ankle leather ties. Brown weathered leather marked with mud and small clumps of snow. Standing together by a rustic lodge threshold, quiet snowy forest beyond. Distinct large boot silhouettes, no person, no modern zippers.
Korean lettering EXACTLY: title "나그네 장화", separate category line "장비 · 장신구", rules line 1 "누구에게나 신깁니다.", rules line 2 "더 빨리 걷습니다.".
IMPORTANT: make the top cream panel taller so its lower edge at center is y340 (22% of image height). Title is SMALL, 70px, centered near y130. Reserve x110..914,y72..236 entirely for the title's TWO-line space. Put category much LOWER at y285 with 38px lettering. This creates a conspicuous BLANK GAP between the title and category.
Bottom cream rules panel has same large dimensions as first image; exact two rules lines SMALL 48px with 60px line spacing near y1275 and y1335, leaving enough clean room for FOUR lines x110..914,y1185..1445.
No picture/frame/decoration intrudes into text areas. Shield tip above y1110. Medieval-based fantasy winter lodge, hand painted bold tapered ink printing texture. One full rectangular 1024x1536 (2:3) card, round four corners, genuine transparency ONLY outside corners, opaque interior. No stats or additional words.
```

가공 전 생성본: `art/cards/equipment-v01/drafts/traveler_boots-final-generated.png`
SHA-256: `c427ab4ea88a2bb61d90a0f06785eede510b9f13705ae8d1bf687066d5288945`

## rowan_charm · final-generated

채택: True · 사유: 첫 생성 채택

실제 참고 입력:
1. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/cards/equipment-v01/rusty_longsword.png`
2. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png`
3. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/moonlit_charm.png`
4. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/wolf_fang_pendant.png`
5. `C:/Users/Loadcomplete/Documents/ChatGPT/마녀산장/witchs-lodge/godot/assets/cards/old_spellbook.png`

```text
EDIT THE FIRST IMAGE (the rusty sword card), preserving its corrected spacious frame and SMALL type, replacing only the pictured item and exact lettering. Images 2-5 are actual reference inputs: 2 approved equipment/relic frame, 3 current moonlit_charm, 4 wolf_fang_pendant, 5 old_spellbook texture only, ignore its diamond. Preserve the FIRST image's shield-shaped window, purple card, black waves and broad cream panels. DO NOT use the old references' larger lettering.
Replace the sword scene with: One suspended folk rowan protective charm: two natural rowan twigs visibly crossed and lashed at their center with RED THREAD, a cluster of bright RED ROWAN BERRIES attached, hanging down from a simple cord. Subtle warm amber protective glow, dark purple lodge timbers and quiet snowy forest glimpsed behind. A humble natural medieval folk talisman, not an ornate metal pendant; large clear crossed-twig-and-berry silhouette, no person.
Korean lettering EXACTLY: title "마가목 부적", separate category line "장비 · 장신구", rules line 1 "누구에게나 걸어 줍니다.", rules line 2 "상처가 천천히 아뭅니다.".
IMPORTANT: make the top cream panel taller so its lower edge at center is y340 (22% of image height). Title is SMALL, 70px, centered near y130. Reserve x110..914,y72..236 entirely for the title's TWO-line space. Put category much LOWER at y285 with 38px lettering. This creates a conspicuous BLANK GAP between the title and category.
Bottom cream rules panel has same large dimensions as first image; exact two rules lines SMALL 48px with 60px line spacing near y1275 and y1335, leaving enough clean room for FOUR lines x110..914,y1185..1445.
No picture/frame/decoration intrudes into text areas. Shield tip above y1110. Medieval-based fantasy winter lodge, hand painted bold tapered ink printing texture. One full rectangular 1024x1536 (2:3) card, round four corners, genuine transparency ONLY outside corners, opaque interior. No stats or additional words.
```

가공 전 생성본: `art/cards/equipment-v01/drafts/rowan_charm-final-generated.png`
SHA-256: `750c71e8825acb7ac2ab648f92038a34c2d6921c2c533fa7986a7cb3e2c0cce3`

## 납품 후처리

생성 원본 8개를 drafts에 그대로 보존했다. 채택한 5개의 RGB와 글자를 그대로 유지하고, 약한 내부 반투명을 불투명 카드지로 정규화했다. 40px 라운드 외곽은 4배 해상도 마스크로 안티앨리어싱했다. 게임용은 원본 크기 1024×1536, 손패용은 LANCZOS로 256×384로만 균등 축소했다. 원화·글자에 코드 합성이나 교체는 하지 않았다.

제목 2줄·설명 4줄 여백과 한글 문구는 1:1 검수 이미지 및 전체 시트로 직접 확인한다. 모든 언어의 동적 텍스트 수용이나 픽셀 단위 프레임 마스크 검증을 의미하지 않는다.
