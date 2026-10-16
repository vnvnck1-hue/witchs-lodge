# 6종 카드 개별화·다국어 레이아웃 정리 — 실제 프롬프트 v02

2026-10-16 · 내장 image_gen · 입력: `art/concepts/cards/roles-races-v01/01-role-formats-v02.png`(빨간 주석 없는 원본).

카드별 기본 이름·원화·포맷은 비교판을 따른다. 사용자가 지적한 목재의 중복 먹선, 제단 설명칸 폭·높이 부족, 수확제 설명란 중앙 문양을 정리한다. 제목 2줄과 설명 4줄을 위한 공통 안전 영역을 목표로 1024×1536 단일 카드 여섯 장을 각각 생성한다. 아래 좌표는 생성 지시의 목표이며 향후 실제 UI 텍스트 배치를 위한 강제 마스크·레이어 구현은 별도다.

## character — 잡화상 니브

```text
Use case: precise-object-edit / style-transfer. Asset type: ONE cleaned individual full fantasy card from the supplied six-role concept sheet for Witch's Lodge. The attached clean six-card board is the AUTHORITATIVE visual reference. Preserve the chosen card's subject, role-specific frame, dusty violet stock, thick expressive BLACK brush-ink waves, warm cream paper, hand-lettered Korean, bold painterly fairytale print style, snowy teal/indigo and amber palette. This is NOT any later empty-frame or minimalist experiment.
Output exactly ONE upright complete card at 1024x1536, 2:3. It fills the canvas with only slight rounded outer corners; keep purple card body opaque, only outside perimeter transparent. NO board, external heading, caption or second card. Do not squash vertically. Redraw as a high-quality individual card, not a blurry crop.
PRIMARY TASK: clean and standardize layout for MULTILINGUAL TEXT. Card artwork and ornament must yield space to title and rules. Preserve distinct role-specific art-window geometry, but align the name and description areas to a shared usable standard.
LAYOUT AT 1024x1536:
- TOP cream name panel runs approximately y=30..325. Its interior has an unobstructed central rectangle x=110..914, y=72..236 for up to TWO lines of localized title. Current Korean title can be one line centered around y=145, at about 68-72 px; leave generous top/bottom room instead of filling the whole panel with giant lettering.
- Role/category is a separate smaller line around y=267..300, about 38-40px, not overlapping title or art.
- Artwork occupies middle region y=350..1080 approximately. Keep its main subject composed clearly despite shorter height.
- BOTTOM cream rules panel is one LARGE CONTIGUOUS CLEAN field, approximately x=55..970,y=1120..1495. Safe text rectangle x=110..914, y=1185..1445 (804x260), enough for at least FOUR lines around 46-48px with 58-60px leading. Render the given short Korean rules at normal size in this field, leaving genuinely visible spare space for longer translations. Do NOT inflate a one-line rule into a huge font. Do NOT shrink the panel to fit the short Korean text.
- NO black ornamental line, symbol, badge, frame corner, stone block, divider, ribbon tail or art point may enter this bottom text rectangle. Side decorations stay in the outside margin. Bottom panel upper edge can be subtly curved, but the central safe rectangle is broad and unclipped.
- Species or resource badge, if present, sits at artwork's lower edge around y=1020..1120 and stays ABOVE the rules safe area. It must not reduce text width.
- No printed cost/attack/health/duration/count numbers. No game-stat gems. No new gameplay or changed effects. All decorations purposeful and restrained, fewer than reference where they cost text area.
This is a polished visual sample including artwork and Korean text; maintain the existing image identity, do not fill art with gray. Existing source board is being promoted to six separate cards with cleaner localization-ready panels.

Use ONLY TOP LEFT goblin merchant from reference. Preserve the specific jaunty green goblin with enormous ears, rust-red cap/scarf, curious welcoming grin, travel packs, pouches and a coin offered in open palm, amber lanterns and snowy teal forest. Same portrait identity as the board, not the later separate dark-haired merchant variant. Large face/upper body in softly ARCH-shaped portrait window, original asymmetrical S-wave style on sides. Species medallion exact "고블린" with a simple goblin-ear/coin symbol at portrait base, compact enough to end by y=1120. Name panel at TOP, no new title strap at portrait base. One uninterrupted large cream footer, clean margins.

EXACT KOREAN TEXT:
Title: "잡화상 니브"
Category: "인물"
Rules lines (retain spelling, permit only these line breaks):
"손님과 물건을 거래합니다."
No extra words, no external role labels. Keep the wide reserved text areas obvious even with short Korean copy.
```

