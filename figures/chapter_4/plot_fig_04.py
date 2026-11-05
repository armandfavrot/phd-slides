"""Reproduire fig_04.pdf à partir des données locales du chapitre 4."""

import argparse
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from _theme import apply_theme, save_and_publish
import numpy as np
import pandas as pd
from matplotlib.ticker import MaxNLocator
SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_PATH = SCRIPT_DIR / "pdf" / "fig_04.pdf"

# Text calibration, matching the Python introduction figures at 1 linewidth.
latex_linewidth = 1
pdf_width = 28 * 72
pdf_height = 7 * 72
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

def plot_distributions(values_by_model, output_path):
    """Plot negative-flux magnitudes on a common logarithmic scale."""

    non_empty = [np.abs(values) for values in values_by_model.values() if len(values)]
    minimum = min(values.min() for values in non_empty)
    maximum = max(values.max() for values in non_empty)
    bins = np.geomspace(minimum, maximum, 21)

    fig, axes = plt.subplots(
        1, 6, figsize=(pdf_width / 72, pdf_height / 72), sharex=True, sharey=True,
        squeeze=False,
    )
    for axis, (directory, display_name) in zip(axes.flat, MODELS):
        values = np.abs(values_by_model[directory])
        if len(values):
            axis.hist(
                values, bins=bins, color="#D55E00",
                edgecolor="white", linewidth=0.8,
            )
        else:
            axis.text(
                0.5, 0.5, "No negative flux",
                ha="center", va="center", fontsize=0.45 * axis_title_size,
                transform=axis.transAxes,
            )
        axis.set_title(display_name, fontsize=0.6 * axis_title_size, pad=0.5 * axis_x_margin, fontweight="bold")
        axis.text(
            0.03, 0.93, f"n = {len(values)}",
            ha="left", va="top", fontsize=0.45 * axis_title_size,
            transform=axis.transAxes,
        )
        axis.yaxis.set_major_locator(MaxNLocator(nbins=4, integer=True))
        axis.set_xscale("log")
        axis.tick_params(labelsize=0.35 * axis_title_size)
        axis.grid(axis="y", alpha=0.25)

    fig.supylabel("Number of time steps", fontsize=0.5 * axis_title_size, x=0.015, y=0.53)
    fig.supxlabel(
        r"Magnitude of negative fluxes (kg N-NH$_3$ ha$^{-1}$ h$^{-1}$)",
        fontsize=0.6 * axis_title_size,
        y=0.07,
    )
    fig.tight_layout(rect=[0.0, 0.0, 1, 1], w_pad=0.1, pad=0.6)
    save_and_publish(fig, output_path, "fig_04.pdf")
    plt.close(fig)


def main():
    output = output_argument()
    data = pd.read_csv(SCRIPT_DIR / "data/fig_04.csv", float_precision="round_trip")
    values_by_model = {
        directory: data.loc[data["model_directory"].eq(directory), "value"].to_numpy()
        for directory, _ in MODELS
    }
    plot_distributions(values_by_model, output)
    print(f"Figure enregistrée : {output.resolve()}")


if __name__ == "__main__":
    main()
