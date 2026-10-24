# 브로크 초상·상점 UI 실제 생성 프롬프트 · v01

작성: 2026-10-24. 내장 `image_gen` 사용. 모든 호출은 `transparent_background=true`, 아래 PNG 경로를 `referenced_image_paths`로 실제 입력했다. 외부 API/CLI는 사용하지 않았다.

중세 기반 판타지, 승인 초상의 검은 먹선·큰 명암 색면·페인터리 질감을 기준으로 제작했다. 카드 원화는 생성·수정하지 않았으며 기존 카드 PNG는 합성 시트에서만 읽었다.

## A

실제 입력 PNG:

- `godot/assets/portraits/guest_luka_cutout.png`
- `godot/assets/portraits/guest_fargh_cutout.png`
- `godot/assets/portraits/guest_bram_cutout.png`
- `godot/assets/portraits/guest_nib_cutout.png`
- `godot/assets/portraits/guest_sera_cutout.png`

프롬프트 전문:

```text
Use case: stylized-concept.
Asset type: production transparent guest portrait A, Brock the badger merchant for Witch's Lodge medieval fantasy game.
Input images: 1 Luka fox, 2 Fargh wolf, 3 approved Bram: PRIMARY STYLE references, faithfully match the tapered black ink, broad angular shadow planes and restrained painterly printed texture. 4 Nib goblin and 5 Sera human: merchant mood only, create a completely different person.
Create ONE stocky broad middle-aged male BADGER beastfolk itinerant merchant, chest-to-waist upper body, gentle three-quarter turn toward viewer's right. Distinct small round ears, sturdy broad muzzle, black-and-white badger face with central white stripe from forehead to nose bridge and broad black eye bands. Small round plain iron-rim spectacles perched low on nose, amused half-smile, shrewd but honest relaxed expression. Thick short paw-like hands.
Clothing: dark mustard quilted vest, worn dark russet-brown travel cloak, PLAIN solid reddish-brown scarf (NO checks, NO patterns). Belt visible with several small coin pouches and a miniature brass balance scale. Behind his shoulders the top of a wooden backpack carrying frame with a tied bundle, dried herbs and a small hanging medieval lantern. One hand casually offers ONE plain blank card with its BACK toward viewer, no pattern or image on the card. Other hand rests near pouches.
Medieval-based fantasy with lived-in medieval materials and atmosphere, fantasy adaptation allowed; no modern clothing. Warm amber key light and restrained cool lavender rim light on the actual form. Same bold inked hand-painted fantasy portrait family as input images, not photorealistic, not anime, not 3D.
Composition: portrait canvas approximately 1122 by 1402 / 4:5. Entire ears/head, both shoulders, elbows, hands, offered card, backpack frame, lantern and pouches inside the canvas with clear transparent margins on all four sides; ample headroom. Natural curved lower clothing edge. No body or prop cropped. Character fills canvas comparably to reference portraits.
Genuine transparent RGBA background; clean antialiased fur edges without any colored halo, no haze or scenery, no floor shadow, no frame.
ABSOLUTELY NO writing, letters, numbers, glyphs, symbols, runes, logos, watermarks or decorative insignia anywhere, including the card and coins. Only one character.
```

## B

실제 입력 PNG:

- `godot/assets/ui/chest_closed.png`
- `godot/assets/ui/hand_workbench/witch-props-v02.png`

프롬프트 전문:

```text
Use case: stylized-concept.
Asset type: B isolated transparent merchant stall board sprite for a medieval fantasy card-game shop UI.
Input images 1 chest_closed: reference for chunky old timber and dark riveted iron painted with bold tapered black ink and broad shadow planes; do NOT reproduce chest shape, snow, moss, moon or symbols. Input image 2 witch-props-v02: reference for restrained purple shadows, hand-painted wood/material style and UI cutout finish, do NOT reproduce its objects.
Create ONE very wide low horizontal worn wooden merchant counter / display ledge, frontal view with a very shallow visible tabletop. Final target 1800x360 (5:1), use that wide low silhouette, centered with transparent space around ALL edges. Long uninterrupted straight level top plank, comfortably supports five cards that the game draws ON TOP of it. Simple central top, low visual clutter; no partitions, no slots, no objects, NO cards baked into image. A dark muted indigo-plum cloth hangs down the FRONT in a few broad simple folds, ends attached at the two corners; visible warm weathered wooden rim and side ends, a couple plain iron corner fasteners. The cloth occupies most of the low front face. No legs, no vertical posts, no canopy, no background, no cast shadow outside the silhouette.
Medieval-based fantasy with lived-in medieval atmosphere, fantasy adaptation allowed. Cohesive hand-painted fantasy game material, black ink edges, broad painterly color planes, understated warm amber from upper left and cool lavender edge. Not realistic, not anime, not 3D.
Genuinely transparent RGBA background; clean simple antialiased edges; preserve narrow transparent padding. Absolutely NO text, letters, numbers, glyphs, runes, logos, emblems, symbols or watermark, no decorative insignia. Only one wide UI material.
```

