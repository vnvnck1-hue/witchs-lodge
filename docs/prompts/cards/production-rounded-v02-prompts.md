# 실사용 카드 라운드·투명 PNG 최종 프롬프트

2026-10-13 · 도구: 내장 image_gen · transparent_background=true

최종 목재는 `timber-final-lavender-edge` 수정본을 사용한다. 최초 목재의 흐릿한 외곽을 정리하고 보라색 카드 프레임을 유지했다. `timber-final-edge-cleanup` 결과는 보라색 프레임까지 투명해져 미채택이며 경과 기록으로만 남긴다.

## timber-final-lavender-edge — 최종 채택 납품본

```text
Use case: precise-object-edit.
Asset type: complete TIMBER game card, revised alpha silhouette for production.
Image 1 is the TIMBER card edit target, KEEP ALL CONTENT including its DUSTY LAVENDER OUTER BORDER, creamy title/rules panels, black S-shape frame, logs, snow, Korean text.
Image 2 is the successful AXE CARD reference showing the correct LAVENDER cardboard edge and correct transparent corners.
CRITICAL: The LAVENDER AREA IS THE PHYSICAL CARD itself. It is NOT background and must remain fully OPAQUE. Preserve all of the lavender border at top, bottom and both sides. Only pixels OUTSIDE the rectangular lavender card's rounded outer perimeter should be transparent. Do not erase the lavender framing or reduce the card to the interior black oval.
Rebuild Image1's OUTERMOST boundary to match Image2: a CLEAN LAVENDER ROUNDED RECTANGLE, 2:3, four subtle 40px radius corners, straight sides. The card is fully opaque including all lavender material. Immediately outside this rectangle is zero alpha. No diffuse translucent halo, no outside rim, no drop shadow, no black matte or checkerboard. Sharply antialiased edge about1px, smooth slight round corners. Portrait ideally1024x1536, lavender cardboard edge touches the canvas along all four middle sides and only corner cutouts are transparent.
DO NOT change illustration or wording. Large top title "목재"; subtitle "자원 · 벌목 재료"; bottom first line "벌목을 마치면 얻습니다."; bottom second "산장 수리에 사용할 수 있습니다.". Keep hand-ink print style and warm cream/teal/lavender colors exactly.
Make the entire complete TIMBER card look like a member of Image2's same card set with LAVENDER visible outer cardboard.
```

## timber-final-edge-cleanup

```text
Use case: background-extraction / precise-object-edit.
Image 1 is the timber card EDIT TARGET. Image 2 is the final axe mercenary card edge reference.
Fix ONE specific production defect in Image 1: the fuzzy partly transparent PURPLE HALO / outer soft rectangular rim around the actual card. REMOVE that halo completely so there is only ONE clean card silhouette and real alpha transparency immediately outside the lavender edge. NO soft shadow, NO outer fringe, NO double outline, NO blurry corners.
Use the gently rounded outer silhouette of Image 2, about 40px corner radius, with crisp antialiased edge only 1-2px wide. Outside the edge ALPHA must be ZERO. Interior card completely opaque. Tightly crop to the actual card at 2:3 portrait ideally1024x1536 with only the tiny rounded corner cutouts transparent.
Preserve Image1 illustration, all current exact title/category/rules, ink texture, colors, main black S-shaped frame and cream panels. Do not redesign or regenerate the logs or forest, do not alter text.
Text invariants: "목재"; "자원 · 벌목 재료"; "벌목을 마치면 얻습니다."; "산장 수리에 사용할 수 있습니다.".
No extra new thin black outside outline. Match Image2's clean boundary. Background is genuinely transparent, never a purple or black backdrop.
```

기준: 카드 코어 v0.3의 네 카드와 공용 뒷면. 기존 시안은 보존하고 새 실사용 에셋은 art/cards/rounded/, 크기 정규화본은 godot/assets/cards/에 납품한다. 알파·라운드 수정과 새 원화는 image_gen으로 수행했다. Godot 패키징은 생성 알파를 유지한 크롭·리사이즈다.

입력 역할: 도끼 용병/양털/숲의 괴물은 기존 카드가 수정 대상, 수정된 도끼 용병이 모서리/포맷 참고다. 목재는 도끼 용병 포맷과 기존 양털 자원 구성을 참고하며, 뒷면은 수정된 도끼 용병의 화풍만 참고한다.

## axe_mercenary

