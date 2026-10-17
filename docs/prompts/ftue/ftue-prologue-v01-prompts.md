# FTUE 프롤로그 v01 — 실제 이미지 생성 기록

- 제작일: 2026-10-17
- 방식: 내장 `image_gen`. CLI/API 우회 사용 없음. 총 8회 호출(필수 7종, 첫 장 재생성 1회).
- 각 참조는 실제 `referenced_image_paths` 입력이다. 편집 요청을 제외하면 원본 수정 대상이 아닌 시각 참고 자료다.
- 최종 크기·채널 변환: `output/ftue-prologue-v01/build-assets.ps1`의 System.Drawing 처리. 배경은 비율 유지 중앙 크롭/리사이즈 후 RGB, 인물은 비율 유지 contain 리사이즈 후 RGBA. 생성된 알파를 유지한다.
- 잠금 실루엣은 image_gen 편집 결과의 미세한 RGB 변동을 제거하기 위해 보이는 모든 픽셀을 정확한 `#2a2346`으로 양자화했다. 생성된 외곽과 알파는 유지했다.
- 선택 로고는 생략하고 요청서의 게임 폰트 대체 방식을 사용한다.

## 1. prologue_01 — 시도 1

실제 참고 입력:

- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/04-prototype-reference-simplified.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/07-colored-forest-darkness.png`

도구 옵션: `transparent_background=false`.

실제 프롬프트:

```text
Use case: illustration-story. Asset for Witch's Lodge, a medieval fantasy game. Create ONE finished 16:9 landscape illustration, target 1920x1080, full bleed, no border. Reference 1 is the primary approved environment: use its compact timber and stone gabled lodge, broad simplified snow shapes and restrained painterly brushwork. Reference 2 supplies dark violet-indigo-teal forest colors. Any gameplay screenshot supplies building proportions only, never copy its UI, text or low-poly rendering. Hand-painted storybook game illustration with confident sparse brushstrokes, large clear color masses, restrained detail, readable silhouettes. No photography, no 3D rendering, no dense grain or stippling. Medieval timber, stone, wool, leather, iron, candles only. Cold violet/indigo/teal palette; warm amber is localized fire or window/candle light. No modern objects. No text, lettering, logo, signature, watermark or UI. Bottom 25% of the WHOLE canvas must be very dark, low-contrast and exceptionally simple, with no focal objects, characters, bright snow, particles or patterned texture, suitable for subtitle overlay. Keep all important subjects away from the outermost 5% for a slow zoom. No gore or explicit violence. Any witch wears a violet-indigo cloak with a LOW ROUNDED NON-POINTED hood; hidden face, no directional affiliation symbols, no frost/flame/herb/ghost emblems.
Scene: aftermath of the witch hunt. A distant medieval village burns in dim amber fire with reddish purple smoke; crooked rooflines and a narrow stone steeple form a small faraway silhouette. Vast indigo sky and huge sweeping smoke masses dominate the top two thirds. On a nearby hill across the middle-lower portion, EXACTLY FOUR SMALL cloaked witches seen from behind separate along four diverging paths, their distinct silhouettes subtly turning away in different directions. All four figures must be small, fully above y=75%, no close-up people. The foreground hill falls into broad uninterrupted deep violet shadow across the bottom quarter. Somber, quiet escape; no victims, weapons, bodies or graphic destruction. Wide cinematic composition, no compass or directional iconography.
```

## 2. prologue_01 — 시도 2

실제 참고 입력:

- `C:/Users/vnvnc/.codex/generated_images/01a14a51-5d35-70a1-936c-789a9231345f/exec-34acd951-732f-4d6c-b912-7d6b4adc993f.png`

도구 옵션: `transparent_background=false`.

실제 프롬프트:

```text
Edit this prologue illustration. Keep its distant burning medieval village, huge purple smoke and sky, violet snow, four diverging paths, four SMALL cloaked figures, painterly broad color masses and very dark empty bottom quarter. Remove the entire nearby lodge, its fence, sheep, barrels and every warm light on the LEFT hill; replace this area with plain dark violet snowy hillside and sparse trees. The story takes place BEFORE the lodge exists. Change ALL FOUR figures into simple featureless dark cloaked silhouettes with LOW ROUND HOODS, ABSOLUTELY NO pointed hat tips, hat brims, staffs, tools, visible faces, bags or other accessories. Heads must have smooth rounded contours like plain medieval cowls. Exactly four survivors with backs turned and walking away along differing paths; place all bodies above the bottom quarter. Keep them small and their details minimal. Simplify the foreground down to large dark shadow shapes. No text, watermark, compass, symbols, gore or UI. Output one 16:9 illustration.
```

## 3. prologue_02 — 시도 1

실제 참고 입력:

- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/04-prototype-reference-simplified.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/07-colored-forest-darkness.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/godot/screenshots/01-start.png`

