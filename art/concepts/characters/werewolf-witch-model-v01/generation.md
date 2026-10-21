# 늑대인간 마녀 변신체 — 모델링용 3/4뷰 v01

- 요청서: `docs/handoff/codex-werewolf-witch-model-3q-v01.md` (UTF-8로 읽음)
- 제작일: 2026-10-21
- 제작 방식: 내장 `image_gen` 도구, 모든 호출 `transparent_background=true`. CLI/API 대체 경로 사용 없음.
- 범위: 이 폴더에 원화와 기록만 생성. 게임 적용·Tripo 모델링·실행파일 갱신·커밋 없음.

## 실제 열어 본 입력 이미지 및 호출별 사용

1. `art/concepts/characters/witch-north-model-v01/witch-3q-a-v01.png`
2. `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png`
3. `art/concepts/characters/beastfolk-common-model-v02/beastfolk-common-3q-v02.png`
4. `art/references/characters/stylized-toy-chibi-ref-01.png`

입력 1은 마녀의 정체성·색, 2는 무광 점토 마감·카메라, 3은 기존 회색 수인과의 차별화, 4는 큰 덩어리 조형만 참고했다. 네 장 모두 `view_image`로 실제 열고 최초 A/B 생성 호출의 `referenced_image_paths`에 순서대로 전달했다. 각 후속 보정은 해당 최초 생성 PNG 한 장을 실제 이미지 입력으로 전달했다. 최종 A는 첫 A로부터 두 번째 꼬리 보정을 거친 뒤 1536×1536 중간본을 입력해 머리를 확대한 결과이며, 최종 B는 첫 B로부터 첫 보정이다. A의 머리 확대 실제 입력은 `raw/werewolf-a-proportion-input.png`에 보존했다. 첫 A 꼬리 보정은 손과 겹침이 남아 채택하지 않았다.

## 실제 프롬프트 전문

### A initial

원본 보존: `raw/werewolf-a-initial.png`

```text
Use case: stylized-concept.
Asset type: single full-body 3D modeling concept, werewolf transformation of the player witch in Witch's Lodge, NOT an ordinary clothed beastfolk guest.
Input reference images, in order: 1 witch-3q-a-v01.png = primary identity and palette: muted purple hooded cape, chestnut wavy hair, cream dress, brown leather belt with simple square buckle. 2 nib-3q-v03.png = primary smooth matte clay/vinyl toy style and exact camera height. 3 beastfolk-common-3q-v02.png = differentiation reference only: the existing friendly grey wolf guest must NOT be copied; this transformed witch must look visibly heavier, stronger, more wolf-like and feral. 4 stylized-toy-chibi-ref-01.png = broad simple sculpted shape language only; do not copy any character, costume or props.
Scene/backdrop: genuinely transparent alpha background, isolated character, no ground, no floor shadow, no backdrop, no checkerboard painted in.
World: medieval-based fantasy; retain medieval everyday materials and atmosphere while allowing fantasy adaptation. Only simple cloth remnants and leather belt; no modern elements.
Style/medium: match images 1 and 2: smooth matte clay/vinyl toy, soft broad shading, no outlines, no ink, no fine fur strands, no surface noise, no realistic muscles, no photorealism. Fur is only a few large rounded sculpted tufts. Only 3–5 dominant color regions: dark warm brown/grey-brown fur connected to the witch's chestnut hair, cream muzzle and bare belly, muted purple cape fragments, brown belt with small simple buckle; pale lavender eyes as tiny accents. NO cool grey guest fur.
Face: unmistakable wolf head and muzzle, simple narrow small solid pale-lavender eyes with NO pupils or highlights, gently sharp brows. Stalwart and fierce but not horrific. No blood, wounds, tooth detail or bared rows of teeth; at most two tiny blunt fangs.
Composition/camera: square 1536 x 1536 requested; centered full body with all ears, feet, paws and tail safely inside frame, overall ear-tip-to-foot height about 1200 px (1150–1250), generous transparent margins. FRONT-LEFT three-quarter view 30–45 degrees, face points slightly towards image left, both eyes and both arms visible, same mildly elevated studio camera as Nib reference, no wide angle distortion.
Rigging pose: exactly one character standing on TWO feet in a clear open A-pose. Both arms slope down and outward away from the torso with transparent gaps, both empty hands visible, each paw has only 3–4 thick blunt digit/claw masses. Two legs clearly separate with an open gap. A short thick tail grows behind the pelvis and extends rearward to image right; its visible outer segment must have a transparent gap from both legs and both arms, never cross a hand or ankle. Cape remnants short and close to the body, never bridge the arm-body gaps.
No text, labels, frames, diagram, extra character, weapons, staff, lantern, shoes, trousers, armor, jewellery, elaborate accessories, detached fur bits, magic aura or semi-transparent glow. Keep the solid character fully opaque; only 1–2 pixel edge antialiasing.
VARIANT A — CLAY TOY WEREWOLF: Very compact approximately 2.0–2.3 heads tall, proportion defined by wolf skull excluding ear tips. A large rounded wolf head with a short clearly projecting muzzle, round barrel chest, wide heavy shoulders, short thick legs, huge round forepaws. Very slight forward lean but almost upright, reliable heavy protector. Retain witch identity in a muted purple hood thrown back OFF the head, pooled behind the neck as a short attached hooded mantle around the shoulders, and chestnut wavy crown/mane clumps. A brown leather waist belt with a plain square buckle remains; no lantern. Bare fur torso and legs, not a dressed wolf child, cream belly exposed; no intact dress. More bulky than reference witch by approximately 1.3–1.5 times perceived body volume at the same camera scale. The great head, broad torso and huge round paws must remain simple, cute but imposing in mass.
```

