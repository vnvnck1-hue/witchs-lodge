# 인간 종족 공용 손님 — 모델링용 3/4 원화 v02

- 제작일: 2026-10-20 (Asia/Seoul).
- 요청서: `docs/handoff/codex-race-common-models-3q-v02.md`의 **human 행만** 수행.
- 최종 납품: [human-common-3q-v02.png](human-common-3q-v02.png), **1536×1536 RGBA PNG**, 1,000,744 bytes.
- 내장 `image_gen.imagegen` 2회 사용: 최초 제작 1회 + 머리 비율을 니브에 더 가깝게 맞추는 수정 1회. 두 호출 모두 `transparent_background=true`. CLI/API 대체 생성 없음.
- 인간 종족 누구에게나 사용할 평범한 여행자. 인물 이름·수염·흉터·개인 장신구 없이 짧은 갈색 머리, 크림 모피 깃과 짧은 초록 망토, 갈색 가죽 조끼·귀리색 셔츠·벨트·장화.
- 이 작업에서 작성·수정한 프로젝트 파일은 모두 이 human 출력 폴더 내부에 있다. 다른 종족 출력 폴더, 기존 입력 원화, `godot/**`, `docs/**`, 실행파일은 수정하지 않았다. 커밋 명령을 실행하지 않았다. 게임 적용은 범위 밖이다.

## 실제 이미지 입력

다음 세 PNG를 `view_image`로 직접 열어 확인한 뒤, 최초 생성 호출의 `referenced_image_paths`에 아래 순서로 실제 첨부했다.

1. `art/concepts/characters/goblin-nib-model-v03/nib-3q-v03.png`: **등신·화풍·카메라·표현·화면 속 크기의 최우선 기준**.
2. `art/references/characters/stylized-toy-chibi-ref-01.png`: 간결한 장난감 덩어리감 보조.
3. `art/concepts/characters/human-bram-model-v01/bram-3q-b-v01.png`: 인간 의상과 색상만 참고. 기존 등신·수염·회색 옆머리·눈썹·인물성을 가져오지 않도록 지정.

두 번째 호출은 첫 완성 시도의 `human-common-3q-v02.png`와 니브 v03 두 장을 실제 첨부했다. 첫 시도는 당시 머리 비율 약 48.3%로 보여 한 차례 비율 수정을 요청했다. 이 편집 입력은 현재 [raw/human-common-3q-v02-attempt01.png](raw/human-common-3q-v02-attempt01.png)에 보존되어 있다.

중세 기반 판타지라는 공통 세계관과 아트 가이드를 읽었으며, 두 실제 프롬프트에도 중세의 생활감과 분위기를 유지하면서 판타지적 각색을 허용한다고 명시했다.

## 머리 비율 — 니브와 나란히 직접 비교

[동일 배율 비교 PNG](raw/nib-human-comparison.png)를 실제로 열어 확인했다. 두 이미지를 같은 1536 캔버스, 같은 표시 배율로 나란히 놓았다. 귀의 가로 폭은 머리 높이 계산에서 제외하며 **정수리 머리카락 꼭대기부터 얼굴 턱 아래까지**를 머리 높이로 측정했다. 목·모피 깃은 제외한다.

전체 높이의 기준은 알파 ≥192인 실루엣 경계다. 좌표는 0부터 시작하며 높이는 양 끝 픽셀을 포함한다. 턱 위치는 시각적으로 지정한 랜드마크로 약 ±5px의 오차가 있다.

| 항목 | 니브 v03 | human v02 |
| --- | ---: | ---: |
| 캔버스 | 1536×1536 | 1536×1536 |
| 정수리 Y | 218 | 218 |
| 발바닥 Y | 1329 | 1329 |
| 전체 높이 | **1112px** | **1112px** |
| 턱 아래 Y | 733 | 740 |
| 머리 높이 | **516px** | **523px** |
| 머리 / 전체 키 | **46.40%** | **47.03%** |
| 전체 키 / 머리 높이 | 약 2.16등신 | 약 2.13등신 |

최종 차이는 머리 높이 **7px**, 비율 **약 0.63%p**다. 요청의 “약 45%”는 실제 니브를 우선하여 대조했으며, 실제 결과는 위 수치다. 정확히 45.00%이거나 니브와 수학적으로 동일하다고 주장하지 않는다. ±5px의 턱 측정 오차는 비율 약 ±0.45%p에 해당한다.

