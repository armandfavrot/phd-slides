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

figure_time_sequence_effect_rnn_4 = df_efficacy_rnn_data_augmentation %>%
    filter (strategy != "Broadcast") %>% 
    
    ggplot () +
        
        geom_boxplot (aes (x = efficacy, y = strategy, fill = strategy)) +
        scale_fill_manual (values = Dark2) +
        scale_y_discrete (limits = c ("Closed slot", "Open slot", "Trailing shoe", "Trailing hose", "Incorporation")) +
        ylab ("") + xlab ("Efficacy (%)") +
        geom_vline (xintercept = 0, linetype = 2) +
        theme (legend.position = "none",
               axis.ticks.y = element_blank(),
               strip.text.x = element_text(margin = ggplot2::margin(t = 8, b = 8, r = 0, l = 0))) +
        facet_wrap (~ model, ncol = 1) +
        theme (axis.title.y = element_text (margin = ggplot2::margin (r = -20))) +
        NULL


grDevices::cairo_pdf('pdf/fig18_appendix.pdf', width=pdf_width/72, height=1000/72, family=FIGURE_FONT, onefile=FALSE)
print(figure_time_sequence_effect_rnn_4)
grDevices::dev.off()
publish_pdf('fig18_appendix.pdf')
