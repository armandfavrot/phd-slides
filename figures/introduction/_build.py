"""Compilation dans un répertoire temporaire : seuls les PDF sont conservés."""
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "pdf"
MANUSCRIPT_OUT = ROOT.parents[1] / "manuscrit" / "images" / "introduction"

def publish(pdf):
    """Copie un PDF genere vers le dossier utilise par main.tex."""
    pdf = Path(pdf)
    MANUSCRIPT_OUT.mkdir(parents=True, exist_ok=True)
    destination = MANUSCRIPT_OUT / pdf.name
    shutil.copy2(pdf, destination)
    print(destination)

def latex(folder, name, source="figure.tex"):
    folder = Path(folder)
    OUT.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="intro-tex-") as temp:
        result = subprocess.run(
            ["pdflatex", "-interaction=nonstopmode", "-halt-on-error",
             "-output-directory=" + temp, source],
            cwd=folder, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if result.returncode:
            raise RuntimeError(result.stdout)
        shutil.copy2(Path(temp) / (Path(source).stem + ".pdf"), OUT / (name + ".pdf"))
    pdf = OUT / (name + ".pdf")
    publish(pdf)
    print(pdf)

def draw(folder, destination, page=1):
    """Export Draw facultatif ; profil isolé, sans toucher à une session ouverte."""
    folder = Path(folder)
    with tempfile.TemporaryDirectory(prefix="intro-draw-") as temp:
        profile = (Path(temp) / "profile").as_uri()
        options = '{"PageRange":{"type":"string","value":"' + str(page) + '"}}'
        subprocess.run(["libreoffice", "-env:UserInstallation=" + profile,
                        "--headless", "--convert-to", "pdf:draw_pdf_Export:" + options,
                        "--outdir", temp, str(folder / "source.odg")], check=True)
        shutil.copy2(Path(temp) / "source.pdf", destination)
