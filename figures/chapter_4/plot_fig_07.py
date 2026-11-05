"""Reproduire la comparaison des MAE selon la population d'entraînement."""

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
OUTPUT_PATH = SCRIPT_DIR / "pdf" / "fig_07.pdf"

# Full-width calibration, with the same text proportions as figure 6.
latex_linewidth = 1
pdf_width = 10 * 72
pdf_height = 2.5 * 72
layout_ratio = 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size = reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.8 * axis_title_size
axis_x_margin = 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
apply_theme(axis_title_size, axis_text_size)

EXPERIMENTS = [
    ("05_physique", "with micromet. trials", "#A8D5BA"),
    ("05_physique_4", "with all trials", "#F4B6C2"),
]


def plot_comparison(data, output):
    labels = [label for _, label, _ in EXPERIMENTS]
    palette = {label: color for _, label, color in EXPERIMENTS}
    fig, ax = plt.subplots(figsize=(pdf_width / 72, pdf_height / 72), layout="constrained")
    sns.boxplot(data=data, x="mae", y="training_population", order=labels,
                hue="training_population", palette=palette, legend=False,
                dodge=False, width=.5, showfliers=False, ax=ax)
    np.random.seed(42)
    sns.stripplot(data=data, x="mae", y="training_population", order=labels,
                  color="#1F1F1F", size=5, jitter=.12, alpha=.8, ax=ax)
    ax.set(ylabel="")
    ax.set_xlabel(r"Test-set MAE (kg N-NH$_3$ ha$^{-1}$)",
                  fontsize=0.7 * axis_title_size, labelpad=axis_x_margin)
    ax.tick_params(axis="x", labelsize=0.7 * axis_text_size)
    ax.tick_params(axis="y", labelsize=0.75 * axis_text_size)
    ax.grid(axis="x", alpha=.25)
    ax.set_axisbelow(True)
    save_and_publish(fig, output, "fig_07.pdf")
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=OUTPUT_PATH,
                        help="Chemin du PDF de sortie.")
    output = parser.parse_args().output
    output.parent.mkdir(parents=True, exist_ok=True)
    data = pd.read_csv(SCRIPT_DIR / "data/fig_07.csv", float_precision="round_trip")
    plot_comparison(data, output)
    print(f"Figure enregistrée : {output.resolve()}")


if __name__ == "__main__":
    main()
