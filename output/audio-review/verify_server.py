"""Validate approval application in an isolated workspace, preserving real decisions."""
from pathlib import Path
import importlib.util
import json
import shutil
import tempfile

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('review_server', HERE / 'server.py')
server = importlib.util.module_from_spec(spec)
spec.loader.exec_module(server)
checks = []


def check(name, passed):
    checks.append({'check': name, 'passed': bool(passed)})
    assert passed, name


with tempfile.TemporaryDirectory(prefix='approval-test-', dir=HERE) as folder:
    server.ROOT = Path(folder)
    server.HERE = Path(folder) / 'review'
    server.HERE.mkdir()
    data = {'selected': ['magic-bolt-01.mp3', 'magic-bolt-03.mp3', 'dragon-arrival-02.mp3'],
            'volumes': {'magic_bolt': -18, 'dragon_arrival': -9}, 'notes': {'magic-bolt-01.mp3': '선호'}}
    result = server.apply(data)
    config = json.loads((server.ROOT / 'godot/assets/audio/selected.json').read_text(encoding='utf-8'))
    check('only approved event types applied', set(config['sounds']) == {'magic_bolt', 'dragon_arrival'})
    check('multiple approved variants preserved', len(config['sounds']['magic_bolt']['files']) == 2)
    check('preview gain matches game gain', config['sounds']['magic_bolt']['volume_db'] == -18)
    check('source and both game outputs receive selection', all((server.ROOT / p / 'selected.json').exists() for p in ['godot/assets/audio', 'build/audio', 'build/audio-review/audio']))
    check('approved MP3 bytes match source', (server.ROOT / 'build/audio-review/audio/magic-bolt-01.mp3').read_bytes() == (server.SOURCE / 'magic-bolt-01.mp3').read_bytes())
    check('no unapproved files copied', not (server.ROOT / 'build/audio-review/audio/gold-reward-01.mp3').exists())
    server.apply({'selected': ['card-play-01.mp3', 'field-chill-01.wav', 'forest-wind-02.mp3']})
    field = json.loads((server.ROOT / 'godot/assets/audio/selected.json').read_text())
    check('field music and nature layer can accompany existing effects', set(field['sounds']) == {'card_play', 'bgm_field', 'ambience_day'})
    check('original BGM WAV copied without conversion', (server.ROOT / 'build/audio-review/audio/field-chill-01.wav').read_bytes() == (server.SOURCES['field-chill-01.wav'] / 'field-chill-01.wav').read_bytes())
    server.apply({'selected': []})
    check('deselecting all clears active sounds', json.loads((server.ROOT / 'godot/assets/audio/selected.json').read_text())['sounds'] == {})
    for bad in [{'selected': ['../../outside.mp3']}, {'volumes': {'magic_bolt': 50}}, {'volumes': {'magic_bolt': float('nan')}}, {'selected': ['field-chill-01.wav', 'field-chill-02.wav']}]:
        rejected = False
        try:
            server.normalize(bad)
        except ValueError:
            rejected = True
        check('invalid filename or volume rejected', rejected)
(HERE / 'server-verification.json').write_text(json.dumps({'passed': True, 'checks': checks}, indent=2), encoding='utf-8')
print(f'{len(checks)} server checks passed')
