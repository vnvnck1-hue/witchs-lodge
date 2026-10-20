# Fairy 종족 공용 3/4뷰 원화 v02 제작·검수

- 작업일: 2026-10-20.
- 요청 범위: `docs/handoff/codex-race-common-models-3q-v02.md`의 **fairy 행 하나**.
- 방식: **내장 image_gen**으로 3회 생성/수정. API/CLI 대체 경로는 사용하지 않았다.
- 납품: [fairy-common-3q-v02.png](fairy-common-3q-v02.png), **1536×1536 RGBA PNG**.
- 이 작업의 프로젝트 파일 쓰기는 이 폴더와 `raw/`에만 한정했다. 다른 종족 폴더·기존 원화·docs·godot·실행파일을 수정하지 않았고 커밋하지 않았다. 게임 변경 작업이 아니므로 실행파일 재내보내기는 하지 않았다.
- 생성 도구의 자동 저장 사본은 도구 기본 경로에 생기며, 프로젝트용 원본 사본은 아래 raw에 보존했다.

## 실제로 열고 사용한 입력

세 이미지를 모두 `view_image`로 열어 확인하고 첫 image_gen 호출의 `referenced_image_paths`에 실제 파일로 전달했다. 2·3차는 직전 fairy PNG와 니브 PNG를 다시 실제 입력으로 전달했다.

| 입력(프로젝트 루트 상대경로) | 역할 | SHA256 |
| --- | --- | --- |
| `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png` | 최우선 등신·화풍·시점 | `D33657A5A0B50B9B8BDD4F6384A3014B49AA0610111DFE8015480D038FF71F1B` |
| `art/references/characters/stylized-toy-chibi-ref-01.png` | 단순 점토 장난감 형태 | `C26F3E21A10E119047DF10986BF4D27720C2E6B7A266ACA142BA2FCF78BF8687` |
| `art/concepts/characters/fairy-thistle-model-v01/thistle-3q-b-v01.png` | 종족 정체성과 색만; 긴 체형은 제외 | `8B2EF729EB013F12828DA8A74443CCB4316FD6A9F6DA006AED82E91A4D0663C2` |

세계관·아트 가이드를 읽고 모든 실제 프롬프트에 중세 기반 판타지와 중세 생활 분위기, 판타지 각색 허용을 명시했다.

## 등신 실측 및 직접 비교

[니브와 동일 배율로 나란히 놓은 비교 이미지](raw/nib-v03-comparison.png)를 실제로 열어 검수했다. 좌 니브 / 우 fairy. 수평선은 y=218 및 y=1330이다. 비교 이미지는 검수용 불투명 배경이며 납품 PNG의 배경은 투명이다.

머리는 **더듬이·귀·옆머리 끝을 제외하고 머리카락 정수리에서 얼굴 턱 아래까지**로 정의했다. 니브와 fairy 모두 머리카락을 포함한다. 분모는 정수리부터 발바닥까지다. 투영된 턱 위치는 시각 판독이므로 약 ±5px 오차가 있다. 실루엣 발 끝은 alpha≥128 경계를 사용하며 오른쪽/아래 끝 좌표는 exclusive다.

| 항목 | 니브 v03 | 최종 fairy v02 |
| --- | ---: | ---: |
| 캔버스 | 1536×1536 | 1536×1536 |
| 정수리 y | 약 218 | 약 218 |
| 턱 아래 y | 약 735 | 약 747 |
| 발바닥 y (exclusive) | 1330 | 1328 |
| 정수리~발바닥 전체 키 | 1112px | 1110px |
| 머리 높이 | 약 517px | 약 529px |
| **머리/전체 키** | **약 46.5%** | **약 47.7%** |
| 더듬이 포함 실루엣 높이 | 1112px | 1179px |

