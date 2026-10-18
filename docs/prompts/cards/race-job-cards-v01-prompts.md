# 종족별 직업 계약 카드 v01 — 실제 생성 프롬프트

2026-10-18 · 내장 `image_gen` 사용 · 20장 개별 생성(최초 20회 + 재생성 7회).

각 호출에 같은 직업의 현재 게임 카드, 승인 인물 카드 니브, 해당 손님 포트레이트를 실제 이미지 입력으로 제공했다. 재생성에는 이 세 입력을 다시 제공하고 직전 초안도 네 번째 입력으로 추가했다. 아래 경로는 호출 당시의 정확한 입력이다. 재생성 당시 `art/cards/races-v01/`에 있던 v01은 현재 `drafts/<race>-<job>-v1.png`에 보존되어 있다.

원본 PNG는 생성 파일을 바이트 그대로 보존한다. 런타임 후처리는 기존 직업 카드의 연결된 크림 패널 외곽을 따라 제목·분류·설명과 패널 배경 RGB 픽셀 복원, 종족당 전투용병 원본의 배지 픽셀 공용화, 카드 내부 알파 255 정규화, 56px 라운드 모서리 알파, 손패용 256×384 비율 유지 축소다. 인물 합성·재채색은 하지 않았다. 생성 원본에는 모서리 외곽 알파가 완성되지 않은 경우가 있으므로 납품 게임용·손패용 PNG로 투명을 확인한다.

[제작 요청서](../../handoff/codex-race-job-cards-v01.md) · [전체 생성 매니페스트](../../../output/race-job-cards-v01/generation-manifest.json) · [검증](../../../output/race-job-cards-v01/verification.json) · [전체 비교 시트](../../../godot/screenshots/race-job-cards/sheet.png)

## dwarf-warrior · harald

