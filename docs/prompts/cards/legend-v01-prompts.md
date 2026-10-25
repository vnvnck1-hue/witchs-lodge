# 전설 5종·광석 카드 원화 실제 프롬프트 · v01

제작: 2026-10-25 · 도구: 내장 `image_gen` (CLI/API 전환 없음). 중세 기반 판타지와 카드 디자인 가이드를 적용했다.

## 입력과 최종 산출물

- 전설 편집 대상: `art/cards/legendary-v01/drunken_erin_legendary_blank.png`
- 전설 화풍 참고: `art/cards/tavern-v01/drafts/art_fire_ale.png`
- 자원 편집 대상: `godot/assets/cards/timber.png`
- 자원 승인 참고: `art/concepts/cards/roles-individual-v02/03-resource-timber.png`
- 그림 창 측정 참고: `art/cards/tavern-v06/original-art-mask.png` (그대로 적용하지 않고 현재 전설·자원 틀의 안쪽 경계를 별도 추적)
- 최종 원본: `art/cards/legend-v01/<id>.png` / 게임용: `godot/assets/cards/<id>.png` / 손패용: `godot/assets/cards/hand/<id>.png`
- 최초 카드 생성본: `art/cards/legend-v01/drafts/<id>-card-draft.png` (1024×1536 RGBA). 최종 프레임으로는 채택하지 않고 배지/광석 그림의 입력으로만 사용.
- 전설의 프레임 없는 생성 원본은 `output/legend-v01/sources/<id>-illustration.png`에 도구 출력의 원래 해상도로 별도 보관. 이 파일은 납품 카드 PNG가 아니라 합성용 입력이다.

## 합성·축소·검증 방법

`output/legend-v01/package.cs`와 `package.ps1`에 재현 가능한 패키징을 보관했다. 새로운 원화와 아이콘을 그리는 작업은 image_gen이 수행했으며, 후처리는 요청서에 지정된 마스크 합성과 크기 변환만 수행했다.

1. 전설 원본 프레임을 그대로 읽어 시작한다. 그림 창과 배지 내부만 별도 마스크로 허용한다. 금테·보라 별빛·위 타원 이름판·하단 설명판·모서리 알파는 원본을 사용한다.
2. 전설의 새 정사각 원화를 비율 유지하여 974×974로 축소하고 x=25, y=250에 배치한다. 화로는 세 다리가 배지 위에 나오도록 900×900, x=62, y=250을 사용한다. 창 가장자리에 필요한 짧은 배경 영역은 원화 가장자리 픽셀로 연장한다. 인물/프레임을 비균등 변형하지 않는다.
3. 전설 배지 원 내부에는 최초 생성 카드의 새 아이콘만 복사한다. 기존 금테와 좌우 별빛 끝은 제외한다. 광석은 생성 카드의 그림 창과 작은 표식 안쪽만 복사한다.
4. 허용 마스크 밖에는 어떤 채널도 쓰지 않으며, 전체 알파는 원본 틀에서 그대로 유지한다. 마스크 PNG와 색상 검토본은 `output/legend-v01/*-mask-preview*.png`에 남긴다.
5. 최종 원본과 게임용은 바이트 동일 복사. 손패용은 가장자리 반사 샘플링을 쓰는 고품질 bicubic으로 256×384 RGBA를 만든다.
6. 다시 PNG를 열어 크기·PNG RGBA 색 유형·모서리 알파·전체 알파·마스크 밖 RGBA 차이·SHA-256을 검사한다. 손패 보존 대조는 같은 방식으로 축소한 기준 틀과 비교하되 필터 영향 범위 2px만 제외한다. 실제 256×384 손패 크기의 6장과 에린/목재 비교 시트를 직접 검토한다.

목재 원본의 네 꼭짓점 알파는 TL/TR/BL/BR 순서 `[1,0,2,0]`이다. 광석도 이를 정확히 보존한다. 완전한 0으로 고치면 요청서의 틀 픽셀·알파 보존 조건을 어기므로 수정하지 않았다. 전설의 네 꼭짓점은 모두 0이다.

## 재생성·채택 이유

