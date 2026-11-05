from pathlib import Path
import sys
FOLDER = Path(__file__).resolve().parent
sys.path.insert(0, str(FOLDER.parent))
from _build import latex, draw
import subprocess
if "--draw" in sys.argv:
    draw(FOLDER, FOLDER / "superposition_plot_2.pdf", page=2)
subprocess.run(["Rscript", str(FOLDER / "histogram.R")], check=True)
latex(FOLDER, "superposition_and_overlap_histogram")

