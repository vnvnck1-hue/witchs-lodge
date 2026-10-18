# 고기 스튜 v01 · 실제 생성 프롬프트와 납품 처리

2026-10-18 · 내장 `image_gen` 사용. 세 호출 모두 `transparent_background=true`, `referenced_image_paths`로 실제 입력.

## 생성 1

판정: 첫 생성: 원화·문구 양호. 제목이 크고 분류·표식이 여백을 압박하여 미채택.

실제 참고 입력:
- `art/concepts/cards/roles-individual-v02/03-resource-timber.png`
- `godot/assets/cards/raw_meat.png`
- `godot/assets/cards/timber.png`
- `godot/assets/cards/rabbit_pelt.png`

실제 프롬프트:

```text
Use case: stylized-concept.
Create ONE complete upright Korean resource game card, 1024x1536 true 2:3, full card filling the canvas, very slightly rounded rectangular outer corners, actual transparency ONLY outside the outer corners. Opaque purple card stock inside.
Actual reference inputs: Image 1 is the user APPROVED resource timber card, the authoritative frame/layout reference. Image 2 is current raw_meat card, highest priority painting/brush-density/color consistency reference, the ingredient pair of this new card. Images 3 and 4 are current timber and rabbit_pelt resource cards, supporting style references. These are references, not items to print alongside the result.
Preserve the approved resource card's exact structural language: purple stock, thick tapering black ink waves, cream title panel, a simple roughly rectangular broad artwork window, ONE small cream resource badge at the artwork/rules junction, and ONE continuous cream rules panel. No extra drawers, horizontal bands, double ink dividers. Change subject, badge and text only.
IMPORTANT new layout safe areas at 1024x1536: title x110..914 y72..236 reserves TWO lines (use modest approximately 70px bold Korean brush lettering for the actual one-line title, NOT the oversized 120px reference lettering); classification separate centered line y267..307 approximately 38px. Artwork roughly y330..1020. Small badge must end at or above y1120. Continuous cream rules panel x55..970 y1120..1495; clean rules safe area x110..914 y1185..1445 reserves at least FOUR lines, even though this Korean text uses TWO. Rules approximately 43px, 60px line spacing, center the two lines inside this ample area. No ornaments, frame points, ink, objects or dividers inside either text safe area. Leave empty space for longer translations. Keep the original panel silhouettes and simple ink waves.
Print ONLY these exact Korean strings with correct spelling, spaces and middle dot, no quotes:
Title: 고기 스튜
Classification: 자원 · 모닥불 요리
Rules line 1: 켜진 모닥불에서 생고기로 끓입니다.
Rules line 2: 다친 용병의 체력을 회복합니다.
Artwork: winter night in the snowy lodge front courtyard and forest of a medieval-based fantasy world. Familiar fantasy adaptations allowed, while keeping a medieval sense of daily life and atmosphere. A soot-black cast iron cauldron hangs on an iron tripod over an orange wood campfire enclosed by a few stones. Thick brown stew with clearly visible chunky COOKED brown meat and root vegetables, wooden ladle resting on the rim. In the foreground ONE wooden bowl full of stew and a wooden spoon, inviting and substantial, a meal to give to a wounded mercenary. Soft curving white steam above pot and bowl. Cold purple snowy forest and a small warm lodge window in the distance contrast with the warm orange fire. Match raw_meat card's bold black outlines, large clear color masses, painterly printed texture, same brush density; make them read as a pair. No faces. No blood or raw meat. Medieval iron, wood, pottery, cloth only; no cans, modern saucepan or gas flame. The one small resource badge shows ONE simple stew-bowl silhouette, no timber or meat icon. All cauldron/food/fire stay inside the artwork window.
No numbers, percentages, labels, invented text, watermark, board, surrounding scene or comparison sheet. Preserve the card's 2:3 proportions and full outer silhouette.
```

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14f45-5000-77a2-8f44-13b70ab3cc5f\exec-3215995b-4150-4e40-8029-15c895736e97.png`

## 생성 2

판정: 1차 보정: 제목 축소가 부족하고 분류가 제목 안전 영역과 겹쳐 미채택.

실제 참고 입력:
- `C:/Users/vnvnc/.codex/generated_images/01a14f45-5000-77a2-8f44-13b70ab3cc5f/exec-3215995b-4150-4e40-8029-15c895736e97.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/03-resource-timber.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/raw_meat.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/timber.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/rabbit_pelt.png`

실제 프롬프트:

```text
Use case: precise-object-edit. Edit the supplied meat-stew card, preserving its excellent cauldron, fire, foreground wooden bowl, cooked stew, snowy forest, warm lodge window, painterly brush density, exact Korean spelling and purple/black/cream resource-frame style. Reference 2 is the approved resource card for structure. Reference 3 is raw_meat, the primary painting-style reference. References 4 and 5 are current timber and rabbit_pelt, supporting style references. The only problem to fix is safe-area spacing. Output one complete 1024x1536 card.
Make the title "고기 스튜" smaller: about 70 pixels high, centered at y128..198, leaving x110..914 y72..236 available for two 76px-spaced lines. Classification "자원 · 모닥불 요리" must be a distinctly separate line with actual glyph pixels within y267..307, about 38px high. Move the lower border of the cream title panel down to y322, start the artwork near y340 if needed.
Keep the current scene, but the small stew-bowl resource badge must be REDUCED to roughly width200 height105 and moved up: y1005..1110, ending before y1120. Maintain ONE continuous cream rules panel from roughly y1120..1495 with ONE boundary ink curve, no bands or extra dividers. The text safe area x110..914 y1185..1445 must be entirely free of badge/frame/ornaments and hold four 60px lines when needed.
Print the two rules lines at approximately 43px high, with 60px baseline spacing, centered horizontally, positioned around y1240 and y1300:
켜진 모닥불에서 생고기로 끓입니다.
다친 용병의 체력을 회복합니다.
Both must fit within x110..914. Exact text, punctuation and spaces; no extra text or numbers. Preserve ample blank cream space above/below the two rules lines.
Opaque card stock within the full 2:3 card, slightly rounded rectangular outer corners, genuinely transparent ONLY outside the corners. Medieval-based fantasy and everyday medieval iron/wood materials. Do not redraw scene design, add objects, change colors or texture density. Fix only typography scale/placement and badge size/placement.
```

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14f45-5000-77a2-8f44-13b70ab3cc5f\exec-959a4620-467d-4c5b-a41e-6c9a25e3b9ed.png`

