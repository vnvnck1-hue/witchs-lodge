# 용병 직업·야생 동물·유물 에셋 생성 프롬프트 v01

2026-10-15 · 내장 image_gen · 모든 이미지 transparent_background=true. CLI/API 경로는 사용하지 않았다.

카드는 기존 도끼 용병을 프레임·붓터치·한글 서체 참고로 사용했다. 채집가는 미라 초상을 추가 인물 참고로 사용했다. 아이콘은 기존 moon_runes 승인 아틀라스에서 시작해 icon_timber 원화를 공통 선·채도 참고로 썼다. 상자는 treasure_chest 카드 → chest_closed → chest_open 순서로 동일성을 유지했다.

코드 후처리는 카드의 불투명 본체 크롭과 Lanczos 크기 정규화, UI 원화의 Lanczos 축소만 수행한다. 그림·문자·알파 마스크를 코드로 덧그리지 않았다. 토끼 가죽과 미공개 유물은 첫 검증의 외곽 알파 실패를 image_gen 수정으로 해결했다.

각 항목의 생성 파일은 원본 보존 디렉터리의 파일명이며, 최종본은 프로젝트에 복사했다. 모든 최종 소스·배포 SHA-256은 art/cards/manifest.json과 output/jobs-update-v01/delivery-manifest.json에 기록한다.

## lumberjack · 나무꾼

최종 채택 생성 파일: `exec-a23d40c0-f96e-464c-91b7-958e199e02ea.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: A burly bearded lumberjack man in fur cap and thick orange plaid coat, large axe over shoulder, tied bundle of logs on his back, snowy pine stump and woodchips.
Exact printed text: title "나무꾼"; category "용병 · 벌목 계약"; bottom first line "나무에 사용하면 벌목합니다."; bottom second line "목재를 들고 있다가 건네줍니다.".
```

## hunter · 사냥꾼

최종 채택 생성 파일: `exec-a27969cc-90f1-43d5-ba9f-98a665a87278.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: A leather-hooded hunter with fur shoulders drawing a longbow correctly with taut bowstring and nocked arrow, quiver and small rabbit pelt at waist. Distant deer silhouette between snowy trees.
Exact printed text: title "사냥꾼"; category "용병 · 사냥 계약"; bottom first line "낮에는 토끼와 사슴을 사냥합니다."; bottom second line "밤에는 활로 산장을 지킵니다.".
```

## warrior · 전투용병

최종 채택 생성 파일: `exec-5b1861c0-3475-4515-b591-6a026ecfd997.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: A rugged bearded warrior in leather armor, round wooden shield in one hand and sword held upright in the other, standing in snow in front of lodge, warm distant windows.
Exact printed text: title "전투용병"; category "용병 · 전투 계약"; bottom first line "산장 주변을 정찰합니다."; bottom second line "적이 오면 검으로 맞섭니다.".
```

## gatherer · 채집가

최종 채택 생성 파일: `exec-57eeb240-790b-4e95-917b-9faef75b5854.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: Female gatherer walking a snowy forest path, back basket, lantern in one hand and gathered mushrooms and twigs in other. Image2 is character identity reference: Mira's copper red braid, freckles, teal coat, purple cloak, cream scarf. Translate her to card reference woodcut style.
Exact printed text: title "채집가"; category "용병 · 채집 계약"; bottom first line "낮에 숲을 탐색하고 돌아옵니다."; bottom second line "쓸모 있는 것을 주워 옵니다.".
```

## raw_meat · 생고기

최종 채택 생성 파일: `exec-9be44ed4-df77-4c1b-8ad8-75d88d0d8be9.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: Two fresh red cuts of meat on a broad green leaf, handful of snow and a small clean bone. Tasteful butchered food resource, no gore.
Exact printed text: title "생고기"; category "자원 · 사냥 재료"; bottom first line "사냥과 채집으로 얻습니다."; bottom second line "판매하거나 마녀가 먹습니다.".
```

## rabbit_pelt · 토끼 가죽

최종 채택 생성 파일: `exec-aaf75b30-4451-498f-a673-65670e2788b5.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: Spread gray-brown rabbit pelt, one remaining ear shape, tied leather cord knot on snow. Clearly a cured pelt resource, no living animal, no gore.
Exact printed text: title "토끼 가죽"; category "자원 · 사냥 재료"; bottom first line "토끼를 사냥하면 얻습니다."; bottom second line "산장에서 판매할 수 있습니다.".
```

