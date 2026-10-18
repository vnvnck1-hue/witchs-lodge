# 프롤로그 모션 코믹스 제작 검증

이 폴더의 제작 스크립트는 허용된 에셋 경로 안에서만 PNG 크기 정규화, 알파 8/255 트림, 매니페스트 작성, 가산 합성 미리보기 및 해시 검증을 수행한다. 일러스트 원본은 내장 image_gen으로 생성한다.

## v02 제작 도구

- `generation-index-v02.json`: 실제 생성 프롬프트·참고 이미지·원본 경로·저장 경로·배치 이력. v01 인덱스는 보존한다.
- `ImagePipeline.cs`: PNG RGB/RGBA 정규화, alpha > 8 트림, additive/normal 합성, 화면 영역 (192,108,1920,1080) 추출.
- `build-assets.ps1`: 에셋과 매니페스트, 4개 기본 미리보기 및 컷 2 점등·컷 4 노을 보조 미리보기 생성.
- `contact-sheet.ps1`: 4개 컷과 파일명 표시 레이어 썸네일 작성.
- `verify-assets.ps1`: 명세 id·크기·PNG 채널·알파·좌표·혼합 모드·SHA-256 및 Godot 임포트 종료 코드 검사.
- `protected-before.json`: 작업 시작 시 수정 금지 파일 해시. 동시 작업자의 변경은 되돌리지 않는다.

PowerShell 실행 정책이 제한된 이 환경에서는 시스템 PowerShell의 프로세스 한정 `-ExecutionPolicy Bypass -File`로 위 로컬 제작 스크립트를 실행한다. 시스템 정책이나 프로젝트 코드는 바꾸지 않는다.

`cutN_master-v02.png`는 생성 직후 검수용 마스터(컷 1·2·4), `cut3_master-generated.png`는 보존한 승인 마스터다. `cutN_master.png`는 납품 레이어로 다시 합성한 캔버스 크기 검수본이다. 생성형 분리 결과는 원본 마스터의 픽셀 복제가 아니므로 두 종류를 구분해 보존한다.

노을/밤은 새로 그린 노을 플레이트의 색을 밤 플레이트에 옮겨 지형 좌표가 같은 두 배경으로 납품한다. 눈빛 한 쌍은 같은 원화를 크기·위치가 다른 독립 PNG로 재사용한다. 글로우는 조명만 있으며 JSON에서 `add`를 지정한다.

허용된 출력: `art/concepts/ftue-motion-v01/`, `godot/assets/ui/ftue/motion/`, `godot/screenshots/ftue/motion/`, `output/ftue-motion-v01/`, 프롬프트 기록과 v02 인계 문서. 게임 코드·기존 폴백 PNG는 쓰기 대상이 아니다. 최신 사용자 프로젝트 지침에 따라 납품 후 루트 `WitchsLodge.exe`도 PCK 내장 단일 파일로 다시 내보낸다.

## 2026-10-18 이어서 납품

- `build-assets.ps1`은 기본적으로 컷 1·2·4만 처리한다. 컷 3 PNG·JSON·미리보기는 읽기 전용으로 보존하고 최종 `layout.json`에는 기존 매니페스트를 읽어 포함한다. `-Cuts 1` 또는 `-Cuts 4`로 해당 컷만 다시 만들 수 있다.
- `sync-index.ps1`은 `resume-generated-index.json`의 생성 기록을 기존 인덱스와 병합하고 최종 배치를 적용한다. 넓은 마스터 위치를 유지하는 투명 레이어, 창 유리에 맞춘 빛 트림, 약한 눈밭 반사광을 지원한다.
- `protected-resume-before.json`은 이번 이어서 작업 직전 해시다. 컷 3 관련 34개 파일을 그대로 보존했는지 별도로 검사한다. 다른 프로세스의 게임 스크립트 변경은 검증 JSON에 관찰 결과로 기록하고 되돌리지 않는다.
- `run-godot-checks.ps1`은 프로젝트 안에 임시 사용자 데이터를 두고 임포트·기존 타임라인 검증·컷 1·2·4 렌더를 실행한다. `capture-review.gd`는 기존 컷 3 캡처를 덮어쓰지 않는다.
- `verify-assets.ps1`의 `passed`는 에셋 형식·매니페스트·미리보기 재합성·임포트와 컷 3 보존의 결과다. 게임 코드 전체의 해시 불변을 뜻하지 않는다.
- `resume-prompts.md`와 본 프롬프트 문서에 이번 실제 내장 image_gen 호출을 기록했다. 원본 생성 이미지와 승인 마스터, 미채택 이전 분리본은 보존한다.
