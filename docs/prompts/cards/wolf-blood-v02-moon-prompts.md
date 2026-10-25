# 늑대의 피 달 카드 v02 — 실제 생성 프롬프트

작업일: 2026-10-23 · 도구: 내장 `image_gen` (CLI/API 우회 사용 없음).

## 실제 참고 입력

- 매 카드의 편집 대상: `art/cards/wolf-blood-v02/previous/<id>.png` — 현재 게임의 글자 없는 PNG를 바이트 그대로 복사.
- 승인 스킬 포맷: `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png` (프레임·레이아웃 참고, 글자 복사 금지).
- 화풍: `godot/assets/cards/frost_rune.png`.
- 상현달·보름달 생성에는 새 초승달 생성본도 같은 하늘·화풍 참고 입력으로 전달.
- 모든 위 로컬 이미지를 먼저 열어 확인한 후 실제 이미지 생성 입력으로 사용.

## 초승달 — crescent_moon

```text
Use case: precise-object-edit. Edit the FIRST image, the current crescent_moon card. Image 2 is the approved skill frame/layout reference; image 3 is frost_rune, a watercolor-and-ink style reference only. Medieval-based fantasy world, familiar fantasy adaptations with a medieval atmosphere.
Output one upright 1024x1536 RGBA card. Preserve the first image's purple wave frame, BOTH completely BLANK cream text panels, side sparkle decorations, diamond black/cream border, rounded corners and transparent corner pixels in their exact original locations. Do not copy text from image 2. Change ONLY the artwork INSIDE the central diamond, not the exterior side scenery.
Replace ALL witch, human, hand, staff, person silhouettes, animals and objects in the diamond with a clean winter night sky and ONE large clear waxing crescent moon. The crescent is RIGHT-LIT: a slim luminous silver-white arc along the RIGHT side of the disc, pointed upper/lower tips, opening toward LEFT. NOT a left-lit crescent. Place the moon near x=512,y=655, full lunar disc diameter about 330 pixels, so it occupies about 44% of the window width and is immediately legible at 256x384 card size. Very faint earthshine may outline the dark disc. Simple deep indigo/blue-violet watercolor sky, a few tiny subdued stars, no cloud or branch crossing the moon, crisp clear lunar silhouette. At the lowest 15-20% of the diamond a low distant snow-covered conifer ridge is allowed, no foreground trees, no buildings, no people or animals. Restrained watercolor printed texture, large color shapes and crisp ink contours matching the references, silver moonlight and cool violet snow. Keep most of the scene open sky. No text, letters, numerals, symbols, badges or watermark. Keep both text panels empty. This is the first of a cohesive crescent/half/full lunar triptych, matching sky and palette.
```

생성 결과: `art/cards/wolf-blood-v02/drafts/crescent_moon-generated.png`. 재생성 없음.

## 상현달 — half_moon

```text
Use case: precise-object-edit. Edit image 1, the EXISTING half_moon game card. Image 2 is the approved skill layout (do NOT copy its lettering), image 3 is frost_rune style reference, image 4 is the new crescent card for cohesive sky/style/moon placement.
One upright 1024x1536 RGBA card, medieval-based fantasy atmosphere. Preserve image 1's exact purple wave frame, blank cream title and rules panels, sparkle ornaments, black/cream diamond frame, outside-diamond scenery, rounded silhouette and transparent corner pixels. Replace ONLY the picture inside the central diamond. Remove every witch/human/animal/object inside it.
Match image 4's open indigo/blue-violet winter night sky, restrained watercolor print texture, crisp ink contours, simple large color shapes and low distant snowy conifer ridge in the bottom 15-20%. Only a few subtle stars. ONE clear large FIRST QUARTER HALF MOON centered near x=512,y=665, diameter about 350px. Exactly the RIGHT 50 percent of the lunar disc is illuminated silver-white, the LEFT 50 percent is dark navy, with a perfectly straight clean VERTICAL terminator through its center. The outer illuminated edge is a perfect semicircle. NOT a crescent, NOT gibbous, NOT a curved terminator, not tilted. Dark left half may have very faint earthshine, far darker than the right. Gentle subtle lunar maria, restrained glow, uncluttered open sky. Readable half-disc silhouette at 256x384. No cloud or branch over moon; no people, animals, figures, buildings, props. No text, numbers, runes, symbols or watermark. Both cream panels remain entirely empty. Match the crescent card's palette, composition and painted winter-night style.
```

첫 결과: `art/cards/wolf-blood-v02/drafts/half_moon-generated.png`. 명암 경계의 굴곡을 없애고 정확한 수직 반달을 만들기 위해 한 번 보정 생성.

보정의 실제 입력: 위 첫 생성본 1장.

