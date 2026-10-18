# 숙박 손님 포트레이트

## 종족 손님 35장 추가 (2026-10-18)

드워프·요정·고블린·수인·오크 손님 35명의 `guest_<id>_cutout.png`(RGBA 1122×1402)를 코덱스가 카드 화풍(승인 브람 v02 기준)으로 제작했다. 인물 표·성격은 [종족 시스템 1차](../../../docs/races-guests-v01.md) §3, 실제 프롬프트·검수는 [코덱스 납품 결과](../../../docs/handoff/codex-race-portraits-v01.md)와 `art/portraits/card-style-v01/races/`. 프로필 연결은 `scripts/ui/guest_profiles.gd`이며, 파일이 없는 인물은 `PLACEHOLDER_PORTRAIT`(익명 실루엣)로 대체된다. 미리보기 `screenshots/races/portrait-sheet.png`, 실제 도착 창 캡처 `screenshots/races/arrival/`.

## 신규 손님 5종 · 직접 투명 배경으로 생성

기존 두 명에 더해 아래 다섯 개의 독립 초상을 built-in image_gen의 `transparent_background=true`로 생성했다.

- `guest_olaf_cutout.png`: 올라프
- `guest_torbin_cutout.png`: 토르빈
- `guest_neri_cutout.png`: 네리
- `guest_oswin_cutout.png`: 오스윈
- `guest_sera_cutout.png`: 세라

새 초상들은 `guest_profiles.gd`의 일곱 인물 카탈로그에서 사용한다. 용병의 선호 순서는 브람·올라프·토르빈이며, 계약 이름이 이미 사용 중이면 기존 이름 풀의 인물이 용병 초상 원형을 공유한다.

### 올라프 / olaf

Use case: stylized-concept. Asset type: one production transparent-alpha character portrait for the fantasy game Witch's Lodge. Style: polished hand-painted storybook fantasy illustration, bold curved silhouettes, expressive slightly exaggerated adult proportions, confident dark painted edges, broad painted color planes and restrained brush texture, warm amber inn light and cool lavender rim light, cohesive Warcraft / Hearthstone-like readability, not realistic, not anime. Composition: chest-to-waist-up three-quarter portrait, centered, complete head including hair or hat with comfortable transparent headroom, recognizable face large enough for a game notification. Match a traveling fantasy guest in a winter forest. Genuine transparent background everywhere outside the character, no scenery, no smoke background, no frame, no panel, no text, no watermark, no extra figures. Preserve naturally antialiased hair/fur edges without a colored halo. Portrait aspect ratio 4:5. Clothing may be cropped at the very bottom, but keep head and silhouette clearly readable.
Subject: Olaf is a stout middle-aged male guard mercenary with a broad round face, ruddy nose and cheeks, thick ginger beard tied with a small brass bead, bushy ginger eyebrows, friendly skeptical half-smile. He wears a slate blue padded coat, broad ochre shoulder scarf, modest worn steel shoulder guard, heavy tan sheepskin collar, dark leather axe harness. His small leather winter cap sits behind his forehead, face fully visible. Broad grounded silhouette, three-quarter turned a little right. His attitude is gruff but reassuring. Distinct from a brown-haired square-faced mercenary: emphasize the ginger beard and round face. No full weapon obstructing the bust.

### 토르빈 / torbin

Use case: stylized-concept. Asset type: one production transparent-alpha character portrait for the fantasy game Witch's Lodge. Style: polished hand-painted storybook fantasy illustration, bold curved silhouettes, expressive slightly exaggerated adult proportions, confident dark painted edges, broad painted color planes and restrained brush texture, warm amber inn light and cool lavender rim light, cohesive Warcraft / Hearthstone-like readability, not realistic, not anime. Composition: chest-to-waist-up three-quarter portrait, centered, complete head including hair or hat with comfortable transparent headroom, recognizable face large enough for a game notification. Match a traveling fantasy guest in a winter forest. Genuine transparent background everywhere outside the character, no scenery, no smoke background, no frame, no panel, no text, no watermark, no extra figures. Preserve naturally antialiased hair/fur edges without a colored halo. Portrait aspect ratio 4:5. Clothing may be cropped at the very bottom, but keep head and silhouette clearly readable.
Subject: Torbin is a lean older male veteran mercenary in his late fifties, long angular face, swept-back silver hair, short pointed gray goatee, one fine healed scar across one cheek, calm tired eyes and a reserved dignified expression. A dark forest-green high-collared coat under a weathered plum half-cloak, muted leather straps and a small simple metal cloak clasp, light battered shoulder armor. Narrow upright silhouette, three-quarter turned slightly left. A professional who quietly watches the door, not an evil sorcerer. Face fully unobscured; no hood over head, no large weapon.

