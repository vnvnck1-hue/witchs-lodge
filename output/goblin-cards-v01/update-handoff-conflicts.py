from pathlib import Path
import json,hashlib
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'output/goblin-cards-v01'
proof=json.loads((OUT/'handoff-append.json').read_text('utf-8'))
p=ROOT/proof['path'];data=p.read_bytes();prefix=data[:proof['original_bytes']]
assert hashlib.sha256(prefix).hexdigest()==proof['original_sha256']
suffix=data[proof['original_bytes']:].decode('utf-8')
suffix=suffix.replace('39개 PNG 규격·채널·모서리 알파·SHA-256, 원본/게임용 동일성·RGB 보존·손패 균등 축소 검증 **`passed=true`**.','최초 저장 시 39개 PNG 규격·채널·모서리 알파·SHA-256, 원본/게임용 동일성·RGB 보존·손패 균등 축소 검증을 통과했다. 현재는 아래 동시 변경 때문에 최상위 **`passed=false`**, 보존된 요청서 기준 납품 세트는 **`preserved_delivery_passed=true`**다.')
suffix=suffix.replace('- **남은 문제:** 13종 모두 납품 기준 미달 사항 없음. Godot의 시스템 루트 인증서 저장소 오류 로그와 검증기의 원본 이미지 읽기 경고가 있었으나 로컬 이미지 임포트·텍스처 로드·픽셀 검증은 모두 통과했다. 다국어 동적 텍스트 구현은 이번 이미지 납품 범위 밖이다.', '- **남은 문제 · 동시 변경 보존:** 최종 검증 도중 다른 세션이 `junk_sack`·`scrap`의 게임용·손패용 4개를 교체했다. `junk_sack`은 납품 원화와 다른 그림이며, `scrap`은 제목이 요청서의 **고물**에서 **쇠붙이**로 바뀌고 원화도 달라졌다. 다른 변경을 되돌리지 말라는 지시에 따라 덮어쓰지 않았다. 따라서 현재 게임 경로는 이 요청서의 원본과 불일치하며, 해당 2종은 납품 기준 미달로 기록한다. 요청서 기준 13종은 `art/cards/goblin-v01/`, 최초 임포트 검증을 통과한 26개는 `output/goblin-cards-v01/import-project/assets/cards/`에 그대로 보존돼 있다. [현재 파일 관찰·해시](../../output/goblin-cards-v01/concurrent-conflicts.json), [요청서 원본/현재판 비교](../../output/goblin-cards-v01/concurrent-comparison.png). 나머지 11종은 기준 충족. Godot 루트 인증서 저장소 오류 로그·원본 이미지 읽기 경고는 최초 로컬 임포트·텍스처 검사 통과에 영향이 없었다.')
suffix=suffix.replace('[미리보기 시트](../../godot/screenshots/goblin-cards/sheet.png)', '[요청서 기준 납품 미리보기 시트](../../godot/screenshots/goblin-cards/sheet.png)')
p.write_bytes(prefix+suffix.encode('utf-8'))
print('Updated only own appended section with explicit two-card concurrent conflict; original prefix unchanged.')
