# 마법책 제작 화면 컨셉 시안 v01 — 프롬프트 기록

작성: 2026-10-19
요청서: [컨셉 시안 요청서](../../handoff/codex-spellbook-crafting-concepts-v01.md)
납품: [README](../../../art/ui/spellbook-crafting-concepts-v01/README.md) · [비교 시트](../../../art/ui/spellbook-crafting-concepts-v01/sheet.png)

## 생성 방식

내장 `image_gen.imagegen`으로 초안 5장과 부분 보정 4장을 생성했다. CLI/API 우회 없이 호출했으며 `transparent_background=false`다. 아래는 요약이 아닌 실제 전달 프롬프트 전문이다. 파일명은 작업 후 drafts에 복사할 때 붙인 이름이며 생성 도구의 저장 경로를 지정한 것은 아니다. 원래 생성 경로와 호출별 참고 입력은 [generation-session.json](../../../art/ui/spellbook-crafting-concepts-v01/drafts/generation-session.json)에 보존했다.

## 공통 참고 입력

1. `godot/screenshots/party-frames/medallion-right.png` — 실제 낮 산장 화면·HUD 배치
2. `godot/assets/ui/hand_workbench/props-v05/SpellbookAndCandle.png` — 같은 책의 보라 표지·금속·라벤더 문양·촛불
3. `art/ui/moon-runes-v01/approved/mockup.png` — 남색·금테·달 룬 UI
4. `art/ui/moon-runes-v01/approved/hand.png` — 손패의 크림 제목·재료 카드·수량 배지

초안 01·02a·02b는 위 4장, 03·04는 위 4장과 02a 초안을 사용했다. 02a·02b 부분 보정은 해당 초안 1장만, 03·04 부분 보정은 해당 초안과 02a 보정본의 2장을 사용했다. 모든 참고 이미지는 생성 전에 열어 확인했다. 02a 보정본도 대화에서 표시된 결과를 사용했다.

## 01 · 01-entry-book-states-raw.png

출력: `art/ui/spellbook-crafting-concepts-v01/drafts/01-entry-book-states-raw.png`
참고 입력 수: 4

```text
Use-case: ui-mockup. Make a polished hand-painted casual medieval fantasy game concept screen, precisely 1920x1080 landscape 16:9. Medieval daily-life atmosphere with fantasy adaptation, thick tapered ink silhouettes, broad clean painted color masses, warm handmade illustration, restrained textures. Reference images are visual references only: image 1 actual daytime lodge-yard gameplay and HUD composition, image 2 the EXACT spellbook identity: deep purple leather cover, chunky brass corner guards/clasps, lavender parchment with crescent/star and botanical violet ink, short dripping purple candle on bronze holder, purple feather pen; image 3 approved navy/gold crescent-rune UI language, image 4 approved cream-heading resource cards. Preserve identity. Dim the recognizable DAYTIME snowy lavender lodge yard behind the foreground UI, with the game's HUD at edges. No modern technology, photorealism, cooking/firepit, invented lore, watermark, extra text or fake writing. Korean typography must be legible and spelled verbatim, cream on navy and dark violet on parchment. Large clear "???" unknown entries with empty dark item silhouettes. This is a concept mockup, not production assets.
Scene 01: ENTRY BOOK STATES comparison, a presentation board embedded over dimmed actual gameplay. Top centered Korean heading "마법책" and small subtitle "손패 왼쪽 소품 · 낮에만 제작". Foreground shows THREE equal spacious side-by-side magnified vignettes of the SAME left-end hand workbench prop: purple candle to left of open purple book and feather across its base, neighboring edge of resource hand visible at right. The book itself must match reference 2 exactly in all three states. State 1 left label "① 평소", quiet purple candle with small ordinary flame, normal book. State 2 center label "② 제작 가능", warmer brighter candle, subtle lavender rim glow along book edge, only a few magical sparkles, clearly visible white arrow mouse cursor pointing at this second book. State 3 right label "③ 밤 비활성", dark low-saturation identical book, candle UNLIT with no flame, small moon and padlock badge. A localized cool dark vignette indicates night only inside third state. Keep states separated with fine navy-gold presentation borders without obscuring the props. Above/in rear show enough recognizable daytime lodge scene; below subtle navy captions "소품 위치 고정", "빛으로 사용 가능 알림", "밤에는 제작 불가". Illustration fills width with generous margins, no crafting window in this scene. Full 1920x1080 screen.
```

