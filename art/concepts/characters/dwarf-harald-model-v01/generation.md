# 하랄 드워프 3/4뷰 모델링 원화 v01 — 생성·검수 기록

- 제작일: 2026-10-20
- 요청: `docs/handoff/codex-dwarf-harald-model-3q-v01.md`
- 공통 기준: `docs/handoff/codex-race-models-3q-common-v01.md`
- 방식: 내장 `image_gen` 사용. CLI/API 대체 경로를 사용하지 않았다.
- 프로젝트의 모든 저장·수정은 `art/concepts/characters/dwarf-harald-model-v01/` 안에 한정했다. 다른 종족·기존 참조·게임·문서는 수정하지 않았고 커밋하지 않았다. 생성 도구가 자체 캐시에 보관한 반환 원본을 이 폴더의 `raw/`에 그대로 복사했다.
- 중세 기반 판타지 세계관을 반영했다. 카드 원화의 먹선·세부 묘사 대신 승인된 니브·마녀의 매끈한 무광 점토 장난감 조형을 기준으로 삼았다.

## 납품

| 파일 | 구성 | 크기 | 바이트 |
| --- | --- | --- | --- |
| [harald-3q-a-v01.png](harald-3q-a-v01.png) | 초상 충실형: 회색으로 단순화한 사슬갑옷, 가죽 앞치마·팔토시, 황동 버클, 등에 멘 철테 나무 방패 | 1536×1536 RGBA PNG | 1,731,232 |
| [harald-3q-b-v01.png](harald-3q-b-v01.png) | 공용 겸용형: 평범한 두꺼운 회색 모직 튜닉, 가죽 앞치마·벨트·굵은 장화. 방패·갑옷·팔토시 제거 | 1536×1536 RGBA PNG | 1,579,853 |

A와 B는 같은 대머리 정수리, 회색 옆·뒤 머리, 두 갈래로 땋은 풍성한 회색 수염과 은색 고리, 모은 굵은 눈썹, 낮고 넓은 체형을 공유한다.

## 실제 이미지 입력

아래 네 파일을 모두 `view_image`로 실제로 열어 확인하고, 두 생성 호출 모두 `referenced_image_paths`에 전달했다. 경로는 프로젝트 루트 기준이다. B에는 A 생성 원본도 다섯 번째 이미지 입력으로 전달해 얼굴·체형·포즈를 유지했다.

| 순번 | 경로 | 역할 | SHA256 |
| --- | --- | --- | --- |
| 1 | `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png` | 1순위 화풍·비례·카메라 | `d33657a5a0b50b9b8bdd4f6384a3014b49aa0610111dfe8015480d038ff71f1b` |
| 2 | `art/concepts/characters/witch-north-model-v01/witch-3q-a-v01.png` | 2순위 동일 게임 화풍 | `105efb88d1a6b0449523c1c9b8bc0ba466b41e3b2c3946f77c9424caddeb3682` |
| 3 | `art/references/characters/stylized-toy-chibi-ref-01.png` | 조형 언어만 참고, 인물·의상 복제 금지 | `c26f3e21a10e119047df10986bf4d27720c2e6b7a266aca142ba2fcf78bf8687` |
| 4 | `godot/assets/portraits/guest_harald_cutout.png` | 하랄의 얼굴 특징·색 배치·의상·방패 정체성 | `13c449ccb974855f47284296ef99c470143a20dd08732f80e5ecd89b05e70da2` |
| B의 5 | `art/concepts/characters/dwarf-harald-model-v01/raw/harald-3q-a-generated-v01.png` | A와 동일한 인물·포즈 유지 | `bfb8652dd9b76fd80aadd0d0591fe964fdee9549d6c73c075ee6130cf8204052` |

## 실제 생성 호출과 프롬프트 전문

두 호출의 `transparent_background`는 `true`다. `num_last_images_to_include`는 사용하지 않았다. 첫 호출은 위 1~4, 두 번째 호출은 1~5 순서의 절대경로를 `referenced_image_paths`에 전달했다. 추가 생성이나 수정 생성 호출은 없다.

### A — 실제 전달한 prompt

