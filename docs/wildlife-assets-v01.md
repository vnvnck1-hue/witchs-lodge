# 야생 동물 에셋 v01

2026-10-15 · [직업 업데이트 요청서](handoff/codex-jobs-update-v01.md). Blender 5.2.2 LTS 직접 제작, Godot 4.7.2 임포트/렌더 확인.

| 대상 | GLB | Godot 래퍼 | 길이 | 높이 | 삼각형 |
| --- | --- | --- | --- | --- | --- |
| 토끼 | [rabbit.glb](../godot/assets/nature/rabbit.glb) | [rabbit.tscn](../godot/scenes/props/nature/rabbit.tscn) | 0.45m | 0.35m | 2,528 |
| 사슴 | [deer.glb](../godot/assets/nature/deer.glb) | [deer.tscn](../godot/scenes/props/nature/deer.tscn) | 1.50m | 어깨 약 1.10m / 뿔 포함 1.60m | 2,548 |

[원본 wildlife.blend](../godot/art_sources/wildlife.blend)에는 rabbit·deer 컬렉션이 있으며 편집 편의를 위해 나란히 놓았다. 각각 루트 아래 Body와 Head 피벗을 편집할 수 있다. 원본에서 사슴 피벗 이름은 Blender의 전역 이름 중복 방지를 위해 Body_deer/Head_deer이며 내보낸 두 GLB는 모두 정확히 Body/Head다.

Godot에서 두 GLB와 래퍼의 노드 경로는 `Body`, `Body/Head`다. 일반 정적 프랍의 Model 중간 노드와 달리 동물 래퍼는 GLB 루트를 상속해 현재 게임의 `get_node("Body/Head")` 규약을 유지한다. 머리 피벗을 X축 +0.45rad 돌리면 고개를 숙인다. Body는 지면 원점에 있으므로 Y 이동으로 몸·머리·다리 전체가 함께 움직인다. 애니메이션 트랙이나 스크립트가 필요하지 않다.

1단위=1m, +Y 위, +Z 정면, 발 접점 Y=0, 루트 위치/회전=0·스케일=1. 각 동물은 몸/머리 2메시·메시당 1표면이며 텍스처가 없다. 토끼는 회갈색과 흰 배, 사슴은 적갈색과 흰 배/꼬리 및 상아색 뿔이다. 기존 자연물 키트의 Col 코너 버텍스 색과 같은 평면 색 방식을 사용한다. 래퍼는 기존 `nature_paint.tres`를 공유하고 바람 재질을 쓰지 않는다. 기존 재질/셰이더를 수정하지 않았다.

재제작: Blender `--background --python godot/art_sources/build_wildlife.py` → [파이프라인](../godot/art_sources/run_jobs_asset_pipeline.ps1). Godot 사용자 캐시는 output/jobs-update-v01/runtime 아래로 분리하며 필요한 실행 파일은 프로젝트 .tools/Godot-4.7.2.exe다.

[Blender 검사](../output/jobs-update-v01/wildlife-blender-verification.json): 비매니폴드 엣지·퇴화 면 0. [Godot 검사](../output/jobs-update-v01/asset-verification.json): GLB와 tscn 각 2개 로드, 실제 치수·발 접점·Body/Head 경로·버텍스 색·공유 재질·Body/Head 동작 통과. [idle 렌더](../output/jobs-update-v01/wildlife-godot-idle.png) · [숙임 렌더](../output/jobs-update-v01/wildlife-godot-grazing.png). 두 렌더 모두 RTX 3060 Forward+ 실물이다.

상세 형상 검토: [토끼 정면](../output/jobs-update-v01/rabbit-front.png) · [측면](../output/jobs-update-v01/rabbit-side.png) · [후면](../output/jobs-update-v01/rabbit-rear.png), [사슴 정면](../output/jobs-update-v01/deer-front.png) · [측면](../output/jobs-update-v01/deer-side.png) · [후면](../output/jobs-update-v01/deer-rear.png). 이 이미지는 실제 납품 메시의 Blender 렌더다.
