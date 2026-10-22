# 그라즈 메달 컷아웃 — 실제 생성 프롬프트

2026-10-23 · 내장 `image_gen` · 두 호출 모두 `transparent_background: true` · CLI/API fallback 미사용.

## 01 — 기존 초상과 함께 입력한 첫 편집 (최종 미채택)

입력 순서: `docs/handoff/refs/speech-medal-concept-crop3x.png`, `output/guest-speech-simplified-v02/03-speech-only.png`, `godot/assets/portraits/guest_graz_cutout.png`, `art/concepts/portraits/card-style-v01/bram-card-style-v02.png`.

결과: `drafts/01-generated.png`. 기존 초상의 긴 칼과 얼굴 영향을 받아 미채택.

```text
Use case: identity-preserve / background-extraction.
Asset: transparent full upper-body game portrait for a small circular speech notification medal.
PRIMARY EDIT TARGET: image 1, docs/handoff/refs/speech-medal-concept-crop3x.png. Edit the actual goblin inside this concept medal into an isolated upper-body cutout. Image 2 is the full original concept for exact proportions and colors. Image 3, existing guest_graz_cutout.png, is identity and hidden clothing information ONLY: do NOT copy its smaller helmet, longer face or lower sword/head proportions. Image 4 is approved painted-ink style reference only.
Keep the concept goblin in image 1 EXACTLY recognizable, including pose and relative landmark geometry: large tilted cooking-pot steel helmet with a short horizontal black handle above it; helmet occupies a very large part of head; moss yellow-green skin, short broad cheeky grinning face, big round upward-looking pale eyes, orange-red round nose, two small uneven teeth, messy dark brown hair, long pointed ears extending sideways, earrings, red-orange folded scarf. Face points slightly viewer right. Viewer-left fist holds the short broad steel dagger absolutely in the same almost-vertical diagonal (tip leaning left), with tip higher than the helmet handle. Preserve image 1's compact helmet/face/scarf layout and broad, simple painted planes and black ink contours. Do NOT redesign or replace the expression with image 3's face.
Remove the circular medal/frame, snowy background, speech bubble and every other UI element. Outpaint only hidden shoulders, forearms, remainder of the dagger and chest in the same style. Show full shoulder/arm silhouette, appropriate patched medieval leather clothing, simple steel left shoulder plate, tunic and leather belt to a naturally irregular upper-body lower edge. Keep visible original design and proportions unchanged.
Canvas portrait aspect 1122:1402; leave about 8% clear transparent space over highest point, comfortable transparent side and lower margins. Center the complete silhouette horizontally. True alpha-transparent background, absolutely no frame, circle, backdrop, cast shadow, text or checkerboard drawn into art. Do not render a medal image; render only the unframed goblin and his dagger.
World: medieval-based fantasy, preserving medieval everyday atmosphere while permitting fantasy adaptation. Style: strong tapered black ink, broad light-and-shadow color shapes, restrained painterly print texture, warm ochre highlights, same as image 1; not photorealistic, no excessive speckled texture. The concept target image is the source to preserve, not merely loose inspiration.
```

## 02 — 시안 단독 편집 / 가려진 상반신 보완에 사용

입력: `docs/handoff/refs/speech-medal-concept-crop3x.png` 한 장.

결과: `drafts/02-generated.png`. `build-sheet.ps1 -InputName drafts/02-generated.png -OutputName drafts/02-normalized.png -SheetName drafts/02-comparison.png`으로 정규화한 원본은 `drafts/02-normalized.png`.

```text
Use case: identity-preserve / background-extraction.
EDIT ONLY THE ATTACHED IMAGE. This concept screenshot is the actual source artwork to extract, NOT a loose reference. Preserve the goblin artwork inside the circular medal as faithfully as possible: do not invent a new face, expression, helmet, ears, sword, or camera angle. Remove the circular frame, forest background and speech bubble, and complete the goblin's hidden outer shoulder/arm silhouette. Output ONLY the isolated goblin as a true transparent upper-body cutout.
CRITICAL geometry from 570x510 input, maintain these proportions exactly: sword tip at (151,30), helmet handle top (312,30), helmet dome top (347,54), helmet left rim (226,193), helmet right brim (446,109); left ear outer point about (217,207); right ear point (519,154); face eye pair near (358,180) and (412,166); orange nose (403,198); chin (399,275); scarf spans (286,267) to (484,397). This means the sword tip and the helmet handle top are at almost EXACTLY THE SAME HEIGHT. The blade is short and broad, tilted slightly left, not an extra long sword soaring far above the helmet. The oversized helmet with broad silver band and short handle is tilted left and surrounds the compact head. Preserve the bulging round near-white eyes looking UP, worried eyebrows, compact toothy half-grin with two irregular teeth and dark mouth, broad flat olive-yellow cheeks and long narrow chin/neck, red triangular scarf. Do not use a different goblin portrait.
Keep visible concept pixels/contours, character proportions and colors, expanding only where frame/bubble occludes the shoulder, forearm and lower chest. Extend the hidden viewer-left arm downward holding the dagger, show the simple silver shoulder plate. Extend the leather right shoulder and cloth tunic to upper waist, natural irregular lower edge and fully visible side silhouettes. Do not make body dominate the enlarged head. Similar black ink, flat broad value planes, warm painterly shading and restrained print grain as source. No oversharpened tiny speckles.
Output portrait canvas with exact ratio 1122:1402, complete silhouette horizontally centered, transparent margins around all parts, 8 percent top margin including sword and helmet. No medal, no circle, no drawn checkerboard, no text, no environment, no shadow. True alpha-transparent outside. Medieval-based fantasy, preserving medieval everyday atmosphere while allowing fantasy adaptation.
```

## 최종 후처리 결정

생성본만으로는 귀·턱·칼의 윤곽이 시안과 조금씩 달라졌다. 최종본은 시안의 실제 인물 픽셀을 윤곽 마스크로 분리하고, 틀에 가려졌던 상반신만 02의 생성 결과로 보완했다. 투구 손잡이와 귀걸이 안쪽도 알파로 뚫었다. 원본 메달 내부 가장자리와 겹치는 하단은 원형 전이로 생성 몸통에 연결하고, 지정 틀로 덮이는 범위에서 마감했다.

별도의 생성 호출·모델 변경은 없다. 모든 재구성·알파·배치·검수 합성은 프로젝트 내 `build-sheet.ps1`의 System.Drawing 코드로 재현한다. 실제 시안 픽셀을 살렸으므로 원본의 낮은 디테일도 유지되며, 확대용 새 고해상도 초상으로 재해석하지 않았다.
