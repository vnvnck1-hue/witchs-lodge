# 직업 픽토그램 v01 — 내장 이미지 생성 프롬프트

- 제작일: 2026-10-19
- 방식: 내장 `image_gen.imagegen`, 각 직업별 1회, `transparent_background=true`. 외부 API·CLI 생성 미사용.
- 용도: 중세 기반 판타지 직업 배지용 그림. 카드 원화·게임 코드 수정 아님.
- 호출당 참고 입력 최대 5장. 최초 8장 전달은 도구 인자 검증에서 거절되어 이미지가 생성되지 않았음. 아래처럼 각 호출에 공통 UI 3장 + 해당 직업 카드 + 화면 1장을 실제 `referenced_image_paths`로 전달하여 요청서의 8장 전부를 사용함.
- 원본은 `art/ui/job-pictograms-v01/*-generated.png`에 그대로 보존. 재생성·폐기 시안 없음.
- 후처리: 원래 알파를 유지하고 원본 RGB를 크림 #FCE7B0·먹선 #2A1A12·직업별 단일 강조색(은빛 #D8D8DC 또는 버섯 #C24837)으로 최근접 정리. 알파 경계 기준 균등 축소 및 중앙 배치, 긴 변 108px, 128×128 RGBA. 도형 재작화·배경 합성 없음. 가장자리 안티앨리어싱 유지.

## warrior

원본: `art/ui/job-pictograms-v01/warrior-generated.png`

실제 참고 입력(순서대로):

- `godot/assets/ui/icons/icon_timber.png`
- `godot/assets/ui/icons/icon_raw_meat.png`
- `godot/assets/ui/icons/icon_moonlit_charm.png`
- `godot/assets/cards/hand/warrior.png`
- `godot/screenshots/party-frames/medallion-right-hover.png`

실제 프롬프트:

```text
Use case: stylized-concept.
Create ONE production game UI job pictogram on a genuinely transparent background. This is for Witch's Lodge, a medieval-based fantasy world retaining medieval everyday tools and atmosphere with fantasy adaptation allowed.
Use the supplied five images as actual visual reference inputs: images 1-3 establish strong dark ink contour and warm game palette; image 4 is this job's contract card, use its medieval tools and mood only; image 5 establishes the tiny job badge at the upper left of a portrait medallion and background contrast. Do NOT copy the text, card frame, portraits or screenshot background.
Output a square isolated pictogram, designed for final 128x128 RGBA and display at only 20x20 pixels. Center the complete silhouette inside the canvas with approximately 10px equivalent clear margin on all sides. Bold extremely simple chunky silhouette, flat solid cream #FCE7B0 body and uniform deep brown #2A1A12 contours, 6px equivalent at 128px (about 48px at 1024). Minimal internal strokes, same weight, round ink joins. At most one accent color if specified. Almost two-tone. No thin ornament, grain, hatching, gradients, shadows, glow, vignette, tiny highlights, photorealism, text, letters or numbers. No circular badge, frame, border, background plate or surrounding disk: the game draws those. Preserve empty space as true alpha. Read clearly on dark navy-purple, dark orange, dark green, dark lavender.
Subject: one straight-bladed medieval longsword over the FRONT of one round wooden shield. Shield behind toward lower-right; sword crosses it diagonally from hilt lower-left to straight pointed blade upper-right. Recognizably round shield, simple 2 broad plank divisions; sword has a simple crossguard. All cream and deep brown, no extra accent, no metal studs, no decoration. The round shield is the required object, not a surrounding badge.
```

## hunter

원본: `art/ui/job-pictograms-v01/hunter-generated.png`

실제 참고 입력(순서대로):

- `godot/assets/ui/icons/icon_timber.png`
- `godot/assets/ui/icons/icon_raw_meat.png`
- `godot/assets/ui/icons/icon_moonlit_charm.png`
- `godot/assets/cards/hand/hunter.png`
- `godot/screenshots/party-frames/medallion-right-hover.png`

실제 프롬프트:

```text
Use case: stylized-concept.
Create ONE production game UI job pictogram on a genuinely transparent background. This is for Witch's Lodge, a medieval-based fantasy world retaining medieval everyday tools and atmosphere with fantasy adaptation allowed.
Use the supplied five images as actual visual reference inputs: images 1-3 establish strong dark ink contour and warm game palette; image 4 is this job's contract card, use its medieval tools and mood only; image 5 establishes the tiny job badge at the upper left of a portrait medallion and background contrast. Do NOT copy the text, card frame, portraits or screenshot background.
Output a square isolated pictogram, designed for final 128x128 RGBA and display at only 20x20 pixels. Center the complete silhouette inside the canvas with approximately 10px equivalent clear margin on all sides. Bold extremely simple chunky silhouette, flat solid cream #FCE7B0 body and uniform deep brown #2A1A12 contours, 6px equivalent at 128px (about 48px at 1024). Minimal internal strokes, same weight, round ink joins. At most one accent color if specified. Almost two-tone. No thin ornament, grain, hatching, gradients, shadows, glow, vignette, tiny highlights, photorealism, text, letters or numbers. No circular badge, frame, border, background plate or surrounding disk: the game draws those. Preserve empty space as true alpha. Read clearly on dark navy-purple, dark orange, dark green, dark lavender.
Subject: one drawn medieval longbow with one nocked arrow, arrowhead points upper-right diagonally. Clear tall curved bow on right, chunky taut V-shaped bowstring pulled toward lower-left, one bold arrow shaft running lower-left to upper-right through the middle, large triangular arrowhead. Cream and deep brown with only pale silver arrowhead as optional single accent. No hands or person, no quiver, no extra arrows. Bowstring must be robust enough to survive 20px display, not hairline.
```