- fairy와 니브의 머리 비율 차이는 약 **+1.2%p**. 요청서의 ‘약 45%’에 대해 실제 니브 이미지의 약 46.5%를 우선해 비교했다. 정확히 45.0% 또는 완전히 동일한 수치는 아니다.
- 몸통은 가늘고 짧게, 다리는 매우 짧게 해 튜닉 바로 아래에 신발이 온다. 머리는 어깨보다 넓고, 빈손 양팔과 양다리가 읽힌다.
- [턱 위치 확인 확대본](raw/head-measurement-check.png)의 빨간 선은 최종 y=747이다. 확대본은 최종 PNG의 x=350, y=100부터 700×750 영역을 흰 배경에 표시했다.
- 1차: 기존 v01보다 짧은 체형 확보. 2차: 더듬이 단축·날개 위로 이동. 3차: 머리는 유지하고 턱 아래 체형 높이를 약 10% 줄이도록 요청해 니브 비율에 더 가까워졌다.

## 알파·크기·파일 검수

- 최종: **1536×1536**, PNG RGBA, **1,471,572 bytes**.
- SHA256: `7740B9F690743A276153E1C2AE8DAADAD9F565145F0EB0EC4FE6400660B2EDE7`.
- alpha=0: **1,564,778px**; alpha=255: **4,130px**; 0<alpha<255: **790,388px**.
- 전체 캔버스 가장자리에서 alpha>0인 픽셀 **0개**. 진짜 알파 투명 배경이며 체크무늬를 배경으로 그린 그림이 아니다.
- alpha≥128 실루엣 bbox: **[236, 149, 1438, 1328)**. 더듬이와 네 날개 끝, 신발이 모두 캔버스 안에 있다.
- 원본 도구 출력은 1254×1254였다. 3차 원본을 **종횡비 동일한 1.326968973747 배 확대** 및 평행 이동해 요구된 1536×1536 캔버스/니브 화면 속 크기에 맞췄다. 해부학 비율을 사후 변형하지 않았다. 원본 알파를 유지하고 인물과 떨어진 바깥 16px 여백의 미세 잡픽셀만 비웠다.
- `raw/prepare-final.ps1`, `raw/preparation.json`에 변환 재현 절차/수치가 있으며 `raw/verify-image.ps1`, `raw/validation.json`에 알파 검수와 측정값이 있다.

## 시각 검수와 한계

- 확인: 연보라 피부, 은발, 온전한 뾰족 귀, **더듬이 두 가닥**, 초록 잎 튜닉, **크림 위 날개 2장 + 연보라 아래 날개 2장**. 날개 네 끝이 구별되며 팔꿈치·손보다 위/뒤에 놓였다. 뿌리는 몸통/어깨 뒤로 자연스럽게 가려지고 손·전완과 겹치지 않는다.
- 확인: 앞-왼쪽 3/4뷰, 한 명 전신, 빈손 A자, 큰 무광 단추 눈·작은 코·작은 미소, 부드러운 점토/비닐 장난감 표현. 무기·등짐·개인 장신구·이름·문자는 없다.
- 두 팔은 어깨에서 붙는 정상적인 연결부를 제외하고 몸통 밖으로 분리된다. 튜닉 아래 양다리와 신발 사이에 간격이 있다. 날개가 넓지만 체격 자체는 가늘게 유지했다.
- 알파는 생성 도구의 값을 보존했다. 물체 내부에도 255보다 약간 낮은 알파가 많아 모든 물체 픽셀이 완전 불투명한 것은 아니다. 날개는 시각적으로 불투명한 판 형태이며 투명한 막이나 세밀한 시맥은 없다. 아주 작은 생성 가장자리 색/알파 흔적이 남을 수 있다.
- 머리 비율은 2D 투영·시각 측정이다. 3D 메시·후면 형태·리깅/날개 분리·게임 내 적용을 검증한 결과가 아니며 사용자 승인도 별도로 필요하다.

## 원본 보존

