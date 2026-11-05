from pathlib import Path
import sys
FOLDER = Path(__file__).resolve().parent
sys.path.insert(0, str(FOLDER.parent))
from _build import latex, draw
latex(FOLDER, "nitrogen_cycle")

