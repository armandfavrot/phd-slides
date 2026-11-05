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
       axis.text.x = element_text (size = 0.9 * axis_title_size),
       axis.title.y = element_text (size = axis_title_size, margin = ggplot2::margin (r = axis_y_margin)),
       axis.text.y = element_text (size = axis_text_size),
       strip.text = element_text (size = 0.9 * axis_title_size),
       plot.title = element_text (size = axis_title_size),
       legend.title = element_text(size = 1 * axis_title_size, face = "bold", margin = ggplot2::margin(r = legend_title_margin)),
       legend.text = element_text (size = axis_title_size))

update_geom_defaults("text", list(size = 0.6 * axis_text_size / ggplot2::.pt))

load('data/plot_inputs.RData')
dir.create('pdf', showWarnings=FALSE)

pmids_check = c (1132, 1527, 2828, 3168)

df_plot = df_res_all_dynamic %>%
    filter (sample == 1) %>%
    filter (pmid %in% pmids_check) %>%
    filter (model != "9 interp") %>%
    filter (model_type == "ALFAM2" | (model_type == "dynamic rf" & model == "- 2") | (model_type == "rnn" & model == 9)) %>%
    select (model_type, pmid, e.cum, ct, prediction_ecum) %>%
    pivot_longer (cols = c (e.cum, prediction_ecum)) %>%
    mutate (name = ifelse (name == "prediction_ecum" & model_type == "ALFAM2", "ALFAM2", name)) %>%
    mutate (name = ifelse (name == "prediction_ecum" & model_type == "dynamic rf", "dynamic rf - 2", name)) %>%
    mutate (name = ifelse (name == "prediction_ecum" & model_type == "rnn", "rnn 9 - data a.", name)) %>%
    mutate (name = ifelse (name == "e.cum", "Observed values", name)) %>%
    distinct

# adding value e.cum = 0 at t = 0
df_plot_final = NULL
for (i in pmids_check){
    for (n in df_plot$name %>% unique){
        df_tmp = df_plot %>% filter (name == n & pmid == i)
        to_bind = df_tmp[1, ] %>% mutate (ct = 0, value = 0)
        df_tmp = rbind (to_bind, df_tmp)
        df_plot_final = rbind (df_plot_final, df_tmp)
    }
}

df_plot_final = df_plot_final %>%
    mutate (name = factor (name, levels = c ("Observed values", "ALFAM2", "dynamic rf - 2", "rnn 9 - data a.")))

figure_prediction_examples = df_plot_final %>%
    ggplot () +
        geom_point (aes (x = ct, y = value, color = name), size = 2) +
        geom_line (aes (x = ct, y = value, color = name, linetype = name), linewidth = 0.5) +
        facet_wrap (~ pmid, scales = "free") +
        scale_color_manual (values = c ("red", "black", Dark2 [c(1, 3)])) +
        scale_linetype_manual(values = c("dashed", "solid", "solid", "solid")) +
        labs(color = "", linetype = "") +
        xlab ("Time since fertilizer application (h)") +
        ylab ("Cumulative emissions (kgN/ha)") +
        theme (legend.position = "bottom") +
        NULL


grDevices::cairo_pdf('pdf/fig07.pdf', width=pdf_width/72, height=600/72, family=FIGURE_FONT, onefile=FALSE)
print(figure_prediction_examples)
grDevices::dev.off()
publish_pdf('fig07.pdf')