| 파일 | SHA256 | 용도 |
| --- | --- | --- |
| `raw/fairy-common-3q-v02-generated-01.png` | `AA4498ECFEE8151605BB5214BF4717B1511755FD939326FDC94D4B0AFC8ACB81` | 첫 생성 원본 |
| `raw/fairy-common-3q-v02-generated-02.png` | `34C01B1BEF7A03B7E276EA763141300C8B99E8B1E93F62E3F96DD9ABD0ECDF2D` | 더듬이·날개 수정 원본 |
| `raw/fairy-common-3q-v02-generated-03.png` | `E6D6E3967B7E31458C8C692C6DBFDA0F1A0BEF85664ACD9C68A84CFDA339F84C` | 최종 채택 원본 |

## 실제 프롬프트 전문

모든 호출에서 `transparent_background=true`. 참조 입력은 위에 명시한 실제 PNG 경로다. 아래 내용은 전송한 문자열 그대로이며 별도 `raw/prompt-01.txt`~`prompt-03.txt`에도 보존했다.

### 1차 — 생성

```text
Use case: stylized-concept
Asset type: ONE reusable fairy-race guest full-body concept for subsequent 3D modeling, Witch's Lodge.
Input images are REFERENCES, not edit targets:
1. nib-3q-v03.png: PRIMARY and authoritative reference for head/body proportions, framing, front-left three-quarter camera, smooth matte clay/vinyl toy rendering and minimal face.
2. stylized-toy-chibi-ref-01.png: secondary supporting reference for simple chunky toy forms and large color areas only.
3. thistle-3q-b-v01.png: fairy species identity and colors ONLY. DO NOT copy its elongated body, long legs, long braid, eyebrows, belt details, or antenna length.

Generate a new ordinary generic fairy traveler, no named-person identity, no unique jewelry, no props. Medieval-based fantasy, maintaining medieval everyday-life atmosphere with fantasy adaptation allowed. One character only, standing upright in relaxed A-pose, fully visible, front-left three-quarter view 30–45 degrees with face pointing toward viewer-left, match image 1 camera height. Both hands EMPTY and outside torso silhouette; feet and both legs clearly separated.

MOST IMPORTANT: Match Nib image 1 head-to-body ratio. An enormous rounded head including silver hair is approximately 45–47 percent of crown-to-sole height, nearly as tall as torso plus legs. Target on 1536x1536 canvas: crown around y=220–230, chin around y=725–735, soles around y=1330; head about 500–510 px, crown-to-sole body about 1100–1110 px. Width difference expresses fairy slenderness, NEVER height or longer legs. Head wider than shoulders. Very short narrow rounded torso. Extremely short stubby legs, rounded shoes immediately below leaf tunic; almost no exposed shin. Arms short and simple, hands blunt mitten-like masses. Do not make a conventional tall chibi or small-headed figure.

Fairy species: pale lavender skin; two intact pointed ears; silver-white hair built from just a few broad smooth sculpted locks, short compact hair, no long braid. Exactly TWO small curved lavender antennae, compact and only slightly above the crown, not a tall extension of the silhouette. Exactly FOUR wings, two pairs from the upper back: upper pair opaque cream panels; lower pair opaque pale-lavender panels. Simple solid rounded leaf/oval panels, no transparent membranes, no filigree, no veins. Spread the wings upward and backward into clearly visible side silhouettes so all four tips read separately, ABOVE the short arms, with transparent gaps between wings and arms/hands. Wing roots naturally behind the upper torso. Do not let wings merge with hands or forearms. Short green leaf-shaped tunic, minimal green collar, compact brown rounded medieval shoes. No cape or hanging accessories. No weapon, shield, luggage, bag, staff, wand, jewelry, scars, torn ears, or personal symbols.

Face like Nib: two large dark matte button eyes with NO highlights, tiny rounded nose, tiny gentle smile, calm kind expression. No elaborate eyebrows, eyelashes, wrinkles, detailed fingers, or realistic anatomy.

Style: match reference 1 smooth matte clay/vinyl collectible toy, no outlines, soft broad form shading, no fabric grain or surface noise. Only 3–5 broad palette families: lavender skin and lower wings, silver hair, green tunic, cream upper wings, small brown shoes; dark eyes as facial accents. Minimal decoration. Soft neutral studio illumination, no environment.
Output: 1536x1536 square PNG, truly transparent alpha background. Empty transparent margins all around. No ground, pedestal, cast ground shadow, text, labels, collage, comparison, watermark, borders, checkerboard artwork or background color. Render only this ONE fairy.
```

