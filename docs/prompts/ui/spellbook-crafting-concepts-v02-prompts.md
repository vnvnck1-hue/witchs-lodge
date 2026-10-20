# 마법책 제작 화면 컨셉 v02 — 실제 프롬프트 기록

작성일: 2026-10-20 · 도구: 내장 `image_gen` · 사용 스킬: `imagegen`

요청서: [책자 방향·러프하게 힘 빼기](../../handoff/codex-spellbook-crafting-concepts-v02.md)

## 생성·저장 조건

- 내장 이미지 생성만 사용했다. CLI/API 대체 생성은 하지 않았다.
- 시안 3종을 개별 호출하고, 기본 창 1회·획득 장면 2회 추가 보정했다. 총 6회, 호출당 실제 참고 이미지 1~5장.
- 아래 입력 순서는 `referenced_image_paths` 순서와 같으며, 각 이미지는 먼저 직접 열어 확인했다. `transparent_background=false`.
- 최종 선택 원본 3장은 1672×941 PNG로 반환됐다(04 첫 초안만 1672×940, 그 외 원본도 1672×941). 최종 선택본을 비율 유지 확대 후 수직 합계 약 0.57px를 중앙 크롭해 1920×1080으로 납품했다. 이미지를 늘여 비율을 바꾸지 않았다.
- 원본·불합격본을 모두 [drafts/](../../../art/ui/spellbook-crafting-concepts-v02/drafts/)에 보존했다. 생성 경로·해시는 같은 폴더의 manifest.json 참조.
- 최종 제목·HUD 날짜·발견 전 표시는 읽기 전용 게임 글꼴 Noto Sans KR을 PrivateFontCollection으로 로드해 후처리했다. 다른 생성 한글은 직접 검수해 유지했다.
- 05는 배너와 단순화는 반영했지만 재료 슬롯을 삭제하여 불합격 처리했다. 06으로 3슬롯/결과/도장 순서를 복원했다.

## 01 · 기본 제작 창 첫 생성

생성 원본: [02-window-first.png](../../../art/ui/spellbook-crafting-concepts-v02/drafts/02-window-first.png)

실제 참고 입력(순서):

1. `art/ui/spellbook-crafting-concepts-v01/02a-window-diorama.png`
2. `godot/assets/ui/hand_workbench/props-v05/SpellbookAndCandle.png`
3. `godot/screenshots/party-frames/medallion-right.png`
4. `art/ui/job-pictograms-v02/warrior.png`
5. `art/concepts/cards/roles-individual-v02/03-resource-timber.png`

실제 전달 프롬프트:

