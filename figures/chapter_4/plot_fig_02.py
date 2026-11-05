"""Reproduire fig_02.pdf à partir des données locales du chapitre 4."""

import argparse
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from _theme import apply_theme, save_and_publish
import numpy as np
import pandas as pd

SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_PATH = SCRIPT_DIR / "pdf" / "fig_02.pdf"

# Text calibration, matching the Python introduction figures at 1 linewidth.
latex_linewidth = 1
pdf_width = 12 * 72
pdf_height = 5.5 * 72
layout_ratio = 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size = 0.8 * reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.7 * axis_title_size
axis_y_margin = 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin = 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin = 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
apply_theme(axis_title_size, axis_text_size)

def output_argument():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=OUTPUT_PATH,
                        help="Chemin du PDF de sortie.")
    output = parser.parse_args().output
    output.parent.mkdir(parents=True, exist_ok=True)
    return output

def plot_selected_time_extensions(predictions, output_path):
    """Plot absolute emissions for multiple time-sequence variants per PMID."""

    styles = {
        "Original time sequence": ("#1F1F1F", (0, (1.5, 1)), 1.9),
        "Extended to 120 h": ("#D55E00", (0, (1.5, 1)), 1.9),
        "Extended to 240 h": ("#0072B2", (0, (1.5, 1)), 1.9),
        "Extended to 480 h": ("#009E73", (0, (1.5, 1)), 1.9),
    }
    fig, axes = plt.subplots(
        1, len(predictions), figsize=(pdf_width / 72, pdf_height / 72), sharex=True, sharey=False,
        squeeze=False,
    )
    for axis, (pmid, variants) in zip(axes.flat, predictions.items()):
        for label, curve in variants.items():
            if label not in styles:
                raise ValueError(f"No plotting style defined for {label}")
            color, linestyle, linewidth = styles[label]
            axis.plot(
                np.r_[0.0, curve["ct_origin"].to_numpy()],
                np.r_[0.0, curve["prediction_ecum"].to_numpy()],
                color=color, linestyle=linestyle, linewidth=linewidth,
                label=label,
            )
        observed_end = variants["Original time sequence"]["ct_origin"].max()
        tan_applied = float(
            variants["Original time sequence"]["tan_app_origin"].iloc[0]
        )
        axis.axvline(
            observed_end, color="0.5", linestyle=":", linewidth=1,
        )
        axis.axhline(
            tan_applied, color="#7A3E9D", linestyle=(0, (1, 2)), linewidth=2.2,
            label="Applied TAN",
        )
        axis.set_title(f"PMID {pmid}", fontsize=0.8 * axis_title_size, fontweight="bold")
        axis.tick_params(labelsize=axis_text_size)
        axis.grid(alpha=0.25)
    fig.supylabel(
        "Cumulative emission",
        fontsize=1 * axis_title_size,
        x=0.025, y=0.63, ha="center",
    )
    fig.text(
        0.06, 0.63,
        r"(kg N-NH$_3$ ha$^{-1}$)",
        fontsize=0.8 * axis_title_size,
        rotation=90,
        ha="center", va="center",
    )
    handles, labels = axes[0, 0].get_legend_handles_labels()
    fig.legend(
        handles, labels, loc="lower center", ncols=3,
        frameon=False, fontsize=0.9 * axis_title_size,
        bbox_to_anchor = (0.55, 0.00)
    )
    fig.supxlabel("Time since fertilizer application (h)", fontsize=1 * axis_title_size, y=0.18)
    # Reserve space for the separate units label, not managed by tight_layout.
    fig.tight_layout(rect=[0.035, 0.15, 1, 1])
    save_and_publish(fig, output_path, "fig_02.pdf")
    plt.close(fig)


def main():
    output = output_argument()
    data = pd.read_csv(SCRIPT_DIR / "data/fig_02.csv", float_precision="round_trip")
    predictions = {
        pmid: {label: curve for label, curve in subset.groupby("variant", sort=False)}
        for pmid, subset in data.groupby("pmid", sort=False)
    }
    plot_selected_time_extensions(predictions, output)
    print(f"Figure enregistrée : {output.resolve()}")


if __name__ == "__main__":
    main()
