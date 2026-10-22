# 손님 말 걸기 알림 · 말풍선 에셋 v01

2026-10-22. 작업 기준: [Codex 인수인계 문서](../../../docs/handoff/codex-speech-notification-v01.md).
중세 기반 판타지의 밝은 종이와 짙은 자두색 먹선으로 목표 시안의 말풍선을 제작했다.

## 납품 파일

| 파일 | 규격 | 용도 |
| --- | --- | --- |
| [speech_plain.png](../../../godot/assets/ui/moon_runes/common/speech_plain.png) | 512×256 RGBA | 꼬리 없는 몸통. 네 방향 48px 9분할 |
| [speech_tail_left.png](../../../godot/assets/ui/moon_runes/common/speech_tail_left.png) | 96×96 RGBA | 왼쪽 삼각 꼬리. 오른쪽은 열린 크림색 접합부 |
| [sheet.png](sheet.png) | 1440×1800 RGB | 어두운/밝은 배경에 기본 합성·1024×384 확대 합성·목표 시안 비교 |
| [prompts.md](prompts.md) | Markdown | 실제 생성 프롬프트·참고 입력·후처리 기록 |
| [validation.json](validation.json) | JSON | 규격·알파·평탄화·접합 검사, 해시 및 보호 경로 관찰 |

게임용 PNG 두 장에는 글자·초상·메달·화살표·그림자·배경이 없다. 미리보기의 제목과 목표 시안 발췌는 설명용이며 게임 PNG에 포함되지 않는다. 내장 image_gen으로 각각 생성 후 요청된 후처리를 수행했다. 생성 원본과 중간본은 [drafts/](drafts/)에 보관했다.

## 적용 좌표

- 몸통: `StyleBoxTexture`의 texture margin을 좌·상·우·하 모두 **48px**로 설정한다. 모서리 반지름은 약 40px, 먹선은 약 7px다. 늘어나는 중앙 영역 `x48..463, y48..207`은 완전 불투명 단색 종이 면이다.
- 꼬리: 몸통을 먼저 그리고 꼬리를 나중에 겹친다. 꼬리의 왼쪽 위 위치는 **몸통 왼쪽 위 + (-50, 몸통 높이/2 - 48)** 이다. 현재 PNG의 원본 크기를 기준으로 한다. 함께 축소할 때는 이 좌표도 같은 배율을 적용한다.
- 꼬리 오른쪽 `x60..95`에는 먹선이 없다. 이 부분의 안쪽 면 `y25..70`은 몸통과 같은 완전 불투명 크림색이다. 오른쪽 끝은 이미지 경계까지 열린다. 꼬리의 두 빗변 먹선은 몸통의 왼쪽 먹선과 만난다.
- 글자·메달·화살표는 담당 구현 코드에서 별도로 그린다. 임포트 사이드카는 이번 작업에서 만들지 않았다.

종이색 **#F6E0BA**, 먹선 기준색 **#3A223D**는 목표 시안에서 직접 추출했다. 몸통 먹선에는 생성 원본에서 가져온 1 RGB 레벨 이내의 미세 변화가 있다. 생성 원본의 넓은 베벨·중앙 그러데이션·알파 잡티는 제거하고 얇은 종이 안쪽 림만 남겼다. 샘플 위치는 [palette-samples.json](drafts/palette-samples.json)을 참고한다.

## 검수

- 두 파일의 지정 크기와 RGBA 형식 확인.
- 몸통 외곽, 꼬리 외부 alpha 0 확인. 꼬리의 오른쪽 접합부만 의도적으로 이미지 오른쪽 경계까지 채운다.
- 투명 픽셀의 RGB를 0으로 정리하고 외곽 안티앨리어싱 유지.
- 48px 9분할로 몸통 전체를 **1024×384(가로 2배·세로 1.5배)**로 확대. 중앙 면은 완전 단색이므로 얼룩이나 늘어진 무늬가 없다. 모서리와 먹선 두께는 유지된다.
- 꼬리 위아래 픽셀 대칭, 오른쪽 열린 면의 색·불투명도, 접합 중앙에 기존 세로 먹선이 남지 않는지 수치 검사 통과.
- [시트](sheet.png)와 [접합 확대](drafts/join-inspection-2x.png)를 열어 밝고 어두운 배경에서 선 끊김·이중선·접합 틈이 없는지 시각 확인.
- 목표 시안 발췌와 나란히 색·단순한 둥근 형태를 대조했다. 확대 안정성을 위해 중앙의 눈에 띄는 종이 무늬는 생략했다.

1:1 픽셀 크기의 독립 확대 검수판: [어두운 배경](drafts/nine-slice-dark.png), [밝은 배경](drafts/nine-slice-light.png).

## 보호 범위

이 작업에서 작성한 경로는 `art/ui/speech-notification-v01/`와 요청된 게임용 PNG 두 경로뿐이다.
코드·씬·셰이더·카드·extension_v01·approved·루트 실행파일·docs에는 쓰기 작업을 하지 않았다. 커밋, Godot 실행·임포트·내보내기도 수행하지 않았다.

