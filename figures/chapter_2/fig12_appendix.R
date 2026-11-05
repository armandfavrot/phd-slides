#!/usr/bin/env Rscript
# Plot code adapted from results.ipynb.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (length(arg) != 1L) stop('Run with Rscript')
setwd(dirname(normalizePath(sub('^--file=', '', arg))))
source('../common.R')
init_figure_environment('chapter_2', getwd())

latex_linewidth = 1.052
pdf_width = 1200
# Conserver la calibration visuelle du test avec une largeur de texte de 424.06033 pt.
layout_ratio <- 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size <- reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.8 * axis_title_size
axis_y_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)

theme_update (axis.title.x = element_text(size = axis_title_size, margin = ggplot2::margin(t = axis_x_margin)),
       axis.text.x = element_text (size = 0.9 * axis_text_size),
       axis.title.y = element_text (size = axis_title_size, margin = ggplot2::margin (r = axis_y_margin)),
       axis.text.y = element_text (size = 1 * axis_text_size),
       strip.text = element_text (size = 0.9 * axis_title_size),
       plot.title = element_text (size = axis_title_size),
       legend.title = element_text(size = 1 * axis_title_size, face = "bold", margin = ggplot2::margin(r = legend_title_margin)),
       legend.text = element_text (size = axis_title_size))

update_geom_defaults(
  "text",
  list(size = 0.6 * axis_text_size / ggplot2::.pt)
)
load('data/plot_inputs.RData')
dir.create('pdf', showWarnings=FALSE)

figure_rnn_comparison_of_all_models = df_res_rnn_all %>%
    summarise (MAE = mean (abs (e.cum - prediction_ecum)), .by = c (sample, model)) %>%
    mutate (model = paste ("rnn", model)) %>%
    mutate (model = factor (model, levels = level_models)) %>%

    ggplot () +
        geom_boxplot (aes (x = model, y = MAE), fill = "#e1f0e1") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        geom_hline (yintercept = 4, linetype = 2, linewidth = 0.3) +
        ylab ("MAE (kgN/ha)") +
        theme (axis.title.x = element_text(margin = ggplot2::margin(t = axis_x_margin, b = -30))) +
        xlab ("")


grDevices::cairo_pdf('pdf/fig12_appendix.pdf', width=pdf_width/72, height=600/72, family=FIGURE_FONT, onefile=FALSE)
print(figure_rnn_comparison_of_all_models)
grDevices::dev.off()
publish_pdf('fig12_appendix.pdf')