```text
Use case: ui-mockup / style-transfer. Generate ONE full-screen 1920x1080 landscape PNG concept image for the Korean medieval fantasy game Witch's Lodge. This is a deliberately ROUGH, relaxed, low-detail painted sketch, NOT polished concept illustration.
INPUTS IN ORDER: (1) v01 02a is the exact COMPOSITION / UI LAYOUT reference; preserve book size, locations and information hierarchy, but remove over 60% of its drawing marks and decorations. (2) SpellbookAndCandle is BOOK IDENTITY only, do not copy its dense patterns. (3) actual game screenshot is background / HUD context only. (4) warrior pictogram is the SIMPLICITY benchmark: bold uneven hand-drawn contour, flat large color masses. (5) approved resource card is card silhouette/color grammar only, vastly simplify its illustration and omit description in these small UI previews.
COMPOSITION at 1920x1080: muted dark purple snowy lodge game background with a restrained existing HUD across the top. Huge open physical purple leather book fills x280..1660 y170..825. Cream parchment facing pages, broad plain bronze corners, purple ribbon hanging at right. Pages are largely plain solid cream, NO all-over texture. Simple title plaque centered at x960 y170 reads "마법책", small subtitle "낮 · 시간 멈춤"; close X upper right. LEFT PAGE x390..950: top three tabs "물약 1 / 4" selected green, "장비 1 / 5" brown, "마법 1 / 4" purple. Below exactly 2x2 recipe tiles in the same geometry as reference: known "치유 물약" upper left with one chunky red potion silhouette; other THREE tiles are muted simple silhouettes, each with a big dark "???". RIGHT PAGE x1000..1550: heading "치유 물약"; horizontal row of exactly THREE ingredient circles, each ONE heavy purple outline; first has a single simple leaf clump, round quantity badge "×2", label "약초"; other two empty except one tiny simple center tick. Short simple connector arrow beneath. Centered below slots a small result card showing the same red potion, label "치유 물약", on just TWO plain purple rings and very restrained lavender glow. NO runes or star shapes. At bottom right page the familiar broad purple wax seal button clearly reads "제작".
BOTTOM RESOURCE ROW stays in same positions as v01 x420..1510 y835..1020: exactly six purple rectangular cards with cream name strips and quantity badges, each icon ONE simple large mass: "약초" ×3 (green leaves), "정화된 정수" ×1 (blue droplet), "양털" ×4 (cream fleece blob), "목재" ×2 (one chunky log), "쇠붙이" ×2 (one iron lump), "토끼 가죽" ×1 (one hide silhouette). Keep all six fully in frame.
SIMPLIFY VERY AGGRESSIVELY: uneven thick outer contour, no more than 2–3 flat value planes per object; a few loose confident brush strokes only. Leather has NO grain, stitch, scratches, engraved lines; parchment has NO stains, folds, tears, flecks; metal has NO rivets or engraving. NO border vines, NO leaves or flowers around book, NO scattered stars/dots, NO quill, NO inkpot, NO piles of books. Desk is broad quiet brown planes, NO woodgrain. Only ONE chunky purple candle on the LEFT and ONE simple material pouch on RIGHT. Empty page margins remain empty. This MUST look at least half as busy as image 1, more like a clean colored thumbnail sketch with readable UI than a finished painting.
Medieval-based fantasy world; allow familiar fantasy adaptations while retaining medieval daily-life atmosphere. No modern objects. Korean text exact and sharply legible; all information must be more obvious than the reference. Do not add commentary labels, sample captions, watermarks, extra props, or decorative framing. Preserve same physical book identity and layout.
```

## 02 · 기본 창 원형 장식·배경 보정

생성 원본: [02-window-generated.png](../../../art/ui/spellbook-crafting-concepts-v02/drafts/02-window-generated.png)

실제 참고 입력(순서):

1. `art/ui/spellbook-crafting-concepts-v02/drafts/02-window-first.png`

실제 전달 프롬프트:

```text
Use case: ui-mockup / precise-object-edit. Refine ONLY the following details of this supplied simplified spellbook UI mockup, preserving ALL current layout coordinates, book shape, color-block sketch style, recipe cards and their text, candle and pouch, resource cards, background composition. Keep the low detail density. Output one 1920x1080 landscape image.
1. Restore the missing SMALL plain purple title plaque centered across the top book spine, at roughly x960 y172 in final 1920x1080 coordinates, reading exactly "마법책" with small "낮 · 시간 멈춤" below. Must not cover tabs.
2. Each of the THREE ingredient slots should have exactly ONE thick hand-drawn circle outline, not double parallel outlines. Preserve the herb icon and ×2 quantity and two empty slots with tiny center marks.
3. The result under the red potion card should have exactly TWO simple concentric elliptical lines with very subtle soft lavender light. Remove the additional segmented arcs / multiple band rings. No runes, no stars.
4. Dim ONLY the snowy game-world background visible behind the book, by about 30%; keep top HUD legible and preserve brightness of book, resource cards and the two foreground props.
5. Broad flat parchment color, remove remaining corner stains/abrasions and excess tiny surface marks. Keep lively slightly uneven contour, rough simplified paint, 2–3 tone planes, not photorealism. Add no new decoration or props.
Exact texts and resource quantities must stay unchanged and readable. Medieval-based fantasy world, familiar fantasy adaptations allowed, keeping medieval life and atmosphere.
```

## 03 · 새 비법 발견

생성 원본: [03-discovery-generated.png](../../../art/ui/spellbook-crafting-concepts-v02/drafts/03-discovery-generated.png)

실제 참고 입력(순서):

1. `art/ui/spellbook-crafting-concepts-v02/drafts/02-window-generated.png`
2. `art/ui/spellbook-crafting-concepts-v01/03-discovery-moment.png`
3. `godot/assets/ui/hand_workbench/props-v05/SpellbookAndCandle.png`
4. `art/ui/job-pictograms-v02/warrior.png`

실제 전달 프롬프트:

