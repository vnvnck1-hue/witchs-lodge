
## v02 이어서 제작 · 2026-10-18

내장 `image_gen`을 사용했다. 컷 3은 생성·수정하지 않았다. 아래 기록과 `output/ftue-motion-v01/resume-generated-index.json`에 실제 프롬프트·참고 입력·원본 경로를 보존한다. 최종 배치·트림·창 유리 정렬·글로우 강도·노을 색상 전달은 재사용 제작 스크립트와 `generation-index-v02.json`에 기록한다.

### 이어서 제작: cut1_witch_fore

저장: `art/concepts/ftue-motion-v01/cut1_witch_fore-v03-generated.png`

참고 입력:
- `art/concepts/ftue-motion-v01/cut1_master-v02.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. Input 1 is the LOCKED approved cinematic scene master. Extract ONLY the enormous near-camera witch at the right foreground, with identical silhouette, hood/shoulder/cape folds, orange fire rim and deep violet black inks. Preserve the EXACT FULL WIDE IMAGE LAYOUT and object location: hood fills upper right corner, shoulder sweeps through right middle, lower cape extends diagonally far toward bottom left. Witch is CROPPED by top, right and bottom frame edges just as in master. Everything else including snow, mountains, village, sky, smoke, small witches becomes REAL TRANSPARENCY. Do not shrink, recenter or fit entire witch; no face/body completion. Keep full 16:9 canvas proportions. Large flat color planes, 2-3 shading steps, black tapering ink, dry gouache grain. Medieval-based fantasy with medieval atmosphere and materials. No text, symbol, watermark, backdrop or glow beyond solid rim silhouette.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-925b0fb6-d299-403c-9703-ae049447cadf.png`

### 이어서 제작: cut2_witch

저장: `art/concepts/ftue-motion-v01/cut2_witch-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut2_master-v02.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/portraits/card-style-v01/witch.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE isolated full-body witch for a motion comic, real transparent background. Input 1 LOCKED scene master: extract the walking witch at center-left exactly, rear three-quarter view walking uphill toward upper right, windswept purple cloak, rounded hood, wavy violet hair, cream dress, leather boots, right hand holds iron candle lantern. Input 2 approved witch IDENTITY; input 3 CARD ink/gouache STYLE. Keep pose and lantern position of image 1, render full silhouette with no ground, background, cast shadow or light pool. Medieval-based fantasy maintaining medieval materials and atmosphere. Bold tapering black ink contours, large violet/indigo color planes, 2-3 shading steps, printed dry gouache grain, local amber lantern rim. No added symbols, text, frame, logo, watermark. Leave transparent padding around whole character; do not crop boots or cloak. Lantern hardware included; external radiance is separate.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-49445e1a-21d0-493a-9b32-63de301d04bf.png`

### 이어서 제작: cut2_lantern_glow

저장: `art/concepts/ftue-motion-v01/cut2_lantern_glow-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut2_master-v02.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE production motion-comic isolated layer. Input1 locked scene master; Input2 ink/gouache style only. Preserve master perspective, shape and color. Medieval-based fantasy retaining medieval materials and atmosphere. Bold tapering black ink contours, large flat color planes, 2-3 step shading, printed dry gouache grain, violet-indigo-teal shadows, amber local rim. No text, logos, watermark or frame. REAL TRANSPARENT BACKGROUND. Only soft translucent AMBER CANDLE RADIANCE: small bright warm oval halo at upper center and faint horizontal elliptical pool of amber bounce light below. No iron lantern, no candle object, no character, no snow/ground, no black outlines, no opaque white shapes. Pure light on real transparency, low-alpha feathered edges, for additive blend. Match the witch lantern's local color, not a sunburst.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-85205ee6-e09a-452c-9204-99492df6c988.png`

### 이어서 제작: cut2_trunk_left

저장: `art/concepts/ftue-motion-v01/cut2_trunk_left-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut2_master-v02.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE production motion-comic isolated layer. Input1 locked scene master; Input2 ink/gouache style only. Preserve master perspective, shape and color. Medieval-based fantasy retaining medieval materials and atmosphere. Bold tapering black ink contours, large flat color planes, 2-3 step shading, printed dry gouache grain, violet-indigo-teal shadows, amber local rim. No text, logos, watermark or frame. REAL TRANSPARENT BACKGROUND. Extract ONLY the gigantic LEFT FOREGROUND tree trunk and its snowy projecting branches/root base in the scene. Cropped vertically at top and bottom, thick gnarled near-black violet bark, left edge clipped; inward-facing contour organic and jagged, a few snow-loaded fir boughs projecting to the right. One huge vertical tree only. No other trees, ground, witch, lodge, moon or sky. Exact low camera angle and violet/amber rim of master. Large opaque silhouette on true transparency, height much greater than width.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-05bca270-5655-4907-9f7f-64d8becabbd8.png`

