# shaga · orc 포트레이트

- 제작: 내장 `image_gen`, 투명 배경 요청, 개별 생성 1회.
- 참고 입력(읽기 전용):
  1. `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/portraits/card-style-v01/bram.png`
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

Reference binding override for this NEW character: Input 1 is a SPECIES/STYLE reference ONLY, NOT an existing identity. Design the distinct subject specified below, NOT Bram or Nib or Luka. Input 2 remains Bram style/composition and input 3 Nib drawing style only.
Orcs: broad build, green/olive skin, CLEAR short lower tusks, bone/leather/red earth pigment ornaments, warm communal characters rather than brutality. Each face/expression/clothing must be distinct.
Avoid modern garments, firearms, goggles, plastic, anime eyes, airbrush, photorealism, additional characters, text, card borders, background scenes or halos. Ensure every prop fits with transparent breathing room. Subject wording is authoritative for identity; tiny book/map markings must be abstract ink shapes, no readable text.

Subject: Shaga, a young orc shaman apprentice gatherer, slender for an orc, grey-green skin, ash-drawn white lines across the face, thoughtful downcast eyes, short tusks. Bundles of roots and dried mushrooms tied across the chest, a small clay bowl of ash held in both hands. Expression: quiet concentration, reverence.
```



## 최종 검수 · 2026-10-18

- 원본: `art/portraits/card-style-v01/races/shaga.png` (1122×1402), 생성본과 SHA-256 일치.
- 런타임: `godot/assets/portraits/guest_shaga_cutout.png` (RGBA 1122×1402), 알파·사방 6% 여백 통과.
- 실제 생성 출력: `C:\Users\vnvnc\.codex\generated_images\01a14d65-9417-7142-9210-2491a7275536\exec-7bf109ac-5131-4994-a336-bdc3ea67ff11.png`.
- 시각 검수: 회녹색 피부·흰 재 선·짧은 엄니·뿌리/버섯·양손의 재 그릇.
- 원본 SHA-256: `689CBF9D2247A67CF579FC03B87B1260325F0EABB85630DD07FAF86E1DC9864B`.
- 런타임 SHA-256: `2037C0B0FB7F8DDFABCB65323FA03E25294C2B2AC9B64F9536D6A839A9062789`.