- 전설 5종: 최초 카드 통째 생성본은 프레임 곡선과 질감이 미세하게 달라 최종 프레임으로 미채택. 프레임 없는 그림을 재생성하고 원본 틀에 합성했다.
- frost_crown: 최초 은색 받침이 섞인 왕관을 전체가 얼음 결정인 왕관으로 정리했다.
- wild_grimoire: 최초 표지에 생긴 문장/나침반 형태의 문양을 없애고, 무문양 표지와 빈 페이지로 재생성했다.
- fire_brazier: 첫 프레임 없는 그림에서는 가운데 다리가 배지 뒤에 가려져, 아래쪽 여백을 늘린 구도로 한 번 더 생성했다. 이전 입력은 `output/legend-v01/sources/fire_brazier-illustration-v01.png`에 남겼다.
- ore: 화풍·소재·아이콘이 요청에 맞아 최초 생성 그림을 채택했다. 프레임은 생성본을 쓰지 않고 목재 원본을 썼다.

## 1차 카드 생성 프롬프트 (실제 전문)

전설의 입력 순서는 편집 대상 전설 틀 → 불꽃 에일 원화이며, `transparent_background=true`로 호출했다. 광석은 목재 게임 PNG → 승인 목재 PNG 순서이며 역시 `transparent_background=true`로 호출했다. 생성 알파를 게임 틀에 덮어쓰지 않았다.

### frost_crown

```text
Use case: stylized-concept; precise-object-edit for a production fantasy game card. Image 1 is the edit target/frame and layout reference. Image 2 is an illustration STYLE reference only, do not copy its mug or fire subject. Create ONE upright 1024x1536 (2:3) card. Set this in a medieval-based fantasy world, allowing familiar fantasy adaptations while preserving a medieval atmosphere. Replace the woman/tavern in the central picture window and replace the beer mug icon inside the small circular badge at (512,1090). Keep the purple starry outer border, gold frame, top oval cream title panel, large continuous lower cream rules panel, corner transparency and all layout geometry unchanged. Absolutely no writing, letters, numbers, runes, glyphs, logos or watermarks anywhere; both panels stay completely blank (two-line title and four-line rules space). The illustration must be bold, smooth, high-saturation collectible fantasy item painting: one very LARGE central subject, dynamic diagonal/swirl composition, chunky simple shapes, striking rim light and magical glow, broad planes of color, very little tiny surface texture, instantly readable at 256x384. No existing game's specific artwork or UI copied. Keep all new content inside the picture window and badge interior.
SUBJECT frost_crown: A queen's crown made entirely from sharp ice crystals floats in the center, tilted dramatically in three-quarter view. It fills most of the central window. Spear-like cold streams burst from the crown and whirl into a sweeping snowstorm around it. Strong icy blue and silver-white crystal edges against deep indigo-violet; blurred snow-covered conifer forest under night sky behind it. Majestic, cold, powerful, no person. BADGE: replace the beer mug with a single small ice crown pictogram, clean cream outline on the existing dark purple circular field. Keep it centered within the existing gold circular rim.
```

### lich_crown

```text
Use case: stylized-concept; precise-object-edit for a production fantasy game card. Image 1 is the edit target/frame and layout reference. Image 2 is an illustration STYLE reference only, do not copy its mug or fire subject. Create ONE upright 1024x1536 (2:3) card. Set this in a medieval-based fantasy world, allowing familiar fantasy adaptations while preserving a medieval atmosphere. Replace the woman/tavern in the central picture window and replace the beer mug icon inside the small circular badge at (512,1090). Keep the purple starry outer border, gold frame, top oval cream title panel, large continuous lower cream rules panel, corner transparency and all layout geometry unchanged. Absolutely no writing, letters, numbers, runes, glyphs, logos or watermarks anywhere; both panels stay completely blank (two-line title and four-line rules space). The illustration must be bold, smooth, high-saturation collectible fantasy item painting: one very LARGE central subject, dynamic diagonal/swirl composition, chunky simple shapes, striking rim light and magical glow, broad planes of color, very little tiny surface texture, instantly readable at 256x384. No existing game's specific artwork or UI copied. Keep all new content inside the picture window and badge interior.
SUBJECT lich_crown: A massive lord's crown forged from black iron and ivory bones floats at a dramatic angle in the middle. A large violet gemstone shines on its brow. Teal-green and purple spirit flames lick up and spiral around it. Below: graveyard fog and blurred leaning gravestone silhouettes, no inscriptions. Crown large and immediately recognizable, no wearer. Black, bone ivory, luminous teal and purple. No blood, gore or brutality. BADGE: a small bone crown pictogram with cream edge on the existing dark purple field, centered inside the original gold circular rim.
```

### wild_grimoire