- 생성 원본: `art/cards/races-v01/dwarf-warrior.png`
- 게임용: `godot/assets/cards/races/dwarf/warrior.png`
- 손패용: `godot/assets/cards/races/dwarf/hand/warrior.png`
- 인쇄 문구: 전투용병 / 용병 · 전투 계약 / 산장 주변을 정찰합니다. / 적이 오면 검으로 맞섭니다. / 드워프
- 시각 검수: 넓은 대머리·회색 이중 땋은 수염·철제 고리·사슬갑옷·가죽 앞치마를 유지. 검과 둥근 철테 방패로 산장 앞 경계.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/warrior.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_harald_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-665661e6-fa6e-4a68-972d-3e839960361c.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input image 1 is the EXACT current warrior card: edit target and immutable layout/type reference. Input image 2 is APPROVED character Nib: style reference and badge construction, NOT the subject. Input image 3 is Harald's portrait: binding identity reference.
Preserve image 1's purple stock, black tapered ink waves, cream panels, all lettering, typography, frame, art-window silhouette, medallion and nameplate geometry and coordinates. Change ONLY the illustrated person/scene inside its artwork window and the race icon/name. Do not copy the human face or Nib's face. Repaint Harald as the exact same dwarf man as image 3: broad square bald/grey-haired head, heavy brow, calm stubborn eyes, thick grey beard braided into two iron-ring braids, mail over scorched leather apron, copper studs, round iron-rimmed wooden shield. Waist-up, taking guard before a snowy timber lodge, holding a short sword and his shield, wary deliberate appraisal. Copper/stone accents, snowy winter firs and warm lodge windows. Keep medieval daily life and atmosphere, allowing familiar fantasy adaptations; wood, wool, leather and iron, no modern objects. Bold tapered ink, large color shapes, 2-3 shadow levels, painterly printed texture, exactly same illustrator as references.
Race badge: same round bronze medallion and rounded cream nameplate at exact image 1 coordinates; simple gold hammer silhouette inside, label "드워프" below. No human icon. Four dwarf cards will share this badge.
EXACT text only, reproduce input 1's size/position/calligraphic type: title "전투용병"; category "용병 · 전투 계약"; line 1 "산장 주변을 정찰합니다."; line 2 "적이 오면 검으로 맞섭니다."; badge "드워프". No character name, stats, price, symbols or additional text.
Retain full two-line title capacity and continuous four-line rules safe field (x110..914 y1185..1445), no decoration enters. Full rectangular 2:3 card with softly rounded four corners and true transparent alpha ONLY outside corners, no surrounding margin, no checkerboard painted in. One card, no sheet.
```

## dwarf-hunter · brynhild

- 생성 원본: `art/cards/races-v01/dwarf-hunter.png`
- 게임용: `godot/assets/cards/races/dwarf/hunter.png`
- 손패용: `godot/assets/cards/races/dwarf/hand/hunter.png`
- 인쇄 문구: 사냥꾼 / 용병 · 사냥 계약 / 낮에는 토끼와 사슴을 사냥합니다. / 밤에는 활로 산장을 지킵니다. / 드워프
- 시각 검수: 붉은 땋은 머리·호탕한 치아 웃음·늑대 털깃·석궁과 화살통을 유지. 석궁 조준.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/hunter.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_brynhild_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-04b68109-e99a-48fd-ab3f-5fcbdf51a65f.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current hunter card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: brynhild guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Brynhild, a boisterous dwarf huntress, adult, ruddy round face, bright red hair in thick braids pinned up, small healed scar on one cheekbone, wide grin showing a gap tooth. Wolf-pelt collar over a rust-brown quilted coat, crossbow slung over her shoulder with the stock visible, bolt quiver strap. One fist on hip, other hand holding up a coin as if offering a bet. Expression: loud confident challenge.
Action overrides static portrait gesture: actively hunting in winter woods with the character's bow, crossbow, throwing spear or snare; weapon and distinctive hunting gear visible, no gore. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. copper and stone accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold hammer silhouette in medallion; label "드워프" below. NOT a human icon. All four dwarf cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "사냥꾼"; classification "용병 · 사냥 계약"; rules line 1 "낮에는 토끼와 사슴을 사냥합니다."; line 2 "밤에는 활로 산장을 지킵니다."; race "드워프". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## dwarf-lumberjack · thorgrim

- 생성 원본: `art/cards/races-v01/dwarf-lumberjack.png`
- 게임용: `godot/assets/cards/races/dwarf/lumberjack.png`
- 손패용: `godot/assets/cards/races/dwarf/hand/lumberjack.png`
- 인쇄 문구: 나무꾼 / 용병 · 벌목 계약 / 나무에 사용하면 벌목합니다. / 목재를 들고 있다가 건네줍니다. / 드워프
- 시각 검수: 검은 톱밥 수염·좁은 눈·회색 조끼·자와 끌 도구를 유지. 양손 도끼로 벌목.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/lumberjack.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_thorgrim_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-657d8d2e-40d0-461d-a7cd-a68813a8c5b7.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current lumberjack card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: thorgrim guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Thorgrim, a meticulous dwarf timber-carpenter turned lumberjack, middle age, long black beard dusted with sawdust, narrowed measuring eyes, lined forehead. Thick grey wool vest, rolled sleeves, belt with folding rule, chisel and a small hatchet handle. Hands holding a short plank up to his eye, sighting along its grain. Expression: quiet professional scrutiny, mouth a flat line.
Action overrides static portrait gesture: actively cutting a tree/branch with the character's axe or saw, inspecting timber grain; clearly show the tool in both hands and snowy wood. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. copper and stone accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold hammer silhouette in medallion; label "드워프" below. NOT a human icon. All four dwarf cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "나무꾼"; classification "용병 · 벌목 계약"; rules line 1 "나무에 사용하면 벌목합니다."; line 2 "목재를 들고 있다가 건네줍니다."; race "드워프". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## dwarf-gatherer · durga

- 생성 원본: `art/cards/races-v01/dwarf-gatherer.png`
- 게임용: `godot/assets/cards/races/dwarf/gatherer.png`
- 손패용: `godot/assets/cards/races/dwarf/hand/gatherer.png`
- 인쇄 문구: 채집가 / 용병 · 채집 계약 / 낮에 숲을 탐색하고 돌아옵니다. / 쓸모 있는 것을 주워 옵니다. / 드워프
- 시각 검수: 흰 올림머리·안경 사슬·뼈 비녀·녹색 숄·광석 주머니·바구니. 버섯을 들어 감별.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/gatherer.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_durga_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-59ec5807-1983-45dc-ba02-267972cfd7c4.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current gatherer card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: durga guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Durga, an elderly dwarf woman gatherer, deeply wrinkled kind-grumpy face, white hair in a tight bun with a bone pin, thick round spectacles on a nose chain, pursed mouth. Dark green shawl over a patched ochre dress, moss basket on one arm, small ore pouch at her belt, lantern hook. One hand raised wagging a finger mid-scold while the other clutches the basket. Expression: scolding but warm.
Action overrides static portrait gesture: actively gathering mushrooms, herbs, roots or seeds in winter woods with the character's basket or pouches and one hand selecting a find. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. copper and stone accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold hammer silhouette in medallion; label "드워프" below. NOT a human icon. All four dwarf cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "채집가"; classification "용병 · 채집 계약"; rules line 1 "낮에 숲을 탐색하고 돌아옵니다."; line 2 "쓸모 있는 것을 주워 옵니다."; race "드워프". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## fairy-warrior · thistle

- 생성 원본: `art/cards/races-v01/fairy-warrior.png`
- 게임용: `godot/assets/cards/races/fairy/warrior.png`
- 손패용: `godot/assets/cards/races/fairy/hand/warrior.png`
- 인쇄 문구: 전투용병 / 용병 · 전투 계약 / 산장 주변을 정찰합니다. / 적이 오면 검으로 맞섭니다. / 요정
- 시각 검수: 연보라 피부·흰 땋은 머리·더듬이·날개·도토리 투구·엉겅퀴 창. 큰 도토리와 버섯으로 작은 체구 표현.

### v1 · 미채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/warrior.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_thistle_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-27ba4ea4-febf-46e5-92bd-6e3c327b2dfa.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current warrior card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: thistle guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Thistle, a tiny fairy guardian warrior, pale violet skin, sharp proud features, large dark eyes, thin antennae, dragonfly wings folded upright behind. Acorn-cup helmet, armor of overlapping thistle bracts, a long thistle-spine spear held vertically beside the face so its scale reads as a whole plant stem. Posture stiffly formal, chin raised. Expression: grave ceremonial dignity on a small face.
Action overrides static portrait gesture: actively standing guard before a snowy timber lodge with the character's portrait weapon and a shield (Fargh keeps his two-handed sword; Thistle keeps the thistle spear); alert protective waist-up pose. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. pale green and silver accent details. This is a TINY nature fairy; acorns, leaves, mushrooms and plant stems are large relative to the subject to show scale, while the half-body fills the window. Preserve the exact wings/antennae of the portrait.
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold sprouting seed silhouette in medallion; label "요정" below. NOT a human icon. All four fairy cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "전투용병"; classification "용병 · 전투 계약"; rules line 1 "산장 주변을 정찰합니다."; line 2 "적이 오면 검으로 맞섭니다."; race "요정". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

### v2 · 채택

이유: 요정의 작은 체구를 큰 도토리·잎·버섯 비례로 보강. fern은 민들레 씨 복원.

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/warrior.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_thistle_cutout.png`
4. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/cards/races-v01/fairy-warrior.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-21e36c34-9a03-4a23-9bdd-effd29040a83.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current warrior card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: thistle guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Thistle, a tiny fairy guardian warrior, pale violet skin, sharp proud features, large dark eyes, thin antennae, dragonfly wings folded upright behind. Acorn-cup helmet, armor of overlapping thistle bracts, a long thistle-spine spear held vertically beside the face so its scale reads as a whole plant stem. Posture stiffly formal, chin raised. Expression: grave ceremonial dignity on a small face.
Action overrides static portrait gesture: actively standing guard before a snowy timber lodge with the character's portrait weapon and a shield (Fargh keeps his two-handed sword; Thistle keeps the thistle spear); alert protective waist-up pose. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. pale green and silver accent details. This is a TINY nature fairy; acorns, leaves, mushrooms and plant stems are large relative to the subject to show scale, while the half-body fills the window. Preserve the exact wings/antennae of the portrait.
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold sprouting seed silhouette in medallion; label "요정" below. NOT a human icon. All four fairy cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "전투용병"; classification "용병 · 전투 계약"; rules line 1 "산장 주변을 정찰합니다."; line 2 "적이 오면 검으로 맞섭니다."; race "요정". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
PRIORITY REVISION v02: Input 4 is this character's generated card draft, an additional EDIT TARGET. Keep its exact character face, outfit, wings, type and frame, but correct the illustration's SCALE cues. This fairy is palm-sized, not human-sized. Replace the town-scale backdrop with a MACRO view of winter forest floor: a natural acorn or seedpod beside the waist is as big as the fairy's HEAD, an ordinary leaf beside the shoulder is as wide as the entire torso, and snow-capped mushrooms rise to shoulder height. Keep the character HALF BODY filling the artwork window, NOT a distant full-body figure. Background giant plant stems, roots and snowy bark, with only a tiny distant amber lodge glow through the forest. Do not shrink the person in the window. Thistle uses the existing thistle spear and a seed-shell shield, both clearly held while guarding. Exact type and race badge remain unchanged.
```

## fairy-hunter · tilia

- 생성 원본: `art/cards/races-v01/fairy-hunter.png`
- 게임용: `godot/assets/cards/races/fairy/hunter.png`
- 손패용: `godot/assets/cards/races/fairy/hand/hunter.png`
- 인쇄 문구: 사냥꾼 / 용병 · 사냥 계약 / 낮에는 토끼와 사슴을 사냥합니다. / 밤에는 활로 산장을 지킵니다. / 요정
- 시각 검수: 꿀빛 피부·단풍 씨 머리·나방 날개·윙크·단풍잎 망토·나뭇가지 활. 머리보다 큰 도토리 곁에서 조준.

### v1 · 미채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/hunter.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_tilia_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-7b6330b2-5d16-4158-aee3-7952c227380a.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current hunter card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: tilia guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Tilia, a mischievous fairy archer, warm honey-tan skin dotted with freckle-like glowing specks, pointed ears, moth wings patterned brown and cream, hair like loose maple-seed tufts. Maple-leaf cloak, a bow made from a bent twig with a strand of spider-silk, quiver of pine-needle arrows. One eye winking, drawing an arrow lazily. Expression: playful aim, half-smile.
Action overrides static portrait gesture: actively hunting in winter woods with the character's bow, crossbow, throwing spear or snare; weapon and distinctive hunting gear visible, no gore. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. pale green and silver accent details. This is a TINY nature fairy; acorns, leaves, mushrooms and plant stems are large relative to the subject to show scale, while the half-body fills the window. Preserve the exact wings/antennae of the portrait.
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold sprouting seed silhouette in medallion; label "요정" below. NOT a human icon. All four fairy cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "사냥꾼"; classification "용병 · 사냥 계약"; rules line 1 "낮에는 토끼와 사슴을 사냥합니다."; line 2 "밤에는 활로 산장을 지킵니다."; race "요정". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

### v2 · 채택

이유: 요정의 작은 체구를 큰 도토리·잎·버섯 비례로 보강. fern은 민들레 씨 복원.

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/hunter.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_tilia_cutout.png`
4. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/cards/races-v01/fairy-hunter.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-fee1f5b1-d9cb-4265-918c-227dceef4295.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current hunter card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: tilia guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Tilia, a mischievous fairy archer, warm honey-tan skin dotted with freckle-like glowing specks, pointed ears, moth wings patterned brown and cream, hair like loose maple-seed tufts. Maple-leaf cloak, a bow made from a bent twig with a strand of spider-silk, quiver of pine-needle arrows. One eye winking, drawing an arrow lazily. Expression: playful aim, half-smile.
Action overrides static portrait gesture: actively hunting in winter woods with the character's bow, crossbow, throwing spear or snare; weapon and distinctive hunting gear visible, no gore. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. pale green and silver accent details. This is a TINY nature fairy; acorns, leaves, mushrooms and plant stems are large relative to the subject to show scale, while the half-body fills the window. Preserve the exact wings/antennae of the portrait.
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold sprouting seed silhouette in medallion; label "요정" below. NOT a human icon. All four fairy cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "사냥꾼"; classification "용병 · 사냥 계약"; rules line 1 "낮에는 토끼와 사슴을 사냥합니다."; line 2 "밤에는 활로 산장을 지킵니다."; race "요정". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
PRIORITY REVISION v02: Input 4 is this character's generated card draft, an additional EDIT TARGET. Keep its exact character face, outfit, wings, type and frame, but correct the illustration's SCALE cues. This fairy is palm-sized, not human-sized. Replace the town-scale backdrop with a MACRO view of winter forest floor: a natural acorn or seedpod beside the waist is as big as the fairy's HEAD, an ordinary leaf beside the shoulder is as wide as the entire torso, and snow-capped mushrooms rise to shoulder height. Keep the character HALF BODY filling the artwork window, NOT a distant full-body figure. Background giant plant stems, roots and snowy bark, with only a tiny distant amber lodge glow through the forest. Do not shrink the person in the window. Tilia draws the twig bow and pine-needle arrow, keep wink, a head-sized acorn foreground. Exact type and race badge remain unchanged.
```

## fairy-lumberjack · larch

- 생성 원본: `art/cards/races-v01/fairy-lumberjack.png`
- 게임용: `godot/assets/cards/races/fairy/lumberjack.png`
- 손패용: `godot/assets/cards/races/fairy/hand/lumberjack.png`
- 인쇄 문구: 나무꾼 / 용병 · 벌목 계약 / 나무에 사용하면 벌목합니다. / 목재를 들고 있다가 건네줍니다. / 요정
- 시각 검수: 올리브 피부·솔잎 머리·엄격한 눈·청동 곤충 날개·톱과 전지가위. 큰 도토리·버섯 곁에서 가지를 톱질.

### v1 · 미채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/lumberjack.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_larch_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-3280da69-2e6a-49b7-b995-8de92915551e.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current lumberjack card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: larch guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Larch, a stern fairy pruner (lumberjack role), olive-green skin, pine-needle hair swept back, furrowed brow, thin mouth, beetle-shell wing covers in dark bronze. Bark-plate vest, a tiny pruning saw and shears at belt, holding a cut diseased twig up with disapproval. Expression: strict gardener's frown, inspecting.
Action overrides static portrait gesture: actively cutting a tree/branch with the character's axe or saw, inspecting timber grain; clearly show the tool in both hands and snowy wood. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. pale green and silver accent details. This is a TINY nature fairy; acorns, leaves, mushrooms and plant stems are large relative to the subject to show scale, while the half-body fills the window. Preserve the exact wings/antennae of the portrait.
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold sprouting seed silhouette in medallion; label "요정" below. NOT a human icon. All four fairy cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "나무꾼"; classification "용병 · 벌목 계약"; rules line 1 "나무에 사용하면 벌목합니다."; line 2 "목재를 들고 있다가 건네줍니다."; race "요정". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

### v2 · 채택

이유: 요정의 작은 체구를 큰 도토리·잎·버섯 비례로 보강. fern은 민들레 씨 복원.

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/lumberjack.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_larch_cutout.png`
4. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/cards/races-v01/fairy-lumberjack.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-2a4a823b-53bd-429c-b6b3-05979693b741.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current lumberjack card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: larch guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Larch, a stern fairy pruner (lumberjack role), olive-green skin, pine-needle hair swept back, furrowed brow, thin mouth, beetle-shell wing covers in dark bronze. Bark-plate vest, a tiny pruning saw and shears at belt, holding a cut diseased twig up with disapproval. Expression: strict gardener's frown, inspecting.
Action overrides static portrait gesture: actively cutting a tree/branch with the character's axe or saw, inspecting timber grain; clearly show the tool in both hands and snowy wood. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. pale green and silver accent details. This is a TINY nature fairy; acorns, leaves, mushrooms and plant stems are large relative to the subject to show scale, while the half-body fills the window. Preserve the exact wings/antennae of the portrait.
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold sprouting seed silhouette in medallion; label "요정" below. NOT a human icon. All four fairy cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "나무꾼"; classification "용병 · 벌목 계약"; rules line 1 "나무에 사용하면 벌목합니다."; line 2 "목재를 들고 있다가 건네줍니다."; race "요정". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
PRIORITY REVISION v02: Input 4 is this character's generated card draft, an additional EDIT TARGET. Keep its exact character face, outfit, wings, type and frame, but correct the illustration's SCALE cues. This fairy is palm-sized, not human-sized. Replace the town-scale backdrop with a MACRO view of winter forest floor: a natural acorn or seedpod beside the waist is as big as the fairy's HEAD, an ordinary leaf beside the shoulder is as wide as the entire torso, and snow-capped mushrooms rise to shoulder height. Keep the character HALF BODY filling the artwork window, NOT a distant full-body figure. Background giant plant stems, roots and snowy bark, with only a tiny distant amber lodge glow through the forest. Do not shrink the person in the window. Larch cuts a twig with the pruning saw, large fallen leaf and acorn establish palm-size scale. Exact type and race badge remain unchanged.
```

## fairy-gatherer · fern

- 생성 원본: `art/cards/races-v01/fairy-gatherer.png`
- 게임용: `godot/assets/cards/races/fairy/gatherer.png`
- 손패용: `godot/assets/cards/races/fairy/hand/gatherer.png`
- 인쇄 문구: 채집가 / 용병 · 채집 계약 / 낮에 숲을 탐색하고 돌아옵니다. / 쓸모 있는 것을 주워 옵니다. / 요정
- 시각 검수: 연두 피부·고사리 머리·큰 수줍은 눈·맥이 보이는 날개·씨앗 주머니. 큰 민들레 씨와 씨앗 채집.

### v1 · 미채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/gatherer.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_fern_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-56b120cb-5aef-49de-895c-e0696188db17.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current gatherer card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: fern guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Fern, a shy fairy seed gatherer, pale green skin, hair of unfurling fern fronds, very large glossy eyes, translucent veined wings. Seed pouch belt with many small bulging pockets, a single oversized dandelion seed held in both hands close to the chest. Shoulders drawn in, peeking up. Expression: timid curiosity.
Action overrides static portrait gesture: actively gathering mushrooms, herbs, roots or seeds in winter woods with the character's basket or pouches and one hand selecting a find. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. pale green and silver accent details. This is a TINY nature fairy; acorns, leaves, mushrooms and plant stems are large relative to the subject to show scale, while the half-body fills the window. Preserve the exact wings/antennae of the portrait.
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold sprouting seed silhouette in medallion; label "요정" below. NOT a human icon. All four fairy cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "채집가"; classification "용병 · 채집 계약"; rules line 1 "낮에 숲을 탐색하고 돌아옵니다."; line 2 "쓸모 있는 것을 주워 옵니다."; race "요정". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

### v2 · 채택

이유: 요정의 작은 체구를 큰 도토리·잎·버섯 비례로 보강. fern은 민들레 씨 복원.

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/gatherer.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_fern_cutout.png`
4. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/cards/races-v01/fairy-gatherer.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-3b0cf37b-3e6d-4a4b-9403-040c512a1793.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current gatherer card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: fern guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Fern, a shy fairy seed gatherer, pale green skin, hair of unfurling fern fronds, very large glossy eyes, translucent veined wings. Seed pouch belt with many small bulging pockets, a single oversized dandelion seed held in both hands close to the chest. Shoulders drawn in, peeking up. Expression: timid curiosity.
Action overrides static portrait gesture: actively gathering mushrooms, herbs, roots or seeds in winter woods with the character's basket or pouches and one hand selecting a find. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. pale green and silver accent details. This is a TINY nature fairy; acorns, leaves, mushrooms and plant stems are large relative to the subject to show scale, while the half-body fills the window. Preserve the exact wings/antennae of the portrait.
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold sprouting seed silhouette in medallion; label "요정" below. NOT a human icon. All four fairy cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "채집가"; classification "용병 · 채집 계약"; rules line 1 "낮에 숲을 탐색하고 돌아옵니다."; line 2 "쓸모 있는 것을 주워 옵니다."; race "요정". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
PRIORITY REVISION v02: Input 4 is this character's generated card draft, an additional EDIT TARGET. Keep its exact character face, outfit, wings, type and frame, but correct the illustration's SCALE cues. This fairy is palm-sized, not human-sized. Replace the town-scale backdrop with a MACRO view of winter forest floor: a natural acorn or seedpod beside the waist is as big as the fairy's HEAD, an ordinary leaf beside the shoulder is as wide as the entire torso, and snow-capped mushrooms rise to shoulder height. Keep the character HALF BODY filling the artwork window, NOT a distant full-body figure. Background giant plant stems, roots and snowy bark, with only a tiny distant amber lodge glow through the forest. Do not shrink the person in the window. Fern gathers a huge DANDELION SEED, the white fluffy seed parachute as wide as her head, in one hand, seed pouches visible and other hand selecting a seed from a huge dried seedpod. Keep shy eyes and fern-frond hair. Exact type and race badge remain unchanged.
```

## goblin-warrior · graz

- 생성 원본: `art/cards/races-v01/goblin-warrior.png`
- 게임용: `godot/assets/cards/races/goblin/warrior.png`
- 손패용: `godot/assets/cards/races/goblin/hand/warrior.png`
- 인쇄 문구: 전투용병 / 용병 · 전투 계약 / 산장 주변을 정찰합니다. / 적이 오면 검으로 맞섭니다. / 고블린
- 시각 검수: 긴 귀 한쪽 꺾임·냄비 투구·짝짝이 갑옷·긴장한 허세 웃음. 검·방패 경계.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/warrior.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_graz_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-6abc7765-27a9-4367-8d7d-94fb3c8885f3.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current warrior card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: graz guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Graz, a goblin warrior in mismatched scrap armor, mossy green skin, very long ears one bent, big forced brave grin with crooked teeth, nervous darting eyes. Dented cooking-pot helmet, one steel pauldron and one leather pauldron, a chipped shortsword held up in a would-be heroic pose with the other hand hiding behind the back. Expression: bluster covering fear.
Action overrides static portrait gesture: actively standing guard before a snowy timber lodge with the character's portrait weapon and a shield (Fargh keeps his two-handed sword; Thistle keeps the thistle spear); alert protective waist-up pose. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. moss and copper accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold goblin face exactly like Nib medallion silhouette in medallion; label "고블린" below. NOT a human icon. All four goblin cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "전투용병"; classification "용병 · 전투 계약"; rules line 1 "산장 주변을 정찰합니다."; line 2 "적이 오면 검으로 맞섭니다."; race "고블린". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## goblin-hunter · pikl

- 생성 원본: `art/cards/races-v01/goblin-hunter.png`
- 게임용: `godot/assets/cards/races/goblin/hunter.png`
- 손패용: `godot/assets/cards/races/goblin/hand/hunter.png`
- 인쇄 문구: 사냥꾼 / 용병 · 사냥 계약 / 낮에는 토끼와 사슴을 사냥합니다. / 밤에는 활로 산장을 지킵니다. / 고블린
- 시각 검수: 귀덮개 가죽 모자·가늘고 의심하는 눈·끈과 덫. 활 조준과 몸의 덫 장비로 사냥 직업 표현.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/hunter.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_pikl_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-83e402ac-c50e-4d61-b100-94270e23f55d.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current hunter card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: pikl guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Pikl, a goblin trapper hunter, narrow suspicious eyes, thin pursed lips, leather cap with ear flaps for long ears, olive skin. Coils of snare cord and small iron traps hanging from belt and shoulder strap, a knotted tally string held up while counting on the fingers of the other hand. Expression: calculating, lips moving as he counts.
Action overrides static portrait gesture: actively hunting in winter woods with the character's bow, crossbow, throwing spear or snare; weapon and distinctive hunting gear visible, no gore. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. moss and copper accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold goblin face exactly like Nib medallion silhouette in medallion; label "고블린" below. NOT a human icon. All four goblin cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "사냥꾼"; classification "용병 · 사냥 계약"; rules line 1 "낮에는 토끼와 사슴을 사냥합니다."; line 2 "밤에는 활로 산장을 지킵니다."; race "고블린". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## goblin-lumberjack · rusk

- 생성 원본: `art/cards/races-v01/goblin-lumberjack.png`
- 게임용: `godot/assets/cards/races/goblin/lumberjack.png`
- 손패용: `godot/assets/cards/races/goblin/hand/lumberjack.png`
- 인쇄 문구: 나무꾼 / 용병 · 벌목 계약 / 나무에 사용하면 벌목합니다. / 목재를 들고 있다가 건네줍니다. / 고블린
- 시각 검수: 뻗친 톱밥 머리·빠진 이 웃음·긴 귀·등의 톱 세 자루. 별도 톱을 양손으로 잡고 나무 절단.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/lumberjack.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_rusk_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-9143750b-2c16-4749-a3b3-74b3617aa8ec.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current lumberjack card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: rusk guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Rusk, a goblin lumberjack who collects saws, gap-toothed delighted smile, sawdust in bristly hair, long ears, grey-green skin. Three different saws strapped across his back with handles visible above the shoulders, patched vest, hands lovingly polishing a saw blade with a rag. Expression: affectionate pride in tools.
Action overrides static portrait gesture: actively cutting a tree/branch with the character's axe or saw, inspecting timber grain; clearly show the tool in both hands and snowy wood. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. moss and copper accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold goblin face exactly like Nib medallion silhouette in medallion; label "고블린" below. NOT a human icon. All four goblin cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "나무꾼"; classification "용병 · 벌목 계약"; rules line 1 "나무에 사용하면 벌목합니다."; line 2 "목재를 들고 있다가 건네줍니다."; race "고블린". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## goblin-gatherer · tak

- 생성 원본: `art/cards/races-v01/goblin-gatherer.png`
- 게임용: `godot/assets/cards/races/goblin/gatherer.png`
- 손패용: `godot/assets/cards/races/goblin/hand/gatherer.png`
- 인쇄 문구: 채집가 / 용병 · 채집 계약 / 낮에 숲을 탐색하고 돌아옵니다. / 쓸모 있는 것을 주워 옵니다. / 고블린
- 시각 검수: 반짝이는 큰 눈·단추 귀걸이·구슬/숟가락 목걸이·주머니 외투·보석. 바구니와 버섯 채집.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/gatherer.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_tak_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-d6b29a1e-f293-4765-9e76-c61396234983.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current gatherer card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: tak guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Tak, a goblin gatherer of shiny things, large sparkling eyes, long twitchy ears with earrings made of buttons, yellowish-green skin. Coat covered in dozens of small bulging pockets, necklace of glass beads and buttons and a spoon, one hand pulling a glittering pebble from a pocket to show. Expression: bursting curiosity.
Action overrides static portrait gesture: actively gathering mushrooms, herbs, roots or seeds in winter woods with the character's basket or pouches and one hand selecting a find. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. moss and copper accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold goblin face exactly like Nib medallion silhouette in medallion; label "고블린" below. NOT a human icon. All four goblin cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "채집가"; classification "용병 · 채집 계약"; rules line 1 "낮에 숲을 탐색하고 돌아옵니다."; line 2 "쓸모 있는 것을 주워 옵니다."; race "고블린". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## beastfolk-warrior · fargh

- 생성 원본: `art/cards/races-v01/beastfolk-warrior.png`
- 게임용: `godot/assets/cards/races/beastfolk/warrior.png`
- 손패용: `godot/assets/cards/races/beastfolk/hand/warrior.png`
- 인쇄 문구: 전투용병 / 용병 · 전투 계약 / 산장 주변을 정찰합니다. / 적이 오면 검으로 맞섭니다. / 수인
- 시각 검수: 회색 늑대 얼굴·찢긴 귀·주둥이 흉터·호박 눈·털깃 갑옷·끈 목걸이. 양손검을 두 손으로 쥔 경계.

### v1 · 미채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/warrior.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_fargh_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-37131d3b-a665-4d7a-bcc9-722e7d6ad9bd.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current warrior card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: fargh guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Fargh, a wolf beastfolk warrior, grey wolf head with a torn ear and pale muzzle scar, amber eyes, calm closed muzzle. Fur-collared dark leather armor with iron studs, two-handed sword hilt rising over one shoulder, a pack-token of braided cord at the neck. Arms crossed low, standing guard. Expression: silent watchful loyalty.
Action overrides static portrait gesture: actively standing guard before a snowy timber lodge with the character's portrait weapon and a shield (Fargh keeps his two-handed sword; Thistle keeps the thistle spear); alert protective waist-up pose. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. amber and cream accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paw print silhouette in medallion; label "수인" below. NOT a human icon. All four beastfolk cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "전투용병"; classification "용병 · 전투 계약"; rules line 1 "산장 주변을 정찰합니다."; line 2 "적이 오면 검으로 맞섭니다."; race "수인". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

### v2 · 채택

이유: 파르그의 양손검을 뽑아 양손으로 잡는 경계 행동 보강.

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/warrior.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_fargh_cutout.png`
4. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/cards/races-v01/beastfolk-warrior.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-aed3163d-3f4a-426f-8ee2-9645db07b8ec.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current warrior card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: fargh guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Fargh, a wolf beastfolk warrior, grey wolf head with a torn ear and pale muzzle scar, amber eyes, calm closed muzzle. Fur-collared dark leather armor with iron studs, two-handed sword hilt rising over one shoulder, a pack-token of braided cord at the neck. Arms crossed low, standing guard. Expression: silent watchful loyalty.
Action overrides static portrait gesture: actively standing guard before a snowy timber lodge with the character's portrait weapon and a shield (Fargh keeps his two-handed sword; Thistle keeps the thistle spear); alert protective waist-up pose. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. amber and cream accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paw print silhouette in medallion; label "수인" below. NOT a human icon. All four beastfolk cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "전투용병"; classification "용병 · 전투 계약"; rules line 1 "산장 주변을 정찰합니다."; line 2 "적이 오면 검으로 맞섭니다."; race "수인". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
PRIORITY CORRECTION v02: Input 4 is a rejected draft edit target, added to the mandatory three references. Preserve its exact frame, Korean text and character identity, but correct the action/equipment. Fargh must NOT stand with crossed arms and a sheathed sword. He actively guards with his GREAT TWO-HANDED SWORD drawn and gripped firmly in BOTH hands at waist height, its broad blade pointing diagonally upward. Keep his torn wolf ear, pale muzzle scar, amber eyes, grey fur and armor. Any shield hangs at his side or behind him, hands remain on the greatsword.
```

## beastfolk-hunter · saya

- 생성 원본: `art/cards/races-v01/beastfolk-hunter.png`
- 게임용: `godot/assets/cards/races/beastfolk/hunter.png`
- 손패용: `godot/assets/cards/races/beastfolk/hand/hunter.png`
- 인쇄 문구: 사냥꾼 / 용병 · 사냥 계약 / 낮에는 토끼와 사슴을 사냥합니다. / 밤에는 활로 산장을 지킵니다. / 수인
- 시각 검수: 삵의 반점·술귀·수염·녹색 두건·짧은 활·깃털. 겨울 숲에서 화살을 준비한 사냥 자세.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/hunter.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_saya_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-9daa7ad2-a1d5-4bfd-b7f8-8142721d16b8.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current hunter card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: saya guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Saya, a lynx beastfolk huntress, spotted tawny fur, tufted ears, slit pupils reflecting light, short whiskers. Dark green hood pushed back, short recurve bow held low, a small bird-feather fletching tucked in the hood. Head turned slightly as if listening to the dark. Expression: terse, alert, unbothered.
Action overrides static portrait gesture: actively hunting in winter woods with the character's bow, crossbow, throwing spear or snare; weapon and distinctive hunting gear visible, no gore. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. amber and cream accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paw print silhouette in medallion; label "수인" below. NOT a human icon. All four beastfolk cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "사냥꾼"; classification "용병 · 사냥 계약"; rules line 1 "낮에는 토끼와 사슴을 사냥합니다."; line 2 "밤에는 활로 산장을 지킵니다."; race "수인". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## beastfolk-lumberjack · urso

- 생성 원본: `art/cards/races-v01/beastfolk-lumberjack.png`
- 게임용: `godot/assets/cards/races/beastfolk/lumberjack.png`
- 손패용: `godot/assets/cards/races/beastfolk/hand/lumberjack.png`
- 인쇄 문구: 나무꾼 / 용병 · 벌목 계약 / 나무에 사용하면 벌목합니다. / 목재를 들고 있다가 건네줍니다. / 수인
- 시각 검수: 거대한 갈색 곰·졸린 눈과 웃음·양모 외투·꿀단지. 양손 벌목 도끼로 목재 절단.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/lumberjack.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_urso_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-cdb20190-beb4-4f65-9c75-d8633ec72858.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current lumberjack card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: urso guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Urso, a bear beastfolk lumberjack, massive brown bear head and shoulders, small sleepy eyes, soft half-smile. Enormous wool coat straining at the shoulders, a honey jar tied by a cord at the belt, a felling axe resting easily on one shoulder. Scratching behind one ear. Expression: unhurried, amused patience.
Action overrides static portrait gesture: actively cutting a tree/branch with the character's axe or saw, inspecting timber grain; clearly show the tool in both hands and snowy wood. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. amber and cream accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paw print silhouette in medallion; label "수인" below. NOT a human icon. All four beastfolk cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "나무꾼"; classification "용병 · 벌목 계약"; rules line 1 "나무에 사용하면 벌목합니다."; line 2 "목재를 들고 있다가 건네줍니다."; race "수인". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## beastfolk-gatherer · momi

- 생성 원본: `art/cards/races-v01/beastfolk-gatherer.png`
- 게임용: `godot/assets/cards/races/beastfolk/gatherer.png`
- 손패용: `godot/assets/cards/races/beastfolk/hand/gatherer.png`
- 인쇄 문구: 채집가 / 용병 · 채집 계약 / 낮에 숲을 탐색하고 돌아옵니다. / 쓸모 있는 것을 주워 옵니다. / 수인
- 시각 검수: 회갈색 토끼·처진 한 귀·겁 많은 큰 눈·기운 망토·약초 바구니·모종삽. 숲에서 버섯 채집.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/gatherer.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_momi_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-f4af021b-819b-4888-911d-34033b9773e0.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current gatherer card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: momi guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Momi, a rabbit beastfolk gatherer, soft grey-brown fur, one long ear folded down, wide anxious eyes, twitching nose. Patched travel cloak, herb basket hugged tightly to the chest, a tiny digging trowel at the belt. Shoulders hunched, glancing sideways. Expression: nervous but determined.
Action overrides static portrait gesture: actively gathering mushrooms, herbs, roots or seeds in winter woods with the character's basket or pouches and one hand selecting a find. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. amber and cream accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paw print silhouette in medallion; label "수인" below. NOT a human icon. All four beastfolk cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "채집가"; classification "용병 · 채집 계약"; rules line 1 "낮에 숲을 탐색하고 돌아옵니다."; line 2 "쓸모 있는 것을 주워 옵니다."; race "수인". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## orc-warrior · garok

- 생성 원본: `art/cards/races-v01/orc-warrior.png`
- 게임용: `godot/assets/cards/races/orc/warrior.png`
- 손패용: `godot/assets/cards/races/orc/hand/warrior.png`
- 인쇄 문구: 전투용병 / 용병 · 전투 계약 / 산장 주변을 정찰합니다. / 적이 오면 검으로 맞섭니다. / 오크
- 시각 검수: 녹색 피부·상투·짧은 엄니·각진 턱·뼈 맹세 목걸이·붉은 망토·청동 견갑. 검·방패 경계.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/warrior.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_garok_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-ad55024a-7358-4f6d-9468-1b1c23223181.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current warrior card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: garok guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Garok, an orc guard-captain warrior, dark green skin, short lower tusks, square jaw, deliberate heavy-browed eyes, hair in a tight topknot. Layered leather and bronze pauldrons, a bone-bead necklace of oath tokens, a thick cloak. One fist pressed flat over the heart in a vow gesture, other hand on a sheathed broad blade. Expression: solemn, binding promise.
Action overrides static portrait gesture: actively standing guard before a snowy timber lodge with the character's portrait weapon and a shield (Fargh keeps his two-handed sword; Thistle keeps the thistle spear); alert protective waist-up pose. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. red earth and bone accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paired tusks silhouette in medallion; label "오크" below. NOT a human icon. All four orc cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "전투용병"; classification "용병 · 전투 계약"; rules line 1 "산장 주변을 정찰합니다."; line 2 "적이 오면 검으로 맞섭니다."; race "오크". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

## orc-hunter · kranya

- 생성 원본: `art/cards/races-v01/orc-hunter.png`
- 게임용: `godot/assets/cards/races/orc/hunter.png`
- 손패용: `godot/assets/cards/races/orc/hand/hunter.png`
- 인쇄 문구: 사냥꾼 / 용병 · 사냥 계약 / 낮에는 토끼와 사슴을 사냥합니다. / 밤에는 활로 산장을 지킵니다. / 오크
- 시각 검수: 올리브 피부·짐승 이빨을 엮은 긴 땋은 머리·깨진 엄니·자신감 있는 웃음·가죽 조끼·토끼. 투창 사냥.

### v1 · 미채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/hunter.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_kranya_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-b2916d30-82ab-46f3-8137-99b6519eace1.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current hunter card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: kranya guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Kranya, an orc huntress, olive skin, long black braids with animal teeth woven in, one tusk chipped, bright competitive grin. Hide vest with trophy claws, a throwing spear held upright, a brace of hares hanging from her belt. Expression: proud boast, chin up.
Action overrides static portrait gesture: actively hunting in winter woods with the character's bow, crossbow, throwing spear or snare; weapon and distinctive hunting gear visible, no gore. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. red earth and bone accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paired tusks silhouette in medallion; label "오크" below. NOT a human icon. All four orc cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "사냥꾼"; classification "용병 · 사냥 계약"; rules line 1 "낮에는 토끼와 사슴을 사냥합니다."; line 2 "밤에는 활로 산장을 지킵니다."; race "오크". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

### v2 · 채택

이유: 크라냐의 활을 포트레이트의 투창으로 복원.

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/hunter.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_kranya_cutout.png`
4. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/cards/races-v01/orc-hunter.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-fe6d5f52-e193-43a3-ba33-c000650e2fa5.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current hunter card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: kranya guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Kranya, an orc huntress, olive skin, long black braids with animal teeth woven in, one tusk chipped, bright competitive grin. Hide vest with trophy claws, a throwing spear held upright, a brace of hares hanging from her belt. Expression: proud boast, chin up.
Action overrides static portrait gesture: actively hunting in winter woods with the character's bow, crossbow, throwing spear or snare; weapon and distinctive hunting gear visible, no gore. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. red earth and bone accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paired tusks silhouette in medallion; label "오크" below. NOT a human icon. All four orc cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "사냥꾼"; classification "용병 · 사냥 계약"; rules line 1 "낮에는 토끼와 사슴을 사냥합니다."; line 2 "밤에는 활로 산장을 지킵니다."; race "오크". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
PRIORITY CORRECTION v02: Input 4 is a rejected draft edit target, added to the mandatory three references. Preserve its exact frame, Korean text and character identity, but correct the action/equipment. Kranya MUST use the THROWING SPEAR from her portrait. Remove the bow, ALL bowstrings and arrows entirely. Show her right hand holding a straight wooden throwing-spear shaft near her shoulder, elbow drawn back about to throw; a large triangular iron SPEARHEAD visibly attached to that same straight shaft near the top left. Left arm extended for balance. Keep her olive skin, long black braids with animal teeth, chipped tusk, competitive grin, hide vest and brace of hares. No bow.
```

## orc-lumberjack · moga

- 생성 원본: `art/cards/races-v01/orc-lumberjack.png`
- 게임용: `godot/assets/cards/races/orc/lumberjack.png`
- 손패용: `godot/assets/cards/races/orc/hand/lumberjack.png`
- 인쇄 문구: 나무꾼 / 용병 · 벌목 계약 / 나무에 사용하면 벌목합니다. / 목재를 들고 있다가 건네줍니다. / 오크
- 시각 검수: 거구·대머리 붉은 칠·호탕한 웃음·작은 엄니·나무 부적·양모 튜닉. 양날 도끼의 두 날을 모두 보이며 벌목.

### v1 · 미채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/lumberjack.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_moga_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-d8945c53-115a-4d09-af10-68b2cec740ea.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current lumberjack card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: moga guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Moga, a gigantic orc lumberjack, huge shoulders filling the frame, wide joyful gap-toothed laugh, small tusks, bald head with red earth paint stripes. Double-bitted axe across the back, a carved wooden tree charm on a cord, sleeveless wool tunic. Both big hands raised in an apologetic shrug as if saying sorry to a tree. Expression: booming warmth.
Action overrides static portrait gesture: actively cutting a tree/branch with the character's axe or saw, inspecting timber grain; clearly show the tool in both hands and snowy wood. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. red earth and bone accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paired tusks silhouette in medallion; label "오크" below. NOT a human icon. All four orc cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "나무꾼"; classification "용병 · 벌목 계약"; rules line 1 "나무에 사용하면 벌목합니다."; line 2 "목재를 들고 있다가 건네줍니다."; race "오크". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```

