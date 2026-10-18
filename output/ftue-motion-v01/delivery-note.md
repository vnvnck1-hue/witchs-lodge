
## Codex 납품 결과 · 2026-10-18

요청된 순서의 에셋 작업을 완료했다. 이미지 제작은 내장 `image_gen`을 사용했고, 기존 `output/ftue-motion-v01/` 제작 스크립트를 재사용·보완했다. 게임 코드와 기존 폴백·타이틀·마녀 초상 PNG는 수정하지 않았으며 커밋하지 않았다.

- **컷 1:** `witch_fore`를 승인 마스터의 넓은 망토 실루엣으로 재분리했다. 화면 오른쪽·아래로 잘리는 큰 전경을 복원했고 실제 8.4초(1.12배 줌·오른쪽 이동 후) 렌더에서 충분한 전경 비중을 확인했다. 세 작은 마녀는 눈길로 옮겨 발을 맞췄으며 `witch_3`은 마을과 떨어뜨렸다. 마을은 600×180, 연기는 1050×560 배치로 키웠다.
- **컷 2:** 12개 레이어와 매니페스트를 완성했다. `lodge`의 창 유리는 불 꺼진 상태이며 연기가 본체에 들어 있지 않다. `window_glow`는 창 유리의 앰버 빛·약한 반사광만 있는 RGBA이며 `add`다. 승인 마녀의 후드·물결머리·크림 드레스·철제 등불을 맞추고, 등불 빛·좌우 전경 둥치·앞쪽 눈바위·안개를 분리했다.
- **컷 4:** 최종 `cut4_master-v02.png`를 참고 입력으로 13개 레이어와 매니페스트를 완성했다. 노을·밤 배경은 같은 밤 플레이트의 좌표를 유지한 색상 전달 방식이며 지형을 다시 그리거나 변형하지 않았다. 계단을 오르는 나그네·문을 두드리는 나그네·큰 전경 나그네와 거미 다리·머리·숲 눈빛을 각각 분리했다. 전경 나그네와 거미 다리는 합성 후 크기를 보정해 마스터의 깊이 차이를 맞췄다.
- **컷 3 보존:** 원화·런타임 PNG·JSON·기존 미리보기와 캡처 등 관련 **34개 파일의 SHA-256이 이어서 작업 직전과 같다.** 빌드 스크립트는 컷 3 출력을 금지한다.
- **틀:** `godot/assets/ui/ftue/motion/panel_frame.png` — RGBA 1920×1080, 먹선 물결 가장자리, 내부 완전 투명, 최대 침범 70px.

### 납품 경로

- 런타임 레이어·틀과 매니페스트: [motion 폴더](../../godot/assets/ui/ftue/motion/) — 전체 **44 PNG(43개 레이어 + 틀), 4개 JSON**. 이 중 컷 3의 9 PNG·JSON은 보존본이다.
- 검수: [컨택트 시트](../../godot/screenshots/ftue/motion/contact-sheet.png), `cut1_preview.png`, `cut2_preview.png`(창문 꺼짐), `cut2_lit_preview.png`, `cut4_preview.png`(밤), `cut4_dusk_preview.png`. 기존 컷 3 미리보기도 컨택트 시트에 읽어서 포함했다.
- 실제 게임 렌더: `godot/screenshots/ftue/motion/review-cut1-02.6.png`·`review-cut1-08.4.png`, `review-cut2-04.0.png`·`review-cut2-05.6.png`, `review-cut4-03.4.png`·`review-cut4-06.4.png`. 컷 3 캡처는 다시 쓰지 않았다.
- 생성 원본·승인 마스터·레이어 재합성 마스터: `art/concepts/ftue-motion-v01/`. 승인 `cutN_master-v02.png`와 분리본 합성 `cutN_master.png`는 구분해 보존한다. 생성형 분리본은 승인 마스터의 픽셀 복제본이 아니다.
- 실제 프롬프트·참고 입력·생성 경로: [프롬프트 기록](../prompts/ftue/prologue-motion-comics-v01-prompts.md)의 “v02 이어서 제작”, `output/ftue-motion-v01/resume-generated-index.json`. 최종 배치는 `generation-index-v02.json`·`layout.json`과 제작 스크립트에 남겼다.

### 검증

- [asset-verification.json](../../output/ftue-motion-v01/asset-verification.json): **`passed=true`**. 파일별 크기·RGB/RGBA·알파·트림 경계(alpha > 8)·SHA-256·매니페스트 id·좌표·혼합 모드·임포트 메타데이터를 검사했다.
- 4개 레이어 재합성 마스터와 화면 크롭 미리보기의 픽셀 차이는 모두 0이다. 승인 생성 마스터와의 대조는 시각 검수이며 픽셀 일치를 주장하지 않는다.
- Godot `--import` **종료 코드 0**. 기존 `verify_prologue_motion.gd` **72/72 통과, 종료 코드 0**. 컷 1·2·4 실제 렌더 **종료 코드 0**, 레이어 모드와 창문 점등 전후·줌·거미 등장 확인.
- 작업 중 다른 프로세스에 의한 게임 스크립트 변경 **6건**이 해시 비교에서 관찰되었다. 해당 파일은 이 에셋 파이프라인의 쓰기 대상이 아니며 변경을 되돌리지 않았다. 목록은 검증 JSON의 `continuation_protection.concurrent_source_changes`에 있다. 따라서 `passed`는 게임 코드 전체의 해시 불변을 뜻하지 않는다.
- 엔진 stderr의 Windows 루트 인증서 저장소 접근 메시지는 로컬 실행 환경의 메시지다. 임포트·타임라인 검증·렌더는 정상 종료했고 모션 에셋 누락·텍스처 로드 실패는 없었다.


- **실행파일 갱신 미확정:** 루트 `WitchsLodge.exe` 대상 공식 릴리스 내보내기는 PCK 완성 후 최종 임시 파일 교체에서 실패했다(종료 코드 1). 다른 카드 작업의 동일 경로 내보내기도 진행되어 해당 작업을 중단하지 않았다. 그 별도 프로젝트의 44 PNG·4 JSON이 이번 납품과 SHA-256까지 같음은 확인했다(`concurrent-export-assets.json`). 자동 승인 검토는 동시 내보내기 중 임시 실행파일 복사를 불완전·충돌 파일 위험으로 거절했다. 기존 실행파일을 최신으로 갱신했다고 주장하지 않는다. 게임 에셋 납품·임포트·검수는 위 결과대로 완료이며, 실행파일 교체는 동시 내보내기 종료 후 별도 확인이 필요하다.