```text
Use case: stylized-concept; precise-object-edit for a production fantasy game card. Image 1 is the edit target/frame and layout reference. Image 2 is an illustration STYLE reference only, do not copy its mug or fire subject. Create ONE upright 1024x1536 (2:3) card. Set this in a medieval-based fantasy world, allowing familiar fantasy adaptations while preserving a medieval atmosphere. Replace the woman/tavern in the central picture window and replace the beer mug icon inside the small circular badge at (512,1090). Keep the purple starry outer border, gold frame, top oval cream title panel, large continuous lower cream rules panel, corner transparency and all layout geometry unchanged. Absolutely no writing, letters, numbers, runes, glyphs, logos or watermarks anywhere; both panels stay completely blank (two-line title and four-line rules space). The illustration must be bold, smooth, high-saturation collectible fantasy item painting: one very LARGE central subject, dynamic diagonal/swirl composition, chunky simple shapes, striking rim light and magical glow, broad planes of color, very little tiny surface texture, instantly readable at 256x384. No existing game's specific artwork or UI copied. Keep all new content inside the picture window and badge interior.
SUBJECT wild_grimoire: A large battered leather grimoire floats WIDE OPEN, tilted diagonally in the middle. Completely blank cream pages curl and flutter from it; no page text or runes at all. Fire, chunky ice shards, green vines, forked lightning and bright starlight burst from between its pages in a single exuberant swirling eruption. Purple background with orange, teal and green flashes. Chaotic yet joyful magic; the open book is clearly the primary large silhouette. BADGE: a single small open book pictogram with blank pages, cream edge on the existing purple field inside the original gold circular rim.
```

### fire_brazier

```text
Use case: stylized-concept; precise-object-edit for a production fantasy game card. Image 1 is the edit target/frame and layout reference. Image 2 is an illustration STYLE reference only, do not copy its mug or fire subject. Create ONE upright 1024x1536 (2:3) card. Set this in a medieval-based fantasy world, allowing familiar fantasy adaptations while preserving a medieval atmosphere. Replace the woman/tavern in the central picture window and replace the beer mug icon inside the small circular badge at (512,1090). Keep the purple starry outer border, gold frame, top oval cream title panel, large continuous lower cream rules panel, corner transparency and all layout geometry unchanged. Absolutely no writing, letters, numbers, runes, glyphs, logos or watermarks anywhere; both panels stay completely blank (two-line title and four-line rules space). The illustration must be bold, smooth, high-saturation collectible fantasy item painting: one very LARGE central subject, dynamic diagonal/swirl composition, chunky simple shapes, striking rim light and magical glow, broad planes of color, very little tiny surface texture, instantly readable at 256x384. No existing game's specific artwork or UI copied. Keep all new content inside the picture window and badge interior.
SUBJECT fire_brazier: A monumental medieval stone and cast-iron brazier on THREE sturdy legs fills the central picture window. An imposing FIRE ELEMENTAL emerges from it as a huge living flame face with two blazing eyes and an open mouth. Two arm-like flame tongues rise from the flame body, one holding a single LARGE fireball overhead. Majestic, fierce and powerful, not cute or childish. Hot orange, crimson and molten gold, intense glow against dark violet smoke. Keep the three-legged vessel recognizable and fully inside the illustration. BADGE: one bold small flame pictogram with cream edge on the existing dark purple field inside the original gold circular rim.
```

### winter_bell

```text
Use case: stylized-concept; precise-object-edit for a production fantasy game card. Image 1 is the edit target/frame and layout reference. Image 2 is an illustration STYLE reference only, do not copy its mug or fire subject. Create ONE upright 1024x1536 (2:3) card. Set this in a medieval-based fantasy world, allowing familiar fantasy adaptations while preserving a medieval atmosphere. Replace the woman/tavern in the central picture window and replace the beer mug icon inside the small circular badge at (512,1090). Keep the purple starry outer border, gold frame, top oval cream title panel, large continuous lower cream rules panel, corner transparency and all layout geometry unchanged. Absolutely no writing, letters, numbers, runes, glyphs, logos or watermarks anywhere; both panels stay completely blank (two-line title and four-line rules space). The illustration must be bold, smooth, high-saturation collectible fantasy item painting: one very LARGE central subject, dynamic diagonal/swirl composition, chunky simple shapes, striking rim light and magical glow, broad planes of color, very little tiny surface texture, instantly readable at 256x384. No existing game's specific artwork or UI copied. Keep all new content inside the picture window and badge interior.
SUBJECT winter_bell: One huge frost-covered ancient BRONZE BELL hangs from a weathered medieval WOODEN BELFRY CROSSBEAM near the upper edge of the art window. The bell swings dramatically on its chain, its entire flared bronze silhouette large and clear in the center. A white blizzard SHOCKWAVE RING spreads outward from its mouth, driving vague shadow monster silhouettes outward and dissolving them into dark wisps. Solemn, majestic, slightly frightening, no gore. Bronze, white snow, deep midnight indigo. No inscriptions or symbols. BADGE: one small bronze bell pictogram with cream edge on the existing purple field inside the original gold circular rim.
```

