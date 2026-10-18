# ormu · dwarf 포트레이트

- 내장 image_gen 개별 생성 v01, 실제 투명 배경 요청.
- 참조 입력: `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/portraits/card-style-v01/bram.png` / `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/portraits/card-style-v01/bram.png` / `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/races-guests/art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png`
- 재생성 이력: 최초 생성 1회. 원본 보존, 런타임 전체 캔버스 비율 유지 축소 및 투명 여백 배치.

```text
Use case: style-transfer.
Asset: ONE production transparent-alpha HALF-BODY character portrait for Witch's Lodge.
Input 1 is this character's existing IDENTITY reference. Preserve THAT person's recognizable face, age, complexion, hair, expression, clothing colors and signature props. Input 2 is APPROVED BRAM V02: match its bold card-illustration style AND its complete, uncropped half-body composition with deliberate lower finish. Input 3 is the APPROVED NIB CHARACTER CARD: drawing style only, not goblin identity or card frame.

Redraw the input-1 character using thick tapered BLACK INK contours, strong internal ink shapes, large painted color planes, expressive lightly exaggerated adult features, decisive two/three-value shadows and restrained printed gouache/dry-brush texture, like input 2 and the artwork inside input 3. Make it look drawn by the same card illustrator. No realistic 3D shading, glossy airbrush or dense microtexture.

COMPOSITION IS CRITICAL: upright 4:5, ideally 1122x1402. Head to waist half-body, including COMPLETE shoulders, BOTH elbows, forearms and hands where visible. All hair, hat, clothes, arms and props must fit inside the canvas. Leave at least 6 percent genuinely transparent breathing room on ALL FOUR sides of the ENTIRE illustration, including below the lowest painted edge. Zoom out and reconstruct any anatomy missing in input 1. Nothing can touch or be chopped off by the rectangular canvas. Don't simply pad an already cropped portrait.
Finish lower torso below waist with a gently irregular curved hand-painted vignette edge, like Bram v02, fully surrounded by alpha; no hard straight horizontal crop, no severed arms. No legs or full body. Keep the face prominent, with similar head-to-body proportions to Bram v02. Natural character-appropriate hands/pose, not all the same pose.
Genuine transparent alpha everywhere outside the illustrated silhouette, clean antialiased edges. No colored fog, halo, rectangular background, frame, UI, label, badge, letters, watermark or extra figures.
World: medieval-based fantasy; familiar fantasy adaptations allowed while retaining medieval daily-life materials and atmosphere.

Reference binding for this NEW character: input 1 is only a STYLE/COMPOSITION reference, NOT human identity. Design the distinct dwarf specified below, NOT Bram's face. Input 2 remains Bram style/composition; input 3 is Nib drawing style only. Dwarves are stocky, broad-shouldered with proportionately large heads. Copper and stone accents in clothing/props only. Keep every prop inside the alpha silhouette. No realism, anime, background or extra figures.

Subject: Ormu, a dwarf ruin surveyor traveler, middle age, dust-grey beard trimmed short, intense squinting eyes, stone dust on cheeks. Heavy hooded travel coat with many sample pockets, a chipped carved stone fragment held up in one hand, small geologist hammer and chisel at belt, rolled leather map case. Expression: absorbed fascination, as if about to argue.
```


## 재생성 v02 · 최종 채택

v01은 브람 얼굴·털깃 복장의 영향이 강해 제외했다. v02는 별도 드워프 얼굴·체형과 회색 조사 외투로 재제작했다. 아래는 실제 재생성 프롬프트다.

참조: `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/art/portraits/card-style-v01/bram.png` / `D:/2020_이전승찬파일/작업,내파일/2026/프로토타입 게임/마녀산장/.claude/worktrees/races-guests/art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png`

