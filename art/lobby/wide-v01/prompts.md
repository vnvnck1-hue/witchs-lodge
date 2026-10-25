# 로비 왼쪽 확장 v01 · 실제 생성 기록

2026-10-24. 내장 `image_gen` 편집을 사용한다. 중세 기반 판타지와 승인 원화의 먹선·색면·인쇄 질감을 따른다. 아래 입력은 원본 레이어를 x=720에 붙인 실제 2640×1080 캔버스다. 생성본은 초안이며, 최종 x≥720에는 현재 원본 PNG를 픽셀 그대로 다시 붙인다.

## 1. 인물 왼쪽 이어 그리기

입력: `drafts/lobby_characters-outpaint-target.png` (`lobby_characters.png`를 x=720에 배치, 왼쪽 투명).
`transparent_background=true`.
출력 원본: `drafts/01-characters-imagegen.png`.

```text
Use case: precise-object-edit / outpainting. Edit target: attached 2640x1080 transparent medieval fantasy lobby character layer. The ORIGINAL 1920x1080 artwork starts at x=720, extends to x=2639, and MUST remain at exactly that scale and placement, no cropping/resizing/recentering or restyling. Fill ONLY the missing LEFT 720 pixel strip by naturally continuing the existing cut-off bodies and garments through its edge x720. Original human fur-lined dark forest-green cloak, leather straps and subtle brass fittings continue toward the far left in the upper/middle strip; existing wolf fur mass continues at the very top; existing dwarf shoulder armor and dark leather continue across the lower left, with braid ends only as natural continuations; existing fairy wing extends left near mid-height, with correct same delicate lavender insect membrane. NO NEW faces, heads, people, animals, hands or weapons. No new human silhouettes. Left edge should remain densely filled with large cloak/fur/armor masses and quiet dark plum-indigo shaded cloth so attention stays on ORIGINAL faces. Match EXACT thick tapered black ink contours, broad painterly printed color shapes, same restrained texture, same light, medieval-based fantasy preserving medieval everyday atmosphere with fantasy adaptation. Keep ALL original seven faces, hat, wings, figures and every existing contour unchanged. This is ONE foreground cutout with real alpha transparency outside figures, retaining original right empty transparent area. NO forest/sky/background painted into the character cutout, no text, no frames, no checkerboard. Requested output 2640x1080, seamless continuation precisely at x720.
```


## 2. 배경 왼쪽 이어 그리기

입력: `drafts/lobby_bg-outpaint-target.png`, 왼쪽은 평면 자두색 가이드. `transparent_background=false`.
출력: `drafts/02-background-imagegen.png`.

```text
Use case: precise-object-edit / outpainting. Edit target: attached 2640x1080 medieval-fantasy winter forest background plate, with a flat dark plum placeholder strip on the LEFT x=0..719. Replace ONLY that flat LEFT 720px strip by continuing the snow-laden conifer forest naturally from the boundary at x720. Preserve the existing picture from x720 to x2639 at EXACT original position, scale, and composition; do not crop, zoom or move the lodge, trees or the pale cream mist on the right. The new strip is quiet dark plum/indigo evergreen forest, lavender snow branches, restrained pale winter mist. Fill the entire strip as continuous environment with trees and snow; no flat fill, no seams at x720. No people, no animals, no faces, no bodies, no props, no lettering, logo, symbols, border or watermark. Match existing broad color planes, tapered ink-like marks, painterly printed texture, lavender/periwinkle snow and indigo/plum shaded forest, pale cream glow on the right. Medieval-based fantasy retaining medieval everyday atmosphere with fantasy adaptation; preserve the single original small timber gabled lodge and amber windows on far right. This is a clean opaque background plate behind separately animated foreground portraits. Requested wide landscape output 2640x1080, use entire input canvas, extend left only.
```

## 3. 과장된 날개 확장 수정

첫 합성 확대에서 원본 날개 끝과 길게 생성된 날개의 접속이 부자연스러워 수정했다. 실제 입력은 이 단계의 `lobby_characters_wide.png`이며, 같은 입력을 `drafts/03-wing-correction-input.png`로 재현·보관한다. `transparent_background=true`. 출력: `drafts/03-wing-correction-imagegen.png`.

```text
Use case precise-object-edit. Attached image is a 2640x1080 transparent medieval fantasy foreground cutout. Keep the entire image and composition exactly as supplied except one local correction on LEFT of x720. There is an incorrect enormous extra lavender fairy wing extending across x320..720 at y540..650, visibly meeting the original small lavender wing tip at x720,y560 with a straight vertical discontinuity. REMOVE THIS EXTRA LONG LEFT WING (x320..719), restore the underlying dark green human cloak and its natural folds there, and let the ORIGINAL small wing tip from x720,y560 extend at most 20 pixels to the LEFT to finish as ONE tiny pointed tip at x700,y560. The existing original wing at x>=720 MUST remain unchanged. No long wing in left extension, no second overlapping wing, no vertical seam at x720. Everything else unchanged: all seven original faces and figures, all original clothing, green cloak leather straps and brass fittings, top fur mass, dwarf lower armor. Existing x>=720 pixels should keep exact location scale and appearance. No added faces people animals limbs props or text. Thick tapered black ink, large color planes, restrained print texture, muted plum indigo shadow at far left; medieval-based fantasy retaining medieval atmosphere with fantasy adaptation. Retain true transparent background outside the cutout, no painted backdrop, no checkerboard. Output same full wide 2640x1080 canvas.
```

## 결정적 후처리와 재현

생성본 3장은 각각 1961×802이며 원본 그대로 `drafts/`에 보존했다. 최종화에서 생성본만 2640×1080으로 맞춘다. 첫 인물 생성본의 원본 대조 패치 등록에서는 대체로 x=-4~-6px, y=0px 차이를 확인했다(`alignment-points.json`). 왼쪽 생성 영역을 714px 경계로 추출해 720px로 맞춘다. 두 번째 인물 생성본은 y=460~680 띠에만 사용해 잘못 늘어난 날개를 지우고, 원본 날개 끝의 실제 색을 21px 길이의 작은 끝으로 이어 붙인다. 경계 색 차이는 왼쪽 9px 감쇠 길이로만 정리하고 x≥720에는 원본을 그대로 붙인다. 멀리 왼쪽은 자두·남색 그림자로 살짝 낮추며 x=540 전에 보정이 끝난다. 생성 인물의 알파를 유지하고 투명 RGB는 0으로 정리한다.

생성 도구의 의복 내부 alpha 250~253은 불투명한 인물 영역이 되도록 255로 복원한다. 실루엣의 부분 알파와 바깥 0을 유지한다. 구역 지도는 원본의 정수값을 복사하고 확장 영역에는 인간/가장 가까운 털·천 20, 드워프 160, 원래 날개 끝 220을 최근접 평면 구역으로 붙인다. 배경은 인물 없는 생성 숲을 전 영역에 깔아 인물 이동 뒤에도 빈 곳이 없다.

`drafts/build_wide.py`가 지정 세 `_wide.png`와 검수 그림만 재현하며, `drafts/verify_wide.py`가 저장된 PNG를 다시 읽어 검증한다. Godot를 시작하지 않는다. 필요한 도구는 Python 3, Pillow, NumPy다.

```powershell
& 'C:/Users/vnvnc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' 'art/lobby/wide-v01/drafts/build_wide.py'
& 'C:/Users/vnvnc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' 'art/lobby/wide-v01/drafts/verify_wide.py'
```