### ore

```text
Use case: stylized-concept / precise-object-edit. Make ONE upright 1024x1536 (2:3) resource card for a medieval-based fantasy game; familiar fantasy adaptations allowed while preserving a medieval atmosphere. Image 1 is the EDIT TARGET: the current textless timber card. Image 2 is the APPROVED resource layout/style reference ONLY; do not reproduce its writing. Replace ONLY the picture inside the central rounded rectangular window and the timber icon in the small cream lozenge at (512,1090). Keep all existing purple card stock, black variable-width ink frame, blank cream title panel and single large continuous blank cream rules panel, small icon holder outline, positions, proportions, and rounded corner transparency exactly unchanged. The name panel has space for two lines and lower panel four lines. All panels must be COMPLETELY BLANK. No letters, words, writing, numbers, runes, glyphs, watermarks or logos anywhere. SUBJECT ore: two or three LARGE angular gray rock lumps with visible bluish metal veins and a few chunky blue-gray metallic crystals embedded in them. Put the ore prominently in the CENTER. Beside the rocks, include a stout dwarven pickaxe HEAD with a short visible wooden handle and an old medieval miner's oil lantern that glows warm orange; dark stone mine tunnel wall as subdued background. Cool gray and slate blue ore, small warm amber lamp contrast. Painting style must MATCH the approved timber resource card: watercolor and broad color washes, bold clear black tapered ink outlines, large graphic shapes, minimal tiny texture, readable as ore at 256x384. No photorealism, modern machinery, wires or electric lamp. SMALL ICON: replace the log bundle with a single chunky gray ore rock with a blue metallic vein, outlined in thick black ink, centered inside the EXISTING small cream icon holder at y1025..1154 without changing its black rim.
```

## 2차 전설 그림 전용 프롬프트 (실제 전문)

입력 순서: 불꽃 에일 원화(화풍) → 전설 틀(세계와 색상 맥락). `transparent_background=false`. 도구의 정사각 원본 해상도를 보관하고 카드에 넣을 때 비율을 유지했다.

### frost_crown

```text
Use case: stylized-concept, production illustration insert. Generate ONE SQUARE 1024x1024 FULL-BLEED ILLUSTRATION ONLY, NOT A CARD. Image 1 is a STYLE reference: use its bold chunky simplified magical collectible-item painting, strong rim lighting and broad smooth color masses, but NOT its mug or fire subject. Image 2 supplies the medieval fantasy game's palette context ONLY; do NOT draw its frame, woman, tavern, beer, badge, cream panels, border, text fields, lettering or interface. This image will be cut into the existing card's central art window. Keep the main object LARGE at the center, entirely within x=150..875 and y=120..850 of the square. Atmospheric background must fill every edge. Use dynamic diagonal movement and swirl, saturated smooth painterly color, a few large exaggerated shapes, bright magical lighting, clean silhouette at thumbnail size. Avoid tiny scratches, granular texture, engraving, intricate filigree or excessive small particles. This is an original item illustration, not a copy of any existing game art. Medieval-based fantasy with familiar fantasy adaptations and medieval everyday materials and atmosphere. Absolutely NO letters, numbers, writing, runes, glyphs, sigils, emblems, geometric marks or watermarks anywhere, including the object's surfaces. No people.
SUBJECT: A queen's crown made ENTIRELY OF BLUE ICE CRYSTALS floats at a dynamic three-quarter tilt in the middle. No metal setting: the whole crown is solid transparent ice with five or six large sharp crystalline spires. Spear-like cold streams burst from it into a sweeping snowstorm vortex. Silver-white rim light, icy cyan, deep indigo-purple. Subdued blurred snowy conifer forest at night behind it. The ice crown should be the dominant simple readable silhouette.
```

### lich_crown

