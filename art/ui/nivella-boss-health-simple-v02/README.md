# 니벨라 체력 UI — 심플 시안 2종 v02

- 제작일: 2026-10-23
- 도구: 내장 image_gen, 불투명 배경.
- 사용자 피드백: 앞선 v01의 과한 장식을 줄이되 두꺼운 체력 게이지를 유지.
- 두 이미지 모두 이전에 실제 게임에서 촬영한 동일 보스전 캡처 `../nivella-boss-health-concept-v01/00-boss-fight-capture.png` 위에 합성.
- 게임 런타임 변경 없음.

## 시안

- [A — 아이보리 테두리형](01-a-ivory-minimal.png): 작게 둥근 직사각형 게이지와 얇은 아이보리 테두리. 이름 왼쪽 정렬, 원형 3단 표시.
- [B — 서리 포인트형](02-b-frost-minimal.png): 작은 사선 모서리, 얇은 은청색 테두리와 양 끝의 미세한 포인트. 이름 가운데 정렬, 작은 마름모 3단 표시.

두 안 모두 거미 문장·초상·다리 장식·거미줄·큰 보석 소켓을 제거했다. 채움 영역 자체가 기존 임시 바보다 두껍고, 총 체력 수치와 피격 잔상을 중심으로 읽힌다.

## 검수

같은 화면·상태에서 윤곽과 정보 배치를 비교하도록 구성했다. 생성형 합성으로 배경과 글자의 픽셀 단위 보존, 수치와 채움 폭의 정합성은 보증하지 않는다. 실제 게임 반영 전 콘셉트 원화다.

## 실제 프롬프트

### A

```text
Use case: ui-mockup / compositing.
Asset type: simplified boss-health HUD concept over the user's actual current Witch's Lodge boss battle screenshot, one full 16:9 screenshot.
Input image 1 is the SCREENSHOT EDIT TARGET. Preserve its exact camera, giant spider model/pose, player, arena, eggs, web, lighting, attack telegraphs and all unrelated HUD elements. Replace ONLY the temporary BOSS HEALTH UI in the upper center: old boss name/subtitle, old thin health gauge, its three primitive diamonds, and its -48 readout. Do not repaint the scene or the rest of the interface.
User feedback: previous ornamental redesign was FAR TOO ELABORATE. This version must be restrained, compact, simple and very legible. ABSOLUTELY NO spider portrait or medallion, no horns, wings, spider-leg framing, web ornament, icicles, carved filigree, decorative flourishes or big gemstone sockets. No new mechanics.
Keep the HEALTH FILL ITSELF chunky and thick, approx 34-38px tall in a 1600x900 screenshot; original was ~17px. Compact horizontal health gauge, approx 720px long, centered at x=440..1160, y=151..187 in 1600x900 coordinates. Name row immediately above it within y=119..143. Main UI should stop above y=205 and remain below the existing clock with a comfortable gap, no large opaque backplate.
Text: large simple readable ivory “니벨라”, smaller muted ivory subtitle “서리 둥지의 여왕” beside it, with an unobtrusive dark outline. Three SMALL simple stock indicators upper right on the name row, showing 3 remaining stocks, plus a small clear “×3”; no elaborate decorated jewels. Filled health is vivid muted amethyst violet, approx84% of the current-stock track, short pale-ivory trailing damage region to90%, last10% clearly empty dark purple. No faceted triangular mosaic fill, no patterned noise, no busy stripes. Broad smooth fill, narrow soft upper highlight, deep lower shade. Numeric “852 / 900” centered in the thick gauge, ivory with dark shadow; optional small “-48” immediately below the cutoff, understated. Gauge should stand out from icy-blue background using clean contrast, not oversized ornament.
Match the game's hand-painted medieval-fantasy HUD vocabulary, deep plum and ivory, sparse cyan if specified. Preserve source's top-left player and house health, clock, currencies, task panel, bottom UI and debug values. No new labels or concept title drawn on the screenshot, no comparison layout, no annotations, no watermark. VARIANT A, clean ivory border: ONE simple long rounded rectangular recessed plum-black track with slightly rounded 6px corners and a single thin warm-ivory 1.5-2px outline. Soft compact drop shadow for contrast. Square-ended health fill with subtle shading only; fill 36px tall. The frame is uniform and straight, NO extended end caps or pointed flourishes. Name is left-aligned with bar, subtitle beside it. Three tiny circular stock dots at name-row right, ivory-edged violet/amber/red centers, all about7px diameter, followed by small ×3. Name/HP/stock information form a clean single unit. Its simplicity should feel deliberate and polished. This is the most restrained, familiar, minimal version with a strong thick readable bar.
```

