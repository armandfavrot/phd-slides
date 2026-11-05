#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = FALSE)
setwd(dirname(normalizePath(sub("^--file=", "", args[grepl("^--file=", args)][1]))))
source("../../common.R")
init_figure_environment("introduction", normalizePath(".."))
library(ggplot2)

input_file <- "data.csv"
out_dir <- "."
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

counts <- read.csv(input_file, stringsAsFactors = FALSE)
counts$database <- factor(
  counts$database,
  levels = c("ALFAM2", "Peng Xu et al. 2024", "ELFE NH3 spreading", "DATAMAN NH3", "Hutchings et al. 2026")
)

plot_data <- rbind(
  data.frame(
    database = counts$database,
    status = "Publication available",
    n = counts$publication_available,
    stringsAsFactors = FALSE
  ),
  data.frame(
    database = counts$database,
    status = "Missing publication",
    n = counts$missing_publication,
    stringsAsFactors = FALSE
  )
)
plot_data$status <- factor(plot_data$status, levels = c("Publication available", "Missing publication"))

total_labels <- data.frame(
  database = counts$database,
  total_plots = counts$total_plots,
  y = counts$total_plots,
  label = paste0("n = ", counts$total_plots),
  stringsAsFactors = FALSE
)

p <- ggplot(plot_data, aes(x = database, y = n, fill = status)) +
  geom_col(width = 0.72) +
  geom_text(
    data = total_labels,
    aes(x = database, y = y, label = label),
    inherit.aes = FALSE,
    vjust = -0.35,
    size = 4.5
  ) +
  scale_fill_manual(values = c(
    "Publication available" = "#59A14F",
    "Missing publication" = "#E15759"
  )) +
  labs(
    x = NULL,
    y = "Number of plots",
    fill = NULL
  ) +
  expand_limits(y = max(counts$total_plots) * 1.14) +
  theme(
    axis.title.y = element_text(size = 20, margin = margin(r = 12)),
    axis.text.x = element_text(size = 18, angle = 25, hjust = 1, margin = margin(t = 2)),
    axis.text.y = element_text(size = 16),
    legend.position = "top",
    legend.text = element_text(size = 18),
    legend.margin = margin(b = 0),
    legend.box.margin = margin(b = -0),
    panel.grid.minor = element_blank(),
    plot.margin = margin(5, 8, 5, 8)
  )

output_pdf <- file.path(out_dir, "database_overlap_histogram_standalone.pdf")

ggsave(output_pdf, p, width = 7.2, height = 5.56)

cat("PDF written:", output_pdf, "\n")