큰 머리와 짧고 둥근 몸통, 몸통 바로 아래의 짧은 다리와 장화가 나란히 보았을 때 가까운 등신으로 읽힌다. 귀를 제외한 인간 머리 너비도 망토 어깨 너비 이상이다. 몸 부위를 잘라 늘이거나 줄이는 후처리는 하지 않았다.

수치와 재현 스크립트: [proportion-report.json](raw/proportion-report.json), [verify-proportions.ps1](raw/verify-proportions.ps1).

## 생성 원본과 1536 캔버스 마감

- 최종 선택된 생성 원본: [raw/human-common-3q-v02.png](raw/human-common-3q-v02.png), **1254×1254**, 607,599 bytes. 도구 저장본을 바이트 그대로 복사하여 보존했다.
- 최종 선택 도구 원본 위치: `C:/Users/Loadcomplete/.codex/generated_images/01a158b3-fe11-7951-b129-ae6717c3b644/exec-be39b682-b99c-4dc2-b603-0845e144936c.png`.
- 첫 생성 원본: [raw/generator-attempt01.png](raw/generator-attempt01.png). 도구 원본 위치: `C:/Users/Loadcomplete/.codex/generated_images/01a158b3-fe11-7951-b129-ae6717c3b644/exec-637de939-e40e-478a-8c1f-ea4bdd4ea660.png`.
- 도구는 두 번 모두 요청한 1536² 대신 1254²를 반환했다. [normalize-layout.ps1](raw/normalize-layout.ps1)로 전체 이미지를 **균등 1.2008639308855291배** 확대하고 투명한 1536² 캔버스에 배치했다. 알파 ≥192의 위·아래를 니브와 맞추고 가로 중심은 X=768로 정렬했다.
- 원본 경계 (344,170)–(911,1095), 배치 이동 X=14.4578857 / Y=13.8531342. High-quality bicubic 재표본화. [layout-report.json](raw/layout-report.json).
- 중간 배치본: [layout-normalized.png](raw/layout-normalized.png). 첫 시도의 마감본·배치본·보고서·검수 이미지는 `raw/*-attempt01.*`에 보존했다. 최종 사용 파일은 폴더 최상위 PNG 한 장이다.
- 두 생성 호출에서 그림 내용을 만들고 수정했다. 결정적 후처리는 전체 균등 배치와 알파 경계 마감에 한정했다. 확대가 원본에 없는 정보를 추가하는 것은 아니다.

## 투명 알파 검수

니브 v03의 기존 마감 스크립트를 읽고 human 폴더 안으로 복사하여 파일명·클래스명·대상을 바꿔 사용했다. 원본 스크립트는 수정하지 않았다. [alpha-cleanup.ps1](raw/alpha-cleanup.ps1).

알파 ≥192 마스크, 3×3 opening, 가장 큰 연결 성분 유지, 16px 이하의 고립 핀홀만 채우기, 내부 알파 255 복구, 좁은 1px 경계 안티에일리어싱 재구성, 인접 내부색으로 경계 RGB 보완을 적용했다. 색상 키는 사용하지 않았다. 팔·몸 사이와 두 다리 사이의 실제 빈 공간은 유지했다.

[흰색·회색 배경 검수 PNG](raw/alpha-proof.png)를 직접 열어 머리·귀·깃·망토·소매·손·장화 경계와 빈 공간을 확인했다. 최종 PNG를 별도로 다시 읽어 알파와 치수를 확인했다.

| 항목 | 최종 |
| --- | ---: |
| 크기 | 1536×1536 |
| 전체 알파 0 | 1,838,260px |
| 전체 알파 255 | 513,377px |
| 부분 알파 | 7,659px, 경계 1px 범위 |
| 본체 내부 불투명 | 511,697 / 511,697 = 100% |
| 실루엣 외부 투명 | 1,836,583 / 1,836,583 = 100% |
| 네 모서리 알파 | 모두 0 |
| 완전 투명 픽셀의 0이 아닌 RGB | 0px |
| 알파 >0 경계 | (426,217)–(1109,1330) |
| 좌/상/우/하 투명 여백 | 426 / 217 / 426 / 205px |
| 최종 연결 성분 | 1개 |

본체 내부와 실루엣 외부는 각각 3×3 이웃이 모두 마스크인 곳, 모두 마스크 바깥인 곳이다. 좁은 경계 픽셀은 이 두 분모에서 제외한다. 알파 경계가 포함된 전체 경계와 비율 측정용 알파 ≥192 경계는 1px 차이가 있다. [alpha-report.json](raw/alpha-report.json)의 Raw 항목은 1254² 생성 원본이 아니라 1536² 배치 중간본의 통계다.

