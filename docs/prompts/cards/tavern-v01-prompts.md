# 주점 카드·에린 초상 생성 프롬프트 v01

2026-10-20 · 근거: `docs/tavern-cards-v01.md`, `docs/card-design-guide.md`, 사용자 외형 지시.

상태: 내장 image_gen으로 에린 카드 생성을 시도했으나 `usage_limit_reached`가 반환되어 이미지 출력은 0장이다. 도구가 안내한 한도 초기화 시각은 **2026-10-20 13:56:01 한국시간**이다. 아래는 실행 준비가 된 최종 프롬프트이며 완성 이미지가 아니다. 별도 API 방식은 사용자 선택 전에는 실행하지 않는다.

제작 순서: 에린 카드 → 술 4종 → 에린 카드를 외형 참조로 술주정 → 같은 외형의 대화창 초상. 각 결과는 원본·손패 크기, 실제 알파, 한글 문구와 프레임 여백을 검수한 뒤 저장한다. 승인 PNG와 기존 배포 자산은 보존한다.

## drunken_erin — 술 주정뱅이 에린

실제 참조 입력: `C:\Users\Loadcomplete\Documents\ChatGPT\마녀산장\witchs-lodge\art\concepts\cards\roles-individual-v02\01-character-nib.png`

```text
Use case: stylized-concept. Deliver exactly ONE finished upright 1024x1536 RGBA PNG collectible game card, true 2:3, full card visible. Actual transparent alpha ONLY outside the gently rounded rectangular outer corners; opaque purple card stock, cream paper and all artwork.
Use supplied APPROVED role card as the direct frame, layout, brush typography and rendering reference. Preserve its purple stock, bold tapering black ink waves, cream title/classification/rules fields, painterly print texture, broad readable colors and role-specific artwork window. Set in a medieval-based fantasy world; fantasy adaptations allowed while preserving medieval daily life, tools, clothing and atmosphere. No modern items, no photorealism, no watermark.
Reserve x=110..914 y=72..236 for a two-line title, classification y=267..307. Rules panel is one uninterrupted cream area x=55..970 y=1120..1495 with text safe area x=110..914 y=1185..1445, enough for FOUR lines even if only two printed. No ornaments, badge, frame points or dividers inside text safe areas. Titles in bold Korean calligraphic brush type, rules clean black Korean brush lettering sized to fit width with breathing room; exact approved text only. No extra rules, numbers, rarity or flavor text. Single card only, no collage, no surrounding scene.
Role: CHARACTER. Input 1 is character frame/style reference ONLY; replace the goblin completely with Erin, a beautiful ADULT HUMAN WOMAN age around 28, normal rounded human ears, light warm skin, shoulder-length slightly tousled chestnut-auburn hair, hazel eyes half closed with a warm mischievous smile and rosy tipsy cheeks. Attractive mature face, glamorous voluptuous hourglass build with a full bust, fitted waist and rounded hips visibly conveyed by a tasteful fitted cream linen blouse and dark brown laced leather bodice, russet travel cloak pushed behind shoulders, belt and diagonal shoulder strap carrying several distinctly shaped medieval colored liquor bottles. Show waist-up including curved waist, face and upper body large in portrait window. One hand raises a wooden ale tankard in a friendly toast, the other rests casually on belt. Keep her clothed, charming and confident; no childlike proportions. Warm amber tavern hearth, timber beams, subtle violet shadows, minimal snowy window in backdrop.
Keep approved character portrait window and a SMALL HUMAN badge at artwork bottom (simple rounded human silhouette icon) with EXACT label "인간", all above y=1120.
Replace title with two lines EXACTLY "술 주정뱅이" / "에린".
Classification EXACTLY "인물 · 주점 손님".
Rules exactly TWO lines:
"술병 다섯 가지 가운데"
"세 병을 아무렇게나 꺼냅니다."
No goblin, no pointed ears, no green skin.
```

## fire_ale — 불꽃 에일

실제 참조 입력: `C:\Users\Loadcomplete\Documents\ChatGPT\마녀산장\witchs-lodge\art\concepts\cards\roles-individual-v02\03-resource-timber.png`

