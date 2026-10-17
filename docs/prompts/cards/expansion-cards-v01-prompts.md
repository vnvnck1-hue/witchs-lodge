# 볼륨 확장 카드 v01 · 실제 내장 이미지 생성 프롬프트

2026-10-17 · generator: `built-in image_gen` · [제작 기준](../../card-design-guide.md) · [요청서](../../handoff/codex-expansion-cards-v01.md)

카드마다 별도 호출을 사용했다. 모든 호출에 역할별 승인 PNG를 실제 `referenced_image_paths` 입력으로 전달했다. 첫 생성은 같은 역할의 기존 게임 PNG도 화풍 참고로 함께 입력했다. `transparent_background=true`; 코드로 원화·한글·프레임을 그리지 않았다. 아래는 축약하지 않은 실제 호출 문자열이다. 생성 파일·선택 결과와 수정 이력은 [generation-results.json](../../../output/expansion-cards-v01/generation-results.json)에 기록한다. 패키징은 생성 알파를 보존하는 Godot 크롭·Lanczos 정규화만 사용한다.

## moss_bandage · 이끼 붕대

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png` — 승인 역할 포맷
2. `godot/assets/cards/frost_rune.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: skill. Large diamond artwork frame with thick black contour and thin cream inner line. Diamond bottom must end above y1120 and never pierce rules-safe field. No species badge.
SUBJECT: close central view of a witch's hands in medieval wool sleeves wrapping linen bandages padded with fresh green moss around a forearm. A few herb sprigs; gentle green healing light pushes away disintegrating violet erosion stains. Snowy forest and distant warm lodge background. Focus hands and moss inside diamond; no gore.
EXACT TITLE: 이끼 붕대
EXACT CATEGORY: 숲 카드 · 회복과 정화
EXACT RULES:
마녀에게 놓아 체력을 돌봅니다.
침식 카드 한 장을 정화합니다.
```

### 수정 1 · 알파 / 필요한 본문 줄바꿈

참고 입력: 위 역할 승인 PNG + 이 카드의 첫 생성 PNG. 주제·문구·역할 포맷을 보존한다.

```text
Repair the SECOND supplied card image for production. FIRST image is mandatory approved skill layout reference. Preserve SECOND image's complete illustration, Korean title 이끼 붕대, category 숲 카드 · 회복과 정화, and exact rules 마녀에게 놓아 체력을 돌봅니다. / 침식 카드 한 장을 정화합니다. Preserve proportions, diamond frame and clear two-line title/four-line footer space. ONLY fix transparency: current file has erroneous translucent alpha across the whole card including corners. Make the purple subtly rounded rectangular card interior completely OPAQUE (alpha255). Cut ONLY outside the tiny rounded corners to true alpha0, all four extreme corner pixels must be alpha0. Fully opaque side midpoints 16px inset. No checkerboard painted into image. One1024x1536 upright card fills canvas, no external padding. Preserve medieval-based fantasy wool and linen scene. Do not change text or paint any additional content.
```

## resin_torch · 송진 횃불

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png` — 승인 역할 포맷
2. `godot/assets/cards/frost_rune.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: skill. Large diamond artwork frame, thick black contour and thin cream inner line. Bottom point ends above y1120, no species badge.
SUBJECT (Korean scene direction, follow exactly): 송진을 먹인 천을 감은 거친 나무 횃불이 밤 눈밭 위로 던져져 주황 불꽃·불티를 흩뿌린다. 송진 방울이 녹아 떨어진다.
EXACT TITLE: 송진 횃불
EXACT CATEGORY: 숲 카드 · 지속 불길
EXACT RULES:
밤에 땅이나 적에게 던집니다.
잠시 동안 불길이 적을 태웁니다.
```