## 02a · 02a-window-diorama-raw.png

출력: `art/ui/spellbook-crafting-concepts-v01/drafts/02a-window-diorama-raw.png`
참고 입력 수: 4

```text
Use-case: ui-mockup. Make a polished hand-painted casual medieval fantasy game concept screen, precisely 1920x1080 landscape 16:9. Medieval daily-life atmosphere with fantasy adaptation, thick tapered ink silhouettes, broad clean painted color masses, warm handmade illustration, restrained textures. Reference images are visual references only: image 1 actual daytime lodge-yard gameplay and HUD composition, image 2 the EXACT spellbook identity: deep purple leather cover, chunky brass corner guards/clasps, lavender parchment with crescent/star and botanical violet ink, short dripping purple candle on bronze holder, purple feather pen; image 3 approved navy/gold crescent-rune UI language, image 4 approved cream-heading resource cards. Preserve identity. Dim the recognizable DAYTIME snowy lavender lodge yard behind the foreground UI, with the game's HUD at edges. No modern technology, photorealism, cooking/firepit, invented lore, watermark, extra text or fake writing. Korean typography must be legible and spelled verbatim, cream on navy and dark violet on parchment. Large clear "???" unknown entries with empty dark item silhouettes. This is a concept mockup, not production assets.
Scene 02A, direction A "실물 책": full usable crafting window centered on gameplay. Front-facing open physical leather spellbook itself IS the window; dark purple cover and brass corners surround two broad creamy lavender parchment pages with violet botanical/crescent marginal art, thick spine, purple ribbon and feather; short purple candle on bronze holder to its left. Book occupies x330..1620 y180..820 approximately with generous readable pages. Top small navy-gold header title "마법책", sublabel "낮 · 시간 멈춤", close X upper right. Left page contains THREE colored ribbon tabs across top: selected GREEN "물약 1 / 4", COPPER "장비 1 / 5", PURPLE "마법 1 / 4". Below on left page exactly FOUR large 2x2 recipe tiles: top left selected green potion icon with title "치유 물약"; other THREE tiles EACH contain one empty item silhouette and a large crisp "???". Most recipes unknown, emphasize this. No unreadable filler writing. Right page title "치유 물약". Under it horizontal row of EXACTLY THREE round violet rune ingredient circles: first contains a tied bundle of green yarrow/mugwort herbs, badge "×2", label "약초"; next TWO empty outlined circles. Then one large central softly glowing purple transmutation magic circle with preview portrait potion CARD hovering just above it, cream card header "치유 물약", purple frame, red healing vial illustration. Below large purple wax-seal button labeled "제작". Bottom row ON WOODEN DESK BENEATH BOOK: EXACTLY SIX neatly spaced miniature cream-heading resource cards, all six readable and visible, below the page not obstructing it. Left to right headers and badges "약초" "×3"; "정화된 정수" "×1"; "양털" "×4"; "목재" "×2"; "쇠붙이" "×2"; "토끼 가죽" "×1". Images respectively tied green herb leaves; a SMALL GLASS DROPLET with clear skyblue/silver luminous water; fluffy wool; cut logs; handful rusty hinge and iron fragments; rabbit hide. Never put essence in a potion bottle. Natural parchment and violet handwriting-like ink. Magical transformation, restrained effects, readily inspectable layout, clear negative space. Do not add any other texts. Full 16:9 1920x1080.
```

## 02b · 02b-window-ui-frame-raw.png

출력: `art/ui/spellbook-crafting-concepts-v01/drafts/02b-window-ui-frame-raw.png`
참고 입력 수: 4

