# 고블린 니브 모델링용 3/4 원화 v02 — 생성 기록

- 제작일: 2026-10-19 (Asia/Seoul)
- 요청서: `docs/handoff/codex-goblin-nib-model-3q-v02.md` (UTF-8로 읽음).
- 도구: 내장 `image_gen.imagegen`, 4회 호출(시안별 최초 생성 1회 + 머리/방향/자세 보정 1회). 모든 호출 `transparent_background=true`. CLI/API 대체 생성 미사용.
- 시안 A: [nib-3q-a-v02.png](nib-3q-a-v02.png) — 둥근 배낭 + 담요 한 롤 + 빛나지 않는 작은 등불, 한 바퀴 목도리.
- 시안 B: [nib-3q-b-v02.png](nib-3q-b-v02.png) — 둥근 보따리 하나 + 짧은 어깨 망토형 목도리. 등불/담요 없음.
- 두 납품본: RGBA PNG, **1536×1536**. 실제 생성 원본은 **1254×1254**. 확대/재표본화하지 않고 각 방향 141px 투명 여백을 추가했다.
- 모든 신규 파일은 이 `art/concepts/characters/goblin-nib-model-v02/` 내부에만 작성했다. 기존 v01, 기존 원화/초상/레퍼런스, `godot/**`, `docs/**`는 수정하지 않았다. 게임 적용·실행파일 재내보내기·커밋은 하지 않았다.

## 실제 이미지 입력

아래 3장을 직접 열어 확인한 뒤, **최초 생성과 보정 4회 모두** `referenced_image_paths`의 1~3번에 실제 파일로 첨부했다. 경로를 텍스트로만 설명한 생성이 아니다.

1. `art/references/characters/stylized-toy-chibi-ref-01.png` — 1순위 화풍: 큰 단순 덩어리, 짧은 비율, 단추 눈, 매끈한 장난감 표면만 사용. 원본 네 인물·의상·색 배치·배경색 칸은 복제하지 않음.
2. `godot/assets/portraits/guest_nib_cutout.png` — 니브 정체성: 연두 피부, 큰 뾰족 귀, 갈색 머리, 주황빨강 목도리, 보라 조끼/흰 셔츠, 행상인 짐.
3. `art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png` — 같은 인물의 정체성 보조. 카드 프레임·텍스트·먹선·세부 질감은 사용하지 않음.

보정 호출의 4번 이미지:
- A: `raw/nib-3q-a-v02-initial.png`
- B: `raw/nib-3q-b-v02-initial.png`

반려작 `art/concepts/characters/goblin-nib-model-v01/nib-3q-a-v01.png`, `nib-3q-b-v01.png`도 직접 열어 피해야 할 세부 묘사를 확인했다. 이 둘은 생성기에 첨부하지 않았다.

## 원본 보존과 호출 순서

| 순서 | 이미지 입력 | 프롬프트 | 생성 원본 |
| --- | --- | --- | --- |
| 1 | 공통 이미지 1~3 | 아래 A 최초 생성 전문 | `raw/nib-3q-a-v02-initial.png` |
| 2 | 공통 이미지 1~3 | 아래 B 최초 생성 전문 | `raw/nib-3q-b-v02-initial.png` |
| 3 | 공통 이미지 1~3 + A 최초 생성 | 아래 A 보정 전문 | `raw/nib-3q-a-v02.png` |
| 4 | 공통 이미지 1~3 + B 최초 생성 | 아래 B 보정 전문 | `raw/nib-3q-b-v02.png` |

원본 PNG는 생성 도구 저장본을 바이트 그대로 복사했고 알파를 변경하지 않았다. 도구 원래 저장 위치는 `C:/Users/Loadcomplete/.codex/generated_images/01a15298-6888-7121-9f44-abb271879e96/`이다. 각각 `exec-852fd91e-c1ad-4239-8462-3b519d44edf7.png`, `exec-729110fa-b074-463f-ab15-34eab3d53a2e.png`, `exec-01379b91-7ec7-449a-b243-60941163f5f5.png`, `exec-35fb2bec-4e34-4de9-bd20-3eb9f3f40e4f.png`.

## 알파 마감과 검수

마감 구현: [raw/alpha-cleanup.ps1](raw/alpha-cleanup.ps1), 상세 수치: [raw/alpha-report.json](raw/alpha-report.json).
알파 마감은 사용자 요청에 따른 결정적 후처리이며 새 이미지 생성/그림 내용 변경은 내장 이미지 도구로 수행했다.

