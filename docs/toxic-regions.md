# 맹독 곤충 서식지

2026-10-15. Godot 4.7.2 / Forward+ 런타임에 적용.

사용자 제공 환경 레퍼런스의 청록색 석재 바닥, 짙은 남보라색 수목, 황록색 형광 균열, 옅은 독안개와 뼈를 참고했다. 곤충 레퍼런스의 네 다리, 네 장의 녹색 막날개, 갑각과 낫 형태의 발끝, 초록색 겹눈을 재구성했다.

## 지도 배치

| 서식지 | 중심 X/Z (m) | 반경 X/Z (m) | 보행 / 비행 |
| --- | --- | --- | --- |
| 맹독 균열지 | -23 / -13 | 8.0 / 6.8 | 4 / 2 |
| 독날개 군락 | 26 / -10 | 6.4 / 7.4 | 3 / 2 |
| 오염된 뿌리숲 | -4 / 28 | 6.2 / 5.4 | 3 / 1 |

모두 산장에서 떨어진 기존 탐험 지도 안에 있다. 산장에서 각 구역 중심까지 실제 내비게이션이 연결된다. 산장 방향에는 진입부를 열고, 외곽에 뒤틀린 죽은 나무·전용 석재·독초·뼈를 배치하며 안쪽에 알이 든 키틴질 둥지 세 개를 둔다. 기존 숲과 풀은 서식지 내부를 비워 새 바닥과 균열이 읽히게 했다. 탐색한 구역은 지도에 녹색 위험 영역으로 표시된다.

## 지면과 분위기

- `godot/assets/hazards/painted_toxic_slate_v1.png`: 전용 손그림 스타일 석재·흙·이끼 텍스처. 기존 바닥 셰이더 안에서 불규칙한 구역 경계로 블렌딩한다.
- 균열은 검고 깨진 가장자리와 좁은 형광 중심을 가진 별도 메시다. 구불구불한 선, 폭 변화, 끝으로 갈수록 가늘어지는 곁가지가 있다. 셰이더가 약 5.6초 주기로 날카로운 밝기 박동과 미세한 흐름을 만든다. 빛이 주변 바닥과 프랍에도 영향을 준다.
- 구역마다 균열 위에서 65개씩 재순환하는 연기 입자와 서로 다른 높이의 노이즈 안개 세 장을 사용한다.
- 플레이어 위치에 따라 부드럽게 진입·이탈한다. 조명·환경광·깊이 안개·블룸·화면 색보정을 함께 조정하고 UI 색은 보존한다. 기본 낮/밤 시계가 매 프레임 기준 조명을 다시 계산하므로 구역에서 나오면 현재 시간대의 조명으로 돌아간다.
- `toxic_kit.gd`가 모델과 전용 프랍의 메시를 만든다. 고정 조각은 재질별로 합치고, 다리와 날개 관절은 별도로 애니메이션한다.

## 생명체 행동과 전투

반경 7.5m 안의 마녀와 소환 아군을 시야 검사 후 추적한다. 대상 또는 자신이 서식지 중심에서 10.5m를 벗어나거나 대상과의 거리가 10.5m를 넘으면 개체별 원래 위치로 돌아간다. 귀환 중에는 재추적하지 않는다. 유효한 대상이 없을 때는 자기 집 주변 1.6m 안에서 짧게 배회한다.

보행형은 60HP / 2.9m/s, 비행형은 48HP / 3.25m/s. 비행형은 1.25m 높이에서 떠다니며 날개를 빠르게 움직이고, 네 다리는 접는다. 둘 다 근접 거리 1.35m에서 1.35초마다 피해 7을 준다. 마녀의 기존 자동 공격, 용의 폭발, 서리 룬과 수호 등불의 피해·감속 인터페이스에 연결되어 있다. 마법 탄환은 비행형의 실제 높이를 향한다.

피격 시 초록색 체액 방울과 작은 얼룩이 생긴다. 치명타를 받으면 큰 웅덩이와 주변 얼룩이 퍼지고, 비행형은 추락한 뒤 다리를 접은 사체로 남는다. 사체는 약 14초 뒤 사라진다. 체액은 약 60초 동안 남으며 최대 48개로 제한한다. 안개와 연기는 표시 효과이며 별도의 지속 독 피해는 추가하지 않았다.

서식지 적은 `enemies`에 포함되어 기존 공격과 HUD를 사용한다. 야간 방어 몬스터만 `wave_enemies`에 속한다. 따라서 살아 있는 서식지 곤충이 있어도 야간 웨이브는 정상적으로 끝난다. 첫 배치는 내비게이션 준비를 기다려 잘못된 좌표에 생성되지 않게 했다.

## 검증·검수

최종 결과: 소스의 위험 지역 통합 검증 통과, Forward+ 실제 렌더 검증 통과, 기존 신규 카드 22개 검사 통과, 내보낸 PCK의 리소스·15마리 배치·체액·지역 색보정 검증 통과. 최종 Forward+ 실행 로그에는 엔진/스크립트 오류가 없다. 헤드리스 실행의 카드 셰이더 진단은 실제 렌더 경로에서도 재검사해 통과했다.

`godot/tools/verify_hazard_regions.gd`는 실제 씬의 추적 이동·근접 피해·귀환 완료·귀환 중 재추적 방지·죽은 타깃 해제·감속 만료·낮/밤 화면 전환과 복원·비행체 탄환 명중·체액·추락 사망·중복 사망 방지·웨이브 종료를 검사한다. `--render`를 붙이면 실제 Forward+ 화면도 저장한다.

`godot/tools/review_hazard_regions.gd`는 세 구역의 전체 화면, 산장 대비, 낮/밤 비교와 모델 상세 화면을 만든다. 전체 구역 검수 화면은 배치가 보이도록 탐험 안개를 끈 상태이며, 모델 상세 화면은 깊이 안개도 끈 상태다. 실제 플레이에서는 기본 탐험 안개가 유지된다.

결과와 캡처: `output/toxic-regions/`. 배포 PCK에도 같은 리소스와 스크립트를 포함한다. 게임에서 `M`으로 탐험 지도를 열 수 있다.

## 텍스처 제작 기록

도구: 내장 imagegen. 생성 원본을 프로젝트의 `godot/assets/hazards/painted_toxic_slate_v1.png`로 복사했다. 프랍·곤충·균열은 Godot 메시와 셰이더로 제작했다.

최종 생성 프롬프트:

> Use case: stylized-concept. Asset type: seamless tileable square terrain albedo texture for a real-time isometric 3D fantasy game. Straight orthographic top-down flat 2D hand-painted surface filling every edge. A poisonous ancient forest floor: broad irregular cracked slate flagstone fragments and compacted dark teal soil, dusty muted turquoise stone face planes with navy and dark desaturated violet crevices, deep emerald moss stains and small sickly yellow-green lichen smears. Strong attractive Warcraft/Hearthstone painted environment texture style, broad deliberate brushwork, chunky varied stone forms of 30-120 pixels across, balanced medium-low contrast. Surface colors primarily #254c50 #326763 #415c66 #283044 with tiny #759c38 accents. NO luminous cracks (animated bright cracks are separate in-engine geometry), no glow, no fog, no cast shadows, no perspective, no trees, no objects, no bones, no letters, no border, no vignette, no large central motif. Seamlessly tiling uniform material density, equally detailed at image edges. Production-ready 1024x1024 game texture, square.
