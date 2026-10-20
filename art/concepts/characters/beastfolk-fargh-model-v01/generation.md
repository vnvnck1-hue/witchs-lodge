# 파르그 3/4뷰 모델링 원화 v01 — 생성·검수 기록

제작일: 2026-10-20 (Asia/Seoul)  
방식: 내장 `image_gen` / `transparent_background=true`. CLI·별도 API 호출 없이 제작했다.  
요청서: `docs/handoff/codex-beastfolk-fargh-model-3q-v01.md` 및 `docs/handoff/codex-race-models-3q-common-v01.md`.

## 납품과 범위

- [A · 초상 충실](fargh-3q-a-v01.png): 크림 모피 깃, 짙은 초록 짧은 망토, 갈색 가죽 갑옷, 강철 어깨받이 하나·팔토시, 황동 버클, 등에 비스듬히 멘 양손검.
- [B · 수인 공용 겸용](fargh-3q-b-v01.png): 같은 늑대 정체성, 가죽 조끼·귀리색 셔츠·짧은 초록 망토. 갑옷·검 제거.
- 최종 2장 모두 1536×1536, RGBA PNG. 본체 불투명, 바깥 투명, 외곽의 1~2px 범위만 중간 알파.
- 프로젝트 내 쓰기는 이 폴더와 `raw/`에 한정했다. 입력 원화·초상·문서·게임 파일과 다른 종족 폴더는 수정하지 않았고 커밋하지 않았다. 게임 적용이나 실행파일 재내보내기는 이번 원화 납품 범위가 아니다.
- 생성 도구가 반환한 서비스 관리 원본은 기본 캐시에 남으며, 모든 생성 PNG를 이 폴더의 `raw/`로 복사 보존했다.

## 실제 입력 이미지

아래 4개를 모두 `view_image`로 열어 눈으로 확인한 뒤, A 최초 생성의 `referenced_image_paths`에 이 순서 그대로 전달했다. B 최초 생성은 아래 4개 뒤에 A 최초 생성 이미지를 다섯 번째 입력으로 추가했다. 문서나 경로 이름만 보고 만든 결과가 아니다.

| 순서 | 경로 | 역할 |
| --- | --- | --- |
| 1 | `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png` | 최우선 화풍·비례·카메라 높이·마감 기준 |
| 2 | `art/concepts/characters/witch-north-model-v01/witch-3q-a-v01.png` | 같은 게임의 보조 화풍 기준 |
| 3 | `art/references/characters/stylized-toy-chibi-ref-01.png` | 큰 덩어리 조형 언어만 참고 |
| 4 | `godot/assets/portraits/guest_fargh_cutout.png` | 늑대 머리·회색/크림 배색·호박색 눈·의상·검의 정체성 |

중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색을 허용하는 세계관을 프롬프트와 검수에 반영했다. 카드 초상의 먹선·털 결·리벳·장식 밀도는 옮기지 않았다.

### 입력 SHA256

- `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png`
  - SHA256: `d33657a5a0b50b9b8bdd4f6384a3014b49aa0610111dfe8015480d038ff71f1b`
- `art/concepts/characters/witch-north-model-v01/witch-3q-a-v01.png`
  - SHA256: `105efb88d1a6b0449523c1c9b8bc0ba466b41e3b2c3946f77c9424caddeb3682`
- `art/references/characters/stylized-toy-chibi-ref-01.png`
  - SHA256: `c26f3e21a10e119047df10986bf4d27720c2e6b7a266aca142ba2fcf78bf8687`
- `godot/assets/portraits/guest_fargh_cutout.png`
  - SHA256: `9d248666bd53f8193cfe42c5e1842f78ddca5d9ded365eb3d5c7d3099c7e1b44`

## 생성 이력과 실제 입력 순서

총 5회. 아래 프롬프트는 도구에 전달한 전문 그대로다. 모든 호출에서 `transparent_background=true`였으며, `num_last_images_to_include`는 쓰지 않았다.

