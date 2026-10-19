# 용병 직업 픽토그램 v02 — 실제 생성 프롬프트

- 날짜: 2026-10-19
- 도구: 내장 `image_gen.imagegen`, `transparent_background=true`. 직업당 독립 호출 1회, 총 4회 생성.
- 호출당 참고 이미지 **3장**: 기존 v01 시트, 실제 게임 4배 확대 화면, 해당 직업 v01 PNG. 최대 5장 제한 준수.
- 1번 참고: `godot/screenshots/party-frames/job-pictograms-sheet.png`
- 2번 참고: `godot/screenshots/party-frames/job-badges-v01-ingame-x4.png`
- 3번 참고: `art/ui/job-pictograms-v02/drafts/{직업}.png` (교체 직전 v01 게임 PNG 사본).
- `referenced_image_paths`에는 위 파일의 절대 경로를 전달했다.

## warrior

생성 원본: `art/ui/job-pictograms-v02/warrior-generated.png`

```text
Use case: stylized-concept. Asset type: Witch's Lodge medieval fantasy game job pictogram, single transparent square PNG. Medieval based fantasy with ordinary medieval tools, fantasy stylization allowed. The reference sheet and in-game crop show OLD v01 icons that FAILED at 20 pixels; use only their ink/cream palette and medieval context, NOT their detailed multi-object compositions. Create one extremely simple flat pictogram designed on a 16x16 logical grid, upscaled cleanly. At final 128x128 size the shape must occupy x4..123 and y4..123 (120x120 footprint), tightly filling the square, no broad transparent margins. Very heavy dark brown #2A1A12 outer contours equivalent to 10-12 px at 128. Only 2-3 flat solid color regions: cream #FCE7B0, dark brown #2A1A12, plus specified accent. No texture, shading, gradients, bevels, small marks, ornamental borders, circles, badge background, letters, numbers, captions, watermark. Maximum one broad interior separation. One connected silhouette, immediately recognizable at 16px. True transparent background. Entire object visible inside square.
Subject: One upright broad medieval longsword, point up at top center, broad silver-gray #C9CED6 blade with NO center line. Squat chunky proportions, nearly square bounding box. Large thick horizontal cream crossguard spanning at least 90% of image width, near lower third. Short broad cream grip and simple solid pommel below. Blade is broad, pointed and tall, guard projects widely left and right. No shield or other object.
Input images: 1 old sheet reference; 2 actual use scale reference; 3 old warrior reference. Replace multi-object old design with the specified ONE sword.
```

## hunter

생성 원본: `art/ui/job-pictograms-v02/hunter-generated.png`

```text
Use case: stylized-concept. Asset type: Witch's Lodge medieval fantasy game job pictogram, single transparent square PNG. Medieval based fantasy with ordinary medieval tools, fantasy stylization allowed. The reference sheet and in-game crop show OLD v01 icons that FAILED at 20 pixels; use only their ink/cream palette and medieval context, NOT their detailed multi-object compositions. Create one extremely simple flat pictogram designed on a 16x16 logical grid, upscaled cleanly. At final 128x128 size the shape must occupy x4..123 and y4..123 (120x120 footprint), tightly filling the square, no broad transparent margins. Very heavy dark brown #2A1A12 outer contours equivalent to 10-12 px at 128. Only 2-3 flat solid color regions: cream #FCE7B0, dark brown #2A1A12, plus specified accent. No texture, shading, gradients, bevels, small marks, ornamental borders, circles, badge background, letters, numbers, captions, watermark. Maximum one broad interior separation. One connected silhouette, immediately recognizable at 16px. True transparent background. Entire object visible inside square.
Subject: One chunky loaded bow symbol. Left side is a thick cream semicircular bow curving far to left, joined top and bottom to one straight very thick vertical bowstring slightly right of center: a backward-D body. Bow body at least 18px thick at final 128, string at least 8px. One integrated thick horizontal arrow through center pointing RIGHT, big solid silver-gray #C9CED6 triangular arrowhead at far right. NO fletching, ties, wrapping or thin details. Outer footprint nearly square, bow reaches top and bottom and left, arrow reaches right. Treat loaded bow as one connected symbol.
Input images: 1 old sheet reference; 2 actual use scale reference; 3 old hunter reference. Replace spindly old bow with a bulky upright left-rounded D and right-pointing arrow.
```

## lumberjack

생성 원본: `art/ui/job-pictograms-v02/lumberjack-generated.png`