## skill — 따뜻한 환대

```text
Use case: precise-object-edit / style-transfer. Asset type: ONE cleaned individual full fantasy card from the supplied six-role concept sheet for Witch's Lodge. The attached clean six-card board is the AUTHORITATIVE visual reference. Preserve the chosen card's subject, role-specific frame, dusty violet stock, thick expressive BLACK brush-ink waves, warm cream paper, hand-lettered Korean, bold painterly fairytale print style, snowy teal/indigo and amber palette. This is NOT any later empty-frame or minimalist experiment.
Output exactly ONE upright complete card at 1024x1536, 2:3. It fills the canvas with only slight rounded outer corners; keep purple card body opaque, only outside perimeter transparent. NO board, external heading, caption or second card. Do not squash vertically. Redraw as a high-quality individual card, not a blurry crop.
PRIMARY TASK: clean and standardize layout for MULTILINGUAL TEXT. Card artwork and ornament must yield space to title and rules. Preserve distinct role-specific art-window geometry, but align the name and description areas to a shared usable standard.
LAYOUT AT 1024x1536:
- TOP cream name panel runs approximately y=30..325. Its interior has an unobstructed central rectangle x=110..914, y=72..236 for up to TWO lines of localized title. Current Korean title can be one line centered around y=145, at about 68-72 px; leave generous top/bottom room instead of filling the whole panel with giant lettering.
- Role/category is a separate smaller line around y=267..300, about 38-40px, not overlapping title or art.
- Artwork occupies middle region y=350..1080 approximately. Keep its main subject composed clearly despite shorter height.
- BOTTOM cream rules panel is one LARGE CONTIGUOUS CLEAN field, approximately x=55..970,y=1120..1495. Safe text rectangle x=110..914, y=1185..1445 (804x260), enough for at least FOUR lines around 46-48px with 58-60px leading. Render the given short Korean rules at normal size in this field, leaving genuinely visible spare space for longer translations. Do NOT inflate a one-line rule into a huge font. Do NOT shrink the panel to fit the short Korean text.
- NO black ornamental line, symbol, badge, frame corner, stone block, divider, ribbon tail or art point may enter this bottom text rectangle. Side decorations stay in the outside margin. Bottom panel upper edge can be subtly curved, but the central safe rectangle is broad and unclipped.
- Species or resource badge, if present, sits at artwork's lower edge around y=1020..1120 and stays ABOVE the rules safe area. It must not reduce text width.
- No printed cost/attack/health/duration/count numbers. No game-stat gems. No new gameplay or changed effects. All decorations purposeful and restrained, fewer than reference where they cost text area.
This is a polished visual sample including artwork and Korean text; maintain the existing image identity, do not fill art with gray. Existing source board is being promoted to six separate cards with cleaner localization-ready panels.

Use ONLY TOP MIDDLE healing SKILL from reference. Broad tilted-square DIAMOND artwork window with bold black outline and narrow cream inset. Painting: a warm human hand reaching down toward an upward green goblin hand; luminous amber healing swirls connecting the hands against snowy teal woodland. Preserve those hands and healing motif, not ice or runes. All primary artwork clipped inside diamond; outside is dusty purple with restrained black waves. Diamond fits between y=345 and y=1110; its bottom point ends above the rules panel. No artwork corners, long diamond tip or black frame protrudes into rules safe area. No goblin species badge: the card itself is a skill, goblin is an effect condition. Full-size shared title and footer zones, three rules lines as specified.

EXACT KOREAN TEXT:
Title: "따뜻한 환대"
Category: "스킬"
Rules lines (retain spelling, permit only these line breaks):
"대상의 체력을 회복합니다."
"대상이 고블린이면"
"추가 회복합니다."
No extra words, no external role labels. Keep the wide reserved text areas obvious even with short Korean copy.
```

