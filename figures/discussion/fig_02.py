"""Reproduire la figure de discussion depuis les CSV locaux, sans modèle entraîné."""

import argparse
import shutil
from pathlib import Path
import subprocess

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib import font_manager
from matplotlib.patches import Patch
import numpy as np
import pandas as pd
import seaborn as sns

SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_NAME = "fig_02.pdf"


def thesis_theme(width_inches):
    """Same font calibration as the R figures at 1 thesis linewidth."""
    font_path = Path(subprocess.check_output(
        ["fc-match", "-f", "%{file}", "Latin Modern Roman"], text=True
    ).strip())
    for font_file in font_path.parent.glob("lmroman*.otf"):
        font_manager.fontManager.addfont(str(font_file))
    size = 32 * (424.06033 / 483.69687) * (72 * width_inches / 1000)
    plt.rcParams.update({
        "font.family": "Latin Modern Roman",
        "font.size": 0.7 * size,
        "axes.labelsize": 0.7 * size,
        "axes.titlesize": 0.7 * size,
        "axes.titleweight": "bold",
        "axes.facecolor": "#f3faff",
        "axes.edgecolor": "#999999",
        "axes.linewidth": 0.3,
        "grid.color": "white",
        "grid.linewidth": 0.6,
        "xtick.color": "#4d4d4d",
        "ytick.color": "#4d4d4d",
        "xtick.labelsize": 0.6 * size,
        "ytick.labelsize": 0.6 * size,
        "legend.fontsize": 0.8 * size,
        "mathtext.fontset": "custom",
        "mathtext.rm": "Latin Modern Roman",
        "mathtext.it": "Latin Modern Roman:italic",
        "mathtext.bf": "Latin Modern Roman:bold",
        "mathtext.cal": "Latin Modern Roman:italic",
        # Latin Modern's OpenType CFF outlines are embedded as vector glyphs.
        "pdf.fonttype": 3,
    })
    return size

