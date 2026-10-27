# 주점 카드 v07 · 실제 이미지 생성 프롬프트

제작일: 2026-10-27 · 도구: 내장 `image_gen` · 요청서: [codex-tavern-drinks-v02](../../handoff/codex-tavern-drinks-v02.md)

중세 기반 판타지의 수채·먹선 기준을 적용했다. 카드 글자는 게임이 그리므로 제목·분류·설명은 미인쇄다. CLI/API 대체 경로는 사용하지 않았다.

## 실제 참고 입력

- 스킬 2종: `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`(승인 골격), 각각 `godot/assets/cards/resin_torch.png`·`frost_rune.png`(편집 대상).
- 용의 숨결 첫 생성에는 `godot/assets/cards/fire_ale.png`도 화풍 참고로 입력했다. 보완 생성은 첫 생성 PNG를 추가 입력했다.
- 사건: `godot/assets/cards/drunk_rant.png`(편집 대상), `art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png`(승인 골격).
- 에린 동일 인물 참고는 `godot/assets/cards/drunken_erin.png`와 `art/cards/tavern-v01/drafts/drunken_erin_v02.png` 모두를 실제 입력했다.
- VFX 3종은 각자 별도 신규 생성했다. 불·토사물은 실제 투명 배경으로 생성했으며 알파를 보존했다. 얼음은 전체 표면을 채운 생성 결과를 반투명화했다.

## 합성·축소 및 보완 이유

- 첫 스킬 시안은 원화가 마름모 프레임을 덮었다. 용의 숨결은 불붙은 헝겊 심지가 불분명했다. 두 스킬은 프레임 없는 원화를 재생성한 후 원본 그림 창에만 합성했다.
- 기존 게임용 `resin_torch`·`frost_rune`·`drunk_rant`를 읽기 전용 복사해 프레임/글판의 기준으로 사용했다. 제목·분류·설명판은 편집 대상 원본 픽셀로 보존했다. 스킬의 횃불·얼음이 가리고 있던 마름모 구간은 같은 역할인 frost_rune의 가려지지 않은 프레임과 하단 좌측 구간의 대칭 복사로 복원했다. 생성 과정에서 어두워진 건배! 글판도 원본의 빈 크림색 판으로 보존했다.
- 합성 마스크·마름모 복원 영역 밖의 RGB 픽셀은 기준 카드와 동일하다. 모서리는 반경 34px 외부와 극저알파 잔여값(<8)을 완전 투명으로 정리했다. 카드 전체의 비율을 변형하지 않았으며, 별도 스킬 원화는 종횡비를 유지해 배치했다. 원화의 중앙 장면은 880px 폭으로 줄여 배치하고 60px 가장자리 블렌딩으로 같은 원화 배경과 연결하여 술병·늑대의 실루엣이 프레임에 잘리지 않게 했다.
- 카드는 1024×1536 RGBA, 손패는 고품질 bicubic 축소 256×384 RGBA다. 기존 카드의 둥근 외곽 알파를 보존했다.
- VFX는 각각 512×512,512×512,256×256 RGBA로 정규화했다. 얼음은 밝기에 따라 알파 160–230 범위로 정규화하고, 48px 폭의 대칭 smoothstep 블렌딩으로 좌우·상하를 연결했다. 2×2 반복 미리보기를 별도 저장했다.
- 재현용 에셋 준비 기록: `output/tavern-v07/prepare-assets.ps1`. 게임 코드·검증 도구·카탈로그·exe·.import 파일은 작성하지 않았다.

## dragon_breath / first draft

```text
Edit the supplied textless resin_torch game card (image 1). Reference image 2 is APPROVED skill layout warm welcome; image 3 is fire_ale PAINT STYLE only. Create ONE upright 1024x1536 textless card, exact 2:3. Retain image 1 entire purple card perimeter, black ink swirls, cream blank title/classification panel and large cream blank rules panel and black diamond with thin cream inner keyline EXACTLY at their original coordinates. Replace ONLY the illustration inside the picture window, maintaining central DIAMOND skill silhouette. NO text, numbers, glyphs, labels or watermark anywhere. The reference's lettering must NEVER be copied. Title safe x110..914 y72..236 and description x110..914 y1185..1445 remain blank and unchanged. Main illustration: medieval fantasy familiar adaptations, medieval atmosphere. A very legible THICK BROWN EARTHENWARE LIQUOR BOTTLE, diagonally tilted, its SHORT pouring spout sculpted like a dragon HEAD in brown ceramic, NOT a whole dragon. A cloth wick at its mouth is burning, no cork. The neck pours fiery liquor downward onto snow. Across the lower center of the diamond a very WIDE LOW orange and crimson burning POOL spreads flat over snowy ground, low broad tongues of flame describing a damaging ground area, not a towering fire. Bottle silhouette clearly separate from pool, huge simple forms readable at 256x384. Snowy dark indigo woods background. Watercolor washes and tapering bold ink, broad color shapes, strongly illustrated, matching supplied card. No people, no entire dragon, no modern objects. Rounded outer corners with real transparent exterior.
```

