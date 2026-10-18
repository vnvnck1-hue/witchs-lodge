# 늑대의 피 v01 · 실제 이미지 생성 기록

2026-10-18 · 내장 `image_gen` 사용. 모든 호출은 `transparent_background=true`. 참고 이미지는 `referenced_image_paths`로 실제 전달했다.

## wolf_blood · 첫 생성

실제 참고 입력:
- `art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`
- `godot/assets/cards/treasure_chest.png`
- `godot/assets/portraits/guest_fargh_cutout.png`

```text
Use case: illustration-story. Create ONE finished upright game card, exactly 1024x1536, true 2:3. Set the artwork in a medieval-based fantasy world, keeping medieval daily life and atmosphere while allowing familiar fantasy adaptations. Match supplied APPROVED role card's frame skeleton, purple stock, sweeping variable-width black ink, cream panels and painterly print texture; match existing game cards' style. Full rectangular card with subtly rounded corners, outside corners genuinely transparent, no background or shadow. Reserve title safe area x110..914 y72..236 for two lines even though title is short. Category separate at y267..307. Reserve one continuous cream rules panel x55..970 y1120..1495 and clean rules safe area x110..914 y1185..1445 for at least four lines. Adjust art height to those safe areas. No ornament, frame point or divider within text fields. No number, key letter Q/E, English, watermark, badge or extra text. Render the specified Korean verbatim in bold expressive black calligraphic ink similar to references, with accurate spelling, punctuation and spaces.
Reference 1 is the APPROVED EVENT frame/layout. Reference 2 is existing event card style. Reference 3 is Fargh character identity. Preserve EVENT wide scene window, folded banner ends outside title field and one broad unbroken rules panel. No central V notch, arrow or split. Scene: inside winter lodge with timber wall and warm hearth, gray-furred wolf beastman Fargh (with torn ear, medieval leather/fur clothes, matching portrait) offering a small bone-stoppered glass vial of dark red glowing liquid to the witch's reaching hand. Hands and vial central and legible; Fargh's head can be visible in upper left behind his offering hand, matching torn ear. No wounds or flowing blood. Violet-clothed witch receiving on right. Exact title: "늑대의 피". Exact category: "늑대 수인의 선물 · 변화". Exact two sentences in rules panel: "마녀에게 쓰면 잠시 고통스럽습니다." then "달의 힘 세 가지가 주머니에 들어옵니다." Wrap the latter at natural word boundaries within x110..914 if necessary, preserving every character.
```

재생성 이유: 큰 제목과 분류가 제목 2줄 여백을 압박해 제목·설명 크기와 패널 여백을 보완했다. 첫 생성은 `drafts/<id>-initial.png`, 채택한 재생성의 가공 전 원본은 `drafts/<id>-layout-generated.png`에 보존했다.

재생성 실제 참고 입력:
- `art/cards/wolf-blood-v01/drafts/wolf_blood-initial.png`
- `art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`
- `godot/assets/cards/treasure_chest.png`
- `godot/assets/portraits/guest_fargh_cutout.png`

```text
Edit reference image 1 only, a wolf_blood finished card. The other references are the APPROVED role frame, existing same-role cards and Fargh portrait, to preserve identity/style. Keep the illustration, subject, medieval fantasy winter setting, purple stock, bold tapering ink, role-specific art frame, rounded rectangular 2:3 shape, continuous cream bottom panel, and all Korean text EXACTLY the same. Change only the TEXT PANEL LAYOUT to provide real translation room. Output exactly 1024x1536 RGBA, outside rounded corners transparent.
Critical correction: the current oversized title and category occupy the same two-line safe zone. Make the title visibly smaller, about 70px high, placing its ink within y90..160. Keep x110..914 y170..236 CLEAR CREAM as the second title line slot. Move the existing category strip down to y267..307 in 38px type. Extend the cream title panel down to y330, following the same approved role's outline; art starts below this. This requires reducing art window height slightly, preserving its proportions as far as possible and full central subject. No ornament or category inside the title safe zone x110..914 y72..236.
Rules correction: reserve a continuous clean cream rules field x110..914 y1185..1445 with capacity for FOUR lines at 48px type and 60px line spacing. Keep both supplied sentences verbatim, but use approximately 48px type (smaller than the current type), all ink within x110..914. Center the two sentences in this larger field, wrapping a long sentence at word boundaries only when needed. No frame tip below y1120, no divider, ornament, notch or badge in rules safe zone. Keep all exact title/category/rules from reference 1, no extra text, no key letters or numbers. This is a precise margin/layout correction, preserve the beautiful scene and calligraphic print style.
```

