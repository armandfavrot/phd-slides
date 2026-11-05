#!/usr/bin/env Rscript
# Plot code adapted from results.ipynb.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (length(arg) != 1L) stop('Run with Rscript')
setwd(dirname(normalizePath(sub('^--file=', '', arg))))
source('../common.R')
init_figure_environment('chapter_2', getwd())

latex_linewidth = 0.789
pdf_width = 800
# Conserver la calibration visuelle du test avec une largeur de texte de 424.06033 pt.
layout_ratio <- 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size <- reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.8 * axis_title_size
axis_y_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)

theme_update(
  axis.title.x = element_text(size = axis_title_size, margin = ggplot2::margin(t = axis_x_margin)),
  axis.text.x = element_text(size = axis_text_size),
  axis.title.y = element_text(size = axis_title_size, margin = ggplot2::margin(r = axis_y_margin)),
  axis.text.y = element_text(size = axis_text_size),
  strip.text = element_text(size = 0.9 * axis_title_size),
  plot.title = element_text (size = axis_title_size),
  legend.title = element_text(size = 1 * axis_title_size, face = "bold", margin = ggplot2::margin(r = legend_title_margin)),
  legend.text = element_text(size = axis_title_size)
)

update_geom_defaults("text", list(size = 0.6 * axis_text_size / ggplot2::.pt))

load('data/plot_inputs.RData')
dir.create('pdf', showWarnings=FALSE)

figure_obs_vs_pred = df_res_all_static %>%
    summarise (prediction_ecum = mean (prediction_ecum), e.cum = unique (e.cum), .by = c (pmid, Model)) %>%
    filter (Model %in% c ("ALFAM2 ", "static nn 12", "rnn 9 - data a.", "static rf ")) %>%
    ggplot () +
        geom_point (aes (x = e.cum, y = prediction_ecum, color = Model), size = 1.2) +
        theme (legend.position = "none") +
        geom_abline (slope = 1, linetype = 2) +
        xlab ("Observed values (kgN/ha)") +
        ylab ("Predicted values (kgN/ha)") +
        facet_wrap (~ Model) +
        NULL


grDevices::cairo_pdf('pdf/fig05.pdf', width=pdf_width/72, height=600/72, family=FIGURE_FONT, onefile=FALSE)
print(figure_obs_vs_pred)
grDevices::dev.off()
publish_pdf('fig05.pdf')