1. 원본 알파 ≥192를 캐릭터 후보 마스크로 사용.
2. 1px opening(3×3 침식 후 팽창)으로 얇은 외곽 돌기 제거, 가장 큰 연결 성분만 유지. 작은 내부 핀홀은 16px 이하만 채움.
3. 마스크 내부를 255로 복원. 가장자리에 3×3 가중치 [1,6,1]의 좁은 안티에일리어싱을 재구성. 8 미만은 0, 247 초과는 255. 부분 알파는 실루엣 경계의 안팎 각 1px 이내에만 존재한다.
4. 부분 알파 픽셀의 RGB는 가까운 마스크 내부 색으로 보완해 붉은/노란 색 번짐을 줄임. 색상 키로 목도리를 제거하지 않는다.
5. 캐릭터를 확대하지 않고 1536×1536 중앙 투명 캔버스에 배치. 투명 픽셀 RGB는 0.
6. [흰색·회색 배경 A](raw/alpha-proof-a.png), [흰색·회색 배경 B](raw/alpha-proof-b.png)를 직접 열어, 귀·머리·목도리·손·등짐·발의 경계와 본체 구멍/반투명을 확인했다. 마감 중 색상 기반 제거가 목도리까지 지우는 문제를 발견해 폐기하고, 색상 키를 없앤 최종 마감본으로 재검수했다.

아래 전체 비율은 최종 1536² 픽셀 기준이다. '본체 내부'는 마스크의 3×3 이웃이 모두 본체인 영역, '바깥'은 3×3 이웃에 본체가 전혀 없는 영역으로 정의한다. 경계 안티에일리어싱 영역은 이 두 분모에서 제외한다.

| 항목 | A | B |
| --- | ---: | ---: |
| 최종 크기 | 1536×1536 | 1536×1536 |
| 본체 내부 알파 255 | 549,971 / 549,971 = **100%** | 621,141 / 621,141 = **100%** |
| 바깥 알파 0 | 1,797,402 / 1,797,402 = **100%** | 1,725,168 / 1,725,168 = **100%** |
| 전체 알파 255 | 551,711 = 23.384560% | 623,097 = 26.410294% |
| 전체 알파 0 | 1,799,134 = 76.257239% | 1,727,109 = 73.204422% |
| 경계 부분 알파 | 8,451 = 0.358200% | 9,090 = 0.385284% |
| 알파 1~7 | **0px** | **0px** |
| 알파 252~253 | **0px** | **0px** |
| 투명 여백 좌/상/우/하 | 326/264/265/233px | 330/217/269/205px |
| 알파 포함 실루엣 경계 (좌,상,우,하, inclusive) | 326,264,1270,1302 | 330,217,1266,1330 |

마감 전 채택 원본 A는 알파 1~7이 40,294px, 252~253이 530,992px이었다. B는 각각 22,195px, 604,215px이었다. 원본 본체의 거의 전 영역에 있던 반투명 알파를 납품본에서 복구했다.

## 시각 검수와 한계

- 레퍼런스 수준의 큰 색면·매끈한 무광 덩어리·둥근 단추 눈·벙어리장갑 손으로 재제작했다. v01의 눈동자/치아/주근깨/잔머리/직물/바느질/다수 귀걸이/보조 주머니를 제거했다. 머리는 둥근 캡과 두 앞머리의 큰 세 덩어리로 읽히며 캡 아래 옆면이 일부 드러난다.
- 니브의 연두 피부, 큰 뾰족 귀, 짙은 갈색 머리, 주황빨강 목도리, 보라 조끼와 흰 셔츠, 갈색 벨트, 등짐을 유지했다. 귀걸이는 한쪽의 동전 하나씩이다. B가 A보다 짐과 목도리 구조가 단순하다.
- 두 시안 모두 앞왼쪽을 향한 약한 상부 시점의 3/4 전신이며 양 눈과 등짐이 보인다. 한 명/한 뷰, 귀끝·발끝·등짐의 잘림, 글자·바닥·투사 그림자·배경색 칸 없음.
- A자 자세로 팔을 비스듬히 내렸고 손에 물건이 없다. 손은 몸통 바깥에 놓이지만 카메라에 가까운 팔 뒤로 등짐이 겹쳐 보이는 부분이 있다. **모델링용 완전한 사지 분리도나 정투영 청사진은 아니다.**
- 중세 기반 판타지에 어울리는 조끼·셔츠·가죽 등짐·천 보따리·금속 등불 조합으로 구성했다. 현대 소품은 추가하지 않았다.
- 한계: 생성 이미지이므로 카메라 회전각 30~45°와 정확한 2등신 수치를 3D 좌표로 보증할 수 없다. B는 A보다 정면성이 강하다. 표면에 약한 넓은 페인터리 명암은 남아 있다. 귀걸이가 A/B 서로 반대쪽 귀에 있어 모델 제작 시 한쪽을 선택해 통일해야 한다. 캐릭터 승인·모델링 착수·게임 자산 교체는 이번 납품에 포함하지 않는다.

