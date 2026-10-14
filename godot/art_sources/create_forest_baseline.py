"""Isolated prior layout with current compatible rendering, never swaps shared source."""
from pathlib import Path
import shutil
ROOT=Path(__file__).resolve().parents[1]
REVIEW=ROOT.parent/'output/forest-composition'
OUT=REVIEW/'baseline-project';OUT.mkdir(exist_ok=True)
for folder in ['assets','scripts','scenes','shaders']:
    shutil.copytree(ROOT/folder,OUT/folder,dirs_exist_ok=True)
shutil.copy2(ROOT/'project.godot',OUT/'project.godot')
shutil.copytree(ROOT/'.godot/imported',OUT/'.godot/imported',dirs_exist_ok=True)
(OUT/'tools').mkdir(exist_ok=True)
shutil.copy2(ROOT/'tools/review_forest_composition.gd',OUT/'tools/review_forest_composition.gd')
shutil.copy2(REVIEW/'before-layout.gd',OUT/'scripts/world/layout.gd')
shutil.copy2(REVIEW/'before-exploration.gd',OUT/'scripts/world/exploration.gd')
print('FOREST_BASELINE_READY',OUT)