도구 옵션: `transparent_background=false`.

실제 프롬프트:

```text
Use case: illustration-story. Asset for Witch's Lodge, a medieval fantasy game. Create ONE finished 16:9 landscape illustration, target 1920x1080, full bleed, no border. Reference 1 is the primary approved environment: use its compact timber and stone gabled lodge, broad simplified snow shapes and restrained painterly brushwork. Reference 2 supplies dark violet-indigo-teal forest colors. Any gameplay screenshot supplies building proportions only, never copy its UI, text or low-poly rendering. Hand-painted storybook game illustration with confident sparse brushstrokes, large clear color masses, restrained detail, readable silhouettes. No photography, no 3D rendering, no dense grain or stippling. Medieval timber, stone, wool, leather, iron, candles only. Cold violet/indigo/teal palette; warm amber is localized fire or window/candle light. No modern objects. No text, lettering, logo, signature, watermark or UI. Bottom 25% of the WHOLE canvas must be very dark, low-contrast and exceptionally simple, with no focal objects, characters, bright snow, particles or patterned texture, suitable for subtitle overlay. Keep all important subjects away from the outermost 5% for a slow zoom. No gore or explicit violence. Any witch wears a violet-indigo cloak with a LOW ROUNDED NON-POINTED hood; hidden face, no directional affiliation symbols, no frost/flame/herb/ghost emblems.
Scene: a small welcoming lodge in a clearing deep inside a snow-covered violet conifer forest. Lodge in the upper-middle, with short compact timber walls on a stone base, ONE simple steep gabled snow roof, stone chimney with a single broad wisp of smoke, a front wooden door and ONE amber-lit window. Use the primary reference's roof/wall construction and screenshot's compact proportions, with fewer props and NO sheep enclosure for this narrative frame. One SMALL witch seen from behind stands before the door holding a tiny amber candle lantern. Her cloak is purple-indigo wool, her plain hood has a SMOOTH ROUNDED head shape with no peak or brim, face completely hidden; no wizard hat, staff or symbols. The clearing leads into deep dark violet foreground shadow. Large simple snowy silhouettes, restrained brushwork, quiet refuge atmosphere. No other buildings, characters or magical decorations. Bottom quarter nearly unbroken deep indigo shadow.
```

## 4. prologue_03 — 시도 1

실제 참고 입력:

- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/04-prototype-reference-simplified.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/07-colored-forest-darkness.png`

도구 옵션: `transparent_background=false`.

실제 프롬프트:

```text
Use case: illustration-story. Asset for Witch's Lodge, a medieval fantasy game. Create ONE finished 16:9 landscape illustration, target 1920x1080, full bleed, no border. Reference 1 is the primary approved environment: use its compact timber and stone gabled lodge, broad simplified snow shapes and restrained painterly brushwork. Reference 2 supplies dark violet-indigo-teal forest colors. Any gameplay screenshot supplies building proportions only, never copy its UI, text or low-poly rendering. Hand-painted storybook game illustration with confident sparse brushstrokes, large clear color masses, restrained detail, readable silhouettes. No photography, no 3D rendering, no dense grain or stippling. Medieval timber, stone, wool, leather, iron, candles only. Cold violet/indigo/teal palette; warm amber is localized fire or window/candle light. No modern objects. No text, lettering, logo, signature, watermark or UI. Bottom 25% of the WHOLE canvas must be very dark, low-contrast and exceptionally simple, with no focal objects, characters, bright snow, particles or patterned texture, suitable for subtitle overlay. Keep all important subjects away from the outermost 5% for a slow zoom. No gore or explicit violence. Any witch wears a violet-indigo cloak with a LOW ROUNDED NON-POINTED hood; hidden face, no directional affiliation symbols, no frost/flame/herb/ghost emblems.
Scene: the secret medieval STONE CELLAR directly beneath the lodge, shown like a storybook cross-section, NO exterior cabin scene. Broad irregular stone chamber walls in very dark indigo, simple stone floor. In the center at x=50%, y=53%, a single ROUNDED upright seal stone about half a person's height, dark gray-violet, with ONLY THREE OR FOUR faint abstract cyan-teal rune-shaped marks glowing very softly. These are pictorial magical markings, not writing or readable letters. At the top of the composition, rough timber floorboards and beams of the lodge overhead; narrow gaps let down a few muted AMBER slivers of light. In dark wall recesses near the left and right sides, just two or three small pairs of dim eyes suggest hidden creatures, no visible bodies. Keep the seal stone entirely above y=73%. Bottom 25% is extremely dark plain shadow with no distinct cobbles, markings or objects, reserved for subtitles. No human, furniture, torches, treasure, extra rune circles, vegetation or pointed emblems. Painterly simple big stone shapes and sparse broad brushwork, mysterious rather than horror.
```

## 5. prologue_04 — 시도 1

실제 참고 입력:

- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/04-prototype-reference-simplified.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/07-colored-forest-darkness.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/godot/screenshots/01-start.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/godot/screenshots/03-combat.png`

도구 옵션: `transparent_background=false`.

실제 프롬프트:

```text
Use case: illustration-story. Asset for Witch's Lodge, a medieval fantasy game. Create ONE finished 16:9 landscape illustration, target 1920x1080, full bleed, no border. Reference 1 is the primary approved environment: use its compact timber and stone gabled lodge, broad simplified snow shapes and restrained painterly brushwork. Reference 2 supplies dark violet-indigo-teal forest colors. Any gameplay screenshot supplies building proportions only, never copy its UI, text or low-poly rendering. Hand-painted storybook game illustration with confident sparse brushstrokes, large clear color masses, restrained detail, readable silhouettes. No photography, no 3D rendering, no dense grain or stippling. Medieval timber, stone, wool, leather, iron, candles only. Cold violet/indigo/teal palette; warm amber is localized fire or window/candle light. No modern objects. No text, lettering, logo, signature, watermark or UI. Bottom 25% of the WHOLE canvas must be very dark, low-contrast and exceptionally simple, with no focal objects, characters, bright snow, particles or patterned texture, suitable for subtitle overlay. Keep all important subjects away from the outermost 5% for a slow zoom. No gore or explicit violence. Any witch wears a violet-indigo cloak with a LOW ROUNDED NON-POINTED hood; hidden face, no directional affiliation symbols, no frost/flame/herb/ghost emblems.
Scene: the compact lodge seen FROM THE FRONT at the transition from dusk into night. Its simple triangular snow-covered gable roof, timber front wall and stone footing match the references. Place lodge around center, an amber window and door as the quiet divider between two worlds. On the LEFT half, under muted mauve evening afterglow, EXACTLY THREE small medieval travelers/mercenaries carrying wool bedrolls, leather packs and one sheathed iron sword gather cautiously before the door. Rounded simple forms, neutral cloaks, no visible faces required. On the RIGHT half, deep dark violet and teal forest at night: one small low spider-like monster silhouette and two tiny pairs of distant glowing eyes half-hidden in the tree line; threatening but not graphic, no giant creature, webs or detailed anatomy. This is ONE continuous environment with a natural dusk-to-night lighting transition, never a split-panel or collage. Keep all visitors and spider fully above y=73%. Broad foreground ground falls into an uninterrupted deep indigo bottom quarter for subtitles. Only window/candle light is warm amber. Restrained brushwork, large shapes, no extra dwellings, no witch in this frame, no text.
```

