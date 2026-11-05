"""Usage : python3 refaire_tout.py [numéro, nom ou fragment du nom]."""
from pathlib import Path
import subprocess
import sys
ROOT = Path(__file__).resolve().parent
(ROOT / "pdf").mkdir(exist_ok=True)
selected = sys.argv[1] if len(sys.argv) > 1 else ""
folders = [p for p in sorted(ROOT.iterdir()) if p.is_dir() and p.name[:2].isdigit() and selected in p.name]
if not folders:
    raise SystemExit("Aucune figure ne correspond : " + selected)
for folder in folders:
    script = folder / "figure.R"
    command = ["Rscript", str(script)] if script.exists() else [sys.executable, str(folder / "figure.py")]
    print("Figure :", folder.name, flush=True)
    subprocess.run(command, cwd=ROOT, check=True)