| 호출 | 용도 | referenced_image_paths 순서 | 저장 원본 |
| --- | --- | --- | --- |
| 1 | A 최초 생성 | 공통 입력 1, 2, 3, 4 | `raw/fargh-3q-a-generated-v01.png` |
| 2 | B 최초 생성 | 공통 입력 1, 2, 3, 4, 호출 1 원본 | `raw/fargh-3q-b-generated-v01.png` |
| 3 | A 팔·망토·자세 보정 | 호출 1 원본, 공통 입력 1 | `raw/fargh-3q-a-pose-revision-v01.png` |
| 4 | A 꼬리 분리 보정 | 호출 3 원본 | `raw/fargh-3q-a-tail-revision-v01.png` |
| 5 | 최종 A의 자세를 유지하며 B 의상으로 변경 | 호출 4 원본, 호출 2 원본 | `raw/fargh-3q-b-pose-revision-v01.png` |

호출 4가 최종 A의 소스, 호출 5가 최종 B의 소스다. 각 생성 결과를 실제 이미지로 확인했다. 최초 시안에서 팔 사이에 망토가 남고 꼬리가 다리에 붙어 보이는 문제를 발견해 호출 3~5에서 보정했다.

### 1 · A 최초 생성

```text
Use case: stylized-concept.
Asset type: Fargh variant A, full-body 3D modeling concept for the medieval fantasy game Witch's Lodge. Generate ONE character, ONE view, on genuinely transparent RGBA background, square 1536x1536.
Reference roles, in order: image 1 approved Nib is the PRIMARY style, proportions, camera-height and finish reference; image 2 approved north witch is secondary same-game style reference; image 3 is shape-language reference ONLY, do not copy its characters or clothing; image 4 Fargh portrait is IDENTITY and costume/color reference ONLY, discard its ink lines, detailed fur and realistic anatomy.
Create Fargh, a quiet gray WOLF beastfolk mercenary swordsman: an upright human-shaped body with a wolf head and fluffy gray tail, no human hairstyle. Extremely cute smooth matte clay/vinyl toy sculpt like image 1, about TWO heads tall with a very large head, short compact torso and short limbs; shoulders slightly wider than a human. Soft gray head, cream short round muzzle and throat, triangular upright ears with cream interiors, one conspicuous torn notch in ONE ear, a single minimal healed scar on cheek. Two simple half-lidded, solid dark-amber button eyes WITHOUT pupils, iris rings or highlights; tiny dark nose, small closed neutral mouth. Quiet watchful expression. Fur modeled as only 3-4 large rounded clumps, no strands.
Variant A costume: a cream fur collar in 3-4 smooth rounded lobes held CLOSE around the neck, SHORT dark forest-green cape down the back stopping near belt and clear of arms; plain brown leather armor tunic, one chunky smooth steel shoulder pad, simple smooth steel forearm bracers, brown belt with ONE plain brass square buckle; dark brown trousers and simple brown medieval boots. Keep gray, cream, dark forest green, brown and steel as broad color groups, brass only tiny accent. No rivets, etched decoration, cords, embroidery, little fur flecks or extra pendants.
A LARGE TWO-HANDED SWORD strapped DIAGONALLY across the BACK, in a simple smooth scabbard. Its long brown grip and plain crossguard project clearly above one shoulder, with the blade/scabbard silhouette distinguishable from body for future removable 3D part. BOTH HANDS EMPTY, relaxed mitten hands.
Pose and composition: upright neutral modeling A-pose, both straight arms angled downward and OUT from torso with continuous visible transparent gaps from armpits to hands. Show BOTH separate short legs and boots, transparent gap between legs. The short collar and cape must not cover arms. The fluffy gray tail hangs downward behind and curves slightly to the visible side, distinctly separated from BOTH legs by transparent space. Same front-left three-quarter view as Nib image 1, approximately 30-45 degrees, face looking gently toward viewer's left, same mildly elevated camera. Full body centered, all ears, sword, arms, feet and tail inside frame with generous transparent margins on every side.
Style: rounded toy geometry, no contour outlines or ink, softly lit broad smooth color masses, soft ambient contact shading only, NO detailed textures, NO photorealistic fur, NO gritty wear. Medieval-based fantasy retaining medieval everyday atmosphere with ordinary fantasy adaptation allowed; no modern clothing, no modern sewing, no plastic ornaments (clay/vinyl refers only to render style).
Background MUST be actual alpha=0 empty space, solid character opaque alpha=255, edge antialiasing only 1-2px. No floor, no shadow ellipse, no checkerboard drawn into pixels, no text, no frame, no watermark, no extra views.
```