## C

실제 입력 PNG:

- `godot/assets/ui/chest_closed.png`
- `godot/assets/ui/hand_workbench/witch-props-v02.png`

프롬프트 전문:

```text
Use case: stylized-concept.
Asset type: C single isolated transparent parchment price-tag sprite for medieval fantasy shop UI, target 240x96 (2.5:1).
Input image 1 chest: reference ONLY for black ink outlines and warm brass painterly material, do not reproduce chest, snow, moss or its symbols. Input image 2 workbench: reference for parchment material, restrained painted texture and cohesive game cutout finish, do not reproduce props or symbols.
Create exactly ONE horizontal pale warm cream parchment merchandise tag with a small punched string hole near the LEFT end, a short loop of plain twine contained completely inside the canvas, and ONE small plain unmarked brass coin sitting at far LEFT. Delicately irregular cut paper edge, a slight dog-ear, restrained light texture. The RIGHT TWO THIRDS must be a large continuous CLEAN BLANK LIGHT CREAM PAPER field for the game to overlay dark price digits, flat clear and evenly lit, no scratches or ornaments in that field. Brass coin and punched hole remain within left third. No rope crosses writing field. Tag shape about 2.5 times wider than tall with narrow transparent margins.
Medieval-based fantasy with medieval lived-in atmosphere, fantasy adaptation allowed. Hand-painted broad color planes and confident black ink matching inputs, warm amber key and a restrained lavender shadow on paper edge only; simple readable UI. Not photorealistic, not anime, not 3D.
Genuine transparent RGBA background. Clean antialiased edges, no background panel or drop shadow, no frame outside tag. Absolutely NO writing, text, letters, digits, runes, glyphs, icons, stamped marks, coin emblems, symbols, logos or watermark. A completely smooth unmarked coin and completely blank paper. One asset only.
```

## D

실제 입력 PNG:

- `godot/assets/ui/chest_closed.png`
- `godot/assets/ui/hand_workbench/witch-props-v02.png`

프롬프트 전문:

```text
Use case: stylized-concept.
Asset type: D one isolated hanging shop sign-board UI sprite for medieval fantasy game, target 900x180 (5:1).
Input image 1 chest_closed: ONLY material/style reference for warm timber, plain dark riveted iron, bold black ink and large painted shadow planes, do NOT copy chest, snow, moss or symbols. Input image 2 witch-props-v02: reference for fantasy UI cutout finish, muted lavender shadows and restrained painted wood texture, do NOT copy any objects or markings.
Create ONE very long low horizontal wooden merchant sign, hanging from exactly TWO short separate dark iron chains, one chain near each upper corner. Full chains are visible and stay within canvas with transparent margin above. Wood body a single broad smooth pale honey-colored aged plank with slight uneven edges; overall board PLUS short chains fit very wide 5:1 silhouette. Only small plain iron corner pieces/rivets as decorations, confined to far left and far right edges. Middle 75 percent is a continuous clean LIGHT warm wood field without seams, large knots or high-contrast grain, broad and blank for the game to overlay dark title lettering. Delicate wood texture only. Completely EMPTY sign face. OMIT any paw print or insignia because all symbols are prohibited. Simple frontal view, shallow thickness visible at lower edge, no angled perspective.
Medieval-based fantasy with lived-in medieval atmosphere, fantasy adaptation allowed. Hand-painted fantasy game, confident tapered black ink contours, broad flat light/shadow planes, warm amber upper-left light and subtle lavender edge shadow. Not photorealistic, not anime, not 3D.
Genuine transparent RGBA background, clean antialiased edges, transparent margin all four sides, no surrounding wall, beam, scenery, drop shadow, or other props.
ABSOLUTELY NO text, writing, numbers, letters, runes, glyphs, symbols, paw prints, stamped emblems, logos or watermarks. One sign only.
```