### B

```text
Use case: ui-mockup / compositing.
Asset type: simplified boss-health HUD concept over the user's actual current Witch's Lodge boss battle screenshot, one full 16:9 screenshot.
Input image 1 is the SCREENSHOT EDIT TARGET. Preserve its exact camera, giant spider model/pose, player, arena, eggs, web, lighting, attack telegraphs and all unrelated HUD elements. Replace ONLY the temporary BOSS HEALTH UI in the upper center: old boss name/subtitle, old thin health gauge, its three primitive diamonds, and its -48 readout. Do not repaint the scene or the rest of the interface.
User feedback: previous ornamental redesign was FAR TOO ELABORATE. This version must be restrained, compact, simple and very legible. ABSOLUTELY NO spider portrait or medallion, no horns, wings, spider-leg framing, web ornament, icicles, carved filigree, decorative flourishes or big gemstone sockets. No new mechanics.
Keep the HEALTH FILL ITSELF chunky and thick, approx 34-38px tall in a 1600x900 screenshot; original was ~17px. Compact horizontal health gauge, approx 720px long, centered at x=440..1160, y=151..187 in 1600x900 coordinates. Name row immediately above it within y=119..143. Main UI should stop above y=205 and remain below the existing clock with a comfortable gap, no large opaque backplate.
Text: large simple readable ivory “니벨라”, smaller muted ivory subtitle “서리 둥지의 여왕” beside it, with an unobtrusive dark outline. Three SMALL simple stock indicators upper right on the name row, showing 3 remaining stocks, plus a small clear “×3”; no elaborate decorated jewels. Filled health is vivid muted amethyst violet, approx84% of the current-stock track, short pale-ivory trailing damage region to90%, last10% clearly empty dark purple. No faceted triangular mosaic fill, no patterned noise, no busy stripes. Broad smooth fill, narrow soft upper highlight, deep lower shade. Numeric “852 / 900” centered in the thick gauge, ivory with dark shadow; optional small “-48” immediately below the cutoff, understated. Gauge should stand out from icy-blue background using clean contrast, not oversized ornament.
Match the game's hand-painted medieval-fantasy HUD vocabulary, deep plum and ivory, sparse cyan if specified. Preserve source's top-left player and house health, clock, currencies, task panel, bottom UI and debug values. No new labels or concept title drawn on the screenshot, no comparison layout, no annotations, no watermark. VARIANT B, restrained frost edges: ONE straight deep-plum wide gauge with tiny chamfered 45-degree corners, not rounded like variant A; outer contour a thin cold silver-blue line with just two compact solid muted silver end brackets each4px wide and flush to the gauge. A narrow cyan line along top lip and a few tiny pale frost notches ONLY at the two outer corners, NO icicles, crystals, snowflakes, webs or filigree. Health fill 36px high, smooth violet with a restrained cold top highlight. There is NO giant central badge, NO side portrait and no sticking-out ornament. Name and subtitle are CENTERED on a single row immediately above the bar, remaining very compact; three tiny flat diamond stock ticks aligned at far right of name row (no sockets, only7px each) followed by ×3. Clean slightly angular silhouette, restrained cool accent distinguishes it from a warm ivory rounded frame, while remaining as simple and uncluttered as possible. Keep all design weight in the thick fill, not in framing.
```

