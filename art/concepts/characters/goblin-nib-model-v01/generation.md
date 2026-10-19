# 고블린 니브 · 3D 모델링용 3/4뷰 시안 v01 제작 기록

- 제작일: 2026-10-19 (Asia/Seoul).
- 요청서: `docs/handoff/codex-goblin-nib-model-3q-v01.md`를 UTF-8로 읽고 수행.
- 도구: 내장 `image_gen.imagegen` (`tools.image_gen__imagegen`), 총 5회. 별도 API/CLI는 사용하지 않았다. 도구가 모델 버전·시드 정보는 제공하지 않아 기록하지 않는다.
- 공통 인자: `transparent_background: true`. 매 호출 `referenced_image_paths`에 아래 실제 로컬 PNG를 전달했다. 단순 경로 언급이나 텍스트 묘사만으로 생성하지 않았다.
- 저장: 생성 원본 PNG를 지정 폴더에 바이트 그대로 복사. 수동 리사이즈·크롭·배경 제거·알파 보정·색보정 없음.
- 작업 범위: 이 폴더의 최종 PNG 2장과 본 문서만 생성. `godot/**`, 기존 원화·초상, `docs/**`는 수정하지 않았다. 게임 변경이 없어 실행파일 재내보내기는 하지 않았다. 다른 변경을 되돌리거나 커밋하지 않았다.
- 상태: 사용자 선택·승인 전 비교 시안. Tripo 입력·3D 모델 생성·게임 적용은 수행하지 않았다.

## 실제 이미지 입력

모든 입력을 이미지로 열어 확인했다. 아래 순서는 최초 생성 및 최종 재생성 호출의 첨부 순서와 같다.

| 번호 | 실제 입력 PNG (저장소 루트 기준) | 역할 | 해상도 | SHA256 |
| --- | --- | --- | --- | --- |
| 1 | `art/concepts/cards/roles-races-v01/02-goblin-nib-v01.png` | 니브 정체성 최우선; 원화 의상·짐 구성 | 1024×1536 | `DA3C9F43EBA6FDBD9977498983D6F866FF565171BE57B4656D32A3923AF62B16` |
| 2 | `godot/assets/portraits/guest_nib_cutout.png` | 동일 인물의 현재 게임 초상 | 1122×1402 | `79CC325D71F96E3CC358A9B6C32DC84BDA5B111206732983152C1833537DC8B1` |
| 3 | `art/concepts/monsters/winter-forest-spider-model-reference-v01/winter-spider-three-quarter-v01.png` | 단일 3/4뷰·절제된 모델링 컨셉 표현만 참고 | 1254×1254 | `473601AEB33F01950AF4E937E5A8A1AA9229B89FF250961EC1AA5AE3D834F291` |
| 4 | `art/model-sheets/starter/02-witch-player.png` | SD 머리/몸통·짧은 팔다리 비례만 참고 | 1774×887 | `7029475050485CCA8F7A608324BDE5D11E05DC2D417E4A995BAA1E8C06D34099` |

문서 기준으로 `docs/art-direction.md`, `docs/world-races-card-formats-v01.md`, `docs/character-3d-pipeline.md`도 읽었다. 중세 기반 판타지·자연 재료·큰 색면·짧고 굵은 SD 실루엣을 반영했다. 카드 프레임·레이아웃 제작 작업은 아니다.

## 최종 파일 및 수치 검수

Windows .NET System.Drawing으로 PNG를 디코딩해 모든 픽셀의 알파를 검사하고, PowerShell `Get-FileHash -Algorithm SHA256`으로 해시를 계산했다. 생성 원본과 복사본의 SHA256이 일치한다.

| 파일 | 픽셀/형식 | 크기 (bytes) | 알파 최소/최대 | SHA256 |
| --- | --- | ---: | --- | --- |
| [nib-3q-a-v01.png](nib-3q-a-v01.png) | 1254×1254 / 32-bit ARGB | 1,521,108 | 0 / 255 | `16283C314FC120758CED4D2D761E65D110A1CEA8BE9F40F29916D1A83E1D680B` |
| [nib-3q-b-v01.png](nib-3q-b-v01.png) | 1254×1254 / 32-bit ARGB | 1,364,799 | 0 / 255 | `F87A78B70F0EAF31180A996C5CFB366D76FB7EE7C107D18D25B4160F7AF4507D` |

