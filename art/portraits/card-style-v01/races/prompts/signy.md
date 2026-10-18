# signy · dwarf 포트레이트

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

Subject: Signy, a cheerful dwarf brewer traveler, adult woman, round flushed cheeks, golden hair in a crown braid, laughing eyes, freckles. Cream linen blouse, red-brown bodice, small wooden cask slung by a strap over her shoulder, pewter tankard hooked to belt. One hand raising the tankard in a toast, other hand on the cask. Expression: hearty laughing welcome.
```


## 최종 검수 · 2026-10-18

- 원본: `art/portraits/card-style-v01/races/signy.png` (1122×1402), 생성본과 SHA-256 일치.
- 런타임: `godot/assets/portraits/guest_signy_cutout.png` (RGBA 1122×1402), 알파·사방 6% 여백 통과.
- 실제 생성 출력: `C:\Users\vnvnc\.codex\generated_images\01a14d65-9417-7142-9210-2491a7275536\exec-b02383ef-ba2b-4409-a980-0ff25c7591b9.png`.
- 시각 검수: 황금 땋은 머리·미소·건배 잔·작은 나무 술통.
- 원본 SHA-256: `7DE816CC746E445971255957958A224DA5C7B580BEB9486E1E3E6365CAA5FCC6`.
- 런타임 SHA-256: `0B84F4F33B65CE934C0B4BC655F0FC71C1D0B7E1B104ECBED12217F26D2005B1`.

