# 실제 생성·보정 프롬프트

내장 `image_gen`, 불투명 PNG, 2026-10-17.

## 1. A안 첫 카메라 보정

입력 1(카메라): `output/layout-a-camera-v02/02-current-game-camera.png`

입력 2(배치·화풍): `art/concepts/environment/lodge-layout-options-v01/01-central-courtyard.png`

```text
Use case: style-transfer + camera correction of a selected level concept.
Deliver ONE complete environment concept painting, landscape aspect ratio EXACTLY 2:1 (1600x800 composition).
INPUT PRIORITY:
IMAGE 1 is a NEW ACTUAL GAME SCREENSHOT. This is the ABSOLUTE camera/projection/composition authority.
IMAGE 2 is the selected "A" level layout and approved softly muted Warcraft/LoL hand-painted art style. Use ONLY its spatial relationships and style, NEVER its camera angle, framing or hero-scale presentation.
The user selected layout A but rejected its isometric-looking camera. Repaint A so it looks like it is viewed through the actual gameplay camera of image 1.

CAMERA IS THE CRITICAL CHANGE:
Reproduce image 1's perspective camera: FOV 34 degrees, downward pitch 50 degrees, yaw 35 degrees, player-follow framing. Same camera height, same lens and same visible ground coverage as image 1. The roof and ground TOP PLANES are conspicuously visible; front walls are more foreshortened/shorter than in image 2. Match the lodge roof ridge direction, visible left-front facade/right wall proportions and near/far size falloff EXACTLY to image 1. No orthographic/isometric camera, no generic isometric diorama, no lower showcase camera, no farther pulled-back overview.
KEEP the cottage's screen footprint and location from image 1: about 17–18% of canvas width, around x=48%, y=21%. Keep it small and game-scaled; do not enlarge the cottage to image 2's hero size. Buildings/people/props must scale naturally in THIS perspective. Pine trees near the camera are larger than distant ones. The purple witch and resting workers must be SMALL in-game figures at similar physical scale, no oversized readable character portraits. Match the camera with image 1's architecture silhouette/ground projection, then paint over it. Do not just crop or widen image 2.

RETAIN SELECTED A TOPOLOGY, projected into image 1's view:
- ONE same small medieval timber-and-stone witch lodge, gabled snowy roof, one chimney, amber windows/door lantern and stone steps, at image 1's exact building angle.
- Rear blocked by a continuous natural band of snow-capped low boulders, pine shrubs and evergreens directly wrapping the building's BACK; no passable rear path.
- Generous empty flat expansion snow parcel immediately touching the lodge's LEFT side wall. No trees, props or paths in it.
- Small existing sheep pen with THREE sheep on the RIGHT, barrel by rear fence and open right-side gate; same perspective and game scale as image 1.
- Modest worker-rest CAMPFIRE in the central FRONT courtyard (approximately x=52%, y=66%), with two simple log benches and two tiny SD workers: lumberjack with axe, gatherer with wicker basket. It is a social facility, not a foreground character closeup. The witch remains nearby on the door-to-court route.
- EXACTLY TWO unbuilt square tower clearings flanking the fire, around x=30%,y=61% and x=75%,y=59%. Simple flat earth patches with four LOW corner stones each; NO towers or raised platforms. Perspective-projected ground quadrilaterals, not an imposed isometric diamond grid.
- EXACTLY ONE empty circular altar clearing at lower-left, around x=26%,y=81%, edged by low stones. Its circle must become an ellipse consistent with image 1's ground plane.
- Two unobstructed broad dirt/snow wave roads enter from LEFT and RIGHT edges and curve toward the front court. Short clear branches connect door, pen gate, fire and altar; walk around fire/benches, not through them. Remove the reference game's central carpet of leafy shrubs to clear these travel lanes. Keep a broad open door apron and no rear circulation.

STYLE AND TONE: maintain image 2's gently muted old Warcraft / classic LoL environment-painting shape language, thick timber and beveled stone, quiet ivory/periwinkle snow, subdued pine green and restrained amber. Comfortable moderate contrast and saturation. Sparse broad brushwork and calm ground areas. Do not inherit the screenshot's low-poly facets or thick fog wash. Medieval-based fantasy, keep medieval everyday atmosphere/materials while allowing fantasy shape exaggeration.
Single coherent finished painting, no UI, text, labels, diagram arrows, grid, watermark, extra houses, towers, built altar or extra decorative clutter. Camera fidelity to IMAGE 1 takes precedence over staged visibility from IMAGE 2.
```

## 2. 실제 캡처만 사용한 카메라 연구 — 비선택

입력: `output/layout-a-camera-v02/02-current-game-camera.png`