### 네리 / neri

Use case: stylized-concept. Asset type: one production transparent-alpha character portrait for the fantasy game Witch's Lodge. Style: polished hand-painted storybook fantasy illustration, bold curved silhouettes, expressive slightly exaggerated adult proportions, confident dark painted edges, broad painted color planes and restrained brush texture, warm amber inn light and cool lavender rim light, cohesive Warcraft / Hearthstone-like readability, not realistic, not anime. Composition: chest-to-waist-up three-quarter portrait, centered, complete head including hair or hat with comfortable transparent headroom, recognizable face large enough for a game notification. Match a traveling fantasy guest in a winter forest. Genuine transparent background everywhere outside the character, no scenery, no smoke background, no frame, no panel, no text, no watermark, no extra figures. Preserve naturally antialiased hair/fur edges without a colored halo. Portrait aspect ratio 4:5. Clothing may be cropped at the very bottom, but keep head and silhouette clearly readable.
Subject: Neri is an energetic young adult woman forest courier, short tousled dark chestnut bob hair, lively hazel eyes, a few freckles, a mischievous confident grin. She wears a simple brown leather travel cap, a long rusty red scarf wrapped around her neck, a muted sage green traveling jacket with fitted leather shoulder patches and a crossbody courier satchel strap. A sealed folded letter peeks from the strap pocket. Slightly tilted lively shoulders, three-quarter turned right, engaging open face. Practical winter traveler, no modern items, no helmet or goggles.

### 오스윈 / oswin

Use case: stylized-concept. Asset type: one production transparent-alpha character portrait for the fantasy game Witch's Lodge. Style: polished hand-painted storybook fantasy illustration, bold curved silhouettes, expressive slightly exaggerated adult proportions, confident dark painted edges, broad painted color planes and restrained brush texture, warm amber inn light and cool lavender rim light, cohesive Warcraft / Hearthstone-like readability, not realistic, not anime. Composition: chest-to-waist-up three-quarter portrait, centered, complete head including hair or hat with comfortable transparent headroom, recognizable face large enough for a game notification. Match a traveling fantasy guest in a winter forest. Genuine transparent background everywhere outside the character, no scenery, no smoke background, no frame, no panel, no text, no watermark, no extra figures. Preserve naturally antialiased hair/fur edges without a colored halo. Portrait aspect ratio 4:5. Clothing may be cropped at the very bottom, but keep head and silhouette clearly readable.
Subject: Oswin is an elderly male ruin chronicler, long white beard with two broad forks, wispy silver eyebrows, kindly observant eyes behind small round brass spectacles, a thoughtful amused closed-mouth smile. He wears a soft crumpled dark navy scholar's travel hat and an ochre mustard wool mantle over an indigo coat, a simple old book strap crossing his chest, one tightly rolled parchment tucked into a coat pocket. Slightly stooped shoulders, three-quarter turned left. Warm curious academic, subtly eccentric, not a wizard with magical effects. Full hat and head visible, no staff or huge props.

### 세라 / sera

Use case: stylized-concept. Asset type: one production transparent-alpha character portrait for the fantasy game Witch's Lodge. Style: polished hand-painted storybook fantasy illustration, bold curved silhouettes, expressive slightly exaggerated adult proportions, confident dark painted edges, broad painted color planes and restrained brush texture, warm amber inn light and cool lavender rim light, cohesive Warcraft / Hearthstone-like readability, not realistic, not anime. Composition: chest-to-waist-up three-quarter portrait, centered, complete head including hair or hat with comfortable transparent headroom, recognizable face large enough for a game notification. Match a traveling fantasy guest in a winter forest. Genuine transparent background everywhere outside the character, no scenery, no smoke background, no frame, no panel, no text, no watermark, no extra figures. Preserve naturally antialiased hair/fur edges without a colored halo. Portrait aspect ratio 4:5. Clothing may be cropped at the very bottom, but keep head and silhouette clearly readable.
Subject: Sera is a confident middle-aged woman traveling merchant with deep warm brown skin, short dense black curls held by a burnt-orange patterned headband, expressive dark eyes, a broad warm pragmatic smile and a small gap between her upper front teeth. She wears an indigo wool winter coat with cream woven collar, brass coin-shaped brooch, a rich muted burgundy sash, a broad worn leather pack strap, a small green glass trade vial tucked safely into the strap pouch. Rounded welcoming shoulders, three-quarter turned slightly right. A practical friendly trader with a distinctive silhouette, no modern accessories, no overflowing huge backpack, no weapons.