## frost_giant_spirit / first draft

```text
Edit textless frost_rune game card image 1. Image 2 is APPROVED warm welcome SKILL frame/layout reference. Make ONE upright 1024x1536 textless medieval fantasy card. Use supplied purple stock, black tapering ink swirls, cream blank two-line title/class panel, one large blank four-line rules panel, DIAMOND frame with black border and thin cream inner keyline. Keep all borders and panels at EXACT source coordinates. NO text, lettering, numbers, glyphs, runes, snowflake symbols or watermark anywhere; NEVER reproduce reference text. Outer corners round, transparent outside. Keep text safe x110..914,y72..236 and x110..914,y1185..1445 blank. Replace illustration only. Central subject inside diamond: a squat wide BLUE GLASS LIQUOR BOTTLE thickly coated with white hoarfrost, huge coarse giant HANDPRINT IMPRESSION etched in the glass (palm and fingers pictogram, NOT writing), THICK ROPE handle. Bottle centered around x425 y550, diagonally tilted mouth down-right, all principal silhouette WITHIN the diamond and not crossing its border. Liquor visibly pours from mouth to snowy ground at x580,y740. From contact ground a cluster of SHARP LARGE CLEAR ICE CRYSTALS erupts outward. In lower-middle/right of diamond, ONE DARK WOLF silhouette entirely trapped inside ONE TRANSPARENT solid chunky ICE BLOCK, all legs head and tail frozen together, recognizable at 256x384. Not a free wolf standing beside ice. Ice refracts wolf outline but remains readable. Palette cold cyan, turquoise, sky blue, white; dark blue snow forest background. Large color shapes, watercolor and bold tapering ink matching references. Medieval based fantasy with familiar fantasy adaptation and medieval atmosphere. No people, no modern objects, no whole giant, no extra animals. Diamond lower tip must stop before blank rules panel.
```

## cheers / selected illustration

```text
Edit image 1, textless drunk_rant EVENT game card, change ONLY illustration window. Reference image 2 APPROVED EVENT forbidden harvest is layout guide ONLY, never copy lettering or subject. Images 3 and 4 are BOTH mandatory character identity references: SAME adult woman ERIN, same face golden BLONDE curly braided hair, rosy cheeks, original green eyes (closed in new pose), gold earrings and pendant, ivory ruffled medieval blouse with modest gathered neckline and brown laced bodice, same clothes. Create a joyful affectionate TOAST scene under warm amber lantern in medieval timber-and-stone lodge tavern. Erin is the only visible person/face, at center, eyes CLOSED with a huge delighted laughing smile. She raises one foaming wooden iron-banded beer tankard HIGH ABOVE HER HEAD (mug near x430 y430, face below around x570 y700). Show coherent entire raised forearm and gripping hand, head hair silhouette and mug entirely inside illustration window y340..1095. Two or three other mercenary HANDS AND TANKARDS ONLY enter from sides to clink nearby, NO other faces, heads or people in background. Beer foam and amber droplets fly naturally, warm lively celebration, no vomit. All clothing modest, no cleavage emphasis or sexualization, medieval atmosphere. Painterly watercolor with decisive tapering black ink contours, broad expressive color blocks matching original cards; face clearly SAME Erin as both references. ONE upright 1024x1536 true 2:3 card. Preserve image 1 EXACT purple perimeter, black ink frame, restrained folded banner corners and EVENT scene window, cream title/classification and ONE wide cream rules panel all at original coordinates. NO text letters digits writing labels watermark or symbols. Top safe x110..914 y72..236 and bottom x110..914 y1185..1445 are blank. No new badge or center divider or V notch. Round outer corners transparent outside.
```

## fire_pool / selected

