# 니벨라 보스 체력 UI 생성 프롬프트

도구: 내장 image_gen. transparent_background=false.

## 1. 기본 전투 합성

입력: 00-boss-fight-capture.png

```text
Use case: ui-mockup / compositing.
Asset type: finished boss-health HUD concept painted directly over a fresh actual Witch's Lodge boss battle screenshot.
Input image 1 is the SCREENSHOT EDIT TARGET. Keep the original 16:9 screenshot, camera, all arena objects, boss model and pose, player, combat telegraph, atmosphere and EVERY existing unrelated HUD element in exactly the same positions. ONLY replace the temporary BOSS HEALTH UI at upper center. Do not repaint the game scene or restyle the entire game. Retouch only enough background to erase the old thin boss bar, old boss labels, three old diamonds, and old bar-specific damage text.
Primary task: a polished chunky medieval-fantasy boss health UI that visually belongs beside the screenshot's existing ivory-gold outlined dark-plum moon HUD. Distinct frost-spider identity, no sci-fi. Make the HEALTH FILL ITSELF much thicker, approximately 40px tall at 1600x900, compared with old ~17px; this is a wide stout highly readable gauge, not a thin line hidden inside thick decoration.
Layout at 1600x900: centered below the existing moon/day clock, boss HUD approx x=390..1210 and y=111..203, preserving a gap from clock and other top panels. Nameplate text row above gauge around y=122..144. Actual gauge fill around y=151..191, 40px tall. Total frame 52px tall. Gauge width about 735px plus compact end ornaments. Do not make a large opaque rectangle panel over the boss abdomen, keep the area beneath y=205 clear.
Style: bold confident tapered black-purple ink contours, deep plum-black recessed track with a subtle shadow/backplate for contrast against bright ice, carved warm ivory/champagne-gold frame with restrained cold silver edge and small cyan frost accents. Two gracefully curved spider-leg-shaped end caps, tiny frozen web filigree only in end corners, a small four-cyan-eyed spider sigil medallion at the left. Match the existing HUD's hand-painted broad color shapes and warm pale-gold outlines, no generic flat rounded progress bar, no maximal tiny ornament, no oversized face portrait. Frame ornament stays OUTSIDE the fill so its entire thick silhouette is readable.
Health fill: luminous saturated violet/amethyst for the first of three health stocks, bright lilac upper bevel, deep purple lower shade, subtle large icy facets, highly readable smooth broad uninterrupted horizontal band. Fill approximately 84% of the track (current overall health 852/900, current stock 252/300). After its endpoint show a SHORT pale ivory trailing-damage segment to about 90%, then clearly empty dark-plum track to 100%. Strong bright cyan/lilac cutoff highlight, no busy vertical barcode patterns. Small icy fragments only at the cutoff edge. Do not divide the main fill into three disconnected bars.
Boss name text exactly “니벨라” prominently in warm ivory at upper left next to the medallion, “서리 둥지의 여왕” as a clearly legible smaller subtitle to the right. No giant centered introduction banner.
Three health-stock indicators at upper right of the same HUD: THREE substantial framed diamond gemstones, violet, amber-orange, crimson-red, all intact in this first-stage screenshot. Give each a pale outline and dark backing; integrated into frame, not floating default primitive diamonds. Tiny clear text “3단계” near them to communicate count.
Small centered numeric health text inside the thick fill “852 / 900”, warm white with deep ink shadow, not crowded against edges. A small pale-ivory recent-damage number “-48” below the cutoff area of the bar; keep it within the boss HUD footprint. This HUD must look like one coherent final art direction including frame/nameplate/stocks/numbers/hit trace.
Constraints: preserve the unrelated top-left player health and house bars, time panel, currency, task panel, bottom controls, all original UI labels outside boss health. Existing player debug HP values belong to capture and must remain. No English captions, no explanatory arrows, no comparison layout, no artboard border, no added buttons or mechanics, no full-screen frost overlay. Single screenshot composite, not isolated asset sheet. Crisp game-scale readability.
```