```text
Use-case: ui-mockup. Make a polished hand-painted casual medieval fantasy game concept screen, precisely 1920x1080 landscape 16:9. Medieval daily-life atmosphere with fantasy adaptation, thick tapered ink silhouettes, broad clean painted color masses, warm handmade illustration, restrained textures. Reference images are visual references only: image 1 actual daytime lodge-yard gameplay and HUD composition, image 2 the EXACT spellbook identity: deep purple leather cover, chunky brass corner guards/clasps, lavender parchment with crescent/star and botanical violet ink, short dripping purple candle on bronze holder, purple feather pen; image 3 approved navy/gold crescent-rune UI language, image 4 approved cream-heading resource cards. Preserve identity. Dim the recognizable DAYTIME snowy lavender lodge yard behind the foreground UI, with the game's HUD at edges. No modern technology, photorealism, cooking/firepit, invented lore, watermark, extra text or fake writing. Korean typography must be legible and spelled verbatim, cream on navy and dark violet on parchment. Large clear "???" unknown entries with empty dark item silhouettes. This is a concept mockup, not production assets.
Scene 02B direction B "달 룬 UI": a highly legible NAVY PANEL, not a large physical open book. Same content as direction A but an approved gold-bordered midnight navy interface with cream Korean text and simple crescent/rune corner ornaments. Window bounds about x260..1660 y160..820; title top "마법책" with a SMALL icon of reference-2 book and candle at UPPER LEFT ONLY. Subtitle "낮 · 시간 멈춤". Close X upper right. Symmetrical column divider: left is recipes, right ingredients and result. THREE colored tabs top left: selected green "물약 1 / 4", copper "장비 1 / 5", purple "마법 1 / 4". Left content exactly FOUR 2x2 square gold-outline recipe tiles: one selected healing vial "치유 물약" and THREE unknown silhouettes with large crisp cream "???". Right title "치유 물약", then EXACTLY THREE gold-bordered circular ingredient slots: first a tied bundle green herb leaves with badge "×2" and caption "약초", other TWO empty gold-outlined circles. Below preview one portrait healing potion card with cream header "치유 물약" and red vial, faint violet magic glow. Below one rectangular navy button with gold border "제작". Large clean negative space, no overornament. Outside and directly below panel, SIX cream-heading resource hand cards in a level row on a narrow navy crescent-rune tray: "약초" badge "×3"; "정화된 정수" "×1"; "양털" "×4"; "목재" "×2"; "쇠붙이" "×2"; "토끼 가죽" "×1". Respectively tied green herb bundle; a transparent tear-shaped GLASS BEAD containing clear skyblue/silver water (NO bottle, NO cork, NO neck); wool; logs; rusty iron fragments and hinges; rabbit hide. Do not add any other texts. Keep actual dim daytime snowy lodge game background and HUD visible around window edges. 1920x1080 full-screen, warm casual painterly fantasy UI matching approved references.
```

## 03 · 03-discovery-moment-raw.png

출력: `art/ui/spellbook-crafting-concepts-v01/drafts/03-discovery-moment-raw.png`
참고 입력 수: 5