### 이어서 제작: cut2_trunk_right

저장: `art/concepts/ftue-motion-v01/cut2_trunk_right-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut2_master-v02.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE production motion-comic isolated layer. Input1 locked scene master; Input2 ink/gouache style only. Preserve master perspective, shape and color. Medieval-based fantasy retaining medieval materials and atmosphere. Bold tapering black ink contours, large flat color planes, 2-3 step shading, printed dry gouache grain, violet-indigo-teal shadows, amber local rim. No text, logos, watermark or frame. REAL TRANSPARENT BACKGROUND. Extract ONLY the gigantic RIGHT FOREGROUND tree trunk and its snowy projecting branches/root base in the scene. Cropped vertically at top and bottom, thick gnarled near-black violet bark, right edge clipped; inward-facing contour organic and jagged, snow-loaded fir boughs projecting to the left. One huge vertical tree only. No other trees, ground, witch, lodge, moon or sky. Exact low camera angle and violet/amber rim of master. Large opaque silhouette on true transparency, height much greater than width.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-190d12bb-0cef-494f-8b3b-9033c992cfab.png`

### 이어서 제작: cut2_fore

저장: `art/concepts/ftue-motion-v01/cut2_fore-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut2_master-v02.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE isolated motion comic layer. Input1 locked master composition and color. Medieval-based fantasy with medieval life and atmosphere; violet-indigo-teal snow, bold tapering black ink and dry gouache for solid items. No text, logos, watermark or frame. Extract only a low wide strip of near foreground snow-covered rock and twig silhouettes along the BOTTOM frame edge. Very dark violet near-black simple planes, snow only on upper ridges, no tall plants. Full 16:9 wide image with all content confined to bottom 18 percent; entire upper 82 percent REAL TRANSPARENT. No character, lantern, house or tree trunk. Bottom quarter should stay dark and visually quiet. Keep original edge framing.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-19b2bbe2-fc8c-4c89-aa04-0864c622471f.png`

### 이어서 제작: cut2_fog

저장: `art/concepts/ftue-motion-v01/cut2_fog-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut2_master-v02.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE isolated motion comic layer. Input1 locked master composition and color. Medieval-based fantasy with medieval life and atmosphere; violet-indigo-teal snow, bold tapering black ink and dry gouache for solid items. No text, logos, watermark or frame. Only thin sparse wisps of low lavender blue snow fog across a wide 16:9 canvas, pale translucent haze in sweeping horizontal diagonal bands. REAL transparency between wisps and at edges, low opacity approximately 10-25 percent. NO ink contour, NO opaque flat background, NO snowflakes, trees, house, character, ground, moon or symbols. Atmospheric overlay that clears in the first second.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-8a81b582-7214-4eb2-bf67-3c28b6f3ef9c.png`

### 이어서 제작: cut4_sky_night

