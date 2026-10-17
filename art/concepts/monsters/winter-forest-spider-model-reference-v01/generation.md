# 겨울 숲 거미 모델링 참고 v01

- 제작일: 2026-10-17
- 도구: 내장 image_gen, 투명 배경 활성화
- 기준: ../winter-forest-spider-v01/winter-forest-spider-v01.png
- 기존 원화와 런타임 자산은 보존.
- 배경 검수: 두 PNG 모두 Format32bppArgb, 8px 간격 알파 샘플 최솟값 0 / 최댓값 255. 실제 투명 배경 확인.
- 시각 검수: 정면·측면·후면 배치와 별도 반측면 전신, 원화의 색상·몸통·송곳니 유지.
- 모델링 참고 한계: 생성형 시안으로 측면에 약간의 반측면 표현이 남고 뷰 사이 다리 가림·무늬에 차이가 있음. 엄밀한 치수 도면이나 정합성이 검증된 3D 투영도는 아님.

| 파일 | 크기 | SHA256 |
| --- | --- | --- |
| winter-spider-three-views-v01.png | 2172×724 | A59B7B9AD8141F88362B15B036C179C7DBA9DBE5FEFB02E2A26595F586A02706 |
| winter-spider-three-quarter-v01.png | 1254×1254 | 473601AEB33F01950AF4E937E5A8A1AA9229B89FF250961EC1AA5AE3D834F291 |

## 3면도 최종 생성 프롬프트

```text
Create a professional orthographic creature turnaround sheet for 3D modeling. Reference image is COLOR AND SHAPE INSPIRATION ONLY. The task is to correct its anatomy into a TRUE EIGHT-LEGGED SPIDER and create three engineering-like orthographic projections, not repeat the reference composition.
Transparent canvas, wide landscape. Three equally sized isolated views, left front / center side / right back. EXACTLY eight legs on the creature = FOUR on the left and FOUR on the right, in addition to two mouth fangs. The number of legs is the highest priority.
FRONT VIEW: four feet visibly spaced on the left, and four feet visibly spaced on the right, no hidden fourth pair. Arrange the four pairs like a clear radial fan, each ending at a different horizontal position. Broad abdomen behind a compact face. Two big pale blue eyes with smaller matching eyes above, two icy curved fangs.
SIDE VIEW: strict true 90 degree lateral orthographic projection, head at far left, abdomen to right. NO visible front plane of the face. Four distinct legs and four distinct feet on the near side, all coming from the thorax beneath/behind the head, not the abdomen. The front-most pair reaches diagonally forwards, two middle pairs reach outward/down, back-most pair reaches backwards. Far side is occluded. Abdomen, thorax and head all in perfect profile with no perspective.
BACK VIEW: show four clearly separated feet on left and four on right. Large spherical abdomen. No face visible.
Creature design: same chunky low-poly hand-painted winter spider as reference. Oversized near-spherical snow-white abdomen with broad muted blue-gray camouflage patches, dark slate indigo armored-looking natural jointed legs, subtle white fur fringe, pale frost on top, dark purple feet tipped cold blue. Basic monster with simple easy-to-model forms. Keep leg lengths and body dimensions consistent in all three views, neutral symmetrical stance, orthographic matching baseline and scale, generous gaps and transparent margins. Crisp clean silhouettes, evenly lit, minimal texture so forms are clear. Not a cinematic illustration.
No background, ground, cast shadows, snow scenery, webs, gradients, checkerboard pixels, panels, labels or text. Actual transparent alpha.
```

## 반측면도 생성 프롬프트

```text
Use case: stylized-concept
Create ONE standalone FRONT THREE-QUARTER VIEW (반측면도) of the SAME winter forest spider shown in the supplied references, for a 3D modeler. Image 1 is the original creature identity reference; image 2 is the turnaround design reference. Preserve the big near-spherical ivory abdomen with broad blue-gray camouflage patches, squat small indigo cephalothorax, icy pale cyan eye cluster, paired thick curved lavender-to-cyan fangs, chunky segmented dark indigo legs with blue tips, subtle white fuzz and thin frost on upper surfaces.
One single creature only, centered, entire body including every foot tip fully visible, generous transparent margin. Front-left three-quarter angle about 45 degrees, slightly elevated camera so the head-to-abdomen connection, leg roots and abdomen volume are clear. Neutral relaxed symmetrical modeling stance. EXACTLY EIGHT walking legs, FOUR ON EACH SIDE, four mirrored pairs joined to the cephalothorax, two separate front fangs. Fan the legs apart enough to show the structure and count them, no merging of adjacent legs. Keep the reference's original proportions and material simplicity, basic monster with no added accessories.
Polished hand-painted stylized 3D concept rendering, clear sculptural volumes, broad color shapes, soft neutral even studio lighting so surface shape is visible without dramatic occlusion. Minimal loose snow to keep joint structure readable. Actual TRANSPARENT ALPHA background, no forest, ground, floor, cast shadow, web, scenery, falling snow, checkerboard pattern, text, labels, frame, duplicate views, comparison layout or watermark. Square high resolution image.
```