```text
Use case: stylized-concept. Deliver exactly ONE finished upright 1024x1536 RGBA PNG collectible game card, true 2:3, full card visible. Actual transparent alpha ONLY outside the gently rounded rectangular outer corners; opaque purple card stock, cream paper and all artwork.
Use supplied APPROVED role card as the direct frame, layout, brush typography and rendering reference. Preserve its purple stock, bold tapering black ink waves, cream title/classification/rules fields, painterly print texture, broad readable colors and role-specific artwork window. Set in a medieval-based fantasy world; fantasy adaptations allowed while preserving medieval daily life, tools, clothing and atmosphere. No modern items, no photorealism, no watermark.
Reserve x=110..914 y=72..236 for a two-line title, classification y=267..307. Rules panel is one uninterrupted cream area x=55..970 y=1120..1495 with text safe area x=110..914 y=1185..1445, enough for FOUR lines even if only two printed. No ornaments, badge, frame points or dividers inside text safe areas. Titles in bold Korean calligraphic brush type, rules clean black Korean brush lettering sized to fit width with breathing room; exact approved text only. No extra rules, numbers, rarity or flavor text. Single card only, no collage, no surrounding scene.
Role: RESOURCE. Input 1 supplies the approved RESOURCE frame/layout/style, not its timber subject. Preserve its simple rounded rectangular artwork window and one continuous cream rules panel; no duplicate lines or empty horizontal compartments. Replace timber illustration with: A chunky medieval wooden ale tankard with iron hoops and soot-dark rim, rich amber ale with creamy foam and small vivid orange-red magical flames dancing just above the foam, on a rough wooden tavern counter. Warm orange and red firelight, deep purple tavern shadows. Bold clear single tankard silhouette.
Replace tiny resource emblem at artwork bottom with a simple small tankard/drop symbol appropriate to this drink; remain above rules safe area. No race badge.
Title EXACTLY "불꽃 에일".
Classification EXACTLY "주점 · 싸움 술".
Rules exactly TWO lines:
"용병 한 명이 그 밤 더 세게 싸웁니다."
"다음 날 숙취로 잠시 쉽니다."
No timber logs. No extra labels or words.
```

## golden_mead — 금빛 꿀술

실제 참조 입력: `C:\Users\Loadcomplete\Documents\ChatGPT\마녀산장\witchs-lodge\art\concepts\cards\roles-individual-v02\03-resource-timber.png`

```text
Use case: stylized-concept. Deliver exactly ONE finished upright 1024x1536 RGBA PNG collectible game card, true 2:3, full card visible. Actual transparent alpha ONLY outside the gently rounded rectangular outer corners; opaque purple card stock, cream paper and all artwork.
Use supplied APPROVED role card as the direct frame, layout, brush typography and rendering reference. Preserve its purple stock, bold tapering black ink waves, cream title/classification/rules fields, painterly print texture, broad readable colors and role-specific artwork window. Set in a medieval-based fantasy world; fantasy adaptations allowed while preserving medieval daily life, tools, clothing and atmosphere. No modern items, no photorealism, no watermark.
Reserve x=110..914 y=72..236 for a two-line title, classification y=267..307. Rules panel is one uninterrupted cream area x=55..970 y=1120..1495 with text safe area x=110..914 y=1185..1445, enough for FOUR lines even if only two printed. No ornaments, badge, frame points or dividers inside text safe areas. Titles in bold Korean calligraphic brush type, rules clean black Korean brush lettering sized to fit width with breathing room; exact approved text only. No extra rules, numbers, rarity or flavor text. Single card only, no collage, no surrounding scene.
Role: RESOURCE. Input 1 supplies the approved RESOURCE frame/layout/style, not its timber subject. Preserve its simple rounded rectangular artwork window and one continuous cream rules panel; no duplicate lines or empty horizontal compartments. Replace timber illustration with: A single round-bellied medieval handblown glass bottle full of luminous golden honey mead, sealed with beeswax, a cord and a small simple bee emblem hanging at the neck, on a tavern counter. Golden amber highlights and warm inviting light, subtle violet background. Bottle itself is the dominant readable silhouette.
Replace tiny resource emblem at artwork bottom with a simple small tankard/drop symbol appropriate to this drink; remain above rules safe area. No race badge.
Title EXACTLY "금빛 꿀술".
Classification EXACTLY "주점 · 대접하는 술".
Rules exactly TWO lines:
"묵는 손님에게 대접합니다."
"내일 선물을 들고 다시 찾아옵니다."
No timber logs. No extra labels or words.
```

## wisp_spirit — 도깨비불 독주