- A: 완전 투명(알파 0) 908,984픽셀, 알파 255 1,007픽셀, 중간 알파 662,525픽셀.
- B: 완전 투명(알파 0) 898,782픽셀, 알파 255 1,042픽셀, 중간 알파 672,692픽셀.
- 진짜 알파 투명 배경이며 체크무늬·불투명 배경을 그려 넣은 이미지가 아니다. 배경·바닥·접지 그림자·글자·라벨·프레임·다중 뷰가 보이지 않는다.
- 알파 8 이상 실루엣의 경계(0부터 시작, 끝 좌표 포함): A `[177,84,1118,1193]`, B `[150,72,1121,1205]`. 이 기준 사방 여백 L/T/R/B는 A `177/84/135/60 px`, B `150/72/132/48 px`.
- **알파 품질 한계:** 생성 원본에는 알파 1–7의 극히 옅은 외곽 잡픽셀이 있다. 모든 비영 알파를 포함한 경계는 A `[0,25,1233,1221]`, B `[0,11,1252,1253]`이며, 캔버스 가장자리의 비영 알파는 각각 6 / 29픽셀이다. 따라서 사방 여백 전체가 픽셀 단위로 완전히 0이라고 판정하지 않는다. 주요 전경도 대부분 알파 252–253으로 아주 미세하게 반투명하다. 원본 알파를 보존했으며 정리된 런타임 컷아웃으로 승인된 것은 아니다.

## 시각 검수와 비교

최종 생성 출력 전체를 직접 열람하여 원화와 대조했다.

| 항목 | A · 원화 충실 | B · 게임 단순화 |
| --- | --- | --- |
| 정체성 | 연두 피부·주근깨·호박색 눈·짙은 갈색 머리·동전 끝 땋은 머리·큰 귀·장난스러운 미소 유지 | 같은 정체성 유지, 더 둥근 얼굴과 큰 머리 |
| 의상 | 붉은 주황 목도리·흰 부푼 소매·보라 X끈 조끼·가죽 벨트/멜빵·황동 버클·손목 감개·약초 주머니 | 같은 색과 핵심 의복, 끈·장식·주머니 세부 축소 |
| 비례 | 약 2.5등신 목표의 짧고 굵은 SD | 약 2등신 목표, 더 큰 머리와 짧고 둥근 몸·단순 손 |
| 등짐 | 머리 위로 솟는 목제 지게·무늬 담요·밧줄·등불·붉은 술 | 머리보다 낮은 작은 둥근 가죽 배낭·말린 담요·등불·작은 붉은 술, 목제 지게 생략 |
| 전신 | 귀끝·머리·지게 꼭대기·양손·양발 포함, 인물 1명 | 귀끝·머리·배낭·양손·양발 포함, 인물 1명 |
| 각도 | 화면 왼쪽을 향하는 앞 3/4, 얼굴·가슴 앞면과 짐 옆면 확인 | 같은 방향의 앞 3/4, 큰 머리에 비해 몸통 회전은 다소 약함 |
| 자세 | 서 있는 중립 A자 자세, 양손이 비어 있고 팔/손과 몸통 사이 빈 공간 확인 | 서 있는 A자 자세, 편하게 굽힌 빈 손과 몸통 사이 빈 공간 확인 |
| 시대·재료·조명 | 중세 판타지의 직물·가죽·목재·구리/황동, 큰 색 덩어리와 부드러운 조명 | 같은 시대·재료, 디테일 밀도와 부속 개수 축소 |

### 사용 전 남은 한계