## 2. 실드 상태 합성

입력: 00-shield-capture.png, 기본 전투 합성 원화.

```text
Use case: ui-mockup / compositing.
Asset type: actual boss battle screenshot paintover, SHIELDED FINAL STOCK state of the same boss-health HUD.
Input image 1 is the screenshot EDIT TARGET: preserve the actual game scene, boss pose, camera and unrelated top-left health UI, clock, currencies, quest panel and bottom controls exactly. Replace ONLY the temporary boss-health bar in the top center.
Input image 2 is the BOSS HUD DESIGN IDENTITY reference: reproduce its exact large four-blue-eyed spider medallion, dark-plum track, thick luminous faceted fill, ivory/champagne-gold outlined spider-leg frame, web details, generous thickness and same screen placement/scale. Do not use image 2's game background, use image 1's background.
This is the SAME interface, after two stocks have broken and the ice-armor shield has appeared. Main health fill remains a thick 40px band at source 1600x900, approx 84% full, now saturated CRIMSON RED with bright coral upper bevel because it is the final stock. Keep the unfilled right area dark. Numeric health centered inside gauge exactly “252 / 900”. Existing source mechanics are 3 health stocks: violet first, amber second, red last. Above right, retain three diamond sockets in same placement: violet and amber stones spent (dark cracked empty sockets), ONLY the crimson stone illuminated. Label exactly “1단계”.
Above left, name “니벨라” large ivory and subtitle “서리 둥지의 여왕”, same typesetting as reference HUD. Add a separate ice-armor sub-gauge BELOW the main gauge, within a compact additional 25px band. This is a visibly SEPARATE slender silver-cyan shield bar, not a white layer covering the red health fill. Small frost-shield icon at left; clear pale silver text “얼음 갑옷 120 / 120” centered, thin bright icy rim and three sparse faceted ice plates linking to the existing frame. Keep both red HEALTH and cyan SHIELD readable simultaneously. Subtle cold frost on end ornaments, NO full-screen frost effects, no enclosing glass bubble around the whole interface. Maintain clear gap below existing time panel and avoid boss face; entire HUD stays near upper center and above source y=235. Remove the old name label, old thin bar and old diamond symbols from screenshot before composing.
Style: same hand-painted stylized medieval fantasy HUD as reference, deep confident ink outlines, simple broad gold-ivory bevels, small cyan frozen-web corners, modest restrained glow, crisp legible Korean UI. No explanatory captions or arrows. Single finished screenshot, not multiple views, no artboard border, no new gameplay mechanics, no new buttons, no sci-fi.
```

## 3. 상태·부품 시트

입력: 기본 전투 합성, 실드 상태 합성.