## SHA256

| 파일 | SHA256 |
| --- | --- |
| `nib-3q-a-v02.png` | `B7CE03E51CEE6603DC1A2583AC6A5277539B49D959CC904C36B0C1AAEF1B8210` |
| `nib-3q-b-v02.png` | `C47042945BB8861592AF58CF78A5C70B65FADB7526C44F09C9B825FD3B0F6BF0` |
| `raw/nib-3q-a-v02-initial.png` | `2375BB38D3A6B01F349855E065E1EE1A29C7459A496C8602DB9DCDD3B1F140D9` |
| `raw/nib-3q-b-v02-initial.png` | `BDE8B337A7C6956ECEEFBC80909448E270ACE6A7F24FD8A9C039F982BFDF3412` |
| `raw/nib-3q-a-v02.png` | `04B85AD47FA3A80867AA3081E98C77BE6EE8093001A3D66147D0F3022CD9AC16` |
| `raw/nib-3q-b-v02.png` | `5C9263C4E5B7CC3E28C38A0D822ACFD251B9C2719FB02043217BE704DEDF8879` |

실제 입력 이미지의 SHA256:
- 화풍 기준: `C26F3E21A10E119047DF10986BF4D27720C2E6B7A266ACA142BA2FCF78BF8687`
- 니브 초상: `79CC325D71F96E3CC358A9B6C32DC84BDA5B111206732983152C1833537DC8B1`
- 니브 카드: `DA3C9F43EBA6FDBD9977498983D6F866FF565171BE57B4656D32A3923AF62B16`

## 실제 프롬프트 전문 — A 최초 생성

```text
Use case: stylized-concept.
Asset type: a single full-body character concept for 3D modeling, Witch's Lodge medieval fantasy game.
Use the THREE supplied images as actual visual references. Image 1 is the PRIMARY and overriding SHAPE AND SIMPLICITY reference: the four chunky toy characters. Borrow only its sculptural language, large shapes, degree of simplification, proportions, matte surfaces and button eyes; do NOT reproduce any of those four characters, their clothing, props, color arrangements, colored background squares or 2x2 layout. Images 2 and 3 show the SAME goblin Nib; use ONLY his identity, core colors, ears and basic garments, NEVER their illustrative texture, outlines or fine details. Reimagine Nib at the toy simplicity of Image 1.
World: medieval-based fantasy, preserving medieval everyday life and atmosphere while permitting fantasy adaptation (중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색 허용).
Character: light yellow-green skin; HUGE long pointed ears extending out sideways, defining his silhouette; dark brown helmet-like hair made of just THREE large smooth fused clumps; exactly two dark round button-dot eyes without white sclera, pupils or highlights; one small round bump nose; faint blush; a TINY closed asymmetric smile giving a playful bargaining merchant expression, NO teeth. Exactly ONE plain copper coin earring on one ear, no engraved symbols. No other jewelry. Purple vest over off-white shirt; one broad brown waist belt with ONE chunky simple buckle; plain brown short trousers and rounded brown shoe masses.
Proportions: approximately TWO HEADS TALL, the head about as tall as the ENTIRE body including feet. Short cylindrical/trapezoid torso, short fat pillar legs, round feet. Hands are simple blunt MITTEN masses, a palm and a single thumb, NO articulated fingers, nails or knuckles. This must be dramatically simpler than the detailed source art.
Style: smooth matte clay/vinyl collectible toy; very broad clean color areas, one or two soft painterly shading steps. Extremely sparse form definition, no outline/ink, no texture noise, no fabric weave, stitching, x-shaped lacing, wrinkles, fur, strands of hair, braids, freckles, detailed eyebrows, rivets, charms, tassels, herbs or extra pouches. Clothing organized into only 3-4 major color fields, clean fused shapes.
Pose and composition: ONE character, ONE view. Upright neutral modeling A-pose, BOTH arms angled down and outward approximately 30 degrees from torso; clear transparent gaps between BOTH mitten hands and body. Hands empty. FRONT-LEFT three-quarter view 30-45 degrees, face and torso turned together slightly toward image-left, camera mildly elevated as in Image 1. Both eyes visible, ears and pack visible. Not front-on, not side-on, not a back view, not walking, not a dramatic gesture.
Canvas: square 1536 x 1536 or larger, full body centered with generous clear transparent margins on ALL sides, ears, feet and entire baggage fully inside the frame. TRUE transparent alpha background. No ground, floor, cast shadow, backdrop, colored tiles, checkerboard, lettering, watermark, frame, labels, inset, turnarounds or multiple views. The figure itself must be fully opaque, with clean color-neutral edges and only narrow 1-2 pixel edge antialiasing; no translucent skin, red fringe or stray alpha speckles.
Lighting: even neutral diffuse studio light, restrained form shadows only, no dramatic shadow, rim light or glow.
Variant A — traveling merchant: exactly ONE rounded simple brown backpack on the back with ONE plain unpatterned rolled blanket on top; exactly ONE small simplified lantern attached to the backpack side visible at image-right, with a single flat muted yellow glass face, no light emission and no detailed metal lattice. Use only broad simple straps, no extra buckles. Large orange-red scarf wraps ONCE around the neck as one thick smooth loop with one short simple end. Keep the backpack, blanket and lantern chunky and visually subordinate to the head. This is the only requested image for this call.
```

