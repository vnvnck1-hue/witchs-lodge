"""Isolate existing card smoke from purely visual asset changes, no source edits."""
from pathlib import Path
import shutil
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT.parent/'output/nature-kit/baseline-project'
OUT.mkdir(parents=True,exist_ok=True)
for name in ['assets','scripts','scenes','shaders']:
    shutil.copytree(ROOT/name,OUT/name,dirs_exist_ok=True)
shutil.copy2(ROOT/'project.godot',OUT/'project.godot')
shutil.copytree(ROOT/'.godot/imported',OUT/'.godot/imported',dirs_exist_ok=True)
(OUT/'tools').mkdir(exist_ok=True)
(OUT/'art_sources').mkdir(exist_ok=True)
for name in ['verify_card_core.gd','card_core_check.gd']:
    shutil.copy2(ROOT/'tools'/name,OUT/'tools'/name)
p=OUT/'scripts/visual/models.gd'
s=p.read_text(encoding='utf-8')
s=s.replace('return Nature.pine(h, rng)','return Painted.pine(h)')
s=s.replace('return Nature.rock(size, rng)','return Painted.rock(size)')
s=s.replace('return Nature.asset("berry_shrub")','return Painted.asset("shrub")')
s=s.replace('return Nature.asset("fallen_log")','var v := Painted.asset("fallen_log")\n\tv.scale = Vector3(1.5,1.2,1.3)\n\treturn v')
p.write_text(s,encoding='utf-8')
print('BASELINE_PROJECT_READY',OUT)