```text
Use case: ui-mockup / precise-object-edit. Create ONE 1920x1080 landscape PNG, scene 03 NEW RECIPE DISCOVERY in the same deliberately relaxed rough low-detail colored sketch series as input 1.
REFERENCES: image 1 is the SIMPLIFIED v02 base, preserve its exact book geometry, page layout, palette, broad flat shapes, minimal props, lower six resource cards and their quantities. Image 2 is v01 discovery for CONTENT STATE ONLY, do NOT reintroduce its dense decoration or textures. Image 3 is book identity. Image 4 is coarse bold pictogram simplicity.
KEEP: plain purple leather, broad plain metal corners, cream pages, purple bookmark, ONE purple candle left, ONE pouch right, same dark snowy game-world background/HUD, same 2x2 recipe grid on left and three ingredient circles/result/wax "제작" seal on right; all six resources fully visible at bottom unchanged. Thick lightly uneven hand contours, 2–3 flat values, NO grain, stitching, rivets, engraving, ornamental borders, scattered points/stars, quill, flowers or books.
STATE CHANGES:
Tabs now "물약 1 / 4", "장비 1 / 5", selected PURPLE "마법 2 / 4".
Left grid: top-left known "이끼 붕대", drawn as ONE simple cream bandage roll and a small green mass. Top-right is the newly discovered recipe: a large "???" still visible at top fading into ONE broad dark-purple ink bloom behind a simple green vine-loop icon. Cream name strip clearly shows NEW NAME "덩굴 올가미". The change from unknown to known must read immediately. Bottom two tiles remain muted silhouettes with big "???".
Right page heading "재료". Exactly THREE slots with single thick circle outlines: first leaf clump, badge "×2", label "약초"; second blue drop, badge "×1", label "정수"; third empty with one small center mark. One connector arrow. Below, result card "덩굴 올가미" with a simple single green vine loop, exactly TWO unadorned purple ellipses behind it, subtle lavender light only. Seal reads "제작".
One PLAIN dark purple banner above the book says exactly "새로운 비법을 책에 적었다". No ornate border, NO stars, NO sparkles, NO flying leaves or vine tendrils. Keep ink effect as ONE connected broad brush bloom, no scatter. Place title "마법책" in a SMALL plain plaque over the book's top central spine with subtitle "낮 · 시간 멈춤", separate from world HUD if space permits.
Medieval-based fantasy world, familiar fantasy adaptations allowed, retaining medieval daily-life atmosphere. All Korean exact and readable. Same modest density as simplified image 1; no added props. Do not change style to fine detailed polished fantasy illustration.
```

## 04 · 제작법 획득 첫 생성

생성 원본: [04-recipe-reward-first.png](../../../art/ui/spellbook-crafting-concepts-v02/drafts/04-recipe-reward-first.png)

실제 참고 입력(순서):

1. `art/ui/spellbook-crafting-concepts-v02/drafts/02-window-generated.png`
2. `art/ui/spellbook-crafting-concepts-v01/04-recipe-reward.png`
3. `godot/assets/ui/hand_workbench/props-v05/SpellbookAndCandle.png`
4. `art/ui/job-pictograms-v02/warrior.png`

실제 전달 프롬프트:

```text
Use case: ui-mockup / precise-object-edit. Create ONE 1920x1080 landscape PNG, scene 04 RECIPE PAGE REWARD, in exactly the relaxed low-detail flat painted sketch series of image 1.
INPUT ROLES: image 1 simplified v02 book base is the exact layout/style/color/geometry reference. Image 2 v01 reward is composition for visitor hand/page interaction only; DO NOT repeat its known-recipe reward mistake, intricate textures, or bright particle effects. Image 3 same book identity. Image 4 coarse bold pictogram simplicity.
Preserve purple leather open physical book, cream pages with completely empty margins, broad plain bronze corners, ribbon at right, ONE chunky purple candle at left, ONE material pouch right; six simple resource cards remain fully visible at bottom in the same positions with labels and quantities "약초" ×3, "정화된 정수" ×1, "양털" ×4, "목재" ×2, "쇠붙이" ×2, "토끼 가죽" ×1. Same dark purple snowy lodge backdrop and upper HUD. Strong uneven simple contours, no more than 2–3 value planes, rough relaxed thumbnail paint; NO microtexture, grain, stitches, rivets, engraving, border vines, stars or speckling, no extra table props.
REWARD STATE:
Left tabs: "물약 1 / 4", SELECTED warm brown "장비 2 / 5", "마법 1 / 4". Include clearly legible small counter transition "1 / 5 → 2 / 5" directly below selected tab, with enough blank room.
Equipment grid contains FIVE entries, as v01 equipment layout: TWO upper entries and THREE lower entries. Top-left EXISTING known recipe "누빈 솜옷" remains quiet, unhighlighted, a SIMPLE cream padded coat with just two broad quilting lines, no tiny fabric detail. Top-right is a formerly UNKNOWN "???" entry changing into "나그네 장화". It shows ONE simple chunky brown BOOT PAIR, a cream label "나그네 장화", and a clearly visible fading old "???" above that picture; one modest warm highlight band indicates THIS is the newly unlocked tile. The THREE lower entries remain muted simple silhouettes each with big readable "???".
Right page retains exactly THREE empty single-outline ingredient circles and small center marks at top; heading "제작법 획득". Connector and result position remain underneath, TWO plain result circles, purple wax seal "제작" at bottom.
From upper right enters ONE simplified visitor hand with a plain brown medieval sleeve; no stitch/hair detail, only a few broad shading planes. Hand releases ONE small torn cream recipe page over the right page, traveling toward the newly revealed boot tile in the book. The flying page MUST show a clear simple BROWN BOOT PAIR, and exact name "나그네 장화". It DOES NOT show a padded coat. A SINGLE subdued broad curved violet light stroke from hand/page toward book communicates suction; NO shower of sparkles, NO detached scraps, no explosion. Keep all three ingredient slot outlines readable, do not cover the seal or grid.
A plain dark-purple banner, placed near bottom of book above resource row, reads exactly "찢어진 책장을 책에 끼워 넣었다". No ornaments on the banner. Book title "마법책" stays legible. Korean exact. Middle-age-based fantasy, allow familiar fantasy adaptation while retaining medieval daily-life mood. Preserve simple empty page margins, limited density and casual rough confidence. No editorial labels or watermarks.
```

## 05 · 획득 배너·결과 원형·의복 묘사 보정 (배치 불합격본)

생성 원본: [04-recipe-reward-layout-rejected.png](../../../art/ui/spellbook-crafting-concepts-v02/drafts/04-recipe-reward-layout-rejected.png)

실제 참고 입력(순서):

1. `art/ui/spellbook-crafting-concepts-v02/drafts/04-recipe-reward-first.png`

실제 전달 프롬프트:

```text
Use case: ui-mockup / precise-object-edit. Make these targeted corrections ONLY to the supplied simple rough spellbook reward mockup; preserve composition, book, tabs, all recipe tile identities and quantities, background, props and resource row. Output ONE 1920x1080 landscape PNG.
1. ADD the missing plain dark-purple banner across the bottom of the book, just above the bottom resource cards, centered roughly x960,y800 in 1920x1080 coordinates. Exact highly legible Korean text: "찢어진 책장을 책에 끼워 넣었다". Banner must not cover the "제작" wax seal or any resource card.
2. The right-page result area currently has TWO SEPARATE SIDE-BY-SIDE EMPTY CIRCLES, which is wrong. Replace those with ONE single centered result position: TWO CONCENTRIC LARGE ELLIPTICAL LINES in muted purple with gentle dim glow, around a small simple book-page silhouette carrying a BOOT icon. Center at same place as potion result from the base book, above the seal. Do not create multiple result positions.
3. Simplify the existing cream coat drawing on upper-left recipe tile: remove dense diamond quilting and stitching; retain only TWO broad diagonal quilt lines and simple coat silhouette, label "누빈 솜옷" unchanged. Simplify boots to broad brown shapes with maximum two simple fastening strokes, no many tiny lace loops.
4. The single torn recipe page with BOOTS and label "나그네 장화" is now floating released just BELOW the visitor fingers, with a small visible gap. One broad subdued curved lavender light stroke shows it being drawn toward the top-right formerly unknown boot tile. No sparkle particles. Preserve the clearly visible "???" at top of newly revealed boot tile and its "나그네 장화" name strip, keep "1 / 5 → 2 / 5" progress unchanged.
Keep 3 ingredient slots in one horizontal row. Maintain empty page margins, relaxed chunky contour, flat 2–3 plane color, no surface microtexture, no new decorative props or ornaments. Medieval-based fantasy, familiar fantasy adaptation allowed, medieval daily-life mood. All Korean exact and readable.
```