## 시각 검수와 한계

- 한 명의 인간 공용 여행자, 전신, 앞-왼쪽 3/4, 니브와 유사한 살짝 높은 카메라. 머리·얼굴·옷·손·발이 잘리지 않는다.
- 짧은 갈색 머리, 둥근 인간 귀, 수염 없는 얼굴, 하이라이트 없는 큰 단추 눈, 작은 코·차분한 작은 미소. 자세한 눈썹·주름·흉터·회색 옆머리 없음.
- 크림 깃·짧은 초록 망토·갈색 조끼·귀리색 소매·벨트·장화가 읽힌다. 큰 색 덩어리와 무광 점토/비닐 장난감 표현, 외곽선 없음.
- A자 자세와 빈 양손. 팔 아래와 몸통 사이에 빈 공간이 있고 두 다리·장화가 구분된다. 무기·방패·등짐·개인 장신구 없음.
- 중세 기반 판타지 여행복으로 검수했다. 배경·바닥·그림자·글자·워터마크 없음.
- 생성 도구는 편집 때 이미지를 재구성하므로 최초 시도와 최종의 의상 경계·얼굴·명암이 픽셀 단위로 동일하지는 않다.
- 턱 좌표는 수동 시각 측정이고 원근감과 머리카락 조형이 포함된다. 정확한 3D 치수, 정투영·후면 구조, 리깅 준비도를 보증하는 원화는 아니다.
- 게임 자산 교체·3D 모델 제작·실행파일 재내보내기는 수행하지 않았다.

## SHA256

| 파일 | SHA256 |
| --- | --- |
| 최종 `human-common-3q-v02.png` | `F9823E5EFBF9FB6FB29D6BE13C3DA3716958ABB75263B293848ADA0475CD91F8` |
| 생성 원본 `raw/human-common-3q-v02.png` | `56F105C87DC673748F4883AD7B5C4B134C63AE25A2A616914B9FD78A68C67451` |
| 입력 니브 v03 | `D33657A5A0B50B9B8BDD4F6384A3014B49AA0610111DFE8015480D038FF71F1B` |
| 입력 toy 참고 | `C26F3E21A10E119047DF10986BF4D27720C2E6B7A266ACA142BA2FCF78BF8687` |
| 입력 human B | `E086783C11A8F022694835618E24BDDFC3E2FB752AFFCF2F1B756567FF9AA753` |
| 요청서 | `D35C3B06BE77D1FCC99A7BDECB5F7564D58861E745F3EFD1F695C9C80AFF201E` |

입력 및 요청서의 검수 시점 해시는 [input-hashes.json](raw/input-hashes.json), 이 폴더의 그 밖의 산출물 해시는 [artifact-hashes.json](raw/artifact-hashes.json)에 기록한다. 후자는 자기 자신과 이 generation.md를 제외한다. 다른 작업이 진행 중인 외부 폴더에 대해 전체 변경 검사를 수행하거나 변경 원인을 판정하지 않았다.

## 실제 프롬프트 전문 — 최초 생성

실제 호출: 위 입력 3장 순서의 `referenced_image_paths`, `transparent_background=true`. [원문 텍스트](raw/prompt.txt).