### 외곽 알파 수정 · 최종 채택

```text
Use case: precise-object-edit / background-extraction. Image1 is EDIT TARGET: preserve its entire artwork, all exact Korean lettering, same lavender physical cardboard, black S-curve framing and cream title/rules panels. Change ONLY outermost alpha boundary: crisp subtly rounded rectangle radius40px at1024 width, same radius at all four corners, straight edges. Physical lavender card must be FULLY OPAQUE including outer lavender border. Canvas1024x1536 tightly cropped to card, midpoints of straight edges touch canvas. Four very corner pixels must be truly transparent alpha0, antialias only1px at curved boundary. Remove any halo/soft translucency/outside shadow. DO NOT use global translucent opacity: card center and lavender edges must be alpha255. Do not add a thin outside outline. Do not remove lavender material. Outside the rounded lavender card only is true alpha0. Keep original typography EXACTLY and without adding words. Text invariants: "토끼 가죽"; "자원 · 사냥 재료"; "토끼를 사냥하면 얻습니다."; "산장에서 판매할 수 있습니다."
```

## treasure_chest · 보물상자

최종 채택 생성 파일: `exec-d4a1be79-a380-4a6e-a288-58065c9d461b.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: An old rounded oak chest half buried in snow, dark iron reinforcing bands, front lock plate with brass crescent moon emblem, thin warm golden light leaking from lid seam. Moss and frost.
Exact printed text: title "보물상자"; category "보물 · 숲의 발견"; bottom first line "땅에 놓으면 상자가 열립니다."; bottom second line "유물 셋 중 하나를 고릅니다.".
```

## relic_unknown · ?

최종 채택 생성 파일: `exec-e64728bb-2d6d-4ecd-a810-a5cc19bf27d3.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: ONE very large golden glowing question mark centered over dark purple mist, no other illustration elements. Top title is ? and category below it. Keep cream bottom panel blank: NO rules text.
Exact printed text: title "?"; category "유물 · 미공개"; bottom cream panel BLANK no text. One large question mark in artwork.
```

### 외곽 알파 수정 · 최종 채택

```text
Use case: precise-object-edit / background-extraction. Image1 is EDIT TARGET: preserve its entire artwork, all exact Korean lettering, same lavender physical cardboard, black S-curve framing and cream title/rules panels. Change ONLY outermost alpha boundary: crisp subtly rounded rectangle radius40px at1024 width, same radius at all four corners, straight edges. Physical lavender card must be FULLY OPAQUE including outer lavender border. Canvas1024x1536 tightly cropped to card, midpoints of straight edges touch canvas. Four very corner pixels must be truly transparent alpha0, antialias only1px at curved boundary. Remove any halo/soft translucency/outside shadow. DO NOT use global translucent opacity: card center and lavender edges must be alpha255. Do not add a thin outside outline. Do not remove lavender material. Outside the rounded lavender card only is true alpha0. Keep original typography EXACTLY and without adding words. Text invariants: title "?"; category "유물 · 미공개"; one large golden question mark on dark purple mist; blank cream bottom panel. No rules.
```

## moonlit_charm · 달빛 부적

최종 채택 생성 파일: `exec-3013f083-3a0a-4773-b1d9-8f57d08f0d9f.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: Silver crescent moon amulet on silver chain, central purple gemstone, luminous moonlight. A small part of witch's hand holding chain.
Exact printed text: title "달빛 부적"; category "유물 · 마녀의 힘"; bottom first line "마녀의 마법탄이 강해집니다."; bottom second line "더 멀리 닿습니다.".
```

## hearth_ember · 화로의 온기석

최종 채택 생성 파일: `exec-a53e0d03-7937-4b99-9822-0bd106c73935.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: Palm-sized round stone with amber glowing ember pulsing within, broad runes carved on stone, warm light melts snow beneath.
Exact printed text: title "화로의 온기석"; category "유물 · 산장의 온기"; bottom first line "산장 곁의 아군이 회복합니다."; bottom second line "아침마다 산장이 아물어 갑니다.".
```

## old_tree_heart · 고목의 심장

최종 채택 생성 파일: `exec-98d83324-6999-4915-bf33-81807337652a.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: Green glowing wooden heart formed by heart-shaped knot encircled by old tree roots, small sprouts and leaves, glowing sap.
Exact printed text: title "고목의 심장"; category "유물 · 숲의 축복"; bottom first line "벌목이 빨라집니다."; bottom second line "목재를 더 많이 얻습니다.".
```

