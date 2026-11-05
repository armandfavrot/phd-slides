"""Compile the TikZ overview and export it to the manuscript image folder."""
from pathlib import Path
import sys

FOLDER = Path(__file__).resolve().parent
sys.path.insert(0, str(FOLDER.parent))
from _build import latex

latex(FOLDER, "thesis_overview")
