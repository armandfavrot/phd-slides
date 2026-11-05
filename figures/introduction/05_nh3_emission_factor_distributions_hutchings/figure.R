#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = FALSE)
setwd(dirname(normalizePath(sub("^--file=", "", args[grepl("^--file=", args)][1]))))
source("../../common.R")
init_figure_environment("introduction", normalizePath(".."))
library(ggplot2)
library(patchwork)


alfam_file <- "alfam.csv"
latex_linewidth <- 1.1
pdf_width <- 1100
pdf_height <- 470
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
histogram_colors <- as.character(Couleurs$Dark2[1:2])
names(histogram_colors) <- c(
  "Organic fertilizers",
  "Synthetic fertilizers"
)

# Organic fertilizers: ALFAM2 cumulative NH3-N loss as a fraction of applied
# TAN. Convert to percent and retain physically interpretable observations.
alfam <- read.csv(
  alfam_file,
  check.names = FALSE,
  stringsAsFactors = FALSE
)
organic_loss_percent_all <- 100 * alfam$e.rel.final
organic_loss_percent <- organic_loss_percent_all[
  is.finite(organic_loss_percent_all) &
    organic_loss_percent_all >= 0 &
    organic_loss_percent_all <= 100
]

# Mineral fertilizers: Hutchings et al. NH3loss is already expressed as a
# percentage. Retain field trials only, identified as Place == "Outdoor".
hutchings <- read.csv("hutchings.csv")
field_trials <- hutchings[hutchings$Place == "Outdoor", ]

mineral_loss_percent_all <- field_trials$NH3loss
mineral_loss_percent <- mineral_loss_percent_all[
  is.finite(mineral_loss_percent_all) &
    mineral_loss_percent_all >= 0 &
    mineral_loss_percent_all <= 100
]

n_alfam_negative <- sum(organic_loss_percent_all < 0, na.rm = TRUE)
n_alfam_over_100 <- sum(organic_loss_percent_all > 100, na.rm = TRUE)
n_hutchings_negative <- sum(mineral_loss_percent_all < 0, na.rm = TRUE)
n_hutchings_over_100 <- sum(mineral_loss_percent_all > 100, na.rm = TRUE)

plot_data <- rbind(
  data.frame(
    fertilizer_type = "Organic fertilizers",
    loss_percent = organic_loss_percent
  ),
  data.frame(
    fertilizer_type = "Synthetic fertilizers",
    loss_percent = mineral_loss_percent
  )
)
plot_data$fertilizer_type <- factor(
  plot_data$fertilizer_type,
  levels = c("Organic fertilizers", "Synthetic fertilizers")
)

make_histogram <- function(data, x_label, y_label = NULL) {
  ggplot(data, aes(x = loss_percent, fill = fertilizer_type)) +
  geom_histogram(
    binwidth = 5,
    boundary = 0,
    closed = "left",
    colour = "white",
    linewidth = 0.45
  ) +
  facet_wrap(vars(fertilizer_type), nrow = 1) +
  scale_fill_manual(values = histogram_colors) +
  scale_x_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, by = 20),
    expand = expansion(mult = c(0, 0.01))
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.06))
  ) +
  labs(x = x_label, y = y_label) +
  guides(fill = "none") +
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(
      colour = "#D7E5EC",
      linewidth = 0.45
    ),
    panel.grid.minor.y = element_line(
      colour = "#E8F0F4",
      linewidth = 0.3
    ),
    plot.margin = margin(0, 8, 0, 8)
  )
}

organic_figure <- make_histogram(
  plot_data[plot_data$fertilizer_type == "Organic fertilizers", ],
  expression(paste("NH"[3], "-N loss (% of applied TAN)")),
  "Number of observations"
)
mineral_figure <- make_histogram(
  plot_data[plot_data$fertilizer_type == "Synthetic fertilizers", ],
  expression(paste("NH"[3], "-N loss (% of applied N)"))
)

figure <- organic_figure + mineral_figure + plot_layout(nrow = 1)

ggsave("../pdf/nh3_emission_factor_distributions_hutchings.pdf", figure,
       width = pdf_width / 72, height = pdf_height / 72, device = cairo_pdf)
publish_pdf("nh3_emission_factor_distributions_hutchings.pdf")
