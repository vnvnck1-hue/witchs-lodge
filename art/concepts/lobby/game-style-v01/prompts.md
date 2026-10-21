# 로비 게임 화풍 재제작 · 실제 프롬프트

제작일: 2026-10-21 · 내장 `image_gen` · 편집 분류 `style-transfer` · 불투명 배경.
각 시안은 별도 호출로 1회씩 생성했다. 아래 경로는 프로젝트 루트 기준이다.
참고 입력은 호출당 5장이다. 로비 원본은 배치 기준, 브람 v02·니브·마녀는 화풍 기준, 하랄드는 정체성 기준으로 구분했다.
환경 승인 원화 `art/concepts/environment/04-prototype-reference-simplified.png`도 사전 열람했으며, 5장 제한 때문에 생성 호출에는 넣지 않았다.

## 01 · 이야기의 가장자리

입력 순서:

1. `art/concepts/lobby/reference-composition-v01/01-story-edge.png` — 편집 대상 / 구도 기준.
2. `art/concepts/portraits/card-style-v01/bram-card-style-v02.png` — 먹선·명암·질감.
3. `art/concepts/cards/roles-individual-v02/01-character-nib.png` — 화풍·니브 정체성.
4. `art/portraits/card-style-v01/witch.png` — 보라 의상·천 질감.
5. `art/concepts/characters/dwarf-harald-model-v01/harald-3q-a-v01.png` — 하랄드 정체성.

```text
Use case: style-transfer.
Asset type: finished full-screen medieval fantasy game lobby illustration, landscape 16:9, 1920x1080.
EDIT IMAGE 1. Preserve its exact layout, crop, positions, scale ratios, gestures, architecture silhouettes, negative space and UI typography positions. This is a full repaint of the existing image in the game art style of images 2, 3 and 4, NOT a new composition. Image 1 is ONLY the composition master; its smooth anime aesthetic must be replaced.
Input roles: Image 1 = original lobby 01 edit target. Image 2 = Bram v02, primary style reference for bold tapered black ink, large color planes, 2-3 distinct value steps, printed painterly pigment and expressive anatomical features. Image 3 = Nib card, secondary style and goblin identity only; do not import its card frame or card text. Image 4 = witch portrait, purple textile/pigment and ink treatment only; keep silver hair and huge crooked purple hat of image 1. Image 5 = Harald model, dwarf IDENTITY only; never copy its 3D medium.
LOCK THE COMPOSITION OF IMAGE 1: left/bottom diagonal S-shaped cast montage, big silver-haired purple-hat witch seated at bottom-left with shepherd crook and lantern at far left, sleeping ram at feet, the existing small black cat, teal herb witch at upper-left, smiling copper-haired fire witch above her with flame, black-haired contract witch holding book upper-middle; antlered wooden forest face in top-left dark canopy; warm timber lodge and snowy stair ascending behind them; dwarf, human and goblin travelers at same stair positions and sizes. Keep the right cream opening and title/menu exactly where they are. Do not move heads, enlarge figures, remove buildings, change camera or rearrange objects.
IDENTITY corrections in the same silhouettes: stair dwarf = Harald, bald crown, gray side hair, enormous gray beard braided into TWO thick braids, brown leather workwear, no red beard. Human traveler evokes Bram: rugged mature face, thick brows, brown hair graying at temples, beard, green cloak and leather/metal travel gear. Goblin = Nib: olive-green skin, huge pointed ears, red headscarf/scarf and gold hoop earrings, merchant backpack. Give ALL witches individual expressive non-anime faces: shaped noses, angular cheek planes, characterful eyebrows, natural smaller eyes, no porcelain doll beauty.
REPAINT STYLE decisively: bold irregular tapered near-black contour strokes around faces, hands, hats, sheep, timber and folds, as in Bram and Nib. Broad flat gouache planes and hard 2-3-step shadow groups. Dry-brush printed pigment texture selectively on clothing, wood and faces, with LARGE quiet interiors in color masses. NOT merely a color filter or outline over anime. No delicate anime eyes, no smooth gradients or airbrush. Coarse tangible violet fabric. Exaggerated storybook silhouettes with mature expressive faces.
Palette: restrained plum, violet, indigo/navy shadows; lavender snow; warm cream paper opening; small amber windows/lanterns/flame; very few muted teal accents. Simplify decorative density: remove scattered sparkles, petals, tiny stars, foliage filigree, lace, tiny jewelry and repeated ornamental details. Preserve important lanterns, staff, sheep, book, moon, faces. Snow/trees grouped in a few large shapes, no texture confetti.
Medieval-based fantasy with lived-in medieval wood/stone buildings, wool, leather, iron, lanterns, parchment; fantasy adaptation allowed.
TEXT, verbatim and ONLY these existing Korean words, same positions and sizes as image 1: "마녀산장", "이어하기", "새로운 이야기", "기록 보관소", "설정", "나가기". Keep title crescent, amber crescent by continue and brush underline, bottom-right exit. No English, captions, additional UI, border, labels, watermark or card frame. Single complete landscape screen.
```

생성 파일: `C:/Users/vnvnc/.codex/generated_images/01a15e91-d993-7951-9515-d9584c9a5193/exec-773fa928-84cc-4526-bb9e-710ff87abdb4.png`
프로젝트 보존본: `drafts/01-story-edge-generated.png`.

## 02 · 겨울 산장의 창가

입력 순서:

1. `art/concepts/lobby/reference-composition-v01/02-winter-inn-window.png` — 편집 대상 / 구도 기준.
2. `art/concepts/portraits/card-style-v01/bram-card-style-v02.png` — 먹선·명암·질감.
3. `art/concepts/cards/roles-individual-v02/01-character-nib.png` — 화풍·니브 정체성.
4. `art/portraits/card-style-v01/witch.png` — 보라 의상·천 질감.
5. `art/concepts/characters/dwarf-harald-model-v01/harald-3q-a-v01.png` — 하랄드 정체성.

