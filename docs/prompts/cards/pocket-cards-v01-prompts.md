# 마녀의 주머니 카드·버림패 아이콘 v01 — 실제 생성 프롬프트

2026-10-16 · 내장 `image_gen` · 모든 호출 `transparent_background=true`.

요청서: [codex-pocket-cards-v01.md](../../handoff/codex-pocket-cards-v01.md). 카드 그림·한글·라운드와 바깥 투명 알파는 생성본을 유지한다. 코드는 카드 불투명 본체 크롭·Lanczos 축소와 QA 시트 합성만 수행한다. 아이콘은 생성본 그대로 RGBA 변환·96×96 Lanczos 축소한다. CLI/API 대체 생성은 사용하지 않았다.

## poison_mushroom — 최종 채택

원본: `exec-06afe2b5-2924-4d18-8fc5-8f4c09c2d2b0.png`.

```text
Use case: stylized-concept.
Asset type: ONE complete production card face for the Korean game 마녀산장, portrait 2:3, ideally 1024x1536 RGBA.
Input image 1 frost_rune is the FRAME AND TYPOGRAPHY reference; input image 2 black_wool is the cold dark palette/painted ink style reference. Create a new distinct POISON MUSHROOM card belonging to exactly this set.
Preserve the same muted dusty lavender physical cardboard outer framing, heavy black asymmetric S sweep upper-left and opposite lower-right, warm cream flowing title and rules panels in same proportions, bold Korean brush lettering, painterly winter woodcut gouache texture. Full flat front view, straight sides, no perspective. ENTIRE lavender physical card is opaque. Four very subtly rounded outer corners (radius about 40px at width1024), genuine transparent alpha ONLY outside the lavender card. No shadow, halo, matte, checkerboard, or extra thin outside outline. Card almost fills canvas, no large margins.
Subject inside central illustration: exactly three purple-capped poisonous mushrooms sprouting through snow-covered fallen leaves, pale yellow spots on caps, faint lavender poisonous steam rising from bases, one small bone and frost-covered moss. Cold dark teal snowy woodland backdrop. Unsettling fairy-tale mood without gore. Distinct mushrooms readable at hand-card size. Match existing painted ink texture, restrained palette and bold outlines, no photorealism/3D.
Text must be EXACT, carefully legible Hangul, no additions:
Top large title: "독버섯"
Smaller category beneath: "재료 · 숲의 독"
Bottom line 1: "마녀의 체력을 깎습니다."
Bottom line 2: "대신 주머니에서 한 장을 뽑습니다."
Keep each bottom sentence on its own single line, both entirely within cream panel. NO costs, numerals, health badges, stats, watermark. Only this card, no mockup scene.
```

## old_spellbook — 최종 채택

원본: `exec-3f4a9a97-6947-4298-a369-af2b2d0aa5ab.png`.

```text
Use case: stylized-concept.
Asset type: ONE complete production Korean game card for 마녀산장, portrait 2:3, ideally 1024x1536 RGBA.
Input image 1 gatherer is ONLY the card frame, Korean calligraphy and painted ink style reference. Input image 2 frost_rune is ONLY frame/rounded outer boundary reference. Make a new OLD SPELLBOOK card in exactly the same card family.
Use identical dusty lavender opaque physical card border, heavy asymmetric black S sweep upper-left and opposite lower-right, flowing warm cream title/rules panels at same proportions, bold Korean brush-ink lettering and broad gouache woodcut brush texture. Flat straight front view. Four subtly rounded outer corners radius about40px at width1024. REAL ALPHA transparency outside the lavender physical card only; entire card including lavender material remains opaque. Tight almost full canvas; no shadow, halo, matte or checkerboard.
Subject: a thick old leather-bound spellbook, half open on a timber lodge table, crescent moon stamped in leather cover, worn pages emit purple and warm golden magical light. EXACTLY THREE small blank or abstract illustrated cards float in a clearly separated fan above the pages; make all three visibly countable. ONE candle nearby; snowy window behind. Warm amber gold and violet with winter teal accents. Rich hand-painted ink/gouache, bold silhouettes, same fairy-tale art style as references, no photorealism or 3D.
Exact Korean text with fully legible handlettered brush typography:
Top large title, a single line: "오래된 마법서적"
Smaller category: "주문 · 마녀의 서적"
Bottom single line 1: "주머니의 카드 세 장을 펼칩니다."
Bottom single line 2: "그중 한 장을 골라 뽑습니다."
No other words, no Roman letters on book/pages/cards, no cost, health icons, stats, numerals, watermark. Keep both rules on two distinct single lines within cream panel.
```

## icon_discard — 최종 채택

원본: `exec-9520f407-8a97-4ec2-aa22-50d9c4f95613.png`.

```text
Use case: stylized-concept.
Asset type: ONE small inventory/UI icon for Korean witch lodge game 마녀산장, transparent PNG, square canvas, master at 1024x1024 for downsampling to96x96.
Input images icon_treasure_chest and icon_arrow are STYLE references only: match their chunky irregular dark ink outlines, warm muted ivory/ochre and dusty violet colors, simple readable woodcut/gouache silhouette. Create DISCARD PILE icon: a low stack of three playing cards lying sideways, horizontal landscape orientation, slightly offset cream paper edges, top card dusty muted lavender back with tiny simple crescent mark, a few small grey ash/dust flecks drifting off its right edge. Make it a bold clean readable silhouette at96x96, generously thick black contours (about3px at final96px). NO upright cards, no garbage bin, no flames, no crossed-out sign, no arrows, NO letters or numbers. One compact subject occupying85% of square width, center. Genuine transparent alpha background outside cards and specks, no shadow, no glow, no circle or panel, no checkerboard.
```


## poison_mushroom-alpha-final — 최종 채택 알파 수정

최초 생성본은 왼쪽 외곽과 모서리 알파 검사를 실패했다. 아래 수정본으로 교체했다. 최초 프롬프트는 생성 이력이며, 최종 원본은 `exec-53958c5e-df86-4a8c-85e1-3795a672ae31.png`이다.

```text
Use case: precise-object-edit / background-extraction.
Image1 is the POISON MUSHROOM card EDIT TARGET. Image2 frost_rune is ONLY the successful opaque lavender card / transparent rounded silhouette REFERENCE.
Fix ONLY Image1 alpha and OUTERMOST card boundary. Preserve its exact illustration, mushroom count, all Hangul, cream panels, purple palette and heavy asymmetric black S design.
PRODUCTION DEFECT: left side at mid-height has transparency inside the physical lavender framing; some lower corners are opaque. Make ALL pixels INSIDE the physical dusty lavender card completely opaque, alpha255. Lavender is PHYSICAL CARDBOARD, NOT background. Restore straight left/right opaque lavender sides all the way along the card. No transparent holes, bites, inward waves, translucency or erased lavender material. Outline must be a true straight-sided rounded RECTANGLE, subtle identical radius40px on all four corners, portrait2:3. Full1024x1536 canvas card edges at x0,x1023,y0,y1535; opaque lavender touches middle of all four sides; only rounded quarter-circle corner cutouts alpha0. Top-left and all four 5x5 corner regions completely transparent. Smooth1px antialiased boundary only, no outside halo/shadow/thin rim.
Keep every interior ink/illustration/title/rules as close to target as possible. Exact text invariants:
"독버섯"
"재료 · 숲의 독"
"마녀의 체력을 깎습니다."
"대신 주머니에서 한 장을 뽑습니다."
No new words or elements. Transparent PNG.
```
