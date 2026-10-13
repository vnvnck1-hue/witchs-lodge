# 카드 화풍을 기준으로 게임 배경 덧그리기

제작일: 2026-10-13 · 도구: 내장 image_gen · 범위: 시각 스타일 검토용 페인트오버

사용자는 첫 합성본의 큰 카드 배치를 카드 사용 시 올라오는 상태로 인정했다. 그 크기와 위치를 유지하고 게임 배경에 카드 원화의 먹선·큰 색면·인쇄 질감을 덧그린다. 기존 카메라·공간 배치와 비어 있는 플레이 공간을 기준으로 삼는다.

입력 1 (수정 대상): art/concepts/cards/game-screen-hand-v01.png
입력 2 (화풍 참고): art/concepts/cards/base-card-format-approved-v01.png
입력 3 (나무·이끼·눈의 화풍 참고): art/concepts/cards/forest-monster-summon-v01.png
결과: art/concepts/environment/08-card-style-game-paintover-v01.png

별도 이미지 시안이며 런타임 모델·텍스처·셰이더를 수정한 결과는 아니다. 사용자 검토 전 새 최종 배경 기준으로 확정하지 않는다.

## 최종 프롬프트

Use case: style-transfer. Asset type: game visual-direction paintover for 마녀산장.
Input image 1: EDIT TARGET, the user's accepted large-card gameplay composite. Keep the SAME 2:1 landscape canvas, elevated orthographic game camera, framing, spatial layout and object locations. In particular keep exactly the three LARGE raised foreground cards at the bottom in their current position, size, slight tilt, overlap, illustrations and Korean lettering. The user explicitly approves their partially covering the scene during card use; do NOT shrink, lower, move or remove them, and do NOT reveal what they cover.
Input image 2: approved axe mercenary card, STYLE REFERENCE for the world artwork only: lively thick hand-inked black contours, limited broad flat color areas, carved/printed-looking broken brush accents, subtle paper grain, warm cream snow, deep teal pines, warm burnt-orange light, playful slightly eerie illustrated storybook character.
Input image 3: forest monster card, secondary STYLE REFERENCE for inked organic wood/moss/snow treatment, not a request to add the monster.
Primary request: carefully PAINT OVER ONLY THE GAME BACKGROUND of image 1 enough to unify its visual language with the card art. This is a moderate art-direction overpaint of the existing playable-looking scene, not a new location and not a poster. Preserve its existing chunky 3D volumes, oblique top-down readability, sparse prop density, large open snowy ground and exact lodge/pasture/tree/rock arrangement. Change the surface language and silhouette rendering with confident hand-drawn ink and simplified printed colors. Cards already provide the target finish; keep their artwork intact.
World treatment:
- Give lodge roof, thick wooden beams, chimney, door, window frames, sheep, fences, pines and rocks tapered expressive dark charcoal/indigo ink contours, bolder silhouette edges and sparse interior ink accents. Use line weight hierarchy; background outlines are somewhat quieter than card illustrations so the world remains readable rather than noisy.
- Simplify smooth 3D shading into large painted two-or-three-tone shapes while retaining useful volume and cast shadows. Existing low-poly silhouettes can become gently organic at their edges, but keep recognizable geometry and current sizes.
- Pine foliage: large deep teal/navy green shapes, broad asymmetric black brush marks, chunky warm ivory/lavender snow drifts. Do not add extra trees or branch detail. No dense hatching.
- Rocks: broad cool violet/indigo stone planes with bold irregular silhouettes and a few inked cracks, soft cream lavender snow tops. Keep positions and masses.
- Snow and ground: broad lavender and dusty violet fields with a few quiet cream cool-blue printed highlights, sparse broken brush grain, restrained depth through large shadow shapes. Avoid covering empty playable ground with little texture marks.
- Lodge: burnt sienna and muted ochre wood, cream and lilac snow roof, dark ink joins, same warm amber windows and doorstep light. Keep roof/chimney/pasture layout. Sheep are off-white rounded fleece shapes with simple thick dark legs and face accents, precisely the three existing sheep.
- Subtle consistent tactile print/paper grain in environment, matching card artwork, with controlled ink edges. No photorealistic materials, shiny plastic, bloom-heavy lighting, painterly oil smear, excessive comic outlines or muddy brown monochrome.
Lighting/mood: retain original purple/indigo snowy dusk, teal dark forest and comforting amber lodge light. Slightly reduce soft 3D airbrushed appearance in favor of the cards' bold illustration. Preserve readable warm refuge surrounded by cold forest.
Constraints: preserve ALL three foreground card pixels/designs as faithfully as possible; no changes to Hangul titles, categories or rules. Do not add UI, captions, card ornaments, characters, monsters, additional buildings, props, fences or paths. No decorative border around screenshot, no landscape horizon, no change to camera, no enlarged close-up. No split before/after image.
Output ONE complete landscape image showing the SAME approved large-card composite with a coherent storybook ink/flat-print paintover on the game world behind it.