### A tail attempt rejected

원본 보존: `raw/werewolf-a-tail-attempt.png`

```text
Use case: precise-object-edit. Input is werewolf variant A, an already approved direction of a smooth matte clay toy concept. Change ONLY the tail position to fix the modeling silhouette. Keep the exact head, ears, face, body proportions, color, purple folded-back hood, belt, bare cream belly, arms, hands, legs, feet, camera, lighting and toy finish unchanged.
Remove the current tail that overlaps the image-right paw. Replace it with a short thick curved tail emerging BEHIND the image-right hip, curving diagonally DOWN and OUT to the right, then curling up at its end. Keep its entire visible shape BELOW the hanging right hand, and to the RIGHT of the leg. Place its cream tip in the empty far-right space near ankle height. There must be a clean visible TRANSPARENT GAP of at least 30 pixels between the entire visible tail and both the hand above and the leg to its left; only its natural hip attachment may touch the body. No tail pixels behind or beside the fingers. Reduce tail thickness if necessary. Do not create a detached tail.
The image remains ONE full-body 2.0–2.3-head-tall toy werewolf in an A-pose, front-left three-quarter view, both paws empty with 3–4 blunt digits, all appendages inside canvas. Medieval-based fantasy cloth/leather, no lantern or modern props. Genuinely transparent background, fully opaque character, only 1–2 px edge antialiasing, no floor/shadow, no text. Requested square canvas 1536 x 1536 and character height ~1200px.
```

### A tail selected (머리 확대 전 중간 단계)

원본 보존: `raw/werewolf-a-selected.png`

```text
Use case: precise-object-edit. Input is variant A of a full-body smooth matte clay toy witch-werewolf. Preserve its exact rounded compact proportions, huge wolf head, soft materials, warm chestnut fur, cream muzzle/belly, narrow pale lavender eyes, folded-back purple hood around neck/shoulders, brown belt and buckle, thick short legs, broad paws, FRONT-LEFT three-quarter view, open A-pose.
Mandatory change: REMOVE THE ENTIRE TAIL FROM IMAGE RIGHT. There must be NO tail on the right side and no tail emerging from or touching a hand. Add a short curved thick tail emerging BEHIND THE IMAGE-LEFT HIP. Its visible tail sweeps down/out to the LEFT into the empty space beside the lower leg, beneath the image-left hand. The tail tip points left and slightly upwards and is cream colored. The upper contour of the ENTIRE visible tail must be at least 40 pixels BELOW the lowest image-left fingertip. The outer tail is separated from the shin by transparent air. Only the tail's rear-hip base may touch the body. If needed, shift the image-left arm out/up by ten degrees, keeping its downward A-pose and empty paw, to give tail room. Do not make a detached tail. The tail must be MUCH SMALLER than the head and not dominate the silhouette.
Output: one whole 2.0–2.3-head-tall broad bulky toy werewolf, not an ordinary clothed animal child; two separated legs/feet, two empty paws with 3–4 blunt digits. Medieval-based fantasy. No text, no props, no floor, no shadow, true transparent alpha outside, solid fully opaque body, 1–2 pixel antialiased edges. Square 1536x1536, ear-to-toe height ~1200px.
```

