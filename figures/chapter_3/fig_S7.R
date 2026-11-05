# ---------------------------------------------------------------------
### Set up
packages = c(

      "ggplot2",
      "dplyr",
      "tibble", # rownames_to_column
      "tidyr", # pivot_longer
      "stringr", # str_replace
      "gridExtra" # grid.arrange

)

suppressWarnings( suppressMessages (invisible (lapply (packages, FUN = function(X) {do.call ("library", list(X))}))))

data_file = "data/data.csv"
figures_directory = "pdf"

dir.create(figures_directory, recursive = TRUE, showWarnings = FALSE)

source("functions/R_functions.R")



f_theme()

options(
  ggplot2.discrete.colour = function(...) {
    scale_colour_brewer(palette = "Dark2", ...)
  },
  ggplot2.discrete.fill = function(...) {
    scale_fill_brewer(palette = "Dark2", ...)
  }
)



data = read.csv (file = data_file)





# ---------------------------------------------------------------------
### Final cumulative emissions according to measurement method
data_final_cum_by_meas_tech = data %>%
  filter (ct_origin == max (ct_origin), .by = id) %>%
  mutate (meas_tech_group = if_else (meas_tech_origin == "micro met", "Micrometeorological methods", "Other methods")) %>%
  mutate (meas_tech_group = factor (meas_tech_group, levels = c ("Micrometeorological methods", "Other methods")))

fig_S7 = data_final_cum_by_meas_tech %>%
  ggplot () +
    geom_histogram (aes (x = e_cum_origin), bins = 30, fill = "#67c5a7", color = "white") +
    facet_wrap (~ meas_tech_group, scales = "free_y", nrow = 2) +
    xlab (expression("Final cumulative emissions (kg N-" * plain(NH)[3] * " ha"^{-1} * ")")) +
    ylab ("Number of plots")

cairo_pdf (file = file.path(figures_directory, "fig_S7.pdf"), width = 10, height = 8, family = FIGURE_FONT)
fig_S7
dev.off()
publish_pdf("fig_S7.pdf")