## crescent_moon · 첫 생성

실제 참고 입력:
- `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
- `godot/assets/cards/frost_rune.png`
- `godot/assets/cards/vine_snare.png`
- `godot/assets/portraits/guest_fargh_cutout.png`

```text
Use case: illustration-story. Create ONE finished upright game card, exactly 1024x1536, true 2:3. Set the artwork in a medieval-based fantasy world, keeping medieval daily life and atmosphere while allowing familiar fantasy adaptations. Match supplied APPROVED role card's frame skeleton, purple stock, sweeping variable-width black ink, cream panels and painterly print texture; match existing game cards' style. Full rectangular card with subtly rounded corners, outside corners genuinely transparent, no background or shadow. Reserve title safe area x110..914 y72..236 for two lines even though title is short. Category separate at y267..307. Reserve one continuous cream rules panel x55..970 y1120..1495 and clean rules safe area x110..914 y1185..1445 for at least four lines. Adjust art height to those safe areas. No ornament, frame point or divider within text fields. No number, key letter Q/E, English, watermark, badge or extra text. Render the specified Korean verbatim in bold expressive black calligraphic ink similar to references, with accurate spelling, punctuation and spaces.
References 1 APPROVED SKILL frame/layout; 2 and 3 current SKILL card painterly ink style; 4 Fargh wolf identity background context only. Keep SKILL diamond art frame with black outline and thin cream inner stroke, tip ends above y1120, no badge. Scene: thin silver CRESCENT MOON clearly visible in winter indigo-violet night sky above snowy fir forest; witch in purple medieval cloak and pointed violet hat in lower center under the moon, silver light on her raised hand and staff tip, subtle slightly sharpened fingertips. No wolf yet. Palette moon silver, lavender snow, deep blue-purple forest. Exact title: "초승달". Exact category: "늑대의 피 · 밤의 힘". Exact rules lines: "밤에 마녀에게 씁니다." and "오늘 밤 공격 속도가 오릅니다."
Critical layout refinement: cream top panel must extend down to y330, title around y110..185 in approximately 70px type leaving the second-title-line slot unobstructed, category at y285 in 40px type. Diamond starts y340, left and right points y700, bottom point y1100. Rules use 48px type, text centered vertically with both sentences within x110..914. This reserves the requested larger translation spaces.
```

재생성 이유: 큰 제목과 분류가 제목 2줄 여백을 압박해 제목·설명 크기와 패널 여백을 보완했다. 첫 생성은 `drafts/<id>-initial.png`, 채택한 재생성의 가공 전 원본은 `drafts/<id>-layout-generated.png`에 보존했다.

재생성 실제 참고 입력:
- `art/cards/wolf-blood-v01/drafts/crescent_moon-initial.png`
- `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
- `godot/assets/cards/frost_rune.png`
- `godot/assets/cards/vine_snare.png`
- `godot/assets/portraits/guest_fargh_cutout.png`