## firefly_swarm · 반딧불이 떼

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/05-facility-forest-altar.png` — 승인 역할 포맷
2. `godot/assets/cards/ward_lantern.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: facility. Low roof accent above BROAD cream title, architectural posts around art only. No narrow diamond title; no pillars/stones in title or footer safe field.
SUBJECT (Korean scene direction, follow exactly): 코르크 마개를 뺀 낡은 유리병에서 반딧불이 떼가 금빛으로 쏟아져 나와 짙은 안개를 걷어 내는 밤 숲. 시설 포맷의 지붕·기둥은 글칸 밖.
EXACT TITLE: 반딧불이 떼
EXACT CATEGORY: 숲 카드 · 시야
EXACT RULES:
땅에 풀어 안개를 걷어 냅니다.
오늘 밤 전투가 끝나면 흩어집니다.
```

### 수정 1 · 알파 / 필요한 본문 줄바꿈

참고 입력: 위 역할 승인 PNG + 이 카드의 첫 생성 PNG. 주제·문구·역할 포맷을 보존한다.

```text
Correct transparency ONLY in SECOND image, the finished 반딧불이 떼 card. FIRST image is mandatory approved facility format reference. Keep all artwork and Korean lettering unchanged: 반딧불이 떼; 숲 카드 · 시야; 땅에 풀어 안개를 걷어 냅니다.; 오늘 밤 전투가 끝나면 흩어집니다. Preserve wide cream title, low roof and architectural columns, four-line blank-safe footer. Medieval fantasy snowy forest. Preserve 1024x1536, 2:3 rectangular card fills canvas with subtly rounded corners. CRITICAL all FOUR extreme corner pixels must have alpha ZERO (actual transparent cutout, not near-transparent); alpha inside the card body especially center and side midpoints 16px inset must be255. Transparency exists only outside the small rounded rectangle corners. No broad padding, no shadow, no checkerboard paint, no words or shapes outside card.
```

## vine_snare · 덩굴 덫

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png` — 승인 역할 포맷
2. `godot/assets/cards/frost_rune.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: skill. Large diamond artwork frame, thick black contour and thin cream inner line. Bottom point ends above y1120, no species badge.
SUBJECT (Korean scene direction, follow exactly): 눈 덮인 숲 바닥에서 가시 없는 굵은 초록 덩굴이 솟아 그림자 같은 괴물의 발목을 휘감는다. 잔혹하지 않게.
EXACT TITLE: 덩굴 덫
EXACT CATEGORY: 숲 카드 · 속박
EXACT RULES:
밤에 땅이나 적에게 놓습니다.
주변 적을 덩굴로 묶습니다.
```

### 수정 1 · 알파 / 필요한 본문 줄바꿈

참고 입력: 위 역할 승인 PNG + 이 카드의 첫 생성 PNG. 주제·문구·역할 포맷을 보존한다.

```text
Repair SECOND supplied finished 덩굴 덫 card only; FIRST is approved skill frame reference which must be retained. Keep SECOND's illustration and medieval fantasy winter setting, frame, purple stock, cream panels and all exact Korean text unchanged. Title: 덩굴 덫. Category: 숲 카드 · 속박. Rules: 밤에 땅이나 적에게 놓습니다. / 주변 적을 덩굴로 묶습니다.. Fix actual ALPHA: all four extreme corner pixels must be truly TRANSPARENT alpha0. Card interior fully opaque alpha255. Small rounded rectangular silhouette fills whole1024x1536 canvas, side midpoints16px inset opaque255. Do not add outside margins or shadows. Preserve generous two-line title safe field x110..914 y72..236 and four-line rules field x110..914 y1185..1445, no ornament or pointed frame in either field. Keep all words within x110..914; wrap long rules rather than shrink or overflow. No new text/numbers.
```

## winter_firewood · 겨울 장작

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/03-resource-timber.png` — 승인 역할 포맷
2. `godot/assets/cards/timber.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: resource. Broad rectangular art window. ONE small split-firewood pictogram at art/footer boundary ending above y1120. No duplicate horizontal strips or extra compartments; one continuous footer.
SUBJECT (Korean scene direction, follow exactly): 단단히 쪼갠 장작 더미를 가죽 끈으로 묶어 산장 통나무 벽에 기대어 둔 모습. 서리, 약간의 눈. 목재(`timber`)와 구별되도록 쪼갠 단면·끈·겨울 보관 느낌.
EXACT TITLE: 겨울 장작
EXACT CATEGORY: 숲 카드 · 산장 보강
EXACT RULES:
산장에 놓아 벽을 보강합니다.
밤에도 쓸 수 있습니다.
```

## shroud_cloth · 수의

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png` — 승인 역할 포맷
2. `godot/assets/cards/frost_rune.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: skill. Large diamond artwork frame, thick black contour and thin cream inner line. Bottom point ends above y1120, no species badge.
SUBJECT (Korean scene direction, follow exactly): 제단 촛불 앞에 놓인 은빛 자수가 들어간 흰 수의(얇은 천)가 은은히 빛나며 마녀를 감싸듯 펄럭인다. 엄숙하지만 섬뜩하지 않게.
EXACT TITLE: 수의
EXACT CATEGORY: 권능 · 수의의 의식
EXACT RULES:
오늘 밤 마녀와 아군이
치명타를 한 번 버팁니다.
```

