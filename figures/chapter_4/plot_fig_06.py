"""Reproduire fig_06.pdf à partir des données locales du chapitre 4."""

import argparse
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from _theme import apply_theme, save_and_publish
import numpy as np
import pandas as pd
import seaborn as sns
SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_PATH = SCRIPT_DIR / "pdf" / "fig_06.pdf"

# Text calibration, matching the Python introduction figures at 1 linewidth.
latex_linewidth = 1
pdf_width = 13 * 72
pdf_height = 6 * 72
layout_ratio = 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size = reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.8 * axis_title_size
axis_y_margin = 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin = 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin = 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
apply_theme(axis_title_size, axis_text_size)

MODELS = [
    ("01_benchmark", "Benchmark"),
    ("02_non_bidi", "Unidirectional"),
    ("03_e_rel", "Relative emission"),
    ("04_j_nh3", "Flux"),
    ("06_e_rel_and_j_nh3", "Joint"),
    ("05_physique", "Reservoir"),
]

def output_argument():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=OUTPUT_PATH,
                        help="Chemin du PDF de sortie.")
    output = parser.parse_args().output
    output.parent.mkdir(parents=True, exist_ok=True)
    return output

def plot_boxplot(results, output_path):
    order = [label for _, label in MODELS]
    fig, axis = plt.subplots(figsize=(pdf_width / 72, pdf_height / 72))
    np.random.seed(42)

    sns.boxplot(
        data=results,
        x="model",
        y="mae",
        order=order,
        color="#56B4E9",
        width=0.58,
        linewidth=1.3,
        showfliers=False,
        ax=axis,
    )
    sns.stripplot(
        data=results,
        x="model",
        y="mae",
        order=order,
        color="#1F1F1F",
        size=5,
        jitter=0.12,
        alpha=0.8,
        ax=axis,
    )

    axis.set_xlabel("")
    axis.set_ylabel(r"MAE (kg N-NH$_3$ ha$^{-1}$)", fontsize=0.7 * axis_title_size, labelpad=axis_y_margin)
    axis.tick_params(axis="x", labelsize=0.65 * axis_text_size)
    plt.setp(axis.get_xticklabels(), rotation=0, ha="center")
    axis.tick_params(axis="y", labelsize=0.7 * axis_text_size)
    axis.grid(axis="y", alpha=0.25)
    axis.set_axisbelow(True)
    fig.tight_layout()
    save_and_publish(fig, output_path, "fig_06.pdf")
    plt.close(fig)


def main():
    output = output_argument()
    results = pd.read_csv(SCRIPT_DIR / "data/fig_06.csv", float_precision="round_trip")
    plot_boxplot(results, output)
    print(f"Figure enregistrée : {output.resolve()}")


if __name__ == "__main__":
    main()
