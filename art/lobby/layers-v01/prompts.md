# 로비 레이어 v01 · 실제 프롬프트와 재현

2026-10-24. 내장 `image_gen` 편집 1회. CLI/API 대체 생성은 사용하지 않았다.

입력은 승인 원화 `art/concepts/lobby/races-closeup-distant-v02/03-races-closeup-distant.png` 하나이며, 먼저 원본을 열어 확인했다. `referenced_image_paths`로 원본 파일을 실제 편집 입력에 전달했고 `transparent_background=false`를 사용했다. 생성본은 배경 복원용으로만 썼다. 인물·글씨·장식은 생성본에서 가져오지 않는다.

## 실제 입력 프롬프트

```text
Edit target: the attached approved 1920x1080 medieval fantasy lobby painting. Produce ONLY the clean background plate at the identical 16:9 composition. Completely remove ALL seven large foreground figures covering the left two thirds: human, wolf man, orc, fairy including wings and antennae, witch including hat, dwarf, goblin including ears. Also completely remove ALL lettering, title logo, decorative crescent moons, leaves and roof flourish, all five Korean menu labels, gold underline and gold menu crescent. NO people, animals, faces, text, symbols or watermarks anywhere. Extend the winter landscape naturally behind their old silhouettes, especially a minimum 80 pixel inward band around the entire silhouette: lavender winter sky and haze above, dark quiet plum/indigo/teal conifer forest on left, snow-covered hills and atmospheric forest below. The covered far left can be dark forest and mist. Match thick tapered ink marks, broad color shapes, restrained printed painterly texture of approved image. Medieval-based fantasy, retain medieval daily-life atmosphere with fantasy adaptation. Preserve the original right-hand visible snow landscape, small timber gabled lodge with amber windows at x1340 y880, distant trees, sky and lavender palette in their EXACT position. Keep the entire right menu/title area very pale clean cream mist for legibility. Remove the artificial rectangular cream box seams near x1260 and y170 and give this mist area a broad 100+ pixel organic soft irregular feathered boundary into lavender sky/forest. No new props, no new buildings, no frames. This is a background restoration plate, not a redesign; preserve composition and right landscape precisely.
```

## 생성본 보관

도구 출력 `C:/Users/vnvnc/.codex/generated_images/01a16c12-cbc2-7e52-9b7a-c188bf351c45/exec-74f9fa89-1cba-492c-b282-e3bbac8b7318.png`를 [drafts/01-background-imagegen.png](drafts/01-background-imagegen.png)로 복사했다. 재현에는 프로젝트 안의 이 복사본을 사용한다. 생성본만 1920×1080으로 맞추며 승인 원화는 확대·축소·재저장하지 않는다.

## 결정적 후처리

[build_layers.py](drafts/build_layers.py)는 원화 좌표의 실루엣 앵커, 원본 색·먹선과 연결성으로 인물 마스크를 만들고 제목·메뉴를 구분한다. 글자와 로고의 크림 오염은 주변 종이와 국소 잉크색으로 알파를 계산해 제거한다. 알파가 1인 인물·글자 픽셀은 원본 RGB를 그대로 보존하고, 반투명 경계는 배경을 빼서 straight alpha RGB로 복원한다. 투명 픽셀의 RGB는 0으로 정리한다.

배경은 생성된 깨끗한 숲과 주변 대기의 색을 이어 붙여 인물 아래를 채운다. 제목·메뉴의 잉크와 밝은 가장자리 흔적을 주변 크림 종이로 복원하고, 허락된 상자 경계에서는 100px 이상에 걸친 불규칙한 안개 전이를 만든다. 새 글자·인물·소품을 추가하지 않는다. 실제 마스크·구역 지도·재합성·이동 검수 이미지와 수치를 함께 저장한다.

## 재현 순서

Python 3, Pillow, NumPy가 필요하다. Godot를 실행하지 않는다.

```powershell
& 'C:/Users/vnvnc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' 'art/lobby/layers-v01/drafts/build_layers.py'
& 'C:/Users/vnvnc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' 'art/lobby/layers-v01/drafts/verify_delivery.py'
```

다른 환경에서는 동일한 두 스크립트를 해당 Python 실행파일로 실행하면 된다. 빌드 스크립트의 쓰기는 `godot/assets/ui/lobby/`와 `art/lobby/layers-v01/`로 제한된다. 검증 스크립트는 최종 PNG를 다시 읽어 독립적으로 검사한다. `--reviewed`는 실제 시각 검수를 마친 뒤에만 사용한다.