```text
Use case: stylized-concept.
Asset type: one reusable HUMAN race traveler concept for 3D modeling in Witch's Lodge. Output one full-body character only, 1536 x 1536 PNG with genuine transparent alpha background.
Input images in order: 1) nib-3q-v03.png: PRIMARY and authoritative reference for head-to-body proportions, rendering, camera angle, plain face, and framing. 2) stylized-toy-chibi-ref-01.png: supporting simplified toy massing only. 3) bram-3q-b-v01.png: HUMAN wardrobe and color reference only; deliberately DO NOT inherit his body proportions, beard, gray temples, eyebrows, wrinkles, individuality, or jewelry.
MOST IMPORTANT, NONNEGOTIABLE PROPORTIONS: Match reference 1 Nib's squat 2.2-head-tall body exactly. The head INCLUDING short brown hair, from hair crown to chin, must be about 45–46% of total character height. On a 1536-square canvas, hair crown around y=220, chin around y=720, soles around y=1320: approximately 1100 pixels total height and 500 pixels head height. The head is almost as tall as ALL the rest of the body combined. Huge broad rounded head at least as wide as the clothed shoulder mass excluding the splayed arms. Compact round torso, almost no visible neck, extremely stubby legs with chunky boots immediately below torso, not a long-legged humanoid. Maintain these proportions even if clothing must be compressed.
Subject: ordinary generic human adult traveler, warm light peach human skin, small rounded human ears, clean shaven, short chestnut brown hair sculpted as a few broad smooth clumps. Two big flat dark button eyes with NO eye highlights, tiny rounded nose, tiny calm friendly mouth, no eyebrows or wrinkles or stubble.
Wardrobe: medieval-based fantasy, retaining medieval everyday atmosphere while allowing fantasy adaptation (중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색 허용). Very short muted dark forest-green cape close to the body with a cream fur collar sculpted in just a few broad rounded lobes, brown leather vest, oat/cream shirt with short chunky sleeved arms, plain brown belt with one simple muted brass rectangular buckle, dark brown stubby trousers and oversized short brown boots. Cape only reaches near waist; no long flowing tails, no round gold brooch or ornaments. Color grouping: brown, green, oat/cream, peach skin, dark eyes; minimal decoration.
Pose and composition: full body, one centered subject, front-left three-quarter view around 30–45 degrees exactly matching Nib's orientation and slightly elevated camera height. Upright symmetrical neutral A-pose, both arms angled slightly out with transparent gaps from torso, both empty mitten-like rounded hands visible; two very short legs clearly separated with a transparent gap. No props, no weapon, no shield, no backpack, no bedroll, no lantern, no earring, no pendant, no scar. Generous empty transparent margins on every side.
Style: match Nib reference 1 smooth matte clay / soft vinyl toy look, simple broad 3D forms with gentle broad studio shading, no outlines, minimal texture, no individual fur hairs, no fabric grain, no leather pores. Friendly calm expression. This is a reusable race base, not the named character Bram.
Background: genuinely transparent alpha, including all gaps between limbs. No floor, no stand, no contact shadow floating outside the character, no scenery, no gradient, no baked checkerboard, no text, no watermark.
Final check before rendering: HUGE head taking 45–46% of entire height, low compact torso, boots directly below torso. Do not repeat the rejected smaller-head, longer-legged proportions of image 3.
```

## 실제 프롬프트 전문 — 비율 수정

실제 호출: 첫 완성 시도 human PNG, 니브 v03 순서의 `referenced_image_paths`, `transparent_background=true`. [원문 텍스트](raw/prompt-edit.txt).

```text
Use case: precise-object-edit.
Edit target image 1 is the current clean-shaven generic HUMAN traveler concept. Image 2 is the authoritative Nib v03 reference for exact head/body ratio and matte toy rendering.
Make ONLY one targeted adjustment to the human's proportions: image 1 measures about 48.3% hair-crown-to-chin height / full height; Nib image 2 measures about 46.3%. Match Nib's ratio, making the human head 45.5–46.5% of total height, ideally 46%. Keep the body compact and legs extremely stubby. Do not lengthen the legs. Rebalance the head and compact torso very slightly to reach the 46% target. This should be a subtle proportion correction, not a redesign.
At the 1536x1536 final composition target, full human height is about 1110px from y=218 to y=1329, hair crown y=218, chin around y=730, so head height about 512px, rest of body about 599px. Head width remains at least as wide as clothed shoulders excluding outstretched arms.
Preserve everything else from human image 1: the short brown simple sculpted hair, human rounded ears, clean-shaven peach face, huge dark button eyes WITHOUT highlights, tiny nose and closed calm smile, short dark green cape close to body, broad cream fur collar lobes, brown leather vest and plain belt with rectangular buckle, oat shirt sleeves, dark stubby trousers and brown chunky boots, empty mitten hands. No eyebrows, beard, scars, wrinkles, brooch, weapon, backpack, or accessories. Preserve front-left 3/4 camera angle, slightly elevated camera matching Nib, neutral upright A-pose, both arms with clear transparent gaps from torso and two separate legs.
Keep smooth matte clay/vinyl toy style, broad 3D forms and minimal decoration, medieval-based fantasy retaining medieval everyday atmosphere while allowing fantasy adaptation (중세 기반 판타지, 중세의 생활감과 분위기를 유지하면서 판타지적 각색 허용).
Output ONE full-body human only, 1536x1536 RGBA PNG with genuine transparent alpha. Fully opaque body, no background, no floor, no contact shadow, no checkerboard, no text, no watermark. Do not include Nib or a comparison sheet.
The only intended change to the human is 48.3% -> about 46% head height ratio, with same short-legged toy silhouette and all other features preserved.
```
