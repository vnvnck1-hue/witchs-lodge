# 마법책 제작 화면 v03 — 프롬프트 기록

2026-10-20 · 내장 `image_gen.imagegen` 편집 경로 · **시안 3장·비교 시트 제작 완료**

## 결과와 호출 이력

- 이전 시도: 02 첫 호출이 HTTP 429 `usage_limit_reached`로 실패. 이미지 반환 없음. 오류와 당시 재설정 시각은 아래에 보존한다.
- 이번 재개: 준비한 02·03·04 프롬프트를 그대로 사용해 각각 1회 성공. 04는 넝쿨 밀도와 배너 높이를 정리하는 후속 편집 1회 추가 성공. **이번 호출 총 4회, 반환 이미지 4장.**
- 02·03의 첫 결과와 04의 두 번째 결과를 최종 채택했다. 04 첫 결과도 `drafts/`에 보존했다.
- 실제 출력은 모두 1672×941이었다. 원본을 보존하고 비율 유지 확대·상하 합계 약 0.5 원본 픽셀의 중앙 크롭으로 최종 1920×1080 PNG를 만들었다. 비교 시트는 2400×1120이다.
- API/CLI 전환·Godot 임포트·실행파일 내보내기·커밋은 하지 않았다.

## 입력 역할

1. `art/ui/spellbook-crafting-concepts-v01/02a-window-diorama.png` — 전체의 주 화풍·질감·소품 기준이자 02 편집 대상.
2. `art/ui/spellbook-crafting-concepts-v01/03-discovery-moment.png` — 03 편집 대상과 발견 상태.
3. `art/ui/spellbook-crafting-concepts-v02/04-recipe-reward.png` — 04 구성만 참조.
4. `art/ui/spellbook-crafting-concepts-v02/02-window.png` — 직접 열어 단순화 금지선 확인. 생성 입력에서 제외.
5. `godot/assets/ui/hand_workbench/props-v05/SpellbookAndCandle.png` — 직접 열어 책·촛불 정체성 확인. 생성 입력에서 제외, 읽기 전용.

모든 호출은 `transparent_background=false`. 아래 입력 경로는 프로젝트 루트에 대한 상대 경로이며 실제 호출에는 절대 경로를 전달했다. 도구 저장본은 기본 생성 폴더에서 v03 `drafts/`로 복사했다.

## 01 · 02-window — 준비 프롬프트 그대로 재개, 성공

실제 입력 순서:

1. `art/ui/spellbook-crafting-concepts-v01/02a-window-diorama.png`

보존 원본: `drafts/02-window-generated.png` → 02-window.png

실제 호출 프롬프트 원문:

```text
Use case: precise-object-edit. Asset type: 1920x1080 16:9 Korean medieval fantasy game crafting UI concept, image 02-window.
Input image 1 is the EDIT TARGET and sole visual/style authority: v01 02a-window-diorama. Perform a conservative partial clean-up of this exact image, do not redesign it or restyle it. First impression MUST be "same richly illustrated v01 book, a little less crowded". Keep approximately 75-80% of original ornamental density and almost 100% of its material rendering, painterly hand-inked linework, multi-step shading, shapes, colors, composition and prop count.
Scene: 중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색 허용. Same open purple leather spellbook on wooden desk, lavender forest and warm lodge behind, same HUD. Preserve thick rounded worn leather, visible folds, stitches, brass rivets and highlights, dimensional page edges, warm mottled parchment, woodgrain. Preserve purple candle with brass holder left, quill/ink and stacked book bottom left, purple pouch and ribbon right, marginal flowers and foliage (only thin those obscuring HUD/cards).
Change ONLY decorative noise: interrupt the continuous lavender page-border vines, leaving corners and a few isolated edge sprigs, especially clear vines immediately beside recipe tiles/ingredient circles. Remove about half of tiny scattered stars/dots/sparkles while retaining the meaningful purple magical glow and moon motifs. Reduce count/contrast of tiny stitches/rivets/stains slightly without changing their size or eliminating texture. Remove ONE concentric/rune ring layer behind result card but retain luminous detailed magic circle.
Preserve original complete UI layout and exact information. Top HUD "1일차 · 낮", "낮 · 시간 멈춤", witch health 115/115, lodge 300/300, coins 40, wood 0, wool 0, pause. Book title "마법책", subtitle "낮 · 시간 멈춤", close X upper right. Left tabs "물약 1 / 4", "장비 1 / 5", "마법 1 / 4", potion tab selected. Left 2x2 grid: selected detailed red healing potion "치유 물약"; three distinct unknown potion silhouettes each labeled "???". Right page heading "치유 물약"; three ingredient circle slots, first detailed herb bouquet with small round "×2" badge and "약초", other two empty with small star. Below arrow, detailed red potion result card "치유 물약", glossy dimensional purple wax seal "제작". Bottom six lavishly illustrated resource cards at their original positions, label and badge exactly: "약초" ×3, "정화된 정수" ×1, "양털" ×4, "목재" ×2, "쇠붙이" ×2, "토끼 가죽" ×1. Preserve miniature scenic backgrounds and rich material shading of all six cards, never replace them with flat icons.
Keep title, tabs, unknown labels, badges and seal legible with a little more breathing room. NO flattening, vector look, icon simplification, removal of props, blank parchment, blur, global desaturation, layout shift, new decorative clutter. Output one finished landscape image, not a collage.
```