```text
Use case: stylized-concept, production illustration insert. Generate ONE SQUARE 1024x1024 FULL-BLEED ILLUSTRATION ONLY, NOT A CARD. Image 1 is a STYLE reference: use its bold chunky simplified magical collectible-item painting, strong rim lighting and broad smooth color masses, but NOT its mug or fire subject. Image 2 supplies the medieval fantasy game's palette context ONLY; do NOT draw its frame, woman, tavern, beer, badge, cream panels, border, text fields, lettering or interface. This image will be cut into the existing card's central art window. Keep the main object LARGE at the center, entirely within x=150..875 and y=120..850 of the square. Atmospheric background must fill every edge. Use dynamic diagonal movement and swirl, saturated smooth painterly color, a few large exaggerated shapes, bright magical lighting, clean silhouette at thumbnail size. Avoid tiny scratches, granular texture, engraving, intricate filigree or excessive small particles. This is an original item illustration, not a copy of any existing game art. Medieval-based fantasy with familiar fantasy adaptations and medieval everyday materials and atmosphere. Absolutely NO letters, numbers, writing, runes, glyphs, sigils, emblems, geometric marks or watermarks anywhere, including the object's surfaces. No people.
SUBJECT: A massive lord's crown forged of BLACK IRON AND IVORY BONE, its band tilted diagonally, with one large violet gem on the brow. Few large bone arches and black iron spires, no fine ornaments, no skull face. Teal-green and purple spirit flame tongues swirl around the crown. Fog and leaning unmarked gravestone silhouettes below in a blurred medieval graveyard. Crown is large and entirely visible; ominous power. No blood or gore.
```

### wild_grimoire

```text
Use case: stylized-concept, production illustration insert. Generate ONE SQUARE 1024x1024 FULL-BLEED ILLUSTRATION ONLY, NOT A CARD. Image 1 is a STYLE reference: use its bold chunky simplified magical collectible-item painting, strong rim lighting and broad smooth color masses, but NOT its mug or fire subject. Image 2 supplies the medieval fantasy game's palette context ONLY; do NOT draw its frame, woman, tavern, beer, badge, cream panels, border, text fields, lettering or interface. This image will be cut into the existing card's central art window. Keep the main object LARGE at the center, entirely within x=150..875 and y=120..850 of the square. Atmospheric background must fill every edge. Use dynamic diagonal movement and swirl, saturated smooth painterly color, a few large exaggerated shapes, bright magical lighting, clean silhouette at thumbnail size. Avoid tiny scratches, granular texture, engraving, intricate filigree or excessive small particles. This is an original item illustration, not a copy of any existing game art. Medieval-based fantasy with familiar fantasy adaptations and medieval everyday materials and atmosphere. Absolutely NO letters, numbers, writing, runes, glyphs, sigils, emblems, geometric marks or watermarks anywhere, including the object's surfaces. No people.
SUBJECT: A large battered leather grimoire floats WIDE OPEN, tilted diagonally, blank cream pages fluttering in a jubilant magical eruption. The broad dark leather cover is PLAIN with NO design or markings at all; only simple undecorated metal corner protectors. From between the pages burst orange flame, a few chunky blue ice shards, big green vine curls, violet lightning and bright starlight, unified into a single dynamic swirl. Purple background. The book is instantly readable, large with a full unobstructed silhouette. Exciting chaos. All pages completely blank.
```

### fire_brazier

```text
Use case: stylized-concept, production illustration insert. Generate ONE SQUARE 1024x1024 FULL-BLEED ILLUSTRATION ONLY, NOT A CARD. Image 1 is a STYLE reference: use its bold chunky simplified magical collectible-item painting, strong rim lighting and broad smooth color masses, but NOT its mug or fire subject. Image 2 supplies the medieval fantasy game's palette context ONLY; do NOT draw its frame, woman, tavern, beer, badge, cream panels, border, text fields, lettering or interface. This image will be cut into the existing card's central art window. Keep the main object LARGE at the center, entirely within x=150..875 and y=120..850 of the square. Atmospheric background must fill every edge. Use dynamic diagonal movement and swirl, saturated smooth painterly color, a few large exaggerated shapes, bright magical lighting, clean silhouette at thumbnail size. Avoid tiny scratches, granular texture, engraving, intricate filigree or excessive small particles. This is an original item illustration, not a copy of any existing game art. Medieval-based fantasy with familiar fantasy adaptations and medieval everyday materials and atmosphere. Absolutely NO letters, numbers, writing, runes, glyphs, sigils, emblems, geometric marks or watermarks anywhere, including the object's surfaces. No people.
SUBJECT: A broad STONE AND CAST-IRON BRAZIER on THREE sturdy legs stands in the lower center; the three legs are separated and clearly visible. From within it emerges a MAJESTIC FIRE ELEMENTAL: one enormous flame face with TWO DISTINCT EYES and an OPEN MOUTH, no human or skull head. Its two arms are flowing flame tongues, one lifting a SINGLE LARGE FIREBALL overhead. Fierce and imposing, not cute. Hot orange, crimson, gold in large smooth flame shapes against dark violet smoky background. Entire brazier, face, arms and fireball comfortably inside square.
```

