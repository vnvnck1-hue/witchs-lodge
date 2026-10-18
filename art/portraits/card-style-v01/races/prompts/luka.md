# luka · beastfolk 포트레이트

- 제작: 내장 `image_gen`, 투명 배경 요청, 개별 생성 1회.
- 참고 입력(읽기 전용):
  1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/races-guests/art/concepts/cards/roles-races-v01/04-beastfolk-luka-v01.png`
  2. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/portraits/card-style-v01/bram.png`
  3. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/races-guests/art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png`
- `mira.md`의 Use case ~ World 공통 문단은 그대로 사용하고, 신규 인물용 참조 바인딩 보충 문단과 요청서 Subject를 덧붙임.
- 재생성 이력: 최초 생성 v01. 원본 PNG는 생성본 그대로 보존; 런타임은 전체 캔버스 비율 유지 축소·투명 여백 배치만 수행.

```text
Use case: style-transfer.
Asset: ONE production transparent-alpha HALF-BODY character portrait for Witch's Lodge.
Input 1 is this character's existing IDENTITY reference. Preserve THAT person's recognizable face, age, complexion, hair, expression, clothing colors and signature props. Input 2 is APPROVED BRAM V02: match its bold card-illustration style AND its complete, uncropped half-body composition with deliberate lower finish. Input 3 is the APPROVED NIB CHARACTER CARD: drawing style only, not goblin identity or card frame.

Redraw the input-1 character using thick tapered BLACK INK contours, strong internal ink shapes, large painted color planes, expressive lightly exaggerated adult features, decisive two/three-value shadows and restrained printed gouache/dry-brush texture, like input 2 and the artwork inside input 3. Make it look drawn by the same card illustrator. No realistic 3D shading, glossy airbrush or dense microtexture.

COMPOSITION IS CRITICAL: upright 4:5, ideally 1122x1402. Head to waist half-body, including COMPLETE shoulders, BOTH elbows, forearms and hands where visible. All hair, hat, clothes, arms and props must fit inside the canvas. Leave at least 6 percent genuinely transparent breathing room on ALL FOUR sides of the ENTIRE illustration, including below the lowest painted edge. Zoom out and reconstruct any anatomy missing in input 1. Nothing can touch or be chopped off by the rectangular canvas. Don't simply pad an already cropped portrait.
Finish lower torso below waist with a gently irregular curved hand-painted vignette edge, like Bram v02, fully surrounded by alpha; no hard straight horizontal crop, no severed arms. No legs or full body. Keep the face prominent, with similar head-to-body proportions to Bram v02. Natural character-appropriate hands/pose, not all the same pose.
Genuine transparent alpha everywhere outside the illustrated silhouette, clean antialiased edges. No colored fog, halo, rectangular background, frame, UI, label, badge, letters, watermark or extra figures.
World: medieval-based fantasy; familiar fantasy adaptations allowed while retaining medieval daily-life materials and atmosphere.

Input 1 IS the approved character IDENTITY reference: preserve that card character's face, species, colors, ears, ornaments and signature clothing/pack while removing ALL card frame, labels, scenery and text.
Anthropomorphic medieval beastfolk with the specified ANIMAL HEAD, muzzle, fur/feathers and animal ears forming a clear silhouette; NOT human with animal ears. Amber/cream clothing accents. Each animal species must be distinct; preserve Luka's identity only for Luka.
Avoid modern garments, firearms, goggles, plastic, anime eyes, airbrush, photorealism, additional characters, text, card borders, background scenes or halos. Ensure every prop fits with transparent breathing room. Subject wording is authoritative for identity; tiny book/map markings must be abstract ink shapes, no readable text.

Subject: Luka, the fox beastfolk guide from the approved card art `art/concepts/cards/roles-races-v01/04-beastfolk-luka-v01.png`: KEEP that character's fox face, fur colors, ears, amber cloak and ornaments. Reframe as a half-body portrait: one hand raised with a charming open palm as if saying "this way", tail tip visible at the edge of the silhouette. Expression: sly cheerful reassurance.
```



## 재생성 v02 · 최종 채택

승인 카드의 청색 외투·크림 목깃은 유지하되, 요청서 Subject의 호박색 망토가 v01에서 빠져 보완했다. 얼굴·털색·귀·표정·손짓·소품·꼬리를 유지한 편집이다. 당시 입력 1과 같은 v01 생성본은 `output/race-portraits-v01/drafts/luka-v01.png`에 보존했다.

참조: `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/races-guests/art/portraits/card-style-v01/races/luka.png` / `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/portraits/card-style-v01/bram.png` / `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/races-guests/art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png` / `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/races-guests/art/concepts/cards/roles-races-v01/04-beastfolk-luka-v01.png`

```text
Use case: style-transfer.
Asset: ONE production transparent-alpha HALF-BODY character portrait for Witch's Lodge.
Input 1 is this character's existing IDENTITY reference. Preserve THAT person's recognizable face, age, complexion, hair, expression, clothing colors and signature props. Input 2 is APPROVED BRAM V02: match its bold card-illustration style AND its complete, uncropped half-body composition with deliberate lower finish. Input 3 is the APPROVED NIB CHARACTER CARD: drawing style only, not goblin identity or card frame.

