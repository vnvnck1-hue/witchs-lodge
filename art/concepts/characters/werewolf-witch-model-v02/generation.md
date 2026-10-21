# 보름달 늑대인간 B — 회색 늑대 v02 제작 기록

- 제작일: 2026-10-21 (Asia/Seoul)
- 요청서: `docs/handoff/codex-werewolf-witch-model-3q-v02.md`를 UTF-8로 읽고 수행.
- 도구: 내장 `image_gen` 편집 2회. 두 호출 모두 `transparent_background=true`. CLI/API 대체 경로 없음.
- 생성 입력은 아래 v01 B 한 장만 `referenced_image_paths`로 실제 전달했다. 비교용 마녀·수인은 새 늑대인간의 형태에 영향을 주는 생성 입력으로 전달하지 않았다.
- 모든 프로젝트 납품 파일은 이 v02 폴더 안에만 작성. `godot/**`, `docs/**`, 기존 원화 변경·게임 적용·실행파일 재출력·커밋 없음. 내장 도구가 자동 저장하는 `$CODEX_HOME/generated_images/` 원본은 그대로 두고 프로젝트의 `raw/`에 바이트 그대로 복사했다.

## 입력 및 열람

실제 편집 대상: `art/concepts/characters/werewolf-witch-model-v01/werewolf-3q-b-v01.png`.
`view_image`로 직접 열어 본 후, 두 호출 모두 이 원본을 실제 이미지 입력으로 사용했다.
입력 SHA256: `F6AA94483E790A4374C41DC3BE3977A9A6AEAE82DE63F7C936BA8A1E2FEAFEBC` (v01 제작 기록과 일치).

비교판용으로 실제 열어 본 기존 원화:

- `art/concepts/characters/witch-north-model-v01/witch-3q-a-v01.png`
- `art/concepts/characters/beastfolk-common-model-v02/beastfolk-common-3q-v02.png`

시대·재질 기준은 `docs/art-direction.md`, `docs/world-races-card-formats-v01.md`의 중세 기반 판타지를 반영했다. 카드 제작 작업에 해당하지 않는다.

## 실제 프롬프트 전문

### 호출 1 — 회색 털 편집, 여백 부족으로 미채택

입력: v01 B 원본. 생성 원본 보존: `raw/werewolf-b-gray-initial.png`.
털색과 주요 조형은 적절했으나 인물이 화면을 크게 채우고 꼬리 왼쪽 여백이 부족하여 최종본으로 사용하지 않았다.

```text
Use case: precise-object-edit.
Asset type: Witch's Lodge medieval fantasy full-body 3D character concept, gray-wolf recolor of approved werewolf B.
Input image 1 is the ACTUAL EDIT TARGET: werewolf-3q-b-v01.png. Edit this exact picture; preserve its geometry and composition as closely as possible. This is a color-only revision.
Change ONLY the brown fur to cool gray-wolf fur: body, arms, legs, tail, head, ears' outer fur, and ALL mane/hair clumps including the large reddish-brown wavy forelock and flowing side/back mane must become cool medium-to-dark slate gray with a very subtle blue cast. Back, outer arms, and back mane slightly darker; distinguish the sculpted top mane with a slightly different gray value. No reddish/brown hair clumps remaining.
Preserve the pale cream to light-gray muzzle, chest, belly, tail tip, toes, and cream inner ears. Preserve the lavender eyes, short fangs, torn purple cloak over one shoulder, brown leather belt, gold buckle, and cream cloth hanging from belt. Keep nose and claws dark. Preserve their materials, colors, sizes, and placement.
INVARIANTS: same exact silhouette, muscular stocky bulk, crouched stance, foot and hand positions, tail shape and placement, facial expression, eye shape, forelock and mane sculpted shapes, body proportions, 3/4 camera, framing, margins, soft studio lighting, matte clay finish and simplified sculpted fur. Do not redesign or add anything. Medieval-based fantasy, retaining medieval everyday atmosphere while allowing fantasy stylization; preserve existing medieval leather, cloth and buckle.
Output: one isolated character on a genuinely TRANSPARENT alpha background, exactly 1536 x 1536 pixels. Solid subject alpha 255, outside alpha 0; only 1-2 pixel antialiased contour. No backdrop, no floor, no cast shadow, no checkerboard painted into pixels, no pedestal, no text, no watermark. Keep the full character including tail, ear tips and feet within canvas.
```