### B initial

원본 보존: `raw/werewolf-b-initial.png`

```text
Use case: stylized-concept.
Asset type: single full-body 3D modeling concept, werewolf transformation of the player witch in Witch's Lodge, NOT an ordinary clothed beastfolk guest.
Input reference images, in order: 1 witch-3q-a-v01.png = primary identity and palette: muted purple hooded cape, chestnut wavy hair, cream dress, brown leather belt with simple square buckle. 2 nib-3q-v03.png = primary smooth matte clay/vinyl toy style and exact camera height. 3 beastfolk-common-3q-v02.png = differentiation reference only: the existing friendly grey wolf guest must NOT be copied; this transformed witch must look visibly heavier, stronger, more wolf-like and feral. 4 stylized-toy-chibi-ref-01.png = broad simple sculpted shape language only; do not copy any character, costume or props.
Scene/backdrop: genuinely transparent alpha background, isolated character, no ground, no floor shadow, no backdrop, no checkerboard painted in.
World: medieval-based fantasy; retain medieval everyday materials and atmosphere while allowing fantasy adaptation. Only simple cloth remnants and leather belt; no modern elements.
Style/medium: match images 1 and 2: smooth matte clay/vinyl toy, soft broad shading, no outlines, no ink, no fine fur strands, no surface noise, no realistic muscles, no photorealism. Fur is only a few large rounded sculpted tufts. Only 3–5 dominant color regions: dark warm brown/grey-brown fur connected to the witch's chestnut hair, cream muzzle and bare belly, muted purple cape fragments, brown belt with small simple buckle; pale lavender eyes as tiny accents. NO cool grey guest fur.
Face: unmistakable wolf head and muzzle, simple narrow small solid pale-lavender eyes with NO pupils or highlights, gently sharp brows. Stalwart and fierce but not horrific. No blood, wounds, tooth detail or bared rows of teeth; at most two tiny blunt fangs.
Composition/camera: square 1536 x 1536 requested; centered full body with all ears, feet, paws and tail safely inside frame, overall ear-tip-to-foot height about 1200 px (1150–1250), generous transparent margins. FRONT-LEFT three-quarter view 30–45 degrees, face points slightly towards image left, both eyes and both arms visible, same mildly elevated studio camera as Nib reference, no wide angle distortion.
Rigging pose: exactly one character standing on TWO feet in a clear open A-pose. Both arms slope down and outward away from the torso with transparent gaps, both empty hands visible, each paw has only 3–4 thick blunt digit/claw masses. Two legs clearly separate with an open gap. A short thick tail grows behind the pelvis and extends rearward to image right; its visible outer segment must have a transparent gap from both legs and both arms, never cross a hand or ankle. Cape remnants short and close to the body, never bridge the arm-body gaps.
No text, labels, frames, diagram, extra character, weapons, staff, lantern, shoes, trousers, armor, jewellery, elaborate accessories, detached fur bits, magic aura or semi-transparent glow. Keep the solid character fully opaque; only 1–2 pixel edge antialiasing.
VARIANT B — MORE FERAL WEREWOLF: A deliberate mild departure from the common guest proportions, approximately 2.5–3.0 heads tall measured by skull height excluding ears. Huge upper body and smaller lower body form an inverted triangle. LONG thick arms extend outwards in an open A-pose and reach hands close to knee level. Hunched back with wolf head held visibly FORWARD of the shoulders, longer projecting muzzle than A. Large swollen neck/shoulder mane formed by only a FEW broad chunky rounded fur locks, chestnut among the dark warm grey-brown fur. Simple digitigrade beast legs: raised heels, bent hocks, wide bare paws, both feet stand on ground with clear leg separation. A torn short muted purple cape scrap hangs on ONLY ONE shoulder close to the body; a short ragged cream cloth remnant hangs just below the brown waist belt; chest and belly otherwise bare fur. No complete outfit. More feral, heavier brow, stronger silhouette than A yet the SAME soft matte toy finish as Nib and witch. Do not turn into a realistic monster or a thin athletic adult. Keep distinct 2.5–3 head proportions even with crouch.
```

