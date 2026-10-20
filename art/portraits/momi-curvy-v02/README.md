# 모미 포트레이트 체형 갱신과 수줍은 포즈 v02

2026-10-21 사용자 요청: 최신 카드의 풍만한 체형에 맞춰 포트레이트도 갱신하고, 팔로 가슴 앞을 살짝 가리는 수줍은 포즈를 별도로 제작.

사용자가 API 요청을 철회하고 일반 작업 방식으로 변경하여 내장 image_gen 편집을 사용한다. API는 호출하지 않았다.

입력 기준:
- `godot/assets/portraits/guest_momi_cutout.png`: 기존 얼굴·의상·소품과 상반신 구도.
- `art/cards/momi-curvy-v02/beastfolk-gatherer.png`: 최신 체형과 크림색 블라우스·의상·인물 정체성.
- `art/portraits/card-style-v01/bram.png`: 승인된 먹선·명암·페인터리 질감과 상반신 하단 마감.

기본 포트레이트는 바구니를 허리 쪽으로 낮춘 포즈로 게임의 기존 모미 포트레이트를 교체한다. 추가 포즈는 옷을 입은 상태에서 한쪽 팔을 가슴 앞에 가볍게 모으는 수줍은 제스처이며 별도 파일로 보존한다. 귀·양쪽 어깨·팔꿈치·손·소품 전체가 프레임에 들어오도록 사방에 투명 여백을 확보한다.

내장 image_gen 편집으로 두 포즈를 제작했다. 생성본은 `sources/`에 그대로 보존하며, 전체 캔버스 비율을 유지한 축소와 투명 여백 배치만으로 최종 1122×1402 RGBA 포트레이트를 만들었다. 그림을 자르거나 팔·소품을 재배치하는 후처리는 하지 않았다.

- `momi-base.png`: 기본 포트레이트, 바구니를 허리로 낮춘 포즈. `godot/assets/portraits/guest_momi_cutout.png`에 적용.
- `momi-shy.png`: 한쪽 팔로 옷을 입은 가슴 앞을 살짝 가리는 수줍은 포즈. 별도 대안으로 보존하며 게임의 자동 표정·포즈 전환 규칙은 추가하지 않음.
- `before/guest_momi_cutout.png`: 교체 전 게임 포트레이트.
- `sources/momi-base-generated.png`, `sources/momi-shy-generated.png`: 생성 원본.
- `package.ps1`: 비율 유지 패키징·검수·게임 복사.
- `manifest.json`, `alpha-verification.json`: 파일·해시·실제 알파 검사.
- 실제 프롬프트: `docs/prompts/momi-portrait-curvy-v02.md`, `docs/prompts/momi-portrait-shy-v02.md`.

두 파일 모두 RGBA 1122×1402, 완전 투명 외곽과 사방 6% 이상 여백을 통과했다. 기본 여백(좌·상·우·하)은 125·112·123·104px, 수줍은 포즈는 128·113·130·104px이며 외곽 최댓값 알파는 모두 0이다. 기본 포트레이트와 게임용 PNG의 SHA-256도 일치한다. 기존 `art/portraits/card-style-v01/races/momi.png`는 제작 이력으로 보존한다.

최종 사용자 지시: 실행파일 패키징 없이 이미지만 납품하고 종료. 진행 중이던 Windows 내보내기는 이 지시에 따라 중단했다. 이미지 파일 제작·검수와 게임 소스의 기본 포트레이트 PNG 교체까지 완료됐으며, 이번 변경의 실행파일 배포는 완료하지 않았다.