Redraw the input-1 character using thick tapered BLACK INK contours, strong internal ink shapes, large painted color planes, expressive lightly exaggerated adult features, decisive two/three-value shadows and restrained printed gouache/dry-brush texture, like input 2 and the artwork inside input 3. Make it look drawn by the same card illustrator. No realistic 3D shading, glossy airbrush or dense microtexture.

COMPOSITION IS CRITICAL: upright 4:5, ideally 1122x1402. Head to waist half-body, including COMPLETE shoulders, BOTH elbows, forearms and hands where visible. All hair, hat, clothes, arms and props must fit inside the canvas. Leave at least 6 percent genuinely transparent breathing room on ALL FOUR sides of the ENTIRE illustration, including below the lowest painted edge. Zoom out and reconstruct any anatomy missing in input 1. Nothing can touch or be chopped off by the rectangular canvas. Don't simply pad an already cropped portrait.
Finish lower torso below waist with a gently irregular curved hand-painted vignette edge, like Bram v02, fully surrounded by alpha; no hard straight horizontal crop, no severed arms. No legs or full body. Keep the face prominent, with similar head-to-body proportions to Bram v02. Natural character-appropriate hands/pose, not all the same pose.
Genuine transparent alpha everywhere outside the illustrated silhouette, clean antialiased edges. No colored fog, halo, rectangular background, frame, UI, label, badge, letters, watermark or extra figures.
World: medieval-based fantasy; familiar fantasy adaptations allowed while retaining medieval daily-life materials and atmosphere.

TARGETED COSTUME CORRECTION: Input 1 is the generated Luka portrait to EDIT. Input 4 is the original approved Luka card identity. Preserve EXACTLY the current fox face, eyes, orange/cream fur colors, ears, expression, cream neck scarf, blue medieval undercoat, ornaments, hands, open guiding palm pose, scrolls, pack and tail. Add the Subject's missing AMBER/OCHRE travel CLOAK as a clearly visible open-front drape over the shoulders and upper arms; retain the blue undercoat visible in the chest and keep both hands and the cream scarf visible. Amber cloth should visibly read as a cloak, not recolored fur. Only this costume correction; do not redesign the identity or pose. Keep black ink, color planes, painterly irregular waist edge, transparent outside, complete silhouette inside the canvas. No frame, text, scenery or extra figure. This is medieval based fantasy.

Subject: Luka, the fox beastfolk guide from the approved card art `art/concepts/cards/roles-races-v01/04-beastfolk-luka-v01.png`: KEEP that character's fox face, fur colors, ears, amber cloak and ornaments. Reframe as a half-body portrait: one hand raised with a charming open palm as if saying "this way", tail tip visible at the edge of the silhouette. Expression: sly cheerful reassurance.
```



## 최종 검수 · 2026-10-18

- 원본: `art/portraits/card-style-v01/races/luka.png` (1122×1402), 생성본과 SHA-256 일치.
- 런타임: `godot/assets/portraits/guest_luka_cutout.png` (RGBA 1122×1402), 알파·사방 6% 여백 통과.
- 실제 생성 출력: `C:\Users\vnvnc\.codex\generated_images\01a14d65-9417-7142-9210-2491a7275536\exec-9cfc65c4-ce30-474d-b287-09c139022c9f.png`.
- 시각 검수: v02: 승인 원화의 여우 얼굴·주황/크림 털·귀·청색 외투/크림 목깃·장식을 유지하고 열린 안내 손바닥·꼬리·호박색 망토를 확인.
- 원본 SHA-256: `660F4ECB4D3F488B868A45E83E6EF39C7011031C752D1AF58784CD59BF55B469`.
- 런타임 SHA-256: `1030AEB2DCF56E564B495941847EACA61042FD4DF371D1DB7B3D5F117D65B733`.
- 제외한 v01: `output/race-portraits-v01/drafts/luka-v01.png`.

