import csv
from collections import defaultdict
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib import font_manager
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from _build import publish


ROOT = Path(__file__).resolve().parent
FERTILIZERS = ROOT / "FAOSTAT_data_en_6-20-2026_1.csv"
MANURE = ROOT / "FAOSTAT_data_en_6-20-2026_2.csv"
OUT = ROOT.parent / "pdf"
latex_linewidth = 1
pdf_width = 9 * 72
pdf_height = 5 * 72
layout_ratio = 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size = reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.8 * axis_title_size
axis_y_margin = 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin = 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin = 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)

latin_modern_file = subprocess.run(
    ["fc-match", "-f", "%{file}", "Latin Modern Roman"],
    check=True, capture_output=True, text=True
).stdout
font_manager.fontManager.addfont(latin_modern_file)
latin_modern_family = font_manager.FontProperties(fname=latin_modern_file).get_name()

plt.rcParams.update({
    "font.family": latin_modern_family,
    "font.size": axis_text_size,
    "axes.labelsize": axis_title_size,
    "axes.titlesize": axis_title_size,
    "xtick.labelsize": axis_text_size,
    "ytick.labelsize": axis_text_size,
    "legend.fontsize": 0.9 * axis_title_size,
    "legend.title_fontsize": axis_title_size,
    "pdf.fonttype": 42,
})


def read_csv(path):
    with path.open(encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def save(fig, name):
    fig.tight_layout()
    pdf = OUT / name
    fig.savefig(pdf, dpi=180)
    publish(pdf)
    plt.close(fig)


def million_tonnes(value):
    return float(value) / 1_000_000


def main():
    OUT.mkdir(exist_ok=True)
    fert = read_csv(FERTILIZERS)
    manure = read_csv(MANURE)

    by_item_element = defaultdict(list)
    for row in fert:
        by_item_element[(row["Item"], row["Element"])].append(
            (int(row["Year"]), million_tonnes(row["Value"]))
        )

    colors = {"Nutrient nitrogen N (total)": "#1f77b4", "Nutrient phosphate P2O5 (total)": "#ff7f0e", "Nutrient potash K2O (total)": "#2ca02c"}
    manure_n = sorted((int(row["Year"]), float(row["Value"]) / 1_000_000_000) for row in manure)
    fig, ax = plt.subplots(figsize=(pdf_width / 72, pdf_height / 72))
    english_labels = {
        "Nutrient nitrogen N (total)": "Synthetic nitrogen N",
        "Nutrient phosphate P2O5 (total)": "Synthetic phosphate P2O5",
        "Nutrient potash K2O (total)": "Synthetic potash K2O",
    }
    for item, label in english_labels.items():
        series = sorted(by_item_element[(item, "Agricultural Use")])
        ax.plot(
            [year for year, _ in series],
            [value for _, value in series],
            label=label,
            color=colors[item],
            linewidth=2,
        )
    ax.plot(
        [year for year, _ in manure_n],
        [value for _, value in manure_n],
        label="Manure nitrogen N",
        color="#8c564b",
        linewidth=2,
    )
    ax.set_ylabel("Million tonnes of nutrient", labelpad=axis_y_margin)
    ax.set_xlabel("Year", labelpad=axis_x_margin)
    ax.grid(True, alpha=0.25)
    legend = ax.legend(frameon=False)
    legend.get_title().set_fontweight("bold")
    save(fig, "10_synthetic_fertilizers_and_manure_absolute.pdf")

if __name__ == "__main__":
    main()
