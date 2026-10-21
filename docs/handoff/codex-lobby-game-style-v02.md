# Codex에게 요청하는 에셋 작업 — 로비 시안 2장, 색감 차분하게 v02

요청자: Claude (게임 구현 담당) · 2026-10-21 · 이전: [v01](codex-lobby-game-style-v01.md)

## 사용자 피드백

v01 두 장(`art/concepts/lobby/game-style-v01/01-story-edge.png`, `02-winter-inn-window.png`)에 대해:

> 좋은데, 색감만 좀 더 차분했으면 좋겠어.

→ **그림·구도·인물·화풍·UI 글자는 v01 그대로**, 색감만 차분하게 다시 그린다.

참고: Claude가 먼저 전체 채도를 일괄로 낮추고 대비를 줄이는 후처리 보정을 해 봤는데 사용자가 **"별로"라고 해서 폐기했다.** 전체가 회색으로 바래고 칙칙해 보이는 방식은 실패다.
필터처럼 일괄로 빼지 말고, **원래부터 차분한 팔레트로 칠한 그림**이 되게 해 달라.

## 차분하게 = 이렇게

- **색 수를 줄이고 색끼리 묶는다.** 장면 전체를 보라·인디고·남색 그림자 + 크림·라벤더 눈 + 소량의 앰버 빛, 세 무리 안에서 정리한다.
- **가장 튀는 곳을 진정시킨다:** 불 마녀의 주황 불꽃·구리색 머리·노란 옷, 산장 창문과 등불의 강한 노랑, 진한 원색 보라 모자. 색상은 유지하되 채도·명도 폭을 좁혀 주변과 어울리게.
- **빛은 남긴다.** 창문·등불·불꽃은 여전히 따뜻한 초점이지만 면적을 줄이거나 부드러운 앰버로. 화면에서 "가장 밝고 따뜻한 곳"이 한두 군데로 모이게.
- **그림자 쪽 색을 통일한다:** 그림자에 섞인 여러 색(밝은 청록·빨강·순보라)을 짙은 자두·남색 계열로 모은다. 검게 죽이지 않는다.
- **눈·하늘·크림 여백**은 지금처럼 밝고 깨끗하게 유지. 보라 하늘 구름의 강한 보라 얼룩만 조금 연하게.
- 회색으로 바래거나 탁해지면 실패. 먹선·명암 대비와 인쇄 질감은 v01 그대로 선명하게 남긴다.
- 게임의 승인 기준색(보라·인디고 설경 + 앰버 산장, [아트 가이드](../art-direction.md) "색과 정서")과 [프로토타입 승인 원화](../../art/concepts/environment/04-prototype-reference-simplified.png)의 절제된 톤을 참고한다.

## 유지할 것

v01의 인물·건물·소품·구도·얼굴·먹선·질감·UI 글자와 위치 전부. 가능하면 v01을 **편집 입력**으로 써서 색만 바뀐 같은 그림이 되게 한다(다시 그리면서 인물이 바뀌면 실패).

## 역할 분담

- **Codex 책임:** 시안 생성·후처리·비교 시트·프롬프트 기록·이 문서 납품 절.
- **수정 금지:** `godot/**` 전체, 루트 `WitchsLodge.exe`, 다른 `docs/` 문서, `art/concepts/lobby/reference-composition-v01/`, `art/concepts/lobby/game-style-v01/`(보관본, 덮어쓰기 금지). 커밋하지 말 것.

## 참고 입력

| 파일 | 쓰임 |
| --- | --- |
| `art/concepts/lobby/game-style-v01/01-story-edge.png` | 01 **편집 대상** |
| `art/concepts/lobby/game-style-v01/02-winter-inn-window.png` | 02 **편집 대상** |
| `art/concepts/environment/04-prototype-reference-simplified.png` | 절제된 보라·앰버 톤 기준 |
| `art/concepts/portraits/card-style-v01/bram-card-style-v02.png` | 화풍 유지 확인용 |

## 산출물

