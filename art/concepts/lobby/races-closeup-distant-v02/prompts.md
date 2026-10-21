# 종족 클로즈업 로비 · 인물과 원경 연결 v02 제작 기록

2026-10-21 (Asia/Seoul). 내장 `image_gen` 편집 1회와 요청 문서가 허용한 원본 보존 합성을 사용했다. API/CLI 생성은 사용하지 않았다.

## 실제 입력

1. **편집 대상:** `art/concepts/lobby/races-closeup-distant-v01/03-races-closeup-distant.png` — 얼굴·배치·크롭·제목·메뉴의 기준, 1920×1080.
2. **문제 영역 참고:** `docs/handoff/refs/lobby-closeup-distant-v01-feedback.webp` — 사용자의 빨간 표시. 결과에는 표시선을 넣지 않는다.
3. **원경 색·형태 참고:** `art/concepts/environment/04-prototype-reference-simplified.png` — 라벤더 설경·침엽수·작은 목조 박공지붕 산장과 앰버 창문. 카메라나 전체 구도를 옮기지 않는다.

세 입력을 직접 열어 확인하고 모두 실제 `referenced_image_paths`로 전달했다. `transparent_background=false`.

## 실제 편집 프롬프트 · 1차

```text
Use case: compositing.
Asset type: edited Korean medieval fantasy game lobby illustration, full-frame 1920x1080 16:9.
Input images: Image 1 is the exact EDIT TARGET v01. Image 2 is feedback ONLY: red lines indicate the disconnected area to fix; NEVER reproduce red lines. Image 3 is supporting environment reference ONLY for snowy pines, lavender snow, a small timber gabled lodge, and amber window color. Do not use its camera or composition.
Primary request: Make the existing portrait ensemble and winter landscape feel like ONE continuous painting. EDIT image 1 directly. Extend the snowy woodland, low hills, and mist from the lower right all the way LEFT into the negative-space gaps directly BEHIND the goblin head, witch hat brim, and orc shoulder/fur. Eliminate the empty cream strip outlining the right edge of the characters. The characters are standing in front of this winter landscape. A continuous pale lavender/periwinkle atmospheric field must TOUCH their silhouettes rather than fade out before reaching them. Forest silhouettes immediately behind the ensemble are medium muted plum/blue-gray and recede through pale lavender fog toward the right. Upper right logo and immediate menu background remain bright clean cream. Keep the woodland subtle, distant, small-scale and fog-obscured, not a dark foreground forest.
Edge integration: soften and break up ONLY the external tips of the goblin's red scarf and hair, witch hat brim and white hair, orc fur collar and outer hair with fine lavender mist, a few sparse snow flecks, and subtle periwinkle reflected sky light. Let distant blue-gray/lavender colors mingle with the very outer edge and clothing shadows, so there is no hard cutout edge on a flat cream sheet. Keep bold original interior ink and print texture. Do not blur the entire painting or wash out faces. Tiny warm amber window light can glance across the OUTER hair/fur/scarf edges facing the lodge; preserve original facial features exactly.
World and style: medieval-based fantasy, preserving medieval everyday materials and atmosphere while allowing fantasy interpretation. Match original thick tapered ink, broad color planes, painterly print grain. No modern objects or architecture. Keep a single tiny simple snowy timber lodge and existing quiet winter footpath at lower right, integrated with the extended hills. Cool plum/indigo at the character side -> muted blue-gray trees behind them -> faint lavender snow fog -> clean cream around menu. No isolated scenery vignette with cream moat.
Invariants: preserve ALL SEVEN characters' exact faces, expressions, eyes, skin, facial linework, positions, sizes, poses, crop and overlaps. Keep the human, wolf, orc, fairy, dwarf, witch and goblin all identical and in the same position. Only external silhouette tips and adjoining atmosphere may change. Preserve ALL UI lettering and ornament shapes, locations and colors EXACTLY: title "마녀산장", "이어하기", "새로운 이야기", "기록 보관소", "설정", "나가기", existing crescents, underline and title ornaments. No scenery strokes through any letter; keep clean cream breathing room immediately behind each text line. No added text or marks. Do not recrop, shift, resize, mirror or redesign anything.
Output: one complete 1920x1080 landscape lobby illustration. No red annotation, no comparison layout, no borders or watermark.
```

## 후처리·검수

### 생성 원본과 크기

- [생성 원본](drafts/01-imagegen-edit.png)은 1672×941이다. 도구에 1920×1080을 요청했지만 실제 반환 규격은 달랐다. 생성본만 HighQualityBicubic으로 1920×1080에 맞췄다. v01 원본 픽셀은 확대·축소하지 않는다.
- 원래 생성 저장 위치: `C:/Users/vnvnc/.codex/generated_images/01a15ed8-973f-77e3-9fc3-48bdb716bff5/exec-4d450eac-4938-4f42-b808-c7faa7637fbf.png`. 이 파일을 지정 `drafts/`에 복사했다.
- 생성본에서 얼굴과 글자 세부가 바뀌어, 인물 내부·얼굴·UI의 최종 소스는 v01로 정했다. 얼굴 자체의 새 라이팅보다 원본 보존을 우선했다. 앰버와 차가운 반사광은 외곽 머리카락·모자·스카프 끝에 제한했다.