```text
Generate ONE isolated game VFX texture, square 512x512 RGBA with REAL TRANSPARENT background, no checkerboard painted. Orthographic TOP DOWN plan view looking straight down at a ROUND SHALLOW BURNING LIQUOR PUDDLE, suitable as flat ground decal. No perspective, no upright fire wall, no bottle, no floor, no snow, no props, no border, no text symbols or watermark. A continuous low round pool, center warm yellow/gold and orange broad flowing islands, middle orange-red flowing circular swirls, irregular crimson perimeter with many SHORT low licking flame tongues pointing radially outward, fading through thin dark-red translucent watercolor at edge into alpha zero. Keep entire effect within circle diameter 440 centered in square, at least 28px fully transparent outer margin all four sides. Bold painterly watercolor and tapering dark warm ink in a medieval fantasy game, big clearly readable color blocks at small scale, graphic not photoreal, not a volcano or rock. STRICT overhead view, roughly circular, large filled luminous center, natural irregular fiery scalloped edge. Transparent background is essential.
```

## ice_block / selected

```text
Generate ONE square 512x512 game ICE SURFACE texture. Flat front-on uniform material sample covering the ENTIRE square with NO border or isolated object. MUST SEAMLESSLY TILE horizontally and vertically, wrap all cracks naturally across opposite edges, no vignette no center emphasis no lighting gradient. Sky blue and cyan turquoise glacial ice, translucent watercolor masses, broad angular light facets, sparse delicate WHITE CRACKS and frost grains, a FEW thin dark navy ink lines. Quiet large areas, not too many small details. Medieval fantasy illustrated watercolor and ink game aesthetic, absolutely not a photograph, no real environment. This is the surface of a solid ice block to wrap onto box and sphere meshes. No cube drawing, no ice crystal object, no wolf, no snowflake icon, no text, no numbers or symbols, no floor, no drop shadow. Entire sheet material should be semitransparent (alpha varying from 160 to 230 of 255), enough blue body and white veins that the monster beneath remains partly visible. Seamless texture, straight overhead orthographic flat swatch.
```

## vomit_puddle / selected

```text
Create ONE game VFX decal texture 256x256 square RGBA with real TRANSPARENT exterior. Strict orthographic TOP DOWN directly overhead view of a SMALL CUTE CARTOON VOMIT PUDDLE, flat low irregular rounded squishy lobes. Pale buttery yellow and light lime-green broad watercolor shapes, a few small round foam bubbles, restrained tapering dark olive ink contour, simple cute whimsical graphic. NOT realistic or disgusting, no recognisable food chunks, no face or emoji, no people, no container, no ground or cast shadow, no text numbers marks symbols watermark, no checkerboard painted. Medieval fantasy watercolor-and-ink card-game aesthetic, big readable simple shapes. Puddle approximately round width and height, centered, within 205px diameter with 24px entirely transparent margin on all four sides. Occasional tiny separate pale bubble droplets close to puddle. The only content is this little yellow-green foamy puddle.
```

## dragon_breath / selected artwork repair

```text
Create an ILLUSTRATION ONLY to insert behind a preexisting diamond card frame. NO CARD FRAME, NO panels, NO geometric border, no typography. One landscape 4:3 illustration, medieval fantasy watercolor and bold tapering ink, matching supplied actual references. Ref 1 is APPROVED warm welcome SKILL artwork style/layout constraint reference (ignore its written words), ref 2 resin_torch is style/color and edit-target underlying frame reference. Ref 3 previous dragon bottle attempt gives subject, but needs corrective redesign: add UNMISTAKABLE BURNING CLOTH WICK and REDUCE/RECENTER bottle so it fits inside central diamond. Picture snowy indigo forest ground. Central picture composition tightly grouped: THICK squat brown ceramic LIQUOR BOTTLE in center upper-middle, dragon-head short pouring spout facing DOWN toward lower-left, tilted, a visible short FRAYED BEIGE CLOTH WICK extending from its mouth WITH SMALL FLAME burning on the cloth. Brown pottery body, NOT metal tankard, no runic decoration or writing. Liquor pours to ground, creating WIDE LOW FLAT orange/crimson burning puddle on snow below bottle, low broad tongues of flame. Bottle width only 30% image, height 42%, centered x52% y45%. Broad ground pool spans x24%..76%, y63%..80%. Main bottle AND pool entirely in diamond-shaped safe composition with vertices (50%,8%),(89%,50%),(50%,95%),(11%,50%); no critical subject outside. Background snowy pines/blue dark atmosphere all the way to edges. Very clear bottle vs pool silhouette readable small. No person, no whole dragon, no modern items, no text numbers symbols anywhere, no card border. Medieval-based fantasy with familiar fantasy adaptations preserving medieval life and atmosphere.
```