```text
THIS IS A NEW DISTINCT DWARF DESIGN, not a redraw of Bram or Nib. The two supplied images are STYLE REFERENCES ONLY. No existing identity reference is supplied. The historical common template below mentions identity input 1 / style inputs 2 and 3; for THIS request that mapping is superseded by: actual input 1 Bram STYLE/LOWER EDGE ONLY, actual input 2 Nib INK STYLE ONLY. Do not copy either face, hairstyle, clothes, fur collar, pose or anatomy. The SUBJECT at the end defines all identity and clothes.

Use case: style-transfer.
Asset: ONE production transparent-alpha HALF-BODY character portrait for Witch's Lodge.
Input 1 is this character's existing IDENTITY reference. Preserve THAT person's recognizable face, age, complexion, hair, expression, clothing colors and signature props. Input 2 is APPROVED BRAM V02: match its bold card-illustration style AND its complete, uncropped half-body composition with deliberate lower finish. Input 3 is the APPROVED NIB CHARACTER CARD: drawing style only, not goblin identity or card frame.

Redraw the input-1 character using thick tapered BLACK INK contours, strong internal ink shapes, large painted color planes, expressive lightly exaggerated adult features, decisive two/three-value shadows and restrained printed gouache/dry-brush texture, like input 2 and the artwork inside input 3. Make it look drawn by the same card illustrator. No realistic 3D shading, glossy airbrush or dense microtexture.

COMPOSITION IS CRITICAL: upright 4:5, ideally 1122x1402. Head to waist half-body, including COMPLETE shoulders, BOTH elbows, forearms and hands where visible. All hair, hat, clothes, arms and props must fit inside the canvas. Leave at least 6 percent genuinely transparent breathing room on ALL FOUR sides of the ENTIRE illustration, including below the lowest painted edge. Zoom out and reconstruct any anatomy missing in input 1. Nothing can touch or be chopped off by the rectangular canvas. Don't simply pad an already cropped portrait.
Finish lower torso below waist with a gently irregular curved hand-painted vignette edge, like Bram v02, fully surrounded by alpha; no hard straight horizontal crop, no severed arms. No legs or full body. Keep the face prominent, with similar head-to-body proportions to Bram v02. Natural character-appropriate hands/pose, not all the same pose.
Genuine transparent alpha everywhere outside the illustrated silhouette, clean antialiased edges. No colored fog, halo, rectangular background, frame, UI, label, badge, letters, watermark or extra figures.
World: medieval-based fantasy; familiar fantasy adaptations allowed while retaining medieval daily-life materials and atmosphere.

THIS IS A NEW DISTINCT DWARF DESIGN, not a redraw of Bram or Nib. The two supplied images are STYLE REFERENCES ONLY. No existing identity reference is supplied. The historical common template below mentions identity input 1 / style inputs 2 and 3; for THIS request that mapping is superseded by: actual input 1 Bram STYLE/LOWER EDGE ONLY, actual input 2 Nib INK STYLE ONLY. Do not copy either face, hairstyle, clothes, fur collar, pose or anatomy. The SUBJECT at the end defines all identity and clothes.
DRAW A CLEAR CLASSIC DWARF: enormous broad bulbous nose, very wide squat round head, close-set deep eyes, heavy low forehead, head large relative to compressed torso, SHORT thick neck, thick short forearms. A distinct balding middle-aged dwarf with a short dust-grey squared beard, hooded HEAVY TRAVEL COAT of grey wool (no cream fur, no green cloak, no pauldrons). Stocky rustic surveyor, not a handsome human warrior. Intense squint inspecting chipped stone with bare hand; pockets of stone samples and rolled leather map case. Keep other hand fully visible. Transparent, no scene.

Subject: Ormu, a dwarf ruin surveyor traveler, middle age, dust-grey beard trimmed short, intense squinting eyes, stone dust on cheeks. Heavy hooded travel coat with many sample pockets, a chipped carved stone fragment held up in one hand, small geologist hammer and chisel at belt, rolled leather map case. Expression: absorbed fascination, as if about to argue.
```



## 최종 검수 · 2026-10-18

- 원본: `art/portraits/card-style-v01/races/ormu.png` (1072×1467), 생성본과 SHA-256 일치.
- 런타임: `godot/assets/portraits/guest_ormu_cutout.png` (RGBA 1122×1402), 알파·사방 6% 여백 통과.
- 실제 생성 출력: `C:\Users\vnvnc\.codex\generated_images\01a14d65-9417-7142-9210-2491a7275536\exec-db5e8064-f653-4467-8978-6bd8f5f40973.png`.
- 시각 검수: v02: 넓은 코·벗겨진 이마·짧은 회색 수염·회색 조사 외투·돌 조각.
- 원본 SHA-256: `A0EA808790F79974345B075224E9CD0E812A1FE06395AC69C8A22BB0BBE45EAD`.
- 런타임 SHA-256: `074F9BED61A2F85DBD7B1B450CD063CF191631D52B1BA4256C1A64C10CC5BBEC`.
- 제외한 v01: `output/race-portraits-v01/drafts/ormu-v01.png`.