### 2차 — 더듬이·날개 수정

```text
Use case: precise-object-edit.
Edit target: image 1 fairy-common-3q-v02-generated-01.png. Supporting reference: image 2 nib-3q-v03.png, authoritative for body proportions and framing.
Keep the fairy's enormous round silver-haired head, lavender face, completely matte dark button eyes without highlights, simple tiny nose and calm mouth, pointed ears, green leaf tunic, very short legs, chunky brown shoes, smooth matte clay toy finish, colors, empty hands and front-left 3/4 camera. Keep its head height at approximately 45–47% of crown-to-sole body height, matching Nib. Do NOT elongate its torso or legs.
Make these targeted corrections only:
1. Shorten the TWO lavender antennae dramatically: compact curved short stalks above the silver crown, extending upward only about 40px on a 1536 square, not long tall insect feelers. Keep two clearly separate tips.
2. Lift and spread ALL FOUR opaque wing panels upward and backward, upper two cream and lower two pale lavender. Keep four distinct readable tips. The lavender pair must sit ABOVE and BEHIND the arms, ending above elbow height, with visible transparent gaps to both forearms and both mitten hands; no wing edges merged with arms. Wing roots may be naturally occluded by the torso. Do not attach wings to head. Preserve calm ordinary fairy race identity with no personal accessories.
Framing: single full character, not a comparison. On a 1536x1536 square, hair crown at about y=220 and shoes bottom about y=1330; head about 500px, crown-to-sole about 1110px. Give fairy a narrow torso by WIDTH, not by height. All antennae and wing tips inside canvas. Upright A-pose, both empty hands outside torso, two separate stubby legs.
Medieval-based fantasy, medieval everyday-life atmosphere with fantasy adaptation allowed. Truly transparent alpha PNG; no environment, cast ground shadow, text, background checkerboard, outlines, pedestal or particles. Clean smooth antialiased edges, no floating stray pixels.
```

### 3차 — 체형 비율 수정

```text
Use case: precise-object-edit.
Image 1 is the fairy edit target. Image 2 is Nib, the authoritative head/body ratio reference.
Make ONE proportional correction to image 1: preserve the head INCLUDING silver hair at exactly its current size and shape, and shorten the complete region BELOW THE CHIN (torso, arms, legs, shoes) by about TEN PERCENT in vertical height. This must make the silver-hair crown-to-chin head approximately 46% of crown-to-sole height, matching Nib image 2 (about 46.6%). In image 1 it is only about 44%. Do not count antennae in this anatomical measurement. Large head nearly as tall as the entire rest of body, stubby feet immediately under tunic. Keep the fairy slender by WIDTH. Do not shrink the head.
Keep all other design and rendering characteristics: two compact lavender antennae, short silver-white smooth sculpted hair, pale lavender skin, intact pointed ears, no detailed eyebrows, two large dark matte button eyes without highlights, tiny nose and gentle smile. Keep medieval green leaf tunic and small brown shoes, empty blunt mitten hands, relaxed upright A-pose, two visibly separated very short legs. FOUR opaque wings, upper pair cream and lower pair lavender, raised behind shoulders; four distinct tips, clear transparent gaps above forearms and hands. Same front-left 3/4 camera, same soft neutral lighting, same smooth matte clay/vinyl toy rendering and minimal decoration. No personal accessories or props.
Medieval-based fantasy, medieval everyday-life atmosphere with fantasy adaptation allowed.
One full-body fairy centered alone on a truly transparent 1536x1536 square PNG. Target crown y=220 and soles y=1330, head about 515px and crown-to-sole height about1110px, antennae only slightly higher. All extremities inside image. No text, no cast ground shadow, no outline, no background color or painted checkerboard. Clean alpha edges, no loose colored pixels.
```