- 등신·45° 각도·A자 각도는 그림에서 시각적으로 판단한 근사치로, 3D 치수나 정투영을 검증한 값이 아니다. 머리의 미세한 기울기, 양팔 원근 차이와 소매/지게의 부분 중첩이 남는다.
- 투명 여백은 확보되어 있으나, 프롬프트의 14%/중앙 72–75% 목표가 정확히 구현되지는 않았다. 실제 최소 여백과 옅은 알파 잡픽셀은 위 수치를 우선한다.
- A의 귀 장식·벨트·밧줄·약초와 머리카락에는 작은 형상과 표면 묘사가 남아 있어 실제 모델에서는 추가 단순화가 필요하다. B도 손·끈·목도리·등불/배낭 연결부는 생성 후 메시로 검토해야 한다.
- 등불 유리에는 따뜻한 앰버색이 남지만, 배경 후광이나 큰 투사 그림자는 없다.
- 원화에 없는 하체는 중세풍 짧은 갈색 바지와 두툼한 가죽 신발로 추정했다. 후면 구조·숨은 연결부·손가락 구조는 확정 설계가 아니다.
- 아래 프롬프트의 1536×1536 희망치와 달리 도구 실제 반환은 두 장 모두 1254×1254다. 요청서의 최소 해상도는 충족한다.
- Tripo 재구성 품질·실제 폴리곤 수·높은 게임 카메라에서의 최종 가독성은 아직 검증하지 않았다.

## 생성 이력과 실제 사용 프롬프트 전문

프롬프트는 아래 코드 블록을 변경 없이 도구에 전달했다. 최초 A/B 및 최종 A/B는 위 입력 1–4를 동일 순서로 `referenced_image_paths`에 전달했다. A의 중간 편집 1회만 A 최초 결과를 첫 입력으로 추가하고 기준 원화 4장을 뒤에 그대로 전달했다.

생성 원본 보존 폴더: `C:/Users/Loadcomplete/.codex/generated_images/01a15282-67d1-7361-886c-5be11a93ec36/`.
미선정 결과는 저장소에 추가하지 않았다.

### 1. A 최초 생성 · 미선정

- 생성 원본 파일: `exec-26a25bb2-69b5-4c5e-a66d-5162fc08bdc0.png`.
- 정체성은 유지했지만 여백과 팔 분리·짐 높이가 부족해 후속 보정.
- `transparent_background: true`.