### 2 · B 최초 생성

```text
Use case: stylized-concept.
Asset type: Fargh variant B, reusable wolf beastfolk traveler, full-body 3D modeling concept for the medieval fantasy game Witch's Lodge. ONE character, ONE direction, genuinely transparent RGBA, square requested 1536x1536 with generous empty margins.
Input images in order: 1 approved Nib PRIMARY style/proportions/camera/finish; 2 approved north witch secondary same-game reference; 3 toy chibi reference shape-language ONLY, never copy its characters or clothes; 4 Fargh original portrait identity/colors ONLY, not illustration technique; 5 newly generated Fargh A is the SAME CHARACTER to keep the head, ears, face, body and gray tail consistent, but REPLACE the entire mercenary costume as described below.
Create variant B: same gray wolf head with a SHORT rounded cream muzzle and cream throat, two dark amber matte button eyes with simple half-lowered lids and NO highlights, NO pupils or iris rings, small dark nose, tiny neutral mouth; same notch torn out of ONE ear, single simple healed cheek scar, gray rounded cheek tufts. No human hair. Quiet, protective and taciturn. A human-shaped body with wolf head and tail, shoulders slightly wider than a human. About TWO heads tall, huge head, compact torso and short legs, same rounded matte clay toy sculpt as Nib, soft broad shading, few large masses, no ink outlines, no detailed fur texture.
Costume B MUST be plain reusable medieval traveler clothes: a plain warm brown LEATHER VEST over an OATMEAL-COLORED SHIRT, a SHORT close-fitting dark green cape down the back that stops near belt, plain brown belt with small simple brass buckle, brown short trousers and simple brown boots. Cream throat fur natural to the wolf, only a few rounded clumps if visible. No ornate or large armor collar. Absolutely NO ARMOR, NO steel shoulder pad, NO steel bracers, NO metal sleeves, NO sword, NO scabbard, NO weapon, NO pack, NO profession tools. Shirt sleeves clearly visible on both arms, plain cloth. Vest must read as simple everyday clothing, not cuirass. All garment surfaces broad and smooth, no rivets, lacing, rows of buttons, modern stitching or jewelry. Clothes generic enough to recolor for hunters, gatherers, travelers; animal head, ears and tail very clear.
Modeling stance: upright neutral A-pose, feet apart, arms straight angled diagonally DOWN AND OUT to give visibly open transparent spaces between BOTH arms and torso. BOTH hands relaxed empty mitten hands, no gestures. No crossed arms. Cape behind torso and never behind the exposed arms, allowing continuous alpha gaps between arm and body. Two fully visible separate legs below vest with an obvious transparent gap between legs/boots.
One fluffy GRAY tail hanging down behind, curving to the visible side and away from boots so that there is a clearly visible transparent gap between the tail and BOTH legs, no tail wrapped around a leg. Tail formed from 3-4 large rounded clumps, no individual hairs.
Front-left three-quarter view 30-45 degrees, looking gently toward viewer's left, same mildly elevated camera height as Nib, whole body fully inside frame. Keep head/body scale and framing compatible with image 5. Generous empty transparent margin above ears, beside hands/tail and below boots.
Palette limited to broad gray, cream/oatmeal, dark forest green, brown groups, tiny brass buckle only. Medieval-based fantasy retaining medieval everyday atmosphere with ordinary fantasy adaptation allowed. No modern clothing/materials/sewing, no plastic ornaments; matte clay/vinyl is rendering language only.
Output true transparent background alpha=0, solid opaque character alpha=255, only 1-2px antialiased silhouette edge. No floor, no cast shadow patch, no drawn checkerboard, no text, watermark, labels, border or extra views.
```

### 3 · A 팔·망토·자세 보정