```text
Edit reference image 1 only, a crescent_moon finished card. The other references are the APPROVED role frame, existing same-role cards and Fargh portrait, to preserve identity/style. Keep the illustration, subject, medieval fantasy winter setting, purple stock, bold tapering ink, role-specific art frame, rounded rectangular 2:3 shape, continuous cream bottom panel, and all Korean text EXACTLY the same. Change only the TEXT PANEL LAYOUT to provide real translation room. Output exactly 1024x1536 RGBA, outside rounded corners transparent.
Critical correction: the current oversized title and category occupy the same two-line safe zone. Make the title visibly smaller, about 70px high, placing its ink within y90..160. Keep x110..914 y170..236 CLEAR CREAM as the second title line slot. Move the existing category strip down to y267..307 in 38px type. Extend the cream title panel down to y330, following the same approved role's outline; art starts below this. This requires reducing art window height slightly, preserving its proportions as far as possible and full central subject. No ornament or category inside the title safe zone x110..914 y72..236.
Rules correction: reserve a continuous clean cream rules field x110..914 y1185..1445 with capacity for FOUR lines at 48px type and 60px line spacing. Keep both supplied sentences verbatim, but use approximately 48px type (smaller than the current type), all ink within x110..914. Center the two sentences in this larger field, wrapping a long sentence at word boundaries only when needed. No frame tip below y1120, no divider, ornament, notch or badge in rules safe zone. Keep all exact title/category/rules from reference 1, no extra text, no key letters or numbers. This is a precise margin/layout correction, preserve the beautiful scene and calligraphic print style.
```

## half_moon · 첫 생성

실제 참고 입력:
- `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
- `godot/assets/cards/frost_rune.png`
- `godot/assets/cards/vine_snare.png`
- `godot/assets/portraits/guest_fargh_cutout.png`

```text
Use case: illustration-story. Create ONE finished upright game card, exactly 1024x1536, true 2:3. Set the artwork in a medieval-based fantasy world, keeping medieval daily life and atmosphere while allowing familiar fantasy adaptations. Match supplied APPROVED role card's frame skeleton, purple stock, sweeping variable-width black ink, cream panels and painterly print texture; match existing game cards' style. Full rectangular card with subtly rounded corners, outside corners genuinely transparent, no background or shadow. Reserve title safe area x110..914 y72..236 for two lines even though title is short. Category separate at y267..307. Reserve one continuous cream rules panel x55..970 y1120..1495 and clean rules safe area x110..914 y1185..1445 for at least four lines. Adjust art height to those safe areas. No ornament, frame point or divider within text fields. No number, key letter Q/E, English, watermark, badge or extra text. Render the specified Korean verbatim in bold expressive black calligraphic ink similar to references, with accurate spelling, punctuation and spaces.
References 1 APPROVED SKILL frame/layout; 2 and 3 current SKILL card style; 4 Fargh wolf identity context only. Keep SKILL diamond black outline and thin cream inner stroke, bottom tip above y1120. Match a three-card moon family: winter indigo-violet sky, lavender snow, silver moonlight, dark firs. Scene: first-quarter HALF MOON, exactly right half illuminated and left half dark, clearly shaped semicircle high in sky. Purple-cloaked witch in pointed violet hat runs swiftly across snowy clearing within diamond, silver motion trails, hair blowing, yellow glowing eyes. No transformed wolf yet. Exact title: "상현달". Exact category: "늑대의 피 · 밤의 힘". Exact rules lines: "밤에 마녀에게 씁니다." and "오늘 밤 공격과 이동이 빨라집니다."
```

재생성 이유: 큰 제목과 분류가 제목 2줄 여백을 압박해 제목·설명 크기와 패널 여백을 보완했다. 첫 생성은 `drafts/<id>-initial.png`, 채택한 재생성의 가공 전 원본은 `drafts/<id>-layout-generated.png`에 보존했다.

재생성 실제 참고 입력:
- `art/cards/wolf-blood-v01/drafts/half_moon-initial.png`
- `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
- `godot/assets/cards/frost_rune.png`
- `godot/assets/cards/vine_snare.png`
- `godot/assets/portraits/guest_fargh_cutout.png`

