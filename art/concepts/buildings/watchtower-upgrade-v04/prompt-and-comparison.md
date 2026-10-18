# 감시탑 v04 — 실제 게임 산장 텍스처 기준

제작일: 2026-10-18 (Asia/Seoul)
방식: 내장 image_gen 편집. 결과: [watchtower-levels-1-2-v04.png](watchtower-levels-1-2-v04.png), 1536×1024 PNG.
요청: 실제 게임에 적용된 산장 텍스처와 비교해 감시탑의 색·채도·명도를 다시 맞춘다.

## 실제 참고 입력

1. [게임 산장 텍스처 JPG](../../../../godot/assets/cottage/user_cottage_tripo_image_7b97c013-7136-4fe0-9612-a405584e277e_0_0.jpg): 주 재료·색 기준. 현재 user_cottage.glb의 내장 이미지와 SHA-256 일치를 확인했다.
2. [실제 적용 산장 화면](../../../../output/user-cottage/installed-main-cottage.png): 2026-10-15에 저장된 실제 모델 적용 캡처. 새 실행 캡처가 아니다. 질감·재료의 입체 표현을 참고했다.
3. [감시탑 v03](../watchtower-upgrade-v03/watchtower-levels-1-2-v03.png): 구조·구도의 수정 대상.

기존 산장 원화나 3면도는 이번 이미지 생성에 입력하지 않았다. 게임 코드는 모델의 원래 albedo 텍스처를 전용 셰이더로 표시하며 roughness .95, specular 0을 사용한다.

## 비교 및 검수

같은 기준으로 갈색 픽셀 후보를 표본 추출해 HSV 중앙값을 비교했다. 8픽셀 간격, H < .10, S > .25, .15 < V < .85, 각각 0~1 범위. 순서대로 H/S/V:

| 자료 | 후보 수 | H | S | V |
| --- | ---: | ---: | ---: | ---: |
| 실제 산장 텍스처 | 33872 | .041 | .512 | .380 |
| 감시탑 v03 | 5354 | .053 | .530 | .416 |
| 감시탑 v04 | 5576 | .037 | .496 | .361 |

v03보다 색상이 적갈색 쪽으로 이동하고 S/V가 낮아져 세 값 모두 실제 텍스처의 중앙값에 가까워졌다. 이 값은 자동 색상 조건으로 고른 갈색 후보의 비교다. 정확한 목재 재질 마스크·동일 UV 위치·동일 조명의 측정이 아니며 일부 다른 재료도 포함될 수 있다. HSV V는 지각적 명도나 선형 휘도와 같지 않다. 감시탑 원화와 실제 게임 렌더의 최종 색이 완전히 일치한다고 증명하는 수치가 아니다.

육안 검수에서도 목재 전면·난간·사다리의 노란 주황빛과 밝은 모서리 강조가 줄어들고, 더 차분하고 어두운 적갈색과 무광 재료로 바뀐 것을 확인했다. 1단계 지붕 없는 망루와 2단계 지붕·천·종·초승달·보강 구조, 전체 실루엣, 단계 문구는 유지했다. 게임 적용 전 모델링 참고 원화이며 실행파일은 변경하지 않았다.

## 실제 생성 프롬프트

