# 프랍·텍스처 밀도 축소 수정

2026-10-13. 내장 image_gen 사용.

생성 입력: 작업 폴더의 `output/stylized-high-camera/01-sturdy-frontier.png`.
최종 결과 원본: 작업 폴더의 `output/stylized-high-camera/04-simplified-props-textures.png`.
자료집 보존본: [프로토타입 승인 기준](../../art/concepts/environment/04-prototype-reference-simplified.png).

프랍 군집과 작은 장식물을 줄이고 넓은 눈밭을 확보했다. 텍스처의 미세 무늬, 촘촘한 균열, 눈밭의 작은 색조각을 큰 색면과 넓은 명암으로 단순화했다. 높은 카메라, 중앙 산장·마녀·작은 목장과 세 마리 양을 유지했다. 아래 감소 비율은 생성 지시용 목표이며 실제 에셋 개수·텍스처 해상도 측정값이 아니다.

## 단순화 생성 프롬프트

```text
Use case: style-transfer / precise-object-edit.
Edit the supplied Witch's Lodge image to substantially REDUCE BOTH PROP DENSITY AND TEXTURE DETAIL FREQUENCY. The user finds the current image much too busy. This correction must be immediately obvious, not a subtle color adjustment. Keep the same high overhead three-quarter orthographic camera, viewing direction, framing, small centered lodge, single tiny purple-hatted witch directly in front, and tiny right-hand sheep pen with THREE sheep. Preserve purple winter atmosphere, dark green conifers, warm amber door/window and mildly Warcraft/Hearthstone-inspired chunky silhouettes.

PROP SIMPLIFICATION: Remove approximately 65-75 percent of decorative props and understory detail visible in the reference. Make snow and simple readable paths the largest uninterrupted shapes. Keep a loose framing of about 16-22 varied snow-covered conifers around the perimeter with clear gaps between trunks and silhouettes, rather than a tightly packed forest wall. Keep only THREE modest rock groups, ONE short fallen log, ONE stump and TWO simple low shrub clumps around the forest edge, well separated by broad unbroken snow. Remove ALL mushrooms, flowers, berry branches, scattered twigs, reed/grasses, loose pebbles, extra saplings, fence fragments and ornamental rune stones. Cottage household props: only ONE small firewood stack and ONE barrel; remove small pots, buckets and tiny wood scraps. Pen: only ONE compact hay bale, simple low rails and the three sheep. Snow clearing should feel spacious and legible; retain two paths through the forest, render each as a simple broad gently bending band of slightly darker compacted snow, with only 4-6 large widely spaced stone steps near the doorway. Remove extensive broken stone paving and crack networks.

TEXTURE SIMPLIFICATION: Keep the output image sharp and professionally finished at full resolution, but reduce texture frequency and painted detail by about 70 percent. Use LARGE CLEAN COLOR MASSES with a small number of broad hand-painted gradients and broad deliberate edge highlights. Snow is quiet lavender surfaces with soft wide cool shadow shapes, no pebbled/mosaic/confetti pattern, no speckles or tiny brush chips. Tree foliage is 4-5 large folded drooping tier masses per tree with simplified gently serrated outlines, broad dark teal/green faces and simple snow caps; no individually painted needles, no hundreds of jagged tips. Rocks are 3-5 major planes and ONE simple broad crack at most, no detailed fracture networks or moss flecks. Wood has large warm brown surfaces and one or two simple curved grain strokes per major prop, no dense woodgrain. Roof retains the recognizable small gabled structure but shingles are FEWER, LARGER shapes, around 4-5 broad rows, thick smooth lavender snow shapes with no tiny irregular chips; foundation stones and chimney blocks have large simple bevelled surfaces and clean joints, no mottling or distressed chips. Walls use fewer broader boards and bold timber joints. Sheep wool is a few broad soft shaped tufts, not fine curls. Use sparse understated broad brushwork to preserve a hand-painted game texture feel. NO smooth glossy plastic or clay material. NO photoreal texture, no pixel art. This is simplified AUTHORED diffuse texture, not a blurred/downsampled version of the original.

VISUAL HIERARCHY: cottage and witch first, sheep pen second, quiet forest framing third. Modest chunky fantasy stylization, clean silhouettes, readable negative space. Preserve the reference's HIGHER camera: lots of roof, top of witch hat, full pen floor visible, walls foreshortened. Do not lower camera or zoom into house. Single full-frame wide landscape environment, roughly 2:1. No text, UI, logos, frame, title or watermark.
```

## 양 개수 보정 프롬프트

```text
Use case: precise-object-edit. Make ONE very small correction to this image. The small wooden sheep pen on the right of the cottage currently contains FOUR sheep. Remove ONLY the LOWEST sheep in the image, the foreground sheep just behind the nearest diagonal front fence rail (the one at approximately x=62%, y=58%). Reconstruct the tiny lavender snow patch beneath it. Keep exactly THREE sheep: the rear sheep near the hay bale, the left middle sheep, and the right middle sheep. Preserve EVERYTHING ELSE exactly: same higher overhead camera, cottage geometry and size, witch, three rock groups, sparse separated trees, two shrubs, one fallen log, one barrel, firewood, hay, fencing, paths, every color, lighting and image framing. Maintain the simplified broad hand-painted texture shapes and low prop density. Do not add any objects or detail, do not increase texture frequency, do not zoom or move camera, do not restyle the image. No text or watermark.
```

