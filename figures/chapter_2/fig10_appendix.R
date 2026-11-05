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

colors = c("#734196", "#60c67e", "#77c7e4", "#c0e5f2", "#a8e0b8")
figure_comparison_on_final_cumul_2 = df_res_all_static %>%
    filter (Model %in% c ("ALFAM2 ", "rnn 9", "rnn 9 - 2", "rnn 9 - data a.",
                          "dynamic rf - 2", "dynamic rf - 4", "dynamic rf - 6", "dynamic rf - 8", 
                          "dynamic rf - 10", "dynamic rf ", "dynamic rf - data a.", "static nn 1", "static nn 2", "static nn 3", "static nn 4", 
                          "static nn 5", "static nn 6", "static nn 7", "static nn 8", "static nn 9", 
                          "static nn 10", "static nn 11", "static nn 12", "static rf ")) %>%

    summarise (MAE = mean (abs (e.cum - prediction_ecum)), model_type = model_type[1], .by = c (sample, Model)) %>%


    mutate (MAE_rnn_data_a = MAE [Model == "rnn 9 - data a."], .by = sample) %>%
    mutate (diff = MAE - MAE_rnn_data_a) %>%

    filter (Model != "rnn 9 - data a.") %>%

    ggplot () +
        geom_boxplot (aes (x = Model, y = diff, fill = model_type)) +
        geom_hline (yintercept = 0, linetype = 2) +
        theme(axis.text.x = element_text(angle = 45, hjust = 1),
              legend.position = "none") +
        scale_fill_manual (values = colors) +
        xlab ("") +
        ylab ("MAE difference with rnn 9 data a. \n (kgN/ha)") +
        theme (axis.title.x = element_text(margin = ggplot2::margin(t = axis_x_margin, b = -30))) +
        NULL


grDevices::cairo_pdf('pdf/fig10_appendix.pdf', width=pdf_width/72, height=700/72, family=FIGURE_FONT, onefile=FALSE)
print(figure_comparison_on_final_cumul_2)
grDevices::dev.off()
publish_pdf('fig10_appendix.pdf')
