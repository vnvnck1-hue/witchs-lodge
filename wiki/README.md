# 마녀산장 위키 생성기

배포 주소: https://vnvnck1-hue.github.io/witchs-lodge/

- `src/pages/*.md` — 서술 문서(위키용 마크다운). 파일명이 문서 제목, 앞머리 `title:`로 덮어쓸 수 있다.
- `src/pages/cards/<id>.md`, `src/pages/guests/<id>.md` — 카드·손님 문서에 덧붙이는 비고(선택).
- `src/build.js` — `godot/scripts/config.gd`·`chapter_data.gd`·`guest_profiles.gd`·`assets/cards/catalog.json`·`godot/README.md` 조작표를 읽어 `dist/`를 만든다.
- `src/template.html` — 미디어위키 레이아웃 껍데기와 클라이언트 라우팅·검색.

```text
cd wiki && npm install && npm run build && npm run serve   # http://localhost:8766
```

main 에 푸시하면 `.github/workflows/pages.yml` 이 자동으로 빌드·배포한다. 매크로 문법은 위키의 "마녀산장 위키:소개" 문서에 있다.