```text
Use-case: ui-mockup. Make a polished hand-painted casual medieval fantasy game concept screen, precisely 1920x1080 landscape 16:9. Medieval daily-life atmosphere with fantasy adaptation, thick tapered ink silhouettes, broad clean painted color masses, warm handmade illustration, restrained textures. Reference images are visual references only: image 1 actual daytime lodge-yard gameplay and HUD composition, image 2 the EXACT spellbook identity: deep purple leather cover, chunky brass corner guards/clasps, lavender parchment with crescent/star and botanical violet ink, short dripping purple candle on bronze holder, purple feather pen; image 3 approved navy/gold crescent-rune UI language, image 4 approved cream-heading resource cards. Preserve identity. Dim the recognizable DAYTIME snowy lavender lodge yard behind the foreground UI, with the game's HUD at edges. No modern technology, photorealism, cooking/firepit, invented lore, watermark, extra text or fake writing. Korean typography must be legible and spelled verbatim, cream on navy and dark violet on parchment. Large clear "???" unknown entries with empty dark item silhouettes. This is a concept mockup, not production assets.
Scene 03: NEW RECIPE DISCOVERY MOMENT, based on direction A physical open book. Image 5 is supporting layout/continuity reference for direction A. Keep the exact large open purple/brass physical book on wooden desk, violet botanical parchment, short purple candle, dim daytime snowy lodge background. Top prominent navy-gold banner exact Korean "새로운 비법을 책에 적었다". Book heading "마법책", small "낮 · 시간 멈춤". Left page top three ribbon tabs: green "물약 1 / 4", copper "장비 1 / 5", selected PURPLE "마법 2 / 4". Left page FOUR 2x2 tiles: upper left known "이끼 붕대" with a mossy wrapping icon; upper right UNKNOWN BEING REVEALED, violet ink visibly blooming outward from "???" to draw a green VINE SNARE icon and the exact readable new name "덩굴 올가미" along its bottom edge, remnants of question marks dissolving within ink at top of this one tile; lower two tiles remain empty silhouettes with clear large "???". Show spreading ink as painterly wet ink, not fire. Right page top caption "재료". EXACTLY THREE ingredient rune circles, first herb bundle badge "×2", second transparent GLASS TEARDROP BEAD containing clear skyblue silver essence badge "×1", third empty. DO NOT use a bottle for essence. All 3 rings glow with lavender magical transmutation currents. A portrait result CARD titled "덩굴 올가미" with illustration of looping thornless green vines floats UP above the right-page large transmutation circle, slight upward arc and little violet motes. No other result. Beneath a round PURPLE WAX SEAL craft button, the Korean word "제작" clearly centered on seal face, irregular wax rim and stamped crescent. Below the book a row of SIX resource cards with readable headings and badges, values shown BEFORE crafting consumes ingredients: "약초" ×3, "정화된 정수" ×1 (glass teardrop bead), "양털" ×4, "목재" ×2, "쇠붙이" ×2, "토끼 가죽" ×1. Broad warm handmade shapes, thick silhouettes, preserve screen layout and readable UI during spectacle. 1920x1080 16:9. No extra texts.
```

## 04 · 04-recipe-reward-raw.png

출력: `art/ui/spellbook-crafting-concepts-v01/drafts/04-recipe-reward-raw.png`
참고 입력 수: 5

```text
Use-case: ui-mockup. Make a polished hand-painted casual medieval fantasy game concept screen, precisely 1920x1080 landscape 16:9. Medieval daily-life atmosphere with fantasy adaptation, thick tapered ink silhouettes, broad clean painted color masses, warm handmade illustration, restrained textures. Reference images are visual references only: image 1 actual daytime lodge-yard gameplay and HUD composition, image 2 the EXACT spellbook identity: deep purple leather cover, chunky brass corner guards/clasps, lavender parchment with crescent/star and botanical violet ink, short dripping purple candle on bronze holder, purple feather pen; image 3 approved navy/gold crescent-rune UI language, image 4 approved cream-heading resource cards. Preserve identity. Dim the recognizable DAYTIME snowy lavender lodge yard behind the foreground UI, with the game's HUD at edges. No modern technology, photorealism, cooking/firepit, invented lore, watermark, extra text or fake writing. Korean typography must be legible and spelled verbatim, cream on navy and dark violet on parchment. Large clear "???" unknown entries with empty dark item silhouettes. This is a concept mockup, not production assets.
Scene 04: RECIPE REWARD from a medieval guest, direction A physical book. Image 5 is supporting continuity/layout reference for A. Same open purple leather/brass spellbook with lavender botanical parchment, short purple candle left, feather pen, front-facing book on wooden desk over dimmed DAYTIME snowy lodge gameplay. Top heading "마법책", subtitle "낮 · 시간 멈춤". Keep readable left-page tabs: green "물약 1 / 4", selected copper "장비 1 / 5", purple "마법 1 / 4". Left page four/five recipe tiles: exactly FIVE tiles arranged on a 3x2 layout, known "누빈 솜옷" with quilted cloth gambeson icon and FOUR unknown "???" silhouettes. Make unknowns clearly visible. Right page title "제작법 획득", still three EMPTY ingredient rune circles and large preview circle, neutral wax craft button "제작", but overlay the reward animation centered over right page: a visibly OLD TORN PARCHMENT SHEET with uneven ripped edge, small quilted gambeson sketch and clean title "누빈 솜옷", hovering at angle then being pulled into book's right-page inner fold by a sweeping ribbon of pale gold and lavender light, near leading corner partially joining page, luminous ink flecks and paper flutter. Make it unambiguously paper sheet, NOT a standard result card. A guest's gloved medieval hand and brown wool sleeve enter from the upper RIGHT outer margin, visibly just having released this torn recipe page; do not cover tabs or text. Caption in a small navy-gold banner "찢어진 책장을 책에 끼워 넣었다". No invented guest name. At bottom six resource cards "약초" ×3, "정화된 정수" ×1 (transparent tear-shaped glass bead with blue water, NO cork or bottle), "양털" ×4, "목재" ×2, "쇠붙이" ×2, "토끼 가죽" ×1. Warm handmade medieval fantasy with sparse sparkles and bold silhouettes, layout and book identity same as A. 1920x1080 16:9. No other texts.
```