## 실제 프롬프트 전문 — B 최초 생성

```text
Use case: stylized-concept.
Asset type: a single full-body character concept for 3D modeling, Witch's Lodge medieval fantasy game.
Use the THREE supplied images as actual visual references. Image 1 is the PRIMARY and overriding SHAPE AND SIMPLICITY reference: the four chunky toy characters. Borrow only its sculptural language, large shapes, degree of simplification, proportions, matte surfaces and button eyes; do NOT reproduce any of those four characters, their clothing, props, color arrangements, colored background squares or 2x2 layout. Images 2 and 3 show the SAME goblin Nib; use ONLY his identity, core colors, ears and basic garments, NEVER their illustrative texture, outlines or fine details. Reimagine Nib at the toy simplicity of Image 1.
World: medieval-based fantasy, preserving medieval everyday life and atmosphere while permitting fantasy adaptation (중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색 허용).
Character: light yellow-green skin; HUGE long pointed ears extending out sideways, defining his silhouette; dark brown helmet-like hair made of just THREE large smooth fused clumps; exactly two dark round button-dot eyes without white sclera, pupils or highlights; one small round bump nose; faint blush; a TINY closed asymmetric smile giving a playful bargaining merchant expression, NO teeth. Exactly ONE plain copper coin earring on one ear, no engraved symbols. No other jewelry. Purple vest over off-white shirt; one broad brown waist belt with ONE chunky simple buckle; plain brown short trousers and rounded brown shoe masses.
Proportions: approximately TWO HEADS TALL, the head about as tall as the ENTIRE body including feet. Short cylindrical/trapezoid torso, short fat pillar legs, round feet. Hands are simple blunt MITTEN masses, a palm and a single thumb, NO articulated fingers, nails or knuckles. This must be dramatically simpler than the detailed source art.
Style: smooth matte clay/vinyl collectible toy; very broad clean color areas, one or two soft painterly shading steps. Extremely sparse form definition, no outline/ink, no texture noise, no fabric weave, stitching, x-shaped lacing, wrinkles, fur, strands of hair, braids, freckles, detailed eyebrows, rivets, charms, tassels, herbs or extra pouches. Clothing organized into only 3-4 major color fields, clean fused shapes.
Pose and composition: ONE character, ONE view. Upright neutral modeling A-pose, BOTH arms angled down and outward approximately 30 degrees from torso; clear transparent gaps between BOTH mitten hands and body. Hands empty. FRONT-LEFT three-quarter view 30-45 degrees, face and torso turned together slightly toward image-left, camera mildly elevated as in Image 1. Both eyes visible, ears and pack visible. Not front-on, not side-on, not a back view, not walking, not a dramatic gesture.
Canvas: square 1536 x 1536 or larger, full body centered with generous clear transparent margins on ALL sides, ears, feet and entire baggage fully inside the frame. TRUE transparent alpha background. No ground, floor, cast shadow, backdrop, colored tiles, checkerboard, lettering, watermark, frame, labels, inset, turnarounds or multiple views. The figure itself must be fully opaque, with clean color-neutral edges and only narrow 1-2 pixel edge antialiasing; no translucent skin, red fringe or stray alpha speckles.
Lighting: even neutral diffuse studio light, restrained form shadows only, no dramatic shadow, rim light or glow.
Variant B — maximal simplification: exactly ONE rounded tied cloth bundle on the back, a single smooth bulb with a tiny chunky knot and a plain broad strap. NO lantern, NO rolled blanket, NO backpack pockets, NO extra bags or props. Orange-red scarf becomes ONE short smooth shoulder-covering capelet with a simple neck wrap, NO brooch, no long tail, no folds, no fringe. Keep both white sleeves and purple vest visible and arms separated. Use the smallest possible number of large masses while clearly reading as Nib. This is the only requested image for this call.
Simplicity priority, especially hair: construct the hair from ONE smooth rounded brown helmet cap plus only TWO broad fused bangs, exactly three visible volumes total. NO crown spikes, NO overlapping clusters of many teardrop locks, NO sideburn locks. Body must be very squat: head is HALF of the total character height. Smooth untextured color surfaces. Leave at least 10 percent canvas margin around all extremities.
```

