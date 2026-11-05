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
       axis.text.x = element_text (size = axis_text_size, margin = ggplot2::margin (t = 8)),
       axis.title.y = element_text (size = axis_title_size, margin = ggplot2::margin (r = axis_y_margin)),
       axis.text.y = element_text (size = 1 * axis_text_size),
       strip.text = element_text (size = 0.9 * axis_title_size),
       plot.title = element_text (size = axis_title_size),
       legend.title = element_text(size = 1 * axis_title_size, face = "bold", margin = ggplot2::margin(r = legend_title_margin)),
       legend.text = element_text (size = 0.95 * axis_title_size))

update_geom_defaults(
  "text",
  list(size = 0.6 * axis_text_size / ggplot2::.pt)
)
load('data/plot_inputs.RData')
dir.create('pdf', showWarnings=FALSE)

figure_rnn_comparison_of_all_models_2 = df_res_rnn_all %>%
    summarise (MAE = mean (abs (e.cum - prediction_ecum)), .by = c (bidirectional, mlp, with_embeddings, sample, response2)) %>%
    mutate (bidi_mlp = paste (bidirectional, mlp)) %>%
    mutate (with_embeddings = recode (with_embeddings, "True" = "With embeddings", "False" = "Without embeddings")) %>%
    mutate (bidi_mlp = recode (
        bidi_mlp,
        "False False" = "Unidirectional without MLP",
        "False True" = "Unidirectional with MLP",
        "True False" = "Bidirectional without MLP",
        "True True" = "Bidirectional with MLP"
    )) %>%

    ggplot () +
        geom_boxplot (aes (x = with_embeddings, y = MAE, fill = bidi_mlp)) +
        facet_wrap (~ response2) +
        labs (fill = "Model") +
        guides (fill = guide_legend (nrow = 2, byrow = TRUE)) +
        theme (legend.position = "bottom",
               legend.title = element_text(face = "bold", margin = ggplot2::margin(r = legend_title_margin)),
               legend.key.spacing.x = grid::unit (22, "pt"),
               legend.key.spacing.y = grid::unit (12, "pt")) +
        geom_hline (yintercept = 4, linetype = 2, linewidth = 0.3) +
        theme (axis.title.x = element_text(margin = ggplot2::margin(t = axis_x_margin, b = -15))) +
        xlab ("") +
        #theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        geom_text (data = data.frame (response2 = factor("delta_ecum", levels = "delta_ecum")), 
                   aes (x = 0.75, y = 7.5, label = "rnn 9"), size = 10, color = "red", fontface = "bold") +
        geom_text (data = data.frame (response2 = factor("delta_ecum", levels = "delta_ecum")), 
                   aes (x = 0.72, y = 6.35, label = "\u2193"), size = 13, color = "red", fontface = "bold") +
        ylab ("MAE (kgN/ha)") +
        NULL


grDevices::cairo_pdf('pdf/fig13_appendix.pdf', width=pdf_width/72, height=800/72, family=FIGURE_FONT, onefile=FALSE)
print(figure_rnn_comparison_of_all_models_2)
grDevices::dev.off()
publish_pdf('fig13_appendix.pdf')