```text
Use case: stylized-concept.
Asset type: single full-body transparent character concept for Tripo image-to-3D modeling, for the game Witch's Lodge.
Create ONE goblin merchant named Nib. This is a NEW model-reference illustration based on the four attached actual image references, NOT a card, portrait, turnaround or multi-view sheet.

Input images, in exact attachment order:
1. 02-goblin-nib-v01.png: PRIMARY identity reference, highest priority. Preserve the recognizable goblin face, colors, medieval merchant clothing and travel pack.
2. guest_nib_cutout.png: SAME PERSON, supporting current in-game portrait reference. Preserve freckles, pointed oversized ears, copper coin earrings, mischievous bargaining smile, orange-red scarf and purple vest.
3. winter-spider-three-quarter-v01.png: ONLY reference for isolated single-subject three-quarter modeling-concept presentation and restrained painterly 3D volume. Do NOT copy spider anatomy or its colors.
4. 02-witch-player.png: ONLY reference for the game's short stout 2–3-head-tall SD proportions, chunky limbs and simple readable modeled masses. Do NOT copy witch clothing, hat, hair color, multiple-view layout, labels, ground or gray background.

World: medieval-based fantasy, preserving medieval everyday atmosphere while allowing ordinary fantasy adaptation. Use linen, wool, leather, wood, rope, copper and brass. No firearms, modern clothing, plastic, zippers or modern backpack fixtures.
Identity: light yellow-green skin, warm freckles across cheeks and nose, large sharply pointed ears with copper coin ornaments and hoops, messy DARK BROWN hair grouped into large chunky locks, ONE thin braid ending in a copper coin, AMBER eyes, playful clever merchant smile with a few visible uneven teeth. Orange-red warm wool/fur-textured scarf. Off-white puff-sleeved linen shirt, purple vest with clearly readable X-shaped lacing, brown leather belt and pack shoulder straps with brass buckles, leather wrist wraps, one herb pouch at waist. Lower body extrapolation: short simple dark brown trousers and chunky brown leather medieval boots; no extra weapons.
Composition: square high resolution 1536x1536 or larger, minimum 1254x1254. ONE complete character, ONE direction. Front-left three-quarter view about 45 degrees, body and head turned together slightly toward image-left, face and chest front still visible, backpack side visible behind on image-right. Camera at chest height, only very slightly elevated, no steep overhead angle. Entire ears, fingertips, boots and pack top fully inside frame. Character centered and occupying about 80% of canvas height, at least 8% genuinely transparent padding on every side.
Pose: symmetrical neutral upright modeling A-pose, both arms angled down and out about 35 degrees away from torso, visible clear empty gaps between each wrist/hand and torso/hips/pack. Both hands empty, relaxed open or loosely curled, no holding coins or gripping straps, no finger-heart gesture. Two legs short and stout, planted shoulder width apart with readable separation; no leaning, walking, contrapposto or action pose.
Rendering: hand-painted stylized 3D concept render, large clean color blocks, readable volume, restrained brushwork, soft even neutral studio illumination, muted local creases only, subtle contour accents. Hair, scarf, vest, shirt sleeves and pack should read as separate big modeling volumes. No heavy ink-print card treatment, no dramatic shadow, no rim light, no glow/halo/smoke. Lantern may have amber glass but must not cast dramatic emissive light.
Background: ACTUAL transparent alpha background, including between limbs and outside silhouette. NO ground plane, pedestal, floor, contact/cast shadow, snow, scenery, opaque white/black/gray background, fake checkerboard, text, labels, frames, watermark, extra characters or multiple views. Preserve generated transparency.

Variant A — faithful to original:
About 2.5 heads tall from hair crown to boot soles (ear width does not count as height); big head and short stout body/limbs. Preserve nearly all of the primary illustration's overall clothing and merchant pack configuration while consolidating tiny details into a few large readable forms. Large wooden back carrying frame, rising only slightly above the hair crown, with rolled purple/red patterned blanket, a readable coil of rope, one small medieval lantern on the visible outer side, and one dangling red tassel. Copper ear hoops and coin pendants remain recognizable. Keep a visible thin coin-tipped braid. No handheld props. Do not add bundles, tools or jewelry absent from the references. This should look like recognizable Nib adapted into a compact SD modeling-ready figure.
```

### 2. B 최초 생성 · 미선정

- 생성 원본 파일: `exec-6fcc87fe-68de-40d0-add8-2cd603029df7.png`.
- 작은 배낭과 장식 축소를 추가로 강조하기 위해 재생성.
- `transparent_background: true`.