### B selected

원본 보존: `raw/werewolf-b-selected.png`

```text
Use case: precise-object-edit. Improve this SINGLE variant B werewolf 3D modeling concept. Preserve the matte clay toy finish, warm grey-brown fur with chestnut crown locks, pale lavender small eyes, cream muzzle/belly, one-shoulder short purple torn cape, belt, short cream waist cloth, long arms, large mane, digitigrade feet, three-quarter FRONT-LEFT view and transparent background.
CRITICAL CORRECTION: erase the entire tail at image RIGHT. Draw the tail instead emerging behind the image-LEFT hip at belt-to-upper-thigh height. It sweeps out to the LEFT of the body, BELOW the image-left hand, curving left/down then its tip gently up, in the empty space at the far LEFT of the canvas beside the shin. Keep a clear transparent gap between the visible tail and the fingers above it, and between the outer tail and the left shin to its right. NO tail at all on image right, no tail touching any hand, no hand growing a tail, no tail fused to a leg. Tail only attaches at the rear hip. You may lift the image-left arm outward by 10 degrees to open enough room, preserving long arms and an open A-pose. Shift body to image right slightly if needed to reserve space for tail at image LEFT.
Also clarify the raised-heel digitigrade hocks and hunched shoulders/head-forward silhouette, while retaining B's 2.5–3 head-tall proportions (head height includes ears), broad upper body and small lower body.
One full character, both empty hands and both separated legs, 3–4 blunt digits per paw, medieval-based fantasy, fully opaque solid subject on true transparent alpha, no text/floor/shadow/props. Square 1536x1536 requested; full ear-to-toe height ~1200px.
```

### A final — head proportion correction

실제 이미지 입력: `raw/werewolf-a-proportion-input.png` (이전 A 꼬리 채택본을 기술 정리한 1536×1536 파일).
생성 원본: `raw/werewolf-a-proportion-final.png`.

```text
Use case: precise-object-edit. This is werewolf variant A. Make ONE proportion correction only: enlarge the ENTIRE WOLF HEAD INCLUDING BOTH EARS AND MUZZLE by approximately 25 percent relative to the body. The head (top of ears to bottom of wolf jaw, NOT including long neck/shoulder mane) must be about 45 percent of total ear-tip-to-toe height, giving approximately 2.2 heads tall. Right now the head is only about 39 percent; fix that clearly. Move the enlarged head upward as needed, and uniformly refit the whole figure into the square canvas with comfortable margin. Keep head camera/yaw and expression unchanged. This is the rounder extra-chibi A version, so make the head noticeably larger relative to its short body than variant B.
Keep ALL other design details and relative body proportions: barrel torso, round wide shoulders, short thick legs, huge rounded 3–4-digit paws, empty hands, open A-pose, legs separated, small tail at IMAGE LEFT below the hand with clear transparent gap, purple folded-back hood around neck and shoulders, brown belt, chestnut wave-shaped hair/fur locks, cream bare belly, solid narrow pale-lavender eyes without highlights. Keep the smooth matte clay toy rendering and soft shading, no outlines or fine fur. No new costume or prop. Medieval-based fantasy.
One entire character, front-left three-quarter view, truly transparent background, opaque character, no floor or shadow or text. Square 1536x1536 requested, overall character height about 1200 pixels.
```

## 납품 및 기술 처리

