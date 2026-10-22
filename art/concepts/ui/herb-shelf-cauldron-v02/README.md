# 약초 선반과 마녀의 솥 UI 컨셉 v02

- 제작일: 2026-10-22
- 상태: 사용자 검토용. 게임 미적용, 사용자 승인 전.
- 사용자 피드백: v01의 픽셀 화풍을 게임의 기존 화풍에 맞출 것.
- 제작 도구: 내장 image_gen.
- 결과: herb-shelf-cauldron-v02.png
- 실제 참고 입력: 승인 시설 카드 `../../cards/roles-individual-v02/05-facility-forest-altar.png`, 승인 자원 카드 `../../cards/roles-individual-v02/03-resource-timber.png`(먹선·페인터리 화풍); 승인 산장 환경 `../../environment/layout-a-game-camera-v03-style/01-layout-a-style-restored.png`(형태·재질); 이전 `../herb-shelf-cauldron-v01/herb-shelf-cauldron-v01.png`(구도만).
- 시각 확인: 픽셀 윤곽을 유기적인 검은 먹선으로 변경. 보라 그림자·앰버 목재·크림 패널·보라 조합 버튼·명확한 명암 적용. 선반 2단 8개 병, 선택 병과 약초 이동, 하단 솥·거품·증기·불 구도 유지. 안내·버튼 한글 확인.

## 실제 생성 프롬프트

Use case: style-transfer
Asset type: revised landscape 16:9 game UI concept for the existing game 마녀산장.
The user has REJECTED the pixel-art style of the previous mockup and explicitly requires the established game's art style. Repaint the entire scene, not a pixel-art upscale.

INPUT ROLES, in order:
Image 1: APPROVED GAME ART STYLE reference, forest altar card. Closely follow the ILLUSTRATION inside its art window: bold tapered black ink contours, warm amber timber, purple shadow masses, painted printed-storybook surfaces, strongly defined light and shadow.
Image 2: APPROVED GAME ART STYLE reference, timber resource card. Closely follow its illustrative brushwork, chunky readable object silhouettes, bold ink and broad color masses. These two images define the drawing style.
Image 3: APPROVED environment SHAPE AND MATERIAL reference. Slightly exaggerated chunky cozy medieval fantasy props, simplified larger material features. Do not copy its outdoor snow setting or bird's-eye camera.
Image 4: EDIT TARGET and COMPOSITION ONLY: previous herb-shelf/cauldron mockup. Keep its close frontal two-row herb cabinet above, large central bubbling cauldron immediately below, selected yellow-flower jar and downward dragging interaction. Its PIXEL STYLE IS WRONG and must be completely replaced by the approved ink-and-painterly style of images 1 and 2.

PRIMARY TASK: Draw the herb-selection-and-cauldron interface as if it were a new interior illustration painted by the same artist as our approved game cards. Make the stylistic match unmistakable: bold variable-width black ink outlines on cabinet, jar silhouettes, corks, herbs, cauldron and hearth stones; simplified broad painted color areas; decisive 2–3-tone shading; warm amber light against indigo and purple ambient shadows; restrained tactile gouache/printed texture. Continuous smooth drawn contours, organic brush shapes, NO square pixel clusters, NO pixelated fonts, NO dithering. NOT generic realistic fantasy painting.
Composition remains a continuous full-screen scene in landscape 16:9: top about 58% has two chunky wooden shelves, four large distinct herb jars per row, each colorful herb species legible. Lower center about 42% has a wide large black cast-iron witch's cauldron, broad elliptical open rim and vivid green bubbling potion seen slightly from above, curling broad brush-shaped steam, small warm fire and chunky stone hearth. The lower cauldron must be a large usable drop target directly below the jars. Keep the close cabinet view, not a distant room.
Reduce small extraneous decorations and texture noise from image 4. Keep a small skull, a couple of worn books and restrained candles only as subordinate edge decorations. Herbs should be stylized large leaves/flower silhouettes rather than finely realistic botanical detail. No character obstructing the UI.
Interaction: selected yellow-flower jar gets a restrained cream-gold outline; one loose yellow flower bundle and a smoothly drawn cream hand cursor between jar and cauldron; short sparse curved dotted trail. Subtle cream-gold cauldron rim drop-target accent. Small cream parchment quantity tags with herb pictograms. Existing example quantities can remain.
UI trim should share the game's purple, cream paper and variable-width black ink language. Bottom-left small cream parchment with gently irregular black ink border, exact Korean "약초를 솥에 넣으세요". Bottom-right compact PURPLE button, cream inset and organic thick black ink contour, exact Korean "조합하기". Keep legibility. Do NOT turn the whole screen into a card; no card title panels, no card artwork frame, no card categories.
World: medieval-based fantasy, preserving medieval daily-life atmosphere with familiar fantasy adaptations. Wood, iron, glass, cork, parchment, candlelight. No modern objects.
Deliver one polished concept screenshot, no collage, no comparison board, no watermark. The style correction is the priority: APPROVED GAME STORYBOOK INK AND PAINTERLY ART, NOT PIXEL ART.

