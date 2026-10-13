# 실제 게임 화면 카드 손패 합성

제작일: 2026-10-13 · 도구: 내장 image_gen · 범위: 실제 스크린샷 위 배치 시안

배경: godot/screenshots/art-refinement/v24-source-clean.png
입력 카드: base-card-format-approved-v01.png, wool-resource-v01.png, forest-monster-summon-v01.png
결과: art/concepts/cards/game-screen-hand-v01.png

하단 중앙에 도끼 용병·양털·숲의 괴물을 차례로 배치. 1600×800 기준 각 카드 약 124×186, 중심 X=644/800/956, 상단 Y≈602. 마녀·산장·목장·상단 접근로가 보이도록 낮고 작게 배치한다. 이는 합성 시안이며 런타임 UI 구현은 아니다.

## 최종 프롬프트

첫 합성은 카드 크기가 요청보다 커 마녀를 가렸다. 아래 1차 프롬프트를 보존하고, 두 번째 생성에서 카드 크기·하단 위치를 수정했다. 최종 결과 파일: art/concepts/cards/game-screen-hand-v02.png.

### 수정 프롬프트

Use case: precise-object-edit / compositing. Correct ONLY the bottom card HUD placement in Image 1, the first composite. Image 2 is the original unmodified game screenshot and is the authority for restoring any scene regions covered by old cards. Images 3,4,5 are the exact axe mercenary, wool and forest monster card assets.
Critical correction: current cards are MUCH TOO BIG and cover the purple witch! Shrink EACH card to precisely TWO THIRDS its current width and height, and anchor the whole hand lower. All three cards must fit within the BOTTOM 24 PERCENT of the image, not the bottom 37 percent. Their TOP edges must be BELOW the witch's feet. Restore the WHOLE purple pointed-hat witch and the stone walkway from Image 2 at their exact original positions, above the cards. Witch must be clearly fully visible with empty snow gap between her feet and the top of the cards. Never move, resize or omit the witch to solve overlap.
Output same landscape 2:1 full screenshot composition. At output size 1774x887, target card height approximately 196px, width130px, top around y=678, bottom y=874. Three upright fully visible cards centered at x=724,887,1050. Thus complete hand fits a narrow bottom strip with card upper edges below the player (witch occupies around y=600..662). At 1600x800 scale card height177px, top611, bottom788. Keep card titles and pictures identical to supplied assets, same order axe / wool / forest monster, very slight left and right tilt only if it still fits lower strip. No enlarged hover card, no fourth card. Small dark shadows only; no tray or panel.
Keep the game scene exactly as Image 2: its lodge and three sheep, trees and rocks, purple snow, lighting, particles, original camera and exact locations. This is a direct HUD composite over a real screenshot. Do not repaint the scene. Restore ground in the old larger-card footprint from Image 2. Do not change card designs or lettering. No added UI counters, icons, health bars, labels, new text, arrow, glow or borders.
The final must look like the SAME screenshot with three much SMALLER compact UI cards at the very bottom and the ORIGINAL purple witch fully visible above the center card.

### 1차 프롬프트

Use case: compositing. Asset type: faithful game screenshot composite / HUD placement mockup for the Korean Godot game 마녀산장.
Input image 1: EDIT TARGET, actual 1600x800 latest v24-source-clean game screenshot. Keep its full landscape 2:1 canvas, game world, fixed camera, lighting, lodge, pasture, three sheep, witch, pine trees, rocks, ground, particles and their exact locations visually unchanged. Do not repaint or improve the game environment. The point is to assess actual supplied cards OVER THE REAL GAME SCREEN.
Input images 2,3,4: supporting insert assets, respectively APPROVED 도끼 용병 card, 양털 resource card, 숲의 괴물 summon card. Copy these three exact finished illustrated cards faithfully as 2D screen-space HUD graphics, retaining their illustrations, all Korean lettering, dusty purple silhouettes, asymmetric S-sweep black contours and cream title/rules panels. Do not invent or redesign cards. Remove only the black rectangular outside-corner canvas so each card has its existing rounded card silhouette.
Primary request: place exactly these THREE cards in a compact lower-center hand, like a usable actual gameplay HUD. Landscape output same 2:1 aspect ratio, same framing as screenshot.
Placement at 1600x800 reference scale: each card about 124px wide and 186px high, all fully visible; tops around y=602 and bottoms around y=788. Centers approximately x=644 (axe mercenary), x=800 (wool), x=956 (forest monster). A quiet shallow hand arc is allowed, left card tilt minus 4 degrees, central upright, right plus 4 degrees, but no heavy overlap and title and illustration of every card must remain visible. Add only a small restrained dark drop shadow behind the cards to distinguish UI from snow. No enclosing opaque panel, deck tray, banner or decorative chrome. This compact sizing leaves the witch at roughly x=825,y=565 fully visible ABOVE the card row and keeps lodge, pasture and both upper approach paths completely unobstructed. Keep screenshot visible across full frame behind UI.
Do not add mana, costs, stats, gold counters, hearts, other buttons, new text, arrows, explanatory captions, desktop borders or labels. Do not add an enlarged fourth card or duplicated card. No perspective as physical cards standing on the ground: these are flat HUD inserts. No glow outlines.
Exact card lettering must remain as source assets: card 2 '도끼 용병', '용병 · 일회 계약', '나무에 사용하면 벌목합니다.', '작업을 마치면 귀가합니다.'; card 3 '양털', '자원 · 수확 재료', '양에게 다가가 수확합니다.', '산장에서 판매할 수 있습니다.'; card 4 '숲의 괴물', '몬스터 · 하수인 소환', '처치하면 카드를 얻습니다.', '사용하면 하수인을 소환합니다.'.
Output a single complete polished composite image only. Faithful existing screenshot plus supplied exact card assets, with all differences restricted to the small bottom hand UI footprint.