```text
Use case: style-transfer / precise-object-edit.
Task: Correct the existing two-tower concept sheet's material color, saturation, brightness and painted texture to match the ACTUAL IN-GAME COTTAGE TEXTURE provided. This is NOT a match to previous cottage concept art. Redraw the towers with a visibly changed actual-game material palette; preserve their existing structures and composition.

INPUT IMAGES AND PRIORITY:
Image 1 = ACTUAL game's cottage albedo texture atlas, verified byte-for-byte identical to the image embedded in the game cottage GLB. This is the PRIMARY AUTHORITY for timber/stone colors and painted material finish. Its fragmented layout is UV islands, not scene elements; do not reproduce UV fragments in output.
Image 2 = screenshot of that actual installed cottage in the game, supporting reference for how the texture reads wrapped on the 3D model. Use the central timber/stone cottage only as material reference. Ignore scenery, snow, camera, grass, sheep, fence, smoke and character. Never copy any of those into output.
Image 3 = EDIT TARGET, current stage-1 and stage-2 watchtower comparison, whose wood is still too golden/yellow-orange, too bright at its edges, too polished relative to actual cottage. Preserve these watchtower identities exactly, but correct the materials strongly enough to be visibly clear.

ACTUAL GAME PALETTE TO TRANSFER:
The actual cottage timber is subdued RED-BROWN/chestnut with grayish maroon undertones, darker shaded walnut, low-gloss painted surfaces. It is not golden pine, orange honey, caramel, yellow timber, bright tan or saturated red. Refer directly to image 1 brown texture patches and image 2 dark front gable beams/door.
As broad COLOR ANCHORS, wood midtones around #704B40 and #684337, shadow families around #49342F, #55372F, modest soft highlights around #926B59. Use natural broad paint variation and large softly blended planes, not exact flat fill. These anchors describe the materials, do not print swatches or numbers.
Remove the edit target's bright peach/cream/yellow edge highlights from posts, rails, ladder sides and roof beams. All these wooden parts must use the same restrained red-brown family as the actual cottage. Ladder rungs can be a little worn and lighter, still brown, no orange stripe at every edge. Make the broad front faces of wood clearly darker and more red-brown than image 3. Do not merely deepen the shadows while leaving the bright golden front faces unchanged.
Actual cottage stone is muted warm gray/taupe with dusty slightly mauve undertones; reproduce this as broad softly painted stone blocks, not overbright cream cobbles, shiny faceted rock or strongly purple stone. Approximate family #857B75, #A09589, #605C60 with modest lighter faces. Reduce small bright cuts and polished edges.
Roof stays muted indigo-purple slate with a desaturated gray-violet finish, not snowy white. Keep clear but subdued tile group shapes and avoid a bright highlighted rim on each tile.
Iron straps are matte dark brown-gray, low contrast rivets, minimal shine. Crescent finial and bell are dark aged bronze, subdued reflected light, no bright shiny gold. Cloth stays dark dusty violet with a restrained faded pale crescent.
Lantern amber flame/glass remains a small bright accent, like the cottage windows. Do not spread its orange-yellow glow over all wood as the dominant lighting.
Keep all materials cohesive with the actual cottage's restrained texture density, large painted regions, softly rendered wear and very low specular gloss. No lacquer, shiny plastic, exaggerated smooth white bevel highlights, excessive sharp woodgrain or microscopic scratches.

GEOMETRY INVARIANTS:
Exactly two towers from image 3 side by side, LEFT stage 1, RIGHT stage 2, same front-right three-quarter angle, same baseline and world scale, same relative heights and footprints. No redesign.
LEFT must be entirely roofless, open-air square lookout deck with waist-high parapet, short capped posts, a clear front ladder opening, four thick legs, crossbraces, four stone footings and attached lantern. No roof support frame, canopy or tall posts.
RIGHT keeps its same ONE upgraded lookout platform, slightly taller, heavier stone base, shaped balcony supports, rich layered gently sweeping pyramidal roof, visible iron reinforcement, front ladder, small crescent finial, attached bell, violet crescent cloth, lantern. Retain this richer construction and decoration; no new ornaments.
Keep sturdy medieval fantasy architecture and the softly rounded hand-hewn chunky shapes. Medieval-based fantasy, retain medieval everyday life and atmosphere with fantasy adaptation allowed.
No snow on either tower, since these are structural Tripo references.

OUTPUT:
Landscape comparison sheet, same plain light warm gray background and unobtrusive soft neutral contact shadows. Entire towers and ladders and finial visible with margins, neither touches frame or each other; broad blank central gutter. Only text "1단계" under left and "2단계" under right. No inset cottage, palette swatch, UV atlas, reference panel, scenery, ground island, labels beyond those stage labels, UI, watermark or props.
Lighting is quiet diffuse neutral daylight so the true material color remains visible: no sunset orange light, heavy blue/violet wash, fog, global gray filter or overall dark exposure. Crucially darken and shift the WOOD MATERIAL into the actual cottage's grayish chestnut/red-brown family while leaving background and overall viewing clarity intact. Preserve legible geometry and painterly stylized model-ready rendering.
```