## resource — 목재

```text
Use case: precise-object-edit / style-transfer. Asset type: ONE cleaned individual full fantasy card from the supplied six-role concept sheet for Witch's Lodge. The attached clean six-card board is the AUTHORITATIVE visual reference. Preserve the chosen card's subject, role-specific frame, dusty violet stock, thick expressive BLACK brush-ink waves, warm cream paper, hand-lettered Korean, bold painterly fairytale print style, snowy teal/indigo and amber palette. This is NOT any later empty-frame or minimalist experiment.
Output exactly ONE upright complete card at 1024x1536, 2:3. It fills the canvas with only slight rounded outer corners; keep purple card body opaque, only outside perimeter transparent. NO board, external heading, caption or second card. Do not squash vertically. Redraw as a high-quality individual card, not a blurry crop.
PRIMARY TASK: clean and standardize layout for MULTILINGUAL TEXT. Card artwork and ornament must yield space to title and rules. Preserve distinct role-specific art-window geometry, but align the name and description areas to a shared usable standard.
LAYOUT AT 1024x1536:
- TOP cream name panel runs approximately y=30..325. Its interior has an unobstructed central rectangle x=110..914, y=72..236 for up to TWO lines of localized title. Current Korean title can be one line centered around y=145, at about 68-72 px; leave generous top/bottom room instead of filling the whole panel with giant lettering.
- Role/category is a separate smaller line around y=267..300, about 38-40px, not overlapping title or art.
- Artwork occupies middle region y=350..1080 approximately. Keep its main subject composed clearly despite shorter height.
- BOTTOM cream rules panel is one LARGE CONTIGUOUS CLEAN field, approximately x=55..970,y=1120..1495. Safe text rectangle x=110..914, y=1185..1445 (804x260), enough for at least FOUR lines around 46-48px with 58-60px leading. Render the given short Korean rules at normal size in this field, leaving genuinely visible spare space for longer translations. Do NOT inflate a one-line rule into a huge font. Do NOT shrink the panel to fit the short Korean text.
- NO black ornamental line, symbol, badge, frame corner, stone block, divider, ribbon tail or art point may enter this bottom text rectangle. Side decorations stay in the outside margin. Bottom panel upper edge can be subtly curved, but the central safe rectangle is broad and unclipped.
- Species or resource badge, if present, sits at artwork's lower edge around y=1020..1120 and stays ABOVE the rules safe area. It must not reduce text width.
- No printed cost/attack/health/duration/count numbers. No game-stat gems. No new gameplay or changed effects. All decorations purposeful and restrained, fewer than reference where they cost text area.
This is a polished visual sample including artwork and Korean text; maintain the existing image identity, do not fill art with gray. Existing source board is being promoted to six separate cards with cleaner localization-ready panels.

Use ONLY TOP RIGHT wood RESOURCE from reference. Three chunky snow-dusted cut logs tied with cord, visible log end-grain, teal snowy fir forest. Broad RECTANGULAR artwork window with gently rounded/clipped corners; blocky simple resource layout distinct from character/skill. CRITICAL CLEANUP: REMOVE the useless stacked horizontal cream strips and duplicate BLACK horizontal lines flanking the resource badge below art. There is ONLY ONE continuous cream rules panel, no extra narrow empty drawer or separator strip above it. Keep just one small wood-stack emblem centered at the art/panel transition, ending at y=1120, no count printed. Bottom description has full unobstructed width and generous height; no rule crossing behind words, no decorative lower bars. Resource title panel stays broad, clean and rectangular/softly bowed.

EXACT KOREAN TEXT:
Title: "목재"
Category: "자원"
Rules lines (retain spelling, permit only these line breaks):
"건축과 수리에 사용합니다."
No extra words, no external role labels. Keep the wide reserved text areas obvious even with short Korean copy.
```