## 06 · 획득 장면 재료 슬롯 3칸 복원·결과 위치 보정

생성 원본: [04-recipe-reward-generated.png](../../../art/ui/spellbook-crafting-concepts-v02/drafts/04-recipe-reward-generated.png)

실제 참고 입력(순서):

1. `art/ui/spellbook-crafting-concepts-v02/drafts/04-recipe-reward-layout-rejected.png`
2. `art/ui/spellbook-crafting-concepts-v02/drafts/02-window-generated.png`

실제 전달 프롬프트:

```text
Use case: precise-object-edit / ui-mockup. ONE 1920x1080 landscape output. Input 1 is the current reward image to correct; input 2 is the correct right-page LAYOUT reference from the simplified base. Preserve ALL of input 1 EXCEPT the right-page layout and visitor-page release described here.
CRITICAL: the latest reward image accidentally DELETED ALL THREE INGREDIENT SLOTS. Restore THREE empty SINGLE-outline purple ingredient CIRCLES in a horizontal row on the upper-right page, matching input 2 exactly. At 1920x1080 final, their centers are approximately (1100,370), (1270,370), (1440,370), radius about 70. Each contains a tiny purple center tick. This row must be visible, never deleted or covered.
Move the existing result boot-page icon DOWN to center (1270,600), inside TWO SIMPLE CONCENTRIC ELLIPSES, approximate radius (150,90). Match the result-card position of input 2. Thin restrained purple glow only. Keep the "제작" seal below it at approximately (1270,730). Small simple connector down-arrow between ingredients and result, matching input 2.
Keep right heading "제작법 획득", lower banner "찢어진 책장을 책에 끼워 넣었다", the entire left 5-recipe grid, progress 1 / 5 → 2 / 5, upper-right new boot tile with "???" plus "나그네 장화", existing coat "누빈 솜옷", the other 3 ??? tiles, resource row, props and background unchanged.
Visitor torn page moves farther RIGHT, near right book edge around x1735,y465 in final, so it doesn't obscure ingredient circles. ONE boot-page, exact name "나그네 장화", released below fingers: visibly separated from fingertips by about 20 pixels. Short subdued curved violet stroke draws it toward book. No extra fragments or sparkles.
Do NOT replace the 3 slots with the result. Do NOT place the result in the upper slot row. Keep three distinct horizontal slots ABOVE one result position ABOVE the seal, same as input 2. No changes elsewhere. Broad simple rough shapes, 2–3 flat value planes, medieval-based fantasy retaining medieval daily-life atmosphere.
```

## 생성 뒤 후처리와 비교 시트

[재현 스크립트](../../../art/ui/spellbook-crafting-concepts-v02/drafts/finish-and-sheet.ps1)는 Windows System.Drawing을 사용한다. 생성된 원화 자체를 다른 그림 도구로 재제작하지 않았고, 아래 조판·크기 정리만 수행했다.

1. 생성기가 상단 월드 HUD에 배치한 '마법책'을 '1일차 · 낮'으로 정정하고, '마법책 / 낮 · 시간 멈춤'을 책등 위의 작은 무장식 표찰로 옮겼다. 03은 탭과 겹치지 않게 높이를 줄였다.
2. 03에서 이름이 적히는 칸에 이전 상태 '??? →'를 작은 보라색 표기로 추가했다. 잉크 번짐 한 덩어리와 새 이름은 생성 원화를 유지했다.
3. 3장 모두 비율 유지 확대·중앙 미세 크롭으로 1920×1080, 불투명 PNG 저장.
4. 비교 시트 3200×1730: 위 두 칸에 v01 02a와 v02 02를 같은 1520×855 크기로, 아래 세 칸에 최종 3장을 같은 크기로 배치했다. 비교 제목과 설명은 Noto Sans KR.

재현(프로젝트 루트, Windows PowerShell):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File art/ui/spellbook-crafting-concepts-v02/drafts/finish-and-sheet.ps1
```

본 기록은 실제 제작에 사용한 프롬프트다. 세부 픽셀 위치가 v01과 완전히 같다는 뜻은 아니며, 동일한 책자 화면의 구성과 정보 위계를 유지한 화풍 시안이다.

