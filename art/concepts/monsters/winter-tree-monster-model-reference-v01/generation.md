# 겨울 숲 나무 괴물 모델링 참고 v01

- 제작일: 2026-10-17
- 도구: 내장 image_gen, transparent_background=true
- 사용자 요청: 거미와 같은 방식으로 게임에 등장하는 나무 괴물 원화 제작. 이전 요청의 배경 없는 3면도 + 별도 반측면도 구성 유지.
- 정체성 근거: art/concepts/gameplay/03-forest-encounter.png 중앙 큰 나무 괴물, art/concepts/cards/forest-monster-summon-v01.png의 가지 뿔·이끼·황록색 눈.
- 화풍 참조: art/concepts/monsters/winter-forest-spider-model-reference-v01/winter-spider-three-quarter-v01.png.
- 카드 프레임을 제작하거나 기존 게임 자산을 교체하지 않음.
- 검수: 단일 반측면 전신, 정면·측면·후면 3뷰, 가지 뿔과 이끼 덮인 나무 몸통 일관성 확인. 두 파일 Format32bppArgb, 8px 간격 알파 샘플 범위 0..255로 실제 투명 배경 확인.
- 모델링 참고 시안이며 뷰 간 가지의 세부 각도·수피·눈 분포는 완벽한 3D 투영 정합성을 보장하지 않음.

| 결과 | 크기 | SHA256 |
| --- | --- | --- |
| winter-tree-monster-three-quarter-v01.png | 1254×1254 | EDEAC7B03C03AE797FB576352E62555FB2CE9E3CB8ADF64D9EF559A9E6393A6E |
| winter-tree-monster-three-views-v01.png | 1983×793 | 9C2F236A857CEA6A85EC42D8A83C5917BD37F5E1C74FAC8516294B5643EAA482 |

## 반측면도 실제 프롬프트

```text
Use case: stylized-concept
Asset type: standalone full-body FRONT THREE-QUARTER CHARACTER CONCEPT for 3D modeling, the existing forest tree monster in the game 마녀산장.
Input images: Image 1 (winter forest encounter) is CREATURE IDENTITY reference: use the LARGE central mossy wooden monster with branch-antler horns, not the little dark creatures or humans. Image 2 (forest monster card) is an additional IDENTITY reference for bark face, moss mantle and yellow-green eyes only; DO NOT copy its card frame, text, pose cropping, or flat ink style. Image 3 (winter spider) is the desired RENDERING STYLE reference: chunky sculpted forms with clean hand-painted stylized game shading, broad color shapes and soft texture, suitable for a low-poly 3D game.
Subject: ONE squat stout anthropomorphic winter woodland TREE MONSTER. Head and torso formed from one broad slightly hunched trunk, face integrated into layered bark, TWO small restrained luminous yellow-green eyes recessed under a woody brow, no human nose, no wide toothy mouth. TWO upward branching antler-like wooden boughs rooted behind the crown/upper back, sparse simple branches with broken tips. Dark walnut and warm umber bark in large overlapping angular plates. Mossy muted olive-green crown and shoulder mantle, a little on forearms and back; restrained snow caps only on upper branches and shoulder ledges. Two thick articulated wooden arms ending in large hands, each with exactly THREE chunky root-like fingers and ONE thumb; two short sturdy wooden legs ending in broad three-root feet. Broad compact readable silhouette, charming but mildly menacing ordinary game monster, about 2.5 heads tall excluding branches. No clothing, armor or tools.
Composition: one full-body isolated creature, front-left 45-degree three-quarter view, very slight elevation so shoulder structure and feet can be seen, neutral relaxed A stance, feet apart, arms angled slightly away from torso with gaps so elbows/hands are clear. Entire creature including branch tips and toes inside frame with generous margin. Square high resolution.
Modeling clarity: limbs easy to separate into major volumes, bark grooves simplified, no dense twig clutter, little snow so actual forms remain visible. Soft neutral studio lighting, consistent large color planes, not photorealism, not flat woodcut, no dramatic shadow.
ACTUAL TRANSPARENT ALPHA BACKGROUND. No forest, floor, ground shadow, snowfield, floating snow, web, background gradient, checkerboard graphics, card border, text, captions, dimensions, watermark, other creatures or duplicate views.
```

## 3면도 실제 프롬프트

```text
Use case: stylized-concept
Asset type: 3D MODELING TURNAROUND of the exact supplied winter TREE MONSTER.
Input image 1 is the definitive full-body creature design. Preserve its identity exactly: squat broad bark body, face integrated into trunk, two small yellow-green glowing eyes under bark brows, two antler-like branched wood boughs behind crown, layered brown bark plates, olive moss mantle, restrained snow patches, heavy arms and large three-finger-plus-thumb wood hands, short legs and broad three-root feet. Do not redesign it or create variants.
Create ONE wide landscape sheet with exactly THREE SEPARATE FULL-BODY ORTHOGRAPHIC VIEWS arranged left to right:
LEFT: perfectly straight-on FRONT, left and right eyes both visible, symmetric shoulders, hands held slightly away from torso, feet apart.
CENTER: perfectly true LEFT SIDE PROFILE, creature looking LEFT, camera precisely 90 degrees from front; show one eye only and one face contour in silhouette, no second eye or front plane. Shoulders, knees and feet perfectly side-on, far arm and far leg naturally occluded behind near side. The two branch growths must retain correct attachment at upper back, their profile overlap is natural. No three-quarter angle in this center view.
RIGHT: perfectly straight-on BACK; no eyes and no face. Show how the twin branch trunks emerge from the upper back, olive moss across shoulder blades, bark spine and rear of arms and root feet.
All three views have the SAME scale, same head and feet heights, same neutral modeling A pose, matching proportions and branch lengths. Flat orthographic projection without foreshortening. Level baseline, consistent branch-top height. Large empty transparent gaps between views, generous transparent margin around every branch and foot. Nothing cropped, touching or overlapping adjacent views.
Rendering: polished hand-painted stylized low-poly-game-like 3D concept art matching input. Clear major forms and bark plate borders, simple even diffuse studio lighting, subdued contact shading within the character only, no dramatic lighting. Keep fingers and elbows readable, simplify fine moss details without changing silhouette. No additional anatomy, no extra branches, weapons, clothes or gear.
ACTUAL TRANSPARENT ALPHA BACKGROUND, ONLY three isolated character views. No floor, scenery, forest, snow ground, shadow below feet, particles, gradient backdrop, colored panels, checkerboard graphics, captions, letters, labels, dimension lines, UI, card frame or watermark. Wide high-resolution canvas.
```
