#!/usr/bin/env Rscript
# Plot code adapted from results.ipynb.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (length(arg) != 1L) stop('Run with Rscript')
setwd(dirname(normalizePath(sub('^--file=', '', arg))))
source('../common.R')
init_figure_environment('chapter_2', getwd())

latex_linewidth = 1.1
pdf_width = 1400
# Conserver la calibration visuelle du test avec une largeur de texte de 424.06033 pt.
layout_ratio <- 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size <- reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.8 * axis_title_size
axis_y_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)

theme_update (axis.title.x = element_text(size = 0.9 * axis_title_size, margin = ggplot2::margin(t = axis_x_margin)),
       axis.text.x = element_text (size = axis_text_size),
       axis.title.y = element_text (size = 0.85 * axis_title_size, margin = ggplot2::margin (r = axis_y_margin)),
       axis.text.y = element_text (size = 1 * axis_text_size),
       strip.text = element_text (size = 0.75 * axis_title_size),
       plot.title = element_text (size = 0.85 * axis_title_size),
       legend.title = element_text(size = 1 * axis_title_size, face = "bold", margin = ggplot2::margin(r = legend_title_margin)),
       legend.text = element_text (size = axis_title_size))

update_geom_defaults(
  "text",
  list(size = 0.6 * axis_text_size / ggplot2::.pt)
)
load('data/plot_inputs.RData')
dir.create('pdf', showWarnings=FALSE)

x = 5
y = -20
efficacy_vs_bc_emissions_rnn = df_efficacy_rnn_data_augmentation %>% filter (model == "dt = 6") %>%
    select (strategy, scenario, prediction_ecum, efficacy) %>%
    mutate (prediction_ecum_bc = prediction_ecum[strategy == "Broadcast"], .by = scenario) %>%
    filter (strategy != "Broadcast") %>%
    ggplot () +
        geom_point (aes (y = efficacy, x = prediction_ecum_bc)) +
        facet_wrap (~ strategy, nrow = 1) +
        xlab ("Broadcast emissions (kgN/ha)") +
        geom_vline (xintercept = 10, linetype = 2) +
        expand_limits (x = c (0, 70), y = c (- 100, 220)) +
        geom_hline (yintercept = 0, linetype = 2) +
        theme (plot.margin = ggplot2::margin (30, 40, 20, 10, "pt")) +
        ggtitle ("rnn 9 - data a.") +
        theme (plot.title = element_text (hjust = 0)) +
        ylab ("Efficacy (%)")


efficacy_vs_bc_emissions_static_nn = df_efficacy_static_nn %>%
    select (strategy, scenario, prediction_ecum, efficacy) %>%
    mutate (prediction_ecum_bc = prediction_ecum[strategy == "Broadcast"], .by = scenario) %>%
    filter (strategy != "Broadcast") %>%
    ggplot () +
        geom_point (aes (y = efficacy, x = prediction_ecum_bc)) +
        facet_wrap (~ strategy, nrow = 1) +
        xlab ("Broadcast emissions (kgN/ha)") +
        geom_vline (xintercept = 10, linetype = 2) +
        expand_limits (x = c (0, 70), y = c (- 100, 220)) +
        geom_hline (yintercept = 0, linetype = 2) +
        theme (plot.margin = ggplot2::margin (30, 40, 20, 10, "pt")) +
        ggtitle ("static nn 12") +
        theme (plot.title = element_text (hjust = 0)) +
        ylab ("Efficacy (%)")