```text
Precise single-change repair of this half-moon card. Keep EVERYTHING about the supplied card exactly the same: composition, blank cream text panels, purple black cream frame, stars, snowy forest, watercolor print style, position and diameter of moon. Change ONLY the illuminated/dark boundary of the moon. It must be a clean perfectly STRAIGHT VERTICAL LINE exactly at the disc's center: precisely the right 50% bright silver white, left 50% deep dark indigo. No serrated or scalloped edge, no wavy terminator, no curved terminator, no gibbous phase. Understated lunar maria texture within the bright half is fine, but the phase dividing line is straight and clean. Make the dark half and its round outline more faint so it reads instantly as a bright right SEMICIRCLE at hand-card size. No new object, text, symbol, human, animal or building. Preserve transparent rounded corner pixels. Output upright RGBA 1024x1536. Medieval-based fantasy watercolor and ink illustration.
```

선택 결과: `art/cards/wolf-blood-v02/drafts/half_moon-selected.png`.

## 보름달 — full_moon

```text
Use case: precise-object-edit. Edit image 1, the EXISTING full_moon game card. Image 2 is approved skill frame/layout reference (do NOT copy lettering). Image 3 is frost_rune watercolor/ink style reference. Image 4 is the selected new crescent card, match its sky, restrained palette, composition and watercolor print style for a cohesive lunar triptych.
Medieval-based fantasy world with familiar fantasy adaptations and medieval atmosphere. Output a single upright 1024x1536 RGBA card. Preserve image 1's exact purple wave frame, both ENTIRELY BLANK cream text panels, side sparkle decorations, black/cream diamond border, rounded silhouette and transparent corner pixels. Replace the artwork in the central diamond with clear open blue-violet/indigo winter sky. Remove the wolf, witch hat, all people/animals/figures and props. Where the wolf had overlapped the diamond, reconstruct the simple straight black/cream diamond frame so the final scene has no animal remains. Keep everything else as close to the original pixels as possible; final exact frame preservation will be composited separately.
ONE large perfectly round FULL MOON centered at approximately x=512,y=660, diameter about 350 pixels (45-50% of the diamond width). Fully illuminated complete silver-white circle with understated lavender-grey lunar maria, no face, no phase shading, delicate subtle halo, perfectly clear circular silhouette at hand-card scale. Deep indigo night sky with just a few tiny quiet stars; no clouds or branch occlusion. A low distant snowy conifer ridge only in the lowest 15-20% of the diamond, no foreground tree, no building. Large clear color shapes, crisp ink contours, restrained watercolor painted print texture like image 4. No text, numbers, glyphs, badges, watermark, people, wolves, animal silhouettes or human shapes. Both text panels completely empty.
```

생성 결과: `art/cards/wolf-blood-v02/drafts/full_moon-generated.png`. 재생성 없음.

## 합성과 검수 — 현재 적용 보류

요청서가 명시한 창 마스크 합성 방법을 사용했다. `output/wolf-blood-v02/compose.gd`는 격리된 에셋 작업 디렉터리에서 원본 RGBA8을 복사하고 마름모 내부만 생성본 RGB로 교체하며, 원본 알파 채널 전체를 유지한다. 실제 검은 내부 테두리 픽셀은 마스크에서 제외했다. 최종 게임 파일에 쓰는 `--apply`는 실행하지 않았다. 손패 초안은 같은 합성본을 Lanczos로 256×384 축소했다.

- 원본 보존: `art/cards/wolf-blood-v02/previous/{crescent_moon,half_moon,full_moon}.png`.
- 엄격한 창 내부 합성본: `art/cards/wolf-blood-v02/{crescent_moon,half_moon,full_moon}.png`.
- 손패 초안: `output/wolf-blood-v02/<id>-hand-staged.png`.
- 창 마스크: `output/wolf-blood-v02/<id>-window-mask.png`.
- 비교 시트: `godot/screenshots/wolf-blood-cards/moon-v02-sheet.png` (위: 이전 3장, 가운데: 창 내부만 교체한 초안 3장, 아래: 실제 손패 크기 초안).
- 검증: `output/wolf-blood-v02/verification.json`, `passed=false` (시각 요구와 보존 범위 충돌로 게임 적용 전 확인 필요).

창 밖 RGBA 변경 픽셀은 세 장 모두 **0**, 전체 알파 변경 픽셀도 **0**이다. 그러나 원본 인물·동물·기존 달이 창 밖에 걸쳐 있으므로 창 밖을 보존하면 다음 잔여물이 남는다.

| id | 남은 문제 |
| --- | --- |
| crescent_moon | 마름모 오른쪽 아래에 원본 마녀의 옷자락 일부가 남음 |
| half_moon | 원본 모자·신발 일부, 창 밖 오른쪽 위의 기존 달이 남아 달이 두 개로 보임 |
| full_moon | 원본 모자·늑대 몸 일부, 창 밖 오른쪽 위의 기존 큰 달 일부가 남음 |

