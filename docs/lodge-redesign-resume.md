# 산장 리디자인 재개 기록

2026-10-13. 사용자의 “지금 진행하는거 멈추고, 나중에 이어서 할 수 잇게 마무리해봐” 요청에 따라 목표를 **일시정지**했다. 모델 작업 완료나 최종 승인 상태가 아니다. 실행 중인 Blender·Godot 작업은 없으며, 이 정리 과정에서 추가 생성·렌더·빌드 배포를 하지 않았다.

## 현재 상태

목표는 기존 게임의 평이한 산장을 원화처럼 매력적인 데포르메 건물로 다시 만드는 것이다. 새 정면·오른쪽·후면 시트에 이어 Blender 초기 모델까지 생성했다. 다음 재개 때는 아래 저장된 모델 생성 코드에서 시작한다. 시트 생성을 처음부터 반복할 필요는 없다.

| 구분 | 보존 상태 |
| --- | --- |
| 실행용 게임 | `build/WitchsLodge.exe`와 인접한 `WitchsLodge.pck`는 기존 v23 |
| 소스 프로젝트 | 새 산장 v24 작업 후보가 적용됨. 배포된 v23과 다름 |
| 모델 원본 | `godot/art_sources/painted_assets.blend`, 19개 에셋 컬렉션 보존 |
| 새 산장 GLB | `godot/assets/painted/starter_lodge.glb` |
| 완료 증거 | 실제 Blender 3면 렌더, 소스 게임 시작 화면, 메시 검사 및 가져오기 로그 |
| 남은 검증 | v24 패키지 내보내기, 6개 장면 확인, 실제 이동·충돌·게임 진행 검증 |

`build/WitchsLodge-before-art.pck`는 아트 교체 전 백업이며 v23 백업이 아니다. 기존 `refinement_evidence-v23.json`과 `refinement_evidence.json`은 v23 기록이다. 현재 소스 모델의 해시·검증 결과로 사용하지 않는다. `docs/art-refinement-progress.md`와 Godot README의 v23 배포 설명은 그대로 유효하다.

## 저장된 결과와 변경 파일

- [생성 디자인 시트](../art/model-sheets/lodge-redesign/02-lodge-front-right-back.png): 원화 참고 디자인이며 실제 모델 렌더나 사용자 승인본으로 표시하지 않는다. 초안·보정 프롬프트와 이미지 manifest도 보존되어 있다.
- [Blender 원본](../godot/art_sources/painted_assets.blend), [산장 GLB](../godot/assets/painted/starter_lodge.glb).
- 실제 모델 렌더: [정면](../godot/screenshots/lodge-redesign/v24-blender-front.png), [오른쪽](../godot/screenshots/lodge-redesign/v24-blender-right.png), [후면](../godot/screenshots/lodge-redesign/v24-blender-back.png).
- [실제 Godot 소스 화면](../godot/screenshots/art-refinement/v24-source-clean.png): 시작 장면, UI 끔. v24 배포 패키지의 캡처는 아니다.
- [메시 검사](../godot/art_sources/lodge-topology-v24.json): 279개 메시, 비다양체 에지 0. 이 검사는 형태의 원화 일치나 게임 동작의 통과를 의미하지 않는다.
- [산장 생성 코드](../godot/art_sources/build_lodge_redesign.py): 휜 굵은 기둥, 곡선 박공지붕·처마, 큰 접합부, 아치 문, 기단·계단·창·굴뚝, 40개 지붕 눈 패치와 용마루 눈을 생성한다.
- [환경 생성 코드](../godot/art_sources/build_painted_assets.py): 기존 본채 생성 블록 대신 새 산장 생성 코드를 호출한다. 캐릭터 생성 스크립트가 환경과 캐릭터를 함께 생성해 총 19종을 저장한다.
- [게임 재질 연결](../godot/scripts/visual/painted_models.gd): `LodgeWood`, `LodgeStone`의 색·텍스처 혼합 조정.
- [배치 코드](../godot/scripts/world/layout.gd): 새 굴뚝 입구에 맞춰 `CHIMNEY_TOP = (1.55, 5.17, -1.55)`로 조정했다.

