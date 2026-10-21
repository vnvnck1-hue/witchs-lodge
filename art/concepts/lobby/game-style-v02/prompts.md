# 로비 차분한 팔레트 v02 · 실제 프롬프트와 처리 기록

제작일: 2026-10-21. 내장 `image_gen` 편집 호출 3회. CLI/API 대체 호출 없음.
편집 분류: `lighting-weather` — 장면 재구성 없이 색만 변경하는 요청.

## 입력과 호출 이력

모든 호출의 첫 입력은 보관된 v01 원본이다. 2번 입력인 승인 환경 원화는 팔레트만 참고한다.
브람 v02는 사전 열람했으며 첫 호출에서만 화풍 유지 확인용으로 함께 입력했다.
중세 기반 판타지의 생활감과 분위기를 유지하면서 판타지적 각색을 허용한다는 기존 세계관을 유지했다.

| 순서 | 입력 1 · 편집 대상 | 추가 입력 | 생성 원본 | 판단 |
| --- | --- | --- | --- | --- |
| 1 | `../game-style-v01/01-story-edge.png` | 환경 승인 원화, 브람 v02 | `drafts/01-story-edge-generated-a.png` | 색 변화 부족, 미세한 얼굴/선 변경으로 최종 직접 사용 제외 |
| 2 | `../game-style-v01/02-winter-inn-window.png` | 환경 승인 원화 | `drafts/02-winter-inn-window-generated-a.png` | 차분한 배색 기준 채택, 생성된 선 자체는 최종에 사용하지 않음 |
| 3 | `../game-style-v01/01-story-edge.png` | 환경 승인 원화 | `drafts/01-story-edge-generated-b.png` | 차분한 배색 기준 채택, 생성된 선 자체는 최종에 사용하지 않음 |

추가 입력의 프로젝트 경로:

- `art/concepts/environment/04-prototype-reference-simplified.png`
- `art/concepts/portraits/card-style-v01/bram-card-style-v02.png`

생성 경로의 공통 폴더: `C:/Users/vnvnc/.codex/generated_images/01a15eb0-b0b0-7d01-b1b7-3f65551a03b4/`

1. `exec-aca6e8d9-42af-491c-932c-75e11bc53511.png`
2. `exec-c31971ac-93d1-425c-9346-7c3e1a326209.png`
3. `exec-9f346c25-5251-4eea-8acb-0c2a19fccb30.png`

각 생성 원본은 1672×941 PNG이며 변형 없이 drafts에 복사했다. 투명 배경 옵션은 false.

## 호출 1 · 01 초기 편집

```text
Use case: lighting-weather (palette-only recolor edit).
Asset: a single complete 1920x1080 landscape PNG game lobby.
Image 1 is the ONLY edit target and immutable drawing/composition master. Image 2 is a PALETTE reference ONLY (restrained purple-indigo snow and small amber lodge lights); do not copy its 3D style or objects. Image 3 is a STYLE-PRESERVATION check ONLY for existing black ink and printed pigment; do not copy its person, face or framing.
PRIMARY REQUEST: Recolor image 1 with a deliberately calm, richly colored limited palette, as if the very same drawing had originally been painted in those pigments. Change COLOR ONLY. Preserve the precise drawing, all faces and expressions, silhouettes, gestures, character identities, props, architecture, framing, positions, scales, ink strokes, 2-3-step value structure, pigment/print texture, typography, UI ornaments and ALL existing writing unchanged. Do not redraw, simplify, rearrange, crop, restyle or add anything. Do not turn it into reference 2 or 3.
PALETTE GROUPS: (1) deep plum / ink-indigo / midnight navy shadow colors, (2) clean bright warm cream and pale lavender / periwinkle snow, (3) restrained soft amber light. Color is still distinct and alive, never gray or muddy. Unify bright teal, red and pure-violet shadow fragments into colored plum-indigo shadow families without blackening them. Shift strong saturated purple cloth toward quiet ink violet/plum, preserving purple identity and strong black ink contrast. Preserve bright clean snow, sky and cream UI space; only soften the strong violet cloud blotches.
HOTSPOTS: keep orange fire, copper hair and ochre clothes recognizable, but repaint them in gentle amber flame, softer burnished auburn/copper hair and quiet ochre fabric. Repaint strident yellow windows and lanterns in soft honey amber with smaller pale-cream cores; keep light alive and visibly warmer than surroundings, concentrate the brightest warm emphasis into one or two focal groups, reduce the bright yellow peripheral spill. Keep light/dark forms crisp, not flattened.
FORBIDDEN: global desaturation, gray overlay, faded low-contrast wash, muddy brown sepia, pale dead shadows, blurred ink, new brushwork, changed faces, changed text, added details or a different scene. The output must look like image 1 with a carefully re-authored COLOR palette, never a washed-out filter.
TEXT: preserve original Korean glyph shapes, coordinates, sizes and wording exactly: "마녀산장", "이어하기", "새로운 이야기", "기록 보관소", "설정", "나가기". No additional text, labels, captions, watermark or border. Preserve existing tiny in-world book markings; do not invent words.
World remains medieval-based fantasy with lived-in medieval atmosphere and fantasy adaptation allowed.
TARGET 01: preserve the exact S-shaped left cast montage, large silver-haired violet-hat witch and sleeping sheep at bottom-left, lantern at extreme left, black cat, three smaller witches and tree face above, snowy lodge and traveler stair at center, large cream title/menu opening at right. Specific color focus: the TOP fire witch's flame/copper hair/yellow clothing and the bright lodge windows; quiet the vivid purple foreground hat and cloak while retaining rich plum-violet color. The far-left lantern and lodge entrance can remain the two restrained warm focal groups. Keep the existing lighting direction and faces unchanged. Return this SINGLE edited lobby only.
```

