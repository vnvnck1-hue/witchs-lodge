# 기존 카드 2:3 비율 복원 v05

2026-10-16 · 내장 image_gen · 기존 `gatherer.png`, `guest_invitation.png`를 기본 디자인으로 사용.

사용자는 v04 비교판의 카드가 위아래로 찌그러져 보인다고 지적했다. 가로 비교판에 두 장을 함께 넣던 방식을 중단하고 각 카드를 별도의 1024×1536 이미지로 생성한다. 기존 S자 프레임과 이름·설명 패널 비율을 유지하고 인물/사건 원화창 모양만 달리한다. 원화창은 어두운 회색, 텍스트는 비운다.

## 인물

```text
Use case: precise-object-edit. Correct a card-format concept for Witch's Lodge. Create ONE SINGLE CARD ONLY, full image strictly PORTRAIT 2:3 (1024x1536). This is NOT a comparison sheet. NO heading outside, NO second card, NO margins consuming card height. The existing source images are 1024x1536; preserve their exact TALL SLENDER card proportions, aspect 0.6667. Card stock occupies entire image just as source. Never widen the card, never squash vertically, never use a landscape output. Card body has slightly rounded outer corners.
Reference images 1 and 2 are EXISTING IN-GAME cards and the authoritative design base. Preserve their dusty purple stock, huge organic asymmetrical BLACK S-shaped calligraphic side curves, upper warm CREAM wavy title panel at roughly upper 17% of height, and lower warm CREAM wavy rules panel around lower 20%. Keep the long vertical flow of the original sides and same spatial proportions. No metal bevel, no gold thin rim, jewel, corner ornament, temple frame, rigid straight mechanical border. Hand-inked storybook graphic, subtle paper texture only on purple/cream.
Remove ALL existing illustration and words. The title and rules paper panels must be BLANK, no names, numbers, placeholders, dummy lines or role text. Keep the ARTWORK area flat dark gray #34363A with absolutely NO illustration, objects, gradient, icons or texture. This is frame design only. User wants only a different art-window shape introduced into the ORIGINAL S-ink format; do not redesign header/footer or compress the body.

CHARACTER artwork window: tall slender arched opening between header and footer, smooth domed top, straight vertical sides, flat horizontal bottom. Maximum gray opening width about 78% card width, height about 55% card height. The arch crown starts immediately beneath title panel, near y=310 of 1536, straight lower edge near y=1190. Bold black organic outline merges into original S brush flow. Side S curves remain OUTSIDE the gray opening. Preserve ample vertical portrait room and original cream footer. Render full-height original card proportions, not the recently compressed board design.
```

## 사건

```text
Use case: precise-object-edit. Correct a card-format concept for Witch's Lodge. Create ONE SINGLE CARD ONLY, full image strictly PORTRAIT 2:3 (1024x1536). This is NOT a comparison sheet. NO heading outside, NO second card, NO margins consuming card height. The existing source images are 1024x1536; preserve their exact TALL SLENDER card proportions, aspect 0.6667. Card stock occupies entire image just as source. Never widen the card, never squash vertically, never use a landscape output. Card body has slightly rounded outer corners.
Reference images 1 and 2 are EXISTING IN-GAME cards and the authoritative design base. Preserve their dusty purple stock, huge organic asymmetrical BLACK S-shaped calligraphic side curves, upper warm CREAM wavy title panel at roughly upper 17% of height, and lower warm CREAM wavy rules panel around lower 20%. Keep the long vertical flow of the original sides and same spatial proportions. No metal bevel, no gold thin rim, jewel, corner ornament, temple frame, rigid straight mechanical border. Hand-inked storybook graphic, subtle paper texture only on purple/cream.
Remove ALL existing illustration and words. The title and rules paper panels must be BLANK, no names, numbers, placeholders, dummy lines or role text. Keep the ARTWORK area flat dark gray #34363A with absolutely NO illustration, objects, gradient, icons or texture. This is frame design only. User wants only a different art-window shape introduced into the ORIGINAL S-ink format; do not redesign header/footer or compress the body.

EVENT artwork window: a wide landscape rectangle in the central area, gently rounded corners and straight nearly horizontal top/bottom. Gray opening spans about x=105 to x=920 in a 1024-wide card and y=490 to y=1060 in a 1536-tall card, landscape ratio approximately 1.43. The card BODY itself must still remain TALL 2:3, even though the art window is landscape. Use dusty PURPLE stock breathing room between upper cream title bubble and rectangle, and between rectangle and lower cream rules bubble, preserving original header/footer SIZE and LOCATION. Do not solve by enlarging the bottom paper into half the card, or by making whole card landscape or squat. The strong S-ink curves flow vertically around the dark-gray rectangular window, remaining outside it. Single unified blank original-style lower cream rules panel, no split or scroll decorations.
```