## A2

실제 입력 PNG:

- `art/portraits/merchant-brock-v01/brock-generated-v01.png`

재생성 이유: 어깨 원형 브로치에 생성된 해/꽃 모양 각인을 제거하여 기호 금지 조건 충족.

프롬프트 전문:

```text
Use case: precise-object-edit.
Edit target: the supplied generated Brock badger merchant portrait. Make exactly one local correction: replace the round engraved sun/flower brooch on his shoulder with a completely smooth PLAIN unmarked round brass cloak clasp. Remove all engraved radial marks and decorative symbol on this clasp, keeping the same outer circle, size, position and lighting. Everything else must remain identical: badger identity, black and white face, small round spectacles, half smile, plain reddish brown scarf, mustard quilted vest, brown cloak, blank card held in paw, pouches and brass scale, backpack and lantern, bold black ink painterly style, crop, margins and genuine transparency. Do not add any text, number, symbol, emblem or watermark anywhere. Transparent RGBA, no scenery, no halo. Medieval-based fantasy and lived-in medieval atmosphere, fantasy adaptation allowed.
```

## D2

실제 입력 PNG:

- `art/ui/merchant-v01/sign-generated-v01.png`

재생성 이유: 첫 간판의 쇠사슬이 길고 전체 실루엣이 높아, 5:1 납품 비율과 제목 가독성을 위해 짧은 사슬·낮은 목판으로 재생성.

프롬프트 전문:

```text
Use case: precise-object-edit.
Edit target: provided transparent blank wooden merchant sign.
Revise proportions for a very wide low 5:1 UI asset. The whole occupied silhouette INCLUDING chains must be FIVE TIMES WIDER THAN TALL. Keep same painterly inked aged honey-colored timber and plain iron corner materials and completely blank light central title field. SHORTEN the two hanging chains drastically to ONE small visible link each, only 15 percent of total occupied height. Reduce wooden plank height, so plank body is a long low horizontal strip 85 percent of total height. Make central 75 percent width LIGHT, CLEAN and QUIET for dark title lettering, with fewer high-contrast horizontal streaks. Keep the board horizontal, frontal, simple. Transparent canvas may be wider landscape with empty padding, but actual object MUST have 5:1 width-to-height proportions. Full two chain links completely inside canvas with transparent padding above, neither may touch top image edge. Maintain clean antialiased edges, broad painted color/shadow planes and bold tapered black ink, warm amber and restrained cool lavender edge. Medieval-based fantasy, medieval lived-in atmosphere with fantasy adaptation allowed. Genuine transparent RGBA background. No text, digits, letters, symbols, glyphs, emblems, icons, paw prints, runes, logos, watermark, other props, scenery or outside shadow. One sign only.
```

## 채택·규격 처리

- A: `brock-generated-v01.png`은 브로치 문양 때문에 미채택. `brock-generated-v02.png` 채택, 1122×1402 RGBA 크기·구도 유지.
- B: `stall-generated-v01.png` 채택.
- C: `price-generated-v01.png` 채택.
- D: `sign-generated-v01.png`은 긴 사슬과 높은 비율 때문에 미채택. `sign-generated-v02.png` 채택.
- 모든 PNG에서 생성 배경의 알파 1/255 이하 미세 잔여 픽셀만 RGBA 0으로 정리했다. 그 외 생성 알파는 보존했다. UI는 이 실루엣을 기준으로 바깥 투명 여백을 정리하고 균등 배율로 납품 캔버스 안에 중앙 배치했다. System.Drawing으로 투명 정리·규격 맞춤·합성만 수행했으며, 배경색 키잉·수작업 재그림·비균등 변형은 사용하지 않았다.
- 간판 발자국 낙인은 선택 장식이므로 공통 기호 금지 규칙을 우선해 생략했다.
- 합성 시트의 제목·가격 예시는 별도 텍스트 레이어이며 납품 PNG 4종에는 포함되지 않는다. 합성 미리보기는 게임 실행 캡처가 아니다.