## 호출 2 · 02 차분한 배색

```text
Use case: lighting-weather, precise COLOR-ONLY palette recolor.
Image 1 is the only edit target. Image 2 supplies ONLY the restrained colored atmosphere, NOT drawing style. Produce one landscape game lobby at 1920x1080 with exactly the drawing, faces, expressions, composition, brush texture, ink and Korean UI of image 1, but a CLEARLY CALMER limited color palette.
The original already has the correct content and style. Its vivid ORANGE/YELLOW lighting and red-violet colors are TOO LOUD. Make the recolor obvious: mute the size and intensity of golden lighting, change the overly orange red hair to soft brownish auburn, yellow clothes to quiet taupe-ochre, bright yellow windows to pale honey cream with muted bronze borders. KEEP LIGHT ALIVE but choose luminous pale warm cream instead of saturated yellow. Keep the lightness contrast crisp and black ink dark.
Rich calm pigments: shadow indigo #31344F, shadow plum #42364F, cloth violet #575174 and #696087, pale lavender #B6B6DB, clean snowy cream #F5EDDB, lit amber #D4B483 with pale cream cores #F8E7BC, quiet auburn #98705D, blue teal #435563. Unify loud green/red/pure-purple shadow colors into plum/navy. Shadows must stay colored, never gray-black dead patches. Preserve clean light snow and sky, pale UI paper and the indigo-violet snowy landscape. Keep the foreground witch unmistakably purple and silver haired.
This is intentional pigment-by-pigment repainting: do NOT merely apply gray/global desaturation/contrast-reducing filter. Do NOT change the composition or figures. Keep all original fine linework and printed grain; no blur, no new detail.
Exact original text and positions/shapes: "마녀산장", "이어하기", "새로운 이야기", "기록 보관소", "설정", "나가기". Preserve all original typographic details. Add no text. No new objects, no changed faces, no new drawing style, no cropping.
Medieval-based fantasy with lived-in medieval atmosphere and fantasy adaptation allowed.
TARGET 02: Keep giant curved wooden window frame, silver-haired witch seated at RIGHT with hand at cheek and cup in other hand, sheep/books at right bottom, dwarf and goblin at LEFT bottom table, three other witches at same positions, snowy lavender exterior, clean cream LEFT title/menu space. Reduce bright orange wall reflections, red/auburn saturation, yellow pot flame and peripheral candles. Keep main table lantern and pot flame as two small soft amber focal groups. Preserve everything except color.
```

## 호출 3 · 01 차분한 배색 재편집

```text
Use case: lighting-weather, precise COLOR-ONLY palette recolor.
Image 1 is the only edit target. Image 2 supplies ONLY the restrained colored atmosphere, NOT drawing style. Produce one landscape game lobby at 1920x1080 with exactly the drawing, faces, expressions, composition, brush texture, ink and Korean UI of image 1, but a CLEARLY CALMER limited color palette.
The original already has the correct content and style. Its vivid ORANGE/YELLOW lighting and red-violet colors are TOO LOUD. Make the recolor obvious: mute the size and intensity of golden lighting, change the overly orange red hair to soft brownish auburn, yellow clothes to quiet taupe-ochre, bright yellow windows to pale honey cream with muted bronze borders. KEEP LIGHT ALIVE but choose luminous pale warm cream instead of saturated yellow. Keep the lightness contrast crisp and black ink dark.
Rich calm pigments: shadow indigo #31344F, shadow plum #42364F, cloth violet #575174 and #696087, pale lavender #B6B6DB, clean snowy cream #F5EDDB, lit amber #D4B483 with pale cream cores #F8E7BC, quiet auburn #98705D, blue teal #435563. Unify loud green/red/pure-purple shadow colors into plum/navy. Shadows must stay colored, never gray-black dead patches. Preserve clean light snow and sky, pale UI paper and the indigo-violet snowy landscape. Keep the foreground witch unmistakably purple and silver haired.
This is intentional pigment-by-pigment repainting: do NOT merely apply gray/global desaturation/contrast-reducing filter. Do NOT change the composition or figures. Keep all original fine linework and printed grain; no blur, no new detail.
Exact original text and positions/shapes: "마녀산장", "이어하기", "새로운 이야기", "기록 보관소", "설정", "나가기". Preserve all original typographic details. Add no text. No new objects, no changed faces, no new drawing style, no cropping.
Medieval-based fantasy with lived-in medieval atmosphere and fantasy adaptation allowed.
TARGET 01: Preserve S-shaped left cast montage, large silver-haired violet-hat witch at bottom-left with sleeping sheep, lantern at extreme left, black cat, three witches above, tree face, snowy lodge/traveler stair at center, cream title/menu space on RIGHT. Concentrate the recolor on the TOP fire witch's flame/copper hair/yellow clothes, yellow lodge windows, purple foreground hat/cloak, teal clothing and red scarf. Keep flame and lantern light pale warm cream/soft amber rather than vivid orange. Preserve exact original drawing and all faces. No shifts or extra elements. Single edited image.
```