- 최종 A: `werewolf-3q-a-v01.png`, 최종 B: `werewolf-3q-b-v01.png`. 모두 **1536×1536, PNG RGBA**.
- 비교판: `werewolf-v01-contact.png`, **3800×1030 RGB 불투명 PNG**. A/B/마녀 A/니브 v03/수인 공용 순서. 원본 픽셀 기준 **전원 55% 동일 배율**, 발 기준선 정렬, 인물별 키 정규화 없음. 비교판의 source alpha height는 alpha≥128 경계 기준이므로 아래 alpha>0 높이와 2~4px 차이가 난다.
- 원본 `raw/*.png`는 생성 도구 결과를 바이트 그대로 복사했다. 최초 생성·채택하지 않은 보정도 남겼다. 생성 원본은 모두 1254×1254이며, 정확한 납품 규격 1536×1536은 후처리로 맞췄다. `raw/werewolf-a-proportion-input.png`만 실제 다음 호출에 전달한 1536×1536 중간 입력이다.
- 재현 스크립트: `raw/prepare-deliverables.ps1` (PowerShell + System.Drawing). 선택된 생성물의 가장 큰 연결 실루엣을 유지하고 미세한 분리 알파 잡점을 제거했다. 본체 내부 alpha를 255로 정리하고 외곽 2px 범위의 생성 알파만 보존했다. 투명 경계 RGB를 인접 본체 색으로 정리해 색 테두리를 줄였다. 종횡비를 유지하며 실루엣 높이를 1200px로 조정하고, 투명 캔버스 중앙에 배치했다. 색보정·새 그림 합성·수동 팔다리 수정은 하지 않았다. 그림 수정은 모두 내장 image_gen으로 했다.
- 입력 레퍼런스 파일은 읽기만 했다. 비교판에서도 입력의 기존 알파를 그대로 합성했다.

## 크기·알파 수치 검수

좌표 원점은 좌상단, bbox 우·하단은 exclusive. 본체 영역은 alpha=255, 바깥은 alpha=0, 반투명 픽셀은 alpha 128 경계의 안팎 2px 이내인지 전수 검사했다.

| 항목 | A | B |
| --- | ---: | ---: |
| 크기 | 1536×1536 | 1536×1536 |
| alpha>0 bbox | [273,168,1263,1368] | [174,168,1363,1368] |
| 전체 높이 (귀 끝~발 바닥, AA 포함) | 1200px | 1200px |
| alpha=0 픽셀 | 1,588,075 | 1,555,502 |
| alpha=255 픽셀 | 748,028 | 771,142 |
| alpha=1~254 픽셀 | 23,193 | 32,652 |
| 외곽 2px 범위 밖 반투명 픽셀 | 0 | 0 |
| 네 모서리 alpha | 0/0/0/0 | 0/0/0/0 |

머리 높이는 **귀를 포함한 머리 상단~주둥이 아래 턱 경계**, 목·어깨 갈기는 제외한 투영 높이로 시각 측정했다. 턱·목 경계가 부드러워 약 ±10px 오차가 있다. 이 측정은 3D 해부학상 두개골 높이나 실물 길이가 아니다.

| 측정 | A | B |
| --- | ---: | ---: |
| 머리 위 y | 168 | 168 |
| 턱 아래 y (근사) | 752 | 622 |
| 머리 높이 (근사) | 584px | 454px |
| 전체 높이÷머리 높이 (근사) | **2.05등신** | **2.64등신** |
| 전체 중 머리 비율 | 48.7% | 37.8% |

마녀 A의 alpha>0 높이는 1048px이며, 두 늑대 시안은 높이로 약 1.15배이다. 몸통·어깨·손 폭을 늘려 변신 전보다 묵직하게 읽히도록 했다. 요청의 1.3~1.5배 **부피감**은 시각 목표로 적용했으며, 2D 한 장에서 3D 부피를 계측한 수치는 아니다.

## 최종 시각 검수 및 한계