2026-10-15 · built-in image_gen으로 생성한 실제 게임용 초상 2종.

- `guest_bram.png`: 경계심 있는 도끼 용병. 초록 망토, 털 깃, 가죽과 강철 갑옷.
- `guest_mira.png`: 정중한 약초상 미라. 적갈색 땋은 머리, 자주색 후드, 청록 외투, 말린 약초.

원본 1122×1402 PNG를 보존한다. v2 게임은 배경 제거한 별도 PNG의 실제 알파 실루엣을 사용한다.
고용할 때 이름은 소개한 실제 손님의 이름을 유지한다. 신규 확장 후 용병 초상은 브람·올라프·토르빈 세 원형이다.
추가 캐릭터는 `scripts/ui/guest_profiles.gd`에서 문구와 이미지 경로를 연결한다.

## 생성 프롬프트

### v2 배경 제거 · 실제 게임용

- `guest_bram_cutout.png`: 기존 브람에서 배경을 제거한 투명 PNG.
- `guest_mira_cutout.png`: 기존 미라에서 배경을 제거한 투명 PNG.

두 원본을 각각 편집 대상으로 지정하고 built-in image_gen의 `transparent_background=true`로 편집했다. 원본은 교체하지 않았다.

Use case: background-extraction. Edit target: the attached existing painted fantasy character portrait. Remove ONLY the entire purple/smoky scenery background around the person and output a genuine transparent-alpha PNG cutout. Preserve the exact same character, facial features, expression, pose, clothing, hair, lighting, brushwork, colors and silhouette. Keep the chest-up crop and original aspect ratio and scale, and keep the complete head. Keep fur/hair edge detail naturally antialiased, with no purple halo. Transparent outside the actual person. No new background, no frame, no text, no added items. This will float over a dark UI panel inside an existing game, so retain only the person and their existing clothing. Do not repaint or redesign the illustration.

### bram

Use case: stylized-concept. Asset type: production character portrait illustration for Witch's Lodge fantasy game guest introduction UI. Create one single portrait of Bram, a weathered middle-aged male wandering axe mercenary, broad stocky shoulders, large expressive angular face, thick dark eyebrows, short brown hair with gray temples, short beard, a tiny old eyebrow scar. Wearing a heavy moss-green wool cloak with cream fur collar, worn leather straps and modest steel shoulder armor. Expression wary but curious, mouth slightly open as if about to say something dry. Style: polished hand-painted storybook fantasy game illustration, bold curved silhouettes, slightly exaggerated charming proportions, confident dark ink edges, broad painted color planes, restrained texture, Warcraft / Hearthstone-like readability, not realistic, not anime. Chest-up three-quarter portrait looking slightly right toward viewer, complete head and shoulders centered with generous headroom and side margins. Background: simple deep desaturated violet vignette with faint winter mist and warm golden light, no detailed scenery. Warm inn window light from right, cool lavender rim. Portrait aspect ratio 4:5. No text, no letters, no UI, no frame, no watermark, only one character. The image will fill a tall arched guest portrait.

### mira

Use case: stylized-concept. Asset type: production character portrait illustration for Witch's Lodge fantasy game guest introduction UI. Create one single portrait of Mira, a young adult female traveling herbalist with a warm quietly relieved smile, large expressive friendly face, soft freckles, wavy auburn hair braided over one shoulder. Wearing a muted plum hood down around shoulders, cream scarf, teal wool traveling coat with wooden clasp, worn satchel strap and a few dried herbs tucked under it. Style: polished hand-painted storybook fantasy game illustration, bold curved silhouettes, slightly exaggerated charming proportions, confident dark ink edges, broad painted color planes, restrained texture, Warcraft / Hearthstone-like readability, not realistic, not anime. Chest-up three-quarter portrait looking slightly left toward viewer, complete head and shoulders centered with generous headroom and side margins. Background: simple deep desaturated violet vignette with faint winter mist and warm golden light, no detailed scenery. Warm inn window light from left, cool lavender rim. Portrait aspect ratio 4:5. No text, no letters, no UI, no frame, no watermark, only one character. The image will fill a tall arched guest portrait. Match the cohesive storybook fantasy style of a gruff mercenary with moss green cloak and fur collar, but this is a different female character.