```text
Use case: precise-object-edit. Image 1 is the Fargh A EDIT TARGET. Image 2 approved Nib is camera/style reference only. Preserve Fargh's exact identity, wolf face, torn ear, cheek scar, gray/cream colors, toy-clay style, armor, single shoulder pad, steel forearm bracers, belt, boots, back-mounted two-handed sword, and empty hands. Make ONLY these pose/occlusion corrections for 3D modeling:
1. Move BOTH arms farther outward into a neutral A-pose, roughly 35 degrees from vertical, hands down and away, not horizontal. There MUST be a broad continuous TRANSPARENT WEDGE between each entire forearm and torso. Keep the short green cape strictly behind the central torso; remove cape fabric that fills those arm-to-torso gaps. Shorten the cape to belt height and keep cream fur collar tight to neck, not bridging across arms.
2. Move the hanging fluffy gray tail farther toward viewer's RIGHT, keeping the tail behind the hip, so the entire lower tail silhouette has clearly visible TRANSPARENT SPACE between it and the right leg/boot. Its root may attach behind the hip, but the tail must not touch or overlap either leg below the hips. Gray tail with cream tip in only 3-4 rounded masses.
3. Maintain front-left 3/4 view around 30-45 degrees and same slightly elevated camera as Nib. Keep head very large and body about two heads tall. Keep both legs and boots separated. Do not change the character or add accessories.
ONE full-body character only. Exact requested 1536x1536 square with generous transparent padding on ALL sides, no cropping. REAL transparent background (not painted black/checkerboard), interior fully opaque alpha255 and background alpha0, only 1-2 pixel antialiasing on contour. No shadow, floor, text, outlines or additional views.
```

### 4 · A 꼬리 분리 보정

```text
Use case: precise-object-edit. Image 1 is Fargh A EDIT TARGET. Preserve the entire character, exact pose, face, framing, costume, sword, hands, arms, both legs and boots, style and colors. Correct ONLY THE TAIL so it is separated from BOTH LEGS for animation modeling.
Current tail touches the outer right thigh/knee. Replace it with a downward-hanging curved wolf tail entirely OUTSIDE the leg silhouette on the viewer's right. The narrow tail root attaches at the REAR WAIST directly below the belt, then bends OUTWARD to the RIGHT BEFORE descending. The tail's lower body must be shifted farther RIGHT so that a broad clearly visible uninterrupted transparent gap separates tail from trousers AND boots all the way from upper thigh to the bottom tip. The tail is NOT behind a thigh, NOT touching a knee, NOT touching a boot. The lower tail can end at knee height. Keep it well away from the right hand too. Gray smooth fluffy tail formed from 3 big rounded lobes, small cream tip, no fine hairs. Do not change legs or arm pose to make room; just reposition/recurve tail outward. Add transparent canvas margin if required. Same front-left 3/4 toy-clay character, two-heads tall. Fully transparent background, fully opaque body, no floor or shadow. Requested output1536x1536 square. No other changes.
```

### 5 · B 최종 의상·자세 보정

```text
Use case: precise-object-edit. Image 1 is the final Fargh A pose/camera EDIT TARGET. Image 2 is Fargh B COSTUME REFERENCE ONLY. Create final Fargh B by changing ONLY the outfit of image 1 to the plain traveler outfit of image 2.
KEEP image 1's exact gray wolf head, huge head/two-heads-tall body proportions, face, half-lidded solid amber button eyes without highlights, torn ear notch, cheek scar, short rounded cream muzzle, same neutral closed mouth. KEEP the exact front-left three-quarter camera, very wide EMPTY-HANDED modeling A-pose and transparent gaps between BOTH arms and torso, both separate legs/boots, and especially the tail ROOT AT BELT with tail curved OUTWARD and a clear continuous transparent gap between tail and BOTH legs from thigh down. Do not use image 2's closer arm pose or its overlapping tail.
REPLACE armored outfit: remove ENTIRE sword, hilt, pommel, crossguard, scabbard, diagonal sword harness, single steel shoulder pad, both steel forearm bracers and ALL metal armor. Replace with plain warm brown leather VEST over an OATMEAL CLOTH SHIRT, oatmeal sleeves clearly visible on both exposed arms, plain brown belt with ONE small simple brass buckle, brown trousers and plain brown boots. Short plain forest-green cape behind central torso ending at belt, with no cape fabric bridging arm/body transparent gaps. Cream natural neck fur only small close-fitting smooth lobes; no large armor collar. Plain reusable everyday medieval travel clothes, no jewelry, extra straps, profession-specific accessories, rivets or stitching. Same matte clay toy finish, broad smooth colors and rounded shapes as approved Nib, absolutely no realistic fur or ink outlines. Medieval-based fantasy retaining medieval everyday atmosphere with ordinary fantasy adaptation.
BOTH HANDS EMPTY relaxed mitten hands. No weapons or armor anywhere. One full-body character, no extra views. Transparent margin around entire character, requested square1536x1536. Real RGBA background alpha0, body opaque255, only 1-2px antialiased contour. No floor, no shadow patch, no text. Preserve image1 anatomy, arms and separated tail; change ONLY clothing.
```

