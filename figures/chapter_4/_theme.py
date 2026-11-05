"""Python manuscript typography and PDF export (no R theme dependency)."""

from pathlib import Path
import shutil
import subprocess

import matplotlib.pyplot as plt
from matplotlib import font_manager


def apply_theme(axis_title_size, axis_text_size):
    font_file = Path(subprocess.run(
        ["fc-match", "-f", "%{file}", "Latin Modern Roman"],
        check=True, capture_output=True, text=True,
    ).stdout.strip())
    # Register regular, bold and italic variants, including for math labels.
    for variant in font_file.parent.glob("lmroman*.otf"):
        font_manager.fontManager.addfont(str(variant))
    font_manager.fontManager.addfont(str(font_file))
    family = font_manager.FontProperties(fname=font_file).get_name()
    plt.rcParams.update({
        "font.family": family,
        "font.size": axis_text_size,
        "axes.labelsize": axis_title_size,
        "axes.titlesize": axis_title_size,
        "xtick.labelsize": axis_text_size,
        "ytick.labelsize": axis_text_size,
        "legend.fontsize": 0.9 * axis_title_size,
        "legend.title_fontsize": axis_title_size,
        "mathtext.fontset": "custom",
        "mathtext.rm": family,
        "mathtext.it": f"{family}:italic",
        "mathtext.bf": f"{family}:bold",
        "mathtext.cal": f"{family}:italic",
        # Embed CFF OpenType glyphs as vector outlines, compatible with pdfTeX.
        "pdf.fonttype": 3,
    })


def save_and_publish(fig, output_path, name):
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    # Preserve the calibrated canvas width; tight_layout handles inner margins.
    fig.savefig(output_path)
    destination = Path(__file__).resolve().parents[2] / "manuscrit" / "images" / "chapter_4" / name
    destination.parent.mkdir(parents=True, exist_ok=True)
    if output_path.resolve() != destination.resolve():
        shutil.copy2(output_path, destination)
    print(f"Export manuscrit : {destination}")