```text
Use case: ui-mockup.
Asset type: boss-health UI art direction and state sheet, cohesive production concept reference for Witch's Lodge.
Input image 1 and image 2 are DESIGN REFERENCES ONLY. Reproduce the EXACT boss HUD shape from them: four-cyan-eyed spider medallion left, warm ivory/champagne-gold thin beveled outline, curved spider-leg end ornaments, dark plum track, subtle web corners, large stout faceted 40px-style fill, name/subtitle above and three gemstone sockets at upper right. Image 1 is basic violet+damage-trail state, image 2 shows separate silver-cyan shield sub-bar. Do NOT copy the gameplay background or unrelated HUD.
Create ONE high-resolution PORTRAIT 2:3 clean concept sheet. Solid deep desaturated indigo background, no parchment, no texture noise. Six large horizontal full-width boss HUD examples STACKED in six tidy rows, all at IDENTICAL size, geometry, placement relative to row and shared fill thickness; generous row spacing and outside margins. Small warm ivory row labels in Korean at left ABOVE each row, not large essays. At bottom a compact seventh strip of isolated UI COMPONENTS. Nothing clipped, no overlap, no arrows. This is a set of states of ONE design, not six redesigns.
Top title exactly “니벨라 · 보스 체력 UI”. Each full row has exact name “니벨라”, subtitle “서리 둥지의 여왕”, and same medallion/frame architecture. Three sockets ordered LEFT violet, MIDDLE amber, RIGHT red. Filled sockets mean remaining stocks; spent sockets dark and cracked.
ROW 1 label “등장”: violet full gauge at 100%, all three stones intact, small white-cyan highlight at the far right, number “900 / 900”, no damage ghost, “3단계”.
ROW 2 label “피격”: violet gauge at exactly 84% of track width, short pale ivory delayed-damage trace from 84% to 90%, last 10% dark empty. Highlight and tiny ice fragments at 84% cutoff, below it damage “-48”, number “852 / 900”, all three stones, “3단계”.
ROW 3 label “격노”: amber-orange gauge 60% full and 40% empty, first violet socket empty with a few shards falling near it, amber and red sockets lit, “2단계”, number “480 / 900”. Mild amber frame accent, do not draw fire.
ROW 4 label “실드”: RED health gauge at EXACTLY 84% track width and remaining 16% empty, “252 / 900”, “1단계”, violet and amber sockets empty, red lit. A SEPARATE slim cyan-white ice armor sub-bar below the red bar, full length, small shield icon and exact text “얼음 갑옷 120 / 120”. Red fill MUST NOT be masked by shield.
ROW 5 label “빈사”: red/crimson gauge at 30% full and 70% empty, “90 / 900”, “1단계”, only red socket lit. Restricted faint crimson outer rim pulse near bar; no huge red haze. Same stout frame geometry.
ROW 6 label “처치”: empty plum track, “0 / 900”, three empty cracked sockets, left spider medallion darkened, a FEW gold-ivory frame and ice fragments drifting downward to imply dissolve, do not destroy the entire sheet layout.
SEVENTH bottom strip label “프레임 · 문장 · 단계석 · 실드”: show four small separated component groups, NO duplicate full HUD: (1) a short EMPTY frame/track segment showing cross section style with the same generous thickness, (2) the spider-medallion emblem, (3) the three gemstone colors beside one spent socket, (4) shield emblem plus short cyan shield-gauge segment.
Rendering: polished stylized medieval fantasy game UI, confident tapered ink contours, broad painted facets, restrained small cyan frost accents, high readability at game resolution, warm pale outlines against dark blue. Fill thickness is a dominant shape, not a thin line. No extra gameplay stats, abilities, skill icons, meters, screenshots, character art, giant boss illustration, English typography or watermark. No programming notes or implementation descriptions.
```

## 4. 현재 단 기준 게이지 길이 보정

입력: 최초 상태·부품 시트.

```text
Edit this exact boss UI state sheet. Keep all six rows, all typography, all medallions, gold frames, colors, spacing, component strip, shield bar and background UNCHANGED except the three specific main-health fill endpoints described below and the defeated stage label.
IMPORTANT MECHANIC: each main health gauge is a CURRENT STOCK gauge of 300 points, while printed numeric text is TOTAL health out of 900. Do NOT compute fill as text divided by 900. The stock gauge resets between stages.
Only change:
1. Row labelled “격노”, with text “480 / 900”: current-stock health is 180/300. Extend orange fill to exactly 60% of its track length, leaving 40% empty.
2. Row labelled “실드”, with text “252 / 900”: current-stock health is 252/300. Extend the RED MAIN HEALTH FILL to 84% OF TRACK LENGTH, leaving only the rightmost 16% dark. This red fill must reach almost as far right as the purple fill endpoint in row “피격”. Bright red uniform faceted fill across all this 84%, not a tiny bright segment followed by dim red near-black. Keep the separate full cyan shield gauge and “얼음 갑옷 120 / 120” exactly unchanged.
3. Row labelled “빈사”, text “90 / 900”: fill is 90/300, so extend red fill to 30% track length, leaving 70% dark.
4. Row labelled “처치”: remove only the small “1단계” text near the empty three sockets; the empty track stays zero, text “0 / 900” remains.
All other pixels/design/layout remain as before. Preserve all Korean labels and all existing numbers exactly. This is a targeted fill-length correction, not a redesign.
```

