# 초상 메달 틀 · 생성 프롬프트와 제작 기록

2026-10-22. 기준: [메달 틀 인수인계](../../../docs/handoff/codex-speech-medal-frame-v01.md).

## 제작 방법과 참고 입력

내장 `image_gen`을 사용했다. CLI/API 경로는 사용하지 않았다. 중세 기반 판타지의 목재·놋쇠, 짙은 자두색 먹선과 절제된 질감을 기준으로 삼았다.

1. `docs/handoff/refs/speech-medal-concept-crop3x.png`: 목표 메달의 모양. 인물·칼·배경은 제외.
2. `output/guest-speech-simplified-v02/03-speech-only.png`: 원본 시안의 색과 비율.
3. `godot/assets/ui/moon_runes/common/speech_plain.png`: 같은 알림의 먹선 톤.

세 PNG를 열어 확인한 뒤 실제 참고 이미지 입력으로 전달했다. `godot/screenshots/speech-notification/4-graz-low-crop2x.png`는 현재 구현과의 비교에만 사용했다. `guest_graz_cutout.png`는 합성 미리보기에만 사용하며 원본을 수정하지 않는다.

## 실제 생성 프롬프트

```text
Use case: stylized-concept
Asset type: standalone RGBA portrait medal ring sprite for a medieval fantasy game UI.
Primary request: Recreate ONLY the circular wooden and brass portrait frame from input images 1 and 2, closely matching that exact object, with NO portrait or scene. Medieval-based fantasy, preserving medieval everyday atmosphere with fantasy adaptation permitted.
Input images: Image 1 is the enlarged target concept medal (reference ONLY: remove goblin/sword/portrait/background); image 2 is the complete approved UI concept for palette and proportions; image 3 is the companion speech bubble for dark ink style.
Composition: square canvas, front-facing PERFECTLY CIRCULAR concentric annulus, centered exactly at 50%,50%. Outer diameter 96% canvas width, radial band thickness 10.55% canvas width (11% of outer diameter), inner opening diameter 75% canvas width. Thus at 512px final: outer radius 246px, inner radius 192px, band 54px. Generous completely transparent center hole and 2% transparent margin outside. No perspective or ellipse.
Materials: dark warm brown wooden ring #6B3E22 to #8A5530, with sparse subtle curved wood grain following ring; thin warm brass edging #C98E3E to #E6B860 on BOTH inner and outer edges. Clear nearly black plum ink #2A1A2E outer contour and 2-3px-at-512 inner contour. Match the reference's simple painted/inked game illustration, broad flat color areas and restrained print texture. Wood must remain clearly visible between brass rims.
Hardware: exactly 16 SMALL ROUND BRASS RIVET HEADS, uniformly spaced every 22.5 degrees around the band centerline; rivet diameter about 8px at final 512px canvas. Smooth tiny heads, no black screw slots. No other motifs, no bosses, no logos or markings. Ring middle half remains uncluttered for separately coded timer arc.
Lighting: light, understated two-step shading from upper left toward lower right, illustrated matte brass, NO photorealistic reflections, lens highlights, glow, bevel-heavy 3D render.
Symmetry: circular rotationally symmetric silhouette and regular repeating rivet placement, no top or bottom ornament; gentle upper-left lighting allowed.
Transparency: ACTUAL alpha transparency both inside hole and all outside circle. No background color, no checkerboard painted into image, no drop shadow, no cast shadow or haze.
Text: NONE. No character, face, blade, ribbon, gemstones, wings, handles, lettering, timer arc, arrows, extra objects. Deliver one isolated complete ring only.
```

## 2차 수정 프롬프트

초기 원본의 리벳이 목표보다 커서 같은 생성 도구로 크기와 절제된 나무결을 수정했다. 입력은 1차 생성 PNG 한 장이며 투명 배경을 유지하도록 요청했다.