## 규격·알파 처리

도구는 프롬프트의 1536×1536 요청과 달리 1254×1254 PNG를 반환했다. 최종 소스의 알파도 본체 대부분이 252~254 부근인 반투명이었다. 원본은 수정하지 않고, 납품본에만 [처리 스크립트](raw/finish-and-validate.ps1)를 적용했다.

1. 알파 128 이상을 실루엣 기준 마스크로 삼았다.
2. 3×3 이웃이 모두 본체인 내부는 알파 255, 모두 바깥인 영역은 0으로 정리했다. 경계의 낮은 알파 16 이하는 0, 240 이상은 255, 나머지는 253 기준으로 정규화했다.
3. 경계의 RGB는 반경 3px 안 가장 가까운 불투명 내부 색을 사용해 원본에 남은 붉은색·노란색 외곽 잡색을 줄였다. 형태·복장·포즈를 새로 그리거나 배경을 합성해 대체하지 않았다.
4. 투명 외부에서 2px보다 깊은 곳에 고립된 중간 알파를 255로 확정했다.
5. 원본 캐릭터를 확대·축소하지 않고, 가시 실루엣을 1536×1536 투명 캔버스 중앙으로 평행 이동했다. A 이동량 (147,150), B (118,149).
6. 밝은 바탕·어두운 바탕 QA PNG를 `raw/*-qa-light.png`, `raw/*-qa-dark.png`로 만들었다. 이들은 검수용 합성본이며 납품용 투명 PNG와 구분한다.

