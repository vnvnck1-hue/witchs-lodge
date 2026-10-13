# 숲의 배경색을 접목한 어둠

내장 image_gen 편집 사용. 입력: `05-dark-forest-fog-of-war.png`. 결과: `07-colored-forest-darkness.png`.

중앙의 앰버 조명과 기존 프랍 배치를 유지하고, 주변 어둠에 남색·자주·청록의 낮은 안개와 유색 그림자를 더했다.

## 최종 프롬프트

```text
Use case: lighting-weather.
Input image: edit target, the supplied snowy Witch's Lodge scene.
Primary request: revise ONLY the regional darkness and atmospheric color of the surrounding forest. The current near-black border feels flat. Integrate the existing background colors into the darkness so it has a beautiful fantasy forest mood and game fog-of-war depth.

Preserve the exact camera angle, wide 2:1 framing, cottage, witch, pen with exactly THREE sheep, all existing trees and props, their positions and scales. Preserve the sparse prop density and broad simple painted texture treatment. Do not add trees, extra silhouettes, objects, characters, fine detail or noisy texture.
Keep the cottage, witch and nearby paths readable, with warm amber windows, doorway light and lavender snow.

COLOR AND ATMOSPHERE:
Replace the black edges and neutral dark masking with clearly colored, restrained deep plum-indigo shadows and muted petrol-teal forest pockets. Darkest areas should visibly retain violet or blue-green hue rather than pure black. Carry the existing lavender snow into smoky mauve and dusky periwinkle at the perimeter. Existing foliage has cool desaturated teal planes; its snow caps pick up subdued lilac ambient light. Rock shadow planes remain slate violet.
Use a few large smooth low-lying translucent violet and teal mist masses among the existing tree bases. Irregular gentle world-space falloff, with layered colored depth following the forest groups and both receding paths. Keep the outer forest distinctly darker than the center, mysterious and unexplored, but with readable subdued existing silhouettes. Rich subtle color variation, not uniformly bright blue fog. No neon colors, luminous smoke, bright white fog, opaque curtain or circular black vignette.
Preserve the cozy amber center and low-frequency hand-painted material style; color harmony is plum / indigo / subdued teal / lavender with a small warm amber focal area. Sharp geometry and readable game forms; no depth-of-field blur. No text, UI, logos, watermark or border. Same landscape dimensions as input.
```