## 생성 3

판정: 2차 보정: 제목을 더 줄이고 분류를 아래로, 표식을 축소·상향해 채택.

실제 참고 입력:
- `C:/Users/vnvnc/.codex/generated_images/01a14f45-5000-77a2-8f44-13b70ab3cc5f/exec-959a4620-467d-4c5b-a41e-6c9a25e3b9ed.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/03-resource-timber.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/raw_meat.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/timber.png`
- `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/rabbit_pelt.png`

실제 프롬프트:

```text
Make a very precise layout edit to Image 1. Preserve all the beautiful existing stew scene and exact Korean text, all brushwork, colors, silhouettes and single resource-card structure. Images 2-5 remain approved frame and current card references. 1024x1536 complete card.
1. The top title "고기 스튜" currently is about 95 pixels high. REDUCE IT TO TWO THIRDS ITS CURRENT SIZE, approximately 63 pixels high. Center it horizontally at y=130. Keep ample blank cream space beneath it until y=260; this empty space must allow a second title line in another language.
2. MOVE the classification "자원 · 모닥불 요리" DOWN by 55 pixels, so its center sits at y=286 and it is 35 pixels high. Extend cream title panel down slightly and move its bottom black boundary to y=324 if necessary. The classification must be visibly low in the panel, close to its lower edge, separated from the smaller upper title by a large empty gap.
3. REDUCE the small stew-bowl badge by 20 percent and MOVE IT UP by 35 pixels, fully above y=1120. Preserve the one continuous cream description panel, unchanged text:
켜진 모닥불에서 생고기로 끓입니다.
다친 용병의 체력을 회복합니다.
Keep description within x110..914 y1185..1445 with no ornaments, lines or badge entering.
Do not enlarge text to fill whitespace. Whitespace is intentional for translations: two title lines, four rules lines. Keep the artwork and exact spelling unchanged. Purple opaque stock, slight rounded rectangular corners with true transparency outside only. Medieval fantasy iron tripod, soot-black cauldron, cooked meat and vegetables, wooden bowl/ladle/spoon, snowy purple forest and orange wood fire stay unchanged. NO additional words or numbers. This is only a typography and badge position correction.
```

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14f45-5000-77a2-8f44-13b70ab3cc5f\exec-c89a9030-3eb2-47fa-8aeb-820346102c58.png`

## 보존·후처리·검수

선택된 생성 원본은 `art/cards/meat-stew-v01/meat_stew.png`에 바이트 그대로 보존했다. 초기·1차 보정은 `drafts/`에 보존. 원본 알파는 전체 카드지에 반투명도가 있어 게임용만 내부 alpha=255와 40px 라운드 모서리 알파로 정규화했다. RGB와 인쇄 글자를 수정하거나 다시 그리지 않았다. 손패는 게임용을 LANCZOS로 256×384 축소했다.

제목·분류·설명 2줄은 `output/meat-stew-v01/text-review-1to1.png`와 게임용 원본으로 직접 대조했다. 한국어 인쇄 PNG이며 다국어 런타임 구현은 이번 범위가 아니다. 원본 보존 파일의 반투명 알파와 실사용 파일의 라운드 모서리 검증은 구분한다.

## 글자만 수정 · 2026-10-18

내장 `image_gen` 1회로 생고기 카드의 손글씨 결을 참조한 글자를 생성했다. 생성본의 원화·프레임은 채택하지 않고 글자 먹선만 추출했다. 기존 글자의 먹선과 가장자리만 주변 크림색으로 복원한 뒤 제목·분류·설명 2줄을 원래 패널에 합성했다. 원화·프레임·솥 표식과 기존 알파는 그대로 보존했다. 글꼴 파일은 사용하지 않았다.

실제 참고 입력:
- `godot/assets/cards/meat_stew.png`
- `godot/assets/cards/raw_meat.png`
- `art/concepts/cards/roles-individual-v02/03-resource-timber.png`
- `godot/assets/cards/timber.png`

실제 프롬프트:

```text
Use case: text-localization. Edit ONLY THE LETTERING of Image 1, the meat stew card. Output one complete 1024x1536 RGBA card with its original alpha. Image 2 raw_meat is the highest priority handwriting/letter size/position reference. Image 3 is approved resource timber layout, Image 4 current timber secondary handwriting reference. Keep the exact existing stew artwork, bowl badge, fire, pot, spoon, snowy forest, purple card stock, cream panels, black frame and every non-text element unchanged. No scene redesign; medieval fantasy materials unchanged.
Replace ALL four text lines with confident hand-painted Korean ink brush lettering that looks written by the SAME HAND as raw_meat. Bold organic uneven rounded brush ends and variable stroke widths, slightly irregular living glyph shapes; NOT a computer Gothic font. 
Title exact text: 고기 스튜
Title actual black glyph height about 110px (not tiny), centered horizontally, bounding box roughly x260..764 y85..195. The four Hangul syllables should be as LARGE as raw_meat's three syllables; use wider title not smaller text. Keep within title safe area x110..914 y72..236, no ornament intrusion. Classification goes directly beneath title not bottom border: exact text 자원 · 모닥불 요리 , actual glyph height 42..45px at y215..260 centered x512. Use middle dot ·, not black bullet.
Rules two centered lines, matching raw_meat hand-painted letter forms and actual glyph height 55..60px. Keep same vertical placement as raw_meat: first black glyph top y1235, second y1320 (roughly), both inside x110..914 y1185..1445. Long first sentence can have narrower glyph proportions to fit but maintain glyph HEIGHT. Exact text with punctuation and spacing:
켜진 모닥불에서 생고기로 끓입니다.
다친 용병의 체력을 회복합니다.
Spell carefully 켜 진 / 모 닥 불 에 서 / 생 고 기 로 / 끓 입 니 다 . and 다 친 / 용 병 의 / 체 력 을 / 회 복 합 니 다 .
Keep existing panels large and continuous with room for two title lines / four rules lines in localized variants. Do not add dividing lines, decorations, any new words or numbers. Preserve the rest of Image 1 identically.
```

최초 상대경로 호출은 입력 경로 해석 단계에서 실패해 이미지가 생성되지 않았다. 동일 프롬프트와 참고 이미지의 절대경로로 재호출하여 1장을 생성했다. 가공 전 생성본은 `art/cards/meat-stew-v01/drafts/text-repair-generated.png`, 1차 납품의 원본·게임용·손패용은 `drafts/v1-original.png`, `v1-game.png`, `v1-hand.png`에 보존했다.

최종 먹선 실측(100 미만의 어두운 픽셀 경계): 제목 x304..718 / y85..194, 415×110px; 분류 x352..670 / y215..260, 319×46px; 설명 1행 x166..856 / y1235..1292, 691×58px; 설명 2행 x180..843 / y1320..1377, 664×58px. 분류는 획 가장자리를 포함해 요청 근삿값 40~45px보다 1px 크며, 제목·설명은 요청 범위 안이다. 네 문자열의 철자·띄어쓰기·문장부호를 직접 대조했다.

패널 구조를 그대로 두었으며 제목 2줄·설명 4줄을 위한 빈 영역에 장식이 들어오지 않는다. 현재 큰 한국어 인쇄 문구와 다른 언어의 2줄/4줄 배치는 별도 조판으로 다룬다.

최종 원본은 기존 원본의 비문자 RGB와 알파를 보존한 편집본이다. 게임용은 기존 게임용의 비문자 RGBA를 보존하고 손패용은 같은 결과를 256×384로 축소했다. 전체 비교 시트는 3072×1536이며 세 카드를 각각 1024×1536, 1:1로 배치했다. 재현 코드는 `output/meat-stew-v01/TextRepair.cs`, 생성 기록은 `text-repair-generation.json`, 픽셀 보존과 파일/임포트 검증은 같은 폴더의 `verification.json`에 기록했다.

