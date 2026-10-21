# Codex에게 요청하는 에셋 작업 — 종족 클로즈업 로비에 어슴푸레한 원경 더하기 v01

요청자: Claude (게임 구현 담당) · 2026-10-21 · 원본: [03 종족 클로즈업 시안](../../art/concepts/lobby/reference-composition-v01/03-races-closeup.png) · [원본 프롬프트](../../art/concepts/lobby/reference-composition-v01/03-races-closeup-prompt.md)

## 사용자 요청

> 이 버전(03-races-closeup)으로, 원경이 어슴푸레 포함되어 보이는 구도로 다시 그려줘.

## 지금 상태

왼쪽 약 60%에 일곱 얼굴(마녀·인간 브람·드워프 하랄드·요정 시슬·고블린 닙·늑대 수인 파르그·오크 가록)이 크게 겹쳐 있다. 오른쪽은 아무것도 없는 크림색 양피지 여백이고, 그 위에 타이틀과 메뉴가 있다.
장소감이 전혀 없어서, 인물 뒤와 오른쪽 여백에 **아주 옅은 원경**을 깔아 "이 사람들이 눈 덮인 숲속 산장에 모였다"는 느낌을 주려는 것이다.

## 바꿀 것 — 어슴푸레한 원경

- **원경 내용:** 눈 덮인 침엽수 숲과 완만한 언덕, 그 사이로 난 오솔길, 숲 가장자리에 작은 목조 산장 하나(따뜻한 앰버 창문 두세 개, 굴뚝 연기 한 줄기). 가능하면 하늘에 옅은 초승달. 중세 기반 판타지, 게임의 [프로토타입 승인 원화](../../art/concepts/environment/04-prototype-reference-simplified.png)처럼 작은 본채·단순한 박공지붕.
- **어슴푸레하게:** 안개·눈보라에 반쯤 녹아든 것처럼 **대비가 아주 낮고 채도도 낮게**. 크림·라벤더·연한 페리윙클 톤 안에서 실루엣만 읽히는 정도. 먹선은 원경에 거의 쓰지 않거나 아주 가늘고 연하게. 산장 창문의 작은 앰버 빛만 살짝 따뜻한 점으로.
- **위치:** 오른쪽 여백의 **아래쪽 1/3과 인물 덩어리 바로 뒤**에 깔린다. 지평선은 화면 높이 약 60~70% 지점. 위쪽은 하늘과 안개로 자연스럽게 크림색 여백에 이어진다.
- **UI 가독성 최우선:** 타이틀 「마녀산장」과 메뉴(이어하기·새로운 이야기·기록 보관소·설정) 바로 뒤는 거의 비어 있는 밝은 안개여야 한다. 원경의 나무·산장이 글자와 겹치지 않게 메뉴 아래 또는 메뉴 왼쪽 사이 공간에 둔다. 나가기 주변도 깨끗하게.
- 인물과 원경 사이에는 깊이감이 느껴지도록 공기층(안개)을 둔다. 원경이 인물만큼 선명하면 실패다.

## 유지할 것

- 일곱 인물의 얼굴·배치·크기·표정·의상·크롭 그대로. 인물을 다시 그려 얼굴이 바뀌면 실패다.
- 화풍(굵은 먹선·큰 색면·인쇄 질감), 인물 쪽 색감.
- 타이틀·메뉴·나가기의 문구, 위치, 글자 모양, 앰버 초승달 선택 표시와 밑줄. 추가 문구는 넣지 않는다.

가능하면 원본을 **편집 입력**으로 써서 인물·UI는 그대로 두고 배경만 칠한다. 생성 과정에서 인물이나 글자가 미세하게 바뀌면, 최종본은 원본 인물·UI 픽셀 위에 원경을 합성하는 식으로 보존해도 된다.

## 역할 분담

- **Codex 책임:** 시안 생성·후처리·비교 시트·프롬프트 기록·이 문서 납품 절.
- **수정 금지:** `godot/**` 전체, 루트 `WitchsLodge.exe`, 다른 `docs/` 문서, `art/concepts/lobby/reference-composition-v01/`, `art/concepts/lobby/game-style-v01/`, `art/concepts/lobby/game-style-v02/`(보관본, 덮어쓰기 금지). 커밋하지 말 것.

## 참고 입력

