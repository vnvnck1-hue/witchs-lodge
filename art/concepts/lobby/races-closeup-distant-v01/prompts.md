# 종족 클로즈업 로비 · 설경 원경 제작 기록

2026-10-21 (Asia/Seoul). 내장 `image_gen` 편집 1회, 이후 요청 문서가 허용한 원본 픽셀 보존 합성. API/CLI 생성은 사용하지 않았다.

## 실제 입력

1. **편집 대상:** `art/concepts/lobby/reference-composition-v01/03-races-closeup.png` — 일곱 인물, 제목, 모든 메뉴, 초승달, 밑줄, 크롭의 기준. 실제 규격 1672×941.
2. **보조 참고:** `art/concepts/environment/04-prototype-reference-simplified.png` — 눈 덮인 침엽수, 작은 목조 본채와 단순한 박공지붕의 형태.
3. **보조 참고:** `art/concepts/lobby/game-style-v02/02-winter-inn-window.png` — 창밖 숲의 연한 라벤더·페리윙클 밀도만 참고.

세 이미지를 직접 열어 확인한 뒤 실제 `referenced_image_paths` 입력으로 사용했다. `transparent_background=false`.

## 실제 생성 프롬프트

```text
Use case: compositing.
Asset type: edit of an existing 1920x1080 16:9 Korean fantasy game lobby illustration.
Input images: Image 1 is the EXACT EDIT TARGET 03-races-closeup.png; Image 2 is supporting reference ONLY for the small simple snow-covered gable-roof lodge and snowy evergreen forms; Image 3 is supporting reference ONLY for the pale lavender forest in the window, not its composition, people, buildings, or text.
Primary request: Add ONLY a very faint fog-dissolved winter distant landscape behind the existing seven-person closeup ensemble and in the lower right cream background. Preserve EVERY character and ALL existing UI exactly as in image 1: do not repaint, move, resize, recolor or alter any face, eye, hair, costume, contour, crop, text, logo, crescent selection marker or underline. Exact image-1 layout and image bounds.
Scene/backdrop: medieval-based fantasy, preserving medieval everyday materials and atmosphere while allowing fantasy interpretation. Snow-covered evergreen forest, gentle low rolling hills, a winding snowy footpath, and ONE SMALL timber lodge with a SIMPLE gabled snowy roof and two or three tiny subdued amber windows, one very fine chimney smoke curl. Place the lodge near x=1320 y=885 in a 1920x1080 canvas, entirely below and LEFT of the menu lettering. The landscape horizon is around y=700. Tallest softly dissolving tree tips only in the narrow gap just behind the silhouette at x=1220 to 1430, never crossing a letter. Low soft trees and hills can extend along the bottom right, but keep a clear unpainted mist halo around the bottom-right exit word. Trees must not be foreground trees. All scenery is DISTANT, small scale, veiled in air and fog, soft and extremely low-contrast.
Palette and style: warm cream paper, very pale desaturated lavender/periwinkle. Half dissolve every landscape contour in cream snow haze. Minimal very pale linework in scenery; broad painterly shapes consistent with the existing print texture. Character ink and colors remain EXACTLY original. Distant lodge and trees must be far less vivid and sharp than characters. Tiny amber window pinpoints only.
UI keep EXACTLY image 1: title 마녀산장, 이어하기, 새로운 이야기, 기록 보관소, 설정, 나가기, the original plum logo crescent, amber navigation crescent and fine amber underline. Keep their original shapes positions and colors. Background immediately behind ALL lettering, ornamental logo strokes, selection icon, underline and exit remains nearly blank bright cream fog. No tree, roof, horizon line, smoke or path touches or overlaps any UI stroke. No new moon required: preserve the existing crescent only.
Avoid: new people, identity changes, layout changes, buildings behind text, busy scenery, dark trees, strong background outlines, saturated blue, large lodge, castle/town/towers, extra text or labels, borders, watermarks.
Output: one full-frame landscape edited illustration, 1920x1080.
```

## 생성 결과와 후처리

- 생성 원본: [drafts/01-imagegen-edit.png](drafts/01-imagegen-edit.png), 1672×941. 생성본의 인물·UI는 최종본의 소스로 채택하지 않았다.
- 생성 저장 원본: `C:/Users/vnvnc/.codex/generated_images/01a15ecc-82eb-7b63-9552-d0ccd208e2d1/exec-554c8a40-347b-4eaf-b5ec-7870f60c5e80.png`. 프로젝트의 `drafts/`로 복사해 보존했다.
- [재현 스크립트](drafts/compose.ps1): Windows PowerShell 5.1 / System.Drawing. 스크립트는 한글 캡션을 위해 UTF-8 BOM으로 저장했다. 프로젝트 루트에서 `& 'art/concepts/lobby/races-closeup-distant-v01/drafts/compose.ps1'` 실행.
- 원본과 생성본을 동일한 HighQualityBicubic 설정으로 1920×1080에 맞춘다. 원본은 정확한 16:9보다 약 0.053% 좁아, 전체 이미지의 크기 변환만 적용한다. 개별 인물·UI의 이동·재작화·재배치는 없다.
- 최종본의 바탕은 원본이다. 생성본은 배경에만 최대 58%로 합성한다. 원본 좌표 기준 `x≤1080` 또는 `y≤515`는 완전히 보존하고, 각각 `x=1080~1150`, `y=515~710`에서 부드럽게 배경 합성량을 늘린다. 이 경계는 인물 외곽보다 바깥쪽이다.
- 메뉴 보호 사각형 `(1235,480)–(1550,785)`과 나가기 보호 사각형 `(1515,835)–(1672,925)` 안은 원본 그대로다. 바깥쪽은 각각 85px, 75px 폭의 완만한 안개 전이로 연결한다. 모든 좌표는 1672×941 원본 기준.
- 제목은 상단 전체 보호 범위 안에 있다. 메뉴 글자·선택 초승달·밑줄·나가기 뒤까지 기존 크림색 여백을 보존한다. 새 초승달은 추가하지 않고 원래 제목의 초승달만 유지했다.
- [합성 마스크](drafts/03-scenery-blend-mask.png)는 검정이 원본 보존, 밝을수록 생성 배경 사용 비중이 높은 영역이다.

## 확인

최종본과 비교 시트를 직접 열어 인물·문구·창문·눈길·숲의 거리감과 메뉴 여백을 확인했다. 같은 크기의 [원본 비교 기준](drafts/02-original-1920x1080.png) 대비 보호 픽셀 1,872,337개 중 변경 0개, 배경 변경 157,851개다. [수치 기록](drafts/pixel-verification.json)을 함께 보존한다. 이 픽셀 일치는 1920×1080으로 크기 변환한 원본과의 비교이며, 1672×941 입력 파일과의 무변환 일치를 뜻하지 않는다.