### v2 · 채택

이유: 모가의 도끼를 양날이 모두 보이는 양날 도끼로 수정.

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/lumberjack.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_moga_cutout.png`
4. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/cards/races-v01/orc-lumberjack.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-8cebf128-2e34-494e-9a14-78122ef7c293.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current lumberjack card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: moga guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Moga, a gigantic orc lumberjack, huge shoulders filling the frame, wide joyful gap-toothed laugh, small tusks, bald head with red earth paint stripes. Double-bitted axe across the back, a carved wooden tree charm on a cord, sleeveless wool tunic. Both big hands raised in an apologetic shrug as if saying sorry to a tree. Expression: booming warmth.
Action overrides static portrait gesture: actively cutting a tree/branch with the character's axe or saw, inspecting timber grain; clearly show the tool in both hands and snowy wood. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. red earth and bone accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paired tusks silhouette in medallion; label "오크" below. NOT a human icon. All four orc cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "나무꾼"; classification "용병 · 벌목 계약"; rules line 1 "나무에 사용하면 벌목합니다."; line 2 "목재를 들고 있다가 건네줍니다."; race "오크". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
PRIORITY CORRECTION v02: Input 4 is a rejected draft edit target, added to the mandatory three references. Preserve its exact frame, Korean text and character identity, but correct the action/equipment. Moga MUST wield a DOUBLE-BITTED AXE as in his portrait, two large opposing iron cutting edges attached symmetrically to one central haft. The ENTIRE axe head is visible, BOTH opposing crescent blades must be visible with clear space around them and no blade hidden by his body or hands. Both hands grip the haft well below the axe head while he chops snowy timber. Keep bald red-painted head, wide joyful gap-toothed laugh, small tusks, huge shoulders and carved wooden tree-charm necklace.
```