```text
Edit reference image 1 only, a half_moon finished card. The other references are the APPROVED role frame, existing same-role cards and Fargh portrait, to preserve identity/style. Keep the illustration, subject, medieval fantasy winter setting, purple stock, bold tapering ink, role-specific art frame, rounded rectangular 2:3 shape, continuous cream bottom panel, and all Korean text EXACTLY the same. Change only the TEXT PANEL LAYOUT to provide real translation room. Output exactly 1024x1536 RGBA, outside rounded corners transparent.
Critical correction: the current oversized title and category occupy the same two-line safe zone. Make the title visibly smaller, about 70px high, placing its ink within y90..160. Keep x110..914 y170..236 CLEAR CREAM as the second title line slot. Move the existing category strip down to y267..307 in 38px type. Extend the cream title panel down to y330, following the same approved role's outline; art starts below this. This requires reducing art window height slightly, preserving its proportions as far as possible and full central subject. No ornament or category inside the title safe zone x110..914 y72..236.
Rules correction: reserve a continuous clean cream rules field x110..914 y1185..1445 with capacity for FOUR lines at 48px type and 60px line spacing. Keep both supplied sentences verbatim, but use approximately 48px type (smaller than the current type), all ink within x110..914. Center the two sentences in this larger field, wrapping a long sentence at word boundaries only when needed. No frame tip below y1120, no divider, ornament, notch or badge in rules safe zone. Keep all exact title/category/rules from reference 1, no extra text, no key letters or numbers. This is a precise margin/layout correction, preserve the beautiful scene and calligraphic print style.
```

## full_moon · 첫 생성

