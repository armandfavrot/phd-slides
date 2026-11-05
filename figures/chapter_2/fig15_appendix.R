#!/usr/bin/env Rscript
# Plot code adapted from results.ipynb.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (length(arg) != 1L) stop('Run with Rscript')
setwd(dirname(normalizePath(sub('^--file=', '', arg))))
source('../common.R')
init_figure_environment('chapter_2', getwd())

latex_linewidth = 1
pdf_width = 1000
# Conserver la calibration visuelle du test avec une largeur de texte de 424.06033 pt.
layout_ratio <- 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size <- reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.8 * axis_title_size
axis_y_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)

theme_update (axis.title.x = element_text(size = axis_title_size, margin = ggplot2::margin(t = axis_x_margin)),
       axis.text.x = element_text (size = axis_text_size),
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

pmids_check = predictions_without_data_a_on_observed_times %>%
    filter (test_subset == 1) %>%
    pull (pmid) %>%
    unique
prediction_example_without_data_a = predictions_without_data_a_on_observed_times %>%
    filter (seq %in% c ("dt = 2", "real times")) %>%
    filter (test_subset == 1 & pmid %in% pmids_check [1:4]) %>%
    select (ct, e.cum, prediction_ecum, test_subset, seq, pmid) %>%
    ggplot () +
        geom_line (aes (x = ct, y = prediction_ecum, color = seq)) +
        ggtitle ("rnn 9") +
        expand_limits (y = c (0, 60)) +
        facet_wrap (~ pmid, nrow = 1) +
        expand_limits (y = c (0, 90)) +
        theme (legend.position = "none") +
        theme (plot.title = element_text (hjust = 0)) +
        xlab ("Time since fertilizer application (h)") +
        ylab ("Predicted emissions\n(kgN/ha)")

prediction_example_with_data_a = predictions_with_data_a_on_observed_times %>%
    filter (seq %in% c ("dt = 2", "real times")) %>%
    filter (test_subset == 1 & pmid %in% pmids_check [1:4]) %>%
    select (ct, e.cum, prediction_ecum, test_subset, seq, pmid) %>%
    ggplot () +
        geom_line (aes (x = ct, y = prediction_ecum, color = seq)) +
        facet_wrap (~ pmid, nrow = 1) +
        expand_limits (y = c (0, 90)) +
        ggtitle ("rnn 9 - data a.") +
        theme (legend.position = "bottom") +
        theme (plot.title = element_text (hjust = 0)) +
        xlab ("Time since fertilizer application (h)") +
        ylab ("Predicted emissions\n(kgN/ha)") +
        theme (axis.title.x = element_text(margin = ggplot2::margin(t = axis_x_margin, b = 20))) +
        labs (color = "Time sequence")
grDevices::cairo_pdf('pdf/fig15_appendix.pdf', width=pdf_width/72, height=800/72, family=FIGURE_FONT, onefile=FALSE)
grid.arrange (
    prediction_example_without_data_a, 
    prediction_example_with_data_a, 
    heights = c (1, 1.2))
grDevices::dev.off()
publish_pdf('fig15_appendix.pdf')
