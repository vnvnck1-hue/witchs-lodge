# 실제 수정 프롬프트

내장 `image_gen`, 2026-10-17, 불투명 PNG.

입력 1(편집 대상): `art/concepts/environment/layout-a-game-camera-v02/01-layout-a-game-camera.png`

입력 2(색감·표현의 기준): `C:/Users/vnvnc/.codex/generated_images/01a14981-1583-7b43-bc84-99e4ff4814f4/exec-a1035462-46a8-4d75-b076-696109823507.png`

```text
Use case: style-transfer. Repaint IMAGE 1, using IMAGE 2 as the EXACT visual-style and color authority.

IMAGE 1 = EDIT TARGET: the camera-corrected A layout. LOCK its camera, perspective, 2:1 crop, object positions, relative sizes and all spatial content. Do not change the view again.
IMAGE 2 = USER'S CHOSEN ORIGINAL A PAINTING: binding reference for ALL color tones, brushwork, lighting feel, shape treatment and material rendering. The user explicitly says the last revision drifted away from THIS original's palette and expression and wants those restored. Match the SAME PAINTER and the SAME ART DIRECTION as image 2, rather than inventing another variant of fantasy game art.

CHANGE ONLY THE PAINTED LOOK of image 1:
- Restore image 2's creamy warm ivory snow lights and restrained soft dusty blue/lavender snow shadows. Match its warm/cool balance and saturation directly; don't make the whole snowfield pink-purple, icy blue or gray. Keep warm beige/brown paths as in image 2.
- Restore image 2's deep muted teal-green pine/shrub masses, warm amber-orange timber, neutral warm gray stones and restrained amber lights/fire.
- Restore its thick sculpted stylized forms and broad confident soft-edged brush planes: simple chunky cloudlike snow caps, generous broad pine bough shapes, rounded coherent shrub masses, big bevels on stones and timbers. Exactly the same degree of stylization, contour rhythm and shadow softness as image 2.
- Restore the original's sparse, large-scale surface marks. Remove the fine snow stippling, tiny leaf specks, scratchy foliage and excessive little value flecks introduced into image 1. The ground must be large calm painted shapes with the SAME texture frequency and simplification as image 2, not a mosaic of little patches.
- Match image 2's soft comfortable contrast and cozy daylight, no new grading, no increased saturation, no realistic woodland detail, no watercolor wash, no low-poly facets or hard cel shading.

STRICT INVARIANTS FROM IMAGE 1: keep the already adjusted higher gameplay camera and compact gameplay-scale lodge/characters. Same one lodge and chimney, LEFT empty attached extension area, RIGHT sheep pen with THREE sheep, visible purple-hatted witch, central small campfire with TWO resting workers and log benches, TWO unbuilt square tower clearings flanking the fire, ONE empty circular altar site lower-left, rear boulder/pine barrier and left/right approach roads. Do not import image 2's lower camera or larger object scale. Do not add/remove objects, move buildings, crop differently or flatten perspective.

Medieval-based fantasy, preserve medieval everyday materials and atmosphere with fantasy shape exaggeration. Single full 2:1 landscape painting. No UI, lettering, frame, watermark, diagrams or labels.
Desired result: IMAGE 1's camera and layout painted in IMAGE 2's exact colors and expressive visual language.
```
