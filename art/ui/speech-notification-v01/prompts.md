# 말풍선 제작 프롬프트 · v01

2026-10-22. 내장 `image_gen` 도구 사용. CLI/API 대체 경로는 사용하지 않았다.
두 호출 모두 `transparent_background: true`. 참고 파일은 읽기 전용 입력이다.

## 몸통

실제 참고 입력:

- `output/guest-speech-simplified-v02/03-speech-only.png` — 목표 모양·색·먹선.
- `godot/assets/ui/moon_runes/extension_v01/widgets.png` — 종이·먹선 화풍.

생성 원본: `drafts/body-generated.png` (1774×887 RGBA).

```text
Use case: ui-mockup. Asset type: production game UI sprite, blank speech bubble BODY ONLY.
Reference image 1 (game screenshot) is the exact target style: the bright cream notification speech balloon next to the goblin portrait on the left. Reference image 2 widgets.png is secondary ink/paper style only. Do NOT reproduce the screenshots.
Create a single isolated empty rounded rectangular speech bubble body, aspect 2:1, intended final 512x256 RGBA. Truly transparent background. Fill nearly all canvas, about 2px outer transparent padding at final resolution. Rounded corners radius ~40px, a bold consistent 7px dark plum ink outline #3A2240. Light cream parchment flat face near #F6E8C6 (reference takes priority), barely perceptible paper fiber; subtle compressed-paper darker inner rim immediately beside outline is okay. Four sides equal stroke. Corner details confined to 48px margins. Interior rectangle x48..464 y48..208 is completely flat, evenly lit, seamless pale cream with NO gradients, mottling or visible features because stretched with a 48px nine-slice.
World: medieval-based fantasy, keeping medieval everyday material atmosphere with fantasy stylization allowed. Restrained hand-inked parchment as in reference.
Absolutely NO TAIL, text, letters, glyphs, arrows, portraits, medallions, decoration, bevel, gold edge, cast shadow, checker pattern or opaque background. Crisp antialiased silhouette without halo. Only the blank rounded cream ink-outlined body.
```

## 왼쪽 꼬리

실제 참고 입력:

- `output/guest-speech-simplified-v02/03-speech-only.png` — 목표 모양·색·먹선.
- 첫 호출의 몸통 생성 PNG — 종이·먹선 일치.

생성 원본: `drafts/tail-generated.png` (1265×1244 RGBA).

```text
Use case: ui-mockup. Asset type: production medieval fantasy parchment UI speech-bubble LEFT TAIL SPRITE only, intended 96x96 RGBA.
Image 1 is exact target style (cream notification balloon next to goblin portrait); image 2 is the just generated blank body, for matching paper/ink. Images are references only.
Create ONE small LEFT-pointing triangular speech bubble tail, truly transparent outside. Use #F6E8C6 near-flat cream paper and ~7px thick #3A2240 dark plum ink matching body. Keep medieval-based fantasy material atmosphere, allowing fantasy stylization. Symmetric above/below horizontal center y48. Tip at x6,y48. Upper sloping edge runs from tip to x60,y24. Lower sloping edge mirrors to x60,y72. From x60 to RIGHT IMAGE EDGE x96, upper/lower edges run HORIZONTALLY at y24/y72, outlined with SAME dark ink. Right side open: NO vertical dark stroke at x60..96. Cream filled interior reaches right image boundary with NO dark end cap, so overlays the body's left border and visually erases it. Think arrow wedge extended to the right by a cream rectangular joining tab, no arrow shaft point at right. Only outer upper and lower contours have ink. The upper and lower strokes run to the right canvas boundary. Background is actual alpha 0, no shadows or opaque background.
NO speech body rectangle, text, letters, arrows inside, portrait, medallion, ornaments, halo, bevel, checkerboard. Centered height, ample transparency above and below. Only one cream left wedge with open right joining tab.
```

## 후처리 기록

인수인계 문서에서 요청한 알파 정리·9분할 평탄화·접합부 정리를 Pillow/NumPy로 수행했다. 생성 결과는 초안으로 보존하고, 최종본에서는 생성 원본의 큰 안쪽 테두리·불균일한 알파·중앙 그러데이션을 제거했다. 40px 둥근 모서리와 7px 먹선을 일정한 기하로 정규화했다. 가운데는 단색으로 처리하고, 먹선의 극미세 명도 변화만 몸통에 남겼다. 꼬리도 생성된 왼쪽 삼각 형태를 96×96 규격과 위아래 대칭에 맞춰 정규화하고 오른쪽 연결 탭의 먹선을 완전히 지웠다.

색은 목표 시안에서 직접 추출했다. 종이색은 글자가 없는 사각형 `(240,325)–(475,342)`의 채널별 중앙값 `#F6E0BA`, 먹선은 `(265,273)` 픽셀 `#3A223D`다. 요청 문서의 대략적인 색보다 실제 시안 샘플을 우선했다. 좌표와 추출법은 `drafts/palette-samples.json`에 기록했다.

재현 코드: `prepare_assets.py`. 원본 수집은 `prepare`, 최종 PNG·시트 재생성은 `build`, 검수는 `verify` 인자다. 코드는 Godot을 실행하지 않는다.