저장: `art/concepts/ftue-motion-v01/cut4_sky_night-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_master-v02.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `false`

실제 프롬프트:

```text
Use case: precise-object-edit. ONE motion-comics asset. Input1 FINAL APPROVED cut4 master (two midground travelers). Input2 approved CARD STYLE ONLY. Preserve master composition/perspective and bold tapering black ink, large color planes, 2-3 step shading, printed dry gouache grain. Purple-indigo-teal snow, localized amber. Medieval-based fantasy retaining medieval materials and atmosphere. No text/logo/watermark/frame. Create the full wide CLEAN BACKGROUND PLATE of this EXACT low-angle scene. Keep night sky, crescent moon, distant mountain silhouette and snow hillside with the ascending stone path. Remove ALL THREE travelers, lodge, spider/legs/eyes, foreground rocks/bushes and close framing trees. Inpaint lodge location with snow hillside and continue the steps to a small landing at x~1600 y~800; remove foreground traveler to reveal snow path. Keep perspective, mountains horizon and layout fixed. Background must fill complete 16:9 canvas opaquely, no transparency, no hole. Quieter darker bottom quarter. Distant tiny forest silhouettes only; main forest is separate.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-1343d8ab-e46e-42a2-bd94-cf01bbf4b569.png`

### 이어서 제작: cut4_forest

저장: `art/concepts/ftue-motion-v01/cut4_forest-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_master-v02.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE motion-comics asset. Input1 FINAL APPROVED cut4 master (two midground travelers). Input2 approved CARD STYLE ONLY. Preserve master composition/perspective and bold tapering black ink, large color planes, 2-3 step shading, printed dry gouache grain. Purple-indigo-teal snow, localized amber. Medieval-based fantasy retaining medieval materials and atmosphere. No text/logo/watermark/frame. Extract ONLY the surrounding snowy FIR FOREST into a full wide 16:9 transparent layer at EXACT scene positions. Tree masses frame left and right, with a gap revealing central crescent moon and mountains; tree line behind lodge to its left and above/right. REMOVE lodge, all people, spider body/legs, glowing eyes, moon, sky, mountains, ground/path, foreground rocks. Upper treetop silhouette and inner forest edges must be irregular natural pine branches. Do not turn this into a rectangular panel. Real transparency everywhere between trees and outside silhouettes. Preserve exact tree sizes and layout from master; deep violet/teal with lavender snow.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-4dfd5828-7693-486a-b3d4-c16be366f9dc.png`

### 이어서 제작: cut4_lodge

저장: `art/concepts/ftue-motion-v01/cut4_lodge-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_master-v02.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE motion-comics asset. Input1 FINAL APPROVED cut4 master (two midground travelers). Input2 approved CARD STYLE ONLY. Preserve master composition/perspective and bold tapering black ink, large color planes, 2-3 step shading, printed dry gouache grain. Purple-indigo-teal snow, localized amber. Medieval-based fantasy retaining medieval materials and atmosphere. No text/logo/watermark/frame. Extract ONLY the snow-roofed stone/timber LODGE, front door/steps, chimney and lit windows. Same exact low-angle building silhouette, roof direction, stone masonry, door, window arrangement as locked master. Remove the TWO small men completely; reconstruct closed wooden door and unobstructed stone stair behind them. Windows have warm amber candlelit panes, no external glow (separate layer). No chimney smoke. No forest, sky, ground boulders, other trees, traveler, spider, text, sign or emblem. Building sits isolated on real transparency, small transparent padding, retain all chimney and roof extremities.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-d3ea1718-e801-44ca-aed0-2485fa442fc5.png`

### 이어서 제작: cut4_traveler_1

저장: `art/concepts/ftue-motion-v01/cut4_traveler_1-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_master-v02.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE isolated production motion comic sprite on REAL transparent background. Input1 FINAL APPROVED scene master; input2 approved CARD ink/gouache STYLE ONLY. Bold tapering black contours, large color planes, 2-3 step shading, printed dry gouache grain, violet-indigo shadows and amber local rim. Medieval-based fantasy retaining medieval materials and atmosphere (wool, leather, iron). No symbols, letters, text, logo, watermark or frame. Extract ONLY the BLUE-COATED middle-ground traveler with a blue wool cap, fur trim and leather backpack/rolled bedroll (the one climbing lower steps, LEFT of the yellow-cloaked knocker). Rear three-quarter view walking uphill toward upper right. Exactly ONE man, complete boots/backpack/bedroll and low-held sheathed sword, no other traveler. Keep pose, clothing and silhouette from approved master. No floor/stairs, cast shadow, house, forest or spider, small real transparent padding.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-b4a3b7fc-6dbf-44b3-ba4b-dc974156382a.png`

### 이어서 제작: cut4_traveler_2

저장: `art/concepts/ftue-motion-v01/cut4_traveler_2-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_master-v02.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE isolated production motion comic sprite on REAL transparent background. Input1 FINAL APPROVED scene master; input2 approved CARD ink/gouache STYLE ONLY. Bold tapering black contours, large color planes, 2-3 step shading, printed dry gouache grain, violet-indigo shadows and amber local rim. Medieval-based fantasy retaining medieval materials and atmosphere (wool, leather, iron). No symbols, letters, text, logo, watermark or frame. Extract ONLY the YELLOW-OCHRE cloaked middle-ground traveler who raises his RIGHT gloved hand to knock on the door. Rear three-quarter view facing upper right, fur collar, medieval blue tunic below ochre hooded cape, sturdy leather boots. Exactly ONE man, entire silhouette, no other man. Keep raised arm and knocking pose of approved master; remove door completely. No ground/stairs, house, forest, cast shadow or spider, real transparent padding.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-d8fe35e7-1714-4060-a5cb-ad532d469ff4.png`

### 이어서 제작: cut4_traveler_fore

저장: `art/concepts/ftue-motion-v01/cut4_traveler_fore-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_master-v02.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE isolated production motion comic sprite on REAL transparent background. Input1 FINAL APPROVED scene master; input2 approved CARD ink/gouache STYLE ONLY. Bold tapering black contours, large color planes, 2-3 step shading, printed dry gouache grain, violet-indigo shadows and amber local rim. Medieval-based fantasy retaining medieval materials and atmosphere (wool, leather, iron). No symbols, letters, text, logo, watermark or frame. Extract ONLY the huge LEFT FOREGROUND traveler, keeping his EXACT FULL WIDE 16:9 scene layout: head near x~600 y~170, shoulder/fur collar fills left third, huge leather backpack and rolled bedroll, green cloak and armored right arm, body cropped by LEFT and BOTTOM image edges. DO NOT shrink, center, fit complete figure or change perspective. Preserve dominant scale, original cropping and amber rim. All sky/trees/house/other people/monster/snow/rocks removed to REAL TRANSPARENCY. One enormous partial foreground man only. No invented feet or completion.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-5c5a1ea7-ef02-437d-a1ee-6fc7a0c1d9a1.png`

### 이어서 제작: cut4_spider_legs

저장: `art/concepts/ftue-motion-v01/cut4_spider_legs-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_master-v02.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE isolated motion comic layer. Input1 is FINAL APPROVED master. Medieval-based fantasy with medieval atmosphere and materials, tapering black ink contours, 2-3 large color planes, dry gouache print grain, purple-indigo shadows. No text/logo/watermark/frame. Extract ONLY the TWO or THREE huge articulated spider LEGS crossing the UPPER RIGHT of the locked scene. Keep EXACT full wide 16:9 scene layout and original cropped position: legs issue from beyond upper-right edge, one very large bent leg arch extends left across upper middle and its tip points down near x~1000 y~500. Another leg angles toward central roof, 2-3 giant legs total with jointed spiky contour. Body/head/eyes REMOVED, will be separate. All forest/sky/house/people become REAL transparency. Dense near-black purple solid silhouettes with restrained violet ink details and thin amber rim; NOT tiny floating spider, not entire spider in center. Do not fit legs in bounds, preserve edge crop.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-d5027b74-930e-4276-9e97-8d9617de154e.png`

### 이어서 제작: cut4_spider

저장: `art/concepts/ftue-motion-v01/cut4_spider-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_master-v02.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE isolated motion comic layer. Input1 is FINAL APPROVED master. Medieval-based fantasy with medieval atmosphere and materials, tapering black ink contours, 2-3 large color planes, dry gouache print grain, purple-indigo shadows. No text/logo/watermark/frame. Extract ONLY the small visible fragment of the giant spider's HEAD in the extreme UPPER RIGHT corner of approved scene: a dark violet fuzzy/angular mask with multiple small AMBER eyes and short mandible silhouettes, cropped by TOP and RIGHT edges. No body completion, no long legs (separate layer), no sky/tree/background or gore. Keep real transparency outside head. Very dark and minimally detailed, localized amber eyes only. Head is a corner fragment of enormous offscreen monster.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-daa3f42b-fbec-4768-8545-63507731b573.png`

