"""Reproduire fig_05.pdf à partir des données locales du chapitre 4."""

import argparse
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from _theme import apply_theme, save_and_publish
import numpy as np
import pandas as pd
from matplotlib.lines import Line2D
from matplotlib.ticker import PercentFormatter
SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_PATH = SCRIPT_DIR / "pdf" / "fig_05.pdf"

# Text calibration, matching the Python introduction figures at 1 linewidth.
latex_linewidth = 1
pdf_width = 17 * 72
pdf_height = 18 * 72
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

ORIGINS = {
    "cat": ("Cattle slurry", "#0072B2"),
    "pig": ("Pig slurry", "#D55E00"),
}
EXCLUDED_METHODS = {"bsth", "cs"}

def output_argument():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=OUTPUT_PATH,
                        help="Chemin du PDF de sortie.")
    output = parser.parse_args().output
    output.parent.mkdir(parents=True, exist_ok=True)
    return output

def method_label(method):
    if method == "bc + deep immediate incorporation":
        return "bc + deep incorp."
    return method

def plot_comparison(
    dynamics_by_model,
    output_path,
    trajectory_columns,
    trajectory_alpha,
    trajectory_linewidth,
):
    """Create the model-by-method grid and save it as PDF."""

    first = dynamics_by_model[MODELS[0][0]]
    methods = (
        first[["method", "method_order"]]
        .drop_duplicates()
        .loc[lambda data: ~data["method"].isin(EXCLUDED_METHODS)]
        .sort_values("method_order")["method"]
        .tolist()
    )
    if not methods:
        raise ValueError("Aucune méthode d'application trouvée.")

    expected_methods = set(methods)
    for directory, _ in MODELS:
        found = set(dynamics_by_model[directory]["method"].unique()).difference(
            EXCLUDED_METHODS
        )
        if found != expected_methods:
            raise ValueError(
                f"Méthodes incompatibles pour {directory}: "
                f"attendu {sorted(expected_methods)}, trouvé {sorted(found)}"
            )

    fig, axes = plt.subplots(
        nrows=len(MODELS),
        ncols=len(methods),
        figsize=(pdf_width / 72, pdf_height / 72),
        sharex=True,
        sharey=True,
        squeeze=False,
    )

    for row, (directory, display_name) in enumerate(MODELS):
        dynamics = dynamics_by_model[directory]
        for column, method in enumerate(methods):
            axis = axes[row, column]
            method_data = dynamics.loc[dynamics["method"].eq(method)]

            for origin, (_, color) in ORIGINS.items():
                origin_data = method_data.loc[
                    method_data["fer_origin_origin"].eq(origin)
                ]
                for _, trajectory in origin_data.groupby(
                    trajectory_columns, sort=False
                ):
                    axis.plot(
                        trajectory["ct_origin"],
                        trajectory["prediction_e_rel"],
                        color=color,
                        alpha=trajectory_alpha,
                        linewidth=trajectory_linewidth,
                        # Keep faint trajectories vectorial: rasterized PDF
                        # layers can make these thin, transparent lines patchy.
                        rasterized=False,
                    )

                median = origin_data.groupby(
                    "ct_origin", as_index=False
                )["prediction_e_rel"].median()
                axis.plot(
                    median["ct_origin"],
                    median["prediction_e_rel"],
                    color=color,
                    linewidth=2.0,
                )

            axis.axhline(0, color="black", linewidth=0.65, alpha=0.5)
            axis.grid(alpha=0.2, linewidth=0.6)
            axis.yaxis.set_major_formatter(PercentFormatter(xmax=1))
            axis.tick_params(axis="both", labelsize=0.50 * axis_title_size)

            if row == 0:
                axis.set_title(method_label(method), pad=axis_x_margin, fontsize=0.65 * axis_title_size)
            if column == 0:
                axis.set_ylabel(
                    display_name.replace("Relative emission", "Relative\nemission"),
                    fontsize=0.62 * axis_title_size, fontweight="bold", labelpad=axis_y_margin
                )

    legend_handles = [
        Line2D([0], [0], color=color, linewidth=2.5, label=label)
        for label, color in ORIGINS.values()
    ]
    fig.legend(
        handles=legend_handles,
        loc="lower center",
        ncols=len(legend_handles),
        frameon=False,
        bbox_to_anchor=(0.55, 0.01),
        fontsize=0.7 * axis_title_size,
    )
    fig.supylabel(
        "Relative emissions (% of applied TAN)",
        x=0.025,
        y = 0.55,
        fontsize=0.8 * axis_title_size,
    )
    fig.supxlabel("Time since application (h)", fontsize=0.8 * axis_title_size, x = 0.55, y=0.07)
    fig.tight_layout(rect=[0.0, 0.05, 1, 0.995], h_pad=0.4, w_pad=0.0)
    fig.subplots_adjust (wspace = 0.08)

    save_and_publish(fig, output_path, "fig_05.pdf")
    plt.close(fig)


def main():
    output = output_argument()
    data = pd.read_csv(SCRIPT_DIR / "data/fig_05.csv.gz", float_precision="round_trip")
    dynamics_by_model = {
        directory: data.loc[data["model_directory"].eq(directory)].copy()
        for directory, _ in MODELS
    }
    plot_comparison(dynamics_by_model, output, trajectory_columns="pmid",
                    trajectory_alpha=0.09, trajectory_linewidth=0.3)
    print(f"Figure enregistrée : {output.resolve()}")


if __name__ == "__main__":
    main()
