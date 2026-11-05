# Shared thesis theme, calibrated for inclusion at 1 linewidth (424.06033 pt).
source("../common.R")
init_figure_environment("discussion", getwd())

discussion_theme <- function(width_inches) {
  axis_size <- 32 * (424.06033 / 483.69687) * (72 * width_inches / 1000)
  axis_margin <- 15 * (424.06033 / 483.69687) * (72 * width_inches / 1200) * 1.2
  theme_update(
    axis.title.x = element_text(size = axis_size, margin = margin(t = axis_margin)),
    axis.title.y = element_text(size = axis_size, margin = margin(r = axis_margin)),
    axis.text = element_text(size = 0.8 * axis_size),
    strip.text = element_text(size = 0.9 * axis_size),
    plot.title = element_text(size = axis_size),
    legend.title = element_text(size = 0.95 * axis_size, face = "bold"),
    legend.text = element_text(size = 0.95 * axis_size)
  )
  update_geom_defaults("text", list(size = 0.6 * 0.8 * axis_size / ggplot2::.pt))
  invisible(axis_size)
}