## wolf_fang_pendant · 늑대 송곳니 목걸이

최종 채택 생성 파일: `exec-e358867d-51d6-419c-b63c-1cfb517298bf.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: THREE large ivory wolf fangs and small beads strung on leather cord necklace lying on snow, blurred wolf footprints behind. Shorten title size only as necessary to fit full exact wording.
Exact printed text: title "늑대 송곳니 목걸이"; category "유물 · 사냥의 본능"; bottom first line "사냥꾼과 전투용병이 강해집니다."; bottom second line "사냥감에서 더 얻습니다.".
```

## frost_queen_tear · 서리 여왕의 눈물

최종 채택 생성 파일: `exec-7f96f735-1f09-47d6-96ba-789a0dc3c961.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. Asset type: ONE production card for Korean winter forest game 마녀산장. Image 1 is a STYLE AND FRAME REFERENCE only. Create a NEW card in exactly this set: identical dusty lavender physical outer cardboard, broad black asymmetric S sweep down upper left and opposite lower right, flowing cream top title/category panel and bottom two-line rules panel. Thick black woodcut brush outlines, lively flat gouache brush marks, textured ink, teal snowy pine woods and warm ivory snow. Match reference layout and Korean hand-brushed typography. No game numbers, costs, stats, watermark, extra text. Portrait 2:3 ideally1024x1536. Card fills canvas tightly; subtly rounded outermost corners radius40px (4% width); true alpha outside the four rounded corners. Lavender edge is OPAQUE physical card and must remain, center and straight edges fully opaque. NO shadow, backdrop, fake checkerboard, halo or thin added outside outline. Exact Hangul must be perfectly legible.
SUBJECT: Teardrop-shaped blue ice crystal containing a single small snowflake, surrounding growing frost crystals and cold rising vapor.
Exact printed text: title "서리 여왕의 눈물"; category "유물 · 겨울의 저주"; bottom first line "모든 적이 느려집니다."; bottom second line "아침마다 서리 룬을 얻습니다.".
```

## icon_timber · icon_timber

최종 채택 생성 파일: `exec-e477e63e-7300-4d46-8679-785f31ae829b.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE small inventory game icon for 마녀산장, isolated on TRUE transparent background. Reference image1 shows existing UI art tone. Subject THREE short pine logs bundled tightly with beige rope, readable ochre cut ends. Simple bold compact silhouette, thick near-black ink outlines about5px at96px final, broad muted warm brown/ochre colors, sparse gouache brush texture, slight ivory highlight, subtle lavender shadow INSIDE object. Square1024 master, design to read at96x96. Object fills80% of square, centered, no framing, no circle, no text, no backdrop, no cast shadow, no glow outside object.
```

## icon_raw_meat · icon_raw_meat

최종 채택 생성 파일: `exec-2ef21da7-166c-4323-b509-bad8a2b7c8ca.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE compact game inventory icon for 마녀산장, TRUE transparent background, square1024 master to be downscaled to96x96. Image1 is LINE WEIGHT, PALETTE and style reference only: use the SAME thick near-black ink outline (5px at96px final), simple bold silhouette, broad muted medium saturation colors, sparse gouache brush marks, ivory highlights and subtle lavender shadow INSIDE object. Center entire object within80% of square, no crop. No frame, circle, text, scene, ground plane, backdrop, cast shadow or glow outside object.
SUBJECT: Two red cuts of meat on one small green leaf, cream fat stripes, no gore.
```

## icon_rabbit_pelt · icon_rabbit_pelt

최종 채택 생성 파일: `exec-f68d474a-a308-4ff1-b6c1-a8b847c7b718.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE compact game inventory icon for 마녀산장, TRUE transparent background, square1024 master to be downscaled to96x96. Image1 is LINE WEIGHT, PALETTE and style reference only: use the SAME thick near-black ink outline (5px at96px final), simple bold silhouette, broad muted medium saturation colors, sparse gouache brush marks, ivory highlights and subtle lavender shadow INSIDE object. Center entire object within80% of square, no crop. No frame, circle, text, scene, ground plane, backdrop, cast shadow or glow outside object.
SUBJECT: Flat cured gray brown rabbit pelt with one long ear and leather knot, pale fur edge, no eyes or living face.
```