## thorn_bind · 가시 속박

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png` — 승인 역할 포맷
2. `godot/assets/cards/frost_rune.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: skill. Large diamond artwork frame, thick black contour and thin cream inner line. Bottom point ends above y1120, no species badge.
SUBJECT (Korean scene direction, follow exactly): 땅에서 검붉은 가시 덩굴이 원형으로 크게 솟아 여러 그림자 괴물을 묶는 강한 마법. 가시의 봉헌(제단 의식)의 권능이므로 보랏빛 룬 원이 함께 빛난다.
EXACT TITLE: 가시 속박
EXACT CATEGORY: 권능 · 가시의 봉헌
EXACT RULES:
밤에 땅이나 적에게 놓습니다.
넓은 범위의 적을 가시로 묶습니다.
```

### 수정 1 · 알파 / 필요한 본문 줄바꿈

참고 입력: 위 역할 승인 PNG + 이 카드의 첫 생성 PNG. 주제·문구·역할 포맷을 보존한다.

```text
Repair SECOND supplied finished 가시 속박 card only; FIRST is approved skill frame reference which must be retained. Keep SECOND's illustration and medieval fantasy winter setting, frame, purple stock, cream panels and all exact Korean text unchanged. Title: 가시 속박. Category: 권능 · 가시의 봉헌. Rules: 밤에 땅이나 적에게 놓습니다. / 넓은 범위의 적을 가시로 묶습니다.. Fix actual ALPHA: all four extreme corner pixels must be truly TRANSPARENT alpha0. Card interior fully opaque alpha255. Small rounded rectangular silhouette fills whole1024x1536 canvas, side midpoints16px inset opaque255. Do not add outside margins or shadows. Preserve generous two-line title safe field x110..914 y72..236 and four-line rules field x110..914 y1185..1445, no ornament or pointed frame in either field. Keep all words within x110..914; wrap long rules rather than shrink or overflow. No new text/numbers.
```

## red_chalice · 붉은 잔

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png` — 승인 역할 포맷
2. `godot/assets/cards/moonlit_charm.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: relic. Tall SHIELD-shaped art window, subject centered vertically. Shield point ends above y1120; clear continuous footer.
SUBJECT (Korean scene direction, follow exactly): 장식된 은·금 성배에 진홍 액체가 담겨 은은한 붉은 빛과 김이 오른다. 방패형 창 안에 세로로. 피를 직접 묘사하지 말고 포도주처럼.
EXACT TITLE: 붉은 잔
EXACT CATEGORY: 권능 · 붉은 만찬
EXACT RULES:
마녀에게 놓습니다.
오늘 밤 마법탄이 체력을 되돌립니다.
```