로그는 `godot/art_sources/`의 `build-v24.log`, `render-lodge-v24.log`, `import-v24.log`, `capture-v24-source.log`에 보존되어 있다. 생성·렌더·가져오기·소스 시작 화면 캡처는 완료되었고, 가져오기와 소스 캡처 오류 로그는 비어 있다. 에셋 전체를 재생성했으므로 다른 GLB의 해시가 이전 버전과 같다고 가정하지 않는다.

## 재개할 때 먼저 수정할 부분

1. **지붕 눈의 틈 연결.** 오른쪽 실제 렌더에서 독립 눈 패치 사이에 어두운 지붕이 넓게 드러난다. 곡선 지붕 위에 얇고 닫힌 연속 눈 바탕을 추가하고, 큰 패치는 그 위에 얹어 틈을 메운다.
2. **정면·후면·처마 눈 처짐.** 정면에서 두꺼운 박공 목재가 눈 가장자리를 가린다. 목재 상단 앞쪽까지 둥글게 이어지는 눈 테두리를 만들고 아래 목재와 돌출 장식은 읽히게 남긴다. 검토했던 시작 범위는 박공 깊이 바깥쪽 Z 약 ±3.44, 처마 X 약 ±3.36이다. 확정 치수가 아니며 실제 렌더로 조정한다.
3. **눈 덩어리의 규칙성 완화.** 현재 눈이 직사각형 패드 격자로 읽힌다. 큰 불규칙 윤곽과 연결된 쌓임으로 시트에 가깝게 만든다.
4. **목재·돌 무늬 밀도 조정.** 중립 Blender 렌더의 나뭇결과 돌 텍스처가 강하다. 특히 돌마다 큰 아틀라스 무늬가 반복된다. UV 범위·연속성·재질 색을 조정해 넓은 색면을 유지하고 Blender와 게임의 차이도 확인한다.
5. 위 수정 후 실제 3면 렌더와 고정 게임 카메라로 비례·실루엣·목장 가림을 비교한다. 이후 방문자·증축·전투·용 화면과 접근·충돌을 검증한다.
6. 검증이 끝난 뒤에만 v24 PCK를 내보내고 버전별 캡처·해시 증거·배포 문서를 갱신한다. 지금은 v24 완료로 기록하지 않는다.

연속 눈 바탕과 처짐 테두리는 **계획만 작성된 상태이며 아직 구현하지 않았다.** 재개 지점은 `build_lodge_redesign.py`의 눈 생성 부분이다.

## 재개 도구와 순서

작업 폴더: `C:\Users\Loadcomplete\Documents\ChatGPT\마녀산장\witchs-lodge`.

Blender: `C:\Users\Loadcomplete\Documents\ChatGPT\3D배경 만들기\.tools\blender-4.5.9-windows-x64\blender.exe`.

소스 실행용 Godot: 프로젝트의 `.tools/Godot-4.7.2.exe`. `build/WitchsLodge.exe`는 인접한 배포 PCK를 실행하므로 소스 화면 확인용으로 사용하지 않는다.

1. 새 산장 생성 코드를 수정한다.
2. Blender 백그라운드에서 `godot/art_sources/build_character_assets.py`를 실행한다. 환경만 생성하고 끝내지 말고 캐릭터까지 포함한 19종 원본을 저장한다. `BLENDER_USER_RESOURCES`는 프로젝트의 `godot/art_sources/blender_user`로 지정한다.
3. `godot/art_sources/render_lodge_views.py`로 실제 모델의 3면을 렌더한다. 현재 스크립트의 출력 이름은 v24이므로 기존 캡처를 보존하려면 새 반복 버전 이름으로 먼저 바꾼다.
4. 소스 Godot에서 가져오기 후 시작 화면을 캡처한다. 기존 사용 인자는 `--shot=res://screenshots/art-refinement/v24-source-clean.png --scenario=start --ui=off --delay=1.0`이다. 결과 이름은 반복 버전에 맞춰 구분한다.
5. 형태 수정 후 `godot/tools/run_autoplay.gd`로 게임 진행을 확인하고 배포 패키지에서 시작·방문자·증축·전투·용 장면을 확인한다.
6. v24 패키지와 `v24-pack-clean.png` 등 검증 캡처가 준비된 후 `godot/art_sources/publish_art_review.py --version v24`로 비교·해시 증거를 갱신한다.

현재 일시정지한 목표를 사용자가 재개하라고 요청할 때 이어서 수행한다. 예약 실행이나 백그라운드 작업은 설정하지 않았다.