### 이어서 제작: cut4_eyes_1

저장: `art/concepts/ftue-motion-v01/cut4_eyes_1-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_master-v02.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE isolated motion comic layer. Input1 is FINAL APPROVED master. Medieval-based fantasy with medieval atmosphere and materials, tapering black ink contours, 2-3 large color planes, dry gouache print grain, purple-indigo shadows. No text/logo/watermark/frame. Only ONE small pair of AMBER animal eye glints isolated on genuine transparency. No face/body, no black box, no pupils anatomy, no symbols. Two small yellow-orange narrow almond glints spaced as a pair, faint softly feathered amber halo, simple read at 70x40 pixels. For a hidden creature in violet forest edge. No other objects.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-9aee962c-64f3-40e9-963f-61713545acf7.png`

### 이어서 제작: cut4_fore

저장: `art/concepts/ftue-motion-v01/cut4_fore-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_master-v02.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE motion comic layer from final cut4 master. Medieval-based fantasy with medieval materials and atmosphere, bold tapering black ink contours, 2-3 large color planes, dry gouache grain, violet-indigo-teal shadows and local amber only. No text/logo/watermark/frame. Extract ONLY a LOW foreground strip of near-black violet snowy rocks and sparse brambles along bottom edge of the master. Full wide 16:9 canvas; all content confined to lower 17 percent, entire upper 83 percent REAL transparency. Dark simple silhouettes and sparse thin snow ridge, subtitle-friendly quiet lower edge. No big traveler, no forest/house/other people/spider/sky/ground plate. Keep asymmetric corners matching master.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-ecbb95fd-60a0-4c92-bc24-646db0db4366.png`

### 이어서 제작: cut4_sky_dusk_palette