## relic — 달빛 부적

```text
Use case: precise-object-edit / style-transfer. Asset type: ONE cleaned individual full fantasy card from the supplied six-role concept sheet for Witch's Lodge. The attached clean six-card board is the AUTHORITATIVE visual reference. Preserve the chosen card's subject, role-specific frame, dusty violet stock, thick expressive BLACK brush-ink waves, warm cream paper, hand-lettered Korean, bold painterly fairytale print style, snowy teal/indigo and amber palette. This is NOT any later empty-frame or minimalist experiment.
Output exactly ONE upright complete card at 1024x1536, 2:3. It fills the canvas with only slight rounded outer corners; keep purple card body opaque, only outside perimeter transparent. NO board, external heading, caption or second card. Do not squash vertically. Redraw as a high-quality individual card, not a blurry crop.
PRIMARY TASK: clean and standardize layout for MULTILINGUAL TEXT. Card artwork and ornament must yield space to title and rules. Preserve distinct role-specific art-window geometry, but align the name and description areas to a shared usable standard.
LAYOUT AT 1024x1536:
- TOP cream name panel runs approximately y=30..325. Its interior has an unobstructed central rectangle x=110..914, y=72..236 for up to TWO lines of localized title. Current Korean title can be one line centered around y=145, at about 68-72 px; leave generous top/bottom room instead of filling the whole panel with giant lettering.
- Role/category is a separate smaller line around y=267..300, about 38-40px, not overlapping title or art.
- Artwork occupies middle region y=350..1080 approximately. Keep its main subject composed clearly despite shorter height.
- BOTTOM cream rules panel is one LARGE CONTIGUOUS CLEAN field, approximately x=55..970,y=1120..1495. Safe text rectangle x=110..914, y=1185..1445 (804x260), enough for at least FOUR lines around 46-48px with 58-60px leading. Render the given short Korean rules at normal size in this field, leaving genuinely visible spare space for longer translations. Do NOT inflate a one-line rule into a huge font. Do NOT shrink the panel to fit the short Korean text.
- NO black ornamental line, symbol, badge, frame corner, stone block, divider, ribbon tail or art point may enter this bottom text rectangle. Side decorations stay in the outside margin. Bottom panel upper edge can be subtly curved, but the central safe rectangle is broad and unclipped.
- Species or resource badge, if present, sits at artwork's lower edge around y=1020..1120 and stays ABOVE the rules safe area. It must not reduce text width.
- No printed cost/attack/health/duration/count numbers. No game-stat gems. No new gameplay or changed effects. All decorations purposeful and restrained, fewer than reference where they cost text area.
This is a polished visual sample including artwork and Korean text; maintain the existing image identity, do not fill art with gray. Existing source board is being promoted to six separate cards with cleaner localization-ready panels.

Use ONLY BOTTOM LEFT moon pendant EQUIPMENT/RELIC from reference. Beautiful glowing crescent pendant on a gold chain, small celestial inlay, indigo-plum hanging cloth and candlelight, no character. TALL SHIELD-shaped art window with taper to shallow point, expressive black wave sides. Keep shield identity but shorten the lower tip to end before y=1120 so it never pierces the cream description area. No dangling decorative point inside text field. Shared generous top cream name field and one large unclipped footer; short Korean rule at normal body size with spare room for longer translations. The gold is on the illustrated pendant, not a new ornate external frame system.

EXACT KOREAN TEXT:
Title: "달빛 부적"
Category: "장비 · 유물"
Rules lines (retain spelling, permit only these line breaks):
"지니고 있는 동안 힘을 보탭니다."
No extra words, no external role labels. Keep the wide reserved text areas obvious even with short Korean copy.
```

## facility — 숲의 제단