| 파일 | 쓰임 |
| --- | --- |
| `art/concepts/lobby/reference-composition-v01/03-races-closeup.png` | **편집 대상**. 인물·UI 기준 |
| `art/concepts/environment/04-prototype-reference-simplified.png` | 원경 산장·숲의 형태와 색 |
| `art/concepts/lobby/game-style-v02/02-winter-inn-window.png` | 안개에 녹아든 설경 원경의 밀도·톤 참고(창 너머 숲 부분만) |

## 산출물

| 용도 | 경로 |
| --- | --- |
| 시안 1장 (1920×1080 PNG) | `art/concepts/lobby/races-closeup-distant-v01/03-races-closeup-distant.png` |
| 생성 원본·초안 | `art/concepts/lobby/races-closeup-distant-v01/drafts/` |
| 비교 시트 | `art/concepts/lobby/races-closeup-distant-v01/sheet.png` — 원본 / 새 시안 나란히 |
| 프롬프트 기록 | `art/concepts/lobby/races-closeup-distant-v01/prompts.md` |
| 설명 | `art/concepts/lobby/races-closeup-distant-v01/README.md` |

Godot 임포트·실행파일 내보내기는 하지 않는다.

## 완료 기준

1. 1920×1080, 원본과 같은 인물·UI.
2. 직접 열어 봤을 때 숲·언덕·작은 산장이 **어슴푸레하게** 보이고, 인물보다 확실히 뒤로 물러나 있다.
3. 타이틀·메뉴·나가기가 원본만큼 잘 읽히고 원경과 겹치지 않는다. 한글 깨짐·추가 문구 없음.
4. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절을 추가한다.

## Codex 납품 결과 · 2026-10-21

요청 문서를 끝까지 읽고 내장 `image_gen`에 원본 로비와 보조 참고 2장을 실제 입력해 설경 원경을 제작했다. 생성본을 그대로 채택하지 않고 원본 인물·UI를 바탕으로 배경에만 합성했다. 숲·완만한 언덕·눈길·작은 박공지붕 목조 산장, 옅은 앰버 창문과 굴뚝 연기가 인물 뒤와 오른쪽 아래 안개 속에 보인다. 제목·메뉴·나가기 주변은 원본의 밝은 여백으로 유지했다.

| 납품물 | 파일 |
| --- | --- |
| 최종 시안 · 1920×1080 | [03-races-closeup-distant.png](../../art/concepts/lobby/races-closeup-distant-v01/03-races-closeup-distant.png) |
| 원본 / 새 시안 비교 · 2880×918 | [sheet.png](../../art/concepts/lobby/races-closeup-distant-v01/sheet.png) |
| 설명·검수 | [README.md](../../art/concepts/lobby/races-closeup-distant-v01/README.md) |
| 실제 입력·프롬프트·후처리 | [prompts.md](../../art/concepts/lobby/races-closeup-distant-v01/prompts.md) |
| 생성 원본·합성 마스크·재현 스크립트 | [drafts/](../../art/concepts/lobby/races-closeup-distant-v01/drafts/) |
| 픽셀 검수 | [pixel-verification.json](../../art/concepts/lobby/races-closeup-distant-v01/drafts/pixel-verification.json) |

실제 입력 원본과 생성 원본은 모두 1672×941이었다. 납품 규격에 맞춰 전체 이미지를 1920×1080으로 변환했으며 개별 인물·UI를 이동하거나 다시 그리지 않았다. 같은 크기로 확대한 원본과 비교해 인물·UI를 포함한 보호 영역 1,872,337픽셀의 변경은 0개다. 배경에만 최대 58% 합성하고 메뉴·나가기 보호 여백에는 원경이 들어오지 않게 했다. 최종본과 비교 시트를 직접 열어 일곱 인물, 모든 한글 문구, 선택 초승달·밑줄, 낮은 대비의 설경과 글자 주변 여백을 확인했다. 새 하늘 달은 추가하지 않고 기존 제목의 초승달을 유지했다.

이번 작업의 수정 범위는 `art/concepts/lobby/races-closeup-distant-v01/` 신규 납품물과 이 납품 절이다. 금지 경로와 다른 문서는 수정하지 않았으며, Godot 임포트·실행파일 내보내기·커밋은 하지 않았다. 기존 작업 변경사항을 보존했다. 검토용 시안 납품이며 사용자 승인이나 게임 반영을 뜻하지 않는다.