```text
Use case: stylized-concept.
Asset type: single full-body transparent character concept for Tripo image-to-3D modeling, for the game Witch's Lodge.
Create ONE goblin merchant named Nib. This is a NEW model-reference illustration based on the four attached actual image references, NOT a card, portrait, turnaround or multi-view sheet.

Input images, in exact attachment order:
1. 02-goblin-nib-v01.png: PRIMARY identity reference, highest priority. Preserve the recognizable goblin face, colors, medieval merchant clothing and travel pack.
2. guest_nib_cutout.png: SAME PERSON, supporting current in-game portrait reference. Preserve freckles, pointed oversized ears, copper coin earrings, mischievous bargaining smile, orange-red scarf and purple vest.
3. winter-spider-three-quarter-v01.png: ONLY reference for isolated single-subject three-quarter modeling-concept presentation and restrained painterly 3D volume. Do NOT copy spider anatomy or its colors.
4. 02-witch-player.png: ONLY reference for the game's short stout 2–3-head-tall SD proportions, chunky limbs and simple readable modeled masses. Do NOT copy witch clothing, hat, hair color, multiple-view layout, labels, ground or gray background.

World: medieval-based fantasy, preserving medieval everyday atmosphere while allowing ordinary fantasy adaptation. Use linen, wool, leather, wood, rope, copper and brass. No firearms, modern clothing, plastic, zippers or modern backpack fixtures.
Identity: light yellow-green skin, warm freckles across cheeks and nose, large sharply pointed ears with copper coin ornaments and hoops, messy DARK BROWN hair grouped into large chunky locks, ONE thin braid ending in a copper coin, AMBER eyes, playful clever merchant smile with a few visible uneven teeth. Orange-red warm wool/fur-textured scarf. Off-white puff-sleeved linen shirt, purple vest with clearly readable X-shaped lacing, brown leather belt and pack shoulder straps with brass buckles, leather wrist wraps, one herb pouch at waist. Lower body extrapolation: short simple dark brown trousers and chunky brown leather medieval boots; no extra weapons.
Composition: square high resolution 1536x1536 or larger, minimum 1254x1254. ONE complete character, ONE direction. Front-left three-quarter view about 45 degrees, body and head turned together slightly toward image-left, face and chest front still visible, backpack side visible behind on image-right. Camera at chest height, only very slightly elevated, no steep overhead angle. Entire ears, fingertips, boots and pack top fully inside frame. Character centered and occupying about 80% of canvas height, at least 8% genuinely transparent padding on every side.
Pose: symmetrical neutral upright modeling A-pose, both arms angled down and out about 35 degrees away from torso, visible clear empty gaps between each wrist/hand and torso/hips/pack. Both hands empty, relaxed open or loosely curled, no holding coins or gripping straps, no finger-heart gesture. Two legs short and stout, planted shoulder width apart with readable separation; no leaning, walking, contrapposto or action pose.
Rendering: hand-painted stylized 3D concept render, large clean color blocks, readable volume, restrained brushwork, soft even neutral studio illumination, muted local creases only, subtle contour accents. Hair, scarf, vest, shirt sleeves and pack should read as separate big modeling volumes. No heavy ink-print card treatment, no dramatic shadow, no rim light, no glow/halo/smoke. Lantern may have amber glass but must not cast dramatic emissive light.
Background: ACTUAL transparent alpha background, including between limbs and outside silhouette. NO ground plane, pedestal, floor, contact/cast shadow, snow, scenery, opaque white/black/gray background, fake checkerboard, text, labels, frames, watermark, extra characters or multiple views. Preserve generated transparency.

Variant B — game simplified:
About 2 heads tall from hair crown to boot soles, noticeably cuter, rounder and more compact than a 2.5-head design, with a very large rounded head, oversized pointed ears, tiny stout torso, short thick arms and legs, chunky simplified boots. Preserve Nib's same freckles, amber eyes, dark-brown messy hair, single coin-ended braid, mischievous smile, orange-red scarf, white puff sleeves, purple X-laced vest and brown leather belt.
Reduce ornamental count roughly by half: one simple copper coin earring/hoop per ear, one coin on the braid, only a few broad laces and straps, one simple herb pouch; large clean shapes, fewer seams. Simplify the merchant frame into ONE small ROUND brown medieval leather backpack with ONE rolled blanket across its top and ONE little lantern on its visible outer side, minimal rope bindings and a single small red tassel. The rounded pack should be modest in size with top around hair-crown height or lower, visually much smaller than a large wooden merchant carrying rack. Favor low polygon modeling economy and silhouette readability from a high game camera. Still show the requested front-left 45-degree chest-height A-pose view for this reference, with both hands empty and separated from torso.
```

### 3. A 중간 편집 · 미선정

- 생성 원본 파일: `exec-801ea7cc-c342-46cc-93bf-7be622cb3d94.png`.
- 실제 입력 순서: A 최초 PNG → 위 기준 1 → 2 → 3 → 4. 지게 꼭대기가 여전히 머리 아래여서 채택하지 않음.
- `transparent_background: true`.

