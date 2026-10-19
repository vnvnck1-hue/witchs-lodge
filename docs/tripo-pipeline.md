# Tripo API 3D 모델 파이프라인 — 요청부터 게임 배치까지

2026-10-19. Claude가 Tripo3D API(v3)에 직접 모델을 요청하고, 받은 GLB를 게임 프랍으로 바꿔 숲에 배치한 뒤 헤드리스로 검증한다.
이전에는 사용자가 Tripo 웹에서 만든 GLB를 받아 손으로 적용했다([이끼 바위](user-rocks.md), [덩굴](user-vines.md), [서리 거미](frost-spider-monster.md)).

```text
프롬프트/원화 ─▶ ① Tripo 생성 ─▶ ② 임포트 ─▶ ③ 배치 ─▶ ④ 헤드리스 검증 ─▶ (⑤ 실제 화면 캡처) ─▶ ⑥ WitchsLodge.exe
                 tools/tripo/       godot/tools/      godot/tools/     godot/tools/
                 tripo.mjs          tripo_ingest.gd   tripo_place.gd   verify_tripo_props.gd
```

## 준비 — API 키(한 번)

1. <https://platform.tripo3d.ai> 에서 API 키(`tsk_…`)를 발급한다. 웹 구독 크레딧과 API 크레딧은 따로일 수 있으니 콘솔에서 잔액을 확인한다.
2. 키는 **저장소 밖**에 둔다: `%USERPROFILE%\.tripo\api_key` 파일 한 줄, 또는 환경변수 `TRIPO_API_KEY`.
3. 확인: `node tools/tripo/tripo.mjs balance`
   - 401 이면 키 또는 지역 주소 문제다. 국제판 기본 주소는 `https://openapi.tripo3d.ai`, 중국판 키는 `TRIPO_BASE_URL` 로 바꾼다.

## 한 줄로 — `make`

```text
node tools/tripo/tripo.mjs make stone-well --text "mossy stone well with a small wooden roof and bucket" ^
     --height 1.8 --label "이끼 돌우물" --group lodge_west --kind rock
```

| 옵션 | 뜻 |
| --- | --- |
| `--text` / `--image <png>` / `--multiview f,l,b,r` / `--from <폴더·GLB>` | 입력. `--from` 은 이미 받은 결과를 다시 적용(크레딧 없음). multiview 는 `-` 로 빈 면 |
| `--preset prop·character·raw` | 기본 `prop`. 프로젝트 화풍 문구(중세 기반 판타지·두꺼운 실루엣·큰 색면·낮은 무늬 밀도)와 부정 프롬프트, 면 6,000, PBR 끔을 붙인다 |
| `--height <m>` | **필수.** 게임 안 실제 높이. 마녀 약 1.6m, 산장 문 약 2.2m, 나무 4~5.5m |
| `--group <id>` | `forest_layout.json` 군집 id(예 `lodge_west`, `lodge_south`, `north_inner`). 없으면 배치하지 않고 장면만 만든다 |
| `--kind rock·decor` | `rock` = 충돌체·내비 장애물, `decor` = 지나갈 수 있는 장식 |
| `--scale`, `--count`, `--at x,z`, `--place-yaw`, `--clearance` | 배치 세부. `--at` 이 없으면 자동 자리 찾기 |
| `--yaw`, `--frost`, `--max-tex` | 임포트 세부. 모델 앞면 보정 각, 윗면 서리(기본 0.3), 텍스처 최대 픽셀(기본 1024) |
| `--dry-run` | 요청 본문만 출력(크레딧·키 불필요) |
| `--export` | 마지막에 `WitchsLodge.exe` 다시 내보내기 |

## 단계별 상세

### ① 생성 — `tools/tripo/tripo.mjs`

- v3 엔드포인트: `POST /v3/generation/{text|image|multiview}-to-model`, `GET /v3/tasks/{id}`, `POST /v3/files`(이미지 업로드), `GET /v3/account/balance`.
- 모델 버전은 v3에서 필수라 `v3.1-20260211` 을 기본으로 보낸다(`--model` 로 변경. `P1-20260311` 은 `quad`·`smart_low_poly` 불가).
- 생성 요청은 재시도하지 않는다(중복 과금 방지). 조회만 재시도한다.
- 결과: `output/tripo/<name>/` 에 `request.json`(실제 프롬프트·옵션·task id), `task.json`, `model_url.glb`, `rendered_image_url.*`.
  다운로드 URL은 약 24시간 유효하므로 놓쳤다면 `fetch <task_id> --name <name>`.
- 원화·카드처럼 프롬프트 기록이 남는다. 검수 결과가 나쁘면 같은 `request.json` 을 보고 문구를 고쳐 다시 요청한다.

### ② 임포트 — `godot/tools/tripo_ingest.gd`

GLB를 Godot 임포트 설정 없이 바로 쓰이는 자원으로 바꾼다.