def plot_absolute_emissions_by_method_and_tan(predictions, output_path):
    """Combine test MAE and 120 h absolute emissions for extreme TAN levels."""

    size = thesis_theme(17)
    final = predictions
    available_tan = sorted(final["tan_app_origin"].unique())
    tan_values = [available_tan[0], available_tan[-1]]
    methods = final.sort_values("method_order")["method"].drop_duplicates().tolist()
    labels = {
        method: "incorp" if method == "bc + deep immediate incorporation" else method
        for method in methods
    }
    mae = pd.read_csv(SCRIPT_DIR / "data" / "test_mae.csv", float_precision="round_trip")

    model_colors = {
        "Benchmark": "#A8D5BA",
        "alt. model": "#F4B6C2",
    }
    fig = plt.figure(figsize=(17, 12), layout="constrained")
    grid = fig.add_gridspec(
        2, 4, width_ratios=[0.85, 0.35, 1.35, 1.35], wspace=0.10,
    )
    mae_axis = fig.add_subplot(grid[:, 0])
    scenario_axes = np.array([
        [fig.add_subplot(grid[0, 2]), fig.add_subplot(grid[0, 3])],
        [fig.add_subplot(grid[1, 2]), fig.add_subplot(grid[1, 3])],
    ])
    sns.boxplot(
        data=mae, x="configuration", y="mae",
        order=["Benchmark", "alt. model"],
        hue="configuration", palette=model_colors,
        dodge=False, legend=False, ax=mae_axis,
    )
    mae_axis.set_title("")
    mae_axis.set_xlabel("")
    mae_axis.set_ylabel(r"MAE (kg N-NH$_3$ ha$^{-1}$)", labelpad = 18)
    mae_axis.set_xticks(
        [0, 1], ["Benchmark", "alt. model"], rotation=25, ha="center"
    )
    mae_axis.tick_params(axis="x", labelsize=0.65 * size)
    mae_axis.grid(axis="y")
    mae_axis.set_axisbelow(True)

    configurations = [
        ("Benchmark", model_colors["Benchmark"]),
        ("alt. model", model_colors["alt. model"]),
    ]
    reference_axis = scenario_axes[0, 0]
    for row, (configuration, color) in enumerate(configurations):
        for column, tan in enumerate(tan_values):
            axis = scenario_axes[row, column]
            if axis is not reference_axis:
                axis.sharey(reference_axis)
            panel = final.loc[
                final["configuration"].eq(configuration)
                & np.isclose(final["tan_app_origin"], tan)
            ]
            sns.boxplot(
                data=panel, x="method", y="prediction_ecum",
                order=methods, color=color, ax=axis,
            )
            axis.axhline(
                0, color="black", linestyle="--", linewidth=1,
                label="_nolegend_",
            )
            axis.axhline(
                tan, color="#D55E00", linestyle="--", linewidth=1.5,
                label="Applied TAN",
            )
            axis.set_xlabel("")
            axis.set_xticks(
                range(len(methods)), [labels[method] for method in methods],
                rotation=25, ha="right",
            )
            axis.grid(axis="y")
            axis.set_axisbelow(True)
            if row == 0:
                axis.set_title(f"TAN = {tan:g} " + r"(kg N-NH$_3$ ha$^{-1}$)",
                               fontsize=0.55 * size,
                               backgroundcolor="#e5e5e5", pad=16)
            if column == 0:
                axis.set_ylabel("")
            else:
                axis.set_ylabel("")
                axis.tick_params(axis="y", labelleft=False)
    # Common size for all x-axis tick labels, including the MAE panel.
    for axis in [mae_axis, *scenario_axes.flat]:
        axis.tick_params(axis="x", labelsize=0.55 * size)

    line_handles, line_labels = reference_axis.get_legend_handles_labels()
    handles = [
        Patch(facecolor=model_colors["Benchmark"], edgecolor="#666666",
              label="Benchmark"),
        Patch(facecolor=model_colors["alt. model"], edgecolor="#666666",
              label="alt. model"),
        *line_handles,
    ]
    legend_labels = ["Benchmark", "alt. model", *line_labels]
    mae_title = fig.text(
        0.15, 1.01, "Test-set MAE",
        ha="center", va="bottom", fontsize=0.85 * size, fontweight="bold",
    )
    scenario_title = fig.text(
        0.64, 1.01, "Predictions on scenarios",
        ha="center", va="bottom", fontsize= 0.85 * size, fontweight="bold",
    )
    fig.legend(
        handles, legend_labels, loc="lower center", frameon=False, ncols=4,
        bbox_to_anchor=(0.52, -0.08),
    )
    fig.canvas.draw()
    mae_position = mae_axis.get_position()
    mae_title.set_x((mae_position.x0 + mae_position.x1) / 2)
    scenario_left = scenario_axes[0, 0].get_position().x0
    scenario_right = scenario_axes[0, 1].get_position().x1
    scenario_title.set_x((scenario_left + scenario_right) / 2)
    # Keep the calibrated width: reserve space inside the canvas for titles/legend.
    fig.get_layout_engine().set(rect=(0, 0.10, 1, 0.81))
    mae_title.set_y(0.89)
    scenario_title.set_y(0.93)
    fig.legends[0].set_bbox_to_anchor((0.52, 0.01))
    fig.canvas.draw()
    mae_position = mae_axis.get_position()
    scenario_left = scenario_axes[0, 0].get_position().x0
    scenario_right = scenario_axes[0, 1].get_position().x1
    mae_title.set_x((mae_position.x0 + mae_position.x1) / 2)
    scenario_title.set_x((scenario_left + scenario_right) / 2)
    fig.text(
        (mae_position.x1 + scenario_left) / 2 + 0.000, 0.51,
        "Cumulative emission at 120 h\n" + r"(kg N-NH$_3$ ha$^{-1}$)",
        rotation=90, ha="center", va="center",
        fontsize=mae_axis.yaxis.label.get_fontsize(),
    )
    fig.savefig(output_path)
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=SCRIPT_DIR / "pdf" / OUTPUT_NAME,
                        help="Chemin du PDF de sortie.")
    args = parser.parse_args()
    predictions = pd.read_csv(SCRIPT_DIR / "data" / "scenario_predictions_120h.csv",
                              float_precision="round_trip")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    plot_absolute_emissions_by_method_and_tan(predictions, args.output)
    print(f"Figure enregistrée : {args.output.resolve()}")
    manuscript_output = SCRIPT_DIR.parent.parent / "images" / "discussion" / OUTPUT_NAME
    manuscript_output.parent.mkdir(parents=True, exist_ok=True)
    if args.output.resolve() != manuscript_output.resolve():
        shutil.copy2(args.output, manuscript_output)
    print(f"Export manuscrit : {manuscript_output}")


if __name__ == "__main__":
    main()
