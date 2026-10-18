# 감시탑 1·2단계 비교 원화 v03 — 산장 화풍 맞춤

제작일: 2026-10-18 (Asia/Seoul)
방식: 내장 image_gen 편집, 배경 포함 PNG.
결과: [watchtower-levels-1-2-v03.png](watchtower-levels-1-2-v03.png)

사용자 요청: 기존 산장 원화와 결을 맞춰 다시 제작.
실제 입력:
- 수정 대상: [감시탑 v02](../watchtower-upgrade-v02/watchtower-levels-1-2-v02.png).
- 주 화풍·재료 참고: [기존 산장 3면도](../../../model-sheets/lodge-redesign/02-lodge-front-right-back.png).
- 색감·전체 표현 참고: [승인된 산장 앞마당 원화](../../environment/layout-a-game-camera-v03-style/01-layout-a-style-restored.png).

검수: v02보다 목재의 주황빛·날카로운 테두리 강조가 줄고, 기둥·기둥 머리·석재가 둥글고 불규칙한 큰 덩어리로 바뀌었다. 넓은 붓질과 보랏빛 그림자를 확인했다. 1단계의 지붕 없는 구조, 2단계의 지붕·보강·초승달·천·경보 종, 두 탑의 독립된 전체 실루엣과 단계 문구를 유지했다. 원화 검토용 시안이며 게임에는 적용하지 않았다.

## 실제 생성 프롬프트

```text
Use case: style-transfer / precise-object-edit.
Create a revised concept sheet for Tripo image-to-3D modeling of the two watchtower upgrade stages, matching the cottage's actual art direction closely.

REFERENCE ROLES:
Image 1 is the EDIT TARGET: the two watchtowers. Preserve their design identity, access ladders, levels, key upgrade features, front-right three-quarter views and side-by-side presentation.
Image 2 is the PRIMARY STYLE AND MATERIAL REFERENCE: the cottage front/right/back concept sheet. Transfer its rounded hefty timber shapes, restrained brown wood, soft wide painterly shading, rounded irregular taupe stone, understated iron hardware, handcrafted edges and quiet highlights to BOTH towers.
Image 3 is the SECONDARY STYLE AND PALETTE REFERENCE: the approved cottage courtyard painting. Match its mellow brown architectural palette and subtly cool violet-blue reflected shadows. Use ONLY its visual language, not its landscape.

REQUEST:
Redraw both towers convincingly as buildings made by the same craftsmen as the reference cottage. This needs a visible material and shape adjustment, not just a color filter on the edit target. Medieval-based fantasy, retain medieval everyday life and atmosphere with fantasy adaptation allowed.

CHANGES TO SHAPE AND PAINT:
- Reduce the original watchtowers' bright orange-yellow lumber saturation and bright cream razor-edged highlights. Use quieter honey/chestnut/umber browns directly informed by the cottage, keeping warmth but making wood less orange and less new.
- Replace machined straight rectangular timber appearances with slightly bowed, chunky hand-hewn beams, broad soft chamfers, rounded worn corners, subtle irregularity at plank edges, stout softly rounded joinery like the cottage. Keep structurally sound and readable.
- Treat wood with broad quiet brush planes and a very few soft strokes, not many thin grain lines, scratches, sharp cuts or rim highlights.
- Stone foundations have a few larger slightly irregular rounded gray-taupe blocks like the cottage foundation, not small repetitive bricks. No crisp decorative incised diamond patterns on stone.
- Use two or three broad shadow masses with soft painterly transitions, restrained cool lavender-blue in shadows and reflected light, subdued warm broad highlights. No shiny studio product-render look, lacquered surfaces, plastic bevel sheen, photographic texture or harsh black ambient occlusion.
- Iron straps and rivets should be matte dark muted brown-gray iron. Reduce their shine and visual contrast, keep broad simple shapes. Antique bronze crescent/bell should be weathered and subdued, not gleaming yellow-gold.
- Keep clarity and resolution: softer brush language is not blur, haze, desaturation of the whole sheet or muddy lost edges. Buildings remain strongly three-dimensional and cleanly legible for modeling.

LEVEL 1, LEFT:
Absolutely roofless open-air timber lookout platform. No roof, awning, pergola or tall roof posts. Four short capped parapet posts, waist-high plank parapet with clearly visible ladder entry gap, visible open deck, four heavy timber legs with diagonal braces, small individual stone footings, front ladder, small warm amber lantern on a parapet bracket. Retain the original modest sturdy height.

LEVEL 2, RIGHT:
Keep the richer upgraded version, not simplify it down to level 1. Moderately taller deck and stronger stone plinth, broader balcony on thick shaped wooden corbels, heavier diagonal supports, forged iron bindings, richer layered substantial curved eaves, pyramidal muted indigo-purple shingle roof with slightly sweeping lower profile echoing the cottage's gently curved eaves. Roof shingles should be larger broad irregular grouped shapes with fewer individual highlighted seams. Keep a small attached crescent finial, one muted dusky violet crescent cloth panel, warm amber lantern and a small attached bronze alarm bell. Maintain this purposeful richness through larger integrated shapes and crafted structure, not added tiny filigree or scattered props. The upgrade is still one observation platform, no extra story, turret, giant castle mass, weapons or new objects.
Both towers remain the same family; only the upgraded version has a roof. Do not invent snow just to copy the cottage: no snow on either tower, for exposed modelable geometry and seasonal reuse.

COMPOSITION INVARIANTS:
Exactly two towers, left stage 1 and right stage 2. Same physical scale, common ground baseline, same three-quarter camera and lighting, complete silhouettes with all feet, ladders, roof and finial inside frame. Comfortable top margin above crescent, generous side margins and large blank central gutter. Neither tower overlaps the other. Landscape canvas. Plain uniform pale warm gray background, small soft cool contact shadows only. No cottage or environmental scenery in the output. No ground island, vegetation, people, detached accessories, particle effect or comparison inset.
Only text: "1단계" under left tower and "2단계" under right tower, with clear whitespace to buildings. No other text, dimension, title, watermark, card border or UI.

Final impression: a softly painted, chunky, lived-in medieval fantasy cottage asset family, quieter browns and cohesive blue-violet shadows; not polished orange toy towers. Preserve the appealing upgrade silhouette and decoration already requested.
```

