# 토끼 수인 모미 · 글래머 체형 수정 v02

2026-10-20 사용자 요청으로 채집가 모미의 체형을 더 풍만하게 수정했다. 얼굴·회갈색 털·한쪽 접힌 귀·소심한 표정·중세 복식·겨울 숲과 산장 배경, 보라색 인물 카드 프레임·발자국 배지·빈 크림 패널을 유지했다. 약초 바구니를 조금 내려 의복 위로 가슴과 허리의 곡선을 읽기 쉽게 했다.

- `generated.png`: 내장 image_gen 편집 원본, 1024×1536.
- `beastfolk-gatherer.png`: 최종 RGBA 1024×1536. RGB는 생성 결과 그대로이며 투명도만 기존 카드 외곽으로 패키징.
- `hand/gatherer.png`: RGBA 256×384 손패용.
- `before/`: 교체 전 게임용·손패용 카드 보존. 기존 `art/cards/races-v01/beastfolk-gatherer.png`도 보존.
- `manifest.json`: 크기·RGBA·투명도·SHA-256 검증.
- `package.ps1`: 알파 패키징·축소·게임 경로 복사.
- 실제 참고 입력·프롬프트: `docs/prompts/cards/momi-curvy-v02.md`.

적용 경로: `godot/assets/cards/races/beastfolk/gatherer.png`, `godot/assets/cards/races/beastfolk/hand/gatherer.png`. 카드 규칙·카탈로그·손님 포트레이트는 이번 카드 원화 수정 범위에 포함하지 않는다.

검증(2026-10-21): 최종 파일과 게임용 사본의 SHA-256 일치, 1024×1536·256×384 RGBA와 네 모서리 알파 0을 확인했다. Godot import 종료 코드 0. 모미의 `Catalog.texture_for()`가 반환하는 AtlasTexture의 원본 텍스처를 검사하여 전체 카드·손패 모두 지정한 수인 채집가 경로와 치수임을 확인했다(`output/momi-curvy-v02/momi-stdout.log`, `MOMI_RESULT=true`).

기존 `verify_race_job_cards.gd`는 8/11로 종료했다. 파일·규격·알파 검사는 통과했지만 반환 객체 자체의 `resource_path`를 원본 PNG 경로와 비교하는 3개 검사는 현재 `CardFace`의 AtlasTexture 래핑에 맞지 않는다. 이 기존 검사와 게임 코드는 변경하지 않고, 이번 모미 검증에서는 `texture.atlas.resource_path`를 확인했다. 기존 헤드리스 게임 검사에는 카드 셰이더 경고도 기록되어 있다.

실행파일: 병행 중이던 다른 세션의 Windows 내보내기와 같은 루트 임시 파일을 사용하면서 이번 세션의 내보내기 시도는 충돌했다. 기존 실행파일은 백업 후 복원했으며, 병행 내보내기가 갱신한 최종 루트 `WitchsLodge.exe`의 내장 PCK를 직접 파싱해 모미 전체 카드·손패의 임포트된 CTEX SHA-256이 현재 프로젝트 파일과 각각 일치함을 확인했다. `output/momi-curvy-v02/executable-verification.json`의 `passed=true`, 두 파일 모두 `EMBEDDED_MATCH=True`다. 다른 세션의 Godot 프로세스는 중단하지 않았다.