```text
Use case: precise-object-edit. Edit the provided isolated medieval fantasy portrait ring. Keep its same warm wooden band, thin inner and outer brass edging, dark plum ink style, transparent center and transparent exterior. Preserve 16 round brass rivets, but make each rivet only 45% of its current diameter; each should be a tiny restrained round nail head, about 8px diameter relative to a 512px output canvas. Remove original large rivet extents cleanly and replace with matching subtle wood, leaving just the smaller tiny round rivets. The ring must have perfectly circular concentric silhouette, centered on square canvas, outer diameter96% canvas and inner diameter75% canvas. The 16 tiny rivets must be evenly spaced every22.5 degrees exactly at the radial midpoint of the band, starting top. Keep upper-left gentle light and lower-right gentle shade. Reduce the few large wood cracks to sparse quiet curved grain so the middle half of the band remains calm for a separately drawn timer arc. Flat broad painted color areas, subtle printed texture, dark warm brown wood (#6B3E22 to #8A5530), muted warm brass (#C98E3E to #E6B860), dark ink (#2A1A2E). No ornaments, lettering, portrait, gems, extra objects, reflections, gloss, shadows outside the ring, background or glow. Medieval-based fantasy, preserving medieval everyday atmosphere with fantasy adaptation permitted. Deliver ring only with true alpha transparency inside and outside.
```

## 보관과 후처리

- `frame-drafts/frame-generated.png`: 내장 도구의 1차 생성 원본, 1254×1254 RGBA.
- `frame-drafts/frame-edited.png`: 같은 도구로 리벳을 축소하고 큰 나무 균열을 줄인 2차 원본, 1254×1254 RGBA.
- 생성 세션: `01a163f0-a5a4-76d1-baa5-ce618e40a3a0`. 1차 `exec-901e6f30-5131-476b-a23b-83eed52208fd.png`, 2차 `exec-4ee68709-19f2-4885-b63c-5da1e5608ae5.png`. 프로젝트 내부에 모두 복사했다.
- `frame-drafts/geometry-source.json`: 2차 원본에서 관찰한 리벳 중심 16개. 각도·반지름을 보정하는 기준점이다.
- `prepare_frame.py build`: 생성된 화소를 극좌표로 리샘플링해 동심원과 균등 간격으로 정렬한다. 원본의 알파 경계와 리벳 중심을 기준으로 띠를 반지름 192~246px, 리벳 중심을 반지름 219px로 맞춘다. 생성 그림의 색과 질감을 사용하며 새 나무·금속 그림을 코드로 대체하지 않는다.
- 3배 샘플링으로 축소하고 최종 동심원 알파를 적용했다. 안쪽·바깥쪽은 alpha 0, 투명 화소 RGB도 0이다. 가장자리 안티앨리어싱만 남긴다. 상하 구분 장식 없이 원형 윤곽과 리벳 간격을 정렬하고, 재질과 좌상단 조명은 유지한다.
- `frame-drafts/palette-samples.json`: 시안의 가려지지 않은 아래쪽 테에서 직접 추출한 화소와 좌표. 목재 `#6E3E20`·`#8C572D`, 놋쇠 `#CD8E40`·`#E0AA59`, 외곽의 어두운 먹선 `#212122`을 문서의 대략 색 기준과 대조했다. 생성물은 이 재질의 명암 범위를 가지며 단색으로 평탄화하지 않았다.
- `frame-drafts/portrait-composite.png`: 읽기 전용 그라즈 초상의 얼굴 중심 발췌 `(260,225)-(1010,975)`를 원형으로 자른 미리보기. 초상 원본은 수정하지 않았다. 자두색 원형 받침은 미리보기에만 들어 있다.

## 검수와 적용 경계

최종 게임 PNG에는 틀만 있다. 글자·인물·배경·외부 그림자·타이머 호는 없다. 밝고 어두운 배경의 512px 실물, 초상 합성, 256/128/96px 축소와 시안 발췌를 `frame-sheet.png`에서 대조했다. 원형 기하·알파 및 실제 리벳 하이라이트 16개와 간격을 수치 검사한 결과는 `frame-validation.json`에 있다.

커밋·Godot 실행·임포트·내보내기는 수행하지 않았다. 작성 경로는 요청된 `medal_frame.png`, 이 문서, README의 추가 절과 `frame-*` 산출물, 재현용 `prepare_frame.py`뿐이다. 보호 경로의 별도 변경 관찰은 README의 메달 절과 검수 JSON에 명시하며 되돌리지 않는다.