```text
Use case: stylized-concept. Asset type: Witch's Lodge medieval fantasy game job pictogram, single transparent square PNG. Medieval based fantasy with ordinary medieval tools, fantasy stylization allowed. The reference sheet and in-game crop show OLD v01 icons that FAILED at 20 pixels; use only their ink/cream palette and medieval context, NOT their detailed multi-object compositions. Create one extremely simple flat pictogram designed on a 16x16 logical grid, upscaled cleanly. At final 128x128 size the shape must occupy x4..123 and y4..123 (120x120 footprint), tightly filling the square, no broad transparent margins. Very heavy dark brown #2A1A12 outer contours equivalent to 10-12 px at 128. Only 2-3 flat solid color regions: cream #FCE7B0, dark brown #2A1A12, plus specified accent. No texture, shading, gradients, bevels, small marks, ornamental borders, circles, badge background, letters, numbers, captions, watermark. Maximum one broad interior separation. One connected silhouette, immediately recognizable at 16px. True transparent background. Entire object visible inside square.
Subject: One upright single-bladed medieval woodcutter axe with an ENORMOUS broad crescent-shaped silver-gray #C9CED6 head occupying almost the entire top half and nearly full image width. Single cutting edge facing LEFT with broad convex curve; short blunt back toward right. Very short thick vertical cream handle descending from right-of-center to bottom, at least 24px thick at 128. Exaggerated chunky head-to-handle ratio, one connected object, no wrapping, bands, rivets or wood grain. Not a double axe, no diagonal tilt. Silhouette distinctly asymmetric crescent plus short stem.
Input images: 1 old sheet reference; 2 actual use scale reference; 3 old lumberjack reference. Replace diagonal thin old axe with specified huge upright single head and short broad stem.
```

## gatherer

생성 원본: `art/ui/job-pictograms-v02/gatherer-generated.png`

```text
Use case: stylized-concept. Asset type: Witch's Lodge medieval fantasy game job pictogram, single transparent square PNG. Medieval based fantasy with ordinary medieval tools, fantasy stylization allowed. The reference sheet and in-game crop show OLD v01 icons that FAILED at 20 pixels; use only their ink/cream palette and medieval context, NOT their detailed multi-object compositions. Create one extremely simple flat pictogram designed on a 16x16 logical grid, upscaled cleanly. At final 128x128 size the shape must occupy x4..123 and y4..123 (120x120 footprint), tightly filling the square, no broad transparent margins. Very heavy dark brown #2A1A12 outer contours equivalent to 10-12 px at 128. Only 2-3 flat solid color regions: cream #FCE7B0, dark brown #2A1A12, plus specified accent. No texture, shading, gradients, bevels, small marks, ornamental borders, circles, badge background, letters, numbers, captions, watermark. Maximum one broad interior separation. One connected silhouette, immediately recognizable at 16px. True transparent background. Entire object visible inside square.
Subject: One stout mushroom, giant round red #C8503C umbrella cap occupying top 60% of the image and nearly full width. Wide dome, flat slightly curved bottom edge with blunt rounded corners. One thick short cream #FCE7B0 stalk descending centrally to image bottom, broad rounded base. NO white dots, no gills, no internal lines, no basket, no leaves. Two large flat fill regions plus thick dark outline only. Rounded umbrella silhouette clearly unlike pointed sword or asymmetric axe.
Input images: 1 old sheet reference; 2 actual use scale reference; 3 old gatherer reference. Replace entire basket and leaves composition with just ONE mushroom as specified.
```

## 최종 수작업 보정

요청서가 허용한 후처리로 생성 원본의 주요 윤곽을 직접 베지어 곡선으로 정리했다. `art/ui/job-pictograms-v02/prepare-delivery.ps1`에 재현 가능한 형태와 검증·시트 생성 과정을 보존했다. 생성 원본을 단순 축소한 결과는 아니다.

- 검: 손잡이의 가는 띠 2개를 삭제하고 짧은 손잡이와 넓은 가드를 한 덩어리로 연결했다. 넓은 은회색 날과 크림 손잡이만 남겼다.
- 활: D자 몸통과 굵은 수직 시위·가로 화살을 연결했다. 묶음·깃·가는 선을 없애고 화살촉을 크게 남겼다.
- 도끼: 생성본의 길게 내려온 날을 위쪽으로 압축하고 반달 외곽을 유지했다. 자루를 짧고 굵게 정리하고 날의 하이라이트를 삭제했다.
- 버섯: 큰 붉은 갓과 크림 기둥만 남겼다. 흰 점과 내부 선을 생략했다.
- 외곽은 22px 스트로크 안쪽 절반을 색면으로 덮어 11px의 먹선이 남도록 작업한 뒤 최종 120×120에 맞췄다(최종 약 10px). 크림 `#FCE7B0`, 먹선 `#2A1A12`, 은회색 `#C9CED6` 또는 붉은색 `#C8503C`의 큰 색면 3개와 경계 안티앨리어싱만 사용했다.
- 모든 파일의 비투명 경계 상자를 120×120으로 맞춰 (4,4)에 배치했다. 최종 알파는 후처리 도형을 안티앨리어싱해 다시 만들었다. PNG는 RGBA 128×128이며 모서리 알파는 0이다.
- 시트에서 원본, 실제 16·20·24px 배지, 검정 20px 실루엣, v01/v02 20px 비교, 20px 4배 확대를 직접 확인했다. 배지는 직업별 지정색을 0.65배로 어둡게 했으며 게임 PNG에는 배경 원이 없다.

최종 파일: `godot/assets/ui/jobs/{warrior,hunter,lumberjack,gatherer}.png`, 동일 사본 `art/ui/job-pictograms-v02/{warrior,hunter,lumberjack,gatherer}.png`.