## 02a_final · 02a-window-diorama-corrected.png

출력: `art/ui/spellbook-crafting-concepts-v01/drafts/02a-window-diorama-corrected.png`
참고 입력 수: 1

```text
Edit image 1, the direction A spellbook crafting screen, only with these corrections. Preserve exact book, game background, layout, all six resources and their quantities, four recipe tiles, three ingredient slots, and all Korean lettering. (1) On the SECOND resource card at bottom, headed "정화된 정수", replace the corked flask illustration with a large transparent teardrop-shaped GLASS BEAD enclosing clean skyblue and silver luminous WATER DROP. Pointed top and rounded bottom, completely sealed bead, no neck, no rim, no cork, no stopper, no pedestal. Keep original card frame and ×1 badge. (2) Change the purple "제작" button on the lower right page to an unmistakable rounded irregular PURPLE WAX SEAL STAMP: soft circular wax puddle perimeter, embossed crescent around clearly readable "제작". Keep it in same button footprint, no layout shift. (3) Ensure exact title "마법책" and tabs "물약 1 / 4", "장비 1 / 5", "마법 1 / 4", dark violet hand-ink on parchment, cream on ribbons. Main selected recipe and output are "치유 물약". Unknown tiles must be three "???" empty silhouettes. Preserve handmade casual medieval fantasy style and all other objects. Final landscape 16:9 1920x1080.
```

## 02b_final · 02b-window-ui-frame-corrected.png

출력: `art/ui/spellbook-crafting-concepts-v01/drafts/02b-window-ui-frame-corrected.png`
참고 입력 수: 1

```text
Edit image 1 only: the navy/gold moon-rune crafting UI mockup. Preserve the exact panel, information layout, all recipe tiles, resource cards, texts, icons, all quantities, and the small spellbook icon. Make the DAYTIME gameplay lodge background visible behind the modal substantially darker using a translucent midnight-violet modal scrim, about 50 percent dimming, including HUD outside the modal, so panel is dominant. Keep daytime snow and roof readable, do not turn the game into night, do not alter the contents/brightness of the modal, book icon or lower card tray. Exact Korean title "마법책", subtitle "낮 · 시간 멈춤", tabs "물약 1 / 4", "장비 1 / 5", "마법 1 / 4", selected "치유 물약", button "제작", large three "???" labels. Keep first ingredient "약초" ×2, two empty ingredient slots, six card quantities ×3 ×1 ×4 ×2 ×2 ×1. Second resource remains transparent pointed teardrop GLASS BEAD with clear blue/silver water, no bottle or cork. Same casual hand-painted medieval fantasy, same full 16:9 1920x1080 composition. Nothing else changes.
```

## 03_final · 03-discovery-moment-corrected.png

출력: `art/ui/spellbook-crafting-concepts-v01/drafts/03-discovery-moment-corrected.png`
참고 입력 수: 2

