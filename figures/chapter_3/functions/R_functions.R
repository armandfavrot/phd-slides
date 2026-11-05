# Exact calibration used by figures/chapter_3, without loading its old results.
source("../common.R")
init_figure_environment("chapter_3", getwd())

f_theme <- function() {
    script <- basename(sub("^--file=", "", commandArgs()[grepl("^--file=", commandArgs())][1]))
    number <- sub("\\.R$", "", sub("^fig_", "", script))
    # Additional fold-level figures inherit the all-method supplementary theme.
    reference <- if (number %in% c("S9", "S10", "S11")) "S2" else number
    latex_linewidth <- if (reference %in% c("S4", "S7")) 0.9 else if (reference == "S5") 1.1 else 1
    pdf_width <- if (reference == "1") 864 else if (reference %in% c("S4", "S7")) 720 else 1008
    layout_ratio <- 424.06033 / 483.69687
    axis_title_size <- 32 * layout_ratio * (pdf_width / 1000) / latex_linewidth
    axis_text_size <- 0.8 * axis_title_size
    axis_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
    strip_ratio <- if (reference %in% c("S2", "S3", "S5", "S6")) 0.8 else 0.9
    legend_ratio <- if (reference == "5") 0.87 else if (reference %in% c("7", "S1", "S2", "S3")) 0.95 else 1

    theme_update(
        axis.title.x = element_text(size = axis_title_size, margin = margin(t = axis_margin)),
        axis.text.x = element_text(size = axis_text_size),
        axis.title.y = element_text(size = (if (reference == "5") 0.9 else 1) * axis_title_size, margin = margin(r = axis_margin)),
        axis.text.y = element_text(size = axis_text_size),
        strip.text = element_text(size = strip_ratio * axis_title_size),
        plot.title = element_text(size = axis_title_size),
        legend.title = element_text(size = legend_ratio * axis_title_size, face = "bold", margin = margin(r = axis_margin)),
        legend.text = element_text(size = legend_ratio * axis_title_size)
    )
    update_geom_defaults("text", list(size = 0.6 * axis_text_size / ggplot2::.pt))

    if (reference == "1") {
        theme_update(
            panel.grid.major = element_line(colour = "white", linewidth = 0.3),
            panel.grid.minor = element_line(colour = "white", linewidth = 0.15),
            panel.grid.minor.x = element_blank()
        )
    }
    if (reference %in% c("5", "6", "7", "S1", "S2", "S3")) {
        theme_update(
            legend.position = "bottom",
            legend.key.height = unit(0.6, "cm"),
            axis.title.x = element_text(margin = margin(t = axis_margin, b = 10)),
            strip.text.x = element_text(colour = "black"),
            strip.text.y = element_text(angle = 270, colour = "black", margin = margin(0, 14, 0, 14)),
            strip.background = element_rect(fill = "#e5e5e5"),
            panel.spacing = unit(1.4, "lines")
        )
        if (reference != "5") theme_update(legend.key.spacing.x = unit(0.6, "cm"))
    }
}