실제 참조 입력: `C:\Users\Loadcomplete\Documents\ChatGPT\마녀산장\witchs-lodge\art\concepts\cards\roles-individual-v02\03-resource-timber.png`

```text
Use case: stylized-concept. Deliver exactly ONE finished upright 1024x1536 RGBA PNG collectible game card, true 2:3, full card visible. Actual transparent alpha ONLY outside the gently rounded rectangular outer corners; opaque purple card stock, cream paper and all artwork.
Use supplied APPROVED role card as the direct frame, layout, brush typography and rendering reference. Preserve its purple stock, bold tapering black ink waves, cream title/classification/rules fields, painterly print texture, broad readable colors and role-specific artwork window. Set in a medieval-based fantasy world; fantasy adaptations allowed while preserving medieval daily life, tools, clothing and atmosphere. No modern items, no photorealism, no watermark.
Reserve x=110..914 y=72..236 for a two-line title, classification y=267..307. Rules panel is one uninterrupted cream area x=55..970 y=1120..1495 with text safe area x=110..914 y=1185..1445, enough for FOUR lines even if only two printed. No ornaments, badge, frame points or dividers inside text safe areas. Titles in bold Korean calligraphic brush type, rules clean black Korean brush lettering sized to fit width with breathing room; exact approved text only. No extra rules, numbers, rarity or flavor text. Single card only, no collage, no surrounding scene.
Role: RESOURCE. Input 1 supplies the approved RESOURCE frame/layout/style, not its timber subject. Preserve its simple rounded rectangular artwork window and one continuous cream rules panel; no duplicate lines or empty horizontal compartments. Replace timber illustration with: One elongated irregular medieval handblown glass liquor bottle with TWO or THREE small turquoise will-o'-wisps visibly floating inside dark liquor. Restrained cool blue magical light escaping a gap around the cork. Teal, indigo, violet, mysterious and a little risky, rough wooden tavern table, no horror. Large readable bottle silhouette.
Replace tiny resource emblem at artwork bottom with a simple small tankard/drop symbol appropriate to this drink; remain above rules safe area. No race badge.
Title EXACTLY "도깨비불 독주".
Classification EXACTLY "주점 · 도박하는 술".
Rules exactly TWO lines:
"손패 카드 한 장에 붓습니다."
"반은 한 장 더, 반은 주머니로."
No timber logs. No extra labels or words.
```

## dew_of_forgetting — 망각의 이슬주

실제 참조 입력: `C:\Users\Loadcomplete\Documents\ChatGPT\마녀산장\witchs-lodge\art\concepts\cards\roles-individual-v02\03-resource-timber.png`

```text
Use case: stylized-concept. Deliver exactly ONE finished upright 1024x1536 RGBA PNG collectible game card, true 2:3, full card visible. Actual transparent alpha ONLY outside the gently rounded rectangular outer corners; opaque purple card stock, cream paper and all artwork.
Use supplied APPROVED role card as the direct frame, layout, brush typography and rendering reference. Preserve its purple stock, bold tapering black ink waves, cream title/classification/rules fields, painterly print texture, broad readable colors and role-specific artwork window. Set in a medieval-based fantasy world; fantasy adaptations allowed while preserving medieval daily life, tools, clothing and atmosphere. No modern items, no photorealism, no watermark.
Reserve x=110..914 y=72..236 for a two-line title, classification y=267..307. Rules panel is one uninterrupted cream area x=55..970 y=1120..1495 with text safe area x=110..914 y=1185..1445, enough for FOUR lines even if only two printed. No ornaments, badge, frame points or dividers inside text safe areas. Titles in bold Korean calligraphic brush type, rules clean black Korean brush lettering sized to fit width with breathing room; exact approved text only. No extra rules, numbers, rarity or flavor text. Single card only, no collage, no surrounding scene.
Role: RESOURCE. Input 1 supplies the approved RESOURCE frame/layout/style, not its timber subject. Preserve its simple rounded rectangular artwork window and one continuous cream rules panel; no duplicate lines or empty horizontal compartments. Replace timber illustration with: One clear medieval glass liquor bottle covered with large readable dew beads, misty pale silver-blue liquid like a memory fading inside. Beside bottle a small partially erased parchment note, with faint illegible markings, not extra readable text. Quiet wistful moonlight on rough tavern wood, silver gray and pale blue, violet shadows. Bottle is the main focus.
Replace tiny resource emblem at artwork bottom with a simple small tankard/drop symbol appropriate to this drink; remain above rules safe area. No race badge.
Title EXACTLY "망각의 이슬주".
Classification EXACTLY "주점 · 잊게 하는 술".
Rules exactly TWO lines:
"주머니 카드 하나를 영원히 잊습니다."
"다음 날 아침엔 머리가 멍합니다."
No timber logs. No extra labels or words.
```