```text
Use case: stylized-concept
Asset type: single character 3D-modeling concept art for Witch's Lodge, variant A, portrait-faithful Harald.
Create one full-body elderly male DWARF in the exact smooth matte clay toy style of the supplied Nib (image 1, PRIMARY style/proportion/camera reference) and witch (image 2, secondary same-game reference). Image 3 is only a toy sculptural-language reference: do not copy its characters or costumes. Image 4 is Harald's identity reference ONLY: preserve bald crown, gray side/back hair, enormous gray beard split into TWO distinct chunky braided locks with plain silver bands, cautious stubborn thick eyebrows, rusty brown leather apron and belt, gray armor and round iron-rimmed wooden shield. DISCARD the portrait's linework, texture, realism, wrinkles, individual hairs, chain links, ornament, rivets and scratches.
World: medieval-based fantasy, preserving medieval everyday atmosphere while permitting ordinary fantasy adaptation. Clothing represents wool/leather/wood/iron, never modern tailoring or plastic accessories. The render medium itself is matte clay, matching Nib.
Proportions: approximately TWO heads tall; huge round bald head, very low and broad stocky torso and shoulders substantially WIDER than Nib, short thick separated legs and broad boots. Small round nose, TWO dark plain button eyes without any highlights, tiny downturned mouth partly visible above beard, thick simple gray brows drawn together with quiet wary stubbornness. Gray hair forms smooth simple side/back masses; beard is one large sculpted mass covering lower half of face and chest ending in TWO visibly distinct braids, each only 3 large rounded interlocking lobes and one PLAIN silver band. No strand engraving or realistic braiding complexity.
Variant A clothing: a smooth gray thick shirt-like mass representing simplified chain armor, WITHOUT chain loops, scale texture or armor plates; rusty brown leather apron ending well above the knees; very wide brown belt and ONE plain muted brass rectangular buckle; smooth brown leather forearm bracers; dark brown short trousers and chunky brown boots. A round wooden shield with plain iron rim is strapped FLAT ON HIS BACK, visible projecting behind the far shoulder as a clearly separate removable part. Only broad smooth wooden planes, no wood grain or tiny rivets. NO other weapons/tools/lantern/backpack/accessories.
Pose/composition: match image 1's front-left three-quarter view, face pointing slightly toward image-left, about 30–45 degrees with the same mildly elevated camera height, show top of head and boot tops. Stand upright, feet separated. BOTH arms angle downward and OUT away from torso in a clear modeling A-pose, with visible negative-space gaps beneath both arms. BOTH hands EMPTY and relaxed, simple mitten fingers, do not hold shield or touch body. Show TWO entire separate short thick legs below short apron, with a clear gap through to background between legs and boots. All silhouette inside frame, broad generous transparent margins on every side, single character and single view.
Style: match Nib's clean rounded toy geometry and low-detail large forms, 3–5 main color families, smooth matte surfaces, soft studio lighting and soft occlusion only within character; no outlines, ink, painterly marks, fur/cloth grain, surface noise, metallic glare or eye glints. No scene, base, floor, ground shadow, diagram, text, labels or watermark.
Output: square 1536 x 1536 PNG with genuine transparent alpha background. Character opaque alpha 255, outside alpha 0, only thin 1–2 pixel antialias edge. No checkerboard or colored backdrop.
```

### B — 실제 전달한 prompt

