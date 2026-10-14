"""Local sound review: save choices and apply only approved files to Godot."""
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import argparse
import functools
import json
import math
import os
import secrets
import shutil
import subprocess
import threading
from urllib.parse import urlsplit

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
DIST = HERE / 'dist'
SOURCE = ROOT / 'output/audio-elevenlabs-v01'
EVENTS = {'magic_bolt': ('magic-bolt', -12), 'card_play': ('card-play', -10),
          'gold_reward': ('gold-reward', -10), 'dragon_arrival': ('dragon-arrival', -8),
          'bgm_field': ('field-chill', -8), 'bgm_evening': ('evening-tension', -8),
          'ambience_day': ('forest-wind', -18), 'ambience_evening': ('forest-evening', -18)}
BACKGROUND = {'bgm_field', 'bgm_evening', 'ambience_day', 'ambience_evening'}
FILES = [f'{prefix}-0{i}.mp3' for event, (prefix, _) in EVENTS.items() if not event.startswith('bgm_') for i in range(1, 5)]
FILES += [f'{prefix}-0{i}.wav' for event, (prefix, _) in EVENTS.items() if event.startswith('bgm_') for i in (1, 2)]
SOURCES = {f: (SOURCE if f.startswith(('magic-bolt-', 'card-play-', 'gold-reward-', 'dragon-arrival-')) else ROOT / 'output/audio-field-v01') for f in FILES}
TOKEN = secrets.token_urlsafe(32)
LOCK = threading.Lock()
GAME = None


def atomic_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix('.tmp')
    temp.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')
    os.replace(temp, path)


def normalize(value):
    if not isinstance(value, dict):
        raise ValueError('선택 결과 형식이 올바르지 않습니다.')
    selected = value.get('selected', [])
    if not isinstance(selected, list) or any(f not in FILES for f in selected):
        raise ValueError('후보 목록에 없는 파일이 있습니다.')
    for event in BACKGROUND:
        prefix = EVENTS[event][0] + '-'
        if sum(f.startswith(prefix) for f in set(selected)) > 1:
            raise ValueError('BGM과 환경음은 종류마다 한 개씩 선택해 주세요.')
    volumes = value.get('volumes', {})
    if not isinstance(volumes, dict):
        raise ValueError('음량 형식이 올바르지 않습니다.')
    cleaned_volumes = {}
    for event, (_, default) in EVENTS.items():
        db = float(volumes.get(event, default))
        if not math.isfinite(db) or not -30 <= db <= 0:
            raise ValueError('음량은 -30~0 dB 범위여야 합니다.')
        cleaned_volumes[event] = db
    notes, heard = value.get('notes', {}), value.get('heard', [])
    if not isinstance(notes, dict) or not isinstance(heard, list):
        raise ValueError('메모 또는 재생 기록 형식이 올바르지 않습니다.')
    return {'schema': 1, 'selected': [f for f in FILES if f in selected],
            'notes': {f: str(notes[f])[:500] for f in FILES if f in notes},
            'heard': [f for f in FILES if f in heard], 'volumes': cleaned_volumes}


def selection():
    path = HERE / 'selection.json'
    return normalize(json.loads(path.read_text(encoding='utf-8'))) if path.exists() else normalize({})


def apply(value):
    approved = normalize(value)
    config = {'schema': 1, 'sounds': {}}
    for event, (prefix, _) in EVENTS.items():
        files = [f for f in approved['selected'] if f.startswith(prefix + '-')]
        if files:
            config['sounds'][event] = {'files': files, 'volume_db': approved['volumes'][event]}
    targets = [ROOT / 'godot/assets/audio', ROOT / 'build/audio', ROOT / 'build/audio-review/audio']
    for target in targets:
        target.mkdir(parents=True, exist_ok=True)
        for filename in approved['selected']:
            shutil.copy2(SOURCES[filename] / filename, target / filename)
        atomic_json(target / 'selected.json', config)
    atomic_json(HERE / 'selection.json', approved)
    atomic_json(HERE / 'applied.json', approved)
    count = len(approved['selected'])
    return {'ok': True, 'count': count, 'events': len(config['sounds']),
            'message': f'{count}개 후보를 게임에 적용했습니다. 게임 실행을 누르거나, 검토판 실행 중이라면 약 1초 뒤 반영됩니다.'}


class Handler(SimpleHTTPRequestHandler):
    def reply(self, value, status=200):
        data = json.dumps(value, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Cache-Control', 'no-store')
        self.send_header('Content-Length', str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == '/api/state':
            with LOCK:
                self.reply({'selection': selection(), 'token': TOKEN})
        elif self.path.startswith('/api/'):
            self.reply({'error': '없는 기능입니다.'}, 404)
        else:
            super().do_GET()

    def do_POST(self):
        global GAME
        origin = self.headers.get('Origin')
        expected = f'http://127.0.0.1:{self.server.server_port}'
        if self.headers.get('X-Review-Token') != TOKEN or (origin and origin != expected):
            self.reply({'error': '이 검토 화면에서만 실행할 수 있습니다.'}, 403)
            return
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if not 0 < length <= 32768:
                raise ValueError('선택 결과 크기가 올바르지 않습니다.')
            data = json.loads(self.rfile.read(length))
            with LOCK:
                if self.path == '/api/save':
                    atomic_json(HERE / 'selection.json', normalize(data))
                    result = {'ok': True}
                elif self.path == '/api/apply':
                    result = apply(data)
                elif self.path == '/api/launch':
                    executable = ROOT / 'build/audio-review/WitchsLodge.exe'
                    pack = executable.with_suffix('.pck')
                    if not executable.exists() or not pack.exists():
                        raise ValueError('사운드 검토용 게임 실행파일을 아직 준비하지 못했습니다.')
                    if GAME is None or GAME.poll() is not None:
                        log = open(HERE / 'game.log', 'ab')
                        try:
                            GAME = subprocess.Popen([str(executable)], cwd=executable.parent,
                                stdout=log, stderr=log, creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
                        finally:
                            log.close()
                    result = {'ok': True, 'message': '사운드 검토용 게임을 실행했습니다. F1 디버그로 전투·골드·용 소환을 빠르게 확인할 수 있습니다.'}
                else:
                    self.reply({'error': '없는 기능입니다.'}, 404)
                    return
            self.reply(result)
        except (ValueError, TypeError, OSError) as error:
            self.reply({'error': str(error)}, 400)


def prepare():
    audio = DIST / 'audio'
    audio.mkdir(parents=True, exist_ok=True)
    for filename in FILES:
        shutil.copy2(SOURCES[filename] / filename, audio / filename)
    for target in [ROOT / 'build/audio', ROOT / 'build/audio-review/audio']:
        if not (target / 'selected.json').exists():
            atomic_json(target / 'selected.json', {'schema': 1, 'sounds': {}})


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=8614)
    args = parser.parse_args()
    prepare()
    handler = functools.partial(Handler, directory=str(DIST))
    server = ThreadingHTTPServer(('127.0.0.1', args.port), handler)
    print(f'Local: http://127.0.0.1:{server.server_port}', flush=True)
    server.serve_forever()