```text
Use case: precise-object-edit / style-transfer. Asset type: ONE cleaned individual full fantasy card from the supplied six-role concept sheet for Witch's Lodge. The attached clean six-card board is the AUTHORITATIVE visual reference. Preserve the chosen card's subject, role-specific frame, dusty violet stock, thick expressive BLACK brush-ink waves, warm cream paper, hand-lettered Korean, bold painterly fairytale print style, snowy teal/indigo and amber palette. This is NOT any later empty-frame or minimalist experiment.
Output exactly ONE upright complete card at 1024x1536, 2:3. It fills the canvas with only slight rounded outer corners; keep purple card body opaque, only outside perimeter transparent. NO board, external heading, caption or second card. Do not squash vertically. Redraw as a high-quality individual card, not a blurry crop.
PRIMARY TASK: clean and standardize layout for MULTILINGUAL TEXT. Card artwork and ornament must yield space to title and rules. Preserve distinct role-specific art-window geometry, but align the name and description areas to a shared usable standard.
LAYOUT AT 1024x1536:
- TOP cream name panel runs approximately y=30..325. Its interior has an unobstructed central rectangle x=110..914, y=72..236 for up to TWO lines of localized title. Current Korean title can be one line centered around y=145, at about 68-72 px; leave generous top/bottom room instead of filling the whole panel with giant lettering.
- Role/category is a separate smaller line around y=267..300, about 38-40px, not overlapping title or art.
- Artwork occupies middle region y=350..1080 approximately. Keep its main subject composed clearly despite shorter height.
- BOTTOM cream rules panel is one LARGE CONTIGUOUS CLEAN field, approximately x=55..970,y=1120..1495. Safe text rectangle x=110..914, y=1185..1445 (804x260), enough for at least FOUR lines around 46-48px with 58-60px leading. Render the given short Korean rules at normal size in this field, leaving genuinely visible spare space for longer translations. Do NOT inflate a one-line rule into a huge font. Do NOT shrink the panel to fit the short Korean text.
- NO black ornamental line, symbol, badge, frame corner, stone block, divider, ribbon tail or art point may enter this bottom text rectangle. Side decorations stay in the outside margin. Bottom panel upper edge can be subtly curved, but the central safe rectangle is broad and unclipped.
- Species or resource badge, if present, sits at artwork's lower edge around y=1020..1120 and stays ABOVE the rules safe area. It must not reduce text width.
- No printed cost/attack/health/duration/count numbers. No game-stat gems. No new gameplay or changed effects. All decorations purposeful and restrained, fewer than reference where they cost text area.
This is a polished visual sample including artwork and Korean text; maintain the existing image identity, do not fill art with gray. Existing source board is being promoted to six separate cards with cleaner localization-ready panels.

Use ONLY BOTTOM MIDDLE woodland altar FACILITY from reference. Wooden ritual altar with shallow triangular gable, purple banners, crescent ornament, candles, snow-covered steps and teal fir forest. Preserve architectural frame identity via a LOW ROOF crest over a BROAD CREAM TITLE PANEL and slender side posts only around artwork. CRITICAL CLEANUP: footer must be as TALL and WIDE as all other roles, not the tiny original sign at the foot of the stairs. Raise/crop artwork and steps to finish around y=1080 so footer has full y=1120..1495 height. Move any stone foundation blocks, post bases and brackets to OUTERMOST lower corners, wholly outside safe rectangle x=110..914,y=1185..1445. No stair, stone, pillar or diagonal roof/title corner intrudes on text. The top name panel must be broad enough for two lines, NOT a cramped diamond plaque; roof outline may surround above/outside it. Art stays architectural, rules panel stays one open cream rectangle.

EXACT KOREAN TEXT:
Title: "숲의 제단"
Category: "시설"
Rules lines (retain spelling, permit only these line breaks):
"공물을 바쳐 의식을 준비합니다."
No extra words, no external role labels. Keep the wide reserved text areas obvious even with short Korean copy.
```

## event — 금지된 수확제