저장: `art/concepts/ftue-motion-v01/cut4_sky_dusk_palette-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_sky_night-v02-generated.png`

투명 배경 요청: `false`

실제 프롬프트:

```text
Use case: lighting-weather. ONE motion comic layer from final cut4 master. Medieval-based fantasy with medieval materials and atmosphere, bold tapering black ink contours, 2-3 large color planes, dry gouache grain, violet-indigo-teal shadows and local amber only. No text/logo/watermark/frame. Change ONLY the LIGHTING/TIME of the exact clean background plate to late DUSK twilight, with muted warm amber/mauve low sky gradient and lavender snow. Keep every terrain edge, stone step, mountain and tree position exactly unchanged. Crescents can be visible in twilight; reduce stars. Preserve bold ink/gouache style. No house, character, monster, text or frame. Complete opaque wide 16:9 canvas. This is a color-palette reference for coordinate-identical dusk/night grading.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-d2516c74-326e-4fe2-8bef-8ea3766cb46e.png`

### 이어서 제작: cut2_window_glow

저장: `art/concepts/ftue-motion-v01/cut2_window_glow-v03-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut2_lodge-v02-generated.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: precise-object-edit / light-only extraction. Input1 is the EXACT lodge sprite layout. Output ONLY the warm amber emission INSIDE the THREE MAIN WINDOW GLASS areas. Keep the EXACT same canvas dimensions/proportions and same window positions, sizes, perspective and glazing cross divisions as image1. Imagine windows switched on with soft candlelight: translucent GOLDEN AMBER rectangular glass panes, narrow transparent crossbar gaps. Remove EVERYTHING ELSE to REAL TRANSPARENCY: no lodge, roof, stone, wooden frames, chimney, door, ground, snow, beams or external pool. DO NOT rearrange the three windows, DO NOT cluster them together or center them. Faint small feathered amber halo at pane edges only, no large rays, no white blast, no solid white, moderate low-opacity amber. Pure light sprite for additive blending over exact input lodge. Medieval-based fantasy candle windows, ink/gouache grain inside panes but no dark structure. No text/logo/watermark/frame.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-4f1f9407-2f13-43b8-99e4-98ca82b23362.png`

### 이어서 제작: cut4_window_glow

저장: `art/concepts/ftue-motion-v01/cut4_window_glow-v03-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/ftue-motion-v01/cut4_lodge-v02-generated.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: precise-object-edit / light-only extraction. Input1 is the EXACT lodge sprite layout. Output ONLY the warm amber emission INSIDE the THREE MAIN WINDOW GLASS areas. Keep the EXACT same canvas dimensions/proportions and same window positions, sizes, perspective and glazing cross divisions as image1. Imagine windows switched on with soft candlelight: translucent GOLDEN AMBER rectangular glass panes, narrow transparent crossbar gaps. Remove EVERYTHING ELSE to REAL TRANSPARENCY: no lodge, roof, stone, wooden frames, chimney, door, ground, snow, beams or external pool. DO NOT rearrange the three windows, DO NOT cluster them together or center them. Faint small feathered amber halo at pane edges only, no large rays, no white blast, no solid white, moderate low-opacity amber. Pure light sprite for additive blending over exact input lodge. Medieval-based fantasy candle windows, ink/gouache grain inside panes but no dark structure. No text/logo/watermark/frame.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-1d13f45b-fd5b-42af-80ab-2e77a32b62a1.png`

### 이어서 제작: cut0_panel_frame

저장: `art/concepts/ftue-motion-v01/panel_frame-v02-generated.png`

참고 입력:
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`

투명 배경 요청: `true`

실제 프롬프트:

```text
Use case: background-extraction. ONE simple widescreen 16:9 motion-comic PANEL FRAME on genuine transparency. Reference input approved card gives ONLY the irregular tapering black ink edge character. Create an extremely THIN organically WAVERING BLACK INK perimeter stroke around all four image EDGES, with a little near-black deep violet outer shadow. Interior completely empty transparent. NO card layout, parchment, banners, text, symbols, ornament, corners, pillars, objects or imagery. Border should occupy only outermost 2-3 percent of image, maximum 50px at1920x1080; gentle hand-ink ripples, no rectangular black background. Real transparent center and surrounding gaps, not white/checkerboard. Medieval fantasy storybook ink/gouache aesthetic. Wide 1920x1080 intended size.
```

생성 원본: `C:\Users\vnvnc\.codex\generated_images\01a14dde-2f01-74a0-abb3-4079ec647ea6\exec-a4464acf-de62-44a3-9333-b6d8eb459a23.png`