## orc-gatherer · shaga

- 생성 원본: `art/cards/races-v01/orc-gatherer.png`
- 게임용: `godot/assets/cards/races/orc/gatherer.png`
- 손패용: `godot/assets/cards/races/orc/hand/gatherer.png`
- 인쇄 문구: 채집가 / 용병 · 채집 계약 / 낮에 숲을 탐색하고 돌아옵니다. / 쓸모 있는 것을 주워 옵니다. / 오크
- 시각 검수: 재 문양·올리브 회녹색 피부·짧은 엄니·아래로 향한 눈·뿌리/버섯 꾸러미·붉은 망토. 버섯 채집.

### v1 · 채택

이유: initial generation

실제 이미지 입력(순서대로):

1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/cards/gatherer.png`
2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/concepts/cards/roles-individual-v02/01-character-nib.png`
3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/godot/assets/portraits/guest_shaga_cutout.png`

생성 파일: `C:\Users\vnvnc\.codex\generated_images\01a14de5-d596-79b0-893b-12ba637ed89d\exec-51a94536-5e1e-4b90-af5e-6b9685de6907.png`

실제 프롬프트:

```text
Use case: identity-preserve. Asset: ONE finished medieval-fantasy character contract card, upright 1024x1536 RGBA PNG.
Input 1: exact current gatherer card, EDIT TARGET and immutable frame/layout/type reference. Input 2: approved Nib character card, supporting illustration style and badge construction reference ONLY, NOT the character. Input 3: shaga guest portrait, binding identity reference.
Preserve input 1's purple stock, variable-width black ink waves, cream title/class/rules panels, ALL lettering and calligraphic typography, art-window shape, outer frame, badge and nameplate geometry and coordinates. Change ONLY illustration inside the art window and race icon/name. Do not copy input 1's human face or Nib's face. Repaint the SAME person as input 3: preserve face, skin/fur tone, hair, species anatomy, proportions, clothes, accessories and distinctive equipment. Portrait biography: Shaga, a young orc shaman apprentice gatherer, slender for an orc, grey-green skin, ash-drawn white lines across the face, thoughtful downcast eyes, short tusks. Bundles of roots and dried mushrooms tied across the chest, a small clay bowl of ash held in both hands. Expression: quiet concentration, reverence.
Action overrides static portrait gesture: actively gathering mushrooms, herbs, roots or seeds in winter woods with the character's basket or pouches and one hand selecting a find. Half-body to waist, large face and full subject filling artwork window. Winter fir forest and lodge vicinity, warm amber window light and snow. red earth and bone accent details. 
World: medieval-based fantasy, preserve medieval daily-life atmosphere while allowing familiar fantasy adaptations. Wood, wool, leather, iron, bone, no guns, modern objects or plastic. Bold tapered black ink, large color shapes, 2-3 shadow levels and restrained painterly print texture, same illustrator as references.
Badge: same round bronze medallion and small rounded cream race nameplate as input 1, at SAME coordinates. Simple gold paired tusks silhouette in medallion; label "오크" below. NOT a human icon. All four orc cards need the identical race badge.
EXACT printed text, same size/position/type as input 1: title "채집가"; classification "용병 · 채집 계약"; rules line 1 "낮에 숲을 탐색하고 돌아옵니다."; line 2 "쓸모 있는 것을 주워 옵니다."; race "오크". No character name, stats, price, new effects, watermark or other text.
Reserve original full two-line title capacity and clean continuous four-line rules field (text-safe x110..914 y1185..1445). No badge/ornament/divider/frame point inside text fields. One full rectangular 2:3 card, softly rounded four corners, genuine transparent alpha only OUTSIDE rounded corners. No surrounding margin, sheet or painted checkerboard.
```