원본 프레임·빈 글자판·창 밖 배경 전체의 픽셀 보존과 인물·동물 제거/달 하나 조건은 현재 원본에서 동시에 충족할 수 없다. 사용자에게 창 밖 잔여물의 수정 범위를 질문했고, 답변 전에는 게임용·손패용 6개 PNG를 덮어쓰지 않는다. 코드·카탈로그·판 프로파일·다른 카드·EXE·임포트 파일을 수정하지 않았으며 커밋하지 않았다.


## 2차 작업 · 2026-10-23 — 확대 범위 수정·게임 적용 완료

앞 절의 ‘현재 적용 보류’는 1차 작업 당시 상태다. 사용자와 인계 문서의 추가 지시로 마름모 바깥 그림 띠까지 수정하는 범위를 확정했으며, 아래 2차 결과로 해소했다.

- 실제 편집 입력: 기존 `art/cards/wolf-blood-v02/<id>.png` 3장. 이 판은 현재 게임 PNG의 바이트 보존본 `previous/<id>.png`에 1차 달 원화를 합성한 판이다. 원본 게임 PNG를 프레임·패널·알파 복원 기준으로 계속 사용했다.
- 세 호출 모두 승인 스킬 PNG `art/concepts/cards/roles-individual-v02/02-skill-warm-welcome.png`를 실제 참고 입력으로 전달했다. 상현·보름 호출은 2차 초승달 생성본도 화풍 입력으로 사용했다. 입력을 먼저 열어 확인했다.
- 도구: 내장 `image_gen`, 카드별 1회씩 총 3회. 추가 재생성 없음. 범위 확대에 따라 옛 달·인물·늑대·의복·신발 잔여물과 건물을 밤하늘·눈 덮인 숲으로 바꿨다.
- 생성 원본: `art/cards/wolf-blood-v02/drafts/<id>-round2-generated.png`. 1차 합성 이력은 `drafts/<id>-round1-staged.png`와 `output/wolf-blood-v02/verification-round1.json`에 보존했다.

### crescent_moon — 실제 2차 프롬프트

```text
Edit target: image 1, existing crescent_moon staged card. Reference image 2 is the approved SKILL card frame/layout; do NOT copy its lettering. Medieval-based fantasy watercolor and ink, medieval atmosphere with familiar fantasy adaptations. Output one upright 1024x1536 card. Keep image 1's EXACT layout, purple wavy stock frame, black contours, entirely BLANK cream title/rules panels, side sparkle decorations and cream/black diamond border. Keep the central crescent moon and interior winter night scene exactly as they are. Repair the ENTIRE illustrated area INSIDE the purple frame, including the four side panes OUTSIDE the diamond: remove the old witch's sleeve/hand/clothing at lower right, all human/animal fragments and ALL buildings/lanterns. Fill the four outside-diamond panes with a seamless continuation of the central blue-violet starry night sky above and low distant snow-covered conifer forest below. This is one continuous winter landscape behind the diamond border, with a common low horizon. Upper side panes must be open indigo sky and sparse small stars, NO tall foreground trees. Lower panes snowy conifers, no figures, houses or props. There must be exactly ONE moon on the WHOLE card, the current large right-lit crescent inside the diamond. No exterior moon. Restore any hidden diamond border where clothing crossed it. No text, numbers, symbols, watermark or face. Preserve the same crescent, same color palette, watercolor print texture and crisp ink style. Preserve frame and panels precisely; they will be recovered from the original pixels in final compositing.
```

### half_moon — 실제 2차 프롬프트

```text
Edit target image 1, the existing half_moon staged card. Image 2 is the approved SKILL frame/layout reference, do NOT copy text. Image 3 is the newly repaired crescent card, match its continuous background and style. Medieval-based fantasy watercolor and ink illustration, familiar fantasy adaptations with medieval atmosphere. Output upright 1024x1536. Keep image 1's exact purple wavy frame, black contours, blank cream title/rules panels, side sparkles, cream/black diamond border. Keep its central right-lit HALF MOON with a perfectly STRAIGHT VERTICAL terminator exactly at the center, and its central snowy landscape. Repair the ENTIRE illustrated area inside purple frame INCLUDING side panes OUTSIDE diamond. Remove the OLD SMALL MOON in the upper right pane, old witch hat near upper right diamond edge, shoe/clothing at lower diamond edge, every human/animal fragment, ALL buildings and lanterns. Extend the central open indigo starry sky and LOW snowy conifer forest continuously into all four exterior diamond panes, like image 3. Upper panes: open deep blue-violet sky and sparse small stars, NO tall trees. Lower panes: low snow-covered conifer ridges at same horizon as interior. There must be exactly ONE moon on the WHOLE card, the current large right-lit half moon inside the diamond. No exterior moon, people, animals, human shapes, props or architecture. Restore any occluded portions of diamond border to simple black/cream lines. Preserve moon, scene palette, ink and watercolor print texture. NO TEXT/numbers/letters/watermark/symbols. Both text panels empty. Original frame/panels pixels will be restored in final compositing.
```