efficacy_vs_bc_emissions_dynamic_random_forest = df_efficacy_dynamic_rf %>%
    mutate (strategy = factor (strategy, levels = c ("Broadcast", "Incorporation", "Trailing hose", "Trailing shoe", "Open slot", "Closed slot"))) %>%
    select (strategy, scenario, prediction_ecum = e.cum_hat, efficacy) %>%
    mutate (prediction_ecum_bc = prediction_ecum[strategy == "Broadcast"], .by = scenario) %>%
    filter (strategy != "Broadcast") %>%
    ggplot () +
        geom_point (aes (y = efficacy, x = prediction_ecum_bc)) +
        facet_wrap (~ strategy, nrow = 1) +
        xlab ("Broadcast emissions (kgN/ha)") +
        geom_vline (xintercept = 10, linetype = 2) +
        geom_hline (yintercept = 0, linetype = 2) +
        expand_limits (x = c (0, 70), y = c (- 100, 220)) +
        theme (plot.margin = ggplot2::margin (30, 40, 20, 10, "pt")) +
        ggtitle ("dynamic rf - 2") +
        theme (plot.title = element_text (hjust = 0)) +
        ylab ("Efficacy (%)")


efficacy_vs_bc_emissions_static_random_forest = df_efficacy_static_rf %>%
    mutate (strategy = factor (strategy, levels = c ("Broadcast", "Incorporation", "Trailing hose", "Trailing shoe", "Open slot", "Closed slot"))) %>%
    select (strategy, scenario, prediction_ecum = e.cum_hat, efficacy) %>%
    mutate (prediction_ecum_bc = prediction_ecum[strategy == "Broadcast"], .by = scenario) %>%
    filter (strategy != "Broadcast") %>%
    ggplot () +
        geom_point (aes (y = efficacy, x = prediction_ecum_bc)) +
        facet_wrap (~ strategy, nrow = 1) +
        xlab ("Broadcast emissions (kgN/ha)") +
        geom_vline (xintercept = 10, linetype = 2) +
        geom_hline (yintercept = 0, linetype = 2) +
        expand_limits (x = c (0, 70), y = c (- 100, 220)) +
        theme (plot.margin = ggplot2::margin (30, 40, 20, 10, "pt")) +
        ggtitle ("static rf") +
        theme (plot.title = element_text (hjust = 0)) +
        ylab ("Efficacy (%)")


efficacy_vs_bc_emissions_ALFAM2 = df_efficacy_ALFAM2 %>%
    mutate (strategy = factor (strategy, levels = c ("Broadcast", "Incorporation", "Trailing hose", "Trailing shoe", "Open slot", "Closed slot"))) %>%
    select (strategy, scenario, prediction_ecum, efficacy) %>%
    mutate (prediction_ecum_bc = prediction_ecum[strategy == "Broadcast"], .by = scenario) %>%
    filter (strategy != "Broadcast") %>%
    ggplot () +
        geom_point (aes (y = efficacy, x = prediction_ecum_bc)) +
        facet_wrap (~ strategy, nrow = 1) +
        xlab ("Broadcast emissions (kgN/ha)") +
        geom_vline (xintercept = 10, linetype = 2) +
        geom_hline (yintercept = 0, linetype = 2) +
        expand_limits (x = c (0, 70), y = c (- 100, 220)) +
        theme (plot.margin = ggplot2::margin (30, 40, 20, 10, "pt")) +
        ggtitle ("ALFAM2") +
        theme (plot.title = element_text (hjust = 0)) +
        ylab ("Efficacy (%)")


grDevices::cairo_pdf('pdf/fig19_appendix.pdf', width=pdf_width/72, height=1500/72, family=FIGURE_FONT, onefile=FALSE)
grid.arrange (
    efficacy_vs_bc_emissions_ALFAM2 + theme (plot.margin = ggplot2::margin (y, 0, x, 0)),
    efficacy_vs_bc_emissions_static_random_forest + theme (plot.margin = ggplot2::margin (y, 0, x, 0)),
    efficacy_vs_bc_emissions_dynamic_random_forest + theme (plot.margin = ggplot2::margin (y, 0, x, 0)),
    efficacy_vs_bc_emissions_static_nn + theme (plot.margin = ggplot2::margin (y, 0, x, 0)), 
    efficacy_vs_bc_emissions_rnn + theme (plot.margin = ggplot2::margin (y, 0, x, 0)),
    ncol = 1
)
grDevices::dev.off()
publish_pdf('fig19_appendix.pdf')