### 호출 2 — 원본 B로 다시 편집, 여백 유지 강조, 채택

입력: 첫 결과가 아닌 v01 B 원본. 생성 원본 보존: `raw/werewolf-b-gray-selected.png`.

```text
Use case: precise-object-edit.
Asset type: Witch's Lodge medieval fantasy full-body 3D character concept, gray-wolf recolor of approved werewolf B.
Input image 1 is the ACTUAL EDIT TARGET: werewolf-3q-b-v01.png. Edit this exact picture; preserve its geometry and composition as closely as possible. This is a color-only revision.
Change ONLY the brown fur to cool gray-wolf fur: body, arms, legs, tail, head, ears' outer fur, and ALL mane/hair clumps including the large reddish-brown wavy forelock and flowing side/back mane must become cool medium-to-dark slate gray with a very subtle blue cast. Back, outer arms, and back mane slightly darker; distinguish the sculpted top mane with a slightly different gray value. No reddish/brown hair clumps remaining.
Preserve the pale cream to light-gray muzzle, chest, belly, tail tip, toes, and cream inner ears. Preserve the lavender eyes, short fangs, torn purple cloak over one shoulder, brown leather belt, gold buckle, and cream cloth hanging from belt. Keep nose and claws dark. Preserve their materials, colors, sizes, and placement.
INVARIANTS: same exact silhouette, muscular stocky bulk, crouched stance, foot and hand positions, tail shape and placement, facial expression, eye shape, forelock and mane sculpted shapes, body proportions, 3/4 camera, framing, margins, soft studio lighting, matte clay finish and simplified sculpted fur. Do not redesign or add anything. Medieval-based fantasy, retaining medieval everyday atmosphere while allowing fantasy stylization; preserve existing medieval leather, cloth and buckle.
Output: one isolated character on a genuinely TRANSPARENT alpha background, exactly 1536 x 1536 pixels. Solid subject alpha 255, outside alpha 0; only 1-2 pixel antialiased contour. No backdrop, no floor, no cast shadow, no checkerboard painted into pixels, no pedestal, no text, no watermark. Keep the full character including tail, ear tips and feet within canvas.
CRITICAL FRAMING: preserve the input's ENTIRE square canvas and its generous empty transparent border. Do NOT zoom, recrop or enlarge the subject. All fur and all tail edges must be fully intact with empty space outside them. The ear tip starts ~11% below the canvas top, lowest foot ends ~89% of canvas height, tail left tip starts ~11% from the left edge, right hand ends ~89% of width. Character bounding box must be ~78% of canvas width and height, centered. Match the approved input canvas placement. Preserve the original sculpting and relative proportions, change fur pigment only.
```

## 납품 파일 및 기술 정리

- `werewolf-3q-b-v02.png`: **1536×1536 PNG RGBA**, 진짜 투명 알파.
- `werewolf-v02-contact.png`: **3040×1030 불투명 PNG**. 왼쪽부터 v01 B · v02 B · 마녀 A · 수인 공용. 전원 원본 픽셀 기준 **55% 동일 배율**, 발 기준선 정렬. 인물별 키 정규화 없음. 기존 이미지 알파는 비교판에서만 원본 그대로 합성했다.
- `raw/werewolf-b-gray-initial.png`, `raw/werewolf-b-gray-selected.png`: 내장 생성 도구 결과 **1254×1254**를 수정 없이 보존.
- `raw/prepare-deliverables.ps1`: PowerShell + System.Drawing 기술 정리·비교판 생성 스크립트. 기존 v01 스크립트의 복사본을 이 폴더에서만 조정했다. 가장 큰 연결 실루엣을 남기고 분리된 미세 알파 잡점을 제거한다. 본체 내부 알파를 255로 정리하고 외곽 2px 범위 생성 알파를 보존한다. 부분 투명 경계 RGB를 가까운 본체 색으로 정리한다. 종횡비를 유지하여 실루엣 높이 목표 1200px, 위 여백 168px로 1536 정사각 투명 캔버스에 배치했다. 색보정·수동 조형 수정은 하지 않았다. 그림 편집 자체는 내장 image_gen으로 수행했다.
- `raw/alpha-report.txt`: 실제 알파·치수 검사 결과.
- `raw/verify-silhouette.ps1`, `raw/silhouette-report.txt`: 원본 B와 최종본의 같은 좌표에서 알파≥128 마스크 교집합/합집합 비율 검수.