## icon_treasure_chest · icon_treasure_chest

최종 채택 생성 파일: `exec-599bed85-1f98-4faf-b7b5-11451df93534.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE compact game inventory icon for 마녀산장, TRUE transparent background, square1024 master to be downscaled to96x96. Image1 is LINE WEIGHT, PALETTE and style reference only: use the SAME thick near-black ink outline (5px at96px final), simple bold silhouette, broad muted medium saturation colors, sparse gouache brush marks, ivory highlights and subtle lavender shadow INSIDE object. Center entire object within80% of square, no crop. No frame, circle, text, scene, ground plane, backdrop, cast shadow or glow outside object.
SUBJECT: Closed rounded oak treasure chest with dark iron bands and a gold crescent moon lock, same chest as card.
```

## icon_relic_unknown · icon_relic_unknown

최종 채택 생성 파일: `exec-c62b3614-c2b5-4672-8ba9-57f5723977da.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE compact game inventory icon for 마녀산장, TRUE transparent background, square1024 master to be downscaled to96x96. Image1 is LINE WEIGHT, PALETTE and style reference only: use the SAME thick near-black ink outline (5px at96px final), simple bold silhouette, broad muted medium saturation colors, sparse gouache brush marks, ivory highlights and subtle lavender shadow INSIDE object. Center entire object within80% of square, no crop. No frame, circle, text, scene, ground plane, backdrop, cast shadow or glow outside object.
SUBJECT: One bold golden question mark, dark purple inner shading.
```

## icon_moonlit_charm · icon_moonlit_charm

최종 채택 생성 파일: `exec-d79488d6-d1e7-4aaf-9359-204a8a77e5b6.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE compact game inventory icon for 마녀산장, TRUE transparent background, square1024 master to be downscaled to96x96. Image1 is LINE WEIGHT, PALETTE and style reference only: use the SAME thick near-black ink outline (5px at96px final), simple bold silhouette, broad muted medium saturation colors, sparse gouache brush marks, ivory highlights and subtle lavender shadow INSIDE object. Center entire object within80% of square, no crop. No frame, circle, text, scene, ground plane, backdrop, cast shadow or glow outside object.
SUBJECT: Silver crescent moon pendant with purple central gem, small loop of silver chain.
```

## icon_hearth_ember · icon_hearth_ember

최종 채택 생성 파일: `exec-3a5a7d93-b58f-44a4-9056-1e5ab4931101.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE compact game inventory icon for 마녀산장, TRUE transparent background, square1024 master to be downscaled to96x96. Image1 is LINE WEIGHT, PALETTE and style reference only: use the SAME thick near-black ink outline (5px at96px final), simple bold silhouette, broad muted medium saturation colors, sparse gouache brush marks, ivory highlights and subtle lavender shadow INSIDE object. Center entire object within80% of square, no crop. No frame, circle, text, scene, ground plane, backdrop, cast shadow or glow outside object.
SUBJECT: Rounded charcoal stone with glowing amber core and three broad simple carved runes.
```

## icon_old_tree_heart · icon_old_tree_heart

최종 채택 생성 파일: `exec-9df8448b-22fa-4e0a-bccf-75620109548f.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE compact game inventory icon for 마녀산장, TRUE transparent background, square1024 master to be downscaled to96x96. Image1 is LINE WEIGHT, PALETTE and style reference only: use the SAME thick near-black ink outline (5px at96px final), simple bold silhouette, broad muted medium saturation colors, sparse gouache brush marks, ivory highlights and subtle lavender shadow INSIDE object. Center entire object within80% of square, no crop. No frame, circle, text, scene, ground plane, backdrop, cast shadow or glow outside object.
SUBJECT: Green glowing heart-shaped wooden knot wrapped in warm brown roots with two little leaves.
```

## icon_wolf_fang_pendant · icon_wolf_fang_pendant

최종 채택 생성 파일: `exec-8f48773a-9b58-4cc6-8c30-cf9d7ebbfe91.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE compact game inventory icon for 마녀산장, TRUE transparent background, square1024 master to be downscaled to96x96. Image1 is LINE WEIGHT, PALETTE and style reference only: use the SAME thick near-black ink outline (5px at96px final), simple bold silhouette, broad muted medium saturation colors, sparse gouache brush marks, ivory highlights and subtle lavender shadow INSIDE object. Center entire object within80% of square, no crop. No frame, circle, text, scene, ground plane, backdrop, cast shadow or glow outside object.
SUBJECT: Leather cord necklace with THREE chunky ivory wolf fangs and two small teal beads.
```