## hibernation_pelt · 겨울잠 털가죽

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/04-relic-moonlit-charm.png` — 승인 역할 포맷
2. `godot/assets/cards/moonlit_charm.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: relic. Tall SHIELD-shaped art window, subject centered vertically. Shield point ends above y1120; clear continuous footer.
SUBJECT (Korean scene direction, follow exactly): 거대한 짐승(빈 굴의 주인)의 두껍고 회갈색인 털가죽이 산장 지붕·벽 위에 덮인 모습 또는 걸린 전리품. 서리 낀 털, 큰 발톱 하나 정도.
EXACT TITLE: 겨울잠 털가죽
EXACT CATEGORY: 전리품 · 빈 굴의 주인
EXACT RULES:
산장에 덮습니다.
오늘 밤 산장이 받는 피해가 절반입니다.
```

### 수정 1 · 알파 / 필요한 본문 줄바꿈

참고 입력: 위 역할 승인 PNG + 이 카드의 첫 생성 PNG. 주제·문구·역할 포맷을 보존한다.

```text
Repair SECOND supplied finished 겨울잠 털가죽 card only; FIRST is approved relic frame reference which must be retained. Keep SECOND's illustration and medieval fantasy winter setting, frame, purple stock, cream panels and all exact Korean text unchanged. Title: 겨울잠 털가죽. Category: 전리품 · 빈 굴의 주인. Rules: 산장에 덮습니다. / 오늘 밤 산장이 받는 피해가 절반입니다.. 
Footer exact visual line breaks (preserve words):
산장에 덮습니다.
오늘 밤 산장이 받는 피해가
절반입니다.
Fix actual ALPHA: all four extreme corner pixels must be truly TRANSPARENT alpha0. Card interior fully opaque alpha255. Small rounded rectangular silhouette fills whole1024x1536 canvas, side midpoints16px inset opaque255. Do not add outside margins or shadows. Preserve generous two-line title safe field x110..914 y72..236 and four-line rules field x110..914 y1185..1445, no ornament or pointed frame in either field. Keep all words within x110..914; wrap long rules rather than shrink or overflow. No new text/numbers.
```

### 수정 2 · 직사각형 외곽 복구

참고 입력: 승인 유물 PNG + 수정 1 결과. 수정 1이 검은 웨이브를 외곽 컷으로 해석하여 배제하고, 보라 바탕의 정규 직사각형을 복구하도록 재요청했다.

```text
Fix ONLY the OUTER SILHOUETTE of SECOND image. FIRST image is approved relic card structure. SECOND's card was mistakenly cut along wavy decorations: this is WRONG. Fill the outer stock to be a simple regular purple RECTANGLE1024x1536 with very subtle radius24px rounded corners. Black wavy decoration is PRINTED INSIDE purple rectangular card, NEVER the cutting boundary. Bottom side midpoint at(512,1519), top midpoint(512,16), left(16,768), right(1007,768) must all be opaque purple stock alpha255. Only tiny corner cutouts have alpha0, all four(0,0),(1023,0),(0,1535),(1023,1535) alpha0. No margin, no scallops, no floating card, no drop shadows. Keep all illustration, shield frame and Korean exact text:
겨울잠 털가죽
전리품 · 빈 굴의 주인
산장에 덮습니다.
오늘 밤 산장이 받는 피해가
절반입니다.
Keep footer three lines within x110..914 y1185..1445, no shrinking cream footer; maintain space for four lines. Medieval fantasy lodge and graybrown frost-covered giant pelt.
```

## corrupt_prayer · 침식된 기도문

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png` — 승인 역할 포맷
2. `godot/assets/cards/treasure_chest.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: event. Wide scene window, restrained folded banner accents OUTSIDE title, one continuous footer without central arrow/fork/V notch/divider. CORRUPTION: gloomy desaturated muddy purple/black scene and deep violet stock; cream text panels readable. Keep exact event frame skeleton.
SUBJECT (Korean scene direction, follow exactly): 촛불을 든 침식된 자들이 산장 벽에 새긴 뒤틀린 보라 룬 기도문 양피지. 검보라 얼룩이 번지고 글자가 읽히지 않게 뭉개진다. 전체적으로 채도 낮고 어둡게.
EXACT TITLE: 침식된 기도문
EXACT CATEGORY: 침식 · 쓸 수 없음
EXACT RULES:
사용할 수 없습니다.
손패 한 칸을 차지합니다.
```

### 수정 1 · 알파 / 필요한 본문 줄바꿈

참고 입력: 위 역할 승인 PNG + 이 카드의 첫 생성 PNG. 주제·문구·역할 포맷을 보존한다.

```text
Repair SECOND supplied finished 침식된 기도문 card only. FIRST supplied image is approved EVENT layout reference to retain. Preserve SECOND's dark muddy purple/black corruption scene, medieval fantasy snowy lodge, purple stock, bold black ink waves, folded banner outside title, single continuous cream footer; no center divider or V notch. Exact Korean title: 침식된 기도문; category: 침식 · 쓸 수 없음. Exact footer with these visual line breaks:
사용할 수 없습니다.
손패 한 칸을 차지합니다.
All letters and words must remain correct. At normal clear brush type size, place full text within x110..914 y1185..1445; space for four lines; don't make text wider. Preserve two-line title field x110..914 y72..236. No ornament invades either field. MAIN REPAIR: actual transparency is wrong. Make interior opaque alpha255. Only tiny rounded-rectangle outer corners are actual transparent alpha0. All FOUR extreme canvas corner pixels MUST alpha0, not a purple rectangle. Card itself fills full1024x1536 canvas, opaque side midpoint16px inset. No padding, checkerboard pixels, backdrop, shadow or new wording.
```