```text
Edit image 1, the recipe DISCOVERY scene. Image 2 is supporting reference for the corrected essence glass bead and WAX SEAL from direction A. Keep image 1 unchanged except these details: (1) On bottom SECOND resource card "정화된 정수" replace the corked flask with the clear skyblue/silver sealed GLASS TEARDROP BEAD from image 2, no neck or cork, preserve card frame and ×1 badge. The ingredient slot above already has a good teardrop, preserve that and ×1. (2) Replace the purple oblong "제작" button with the round irregular-purple-WAX-SEAL STAMP from image 2, embossed crescent and clean readable "제작". Same position below floating card. (3) On the upper-right recipe tile of LEFT page, show a couple crisp "???" remnants in the wet blooming violet ink ABOVE the emerging vine icon, so it is unmistakably the instant the unknown tile changes into a known one; keep readable "덩굴 올가미" below. Preserve two other unknown tiles "???", known "이끼 붕대", EXACT tabs 물약 1 / 4, 장비 1 / 5, 마법 2 / 4, six quantities ×3 ×1 ×4 ×2 ×2 ×1. Prominent banner exact "새로운 비법을 책에 적었다". Keep exact purple leather/brass/lavender botanical book, candle and hand-painted medieval fantasy style, discovery glow, ALL other layout. Final 16:9 landscape 1920x1080.
```

## 04_final · 04-recipe-reward-corrected.png

출력: `art/ui/spellbook-crafting-concepts-v01/drafts/04-recipe-reward-corrected.png`
참고 입력 수: 2

```text
Edit image 1, the torn RECIPE PAGE REWARD scene. Image 2 supports corrected essence and WAX SEAL appearance. Preserve exact layout, all text, the five left recipe tiles (known "누빈 솜옷" and FOUR unknown "???"), the empty three ingredient circles, guest's gloved medieval hand at upper right and large torn paper flying in light. Change ONLY: (1) Bottom second resource card "정화된 정수" artwork becomes the SEALED transparent tear-shaped GLASS BEAD containing skyblue/silver pure water from image 2. No neck, no cork, no flask. Preserve ×1 badge and card frame. (2) Purple "제작" button becomes same irregular round PURPLE WAX SEAL from image 2, crescent embossed around clear "제작"; fit within old button position and do not touch bottom caption. (3) Make the torn paper's lower-left leading CORNER visibly curl toward and merge with the book page near INNER FOLD, with fine golden/lavender particles showing absorption into the book. Preserve readable title "누빈 솜옷" and gambeson sketch on the torn paper, make it remain obviously worn parchment, never a card. Do not cover the five recipe tiles or bottom caption "찢어진 책장을 책에 끼워 넣었다". Exact header "마법책", right title "제작법 획득", tabs 물약 1 / 4, 장비 1 / 5, 마법 1 / 4. Preserve all six resource values ×3 ×1 ×4 ×2 ×2 ×1. No additional text or objects. Keep deep purple/brass book, lavender botanical parchment, purple candle, snowy daytime gameplay dimmed behind UI, bold warm hand-painted casual medieval fantasy. Full landscape 16:9 1920x1080.
```

## 선택 원본과 후처리

| 최종 PNG | 사용 원본 |
| --- | --- |
| 01-entry-book-states.png | drafts/01-entry-book-states-raw.png |
| 02a-window-diorama.png | drafts/02a-window-diorama-corrected.png |
| 02b-window-ui-frame.png | drafts/02b-window-ui-frame-corrected.png |
| 03-discovery-moment.png | drafts/03-discovery-moment-corrected.png |
| 04-recipe-reward.png | drafts/04-recipe-reward-corrected.png |

선택 원본 1672×941을 자르지 않고 1920×1080 PNG로 bicubic 정규화했다. 장면의 추가 수작업 페인팅은 하지 않았다. 원화의 한글은 최종본을 직접 확인해 읽을 수 있는 상태로 유지했다. 비교 시트 2560×1480은 위쪽 5장 축소본과 아래 A/B 확대본으로 조립했고, Noto Sans KR 복사본으로 제목·주석을 조판했다. 원본 폰트와 게임 파일은 수정하지 않았다.

후처리 재현 자료: [finish-delivery.ps1](../../../art/ui/spellbook-crafting-concepts-v01/drafts/finish-delivery.ps1), [final-manifest.json](../../../art/ui/spellbook-crafting-concepts-v01/drafts/final-manifest.json). 최종 5장·비교 시트를 모두 직접 열어 확인했다. 원본 9장은 제작 이력으로 보존하며 최종 선택본과 구분한다.