```text
Use case: identity-preserve.
Edit image 1 (the generated full-body Nib A concept). Images 2–5 are supporting references: 2 primary original Nib card identity, 3 current portrait identity, 4 single-view modeling concept presentation, 5 SD proportions only. Keep the SAME Nib face, amber eyes, freckles, green skin, pointed ears, orange-red scarf, white shirt, purple X-laced vest, wrist wraps, herb pouch, brown trousers and boots, copper jewelry, visible coin-ended braid and original merchant-frame equipment.
Make ONLY these required modeling corrections:
1. Reframe with much more actual transparent space: the ENTIRE subject bounding box, including raised pack, both ears and feet, must occupy no more than 78% of square canvas width AND height, centered with at least 10% empty transparent border on all four sides. NO cropping, no ground, no shadow, no fake transparency grid. Produce a square PNG at least 1254x1254, ideally 1536x1536.
2. Make a true upright neutral front-left THREE-QUARTER about 45-degree view: turn the torso, boots and face together toward image-left, showing chest FRONT and the SIDE of the backpack on image-right. Head upright, do not lean or tip the head. Camera chest height, only very slightly elevated.
3. Move BOTH arms out wider into a modeling A-pose, about 35 degrees from vertical, with near-straight elbows, empty relaxed hands. Obvious open negative-space gaps between BOTH hands/forearms and torso, hips AND pack. Do not hide the far hand.
4. RAISE the top of the wooden merchant carrying frame and rolled patterned blanket until the PACK TOP stands just a little HIGHER than the hair crown, about 5% of character height higher. Keep one rope coil, one small medieval lantern on the outer side, one red hanging tassel. The full pack top must still fit inside the transparent margin.
Preserve 2.5-head-tall SD body proportions, short stout limbs, large head, recognizable original costume configuration. Consolidate tiny hair wisps into chunky locks and use broad clean color masses and softer less busy surface treatment, restrained hand-painted 3D concept render. EVEN neutral soft light, no rim light or dramatic lantern glow. Medieval-based fantasy with medieval lived-in atmosphere and ordinary fantasy adaptation, linen/wool/leather/wood/brass/copper, no modern objects. One character, one view. Absolutely NO lettering, labels, frames, background, cast shadow, duplicate views, floor or scenery. Real transparent alpha throughout empty space.
```

### 4. A 구조 우선 재생성 · 최종 채택

- 생성 원본 파일: `exec-0f98b36b-94f1-48d4-84ea-293d6342d95e.png`.
- 최종 nib-3q-a-v01.png에 바이트 그대로 복사.
- `transparent_background: true`.

```text
Create a NEW single-character modeling concept of Nib, with the exact identity and costume in attached reference images 1 and 2. Image 3 is isolated modeling concept presentation only; image 4 is chunky SD proportions only.
PRIORITY IS STRUCTURE AND POSE, NOT COPYING THE PORTRAIT COMPOSITION.
Square PNG 1536x1536 with real alpha transparency. ONE full-body goblin, ONE 45-degree front-left view. Upright neutral head, torso and boots all facing image-left together. Camera chest height very slightly elevated.
Leave a LARGE TRANSPARENT BORDER: fit the WHOLE subject in the central 72% of BOTH WIDTH AND HEIGHT. At least 14% completely empty alpha on EVERY SIDE. Whole boots, ears, fingers, raised pack within canvas.
Neutral MODELING A-POSE: both arms are held diagonally DOWN AND OUT, at 40 degrees from vertical, hands completely empty and relaxed. Both hands and forearms clear the torso AND the backpack silhouette, with large obvious transparent triangular gaps below both armpits. Legs shoulder width. No holding straps or objects.
A — faithful original version, 2.5 heads tall. Huge head, short chunky limbs. PRIMARY defining variation: large WOODEN MERCHANT CARRYING FRAME on his back; its top crossbar and rolled patterned blanket MUST BE ABOVE THE TOP OF HIS HAIR. The blanket top is the HIGHEST POINT of the character silhouette, slightly higher than the head. Frame, rolled patterned purple blanket, one coil of rope, one small medieval lantern, one red tassel. All firmly attached to frame, no floating components.
Keep Nib's yellow-green skin, freckled cheeks and nose, huge pointed ears with copper coin earrings and hoops, AMBER eyes, messy dark-brown chunky hair and single coin-ended thin braid, mischievous merchant grin, orange-red warm scarf, off-white puff-sleeved linen shirt, purple X-laced vest, brown leather belt/pack straps with brass buckles, leather wrist wraps, waist herb pouch, dark-brown short trousers and chunky leather boots. Reduce tiny filigree and texture density. No extra costume items.
Hand-painted stylized 3D concept render with broad color blocks, restrained brushwork, distinct modeled masses, EVEN soft neutral studio lighting. No heavy black card outlines, dramatic shadows, rim light or glowing lantern aura.
Medieval-based fantasy with medieval everyday atmosphere and ordinary fantasy adaptation; wood/leather/linen/wool/brass/copper. NO modern clothing, plastic or guns.
ACTUAL transparent alpha, including limb gaps. NO floor, ground shadow, pedestal, background, scenery, snow, checkerboard, frame, labels, text, watermark, duplicate character or multi-view sheet.
```

