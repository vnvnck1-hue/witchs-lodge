# 마녀산장(Witch's Lodge) 게임 전역 지침

Godot 4.7.2 프로젝트는 `godot/`, 에디터는 `.tools/Godot-4.7.2.exe`, **게임 실행파일은 루트의 `WitchsLodge.exe` 하나**. 자세한 구조·조작·검증 기록은
[README.md](README.md)와 [godot/README.md](godot/README.md), 기능별 문서는 `docs/`.

## 모든 설정·리소스의 시대적 기준

- **사용자 확정(2026-10-17): 중세를 기반으로 일반적인 판타지 문법에 따라 어느 정도 각색할 수 있는 세계다.** 중세의 생활감과 분위기를 바탕으로 마법·종족·문화·조형을 게임에 맞게 각색한다.
- 어떤 설정·리소스를 기획·제작·수정하든 이 기준을 반드시 참고한다. 서사·대사·사회·기술·복식·건축·도구·무기·카드·3D 모델·UI 소재·음악·효과음과 제작 프롬프트·결과 검수에 공통 적용한다.
- [세계관 기획](docs/world-races-card-formats-v01.md), [아트 가이드](docs/art-direction.md), [프로젝트 공통 지침](AGENTS.md)을 따른다. 특정 실제 국가·세기·중세 세부 시기나 기술 범위는 아직 정하지 않았다.

## 카드 생성·재제작

- **카드 글자는 이미지가 아니라 게임이 그린다(사용자 확정 2026-10-20).** 원화는 제목판·설명판을 비워 글자 없이 만들고,
  문구는 `catalog.json`(`name`·`category`·`printed_rules`·`badge`)에 쓴다. 폰트는 BM 을지로체. [docs/card-text-runtime.md](docs/card-text-runtime.md).
  글자가 박힌 카드를 받았으면 `tools/card_text_strip/` 로 지운다. 절차·검증은 그 문서를 따른다.

- 작업 전에 [카드 디자인 가이드](docs/card-design-guide.md)를 읽고 해당 역할의 승인 개별 PNG를 실제 이미지 참고 입력으로 사용한다.
- 인물·스킬·자원·장비/유물·시설·사건의 고유 포맷과 1024×1536(2:3), 제목 2줄·설명 4줄 여백을 유지한다. 장식·아이콘·프레임 끝은 글 영역 밖에 둔다.
- 승인 기준은 `art/concepts/cards/roles-individual-v02/`의 최종 6장이다. 비교판·`drafts/`·빈 프레임 실험을 새 템플릿으로 사용하지 않는다. 예시 카드 문구를 새 게임 규칙으로 간주하지 않는다.

## 3D 모델 — Tripo API 파이프라인

- 새 3D 프랍이 필요하면 [Tripo 파이프라인](docs/tripo-pipeline.md)으로 Claude가 직접 요청·적용한다:
  `node tools/tripo/tripo.mjs make <name> --text "<영문 형태 묘사>" --height <m> [--group <숲 군집> --kind rock|decor] [--export]`.
  기본 `prop` 프리셋이 중세 기반 판타지·두꺼운 실루엣·큰 색면 화풍 문구를 붙이므로 프롬프트에는 대상의 형태·재료만 쓴다.
- 생성은 크레딧을 쓴다. 한 번에 여러 개를 요청하기 전에 `balance` 와 `--dry-run` 으로 확인하고, 이미 받은 결과는 `--from` 으로 재사용한다.
- API 키는 `%USERPROFILE%\.tripo\api_key` 또는 `TRIPO_API_KEY` 에만 둔다. 저장소·문서·로그에 쓰지 않는다.
- **캐릭터(애니메이션 필요)는 API 가 아니라 [캐릭터 3D 적용 프로세스](docs/character-3d-pipeline.md)를 따른다** — 사용자 확정 2026-10-19: Codex 원화 승인 → Tripo 웹(구독 크레딧, Chrome) Smart Mesh·Triangle·폴리 3~4천 → Texture → Segment Simple → Godot 묶음 임포트 → 성격에 맞는 애니메이션·배치. API 크레딧은 따로 사지 않는다.

## 테스트 원칙 — 헤드리스 우선

- **가능하면 항상 헤드리스로 검증한다.** 게임 로직·상태·노드 구성·수치·파일 존재는
  `tools/verify_*.gd`(SceneTree 스크립트)를 만들거나 확장해 다음처럼 돌린다(프로젝트 루트 기준).

  ```text
  .tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_<기능>.gd
  ```

  검증 스크립트는 `PASS/FAIL 항목` 줄과 마지막 `RESULT n/m` 을 출력하고 실패 시 종료 코드 1 을 낸다.
- **실제(창을 띄우는) 실행은 꼭 필요할 때만** 한다. 헤드리스의 더미 렌더러로는 확인할 수 없는 것 —
  셰이더 컴파일 오류, 실제 화면 결과(색·블렌딩·입자 모양), 오디오 출력 — 만 `tools/capture_*.gd` 로 짧게 캡처해 확인하고,
  캡처 결과는 `godot/screenshots/<기능>/` 에 둔다. 전체 게임을 손으로 플레이하는 식의 확인은 하지 않는다.
- 새 기능을 넣을 때는 헤드리스 검증 스크립트를 함께 추가하고, 실제 렌더 캡처를 했다면 그 이유(헤드리스로 확인 불가한 항목)를 한 줄 남긴다.

## 게임 실행파일 — 루트의 WitchsLodge.exe 하나로 통일

- **사용자 확정(2026-10-18): 게임 실행파일은 프로젝트 루트의 [WitchsLodge.exe](WitchsLodge.exe) 하나뿐이다.** 게임 데이터(pck)를 안에 넣은 단일 파일이며, 아이콘은 `godot/icon.ico`다.
- 다른 실행 경로(`build/WitchsLodge.exe`, 별도 `.pck`, `.bat` 런처 등)를 새로 만들지 않는다. `build/`에는 비교용 이전 pck 백업과 웹판만 둔다.
- **게임을 고칠 때마다 작업을 마치기 전에 이 파일을 다시 내보내**, 사용자가 더블클릭으로 바로 최신 상태를 확인할 수 있게 한다(프로젝트 루트 기준, 약 1분).

  ```text
  .tools/Godot-4.7.2.exe --headless --path godot --export-release "Windows Desktop" ../WitchsLodge.exe
  ```

  `--export-pack`은 exe를 갱신하지 못하므로 쓰지 않는다. 게임이 켜져 있으면 덮어쓰기에 실패하니 종료 후 다시 내보낸다. 마지막 보고에 이 파일 링크를 남긴다.
