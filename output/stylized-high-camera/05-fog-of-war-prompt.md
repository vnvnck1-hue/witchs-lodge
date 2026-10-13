# 마녀산장 — 어두운 숲·전장의 안개 분위기

2026-10-13. 내장 image_gen 편집 사용.

입력: `04-simplified-props-textures.png`
결과: `05-dark-forest-fog-of-war.png`

중앙 산장·마녀·세 마리 양과 가까운 이동 공간의 가독성을 유지하면서, 주변 숲과 두 길의 먼 끝이 짙은 인디고·청록 어둠에 잠기도록 조정했다. 경계에 옅고 낮은 어두운 안개를 더했다. 기존 높은 카메라와 낮은 프랍·텍스처 밀도를 유지했다. 실제 게임의 시야 계산 기능을 구현한 자료가 아니라 전장의 안개를 연상시키는 분위기 컨셉이다.

## 생성 프롬프트

```text
Use case: lighting-weather.
Asset type: fog-of-war mood revision of the supplied approved Witch's Lodge game concept.
Primary request: Add surrounding DARK FOREST / RTS FOG-OF-WAR darkness while preserving the original simplified scene exactly. The clearing is a small revealed safe area inside an unexplored dark forest.

Change ONLY regional lighting and a restrained ground-hugging shadowy fog layer. Keep the exact existing higher overhead orthographic camera, composition, all object positions and sizes, the small central cottage, one purple-hatted witch in front, tiny right pen and EXACTLY THREE sheep, all sparse conifers, three rock groups, two shrubs, fallen log, barrel, firewood, paths and stone steps. Do not add props, extra trees, monsters or terrain. Preserve the low prop density and clean broad hand-painted color masses, minimal texture detail, chunky mildly Warcraft/Hearthstone-like forms. Do not add noise, microtexture, leaf detail, particles or cinematic blur.

DARKNESS DESIGN:
Maintain an organically irregular elliptical REVEALED AREA around the cottage, pen, witch and immediate walkable snow: these remain clearly readable, with lavender snow and the existing warm amber window/door glow. Make the central warm refuge stand out.
Beyond that safe area, create a broad soft-edged transition from cool periwinkle snow to desaturated deep blue-indigo shadow and finally nearly black blue-green forest darkness towards all four edges and corners. The outermost 15-20 percent should be strongly obscured, with conifers/rocks only partially visible as muted silhouettes; medium-distance trees near the clearing remain readable and have subdued cool rim light. Darkness should emphasize that the world continues into an unseen forest. The upper forest and distant ends of both incoming paths disappear into shadow. Both path entrances near the clearing must still be readable. Keep the witch, all sheep, door and front walkway clearly visible.
This is GAMEPLAY FOG OF WAR integrated with world space: irregular soft shadow banks that curl gently around outer tree bases and rocks, faint very smooth low dark-blue mist at the reveal boundary, layered visibility falloff. Use slightly uneven lobes and interruptions following forest/ground structure. Avoid a uniform circular camera vignette, hard black ring, opaque black disk, top-down spotlight cone or visible bubble wall. No white or bright gray fog; mist is transparent, dark, subtle and subordinate to the darkness. Do not turn the entire image globally dark: the safe interior should retain its original readability and cozy purple winter colors.
Rocks, snow and trees at far edges receive much less ambient light; their texture vanishes into dark large shapes. Retain original amber cottage lighting, add only a restrained natural warm spill nearby if necessary. No extra lights.
Single continuous image with same wide landscape aspect ratio as input. No UI, text, logos, watermark, frame or collage.
```

