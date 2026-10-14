# 달빛 마법 UI 에셋 생성 프롬프트

내장 image_gen. 원본 기준: approved/atlas.png. 숫자용 빈 영역만 실사용 atlas에 반영하며, 원본 정적 픽셀을 패키징 도구로 보존한다.

## dynamic-atlas

```text
Use case: precise-object-edit. This image is our APPROVED 1774x887 transparent game HUD atlas. We need exactly the same HUD for a functional game. Maintain identical canvas size, layout, positions, silhouettes, colors, alpha boundaries, paint style and every illustration. Edit ONLY the following dynamic interiors by removing their text cleanly and rebuilding the underlying flat surface: top-left erase numeric values 100/100 and 300/300; top-left erase the red and turquoise bar fills leaving EMPTY dark progress tracks and their original outlines; top-center erase "1일차 · 낮" and "밤까지 00:35" leaving dark clean label interiors, erase amber progress fill leaving empty dark track with intact outline and sun/moon; top-right erase numbers 40,3,2 leaving gold/log/wool icons unchanged; objective paper erase ONLY its bottom instruction "◆ 손님을 맞이하세요" leaving blank cream paper, keep title "오늘의 할 일" and scroll; at cards bottom erase ONLY ×2 and ×3 numerals inside circular count badges, leave their circular frames; bottom-right erase ONLY "120G" in disabled dragon button, keep "용 공물" and dragon illustration. Preserve all other Korean words, card titles, hero portrait, every illustrated card, moon, teal curls, resource art, storage pouch, lodge button and pause. DO NOT move, resize, redesign or reinterpret ANY component. Not a new style variation. No new objects. No new text. All outside-UI pixels must stay genuinely transparent.
```

## dragon-enabled

```text
Use case: precise-object-edit. Approved reference image is our existing transparent midnight witch HUD atlas. Produce ONLY an ENABLED version of the dragon offering button at bottom-right of that reference, on a true transparent background. One isolated icon-button, no other HUD components. Preserve exactly its original compact silhouette: a dragon head facing left rising above a low rounded plum plaque, ears/horns and flowing long neck inside a curved outer ring, cyan thin edge. Convert existing grey disabled dragon to ACTIVE: dragon illustration in rich muted violet with warm creamlit details, dark indigo shadow and very small turquoise eye, matching moon UI and original chunky ink/cel-shaded artwork. Keep label plaque EMPTY, no letters/numerals. Same proportions and pose as the disabled original, no wings or flame, no new decoration. The button must look like the same object in a usable state, not a new illustration. Single asset centered, tight useful framing, PNG RGBA no background, no scene, no ground shadow, no fake checkerboard.
```

## extension-sheet

```text
Use case: ui-mockup. Create a production sprite sheet of additional generic UI pieces for our approved MOON WITCH HUD in the reference. These are expansion elements used only in popups not shown in the approved HUD. Match exact midnight indigo/plum interiors, thin cream edges, restrained teal S curls/crescent, crisp hand-inked 2-3 tone shapes. TRUE TRANSPARENT background. Square 2048x2048 canvas, strict 2 columns by 4 rows, each cell 1024x512. Each asset centered entirely inside its own cell with at least 40px transparent padding. NO labels, NO text, NO numerals, NO letters, no grid lines, no backgrounds between assets. Row1 col1: wide rectangular modal PANEL with gently rounded corners, sparse tiny crescent at upper left outer edge, a VERY LARGE plain matte indigo central interior so it can be 9-sliced. Row1 col2: rectangular cream-paper TOOLTIP panel with dark plum rim and tiny teal curved tips, large blank cream interior, no pointer. Row2 col1: long narrow dark indigo TOAST plaque with cream thin rim, sparse cyan flourish at ends, empty center. Row2 col2: wide low NORMAL BUTTON, indigo curved plaque with cream edge and teal ends, completely blank center. Row3 col1: same wide low button in HOVER/FOCUS state with slightly brighter teal rim, same silhouette. Row3 col2: same button DISABLED with low contrast grey-violet rim, same silhouette. Row4 col1: two separate thin horizontal SCROLLBAR pieces, an empty dark track above and a short teal-plum rounded thumb below, with no overlap. Row4 col2: a clean horizontal DIVIDER with tiny centered crescent and very small stars, cream and teal tips. Avoid ornate filigree, steampunk, shiny gold, neon sci-fi or wood texture. No cards or characters. Complete all 8 cells exactly.
```


