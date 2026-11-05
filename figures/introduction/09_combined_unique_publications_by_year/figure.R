#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = FALSE)
setwd(dirname(normalizePath(sub("^--file=", "", args[grepl("^--file=", args)][1]))))
source("../../common.R")
init_figure_environment("introduction", normalizePath(".."))
library(ggplot2)
latex_linewidth <- 1.1
pdf_width <- 9.5 * 72
pdf_height <- 5.8 * 72
layout_ratio <- 424.06033 / 483.69687
reference_size <- 32 * layout_ratio
axis_title_size <- reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size <- 0.8 * axis_title_size
axis_y_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
theme_update(
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
publication_counts <- read.csv("data.csv")
left_max <- max(publication_counts$n_publications)
right_max <- max(publication_counts$cumulative_publications)
scale_factor <- left_max / right_max

p <- ggplot(publication_counts, aes(x = year)) +
  geom_col(aes(y = n_publications), width = 0.85, fill = "#8FBCE6") +
  geom_line(
    aes(y = cumulative_publications * scale_factor),
    color = "#E15759",
    linewidth = 0.9
  ) +
  geom_point(
    aes(y = cumulative_publications * scale_factor),
    color = "#E15759",
    size = 1.8
  ) +
  scale_x_continuous(
    breaks = seq(1960, 2025, by = 5),
    minor_breaks = seq(1960, 2025, by = 1)
  ) +
  scale_y_continuous(
    name = "Number of publications",
    sec.axis = sec_axis(~ . / scale_factor, name = "Cumulative publications")
  ) +
  labs(x = "Publication year") +
  theme(
    axis.title = element_text(face = "bold"),
    axis.title.x = element_text(face = "plain", margin = margin(t = axis_x_margin)),
    axis.title.y.left = element_text(color = "#4F8FC9", margin = margin(r = 10)),
    axis.title.y.right = element_text(color = "#E15759", margin = margin(l = 10)),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor.y = element_blank(),
    plot.margin = margin(8, 10, 8, 10)
  )

ggsave("../pdf/combined_unique_publications_by_year.pdf", p,
       width = pdf_width / 72, height = pdf_height / 72, device = cairo_pdf)
publish_pdf("combined_unique_publications_by_year.pdf")
