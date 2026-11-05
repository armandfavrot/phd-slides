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

df_comparison = rbind (
    predictions_without_data_a_on_observed_times %>% mutate (model = "Without data augmentation"),
    predictions_with_data_a_on_observed_times %>% mutate (model = "With data augmentation")
)

figure_time_sequence_effect_rnn_1 = df_comparison %>%
    mutate (model = recode (model, 
                            "Without data augmentation" = "rnn 9", "With data augmentation" = "rnn 9 - data a.")) %>%
    filter (seq %in% c ("dt = 2", "real times")) %>%
    filter (ct == max (ct), .by = c (test_subset, seq, pmid, model)) %>%
    select (e.cum, prediction_ecum, test_subset, seq, pmid, model) %>%
    pivot_wider (names_from = seq, values_from = prediction_ecum) %>%
    mutate (diff = abs (`dt = 2` - `real times`)) %>%

    ggplot () +
        geom_boxplot (aes (x = diff, y = model)) +
        xlab ("Absolute difference on the final emissions (kgN/ha)") +
        scale_y_discrete (limits = c ("rnn 9 - data a.", "rnn 9")) +
        ylab ("") +
        theme (axis.title.y = element_text (margin = ggplot2::margin (r = -20)))


grDevices::cairo_pdf('pdf/fig16_appendix.pdf', width=pdf_width/72, height=250/72, family=FIGURE_FONT, onefile=FALSE)
print(figure_time_sequence_effect_rnn_1)
grDevices::dev.off()
publish_pdf('fig16_appendix.pdf')
