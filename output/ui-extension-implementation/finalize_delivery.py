from pathlib import Path
import json, hashlib, subprocess

ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

art=ROOT/'output/ui-extension-art-v01'
p=art/'manifest.json'
data=json.loads(p.read_text(encoding='utf-8'))
data['stage']='approved by user; implemented in game'
data['game_implementation_modified']=True
data['user_decision']='현재 원화 채택 후 게임에 적용'
data['implementation_report']='../ui-extension-implementation/report.html'
p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
p=art/'review/index.html'
s=p.read_text(encoding='utf-8')
s=s.replace('<b>현재 단계는 원화 검토입니다.</b> 아래 배치 화면은 기존 캡처 위에 새 원화를 놓은 미리보기이며 게임 적용 화면이 아닙니다. 채택할 방향을 결정하신 뒤 실제 부품 분리·텍스트 여백·상태별 그래픽·UI 연결을 진행합니다.', '<b>사용자 채택 완료 · 게임 적용 완료.</b> 이 페이지는 승인된 원화 기록입니다. 아래 합성 이미지는 당시 원화 검토용이며, 실제 적용 화면과 검증 결과는 <a href="../../ui-extension-implementation/report.html">게임 적용 보고서</a>에서 확인할 수 있습니다.')
s=s.replace('<b>이번에 결정하실 부분:</b> 이 먹선·크림 경계·청록 장식의 강도를 전체 확장 방향으로 채택할지, 큰 창의 달/설목 장식을 더 줄일지입니다. 새 기능이나 게임 규칙을 추가하는 제안은 포함하지 않았습니다.', '<b>사용자 결정:</b> 현재 원화 채택 후 게임에 적용. 인물 포트레이트는 기존 그림을 사용합니다.')
s=s.replace('승인 전 원화이며 런타임 UI·게임 코드·배포판은 변경하지 않았습니다.', '채택 원화 기록 · 실제 UI·배포판 반영 결과는 게임 적용 보고서 참고.')
p.write_text(s,encoding='utf-8')
p=art/'README.md'
s=p.read_text(encoding='utf-8').replace('승인 전 시안','사용자 채택 완료')
s=s.replace('- 이번 단계: 원화와 실제 화면 크기에서의 조화 검토. 게임 UI 구현·배포 변경은 사용자 디자인 결정 이후입니다.','- 사용자 결정: 현재 원화 채택 후 게임에 적용. 구현·배포판·캡처·검증은 `../ui-extension-implementation/report.html` 참조.')
p.write_text(s,encoding='utf-8')

files=[ROOT/'build/WitchsLodge.exe',ROOT/'build/WitchsLodge.pck']
files+=sorted((ROOT/'godot/assets/ui/moon_runes/extension_v01').glob('*.png'))
files+=sorted((ROOT/'godot/assets/ui/moon_runes/extension_v01/textures').glob('*.tres'))
changes=[]
for before in (OUT/'before/scripts/ui').rglob('*.gd'):
    current=ROOT/'godot/scripts/ui'/before.relative_to(OUT/'before/scripts/ui')
    if current.exists() and current.read_bytes()!=before.read_bytes():
        changes.append(str(current.relative_to(ROOT)).replace('\\','/'))
manifest={'date':'2026-10-16','status':'implemented and exported','user_decision':'현재 원화 채택 후 게임에 적용',
          'generator':'built-in image_gen','portrait_policy':'Existing PNG files and original profile bindings only; seven SHA-256 matches.',
          'files':[{'path':str(f.relative_to(ROOT)).replace('\\','/'),'bytes':f.stat().st_size,'sha256':sha(f)} for f in files],
          'changed_existing_ui_files':changes,'prior_pack':{'path':'before/WitchsLodge.pck','sha256':sha(OUT/'before/WitchsLodge.pck')},
          'tests':['verification.json','render-verification.json','packed-verification.json','guest-check/verification.json','packed-guest-check/verification.json'],
          'screenshots':'../../godot/screenshots/ui-extension-v01-build',
          'known_diagnostics':['Dummy renderer card shader diagnostics in headless runs.','Existing card ash cleanup tree lookup at verification shutdown.','Editor settings safe-save diagnostic during export; writable TEMP/TMP resolves project.binary output; packed execution verified.']}
(OUT/'build-manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
subprocess.run([__import__('sys').executable,str(OUT/'build_report.py')],check=True)
print('DELIVERY manifest and art status updated')