제작 전 보호 대상 및 기존 common 파일 총 1,347개의 SHA-256을 [protected-before.json](drafts/protected-before.json)에 보관했다. 작업 중 `godot/scripts/ui/guest_arrival.gd`, `godot/scripts/ui/handwriting.gd`의 해시 차이가 감지되었다. 이 작업은 두 파일을 수정하지 않았고, 감지된 별도 변경을 되돌리지 않았다. 비교 결과는 `validation.json`의 `protected_observation`에 그대로 기록했다. 자산 검수 결과와 이 관찰 결과는 분리해서 보고한다.

## 보관·재현

- `drafts/body-generated.png`, `drafts/tail-generated.png`: 생성 원본.
- `drafts/body-resampled-before-flatten.png`: 모서리별 리샘플링 중간본.
- `drafts/target-reference-crop.png`, `widgets-reference-crop.png`, `common-style-reference.png`: 읽기 전용 참고의 발췌/복사.
- `prepare_assets.py build`: 보관된 원본을 바탕으로 지정된 최종 PNG 두 장과 미리보기·검수 기록을 재생성.
- `prepare_assets.py verify`: 자산 규격과 보관된 보호 대상 기준 해시를 재대조. 별도 작업의 변경은 기록하며 되돌리지 않는다.

Pillow와 NumPy가 설치된 Python으로 실행한다. 게임 적용·임포트·내보내기는 인수인계 문서에 따라 Claude 담당이다.

## 초상 메달 틀 PNG v01 · 추가 납품 (2026-10-22)

기준: [메달 틀 인수인계](../../../docs/handoff/codex-speech-medal-frame-v01.md). 목표 시안의 갈색 나무 띠·안팎 놋쇠 테·작은 리벳 16개를 내장 `image_gen`으로 생성하고, 원형과 투명 영역을 후처리했다. 게임 코드에서 타이머 호를 겹칠 수 있도록 별도 장식을 추가하지 않았다.

| 파일 | 규격·역할 |
| --- | --- |
| [medal_frame.png](../../../godot/assets/ui/moon_runes/common/medal_frame.png) | **512×512 RGBA**, 중심 (256,256), 바깥 지름 492px, 안쪽 지름 384px, 띠 두께 54px |
| [frame-sheet.png](frame-sheet.png) | 1680×1360 RGB. 어두운/밝은 배경의 틀 단독, 그라즈 얼굴 합성, 목표 시안·축소 비교 |
| [frame-prompts.md](frame-prompts.md) | 실제 생성·수정 프롬프트, 참고 입력, 후처리·검수 기록 |
| [frame-drafts/](frame-drafts/) | 1·2차 생성 원본, 원형 보정 기준점, 초상 합성, 시안 색 샘플, 보호 대상 기준 해시 |
| [frame-validation.json](frame-validation.json) | 최종 규격·알파·리벳 수와 간격·파일 해시·보호 대상 관찰 결과 |
| [prepare_frame.py](prepare_frame.py) | 이 메달 작업 전용 후처리·미리보기·검수 재현 스크립트 |

가운데와 바깥은 실제 alpha 0이며 투명 화소 RGB도 0이다. 실루엣은 회전 대칭이고 리벳은 22.5° 간격으로 배치했다. 나무결과 좌상단 빛의 명암은 유지했다. 최종 PNG에는 글자·초상·배경·드롭섀도·타이머 호가 없다. 미리보기의 초상과 배경은 설명용 합성이다.

검수는 위 PNG를 열어 밝고 어두운 배경·초상 합성·축소 상태에서 확인하고, 동심원 알파와 실제 리벳 16개 하이라이트의 간격도 수치로 확인했다. 수치 결과는 메달 전용 검수 JSON을 따른다. 최초 말풍선의 `validation.json`과 생성 스크립트는 수정하지 않았다.

재현: Pillow와 NumPy가 있는 Python으로 `prepare_frame.py build`를 실행하면 보관된 2차 원본에서 최종 메달 PNG·미리보기·검수 JSON을 재생성한다. `prepare_frame.py verify`는 PNG와 보호 대상 해시만 재검사한다. Godot 호출과 임포트 사이드카 생성은 하지 않는다.

### 메달 작업의 보호 경로 관찰

이번 작업의 쓰기는 지정된 메달 PNG와 본 아트 폴더의 메달 산출물·README 추가 절에 한정했다. `godot/scripts/**`, `scenes/**`, `shaders/**`, 카드, extension_v01, approved, `speech_*.png`, 루트 실행파일, 다른 `docs/` 문서는 수정하지 않았다. 커밋·Godot 실행·임포트·내보내기도 하지 않았다.

작업 전 보호 대상 1,357개의 SHA-256을 [frame-drafts/protected-before.json](frame-drafts/protected-before.json)에 저장했다. 작업 중 다음 파일에서 기준 해시와 다른 별도 변경을 관찰했다. 이 작업의 쓰기 대상이 아니므로 해당 변경은 그대로 보존했다. 따라서 보호 대상 전체가 불변이었다고 주장하지 않으며, 최신 대조 결과는 `frame-validation.json`에 기록한다.

- `godot/scripts/ui/hud.gd`
- `godot/scripts/game/lodge_economy.gd`
- `godot/scripts/ui/moon/moon_hud.gd`
- `godot/scripts/ui/guest_arrival.gd`
- `godot/scripts/config.gd`
- 루트 `WitchsLodge.exe`

게임 적용과 Godot 임포트·내보내기는 인수인계 문서대로 Claude 담당이다.

