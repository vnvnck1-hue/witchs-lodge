# 게임 배경의 아주 약한 화풍 보정

도구: 내장 image_gen · 2026-10-13

사용자는 v01이 원본을 지나치게 바꾸었다고 지적했다. 원래 큰 카드 합성본에서 다시 시작하며, 3D 형태·색·부드러운 명암·지면 질감·카드 배치를 유지한다. 목재 연결부·일부 바위 눈 경계·나뭇가지 깊은 틈에만 매우 약한 붓선과 목재 면의 제한된 붓질을 추가한다.

입력: art/concepts/cards/game-screen-hand-v01.png
결과: art/concepts/environment/08-card-style-game-paintover-v02.png

## 최종 프롬프트

Use case: precise-object-edit.
Edit the supplied ORIGINAL gameplay composite with an EXTREMELY SUBTLE finishing pass. The user rejected the previous full illustration-style repaint because it changed the game too much. Use ONLY THIS ORIGINAL IMAGE as the source; do not remake the scene.
Keep approximately 95 percent of the original visual appearance. At first glance the result should look like the SAME 3D game screenshot, with just slightly more hand-painted character. Keep the smooth rounded chunky 3D meshes, their original silhouettes, original soft volumetric shading, original violet snow, original cool dark green trees, original warm windows, smoke, shadows, all object locations, the exact top-down camera and framing. The three large cards at the bottom stay COMPLETELY UNCHANGED in size, position, tilt, illustration and Korean text.
Only tiny local edits on the background: add a few very thin, low-opacity dark-purple broken brush accents at EXISTING occlusion seams of the lodge's wooden beams and door frame, underneath a FEW rock snow caps, and in a FEW deep pine branch creases. Gently introduce a few restrained broad painterly accents on existing wooden surfaces. These are soft material accents, not drawn outlines around whole objects. Keep snow-covered surfaces nearly exactly as they are.
The card art is the inspiration for this SMALL finishing touch only. Do not apply its black outline strength, woodcut rendering, flat shading, ivory snow color or paper grain across the environment.
ABSOLUTELY preserve the original ground texture and all its colors; do not add speckles, dabs, hatching, grain or more contrast to the snow field. No global filter, no color grading, no shift toward cream/yellow, no thick black contours, no flattened lighting, no new textures over the entire image. Do not redraw trees, rocks, lodge or sheep. No geometry change, extra detail, props, UI, characters, labels or borders.
Output one same-size 2:1 landscape edited image. Preserve the original screenshot faithfully and change only the few subtle seam and wood-surface accents described. The result must be a light retouch, never a new cartoon painting.