### 5. B 구조 우선 재생성 · 최종 채택

- 생성 원본 파일: `exec-a9198688-2c02-4d24-9c6f-324412af58db.png`.
- 최종 nib-3q-b-v01.png에 바이트 그대로 복사.
- `transparent_background: true`.

```text
Use case: stylized-concept. Create ONE new Nib the goblin merchant full-body image-to-3D modeling reference, variant B GAME SIMPLIFIED.
Actual image references: 1 primary Nib card IDENTITY, 2 same Nib current portrait IDENTITY, 3 single isolated three-quarter model concept PRESENTATION ONLY, 4 witch model sheet for extremely compact chunky SD PROPORTIONS ONLY (no witch costume, sheet layout or text).
PRIORITIZE SD SHAPE AND CLEAN MODELING POSE rather than portrait composition. Nib must look noticeably tiny-bodied and ROUND: about TWO HEADS TALL total hair-crown to soles; head about HALF of this height, much bigger than the short round torso; tiny thick arms and short chunky legs and boots. Dark brown messy hair as just a few large chunky locks. SAME recognizable yellow-green freckled goblin face, AMBER eyes, pointed oversized ears, playful clever merchant grin, ONE thin braid ending in a copper coin. Ornament count halved: ONE simple copper coin earring per ear, ONE braid coin, few broad straps and laces.
Costume: orange-red scarf as one big readable wrap, off-white puffy linen sleeves, purple vest with only a few X-laces, broad brown leather belt with one brass buckle, leather pack straps and wrist wraps, ONE simple herb pouch, dark-brown short trousers and rounded chunky leather boots. Simple broad clean surfaces with reduced stitching and texture, no extra bells or dangling bundles.
Pack: ONE SMALL ROUND leather backpack, ONE rolled purple patterned blanket fixed across top, ONE little medieval lantern fixed to outer side with small red tassel. NO tall wooden carrying rack, NO multiple sacks, NO extra coils of rope. Backpack side visible on image-right, pack top BELOW hair crown, and compact round pack clearly smaller than torso+head.
Pose: completely upright neutral modeling A-POSE, BOTH arms straight diagonally down and OUT 40 degrees from vertical, empty relaxed mitten-like hands, large visible transparent gaps separating both hands AND forearms from torso, hips and pack. Both feet shoulder width apart. Head upright, body/face/boots turned together about 45 degrees toward image-left, clear front-left three-quarter view with face FRONT, chest FRONT and backpack SIDE visible. Camera chest height slightly elevated.
Framing: square high-resolution PNG at least 1254x1254, ideally 1536x1536. Subject occupies no more than CENTRAL 75% of width AND height. Generous actual transparent margins on ALL FOUR sides. Whole ear tips, hair, fingers, boots and backpack inside canvas.
Style: restrained hand-painted stylized 3D concept render, large flat color blocks and soft modeling volume, VERY LOW texture/detail density and clean simplified surfaces. EVEN soft neutral light, NO dramatic shadows, rim light, lantern aura or thick ink/print texture.
World: medieval-based fantasy, keeping medieval everyday atmosphere while permitting ordinary fantasy adaptation. Natural wool/linen/leather/wood/copper/brass, NO modern clothes, plastic, firearm or zipper.
BACKGROUND MUST BE GENUINE TRANSPARENT ALPHA including limb gaps; NO floor, ground shadow, snow, scenery, pedestal, white/black/gray backdrop or fake checkerboard. One character and one view only; NO text, labels, frame, watermark or multi-view sheet.
```