- **화풍:** 최종 A/B와 비교판을 실제 열어 확인했다. 니브·마녀와 같은 매끈한 무광 장난감 재질, 부드러운 명암, 큰 색면, 외곽 먹선 없음. 갈기는 낱털 대신 넓은 조각으로 구성했다. B는 A보다 덩어리가 더 각지고 크다.
- **마녀 정체성:** 두 시안 모두 갈색 웨이브 정수리/갈기, 보라 망토, 갈색 벨트·사각 버클, 크림색을 남겼다. A는 뒤로 젖힌 두건과 둥근 목 망토, B는 한쪽 어깨의 찢긴 보라 천과 짧은 크림 허리 천. 등불·지팡이·무기 없음.
- **기존 수인과 구분:** 따뜻한 갈색~회갈색 털, 돌출된 늑대 주둥이, 연보라 작은 눈, 맨 털 몸통, 거대한 앞발로 회색 여행복 수인과 구분된다. 눈 하이라이트·동공·피·상처·이빨 열 없음; 보이는 짧은 송곳니는 하나이다.
- **A/B 차이:** A는 큰 머리·짧은 몸·굵고 짧은 다리·둥근 앞발의 약 2.05등신. B는 약 2.64등신, 무릎 부근까지 오는 긴 팔, 큰 어깨/갈기, 더 긴 주둥이, 굽힌 짐승 다리로 더 야성적이다. B의 전방 머리/굽은 등은 완만한 편이며 극단적으로 웅크리지는 않았다. 발뒤꿈치와 관절은 단순 조형으로 읽히지만, 정확한 디지티그레이드 골격 설계는 모델링 단계에서 확인해야 한다.
- **시점·자세:** 둘 다 얼굴이 화면 왼쪽을 향하는 앞-왼쪽 3/4 전신. 니브와 비슷한 약한 내려다보기. 한 명, 두 발 서기, 양팔 아래-밖으로 벌린 A자, 빈손, 손발의 뭉툭한 3~4개 덩어리, 양쪽 다리 분리.
- **꼬리:** 두 시안 모두 후속 보정으로 꼬리를 화면 왼쪽 뒤-옆으로 옮겼다. 손·다리 바깥쪽 꼬리 사이에 투명 공간이 보인다. 골반 쪽 꼬리 뿌리는 몸/허벅지 뒤에 부분 가려지며, B의 손 아래 꼬리 간격은 좁은 편이다. 단일 3/4뷰에서 숨은 연결부의 입체 구조까지 확정할 수는 없다.
- **세계관:** 중세 판타지의 단순 천·가죽·버클만 사용. 현대 물건 없음.
- **진행 범위:** 원화 시안 두 장 납품까지만 완료. 사용자 선택·승인, Tripo 메시/리깅, 게임 적용은 진행하지 않았다.

## SHA256

| 파일 | SHA256 |
| --- | --- |
| werewolf-3q-a-v01.png | `B8540401EB8C29C14E7E9D63D584EEDB9C669884C9FBA869B1AEC8F22E569CFC` |
| werewolf-3q-b-v01.png | `F6AA94483E790A4374C41DC3BE3977A9A6AEAE82DE63F7C936BA8A1E2FEAFEBC` |
| werewolf-v01-contact.png | `E1D7CF40F3394F8D77D6B6D27D46835D3454FAF97C0A84B2741B98B08A400954` |
| raw/werewolf-a-initial.png | `74D50199498C7D877AB4E86538A118AEED809D2F52AB501FD588C0CF9816171E` |
| raw/werewolf-a-tail-attempt.png | `9C8D6127B022FC9FEC997865B51FDBFB2C0F2B34E55DB0E8DC1204EC2E22CF65` |
| raw/werewolf-a-selected.png | `88AE489874966FEED62F4C82A93BB8F254D821F800FAFB74A124D8B185FE7F01` |
| raw/werewolf-a-proportion-input.png | `35B00DD9A5050887D79E688FDD89D6D7DBBD9FB3AD7AC7C1BD8DE5A2EB9E0115` |
| raw/werewolf-a-proportion-final.png | `C30538457221D2E35CBCFC9DAF8D6F47A8D0CE26420DC456F686465F78B5B936` |
| raw/werewolf-b-initial.png | `46533758C84E1EF2006C064EF82654B57362ABFE74B4E259BF941FE3B1BB3D5B` |
| raw/werewolf-b-selected.png | `1603F9EE5BFBD53A2A6F04571D408E644579D6382E05D343FEACFF827BC05992` |