## 실제 프롬프트 전문 — A 보정

```text
Use case: precise-object-edit / stylized-concept.
Input images 1, 2 and 3 remain actual visual references: 1 is the overriding toy simplicity reference; 2 and 3 are ONLY Nib's identity and palette reference. Image 4 is the existing Variant A to revise. Preserve Variant A's identity, yellow-green skin, huge pointed ears, dot eyes, tiny smile, white shirt, purple vest, single brown belt and buckle, brown shoes, orange-red scarf, exactly one copper coin earring, ONE round backpack with ONE plain blanket roll and ONE tiny non-glowing yellow-faced lantern.
Make these focused corrections to Image 4:
1. SIMPLIFY HAIR to ONE rounded helmet cap plus TWO broad fused bang lobes ONLY (3 volumes total), with no tufts, spikes, side locks or small strands. Smooth matte clay/vinyl, no grain.
2. The whole character's face AND body should be turned clearly 35 degrees toward image-left (front-left 3/4 view). The near cheek and near side of the vest must be visibly broader than the far side; mildly elevated camera. Both dot eyes visible. Do not face directly front.
3. Squash the body to approximately two-heads-tall toy proportions (head is half the total height).
4. Both arms in clear MODELING A-pose, diagonally down-and-out 35 degrees from torso, with empty mitten hands well outside the vest and baggage outline and obvious transparent gaps. Do not hold or touch the pack.
5. Give generous transparent margins, at least 10 percent of canvas, keep ear tips and shoes and baggage fully visible.
Medieval-based fantasy, preserving medieval daily-life atmosphere while permitting fantasy adaptation. Single full body, one view, square 1536x1536 or larger, genuine transparent alpha, body fully opaque. No floor, shadow, glow, rim lighting, outlines, texture, extra props, text or background squares. Keep all other features unchanged.
```

## 실제 프롬프트 전문 — B 보정

```text
Use case: precise-object-edit / stylized-concept.
Input images 1, 2, 3 are actual visual references: 1 is the overriding chunky simple toy style reference, 2 and 3 are ONLY Nib identity and palette. Image 4 is Variant B to revise.
Preserve the extremely simple matte clay toy design, three major dark-brown hair volumes (rounded helmet cap and two broad bangs, no extra locks), light yellow-green skin, huge pointed ears, dot eyes without highlights, tiny smile, faint blush, exactly one copper coin earring, orange-red short shoulder-covering scarf/capelet, purple vest, plain white shirt, one plain brown belt and chunky buckle, short brown trousers and round shoes, and exactly one tied round off-white cloth bundle on the back with one broad plain strap. NO lantern, blanket roll, extra pouches, fine details, outlines, pattern or texture.
Correct the view: rotate the ENTIRE face AND torso AND feet together to a CLEAR 35-degree FRONT-LEFT three-quarter angle, pointing toward image-left; near cheek and near side of vest noticeably broader than far side, both eyes still visible. Mildly elevated camera as Image 1. No frontal view.
Correct pose: upright neutral modeling A-pose. Angle BOTH arms down and OUTWARD roughly 35 degrees away from torso so each empty mitten hand is visibly separated from torso AND baggage by transparent space. No hand touching hip or bundle. Keep short thick limbs and approximately two-heads-tall proportions.
Square canvas 1536x1536 or larger. One full-body character, ONE view, ear tips, shoes and entire bundle inside frame, generous at least 10 percent transparent margins around all extremities. Genuine transparent alpha background, opaque figure, 1-2px narrow clean antialiasing, no stray colored edge pixels. Even neutral diffuse light. No floor, shadows, backdrop, glow, rim light, text, labels, colored squares, frame or multiple views. Medieval-based fantasy preserving medieval daily-life atmosphere while allowing fantasy adaptation. All other features unchanged.
```