```text
Use case: style-transfer.
Asset type: single finished full-screen medieval fantasy game lobby illustration, 16:9 landscape, 1920x1080 PNG.
EDIT IMAGE 1, the original winter inn window lobby. Preserve the EXACT composition, framing, scale ratios, body/head/hat silhouettes, object positions, quiet left opening and title/menu locations. Full repaint in the approved game style of images 2, 3 and 4, not a new scene or arrangement. Image 1 supplies layout ONLY, do NOT copy its smooth anime rendering.
Input roles: Image 1 = original lobby 02 edit target and authoritative composition. Image 2 = Bram v02 primary STYLE: heavy tapered black ink contours, broad color planes, definite 2-3-step shadows, printed dry-brush pigment, anatomical character faces. Image 3 = Nib card STYLE and goblin IDENTITY only; do not import card frame/text. Image 4 = witch portrait STYLE for tangible violet cloth, bold contour, pigment planes; keep original silver hair and crooked purple hat, NOT the reference hood. Image 5 = Harald dwarf IDENTITY only, never its 3D rendering.
COMPOSITION LOCK: great curved timber window beam at same center-right location, same snowy branches and cropped ceiling. Huge warm ivory window opening on upper/left half with barely visible lavender snowy forest and distant lodge low down. Upper-left title and menus remain at original coordinates. Main large silver-haired witch seated in the RIGHT foreground, looking LEFT, same massive violet hat silhouette, cheek resting on a hand, teacup in the other, chair, cloak and pose. Sleeping sheep and book stack bottom-right. Bottom curved table at exact same height with the same main small amber lantern, closed spellbook and mugs. At lower LEFT the goblin chats with the dwarf in their existing positions and sizes. Herbal witch in muted teal and copper-haired fire witch work at counter lower-middle/right; black-haired contract witch with book at upper-right gallery. Keep all positions and overlap hierarchy. Do not change camera, mirror composition, shift UI, enlarge figures, add extra characters or ornamental objects.
IDENTITIES WITHIN EXISTING POSITIONS: Lower-left goblin is Nib, olive-green skin, huge pointed ears, RED headscarf and red scarf, GOLD hoop earrings, travel pack. Replace original red-bearded dwarf with Harald: BALD crown, gray side hair, huge GRAY mustache and TWO very thick braided gray beard sections, brown leather work apron. No cap covering bald crown, no red beard. Individual expressive faces for all witches: smaller natural eyes, definite nose bridge and tip, angular cheek planes, strong shaped brows and wry personalities; no identical pretty anime faces or tiny button noses.
STYLE: reproduce heavy irregular tapered dark-ink outlines and broad printed gouache colors of Bram v02/Nib. Sharp silhouette hierarchy, firm two-to-three-step shadows, generous quiet color planes, selective rough dry-brush pigment on purple cloth, leather, wood and faces. Clear chunky shapes for braids, fur and folds. Give faces a hand-inked illustrated game-card identity. This must clearly be a new drawing medium, not merely an outline or texture filter over anime. Do not use airbrush, smooth digital beauty shading, glossy luminous anime eyes, watercolor wash outlines, photo or 3D.
Palette: restrained purple/plum/indigo shadows, cream paper-like opening, lavender snow, very small amber lights and hearth, sparse muted teal. Reduce decorative density: remove scattered sparkles/stars/petals, hanging tiny flower bouquets, jewelry clusters, filigree, repeating snow flecks and tiny clutter. Keep important lantern, books, teacup, sheep, visible character features, broad timber construction and the major moon motif. Detail concentrates on faces and main lantern, background stays simplified.
World: medieval-based fantasy; lived-in medieval wood and stone, wool and leather, metal lanterns and parchment, with fantasy adaptation allowed.
Text verbatim, ONLY existing Korean words at EXACT original positions and matching original size: "마녀산장", "이어하기", "새로운 이야기", "기록 보관소", "설정", "나가기". Title top LEFT; thin line with crescent beneath title; amber diamond selection marker beside continue; exit bottom LEFT. No additional writing anywhere, English, labels, watermark, frame, extra UI or comparison sheet. Preserve legibility and clean cream space.
```

생성 파일: `C:/Users/vnvnc/.codex/generated_images/01a15e91-d993-7951-9515-d9584c9a5193/exec-f02430a8-b03f-4e17-9ddb-fd226104ffa7.png`
프로젝트 보존본: `drafts/02-winter-inn-window-generated.png`.

## 후처리 기록

- 도구 출력은 각각 1672×941 PNG다. 원본 해상도를 `drafts/`에 그대로 복사했다.
- 최종 납품본은 System.Drawing의 HighQualityBicubic으로 1920×1080 RGB PNG로 리샘플링했다. 16:9와의 비율 차이는 약 0.053%로, 자르기 없이 화면 전체를 맞췄다.
- 인물·소품·UI를 별도로 이동하거나 합성하지 않았다. 한글은 생성 결과에서 정확하게 유지되어 폰트 재식자는 필요하지 않았다.
- `sheet.png`는 3840×2160, 왼쪽 원본 / 오른쪽 새 시안, 위 01 / 아래 02다.
- 재현 스크립트: `drafts/prepare-assets.ps1`. 이미지 크기·파일 크기·SHA-256: `manifest.json`.
- 내장 생성 도구만 사용했으며 CLI/API 우회 생성, Godot 실행·임포트·내보내기, 커밋은 하지 않았다.