## poison_spore · 독 포자

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png` — 승인 역할 포맷
2. `godot/assets/cards/treasure_chest.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: event. Wide scene window, restrained folded banner accents OUTSIDE title, one continuous footer without central arrow/fork/V notch/divider. CORRUPTION: gloomy desaturated muddy purple/black scene and deep violet stock; cream text panels readable. Keep exact event frame skeleton.
SUBJECT (Korean scene direction, follow exactly): 맹독 곤충이 남긴 녹·보라빛 포자 구름이 산장 창틀·손패 위로 내려앉는 장면. 작은 곤충 날개 실루엣.
EXACT TITLE: 독 포자
EXACT CATEGORY: 침식 · 쓸 수 없음
EXACT RULES:
사용할 수 없습니다.
손패에 있으면 새벽마다 체력을 잃습니다.
```

### 수정 1 · 알파 / 필요한 본문 줄바꿈

참고 입력: 위 역할 승인 PNG + 이 카드의 첫 생성 PNG. 주제·문구·역할 포맷을 보존한다.

```text
Repair SECOND supplied finished 독 포자 card only. FIRST supplied image is approved EVENT layout reference to retain. Preserve SECOND's dark muddy purple/black corruption scene, medieval fantasy snowy lodge, purple stock, bold black ink waves, folded banner outside title, single continuous cream footer; no center divider or V notch. Exact Korean title: 독 포자; category: 침식 · 쓸 수 없음. Exact footer with these visual line breaks:
사용할 수 없습니다.
손패에 있으면 새벽마다
체력을 잃습니다.
All letters and words must remain correct. At normal clear brush type size, place full text within x110..914 y1185..1445; space for four lines; don't make text wider. Preserve two-line title field x110..914 y72..236. No ornament invades either field. MAIN REPAIR: actual transparency is wrong. Make interior opaque alpha255. Only tiny rounded-rectangle outer corners are actual transparent alpha0. All FOUR extreme canvas corner pixels MUST alpha0, not a purple rectangle. Card itself fills full1024x1536 canvas, opaque side midpoint16px inset. No padding, checkerboard pixels, backdrop, shadow or new wording.
```

## cursed_whisper · 저주의 속삭임

실제 참고 입력:

1. `art/concepts/cards/roles-individual-v02/06-event-forbidden-harvest.png` — 승인 역할 포맷
2. `godot/assets/cards/treasure_chest.png` — 기존 게임 화풍

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: event. Wide scene window, restrained folded banner accents OUTSIDE title, one continuous footer without central arrow/fork/V notch/divider. CORRUPTION: gloomy desaturated muddy purple/black scene and deep violet stock; cream text panels readable. Keep exact event frame skeleton.
SUBJECT (Korean scene direction, follow exactly): 어둠 속 거대한 짐승의 울부짖음이 보라 연기 같은 속삭임 문양으로 흘러 잠든 산장 창문을 감싼다. 아침 햇살이 가려진 느낌.
EXACT TITLE: 저주의 속삭임
EXACT CATEGORY: 침식 · 쓸 수 없음
EXACT RULES:
사용할 수 없습니다.
손패에 있으면 아침 드로우를 막습니다.
```

### 수정 1 · 알파 / 필요한 본문 줄바꿈

참고 입력: 위 역할 승인 PNG + 이 카드의 첫 생성 PNG. 주제·문구·역할 포맷을 보존한다.

