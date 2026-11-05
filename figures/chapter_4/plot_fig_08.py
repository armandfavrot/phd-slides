"""Tracer les observations et les prédictions du modèle physique du package jusqu’à 500 h."""

import argparse
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from _theme import apply_theme, save_and_publish
import numpy as np
import pandas as pd
from matplotlib.lines import Line2D
SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_PATH = SCRIPT_DIR / "pdf" / "fig_08.pdf"

# Same full-width text calibration and canvas as figure 1.
latex_linewidth = 1
pdf_width = 14 * 72
pdf_height = 9 * 72
layout_ratio = 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size = 0.8 * reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.7 * axis_title_size
apply_theme(axis_title_size, axis_text_size)

SELECTED_PMIDS = [1463, 1454, 1141, 3481]

def output_argument():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=OUTPUT_PATH,
                        help="Chemin du PDF de sortie.")
    output = parser.parse_args().output
    output.parent.mkdir(parents=True, exist_ok=True)
    return output

def plot_selected_non_physical_pmids_absolute(
    predictions, output_path, pmids=SELECTED_PMIDS
):
    """Comparer les observations aux prédictions physiques du package."""

    available = set(predictions["pmid"].unique())
    missing = [pmid for pmid in pmids if pmid not in available]
    if missing:
        raise ValueError(f"PMIDs absents des prédictions: {missing}")

    fig, axes = plt.subplots(
        2, 2, figsize=(pdf_width / 72, pdf_height / 72), sharex=True, sharey=False, squeeze=False,
    )
    for axis, pmid in zip(axes.flat, pmids):
        curve = predictions.loc[predictions["pmid"].eq(pmid)].sort_values(
            "ct_origin"
        )
        tan_applied = float(curve["tan_app_origin"].iloc[0])
        observed = curve.loc[~curve["is_extension"]]
        extended = pd.concat([observed.tail(1), curve.loc[curve["is_extension"]]])

        axis.plot(
            np.r_[0.0, observed["ct_origin"].to_numpy()],
            np.r_[0.0, observed["e_cum_origin"].to_numpy()],
            color="black", linestyle="-", linewidth=1.8,
        )
        axis.plot(
            np.r_[0.0, observed["ct_origin"].to_numpy()],
            np.r_[0.0, observed["prediction_ecum"].to_numpy()],
            color="#0072B2", linestyle=(0, (3, 2)), linewidth=2.2,
        )
        axis.plot(
            extended["ct_origin"], extended["prediction_ecum"],
            color="#D62728", linestyle=(0, (1, 2)), linewidth=2.2,
        )
        axis.set_xlim(0, 500)
        axis.axhline(
            tan_applied, color="#7A3E9D", linestyle=(0, (1, 2)), linewidth=2.4,
        )
        axis.set_title(f"PMID {pmid}", fontsize=0.8 * axis_title_size, fontweight="bold")
        axis.tick_params(labelsize=axis_text_size)
        axis.grid(alpha=0.25)

    fig.supylabel(
        "Cumulative emission " + r"(kg N-NH$_3$ ha$^{-1}$)",
        fontsize=0.9 * axis_title_size, x=0.035, y=0.58, ha="center",
    )
    fig.supxlabel(
        "Time since fertilizer application (h)", x=0.55, ha="center",
        fontsize=0.9 * axis_title_size, y=0.12,
    )
    fig.legend(
        handles=[
            Line2D([0], [0], color="black", linestyle="-", linewidth=2,
                   label="Observed dynamics"),
            Line2D([0], [0], color="#0072B2", linestyle=(0, (3, 2)), linewidth=2,
                   label="Package model predictions"),
            Line2D([0], [0], color="#D62728", linestyle=(0, (1, 2)), linewidth=2,
                   label="Extended predictions (last weather held constant)"),
            Line2D([0], [0], color="#7A3E9D", linestyle=(0, (1, 2)), linewidth=2,
                   label="Applied TAN"),
        ],
        loc="lower center", ncols=2, frameon=False, fontsize=0.8 * axis_title_size,
        bbox_to_anchor=(0.55, 0.0),
    )
    fig.tight_layout(rect=[0.0, 0.1, 1, 1])
    save_and_publish(fig, output_path, "fig_08.pdf")
    plt.close(fig)


def main():
    output = output_argument()
    predictions = pd.read_csv(SCRIPT_DIR / "data/fig_08.csv", float_precision="round_trip")
    plot_selected_non_physical_pmids_absolute(predictions, output)
    print(f"Figure enregistrée : {output.resolve()}")


if __name__ == "__main__":
    main()