## drunk_rant — 술주정

실제 참조 입력: `C:\Users\Loadcomplete\Documents\ChatGPT\마녀산장\witchs-lodge\art\concepts\cards\roles-individual-v02\06-event-forbidden-harvest.png` 및 `GENERATED drunken_erin.png (required after successful generation)`

```text
Use case: stylized-concept. Deliver exactly ONE finished upright 1024x1536 RGBA PNG collectible game card, true 2:3, full card visible. Actual transparent alpha ONLY outside the gently rounded rectangular outer corners; opaque purple card stock, cream paper and all artwork.
Use supplied APPROVED role card as the direct frame, layout, brush typography and rendering reference. Preserve its purple stock, bold tapering black ink waves, cream title/classification/rules fields, painterly print texture, broad readable colors and role-specific artwork window. Set in a medieval-based fantasy world; fantasy adaptations allowed while preserving medieval daily life, tools, clothing and atmosphere. No modern items, no photorealism, no watermark.
Reserve x=110..914 y=72..236 for a two-line title, classification y=267..307. Rules panel is one uninterrupted cream area x=55..970 y=1120..1495 with text safe area x=110..914 y=1185..1445, enough for FOUR lines even if only two printed. No ornaments, badge, frame points or dividers inside text safe areas. Titles in bold Korean calligraphic brush type, rules clean black Korean brush lettering sized to fit width with breathing room; exact approved text only. No extra rules, numbers, rarity or flavor text. Single card only, no collage, no surrounding scene.
Role: EVENT. Input 1 is approved EVENT frame/style reference, preserve its broad scene window and restrained folded banner points outside title. One wide uninterrupted cream rules field; no central arrow, fork, V-notch or split compartments. Input 2 must be final generated Erin character card for identity reference: same beautiful adult HUMAN woman age 28, rounded human ears, warm fair skin, tousled chestnut-auburn shoulder-length hair, hazel eyes, full bust and curvy fitted waist, cream linen blouse, dark brown laced leather bodice, russet travel cloak and colored bottles on belt/strap. In illustration window, she comically slumps sideways at the timber lodge tavern table, one elbow supporting her cheek while she talks with a tipsy smile and sweeps her other hand, scattering a few game cards as empty medieval glass bottles roll across tabletop. Face clearly visible, glamorous clothed figure recognizable, friendly humorous performance. Hearth orange highlights, violet indoor shadows. No injury, no horror, no other prominent characters. Do not reuse harvest festival subject.
Title EXACTLY "술주정".
Classification EXACTLY "주점 · 사건".
Rules exactly TWO lines:
"손패 두 장을 주머니에 섞어 넣고"
"한 장을 새로 뽑습니다."
```

## guest_erin_cutout — 에린 대화창 초상

실제 참조 입력: `GENERATED drunken_erin.png (required after successful generation)`

```text
Use case: identity-preserve. Create a matching standalone medieval fantasy game dialogue portrait, approximately 1122x1402 RGBA with genuine transparent background. Use final generated drunken_erin.png as REQUIRED identity and clothing reference. Same beautiful adult HUMAN woman age 28 with rounded human ears, warm light skin, shoulder-length tousled chestnut-auburn hair, hazel half-lidded eyes, flushed cheeks and friendly mischievous smile. Glamorous voluptuous build with full bust and visible fitted waist, cream linen blouse and dark brown laced leather bodice, russet travel cloak pushed behind shoulders, bottle belt/strap. Raise wooden ale tankard in one hand; friendly tipsy greeting, clothed. Match approved card's bold tapering black ink outlines, broad readable colors, clear shading and painterly print texture. Include entire head, both shoulders, arms, tankard, bottle accessories and waist inside canvas with generous transparent margins on all sides. Upper-body lower edge finishes naturally without hard straight cut at canvas edge. No frame, text, badge, backdrop, cropped arms or props, pointed ears or goblin features. Preserve warm amber highlights and violet shadows.
```