### 보존 합성

재현 스크립트는 [drafts/compose.ps1](drafts/compose.ps1)이다. Windows PowerShell 5.1 / System.Drawing을 사용하며 한글 캡션을 위해 UTF-8 BOM으로 저장했다. 프로젝트 루트에서 실행한다.

```powershell
& 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe' -NoProfile -ExecutionPolicy Bypass -File 'art/concepts/lobby/races-closeup-distant-v02/drafts/compose.ps1'
```

- v01 실루엣 바깥 먹선·털을 행별로 추적한다. `x=950~1278`에서 `R<210 또는 G<205 또는 B<180`인 마지막 픽셀을 외곽 기준으로 삼고, 그 안쪽 24px에서 바깥쪽 2px까지 생성본으로 완만하게 연결한다. `x<950`은 v01을 그대로 쓴다.
- 실루엣 주변 크림색은 오른쪽에서 연결 영역을 찾아 배경으로 처리한다(`R>210, G>205, B>180`). 인물 주변의 원본 크림 띠를 합성 마스크에 포함해 다시 붙이지 않도록 했다. 모자 아래·머리카락 사이 틈에도 원경의 색이 들어간다.
- 외곽에 가까운 오크·고블린 얼굴은 별도 다각형으로 원본을 보존한다. 나머지 다섯 얼굴은 전부 `x<950`의 원본 보존 범위 안에 있다. 얼굴 다각형 바깥의 연결된 크림은 보호하지 않아 얼굴 밖에 밝은 띠가 남지 않게 했다.
- 제목과 메뉴의 문구·장식·초승달·밑줄·나가기와 글자 뒤 크림을 여섯 사각형에서 원본 그대로 보존한다. 바깥쪽 40px는 부드럽게 이어진다. 좌표는 [픽셀 검수 기록](drafts/pixel-verification.json)의 `ui_regions`에 있다.
- 직접 검수 후, 원경의 대비를 낮추기 위해 생성 영역에 따뜻한 라벤더 공기층(RGB 241,233,231)을 최대 22% 섞었다. `y=360~700`에서 점차 늘려 아래쪽에 적용한다. 얼굴·UI 등 보호 픽셀에는 적용하지 않는다. 전체 흐림 필터는 쓰지 않았다.
- [검수 전 합성 초안](drafts/02-composite-before-qa.png)도 보존했다. 이 초안보다 최종본은 원경이 옅고 얼굴 바깥의 불필요한 크림 보호 부분이 줄었다.
- [최종 생성본 사용 마스크](drafts/03-generated-blend-mask.png): 검정은 v01 그대로, 흰색은 생성 영역, 회색은 전이. [추가 얼굴 보호 마스크](drafts/04-face-protection-mask.png)도 남겼다.

### 최종 검수

- 최종 PNG 1920×1080, v01/v02 나란히 비교 시트 2880×918을 직접 열었다. 일곱 인물과 표정·크롭·원래 한글·제목 장식·선택 표시, 원경 연결·안개·메뉴 여백을 확인했다. 붉은 표시선과 추가 문구가 없다.
- v01과 최종본을 동일한 1920×1080 픽셀에서 비교했다. 보호 영역 1,537,219픽셀 중 변경 0, 추가 오크·고블린 얼굴 마스크의 실효 보호 영역 94,272픽셀 중 변경 0, UI 보호 영역 271,447픽셀 중 변경 0이다. 위 영역은 서로 겹치므로 합산하지 않는다.
- 변경 픽셀은 505,635개다. 생성본의 전체 얼굴이나 UI를 최종으로 채택하지 않았다. 보호 수치는 [drafts/pixel-verification.json](drafts/pixel-verification.json), 납품 파일 SHA-256은 [drafts/delivery-sha256.json](drafts/delivery-sha256.json)에 기록했다.
- 수정 범위는 새 v02 폴더와 요청 문서 끝의 납품 절이다. 게임 임포트·실행·내보내기·커밋을 하지 않았다.
- 작업 전후 기존 보호 파일 8,412개의 메타데이터를 비교했다. 이 작업의 쓰기 범위 밖에서 Godot·다른 문서·루트 실행파일 등 12개 파일의 갱신이 관측됐고, 기존 로비 폴더에는 변경이 없었다. 병행 변경은 되돌리지 않았다. [관측 기록](drafts/protected-paths-verification.json)은 외부 갱신의 관측이며 이 작업의 수정 목록이 아니다.
