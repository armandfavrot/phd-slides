# Thesis figures

This folder is independent of the article repository and trained models.
It uses the thesis theme in `../common.R`, which must be kept alongside it.

Run commands from this folder. Each R script produces a single PDF with the same
name in `pdf/` and automatically copies it to `../../manuscrit/images/chapter_3/`.
Figures 2, 3 and 4 are TikZ diagrams, with one `.tex` file each; the Makefile
exports them to the same manuscript directory. No article/appendix subfolders
are used for these revised figures.

## Usage

Rebuild all figures:

```sh
sh run_all.sh
```

Rebuild one R figure:

```sh
Rscript --vanilla fig_5.R
```

Rebuild one TikZ figure:

```sh
make pdf/fig_3.pdf
```

To synchronise existing TikZ PDFs without forcing a rebuild, run `make publish`.

Edit the corresponding script to change a figure's appearance.
The shared R theme is in `functions/R_functions.R`.
It builds on `../common.R` and retains the reference chapter's per-figure
calibration: font sizes, facet labels, margins, spacing and line widths.
PDF dimensions and facet layouts also follow that reference.
Figures S4 and S7 are included at 0.9 times the thesis text width; the other
R figures are included at the full text width. The additional fold-level figures
use the same styling as the all-method supplementary figures.
Long result legends use two rows. Statistical calculations, repeated-validation
summaries, axis scales and outlier annotations retain the revised article values.
After editing this theme, rerun the R scripts concerned.
Use `make -B` to force rebuilding all TikZ figures.

## Requirements and inputs

R with ggplot2, dplyr (>= 1.1.0), tibble, tidyr, stringr, gridExtra and paletteer;
a LaTeX installation with pdflatex, standalone, TikZ and Latin Modern; and make.
`--vanilla` avoids loading an enclosing project's R startup configuration.

`data/data.csv` is a copy of the prepared data.
`data/df_res_1.csv`, `df_res_2.csv` and `df_res_3.csv` contain the existing
full, partial and embedding-only fine-tuning results.
No data preparation or model training is performed here.
These inputs are a snapshot; changes to the article repository are not
automatically applied to this folder.

The folder reproduces the 17 PDFs present in the article's figure folder:
fig_1–fig_7, fig_S1–fig_S7 and fig_S9–fig_S11.
There is no fig_S8 in that folder.

The prepared data include CaractAir-derived data. This folder is intended for
private thesis work and must not be made public without the required permission.