```text
Use case: precise-object-edit / background-extraction.
Asset type: production-ready transparent PNG card face for Korean Godot game 마녀산장.
Image 1 is the EDIT TARGET: the approved axe mercenary card. Preserve the entire existing illustration, character identity, lavender asymmetric black S-curve frame, cream flowing title and rules panels, handprinted texture and all text EXACTLY.
Only change the four OUTERMOST corners to a subtle matching rounded rectangle, corner radius approximately 4% of card width (about 40px at 1024px wide). The actual card silhouette must have TRUE ALPHA TRANSPARENCY outside the card, no opaque black rectangular backdrop, no checkerboard printed into the image, no drop shadow. Crop tightly to a portrait 2:3 card at ideally 1024x1536; the four sides of the card touch the canvas bounds, only the tiny quarter-circle corner cutouts are transparent. Keep a full-width lavender edge so nothing is cut off.
Exact existing title "도끼 용병", subtitle "용병 · 일회 계약", rules "나무에 사용하면 벌목합니다." and "작업을 마치면 귀가합니다.". Do not repaint or redesign the content. Do not add icons, costs or stats. Slight rounding only; do not make pill-shaped or heavily rounded corners.
```

## wool

```text
Use case: precise-object-edit / background-extraction.
Asset type: production transparent PNG card face for 마녀산장.
Image 1 is the EDIT TARGET wool resource card. Preserve ALL existing content exactly: ivory wool in wicker basket, distant sheep, snowy teal forest and warm lodge, original printed ink texture, lavender frame with asymmetric black S curves, flowing cream title/effect panels, all Hangul.
Image 2 is ONLY the updated rounded-edge/transparent silhouette reference. Match its subtle four rounded OUTERMOST corners, radius about 4% of card width. Replace the EDIT TARGET's opaque black outer background with real alpha transparency. No visible black rectangle, no shadow, no fake checkerboard.
One upright front-facing 2:3 card ideally 1024x1536, as tightly cropped as possible with only transparent tiny corner cutouts. Card fills the canvas. No redesign or content changes. Do NOT alter the illustration or typography.
Exact text: title "양털"; category "자원 · 수확 재료"; bottom "양에게 다가가 수확합니다." then "산장에서 판매할 수 있습니다.". No costs, numbers, extra symbols, watermark.
```

## forest_monster

```text
Use case: precise-object-edit / background-extraction.
Asset type: production transparent PNG face for 마녀산장.
Image 1 is the EDIT TARGET forest monster card. Keep every existing interior pixel, all typography and creature identity as close to the source as possible. Keep branch antlers, yellow-green eyes, mossy wood shoulders, teal snowy woods, large black print contours and original cream/lavender asymmetric S-curve framing.
Image 2 is ONLY the target edge treatment: axe mercenary revised silhouette. Match its subtle 40px radius corners, NOT large oval corners, no added thin black outer outline.
The only edit: remove the opaque black rectangular outside margin, use REAL ALPHA TRANSPARENCY outside the slightly rounded outermost lavender card edge. Exactly four gently rounded corners of approximately 4% width (40px at 1024), same rounding at top and bottom. Tight portrait 2:3 canvas ideally 1024x1536. No shadow, no added border, no checkerboard baked into the image. Preserve all content, do not repaint title or rules.
Exact text: "숲의 괴물"; "몬스터 · 하수인 소환"; "처치하면 카드를 얻습니다."; "사용하면 하수인을 소환합니다.". No costs, stats, gems, watermark or changes to wording.
```

## timber

```text
Use case: stylized-concept.
Asset type: ONE complete illustrated Korean game card for 마녀산장, production transparent PNG.
Input Image 1 is the approved existing rounded axe card, frame and ink-print style reference. Input Image 2 is wool card reference for RESOURCE visual composition. Create the missing TIMBER resource card in exactly this same set.
One front-facing upright portrait 2:3 card, ideally 1024x1536, tightly cropped to the complete card. Keep dusty muted violet outer framing, bold asymmetric black S sweep down the upper left and opposite black curve ascending lower right, flowing warm cream title panel above and rules panel below, proportions as image 1, rich woodcut-like ink print grain, thick varying black outlines, broad flat colors. No added thin black outer outline.
OUTER SHAPE: only very subtly rounded outermost corners, radius about 40px at 1024px width (4%), same at all four corners. REAL alpha transparency outside silhouette, no opaque rectangle, shadow or checkerboard. Card fills canvas.
SUBJECT: a clearly readable RESOURCE pile of freshly chopped timber, three or four short thick pine logs tightly gathered with coarse simple rope, pale ochre cut ends with broad visible annual rings, dark warm brown rough bark, a few wooden splinters beside a low snowy stump. Timber fills the central illustration, dominant and recognizable even as a small hand card. Behind it a very simple teal snowy pine forest, with a tiny distant amber lodge window. No person, monster, axe wielder or saw machinery. Match the wool card's restrained winter background, ivory snow, orange ochre subject contrast and bold graphic silhouette. Keep left/right S framing clear. No photorealism, gradients or 3D, no ornate new decorations, costs, stats or numbers.
Exact Korean lettering black handlettered same as reference, verbatim and fully legible:
Top title: "목재"
Category below: "자원 · 벌목 재료"
Bottom first line: "벌목을 마치면 얻습니다."
Bottom second line: "산장 수리에 사용할 수 있습니다."
No extra words or watermark.
```