- 모든 메시를 합치고 **바닥 중심 피벗**(XZ 가운데, 최저점 y=0)과 **지정 높이**로 맞춘다. 원본 UV는 그대로다.
- 원본 기본색 텍스처만 남긴다(최대 1024px, WebP 손실 압축 `PortableCompressedTexture2D`). PBR 금속·거칠기·노멀 맵은 툰 셰이더가 쓰지 않아 버린다.
- 재질은 사용자 바위·덩굴과 같은 `shaders/user_rock.gdshader` 라서 툰 명암·색 공기·윗면 서리를 똑같이 받는다.
- 결과: `assets/tripo/<id>/`(`*_mesh.res`, `*_paint<n>.res`, `*_mat<n>.tres`, `report.json`), `scenes/props/nature/<id>.tscn`.
  장면은 `nature_id` 메타를 가지므로 `Nature.asset(id)` 로 어디서든 불러 쓸 수 있다.
- id 는 `tripo_<name>` (영문 snake_case). 같은 이름으로 다시 돌리면 덮어쓴다.

### ③ 배치 — `godot/tools/tripo_place.gd` + `godot/art_sources/tripo/placements.json`

- `placements.json` 의 목록대로 `forest_layout.json` 에 부품을 넣는다. 매번 기존 `tripo_*` 부품을 지우고 다시 넣으므로 반복 실행해도 같다.
- `at` 이 없으면 군집 중심에서 가까운 순서로 **게임과 같은 규칙**을 통과하는 자리를 찾는다:
  맹독 지역(`hazard_sites.gd`) 밖, 마당 예약 공간(`Layout.in_yard_reserve`) 밖, 지도 경계 안, 길에서 `clearance`(기본 2m)+반경 이상,
  기존 나무·바위 충돌체와 겹치지 않음. 앞면(+Z)은 가장 가까운 길을 바라본다. 발밑 장식(고사리·관목)은 지운다.
- `build_forest_layout.py` 로 숲을 새로 만들면 `place_user_rocks.py` 등과 함께 `tripo.mjs place` 를 다시 돌린다.
- 숲 군집이 아닌 곳(마당 시설·적·카드 연출 등)에 쓰려면 장면만 만들고(`--group` 생략) 해당 기능 코드에서 `Nature.asset(id)` 로 불러 쓴다.
  캐릭터·움직이는 적은 리깅·애니메이션이 필요해 이 자동 배치 범위 밖이다(Tripo `/v3/animations/rig`·`retarget` 은 후속).

### ④ 헤드리스 검증 — `godot/tools/verify_tripo_props.gd`

```text
.tools/Godot-4.7.2.exe --headless --path godot --script res://tools/verify_tripo_props.gd
```

프랍마다 장면 로드·`nature_id`·바닥 피벗과 높이(±2%)·XZ 중심·삼각형 20,000 이하·재질과 텍스처,
배치마다 맹독 지역·마당 밖·길 여유, 그리고 실제 `main.tscn` 을 띄워 배치 수만큼 프랍이 생기는지 확인한다. `RESULT n/m`, 실패 시 종료 코드 1.

### ⑤ 실제 화면 확인(필요할 때만)

형태·색이 프롬프트와 맞는지, 화풍이 주변과 어울리는지는 헤드리스로 판단할 수 없다. 이때만 실제 플레이 카메라로 짧게 캡처한다.

```text
.tools/Godot-4.7.2.exe --path godot --script res://tools/preview_user_props.gd -- tripo_ tripo-preview
```

결과는 `output/tripo-preview/`. Tripo 미리보기(`rendered_image_url.*`)와 나란히 보고, 어긋나면 `--yaw`(앞면), `--height`, `--frost`, 프롬프트를 고친다.

### ⑥ 실행파일

게임에 넣었으면 마지막에 `WitchsLodge.exe` 를 다시 내보낸다(`make … --export` 또는 [CLAUDE.md](../CLAUDE.md)의 명령).

## 검증 기록

- 2026-10-19: API 키 없이 기존 Tripo GLB 두 개(이끼 바위 시트, 덩굴 바위)를 `make --from` 으로 넣어 임포트→자동 배치(`lodge_west` rock, `lodge_south` decor)→검증 15/15, 약 4초. 시험 자산과 배치는 지우고 숲 배치를 원래대로 돌렸다.
- 다중 재질 GLB(서리 거미, 표면 19개)도 표면별 텍스처로 임포트됨을 확인했다.
- Godot 4.7 헤드리스(더미 렌더러)에서 `PortableCompressedTexture2D` 는 `keep_compressed_buffer = true` 가 없으면 빈 텍스처로 저장된다 — 임포트 스크립트에 반영.
- 실제 Tripo API 호출(키 필요)은 아직 하지 않았다. 요청 본문은 `--dry-run` 으로 확인했다.

## 라이선스 메모

출시 전 Tripo 요금제의 상업 이용 조건을 확인한다(무료 요금제 생성물은 상업 이용이 제한될 수 있다. ElevenLabs 효과음과 같은 점검 대상).