## lumberjack

원본: `art/ui/job-pictograms-v01/lumberjack-generated.png`

실제 참고 입력(순서대로):

- `godot/assets/ui/icons/icon_timber.png`
- `godot/assets/ui/icons/icon_raw_meat.png`
- `godot/assets/ui/icons/icon_moonlit_charm.png`
- `godot/assets/cards/hand/lumberjack.png`
- `godot/screenshots/party-frames/medallion-right-hover.png`

실제 프롬프트:

```text
Use case: stylized-concept.
Create ONE production game UI job pictogram on a genuinely transparent background. This is for Witch's Lodge, a medieval-based fantasy world retaining medieval everyday tools and atmosphere with fantasy adaptation allowed.
Use the supplied five images as actual visual reference inputs: images 1-3 establish strong dark ink contour and warm game palette; image 4 is this job's contract card, use its medieval tools and mood only; image 5 establishes the tiny job badge at the upper left of a portrait medallion and background contrast. Do NOT copy the text, card frame, portraits or screenshot background.
Output a square isolated pictogram, designed for final 128x128 RGBA and display at only 20x20 pixels. Center the complete silhouette inside the canvas with approximately 10px equivalent clear margin on all sides. Bold extremely simple chunky silhouette, flat solid cream #FCE7B0 body and uniform deep brown #2A1A12 contours, 6px equivalent at 128px (about 48px at 1024). Minimal internal strokes, same weight, round ink joins. At most one accent color if specified. Almost two-tone. No thin ornament, grain, hatching, gradients, shadows, glow, vignette, tiny highlights, photorealism, text, letters or numbers. No circular badge, frame, border, background plate or surrounding disk: the game draws those. Preserve empty space as true alpha. Read clearly on dark navy-purple, dark orange, dark green, dark lavender.
Subject: one medieval SINGLE-BITTED woodcutting axe. Thick wooden haft runs diagonally from lower-left to upper-right, with a single very large broad blade extending to upper-left of the haft near the top. Flat cream handle, deep brown contours, only pale silver flat axe blade as one accent. Short bold silhouette, broad cutting edge, no double-headed axe, no wood log, no snow, no tiny wood grain.
```

## gatherer

원본: `art/ui/job-pictograms-v01/gatherer-generated.png`

실제 참고 입력(순서대로):

- `godot/assets/ui/icons/icon_timber.png`
- `godot/assets/ui/icons/icon_raw_meat.png`
- `godot/assets/ui/icons/icon_moonlit_charm.png`
- `godot/assets/cards/hand/gatherer.png`
- `godot/screenshots/party-frames/medallion-right-hover.png`

실제 프롬프트:

```text
Use case: stylized-concept.
Create ONE production game UI job pictogram on a genuinely transparent background. This is for Witch's Lodge, a medieval-based fantasy world retaining medieval everyday tools and atmosphere with fantasy adaptation allowed.
Use the supplied five images as actual visual reference inputs: images 1-3 establish strong dark ink contour and warm game palette; image 4 is this job's contract card, use its medieval tools and mood only; image 5 establishes the tiny job badge at the upper left of a portrait medallion and background contrast. Do NOT copy the text, card frame, portraits or screenshot background.
Output a square isolated pictogram, designed for final 128x128 RGBA and display at only 20x20 pixels. Center the complete silhouette inside the canvas with approximately 10px equivalent clear margin on all sides. Bold extremely simple chunky silhouette, flat solid cream #FCE7B0 body and uniform deep brown #2A1A12 contours, 6px equivalent at 128px (about 48px at 1024). Minimal internal strokes, same weight, round ink joins. At most one accent color if specified. Almost two-tone. No thin ornament, grain, hatching, gradients, shadows, glow, vignette, tiny highlights, photorealism, text, letters or numbers. No circular badge, frame, border, background plate or surrounding disk: the game draws those. Preserve empty space as true alpha. Read clearly on dark navy-purple, dark orange, dark green, dark lavender.
Subject: one chunky woven gathering basket with ONE large red-capped mushroom and a small cluster of TWO broad medicinal herb leaves rising above its rim. Basket and leaves cream, all uniform dark brown contours, mushroom cap muted brick red as the only accent. Just 2 or 3 broad basket weave marks, thick rim, compact basket body. No tall handle crossing the contents, no extra mushrooms, no tiny leaf veins or dots, no decorative texture.
```