### full_moon — 실제 2차 프롬프트

```text
Edit target image 1, the existing full_moon staged card. Image 2 is APPROVED SKILL frame/layout reference, do NOT copy lettering. Image 3 is repaired crescent card, match its continuous exterior-diamond background and style. Medieval-based fantasy watercolor and ink, fantasy adaptations with medieval atmosphere. One upright 1024x1536 card. Keep exact image 1 purple wave frame, black contours, entirely BLANK cream text panels, side sparkle ornaments, black/cream diamond frame. Preserve its large central round FULL MOON and central winter landscape. Repair ENTIRE illustrated area INSIDE purple frame INCLUDING all panes OUTSIDE the diamond. Remove the OLD SECOND LARGE MOON from upper-right exterior pane, witch hat sticking across upper-right diamond edge, ALL wolf fur/legs/paws/body fragments overlapping lower-left and lower-right diamond edges, all figures/animals/humans, ALL buildings and lanterns. Fill exterior panes with continuous open indigo blue-violet starry sky ABOVE and low distant snowy conifer forest BELOW, seamlessly extending same landscape inside diamond. Upper panes are open sky and sparse small stars, NO tall foreground trees. Common low forest horizon as image 3, simple large color shapes. Exactly ONE moon on whole card, the existing central full moon. No moon outside diamond. Restore simple black/cream diamond lines wherever wolf/hat crossed and occluded the border. No text, numbers, lettering, watermark, symbols, human shapes, animals, props or architecture. Both cream text panels completely empty. Match same watercolor print texture and crisp ink style as image 3. Frame/panels original pixels will be restored separately.
```

### 2차 합성·검증 방법

사용자가 지시한 마스크·원본 픽셀 복원을 `output/wolf-blood-v02/round2-compose.cjs`로 수행했다. 보라 프레임 안의 전체 그림을 편집 대상으로 삼되 원본 프레임·빈 패널·좌우 반짝임·기존에 보이던 마름모 먹선/크림 선은 보존 마스크로 제외했다. 의복·모자·발·늑대·눈에 가려 원래 선이 없었던 부분만 생성본의 선으로 연결했다. 모서리를 포함한 원본 알파는 전체 복사했다. 밝은 눈·털을 크림 패널로 오인한 초기 마스크를 원본 크기에서 검수하고 색상 구분과 가림 영역을 보정했다. 생성 이미지 자체를 다시 생성하지는 않았다.

- 편집/보존/마름모 보존 마스크: `output/wolf-blood-v02/<id>-edit-mask.png`, `<id>-preserve-mask.png`, `<id>-diamond-preserve-mask.png`. 보존 부분을 붉게 표시한 검수본: `<id>-mask-review.png`.
- `round2-preview.gd`는 격리된 `output/wolf-blood-v02` 프로젝트에서 PNG를 읽어 RGBA 256×384 Lanczos 축소와 잘리지 않은 비교 시트를 만들었다. 실제 게임 프로젝트의 임포트·실행·내보내기는 하지 않았다.
- 원본 크기 및 실제 손패 크기로 각 달 1개, 인물/동물 잔여물 0, 바깥 옛 달 0, 글자/숫자 0을 시각 검수했다. `round2-verify-apply.cjs`는 마스크 밖 RGBA, 전체 알파, 독립 제목/설명 안전 영역과 반짝임 사각 영역, 파일 크기·채널·모서리 알파·SHA-256을 확인한 뒤 6개 PNG에 적용했다.
- 최종 `verification.json`: `passed=true`, `applied_to_game=true`, `game_assets_replaced=6`. 보존 영역 변경 픽셀 0, 전체 알파 변경 픽셀 0(세 장 모두). `outside_old_diamond_changed_pixels`는 확대 허용된 바깥 띠 변경 수이며, 보존 영역 변경 수와 다르다.
- 수정 금지 경로 1,061개를 시작·적용 직전·적용 직후 해시로 기록했다. 작업 중 다른 세션이 `godot/scripts/game/card_inventory.gd`, `game_session.gd`, `godot/scripts/ui/card_view.gd`를 변경한 사실을 기록하고 그대로 두었다. 이 작업은 해당 경로나 다른 금지 경로에 쓰지 않았다. EXE 해시는 시작과 종료가 같다. 커밋하지 않았다.