```text
Use case: precise-object-edit / style-transfer. Asset type: ONE cleaned individual full fantasy card from the supplied six-role concept sheet for Witch's Lodge. The attached clean six-card board is the AUTHORITATIVE visual reference. Preserve the chosen card's subject, role-specific frame, dusty violet stock, thick expressive BLACK brush-ink waves, warm cream paper, hand-lettered Korean, bold painterly fairytale print style, snowy teal/indigo and amber palette. This is NOT any later empty-frame or minimalist experiment.
Output exactly ONE upright complete card at 1024x1536, 2:3. It fills the canvas with only slight rounded outer corners; keep purple card body opaque, only outside perimeter transparent. NO board, external heading, caption or second card. Do not squash vertically. Redraw as a high-quality individual card, not a blurry crop.
PRIMARY TASK: clean and standardize layout for MULTILINGUAL TEXT. Card artwork and ornament must yield space to title and rules. Preserve distinct role-specific art-window geometry, but align the name and description areas to a shared usable standard.
LAYOUT AT 1024x1536:
- TOP cream name panel runs approximately y=30..325. Its interior has an unobstructed central rectangle x=110..914, y=72..236 for up to TWO lines of localized title. Current Korean title can be one line centered around y=145, at about 68-72 px; leave generous top/bottom room instead of filling the whole panel with giant lettering.
- Role/category is a separate smaller line around y=267..300, about 38-40px, not overlapping title or art.
- Artwork occupies middle region y=350..1080 approximately. Keep its main subject composed clearly despite shorter height.
- BOTTOM cream rules panel is one LARGE CONTIGUOUS CLEAN field, approximately x=55..970,y=1120..1495. Safe text rectangle x=110..914, y=1185..1445 (804x260), enough for at least FOUR lines around 46-48px with 58-60px leading. Render the given short Korean rules at normal size in this field, leaving genuinely visible spare space for longer translations. Do NOT inflate a one-line rule into a huge font. Do NOT shrink the panel to fit the short Korean text.
- NO black ornamental line, symbol, badge, frame corner, stone block, divider, ribbon tail or art point may enter this bottom text rectangle. Side decorations stay in the outside margin. Bottom panel upper edge can be subtly curved, but the central safe rectangle is broad and unclipped.
- Species or resource badge, if present, sits at artwork's lower edge around y=1020..1120 and stays ABOVE the rules safe area. It must not reduce text width.
- No printed cost/attack/health/duration/count numbers. No game-stat gems. No new gameplay or changed effects. All decorations purposeful and restrained, fewer than reference where they cost text area.
This is a polished visual sample including artwork and Korean text; maintain the existing image identity, do not fill art with gray. Existing source board is being promoted to six separate cards with cleaner localization-ready panels.

Use ONLY BOTTOM RIGHT harvest EVENT from reference. An uncanny lantern-lit woodland harvest festival, jack-o'-lantern pumpkins, small cloaked festival figures, warm bonfire, hanging amber lanterns and crescent moon in dark violet sky. Preserve folded-paper/banner outer accents and broad scene window, distinctive from the other roles. CRITICAL CLEANUP: DELETE the central three-way ARROW/TRIDENT/FORK symbol above the description, delete the V notch and split lobes of the rules panel. Replace lower region with ONE SINGLE CLEAN continuous warm cream panel spanning full text width and height, broad near-horizontal upper edge. No center division, no choice icon, no branching badge or isolated black curls inside description. Paper fold accents live ONLY at far outer art corners, not on text field. Top banner is a broad readable cream name panel with shallow outer folds; two-line title safe space must be clear, not cut by angled folds. Scene artwork shortened to allow same generous footer as all other cards.

EXACT KOREAN TEXT:
Title: "금지된 수확제"
Category: "사건"
Rules lines (retain spelling, permit only these line breaks):
"이상한 수확제가 시작됩니다."
No extra words, no external role labels. Keep the wide reserved text areas obvious even with short Korean copy.
```
