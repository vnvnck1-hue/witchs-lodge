# HUD 초상 분리용 기존 패널 편집

내장 image_gen. 기존 HUD의 마녀 그림만 지우고 별도 TextureRect로 새 마녀 초상을 올린다. 기존 프레임·텍스트·게이지 배치를 보존한다.

```text
Use case: precise-object-edit.
Asset: existing transparent game HUD status panel backing, not a new UI design.
Input image 1 is the CURRENT GAME HUD sprite (577x195). Remove ONLY the small illustrated witch person inside the LEFT circular crescent-moon medallion: remove her hat, face, hair, hand and body. Rebuild the underlying plain dark-purple disk cleanly so a separate transparent character portrait can later be layered there by the game.
Keep the cream crescent moon, thin ring contours, teal curls and star, the entire two-row right status panel, heart icon, house icon, the Korean words "마녀" and "산장", empty dark horizontal gauge tracks, blank numeric areas, outer transparency, color, exact silhouette, relative positions and proportions UNCHANGED.
Do not add any character, face, hat, silhouette or placeholder. The left medallion interior must be an empty dark purple disk with its existing cream crescent and teal decorative marks. No modern UI changes. Preserve original wide 577:195 aspect ratio and matching coordinate layout exactly. Full panel contained, not chopped. Genuine transparent background outside the original HUD. No new text, no numbers, no additional icons.
```