## 6. title_bg — 시도 1

실제 참고 입력:

- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/04-prototype-reference-simplified.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/07-colored-forest-darkness.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/godot/screenshots/01-start.png`

도구 옵션: `transparent_background=false`.

실제 프롬프트:

```text
Use case: illustration-story. Asset for Witch's Lodge, a medieval fantasy game. Create ONE finished 16:9 landscape illustration, target 1920x1080, full bleed, no border. Reference 1 is the primary approved environment: use its compact timber and stone gabled lodge, broad simplified snow shapes and restrained painterly brushwork. Reference 2 supplies dark violet-indigo-teal forest colors. Any gameplay screenshot supplies building proportions only, never copy its UI, text or low-poly rendering. Hand-painted storybook game illustration with confident sparse brushstrokes, large clear color masses, restrained detail, readable silhouettes. No photography, no 3D rendering, no dense grain or stippling. Medieval timber, stone, wool, leather, iron, candles only. Cold violet/indigo/teal palette; warm amber is localized fire or window/candle light. No modern objects. No text, lettering, logo, signature, watermark or UI. Bottom 25% of the WHOLE canvas must be very dark, low-contrast and exceptionally simple, with no focal objects, characters, bright snow, particles or patterned texture, suitable for subtitle overlay. Keep all important subjects away from the outermost 5% for a slow zoom. No gore or explicit violence. Any witch wears a violet-indigo cloak with a LOW ROUNDED NON-POINTED hood; hidden face, no directional affiliation symbols, no frost/flame/herb/ghost emblems.
Asset-specific COMPOSITION OVERRIDES: title background, no prologue figures. ONE compact lodge seen from a slightly HIGH ELEVATED three-quarter view, showing roof top and two walls, similar to the game camera. Put the lodge entirely in the CENTER-RIGHT around x=66%, y=52%; timber and stone, simple gabled lavender snowy roof, one chimney with restrained smoke and AMBER WINDOWS. Broad quiet moonlit lavender snow around it, dark purple and teal conifer forest enclosing the clearing. LEFT 40% of the entire image MUST be very dark near-solid indigo forest shade: almost no individual branches, snow highlights, rocks, path or props there; this is a menu overlay area. TOP CENTER 20% of the image must be plain, simple dark night sky, no moon, stars, tree tips or chimney smoke at the title position. Entire lower quarter dark simple shadow. Left and right outermost 8% must be disposable dark scenery with no important subjects, safe for horizontal panning. No characters, no sheep, no monsters, no gate, no flags, no runes, no written signs. Keep the welcoming lodge small, quiet, isolated in a large dark forest. Painterly broad colored shapes, NO 3D render look. No baked text or UI.
```

## 7. witch_portrait — 시도 1

실제 참고 입력:

- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/environment/04-prototype-reference-simplified.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/godot/assets/cards/axe_mercenary.png`

도구 옵션: `transparent_background=true`.

실제 프롬프트:

```text
Use case: stylized-concept. ONE transparent game selection portrait for Witch's Lodge, portrait aspect 2:3, target RGBA 512x768. True transparent background outside the figure. Reference 1: approved environment's broad painterly shapes, violet-indigo palette and sparse texture. Reference 2: game-card illustration brushwork and readable silhouettes ONLY; do NOT include any card border, frame, lettering, labels, paper panels or background.
Subject: the unnamed witch, shown FRONTALLY from just above the knees upward, centered, a self-contained cutout. Violet and indigo wool cloak, loose simple medieval layers and a LOW ROUNDED COWL HOOD that follows the round skull, NO pointed hat, NO hat brim, NO high hood peak. Upper face and eyes fully swallowed in soft hood and hair shadow; only a small neutral lower face visible, no distinctive identity. Plain fabric fastener, no emblems or jewelry. Both arms in frame, hands gently holding a SMALL medieval iron candle lantern at waist level, warm amber glow localized to hands and nearby cloth. No fire magic. Shoulders, hood and lantern have a clear isolated silhouette, all edges comfortably inset from canvas with ample transparent margin. Hem ends in a natural above-knee portrait crop, no legs or feet. Restrained painterly hand-painted fantasy illustration, broad brush strokes and 2-3 clear value bands, simple forms, NO photorealism, NO 3D render, NO dense stippling. No frost, flame, plants, herbs, ghosts, elemental or directional symbols, staff, magic book, crystals, armor, modern clothing, weapons, companion animals or props beyond the small lantern. No ground, scene, backing shape, glow disk, drop shadow or opaque checkerboard. Absolutely no text, symbols, logo, signature or watermark.
```

## 8. witch_locked — 시도 1

실제 참고 입력:

- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/ftue-boost-b44068/art/concepts/ftue/witch_portrait-source.png`

도구 옵션: `transparent_background=true`.

실제 프롬프트:

```text
Edit target: this supplied transparent witch portrait. Create the locked-selection version. Preserve EXACTLY the same 2:3 canvas, centered front-facing above-knee crop, rounded hood, cloak, hands and lantern OUTER CONTOUR and all outside transparent pixels. Replace the ENTIRE visible figure including the face, hair, clothes, hands and lantern with ONE UNIFORM FLAT SOLID COLOR #2a2346 (RGB 42,35,70). Zero internal details: no face, eyes, highlights, folds, clasps, lines, flame, lantern structure, gradient, texture, shadow, outline or glow anywhere inside the silhouette. The lantern and any inside gaps within the contiguous figure are solid silhouette. True transparent background, anti-aliased outer edge only. No question mark, no text, no logo, no watermark, no background or new content. Output ONE RGBA PNG, same pose and composition; target 512x768.
```

## 채택·검수·재생성 이력

- `prologue_01`: 첫 결과에는 산장·뾰족한 모자·지팡이가 따라와 미채택(`art/concepts/ftue/prologue_01-rejected-v01.png`). 두 번째 편집으로 제거한 결과를 채택했다.
- 나머지 6종은 각각 첫 생성 결과를 채택했다. 초상은 실제 알파를 확인했고, 잠금 실루엣은 해당 초상을 실제 편집 입력으로 사용했다.
- 채택 원본: `art/concepts/ftue/<파일명>-source.png`. `witch_portrait-source-v01.png`는 동일한 초상 최초 원본의 보존 사본이다.
- 최종 미리보기 시트에서 7장 모두 직접 확인했다. 인물 뒤 회색은 검수용 바탕이며 납품 PNG의 바깥은 투명하다.
- 검증: `output/ftue-prologue-v01/asset-verification.json`. 시각 확인: `visual-review.json`. 실제 입력과 생성 출력: `generation-manifest.json`.
- 소스 수정 금지를 지키기 위해 이미지 전용 격리 프로젝트에서 같은 `--headless --path godot --import`를 실행했다. 전체 게임 임포트가 새 스크립트의 `.gd.uid` 등을 생성하는 일을 피하고, FTUE 이미지의 `.import`·컴파일 텍스처만 실제 게임에 복사했다. 위치와 로그는 `godot-import-result.json`에 기록한다.

