# 마녀산장 — 배경색을 살린 숲의 어둠

2026-10-13. 내장 image_gen 편집 사용.

입력: `05-dark-forest-fog-of-war.png`
결과: `06-chromatic-forest-fog.png`

검정색에 가까웠던 가장자리 어둠을 보라·인디고·짙은 청록의 유색 그림자와 낮은 안개로 수정했다. 주변 숲과 눈의 색, 희미한 실루엣이 남아 깊이를 만들며 중앙 산장의 앰버 조명과 마녀·양의 가독성을 유지한다.

## 생성 프롬프트

```text
Use case: lighting-weather. Edit the supplied Witch's Lodge scene's OUTER FOREST DARKNESS AND ATMOSPHERIC COLOR only.
The user rejects the flat near-black darkness. Replace it with beautiful CHROMATIC DARKNESS, using the existing world colors, as a stylized hand-painted fantasy game environment. This is a deliberate background color composition, not a black vignette.

Preserve exact scene layout, high overhead camera, all geometry and scale, small centered cottage, one small purple witch in front, right pen with EXACTLY THREE sheep, sparse trees, rocks, shrubs, fallen log and household objects. No new props or characters. Keep the low prop density and low texture frequency: big clean painted masses, broad smooth painterly gradients, no extra fine detail or noisy fog. Preserve warm amber cottage windows and doorway and readable central lavender snowy clearing.

COLOR DESIGN:
Eliminate every near-black border, black corner, black silhouette and neutral gray fog. Lift the darkest values enough that their color is clearly apparent. The darkest background should be a rich smoky plum-indigo (~#292B50) or deep muted blue-teal (~#214653), never black. Make the dark surrounding forest substantially visibly COLORED even at the corners.
Integrate existing snow/foliage color into the shadow: dark green conifers have cool desaturated blue-teal shaded planes, subtle lilac-blue light on snow caps, violet-indigo in occluded boughs. Snow at the perimeter gradually becomes muted dusky lavender and deep periwinkle rather than being painted black. Rocks keep dark slate violet and teal faces. Broad layered banks of translucent dusk-purple mist merge with the ground around forest bases, while subtle muted petrol-teal haze adds depth between the distant trees. These are restrained beautiful atmospheric colors, not saturated neon or luminous magic smoke.
Compose broad organic spatial color variations: rear forest is smoky violet-indigo, lateral forest pockets mix muted teal with deep blue, nearer edge snow has dusky lavender, and tiny muted mauve transitions gently connect back toward the amber-lit cottage. Colors come from soft environmental ambient light and mist, not new visible light sources.
Keep the outer forest about 1.5-2 stops darker than the safe clearing, but maintain shadow hue and readable subdued tree/rock silhouettes throughout. The visual feeling must remain a mysterious dark unexplored forest surrounding a cozy refuge, with an RTS fog-of-war falloff, while avoiding crushed blacks. Retain two path approaches fading softly into the chromatic forest depth. Use irregular soft-edged world-space visibility transitions following ground/tree groups, no uniform circular radial vignette or hard reveal ring. Central clear area retains original warm/cool balance. The slight mist is low, softly layered and colored, not a dense bright curtain. All forms remain sharp enough to read, no defocus.
High-quality stylized game color script with a harmonious plum-indigo / teal / lavender palette and local golden amber accent. Broad painted diffuse textures remain simple. Same full-frame wide landscape aspect ratio. No text, logos, UI, border, watermark or split image.
```