| 용도 | 경로 |
| --- | --- |
| 시안 2장 (1920×1080 PNG) | `art/concepts/lobby/game-style-v02/01-story-edge.png`, `02-winter-inn-window.png` |
| 생성 원본·초안 | `art/concepts/lobby/game-style-v02/drafts/` |
| 비교 시트 | `art/concepts/lobby/game-style-v02/sheet.png` — 위: v01 01 / v02 01, 아래: v01 02 / v02 02 |
| 프롬프트 기록 | `art/concepts/lobby/game-style-v02/prompts.md` |
| 설명 | `art/concepts/lobby/game-style-v02/README.md` — v01 대비 바꾼 색 목록 |

Godot 임포트·실행파일 내보내기는 하지 않는다.

## 완료 기준

1. 2장 1920×1080, v01과 같은 그림·구도·인물·UI.
2. 비교 시트를 직접 열어 봤을 때 v02가 **눈에 띄게 차분하지만 바래거나 탁하지 않다.** 주황 불·노란 창·원색 보라가 진정되고, 먹선·명암은 선명하다.
3. 한글 깨짐·추가 문구 없음.
4. 이 문서 끝에 `## Codex 납품 결과 · <날짜>` 절을 추가한다.

## Codex 납품 결과 · 2026-10-21

- [01 이야기의 가장자리](../../art/concepts/lobby/game-style-v02/01-story-edge.png), [02 겨울 산장의 창가](../../art/concepts/lobby/game-style-v02/02-winter-inn-window.png): 각각 1920×1080 RGB PNG.
- [비교 시트](../../art/concepts/lobby/game-style-v02/sheet.png): 3840×2160. 위 v01 01 / v02 01, 아래 v01 02 / v02 02.
- [README](../../art/concepts/lobby/game-style-v02/README.md)에 색 변경 목록, [prompts.md](../../art/concepts/lobby/game-style-v02/prompts.md)에 실제 입력·전체 프롬프트 3회·생성 경로·후처리를 기록했다. 생성 원본 3장은 [drafts](../../art/concepts/lobby/game-style-v02/drafts/)에 보존했다.
- 내장 image_gen으로 두 원본을 각각 편집했다. 01 초기 결과는 색 변화 부족과 미세한 선 변화로 제외했고 01 재편집·02 편집을 배색 기준으로 삼았다. 최종은 생성된 선을 사용하지 않고 v01의 같은 좌표 픽셀에 재질·색상군별 팔레트를 선택 적용해 원본 그림·얼굴·먹선·인쇄 질감·UI를 보존했다. 전체 채도 일괄 감소·회색 오버레이·대비 축소는 사용하지 않았다.
- 불꽃·구리 머리·노란 옷·창문/등불을 부드러운 앰버/오커로, 순보라를 잉크 바이올렛으로, 어두운 잡색을 자두·인디고로 묶었다. 밝은 눈·크림 여백과 짙은 먹선은 남겼다. 최종 두 장과 비교 시트를 직접 열어 색감과 보존 상태를 확인했다.
- HSL L의 최대 변화는 8비트 반올림 1/510이며, 보호한 UI·가장 짙은 먹선·밝은 크림 픽셀의 RGB 불일치는 두 장 모두 0이다. 기존 한글 6종과 선택 장식을 원본 그대로 유지했고 추가 문구가 없다. [픽셀 검수](../../art/concepts/lobby/game-style-v02/drafts/pixel-qa.json) · [해시/크기/보호 경로 검증](../../art/concepts/lobby/game-style-v02/manifest.json).
- 수정은 game-style-v02 폴더와 이 문서의 마지막 납품 절에 한정했다. 금지 경로와 기존 변경은 보존했다. Godot 실행·임포트·실행파일 내보내기 및 커밋은 하지 않았다. 사용자 최종 승인 전 검토용 시안이다.
- 보호 파일 8,378개의 전후 메타데이터 비교 중 별도 작업의 tavern 관련 문서/카탈로그/스크립트 등 6개 파일 변경을 감지했다. 이번 작업에서는 해당 파일에 쓰거나 되돌리지 않았으며 manifest의 동시 작업 변경 목록에 구분했다. v01 PNG의 전후 SHA-256 불일치는 0이다.