## frost_giant_spirit / selected artwork repair

```text
Generate illustration ONLY, landscape 4:3, to place behind existing DIAMOND skill-card border. NO CARD, no panel, no border, NO diamond line. Mandatory supplied image 1 is approved skill layout/style warm welcome, image 2 frost_rune textless game edit target is style reference, image 3 is first attempt for CONTENT reference. Correct first attempt's size: smaller centrally grouped bottle and frozen wolf, entirely centered, with ample snow/forest surroundings. Medieval-based fantasy, familiar fantasy adaptations preserving medieval life/atmosphere. Bold watercolor + expressive ink outlines, large readable shapes, snowy indigo woods, cold cyan, sky blue white. Composition: frosted squat BLUE GLASS LIQUOR BOTTLE upper-central left (center x43%,y37%, width22%,height30%), coarse HANDPRINT impression in glass and thick ROPE handle, diagonally tilted mouth lower-right. Liquor pours visibly onto snow near center (x54%,y57%). Sharp ice crystals burst radially up from this spot. One single compact translucent chunky solid ICE BLOCK lower-center (center x54%,y65%, width25%,height28%) ENTIRELY enclosing a SMALL DARK WOLF silhouette, side view, FOUR LEGS and tail and head ALL inside ice. Ice block is main effect, wolf entirely trapped, readable through clear cyan ice. Do not let wolf walk outside block. Keep ALL main objects within a CENTRAL DIAMOND safe composition with vertices(50%,5%),(86%,50%),(50%,96%),(14%,50%). Crucial: silhouette of bottle AND entire wolf fully inside this central safe zone, no border overlaps. Surrounding corners are just snowy trees/ground. No person, no whole giant, no text numbers glyphs runes icons snowflake symbols, no modern props.
```


## v03 재제작

제작일: 2026-10-27. 내장 `image_gen` 편집 모드 사용. 편집 대상은 실제 게임의 `wisp_spirit.png`, 추가 참고는 `fire_ale.png`(두 장 공통), `golden_mead.png`·`dew_of_forgetting.png`(서리 거인). 네 장 모두 생성 전 열어 확인했다. 요청서의 술 카드 포맷을 우선해 마름모판을 폐기하고 둥근 사각 그림창과 미니 병 배지를 사용했다.

### dragon_breath · 실제 입력

```text
Use case: precise-object-edit. Edit target image 1 wisp_spirit.png, image 2 fire_ale.png is additional mandatory actual existing DRINK CARD composition/style reference. Create ONE upright textless 1024x1536 medieval fantasy liquor card, true 2:3. Preserve image 1 exact purple card stock, thick black wavy perimeter, huge blank cream top name/classification plate, huge single blank cream bottom description plate, the ROUNDED RECTANGULAR illustration window at x49..975 y317..1080, and small cream OVAL mini bottle badge at x397..628 y1026..1153 with existing black border at same coordinates. Change ONLY artwork inside the rounded rectangular window and the miniature bottle INSIDE badge. NO diamond, shield or skill frame.
Art: a large thick REDDISH-BROWN EARTHENWARE LIQUOR BOTTLE tilted diagonally, clearly the hero occupying 60-65% of window width. Full bottle silhouette visible within window. Short spout carved as an unmistakable DRAGON HEAD in the SAME reddish brown pottery, not a separate dragon. A frayed cloth WICK tied around the bottle NECK has a small bright flame. ORANGE AND CRIMSON BURNING LIQUOR visibly OVERFLOWS from the dragon-shaped open mouth in one broad liquid stream, curling around the bottle in a fiery liquor vortex with drops. Make the dark ceramic bottle immediately legible against bright liquid. Background ONLY deep crimson, red-black and orange magical swirling smoke, fire and sparks; no scenery, ground, people, animals, wolves or monsters. It is a DRINK hero illustration like supplied existing drink cards, not an action scene. Small lower oval badge contains a single clear MINIATURE OF THIS SAME DRAGON-SPOUT POTTERY BOTTLE on cream, no writing.
Match references' painterly watercolor, bold tapering black ink outlines, broad color shapes, glistening liquid and pottery, readable at 256x384. Medieval-based fantasy allowing familiar fantasy adaptation while retaining medieval atmosphere. No text, letters, digits, runes, symbols, labels, watermark anywhere. Keep title safe x110..914 y72..236 and rules safe x110..914 y1185..1445 entirely blank with no ornament. Outer rounded card corners, real transparent outside. Do not move, redraw or recolor any frame, panels or badge borders. ALL changes restricted to illustration and badge INTERIORS.
```

