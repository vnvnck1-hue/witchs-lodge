# 산장 3면도 v02 — 굴뚝 높이 일치

2026-10-13. 내장 `image_gen` 사용. 수정 대상은 `art/model-sheets/lodge-redesign/01-lodge-three-view-draft.png`다.

## 최종 수정 프롬프트

```text
Use case: precise-object-edit. Input image 1 is the EDIT TARGET: the three-view lodge design sheet. Make ONLY a chimney consistency correction in the MIDDLE RIGHT panel. Preserve the charming cottage design, all three projection angles, front and back panels, building widths/heights, curved roof and timber, snow slab shapes, windows, arched door, stairs, materials, lighting, labels and horizontal guide lines EXACTLY. In the middle RIGHT view, the chimney cap is currently higher than both FRONT and BACK caps. Shorten ONLY the upper chimney by approximately 25 pixels at this sheet's displayed scale so its snow-covered top aligns horizontally with the chimney tops in FRONT and BACK. Keep its width, rear-right roof position, stonework style and roof insertion intact. Remove the stray brown square wooden peg attached to the middle panel's chimney cap: all three views must show a purely stone cap and lavender snow on top, no wood ornament on chimney. Do not move or resize any roof ridge ornaments or the house. The result remains one clean orthographic FRONT / RIGHT / BACK turnaround of the same compact building. No added objects, details, inset views, dimensions, smoke, text, measurements or decorative elements. This is a technical consistency correction, not a redesign.
```