```text
Use case: stylized-concept
Asset type: single-character 3D modeling concept art, Witch's Lodge Harald variant B, reusable ordinary dwarf.
Input images: image 1 is approved Nib PRIMARY style/proportion/camera reference; image 2 approved witch secondary same-game style; image 3 toy/chibi sculptural language only (no costume/character copying); image 4 detailed Harald portrait identity ONLY, never copy its linework/realism/textures; image 5 is just-generated Harald A, the exact SAME character whose identity, head, beard, silhouette, camera and pose must be preserved.
Make variant B of image 5 by simplifying ONLY his clothing and removing military equipment. Preserve the exact elderly dwarf identity: bald crown with smooth gray side/back hair, huge gray beard on lower half of face and chest with TWO separate chunky braided locks, 3 big rounded interlocking lobes per braid and one plain silver band on each. Cautious stubborn thick gray brows, two plain dark button eyes with NO highlights, tiny nose and small mouth. About two heads tall, short and very broad stocky dwarf body, wide shoulders, thick short visibly separate legs, chunky boots. Match A's three-quarter angle and head/body geometry.
B outfit: thick PLAIN muted warm-gray wool tunic, short rusty brown leather apron ending well ABOVE both knees, wide brown leather belt with one plain muted brass rectangular buckle, dark brown short trousers, very chunky brown boots. Simple broad smooth wool sleeves with no pattern, shirt and apron made as large clean masses. Bare empty hands. REMOVE shield entirely, no back straps, no armor, no chain mail, no leather bracers, no weapons or tools, no backpack or lantern. The tunic is visibly soft everyday clothing, plain enough to recolor as a brewer, smith, gatherer or traveler. Keep beard and dwarf width especially recognizable.
World: medieval-based fantasy, preserving medieval everyday atmosphere with ordinary fantasy adaptation. Wool, leather and plain metal construction; no modern tailoring, modern materials, plastic accessories or ornamental jewelry beyond two beard bands.
Pose/framing: preserve A's upright standing modeling A-pose. BOTH arms down and OUTWARD, away from torso with visible background gaps beneath them; both hands EMPTY with simple mitten fingers. TWO short thick legs and separate boots fully visible beneath short apron, visible gap between legs; no long robe. Front-left 3/4 view, face toward image-left at 30–45 degrees, same mildly elevated camera as Nib with bald crown and boot tops visible. One full body, one character, one direction. Center in square with ample transparent empty margin on ALL four sides.
Style: exact same smooth matte clay toy rendering as Nib and witch and A; 3–5 big color families, large rounded forms, minimal detail, soft lighting. No outlines, no ink, no painterly/cloth/hair/skin texture, no wrinkles, no engraved hairs or small stitches, no metal glare, no shiny eyes. No scenery, floor, ground shadow, stand, text, labels or watermark.
Output: square 1536 x 1536 PNG with genuine transparent alpha; body opaque alpha 255, empty outside alpha 0, only 1–2px antialias silhouette edge. No checkerboard backdrop.
```

## 원본 보존 및 납품본 처리

- [A 생성 원본](raw/harald-3q-a-generated-v01.png), [B 생성 원본](raw/harald-3q-b-generated-v01.png): 반환 PNG를 내용 변경 없이 복사했다. 둘 다 1254×1254다.
- 생성 반환 위치 A: `C:/Users/Loadcomplete/.codex/generated_images/01a158a2-d7f1-76d3-9415-1b5e98d2519d/exec-132f97ca-d789-4c9b-b652-150605dd4e83.png`
- 생성 반환 위치 B: `C:/Users/Loadcomplete/.codex/generated_images/01a158a2-d7f1-76d3-9415-1b5e98d2519d/exec-048cdf70-5f61-4fd7-b90d-9dca8762b4c7.png`
- 생성 프롬프트는 1536×1536을 요청했지만 실제 반환은 1254×1254였다. Windows System.Drawing의 고품질 bicubic 보간으로 전체 정사각형을 1536×1536으로 균등 확대했다. 크롭·포즈·색상·구성 변경은 하지 않았다.
- 원본 알파는 바깥은 0이지만 본체 대부분이 1~254였다. A는 알파 0: 963,534 / 255: 1,078 / 1~254: 607,904, B는 0: 998,384 / 255: 1,268 / 1~254: 572,864였다.
- 확대 후 알파 128을 기준으로 본체 실루엣을 정하고 최대 8방향 연결 성분만 유지한다. 경계 양쪽의 1픽셀 이웃에서만 기존 알파를 제한 보존하고 본체 내부는 255, 외부는 0으로 정리한다. 따라서 반투명 경계 띠는 대략 1~2px다. 알파 0인 픽셀의 RGB도 0으로 정리했다. 형상을 그려 넣거나 새 배경을 합성하지 않았다.
- 재현용 처리 스크립트: [raw/finalize.ps1](raw/finalize.ps1)
- 수치 검수: [raw/validation.json](raw/validation.json)

## 알파·해상도·여백 검수

| 항목 | A | B |
| --- | --- | --- |
| 해상도 | 1536×1536 | 1536×1536 |
| 알파 0 픽셀 | 1,462,509 | 1,519,506 |
| 알파 255 픽셀 | 883,785 | 826,108 |
| 알파 1~254 픽셀 | 13,002 | 13,682 |
| 경계 띠 바깥 본체 내부의 비불투명 픽셀 | 0 | 0 |
| 알파가 있는 영역 bbox, 양 끝 포함 | (200,136)–(1358,1415) | (196,132)–(1355,1418) |
| 투명 여백: 좌/상/우/하 px | 200 / 136 / 177 / 120 | 196 / 132 / 180 / 117 |

원본과 최종본을 실제 이미지로 열어 시각 검수했다. 최종 PNG에는 바닥·접지 그림자·배경판·체커보드가 없다.