실제 참고 입력:
- `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
- `godot/assets/cards/frost_rune.png`
- `godot/assets/cards/vine_snare.png`
- `godot/assets/portraits/guest_fargh_cutout.png`

```text
Use case: illustration-story. Create ONE finished upright game card, exactly 1024x1536, true 2:3. Set the artwork in a medieval-based fantasy world, keeping medieval daily life and atmosphere while allowing familiar fantasy adaptations. Match supplied APPROVED role card's frame skeleton, purple stock, sweeping variable-width black ink, cream panels and painterly print texture; match existing game cards' style. Full rectangular card with subtly rounded corners, outside corners genuinely transparent, no background or shadow. Reserve title safe area x110..914 y72..236 for two lines even though title is short. Category separate at y267..307. Reserve one continuous cream rules panel x55..970 y1120..1495 and clean rules safe area x110..914 y1185..1445 for at least four lines. Adjust art height to those safe areas. No ornament, frame point or divider within text fields. No number, key letter Q/E, English, watermark, badge or extra text. Render the specified Korean verbatim in bold expressive black calligraphic ink similar to references, with accurate spelling, punctuation and spaces.
References 1 APPROVED SKILL frame/layout; 2 and 3 current SKILL card style; 4 gray wolf fur identity context. Keep SKILL diamond black outline and thin cream inner stroke, bottom tip above y1120, no badge. Match moon trilogy's winter indigo-violet night, lavender snow, silver light and dark firs. Scene: large clearly ROUND FULL MOON behind a quadrupedal gray wolf standing on snowy clearing, visible breath, violet glowing eyes. The wolf is the transformed witch; retain one obvious violet witch hat on wolf's head as her identifying trace. Wolf central, full natural wolf body and paws, no human torso. Exact title: "보름달". Exact category: "늑대의 피 · 밤의 힘". Exact rules lines: "밤에 마녀에게 씁니다." and "오늘 밤 늑대로 변신합니다."
```

재생성 이유: 큰 제목과 분류가 제목 2줄 여백을 압박해 제목·설명 크기와 패널 여백을 보완했다. 첫 생성은 `drafts/<id>-initial.png`, 채택한 재생성의 가공 전 원본은 `drafts/<id>-layout-generated.png`에 보존했다.

재생성 실제 참고 입력:
- `art/cards/wolf-blood-v01/drafts/full_moon-initial.png`
- `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`
- `godot/assets/cards/frost_rune.png`
- `godot/assets/cards/vine_snare.png`
- `godot/assets/portraits/guest_fargh_cutout.png`

```text
Edit reference image 1 only, a full_moon finished card. The other references are the APPROVED role frame, existing same-role cards and Fargh portrait, to preserve identity/style. Keep the illustration, subject, medieval fantasy winter setting, purple stock, bold tapering ink, role-specific art frame, rounded rectangular 2:3 shape, continuous cream bottom panel, and all Korean text EXACTLY the same. Change only the TEXT PANEL LAYOUT to provide real translation room. Output exactly 1024x1536 RGBA, outside rounded corners transparent.
Critical correction: the current oversized title and category occupy the same two-line safe zone. Make the title visibly smaller, about 70px high, placing its ink within y90..160. Keep x110..914 y170..236 CLEAR CREAM as the second title line slot. Move the existing category strip down to y267..307 in 38px type. Extend the cream title panel down to y330, following the same approved role's outline; art starts below this. This requires reducing art window height slightly, preserving its proportions as far as possible and full central subject. No ornament or category inside the title safe zone x110..914 y72..236.
Rules correction: reserve a continuous clean cream rules field x110..914 y1185..1445 with capacity for FOUR lines at 48px type and 60px line spacing. Keep both supplied sentences verbatim, but use approximately 48px type (smaller than the current type), all ink within x110..914. Center the two sentences in this larger field, wrapping a long sentence at word boundaries only when needed. No frame tip below y1120, no divider, ornament, notch or badge in rules safe zone. Keep all exact title/category/rules from reference 1, no extra text, no key letters or numbers. This is a precise margin/layout correction, preserve the beautiful scene and calligraphic print style.
```

## wolf_claw · 첫 생성

실제 참고 입력:
- `godot/assets/ui/icons/icon_moonlit_charm.png`
- `godot/assets/ui/icons/icon_frost_queen_tear.png`
- `godot/assets/ui/icons/icon_hearth_ember.png`

```text
Use case: stylized-concept. Create ONE square game skill icon, designed for final 128x128 display and legible at 56px. Use supplied existing game icon images as actual painterly watercolor-and-bold-black-ink style references. Medieval-based fantasy keeping medieval atmosphere with magical adaptation. One perfectly CIRCULAR medallion centered, dark indigo-purple disc, a single thin aged gold rim, outside circle genuinely transparent. Main symbol: exactly THREE luminous purple claw slash marks fanning apart in a sweeping diagonal gesture, pale violet cutting edges, strong bold simple silhouette, clean ink outlines, broad colors, restrained paper texture. No wolf head, no hand, no lettering, no Q/E, no numbers, no extra surrounding badge, no background or shadow. Circle nearly fills canvas with small transparent margin. Create crisp production-quality matching skill set.
```

재생성 없음. 생성 원본을 `drafts/<id>-initial.png`에 보존하고, 원형 컷아웃의 안티앨리어싱을 보존하면서 내부 알파를 불투명하게 정규화한 뒤 동일 원형 지름·128×128로 축소했다.

## wolf_pounce · 첫 생성

실제 참고 입력:
- `godot/assets/ui/icons/icon_moonlit_charm.png`
- `godot/assets/ui/icons/icon_frost_queen_tear.png`
- `godot/assets/ui/icons/icon_hearth_ember.png`

```text
Use case: stylized-concept. Create ONE square game skill icon, designed for final 128x128 display and legible at 56px. Use supplied existing game icons as actual watercolor-and-bold-black-ink style references. Medieval-based fantasy keeping medieval atmosphere with magical adaptation. One perfectly CIRCULAR medallion centered, dark indigo-purple disc, a single thin aged gold rim, outside circle genuinely transparent. Main symbol: a luminous lavender silhouette of a gray wolf leaping forward toward the right, paws stretched forward, clear pointed ears and long tail, dynamic diagonal pose; include a clear small ivory FANG accent beneath it. Strong simple readable silhouette, clean tapered ink outlines, broad colors, restrained paper texture. No lettering, no Q/E, no numbers, no extra surrounding badge, no background or shadow. Circle nearly fills canvas with small transparent margin. Match a skill set with purple claw-slash icon.
```

재생성 없음. 생성 원본을 `drafts/<id>-initial.png`에 보존하고, 원형 컷아웃의 안티앨리어싱을 보존하면서 내부 알파를 불투명하게 정규화한 뒤 동일 원형 지름·128×128로 축소했다.

## 납품 후처리

카드 RGB와 인쇄 글자는 바꾸지 않고, 내부 반투명 알파를 불투명 카드지로 정규화했다. 40px 라운드 외곽을 4배 마스크로 안티앨리어싱하고 손패는 LANCZOS 1/4 축소했다. 아이콘은 생성된 원형 컷아웃 알파를 유지했다. 원본 크기 글자 검수 이미지는 `output/wolf-blood-v01/review-<id>.png`, 전체 비교 시트는 `godot/screenshots/wolf-blood-cards/sheet.png`다.