## 알파·크기 검수

최종본과 비교판을 `view_image`로 다시 열어 확인했다.

| 항목 | v02 최종본 |
| --- | --- |
| 캔버스 | 1536×1536 |
| alpha>0 경계 (우측·하단 exclusive) | [173,168,1362,1367] |
| 실루엣 높이 | 1199px |
| alpha=0 | 1,551,146px |
| alpha=255 | 776,564px |
| alpha=1~254 | 31,586px |
| 외곽 2px 범위를 벗어난 부분 투명 픽셀 | 0 |
| 네 모서리 알파 | 0 / 0 / 0 / 0 |

알파값은 전체 2,359,296픽셀과 합계가 일치한다. 본체 안쪽은 불투명하며 외부는 투명이다. 부분 투명은 실루엣 경계의 2px 검사 범위 안에만 있다. 체크무늬·바닥·그림자를 이미지에 그려 넣지 않았다. 비교용 기존 수인의 알파 상태는 최종본의 검수와 별개이며, 원본에 손대지 않았다.

## v01 B 대비 형태·색 검수 및 한계

- 동일한 커다란 늑대 머리, 넓은 어깨, 굵은 전완, 구부린 두 다리, 빈 손, 왼쪽으로 뻗은 꼬리, 웨이브 앞머리·갈기 덩어리와 3/4 카메라를 유지했다.
- 머리·귀 바깥·갈기·몸·팔·다리·꼬리의 갈색 털을 차가운 회색~슬레이트 회색으로 바꿨다. 정수리와 뒤쪽 갈기는 명도 차로 구분되고, 뒤쪽과 바깥쪽 털은 더 어둡다.
- 연보라 눈, 크림 주둥이·가슴·배·귀 안·꼬리 끝·발가락, 작은 송곳니, 한쪽 어깨의 찢긴 보라 망토, 갈색 벨트·금색 버클·크림 천과 점토 무광 마감을 유지했다.
- 동일 좌표의 알파≥128 실루엣 IoU는 **0.987034 (98.70%)**. 교집합 786,578px / 합집합 796,911px, 마스크 불일치 10,333px. 원본 alpha>0 높이는 1200px, 최종본은 1199px이며 테두리 정리·리샘플링에 따른 약 1px 차이가 있다.
- 비교판에서 수인 공용보다 훨씬 넓은 어깨·큰 팔·굵은 갈기, 낮고 힘 있는 자세, 좁은 연보라 눈이 분명해 같은 회색 계열에서도 구분된다. 수인은 둥근 검은 눈과 옷을 입은 작은 몸을 가진다.
- **한계:** 생성형 편집이므로 픽셀 단위의 완전한 색상 치환은 아니다. 경계·명암·재질과 일부 미세 조형에 재합성 차이가 있다. IoU는 외곽 마스크의 일치도이며 내부 조형·3D 구조의 동일성을 보증하지 않는다. 형태·자세·비례는 시각적으로 최대한 유지했으며, 모델링/게임 적용 승인이나 3D 치수 도면이 아니다.

## SHA256

| 파일 | SHA256 |
| --- | --- |
| werewolf-3q-b-v02.png | `6E9B026F2B60291A12665E334EA57CF2610D4881E21D108FC6AFC98905A909C3` |
| werewolf-v02-contact.png | `82A3A97437DEFEE0F056F03C8E1356097554EDA6C34CF14443BD3117EADD405A` |
| raw/werewolf-b-gray-initial.png | `A14DBF42C49A8B610CCD18907A3D5F99A5818D6DDB6B7C002CBFC7D7A529C159` |
| raw/werewolf-b-gray-selected.png | `FB9B1877C25689B0D27C1E07948705651BB4660D1EAA2B914195F5AB5EEB30D3` |
| raw/prepare-deliverables.ps1 | `D206106FAB9FAD486CDC773091AFA673C1D0BF62568C6B6D1F22EE5C1B412E7C` |
| raw/alpha-report.txt | `81201B45342CB457C64E6610E468A2EDE2767BBF711E262F6F0CC6A9601FFD83` |
| raw/verify-silhouette.ps1 | `76CD85927F7D659650217DC3FE0D73A5DB97E8E781D1B12E161CC8F1580E3608` |
| raw/silhouette-report.txt | `5321EFF25A0B11933398D275B0E1C67E86E0398A67532A04BA2CBF7024709A9F` |