## 02 · 03-discovery — 준비 프롬프트 그대로 실행, 성공

실제 입력 순서:

1. `art/ui/spellbook-crafting-concepts-v01/03-discovery-moment.png`
2. `art/ui/spellbook-crafting-concepts-v01/02a-window-diorama.png`
3. `art/ui/spellbook-crafting-concepts-v03/drafts/02-window-generated.png`

보존 원본: `drafts/03-discovery-generated.png` → 03-discovery.png

실제 호출 프롬프트 원문:

```text
Use case: precise-object-edit. Asset type: 1920x1080 16:9 Korean medieval fantasy crafting UI, image 03-discovery.
Inputs: image 1 v01/03-discovery-moment.png is the EDIT TARGET for this discovery state and original composition; image 2 v01/02a-window-diorama.png is the primary material/style authority. Image 3 v03/02-window.png, when available, is a supporting consistency reference for the very modest ornamental reduction only. Stay extremely close to v01; do not simplify into flat icons.
Scene: 중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색 허용. Keep original purple dimensional leather book, folds, stitches, brass corners/rivets, warm varied parchment, purple candle, quill, ink, stacked book, pouch, ribbon, woodgrain desk, foliage, lavender forest, warm lodge and complete top HUD. Retain 75-80% of original ornamental density and essentially all rich hand-drawn texture and multi-step material shading. Remove only select vine-border segments immediately crowding tiles and circles; leave corner and isolated marginal sprigs. Halve incidental tiny stars and dots, not meaningful discovery light. Slightly lower number and contrast of stitches/rivets/parchment flecks, without shrinking them or erasing them. Remove just one magic-circle/rune layer behind result. Thin only peripheral foliage that intrudes into HUD/resource cards; keep prop count nearly identical.
Exact UI: top "1일차 · 낮", "낮 · 시간 멈춤", witch 115/115, lodge 300/300, coins 40, wood 0, wool 0, pause. Preserve left quest note "오늘의 할 일", "손님을 맞이하세요". At upper center discovery banner "새로운 비법을 책에 적었다". Book title "마법책", subtitle "낮 · 시간 멈춤" must sit BELOW banner with a clear visible gap of 12-20 pixels at final size; neither touches/overlaps the other or the tabs. Keep book title fully legible; reduce only banner height or shift upward into reserved gap if needed, do not overlap world HUD.
Left tabs "물약 1 / 4", "장비 1 / 5", selected "마법 2 / 4". Left 2x2 grid: existing detailed "이끼 붕대" top left; top right unknown recipe transforming in a coherent purple ink bloom into detailed leafy coiled "덩굴 올가미", with previous-state text "??? →" near its upper edge and new name beneath. Bottom two slots retain distinct unknown non-boot silhouettes and "???". Right heading "재료", exactly three round ingredient slots: detailed herb bouquet ×2, luminous essence droplet ×1, empty star slot; label occupied slots "약초", "정수" if space allows. Purple connecting arrow leads to detailed result card "덩굴 올가미", retained luminous circle and a few meaningful drifting leaves, glossy wax "제작" below. Keep result visible through effects.
Bottom six fully illustrated resource cards, detailed scenic miniature shading at v01 fidelity: "약초" ×3, "정화된 정수" ×1, "양털" ×4, "목재" ×2, "쇠붙이" ×2, "토끼 가죽" ×1.
No blank minimal parchment, no flat vector treatment, no removing desk props, no blurry smoothing, no drastic layout shift. One finished image.
```

## 03 · 04-recipe-reward — 준비 프롬프트 그대로 실행, 성공·초안 보존

실제 입력 순서:

1. `art/ui/spellbook-crafting-concepts-v01/02a-window-diorama.png`
2. `art/ui/spellbook-crafting-concepts-v02/04-recipe-reward.png`
3. `art/ui/spellbook-crafting-concepts-v03/drafts/02-window-generated.png`

보존 원본: `drafts/04-recipe-reward-generated-01.png` → 후속 편집 입력

실제 호출 프롬프트 원문:

```text
Use case: compositing. Asset type: 1920x1080 16:9 Korean medieval fantasy crafting UI, image 04-recipe-reward.
Inputs in order: image 1 v01/02a-window-diorama.png is the dominant STYLE, TEXTURE, DESK PROP and COMPOSITION authority; image 2 v02/04-recipe-reward.png is STRUCTURAL RECIPE-REWARD STATE ONLY, NEVER its simplified rendering style; image 3 v03/02-window.png, when available, is a supporting reference for matching the restrained v03 ornament treatment. Re-create the reward state inside the richly painted v01 book. In visual fidelity this must sit very near v01, with only 20-30% less decoration, nowhere near v02's flat icons.
Scene: 중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색 허용. Keep v01 purple dimensional aged leather book, folds/stitching/brass rivets and reflective corners, warm subtly mottled parchment, purple wax candle and brass holder left, quill/ink/stacked book lower left, material pouch and purple ribbon right, wooden desk grain, peripheral plants, lavender forest and warm medieval lodge, full HUD. Keep almost same prop count. Preserve hand-inked painterly material texture, multiple rich shading steps, detailed illustrated resource cards. Interrupt only select perimeter vines near information; retain corners and isolated edge sprigs. Halve incidental tiny stars; reduce only one rune/circle layer, modestly reduce count/contrast of tiny leather marks and parchment flecks. Clear HUD/card overlaps by peripheral foliage only.
Exact information: HUD "1일차 · 낮", "낮 · 시간 멈춤", witch 115/115, lodge 300/300, coins 40, wood 0, wool 0, pause. Book title "마법책", subtitle "낮 · 시간 멈춤", close X. Left tabs "물약 1 / 4", selected "장비 2 / 5", "마법 1 / 4", with clear progress annotation "1 / 5 → 2 / 5" below equipment tab. Left grid has FIVE recipes in v02 structure: top left existing known "누빈 솜옷" (warm quilted medieval padded coat, richly painted); top right newly unlocked "나그네 장화" with detailed paired brown leather travelling boots, "??? →" above indicating one formerly unknown slot has opened; bottom row THREE remaining unknown silhouettes with "???" underneath. CRITICAL: remaining unknowns must be a rounded medieval HELMET, a drawstring BAG, and a fur-shouldered CLOAK; absolutely NO boot/shoe-shaped silhouette in any remaining unknown.
Right page heading "제작법 획득"; exactly THREE empty circular ingredient slots with small star centers and connecting arrow. Result area shows torn parchment containing detailed brown paired traveller boots and label "나그네 장화", behind retained purple magic circle, glossy "제작" wax seal below. A hand in medieval brown sleeve enters upper right holding a torn page with same boots and exact "나그네 장화"; a modest curved purple light trail points from held page into book to convey insertion. Keep hand/page fully inside composition and do not cover slots/tabs/important text.
Banner above bottom resource row, separated from seal and rows, exact "찢어진 책장을 책에 끼워 넣었다". Keep complete lower six resource cards with v01 detailed illustrated materials and scenic backgrounds, exact labels/badges "약초" ×3, "정화된 정수" ×1, "양털" ×4, "목재" ×2, "쇠붙이" ×2, "토끼 가죽" ×1. All letters legible and correct. No flattening, iconification, large blank pages, deletion of props, unnecessary decorative additions. One finished landscape frame.
```

## 04 · 04-recipe-reward — 국소 정리 후속 편집, 성공·최종 채택

실제 입력 순서:

1. `art/ui/spellbook-crafting-concepts-v03/drafts/04-recipe-reward-generated-01.png`
2. `art/ui/spellbook-crafting-concepts-v03/drafts/02-window-generated.png`

보존 원본: `drafts/04-recipe-reward-generated-02.png` → 04-recipe-reward.png

실제 호출 프롬프트 원문:

```text
Use case: precise-object-edit. Conservative localized repair of input image 1, the existing 04 reward image. Image 2 (v03/02) is a supporting reference ONLY for the amount of vine-border cleanup. Keep image 1's layout, hand-painted textures, dimensional leather folds, brass, candle, quill, ink, book stack, ribbon, pouch, all detailed resource illustrations, background, HUD, entire information and exact Korean text unchanged. 중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색 허용.
Change ONLY two things:
1) Page margin vine density: match input image 2's interrupted border. Remove the middle segments of continuous vertical vines flanking the left recipe grid, especially left edge and immediately beside the book gutter. Leave the corner sprigs, moon motif, isolated edge sprigs, and warm textured parchment. On the right page remove middle/bottom continuous vine segments around the result card and keep only corner/edge sprigs. Do NOT erase grain or flatten shading. The overall goal is 20-30% fewer ornaments than the original v01, retaining rich painterly book rendering. This is not a minimalist redesign.
2) Banner at bottom says exactly "찢어진 책장을 책에 끼워 넣었다". Move this banner DOWN and reduce its height modestly so its top edge is entirely BELOW the bottom of the purple "제작" wax seal, with a visible gap. Fit it in the narrow horizontal gap above the six resource cards, leaving all resource labels fully visible. If necessary lift the wax seal and result parchment together just 10-15 pixels; do not let banner touch seal or cards.
Everything else locked: selected equipment "장비 2 / 5", annotation "1 / 5 → 2 / 5", known "누빈 솜옷", newly unlocked "나그네 장화" with ??? above, THREE unknowns HELMET, BAG, CLOAK with ??? below (no boots among unknowns). Empty three ingredient circles, held torn page and boots result, exact lower resource badges ×3 ×1 ×4 ×2 ×2 ×1. No additional sparkles. Preserve almost all of the v01 rendering, material richness and prop count. Output ONE 1920x1080 landscape reward image.
```

## 이전 429 오류 — 해결 전 이력

실패한 02 호출의 프롬프트는 위 01과 동일했다. 당시 03·04는 미호출 준비 상태였으며 이번 재개에서 실행했다.

```json
{"http_status":429,"error":{"type":"usage_limit_reached","message":"The usage limit has been reached","plan_type":"plus","resets_at":1792472161,"eligible_promo":null,"limit_window_minutes":1440,"resets_in_seconds":9901}}
```

당시 안내된 재설정 시각: 2026-10-20 13:56:01 +09:00. 이번 호출은 정상적으로 이미지를 반환했다.

## 후처리와 실제 검수

- `art/ui/spellbook-crafting-concepts-v03/drafts/build-deliverables.ps1`로 원본을 비율 유지 확대해 PNG 3장과 비교 시트를 조립했다. 이미지 내용을 수작업으로 다시 그리거나 v01·v02 결과를 복사해 최종본으로 삼지 않았다.
- 시트 글자는 게임 글꼴 `godot/assets/fonts/NotoSansKR-wght.ttf`를 읽기 전용으로 로드해 조판했다. 최종 시안 내 한글은 생성 결과를 직접 확인해 유지했다.
- 최종 3장을 원본 해상도로 직접 열고, 시트에서 v01 02a / v03 02 / v02 02를 나란히 확인했다.
- 가죽 주름·스티치·금속 광택·양피지 색 변화·나무결, 촛불·깃펜·책 더미·주머니·리본과 재화 카드 삽화가 남아 있다. 페이지 넝쿨은 이어진 테두리 대신 모서리·고립된 가장자리 가지로 정리됐다. 결과 뒤 마법진은 줄어든 겹과 보라 발광을 유지한다.
- 03의 배너 “새로운 비법을 책에 적었다”와 책 제목판이 분리되어 있다. 마법 2 / 4, 약초 ×2 + 정수 ×1, 덩굴 올가미 발견 상태를 확인했다.
- 04는 장비 2 / 5와 1 / 5 → 2 / 5, 기존 누빈 솜옷·새 나그네 장화, 남은 투구·주머니·망토의 ???를 확인했다. 미지 칸에 장화 실루엣은 없다. 배너는 “찢어진 책장을 책에 끼워 넣었다”다.
- 세 장 모두 아래 재화 수량은 ×3 / ×1 / ×4 / ×2 / ×2 / ×1이며 한글 깨짐을 발견하지 않았다.
- 20~30%는 시각적 정리 목표다. 장식 개수·반짝임의 정확한 감소율이나 모든 미세 질감의 일치를 계측한 수치로 주장하지 않는다. 의미 있는 마법·발견 반짝임은 유지했다.
- `drafts/final-files.json`에 최종 시안의 치수·소스·SHA-256을 기록했다. 기존 `drafts/protected-files-check.json`은 이전 시도의 작업 공간 관찰 이력이며 이번 재개 검증 결과가 아니다.