스크립트는 System.Drawing과 C#으로 알파·여백 규격만 정리한다. 내장 생성 도구로 만든 원화를 보존하고, Python 이미지 편집은 사용하지 않았다. 재현:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File art/concepts/characters/beastfolk-fargh-model-v01/raw/finish-and-validate.ps1
```

정량 결과는 [validation.json](raw/validation.json)에 보존했다.

| 검사항목 | A | B |
| --- | ---: | ---: |
| 최종 크기 | 1536×1536 | 1536×1536 |
| 파일 크기(bytes) | 1207053 | 1055198 |
| 알파 0 픽셀 | 1810774 | 1841790 |
| 알파 255 픽셀 | 539336 | 509552 |
| 외곽 중간 알파 픽셀 | 9186 | 7954 |
| 알파 0에서 2px보다 깊은 중간 알파 | 0 | 0 |
| 가시 연결 성분(8방향) | 1 | 1 |
| 투명 여백 좌/상/우/하(px) | 333 / 202 / 332 / 202 | 350 / 198 / 350 / 199 |

최종 SHA256:

- `fargh-3q-a-v01.png`: `2a12eeb3c68bc9b109a8844a1cb6e38fda8febf505504c392043256b77f4b173`
- `fargh-3q-b-v01.png`: `8dd4093f8f5d127276e7331562564393e144fb92c627f44e9215c6bbcb255b17`

## 시각 검수

최종 PNG와 밝음·어두움 QA를 실제로 열어 확인했다.

| 항목 | 검수 결과 |
| --- | --- |
| 니브 v03·마녀 A와 화풍 | 큰 머리·짧은 몸의 약 2등신, 매끈한 무광 점토 장난감 조형, 둥근 덩어리, 부드러운 명암. 별도 먹선 없음. |
| 정체성 | 회색 늑대 머리, 짧고 둥근 크림 주둥이·목, 호박색 단추 눈, 한쪽 귀의 결손, 볼의 단순 흉터, 과묵한 입, 회색 꼬리. 눈에 동공·점 하이라이트 없음. |
| 팔·빈손 | 두 팔이 아래·바깥을 향하는 A자. 양손 모두 빈손. 망토를 짧게 보정해 팔과 몸통 사이 빈 공간 확보. |
| 다리 | 상의 아래 두 다리와 두 신발이 각각 드러나며, 가운데 투명 간격이 이어짐. |
| 꼬리 | 허리 뒤에서 바깥으로 휘어 내려오는 덩어리. 다리·신발과 떨어지는 투명 틈 확보. 꼬리 끝은 크림색으로 각색. |
| 시점·여백 | 앞-왼쪽 사선 한 방향, 니브와 유사한 약한 내려다보기. 전신과 검·귀·꼬리가 모두 들어가며 최소 투명 여백 198px 이상. |
| A 복장 | 모피 깃·짧은 초록 망토·가죽 갑옷·강철 어깨받이 하나·팔토시·황동 버클. 양손검은 손이 아니라 등에 장착. |
| B 복장 | 갑옷·검·강철 팔토시 제거. 갈색 조끼·귀리색 셔츠·초록 망토로 다른 직업에도 재활용할 수 있게 구성. |
| 세계관 | 중세 생활감에 맞는 천·가죽·강철·황동 의상/장비. 현대 복식이나 장신구 없음. |
| 배경 | 실제 투명 알파, 구워진 체크무늬·바닥·그림자 패치 없음. 밝은/어두운 바탕에서 외곽 확인. |

## 한계와 모델링 인계

- 이번 결과는 3D 모델링을 위한 단일 사선 원화 시안 2장이다. 3D 메시·리깅·파츠 분리나 게임 적용까지 검증한 결과는 아니다.
- 카메라 30~45°는 프롬프트 지시와 시각 기준이며, 생성 이미지에서 정확한 회전각·카메라 높이를 수치로 복원하거나 캘리브레이션한 자료는 아니다.
- A와 B는 독립 생성/편집 결과이므로 머리 크기·팔 각도·의상 두께에 작은 차이가 있다. 실제 모델링 때 동일 베이스 몸체로 정리해야 한다.
- 뒷면과 가려진 검집 하단은 한 장에서 다 보이지 않는다. 등 장착 양손검의 손잡이·가드는 명확하지만, 전체 검/검집과 망토의 후면 구조는 모델링 단계에서 결정해야 한다.
- 금속·신발에는 생성 이미지 특유의 매우 약한 표면 잔흔이 남아 있다. 실제 텍스처 제작에서는 이를 필수 세부로 복제하지 않고 큰 매끈한 색면으로 단순화한다.
- 본체 외곽의 1~2px 알파 정리와 경계색 정리 때문에 최종 납품본은 서비스 원본과 해시가 다르다. 모든 원본은 아래와 같이 그대로 보존했다.

### 생성 원본 SHA256

- `raw/fargh-3q-a-generated-v01.png` (945022 bytes)
  - SHA256: `dc2371fa266f082035cd8a94992671927c3e2c7d2c0e0898e57a5bb14e8d1d05`
- `raw/fargh-3q-a-pose-revision-v01.png` (961988 bytes)
  - SHA256: `90699ab500a1db344cc6a29bda2252b2bb885ad1f5f94ee658f0cb0329755ddb`
- `raw/fargh-3q-a-tail-revision-v01.png` (993995 bytes)
  - SHA256: `ba55e0a93e572e957e29d141cf23bb6547ee01549f058abfc907836c7c577d95`
- `raw/fargh-3q-b-generated-v01.png` (838968 bytes)
  - SHA256: `a42eafd8be59f349a5212a78847057d5ca0d1061feb42a787dd339668e9697d9`
- `raw/fargh-3q-b-pose-revision-v01.png` (890869 bytes)
  - SHA256: `052a68d87ad6468530a4a70be1ef4de06388cbca5b77c8b57fe35a9d57f532b8`