## icon_frost_queen_tear · icon_frost_queen_tear

최종 채택 생성 파일: `exec-62d7517c-090d-4534-acd6-5e347fef36fe.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE compact game inventory icon for 마녀산장, TRUE transparent background, square1024 master to be downscaled to96x96. Image1 is LINE WEIGHT, PALETTE and style reference only: use the SAME thick near-black ink outline (5px at96px final), simple bold silhouette, broad muted medium saturation colors, sparse gouache brush marks, ivory highlights and subtle lavender shadow INSIDE object. Center entire object within80% of square, no crop. No frame, circle, text, scene, ground plane, backdrop, cast shadow or glow outside object.
SUBJECT: Blue teardrop ice gem containing one white snowflake, a few broad angular ice facets.
```

## icon_arrow · icon_arrow

최종 채택 생성 파일: `exec-af0d21c1-fab0-4085-a601-2f343f0a9bbb.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE compact game inventory icon for 마녀산장, TRUE transparent background, square1024 master to be downscaled to96x96. Image1 is LINE WEIGHT, PALETTE and style reference only: use the SAME thick near-black ink outline (5px at96px final), simple bold silhouette, broad muted medium saturation colors, sparse gouache brush marks, ivory highlights and subtle lavender shadow INSIDE object. Center entire object within80% of square, no crop. No frame, circle, text, scene, ground plane, backdrop, cast shadow or glow outside object.
SUBJECT: ONE arrow diagonally bottom-left to top-right, wooden shaft, dark triangular iron point and cream feather fletching.
```

## chest_closed · chest_closed

최종 채택 생성 파일: `exec-a89aecf1-0827-4ac3-9b7e-9178c53faf3d.png`.

### 최초 생성 프롬프트

```text
Use case: stylized-concept. ONE isolated closed treasure chest UI illustration for 마녀산장, TRUE transparent background, square1024 master for512x512. Input image1 is chest IDENTITY reference from card; KEEP same rounded oak planks, two riveted dark iron bands, front shield-shaped iron lockplate with gold crescent moon over keyhole, a little moss and frost on lid. Three-quarter view, centered full chest fills85% square. Thick black woodcut outlines and gouache textured warm brown wood, ivory snow, subdued iron lavender, thin golden light leaking from lid seam. Lid CLOSED. Only chest with a small amount of snow attached, no forest, no ground plane, no text, no card frame, no backdrop or cast shadow.
```

## chest_open · chest_open

최종 채택 생성 파일: `exec-b13e65bf-57c3-43c7-851f-321aa8c3c42b.png`.

### 최초 생성 프롬프트

```text
Use case: precise-object-edit. ONE isolated OPEN treasure chest UI illustration, square1024 master for512x512, TRUE transparent background. Image1 is the EXACT CLOSED CHEST to change: same rounded oak chest, same riveted two dark iron reinforcing bands, same front shield lockplate with gold crescent moon and keyhole, same moss and attached snow, same three-quarter camera, same thick black woodcut brushwork. OPEN only its lid by hinging it backwards away from viewer around rear hinge; reveal warm dark wooden interior and a broad golden magical beam and a few golden sparks rising upward from inside, reserved top space. Front base remains identical. Keep ENTIRE open chest and light inside square with8% transparent padding. No forest, ground plane, cards, text, extra objects, border, backdrop or cast shadow. Keep outside actual chest and golden light fully transparent.
```

## 3D 제작 기록

Blender 5.2.2 LTS에서 godot/art_sources/build_wildlife.py로 직접 메시를 제작했다. 생성 이미지나 외부 모델을 3D로 변환하지 않았다. 1m 단위, +Y 위, +Z 정면, 발바닥 Y=0. Col 코너 버텍스 컬러와 큰 평면 색, 텍스처 0개. Body/Head 피벗을 보존하고 몸·머리를 각 1메시로 통합했다.

토끼 2,528삼각형, 사슴 2,548삼각형. 비매니폴드 엣지·퇴화 면 모두 0. 편집용 wildlife.blend에 토끼·사슴 컬렉션을 보존한다. 두 컬렉션은 편집 편의를 위해 가로로 나란히 배치되며 각 GLB는 원점에서 내보낸다.
