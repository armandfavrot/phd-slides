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

df_tmp = rbind (
    df_res_rnn_with_data_augmentation %>%
        mutate (type = "Without normalisation", model = "rnn 9 - data a.") %>%
        filter (ct == max (ct), .by = c (pmid, sample)) %>%
        select (e.cum, prediction_ecum, sample, type, model),

    df_res_rnn_with_normalisation %>%
        mutate (type = "With normalisation", model = "rnn 9 - data a.") %>%
        filter (ct == max (ct), .by = c (pmid, sample)) %>%
        select (e.cum, prediction_ecum, sample, type, model),

    df_res_static_nn %>% 
        filter (model == 12) %>% 
        mutate (type = "Without normalisation", model = "static nn 12") %>%
        select (e.cum, prediction_ecum, sample, type, model),

    df_res_static_nn_with_normalisation %>% 
        mutate (type = "With normalisation", model = "static nn 12") %>%
        select (e.cum, prediction_ecum, sample, type, model)
    
)

figure_with_and_without_normalisation = df_tmp %>%

    mutate (type = factor (type)) %>%

    summarise (MAE = mean (abs (e.cum - prediction_ecum)), .by = c (sample, type, model)) %>%

    ggplot () +
        geom_boxplot (aes (y = type, x = MAE, fill = type)) +
        facet_wrap (~ model, ncol = 1) +
        xlab ("MAE on the final cumul (kgN/ha)") +
        ylab ("") +
        expand_limits (x = c (3, 8.5)) +
        theme (legend.position = "none") +
        theme (axis.title.y = element_text (margin = ggplot2::margin (r = -20))) +
        labs (fill = "")


grDevices::cairo_pdf('pdf/fig17_appendix.pdf', width=pdf_width/72, height=400/72, family=FIGURE_FONT, onefile=FALSE)
print(figure_with_and_without_normalisation)
grDevices::dev.off()
publish_pdf('fig17_appendix.pdf')