## 시각 검수

| 기준 | A·B 결과 |
| --- | --- |
| 니브 v03·마녀 A와 화풍 일치 | 큰 둥근 덩어리, 약 2등신의 큰 머리, 무광 점토 마감, 먹선 없는 부드러운 명암. 피부·회색·녹슨 갈색·진갈색과 소량 황동 계열로 정리했다. 카드 초상의 사슬 고리·리벳·털 결·흠집을 옮기지 않았다. |
| 하랄 정체성 | 벗어진 정수리, 옆·뒤 회색 머리, 모은 굵은 눈썹, 하안면과 가슴을 덮는 큰 회색 수염, 명확한 두 갈래 땋은 수염과 단순한 은색 고리 두 개. 작은 코와 하이라이트 없는 단추 눈. 입은 콧수염 아래에 작게 드러난다. |
| 드워프 체형 | 큰 머리, 넓은 어깨·몸통, 낮고 단단한 몸, 짧고 굵은 두 다리와 장화. 니브보다 넓은 실루엣으로 드워프를 표현했다. |
| 3/4·전신·여백 | 화면 왼쪽을 향한 앞-왼쪽 3/4, 정수리와 장화 윗면이 보이는 완만한 내려다봄. 한 인물·한 방향·전신이 사방 여백 안에 들어간다. |
| A자·빈손 | 양팔을 아래와 바깥으로 벌렸고 몸통 아래쪽과 손 사이에 투명 틈이 있다. 두 손 모두 비어 있다. A의 방패는 손이 아닌 등에 붙은 별도 덩어리다. |
| 두 다리 분리 | 짧은 앞치마 아래에 두 다리·장화가 드러나고 두 다리 사이에 투명 틈이 있다. 긴 옷자락이 걸음용 다리를 덮지 않는다. |
| A 초상 충실형 | 회색 매끈한 의복 덩어리가 사슬갑옷을 대신하고 가죽 앞치마·팔토시·넓은 벨트·황동 버클을 유지했다. 둥근 철테 나무 방패가 등에 메여 어깨 바깥으로 읽힌다. |
| B 공용 겸용형 | A와 같은 얼굴·수염·체형·포즈를 유지했다. 방패·팔토시·갑옷을 제거하고 두꺼운 평상 튜닉과 앞치마·벨트·장화만 남겨 색 변경으로 다른 드워프 직업에 재활용하기 쉽게 했다. 갈색 어깨 끈은 가죽 앞치마의 끈이다. |
| 시대 기준 | 중세 판타지의 모직·가죽·나무·철·황동 구성. 현대 소재·현대 재봉·현대 장신구를 추가하지 않았다. |

## SHA256

| 파일 | SHA256 |
| --- | --- |
| `harald-3q-a-v01.png` | `56bf9e34bcffa7da7a57db8d0a9cecb24cf64693667a8be56ac9cf8cd3981f06` |
| `harald-3q-b-v01.png` | `0b6930c0e61482358479092a2bfb3265719e220e4a84334e51629a061c8f017a` |
| `raw/harald-3q-a-generated-v01.png` | `bfb8652dd9b76fd80aadd0d0591fe964fdee9549d6c73c075ee6130cf8204052` |
| `raw/harald-3q-b-generated-v01.png` | `c40221dd70925567a7af07909eb1c23893cd7695365d0227f7f1904b4fd87dc6` |

## 한계

- 단일 방향의 모델링용 2D 시안이다. 후면·측면 투영도, 실제 3D 메시, 파츠 분리, 리깅·걷기 검증은 포함하지 않는다.
- 카메라 각도와 2등신 비례는 이미지 기준의 근사치이며 수치 카메라나 정확한 인체 치수는 확정하지 않는다.
- A 방패의 전면 일부는 몸 뒤에 가려진다. 별도 파츠 제작 시 가려진 후면 구조와 등 부착 방식을 정해야 한다.
- 모직과 단순화한 갑옷은 의도적으로 같은 매끈한 회색 큰 덩어리다. A/B 차이는 방패·팔토시 유무와 의복의 구성으로 읽힌다.
- 생성 이미지에 매우 미세한 표면 명암 변화는 남아 있다. 실제 3D 재질은 승인된 니브처럼 매끈한 무광으로 구성하면 된다.
- 1536 납품본은 반환 원본의 확대본이며 새로운 디테일이 추가된 네이티브 1536 생성본은 아니다.