### frost_giant_spirit · 실제 입력

```text
Use case: precise-object-edit. Edit target image 1 wisp_spirit.png; images 2 fire_ale.png, 3 golden_mead.png and 4 dew_of_forgetting.png are mandatory actual existing DRINK CARD format/composition/style references. Make ONE upright 1024x1536 textless DRINK CARD, true 2:3. Preserve image 1 exact purple stock, black ink wave perimeter, blank huge cream name/classification plate, single blank huge cream lower rules plate, ROUNDED RECTANGULAR art window x49..975 y317..1080, and small cream OVAL badge with black rim at x397..628 y1026..1153. No diamond, skill or shield window. Change only the window artwork and badge mini icon inside original borders.
Subject: ONE LARGE SQUAT HEAVY BLUE GLASS LIQUOR BOTTLE, WHITE HOARFROST coating, full silhouette legible. Roughly squared broad shoulders, broad bottom, short neck, a crude SINGLE GIANT HANDPRINT impressed into blue glass on bottle body (palm and five finger mark only, no other markings), THICK TAN ROPE LOOP HANDLE around neck. Distinct from references' tall wisp bottle, round honey bottle and angular perfume flask: this is a broad-shouldered rustic chunky heavy spirit bottle. Tilt diagonally by about 25 degrees, mouth toward upper-right; bottle spans 60-65% of window width, hero subject centered. Open bottle visibly pours/overflows COLD TURQUOISE LIQUOR in a broad curling fluid stream, transforming MID-AIR into SHARP LARGE translucent ICE CRYSTALS. A chunky ICE CRYSTAL STOPPER floats just above/near the open mouth clearly detached. White frost swirls, icy sky-blue/cyan smoke, small natural snow crystals and droplets in abstract magic background only. Bright glistening blue glass and liquid, broad white frost shapes, dark blue contour. No ground scene, forest, landscape, person, monster, giant, wolf, ice-trapped animal or additional main objects.
Small lower oval badge: MINIATURE OF THE SAME FROSTED CHUNKY BLUE GLASS BOTTLE with rope handle and attached ice-crystal stopper, on plain cream. Match supplied drink cards: painterly watercolor and bold tapering ink, strong large color shapes and high contrast, bottle instantly reads at hand size 256x384. Medieval-based fantasy allowing familiar fantasy adaptation, medieval atmosphere. NO text letters numbers runes labels watermark or decorative writing/symbols anywhere. The sole handprint is a material impression not typography. Top safe x110..914 y72..236 and bottom safe x110..914 y1185..1445 empty cream; no ornaments enter. Preserve frame and badge border coordinates exactly. Rounded outside corners, transparent exterior.
```

### 합성·축소·보존

- 생성 원본: `art/cards/tavern-v07/drafts/<id>_drink-generated-v03.png`.
- 반려된 v02 원본은 `<id>_skill-format-rejected.png`로 바이트 그대로 보존 후 최종 경로를 교체했다.
- `output/tavern-v07/prepare-drinks-v03.ps1`에서 System.Drawing으로 요청된 합성·축소만 수행했다. 새 그림을 코드로 그리지 않았다.
- 원본 `wisp_spirit`의 닫힌 먹선으로 그림창·배지 안쪽 마스크를 얻고, 그 안에서만 생성 원본 픽셀을 복사했다. 원본의 프레임·제목판·설명판·배지 테두리·RGBA 모서리는 그대로 보존했다.
- 원본/게임용 RGBA 1024×1536, 손패용 RGBA 256×384, 비율을 유지한 고품질 bicubic 축소. 글자는 미인쇄다.
- 기존 술 4장과 나란히 상단 비교 및 실제 256×384 손패 줄을 담은 `godot/screenshots/tavern-v07/drink-format-sheet.png`로 육안 검수했다.
- 기계 검증은 `output/tavern-v07/verification-v03.json` 참조. 게임 코드·카탈로그·프로파일·VFX·cheers·실행파일은 이번 작업 대상에서 제외했고 커밋하지 않았다.