```text
Repair SECOND supplied finished 저주의 속삭임 card only. FIRST supplied image is approved EVENT layout reference to retain. Preserve SECOND's dark muddy purple/black corruption scene, medieval fantasy snowy lodge, purple stock, bold black ink waves, folded banner outside title, single continuous cream footer; no center divider or V notch. Exact Korean title: 저주의 속삭임; category: 침식 · 쓸 수 없음. Exact footer with these visual line breaks:
사용할 수 없습니다.
손패에 있으면 아침
드로우를 막습니다.
All letters and words must remain correct. At normal clear brush type size, place full text within x110..914 y1185..1445; space for four lines; don't make text wider. Preserve two-line title field x110..914 y72..236. No ornament invades either field. MAIN REPAIR: actual transparency is wrong. Make interior opaque alpha255. Only tiny rounded-rectangle outer corners are actual transparent alpha0. All FOUR extreme canvas corner pixels MUST alpha0, not a purple rectangle. Card itself fills full1024x1536 canvas, opaque side midpoint16px inset. No padding, checkerboard pixels, backdrop, shadow or new wording.
```



### 겨울잠 털가죽 · 수정 3 · 하단 알파와 최종 재생성

수정 2는 하단 보라 바탕이 기준보다 반투명하여 제외했다. 승인 유물 PNG와 수정 2 결과를 실제 참고 입력으로 넣고 아래 문자열로 다시 생성했다. 최종 생성 파일은 `generation-results.json`의 `repair-3`이다.

```text
Use case: stylized-concept. Production card for Witch's Lodge. Create exactly one upright 1024x1536 2:3 card, orthographic full bleed, no perspective or mockup. Image 1 is the APPROVED ROLE FORMAT: preserve its role-specific frame skeleton, cream title and single continuous cream rules panel, purple stock, bold tapering black ink waves and cream inner line, painterly printed illustration. Image 2 is existing game art for matching style only; replace all subject and text. Medieval-based fantasy world, familiar fantasy adaptations permitted while retaining medieval daily-life atmosphere. Winter forest and timber lodge region.
Card silhouette is a subtly rounded RECTANGLE filling the canvas, genuine transparent alpha outside its rounded corners only. All four extreme corner pixels transparent; card side midpoint at 16px inset fully opaque; interior fully opaque. No broad transparent padding, no drop shadow.
Layout safety takes priority: title field x110..914 y72..236 supports TWO lines with 70px type /76px leading, category on separate line y267..307 at38-40px. You may center a short title on one line but retain full two-line space. Art below category, ends before y1120. Footer cream panel x55..970 y1120..1495, with completely clear FOUR-line text-safe field x110..914 y1185..1445; exact two sentences may occupy two centered lines at approximately 42-48px if they fit, or wrap within four lines. Keep generous blank space for longer translations. No ornament, ink wave, frame point, badge, divider, stones or pillars inside either text-safe field. No numbers/stats/extra effects, watermark, logo or other wording.
Use Korean bold brush-like lettering like the references, sharp and perfectly legible. Exact text below; preserve spelling, spaces, punctuation and spaced middle dot.
ROLE: relic. Tall SHIELD-shaped art window, subject centered vertically. Shield point ends above y1120; clear continuous footer.
SUBJECT (Korean scene direction, follow exactly): 거대한 짐승(빈 굴의 주인)의 두껍고 회갈색인 털가죽이 산장 지붕·벽 위에 덮인 모습 또는 걸린 전리품. 서리 낀 털, 큰 발톱 하나 정도.
EXACT TITLE: 겨울잠 털가죽
EXACT CATEGORY: 전리품 · 빈 굴의 주인
EXACT RULES:
산장에 덮습니다.
오늘 밤 산장이 받는 피해가 절반입니다.
FINAL PRODUCTION REPAIR: preserve the subject and precise Korean but render bottom rules in THREE centered lines:
산장에 덮습니다.
오늘 밤 산장이 받는 피해가
절반입니다.
Keep a clear rectangular purple cardstock perimeter with broad opaque purple bottom edge from y1498 to1535. The purple perimeter is SOLID PRINTED CARD STOCK, absolutely opaque, NOT tinted glass, NOT soft fade, NOT a shadow. Only small corner cutouts outside radius24px rounded rectangle are transparent. Center, side midpoints16px inset and especially bottom midpoint(512,1519) have alpha255. Outside corners alpha0. No transparent bottom gradient. Use a regular full-canvas2:3 rectangle, no wave-shaped or scalloped outer cutting. Generate new fully opaque card interior, preserve vivid printed artwork and all wording.
```

