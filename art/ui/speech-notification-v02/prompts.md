# 말풍선 v02 · 실제 생성 입력과 후처리

사용 도구: 내장 `image_gen.imagegen` (편집, `transparent_background: true`). API/CLI 대체 생성 없음.
사용 횟수: 1회. 이후 반복은 요청 문서에 명시된 알파·9분할 평탄화·꼬리 접합 후처리와 검수 합성이다.

## 실제 입력

- 편집 대상: `docs/handoff/refs/speech-bubble-concept-crop3x.png`.
- 시각 검토 입력: `speech-notification-concept-crop2x.png`, `speech-chevron-concept-crop6x.png`, `output/guest-speech-simplified-v02/03-speech-only.png`, `godot/screenshots/speech-notification/1-graz-full.png`.
- 이미지 생성 원본: `drafts/01-imagegen-blank-body.png` (2066×761 RGBA).
- 중세 기반 판타지: 따뜻한 양피지·먹선·보라빛 마법적 외곽 빛을 유지한다. 새 장식이나 현대적 재질은 추가하지 않는다.

## 내장 도구에 전달한 실제 프롬프트

```text
Use case: precise-object-edit / background-extraction. Edit target: the supplied approved parchment speech bubble crop for a medieval fantasy game. Produce ONLY the SAME blank speech bubble BODY, isolated with real transparent alpha background. Faithful restoration, not a redesign: preserve exactly the reference cream parchment, subtle tiny fibers/mottling, edge yellow-ochre inner vignette, thick nearly black plum ink contour and thin muted lavender outer halo, hand-painted slightly uneven near-horizontal upper and lower edges, compact softened rectangular corners. Preserve the reference body's long rectangular proportions (approximately 3.6:1) rather than a capsule. Remove ALL Korean text and its shadow completely and reconstruct matching clean parchment in its place. Remove the right chevron and black speck, reconstruct parchment. Remove the left portrait fragment, background, and the projecting left triangular tail; restore the left body edge as continuous smooth near-vertical ink contour, matching the right edge. Keep all four body edges visually the same drawing as reference, with no added flourishes, no distressed tears, no new folds, no large stains, no decorations. The center must be quiet warm fine-grain parchment, no directional marks; all vignette near edges. Show whole body with modest transparent margin, no cropping. No lettering, no arrow, no portrait, no tail. Transparent exterior; lavender halo only within a very narrow band outside ink.
```

## 최종 픽셀 제작 기록

생성본은 시안보다 종이의 큰 음영이 강했다. 생성본을 최종 전체 그림으로 사용하지 않고, 시안 외곽과 생성본의 고주파 미세 결을 결합했다. 가려진 왼쪽 외곽은 깨끗한 오른쪽을 반사 복원했다. 중앙은 시안에서 읽은 종이색 `(246,224,185)`를 기준으로 하고 큰 음영·접힘·방향성 결을 제거했다.

꺾쇠의 먹선 범위는 시안 3배 발췌에서 대략 `x893~925, y154~206`이다. 이를 가로로 넓히지 않고 64×64 안에 분리했다. 꼬리는 왼쪽 삼각형을 유지하고 오른쪽 `x60~95`에 먹선 없는 종이와 접합용 알파를 만들었다.

반복 수정: 외곽 마스크의 단차 제거 → 미세 종이 결 평탄화 → 꼬리의 사각 겹침 흔적 제거 → 꺾쇠 비율 교정 → alpha 0 픽셀의 RGB 0 정리.

실제 알고리즘과 재현 입력은 `drafts/build.cjs`, `drafts/png-tools.cjs`, `drafts/label-sheet.ps1`에 보존했다. 최종 검수 항목은 `validation.json`과 `README.md`를 따른다.