## 최종 후처리 — 원본 그림을 보존하는 선택적 팔레트 적용

최종 PNG는 생성 결과를 확대해 납품한 파일이 아니다. 생성 결과의 부드러운 앰버·차분한 의상·보라 그림자를 배색 검토용으로 삼고, 보관된 v01의 **같은 좌표의 원본 픽셀**에 색상군별 조정을 적용했다. 생성 과정의 미세한 얼굴·선 변화를 최종본에 옮기지 않기 위한 처리다.

재현 스크립트: [drafts/prepare-assets.ps1](drafts/prepare-assets.ps1). Windows PowerShell / System.Drawing / C# 사용. 새로 그리기, 재식자, 부분 이미지 붙이기, 리사이즈, 자르기, 좌표 이동, 블러, 대비 축소는 없다.

- 노랑·주황: 원래 채도와 얼굴/불 마녀 영역을 구분해 서로 다른 비율로 완화. 구리색 머리·황토색 옷·불꽃·목재 반사광을 소프트 앰버/오커로 묶는다. 따뜻한 색의 HSL 색상을 29° 또는 39° 방향으로 부분 이동한다.
- 빨강: 350° 방향으로 부분 이동하고 버건디로 정리한다. 고블린의 붉은 두건 정체성은 유지한다.
- 초록·올리브: 약한 조정으로 피부·의상 고유색을 남긴다. 어두운 영역만 인디고 계열과 연결한다.
- 청록: 218° 방향의 블루 틸로 묶고 어두운 영역의 잡색을 남색과 연결한다.
- 남색·설경 파랑: 244° 방향으로 약하게 묶으며 밝은 설경의 채도는 대부분 유지한다.
- 순보라·자주: 265° 방향의 잉크 바이올렛으로 묶는다. 밝기별로 다른 조정량을 적용한다.
- HSL L은 원본 그대로 유지한다. 8비트 저장 반올림에 따른 최대 차이는 1/510이다.
- 가장 짙은 원본 먹선(RGB 최대값 61 이하), 밝은 따뜻한 크림 면, 지정된 제목·메뉴·나가기 영역은 RGB를 그대로 복사한다.
- 얼굴의 온기를 별도로 보호하며, 원본 먹선 근처에서는 색 조정 강도를 부드럽게 줄인다.

이는 전체 채도에 한 숫자를 곱하거나 회색을 덮는 일괄 처리와 다르다. 색상군의 색 방향을 바꾸고, 재질/위치/원래 색의 강도에 따라 다르게 적용한다. 최종 선과 질감의 위치는 원본과 정확히 같다.

## 검수

최종 두 장과 비교 시트를 직접 열어 확인했다. 두 장 모두 1920×1080 RGB PNG. 시트는 3840×2160이며 위 01 / 아래 02, 왼쪽 v01 / 오른쪽 v02다. 추가 캡션을 그림 안에 넣지 않았다.

`마녀산장 / 이어하기 / 새로운 이야기 / 기록 보관소 / 설정 / 나가기`와 선택 표시·밑줄·초승달을 원본 그대로 유지한다. UI 보호 영역의 RGB 불일치는 두 장 모두 0이다. 가장 짙은 먹선 및 밝은 크림 보호 픽셀의 불일치도 각각 0이다. 수치는 [drafts/pixel-qa.json](drafts/pixel-qa.json), 해시·크기는 [manifest.json](manifest.json)에 기록한다.

이번 작업은 v02 폴더와 지정 요청 문서의 마지막 납품 절에만 썼다. 금지 경로·기존 변경은 보존했고 Godot 실행/임포트/내보내기 및 커밋을 하지 않았다.