### winter_bell

```text
Use case: stylized-concept, production illustration insert. Generate ONE SQUARE 1024x1024 FULL-BLEED ILLUSTRATION ONLY, NOT A CARD. Image 1 is a STYLE reference: use its bold chunky simplified magical collectible-item painting, strong rim lighting and broad smooth color masses, but NOT its mug or fire subject. Image 2 supplies the medieval fantasy game's palette context ONLY; do NOT draw its frame, woman, tavern, beer, badge, cream panels, border, text fields, lettering or interface. This image will be cut into the existing card's central art window. Keep the main object LARGE at the center, entirely within x=150..875 and y=120..850 of the square. Atmospheric background must fill every edge. Use dynamic diagonal movement and swirl, saturated smooth painterly color, a few large exaggerated shapes, bright magical lighting, clean silhouette at thumbnail size. Avoid tiny scratches, granular texture, engraving, intricate filigree or excessive small particles. This is an original item illustration, not a copy of any existing game art. Medieval-based fantasy with familiar fantasy adaptations and medieval everyday materials and atmosphere. Absolutely NO letters, numbers, writing, runes, glyphs, sigils, emblems, geometric marks or watermarks anywhere, including the object's surfaces. No people.
SUBJECT: A HUGE ANCIENT BRONZE BELL encrusted with white frost hangs from a weathered WOODEN BELFRY CROSSBEAM and short iron chain. The bell swings strongly at a diagonal, complete flared silhouette in the center, broad undecorated bronze surfaces. Its ringing creates a powerful white snowstorm SHOCKWAVE RING spreading around the mouth. Outside the ring, three vague shadow monster silhouettes dissolve into dark wisps and scatter outward. Solemn, majestic and slightly frightening. Bronze, white snow, midnight blue, cool rim light. No gore, symbols or inscriptions.
```

## 3차 화로 구도 수정 프롬프트 (실제 전문)

입력: 2차 `fire_brazier` 그림 전용 생성본. 호출 당시 경로는 `art/cards/legend-v01/drafts/fire_brazier-illustration.png`였고, 납품 정리 후 같은 입력은 `output/legend-v01/sources/fire_brazier-illustration-v01.png`에 보존했다. `transparent_background=false`.

```text
Use case: stylized-concept / composition refinement. Repaint image 1 as ONE SQUARE full-bleed medieval fantasy item illustration, no card frame, borders, panels or badge. Preserve this exact fierce fire elemental concept, warm colors, violet smoky backdrop, two glowing eyes and mouth, flame arms and single overhead fireball, three-legged stone/cast-iron brazier. COMPOSITION CHANGE REQUIRED: fit the COMPLETE elemental, the COMPLETE fireball and ALL THREE separated brazier legs comfortably into the UPPER CENTRAL 75 PERCENT of the square (x15%..85%, y12%..76%). The bottom 24 percent must contain ONLY empty dark violet ground and soft orange reflection; no feet or important objects there, because a circular UI badge will cover bottom-center after compositing. Give the fireball room above; do not cut off its silhouette. Simplify to chunky big smooth forms with a strong rim light and fewer tiny texture marks. No inscriptions, emblems, runes, words, letters, numbers, symbols, watermark, skull decoration or new objects. This is a medieval-based fantasy world with familiar fantasy adaptations and medieval materials, not modern technology. Keep the spirit majestic and menacing, not cute.
```

## 범위

게임 코드·씬·셰이더·카탈로그·글자 배치·기존 다른 카드·루트 실행파일은 이 작업에서 수정하지 않았다. Godot 임포트/실행/내보내기는 수행하지 않았고 커밋·stash·checkout·reset도 수행하지 않았다. 게임 반영의 다음 단계는 구현 담당 세션의 임포트다.