```text
Edit the attached ACTUAL GAME SCREENSHOT directly into a painted environment concept. Camera-locked paintover. Final canvas 2:1, exactly the same composition and projection as input.
MOST IMPORTANT: PRESERVE THE EXISTING COTTAGE AND SHEEP PEN PIXEL SILHOUETTES, SCREEN POSITIONS AND ORIENTATIONS. Do not replace them with a differently viewed house or enlarge them. Trace the existing roof perimeter, ridge axis, chimney, door position, visible wall proportions, footprint and fence perspective. Paint over those exact shapes in a softly muted old Warcraft / classic LoL hand-painted style. The actual input perspective is the desired camera: downward 50°, yaw35°, perspective FOV34°. Keep its high downward look, abundant visible ground and compact game-size props. DO NOT LOWER the camera, pull back, center a hero building, or switch to isometric illustration. Keep the cottage width only about 17% of the whole image. Keep its front steps around their existing location. Same small purple witch scale. Workers added in foreground have the same physical scale as the witch, NOT twice her size. The left roof gable must NOT rotate to face the camera front-on.

The user selected a new courtyard layout, called A. CHANGE GROUND/VEGETATION AND ADD PROPS WITHIN THE EXISTING GAME CAMERA, as follows:
1. Clear away the existing dense central bands of ground shrubs and scattered stepping stones, leaving generous readable walking space in front of the cottage.
2. Behind the lodge build a continuous natural blockade of low snow-covered boulders and dense pine shrubs directly against/around its rear, meeting the outer trees. No rear walking route. Do not enclose the front.
3. Leave a broad flat empty snowy future-extension parcel directly touching the cottage's LEFT wall, between cottage and left trees. No trees, paths, facilities or stones inside the extension area.
4. Preserve the existing small sheep pen on the RIGHT at its existing location and angle, with THREE sheep and a pale barrel, open gate. Do not make it giant.
5. A small worker rest campfire in the central FRONT open ground, centered near image x=52%,y=65%. Two short low log benches and two TINY SD medieval workers resting: lumberjack with axe beside him, gatherer with wicker basket. Top of their hats and shoulders clearly visible from the input's high camera. Entire fire/benches/figures cluster approximately 12% of canvas width, NOT a large foreground vignette.
6. EXACTLY TWO EMPTY tower-building pads flank the fire, x=29%,y=58% and x=75%,y=57%. Each is a small flat square earthen patch with four very LOW corner stones. Project these squares using the ACTUAL input ground camera, not a neat isometric diamond system. No towers yet.
7. EXACTLY ONE empty small circular altar-building site near x=26%,y=82%, bare earth with a few low perimeter stones; viewed from the input camera as an appropriate foreshortened ellipse. No altar built.
8. Broad naturally curving wave routes enter from LEFT and RIGHT edges into the open front court. Simple short walking branches lead to door, fire, pen gate and altar. Fire and pads stay OFF the road. No path behind lodge. Two wave entry directions only.
Retain the A layout relationships: lodge upper-middle; LEFT expansion; RIGHT pen; central campfire; pads either side; altar lower-left. Position new objects on the screenshot's unchanged ground plane.

Painted finish: medieval-based fantasy with medieval everyday atmosphere and allowable shape exaggeration. Warm timber, gray stones, ivory snow and quiet dusty periwinkle shadows, subdued evergreen foliage, restrained amber window/fire light. Comfortable soft saturation and moderate contrast. Broad clean brushwork, gentle gradients and sparse detailing. Crisp enough to read, no blur wash. Improve low-poly material appearance through painting while preserving architecture outline/projection. No generic diorama presentation.
Single complete painting. No interface, labels, arrows, grid, watermark, extra buildings, towers, built altar, monsters or added ornamental clutter. The original screenshot's exact camera and lodge silhouette have higher priority than picturesque composition.
```

## 3. 최종 추가 보정

입력 1(편집 대상): `art/concepts/environment/layout-a-game-camera-v02/drafts/01-camera-pass.png`

입력 2(카메라 기준): `output/layout-a-camera-v02/02-current-game-camera.png`

```text
Image 1 is the edit target: a soft hand-painted old Warcraft/LoL environment concept of the selected A layout. Image 2 is the actual GAME CAMERA reference.
Reproject image 1 into the exact camera angle of image 2. This is a CAMERA CORRECTION, not a new environment or art-style change.
The camera in image 1 is still too low/showcase-like. Raise the downward viewing angle to match image 2 (50 degrees down, 34-degree perspective FOV, 35-degree yaw), so the top of the roof, ground clearings and tops of character hats/shoulders are substantially more visible and front walls are shorter in projection. Make the lodge approximately 15% smaller than in image 1 and keep it in the upper-middle, matching its screen footprint in image 2. Match roof ridge orientation and visible front/right wall proportions to image 2. Reduce front-facing hero presentation; all characters remain small gameplay figures. Use genuine perspective size falloff like image 2, not a uniform isometric map. Same 2:1 landscape aspect. No horizon.
PRESERVE IMAGE 1's exact architectural DESIGN and softly muted PAINTING STYLE: thick curved timber, chunky beveled stone, simple broad pine shapes, large calm snow color areas, dusty periwinkle shadows, subdued green and soft amber lighting. No photorealistic conversion, no fine realistic woodland texture, no extra tufts of grass or tiny branches. Keep the purple pointed-hat witch visible. Keep the same THREE sheep.
Preserve A's world-space topology while changing its projection: lodge upper-middle, RIGHT sheep pen, LEFT attached EMPTY expansion snowfield, natural continuous rear boulder/pine blockade; central front CAMPFIRE with TWO small resting workers and benches; EXACTLY TWO square EMPTY tower pads one each side of fire; ONE circular EMPTY altar pad lower-left; wide LEFT and RIGHT incoming wave roads joining front court, short clear facility links. Nothing built on the three pads, no rear walking route. No extra facilities. Keep all these elements visible without pulling the camera farther away than image 2.
Medieval-based fantasy, everyday medieval materials and atmosphere, fantasy shape exaggeration allowed.
One finished painting only. No UI, text, grids, arrows, logos or watermark.
```
