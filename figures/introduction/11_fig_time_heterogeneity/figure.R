#!/usr/bin/env Rscript
# Adapted from fig_time_heterogeneity/fig_time_heterogeneity.R.
args <- commandArgs(trailingOnly = FALSE)
setwd(dirname(normalizePath(sub("^--file=", "", args[grepl("^--file=", args)][1]))))
source("../../common.R")
init_figure_environment("introduction", normalizePath(".."))
library(ggplot2)
library(dplyr)

# Parameters: fixed seed reproduces the original selection.
seed <- 4
n_trials <- 30


latex_linewidth <- 1
pdf_width <- 864
pdf_height <- 576
layout_ratio <- 424.06033 / 483.69687
reference_size <- 32 * layout_ratio
axis_title_size <- reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size <- 0.8 * axis_title_size
axis_y_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
theme_update(
  text = element_text(family = "Latin Modern Roman"),
  axis.title.x = element_text(size = axis_title_size, margin = ggplot2::margin(t = axis_x_margin)),
  axis.text.x = element_text(size = axis_text_size),
  axis.title.y = element_text(size = axis_title_size, margin = ggplot2::margin(r = axis_y_margin)),
  axis.text.y = element_text(size = axis_text_size),
  strip.text = element_text(size = 0.9 * axis_title_size),
  plot.title = element_text(size = axis_title_size),
  legend.title = element_text(size = axis_title_size, face = "bold", margin = ggplot2::margin(r = legend_title_margin)),
  legend.text = element_text(size = axis_title_size)
)
update_geom_defaults("text", list(size = 0.6 * axis_text_size / ggplot2::.pt))

data = read.csv (file = "data.csv")

### Figure time heterogeneity --------------------------------------------------------------------------------------------------------------------------------
set.seed(seed)
pmids = data$id %>% unique
pmids_tmp = sample(pmids, n_trials)

df = NULL
for (pmid in pmids_tmp) {
    df_tmp = data %>% filter (id == pmid)
    df = rbind (df, rbind (df_tmp[1, ] %>% mutate (ct_origin = 0, e_cum_origin = 0), df_tmp))
}

fig_time_heterogeneity = df %>%
    ggplot () +
        geom_line (aes (x = ct_origin, y = e_cum_origin, group = id), linewidth = 0.01) +
        geom_point (aes (x = ct_origin, y = e_cum_origin, group = id), size = 1.2) +
        xlab ("Time since fertilizer application (h)") +
        ylab (expression("Cumulative emissions (kg N-" * plain(NH)[3] * " ha"^{-1} * ")")) +
        NULL

dir.create("../pdf", showWarnings = FALSE)
cairo_pdf(file = "../pdf/fig_time_heterogeneity.pdf",
          width = pdf_width / 72, height = pdf_height / 72,
          family = "Latin Modern Roman")
fig_time_heterogeneity
dev.off()
publish_pdf("fig_time_heterogeneity.pdf")
