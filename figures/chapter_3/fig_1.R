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



data = read.csv (file = data_file)





# ---------------------------------------------------------------------
### Figure 1 : data description
fig_1 = data %>%
  mutate (meas_tech_origin = recode (meas_tech_origin, "wt" = "Wind tunnel", "CaractAir" = "CaractAir", "cps" = "Cps", "micro met" = "Micromet.", "chamber" = "Dynamic chamber")) %>%
  mutate (meas_tech_origin = factor (meas_tech_origin, levels = c ("Micromet.", "Cps", "Wind tunnel", "Dynamic chamber", "CaractAir"))) %>%
  ggplot () +
    #geom_line (aes (x = ct_origin, y = e_cum_origin / tan_app_origin, group = id), alpha = 0.1) +
    geom_line (aes (x = ct_origin, y = e_cum_origin, group = id), alpha = 0.1) +
    facet_wrap (~ meas_tech_origin, scales = "free_x") +
    theme (axis.title.x = theme_get()$axis.title.x) +
    xlab ("Time since fertilizer application (h)") +
    #ylab ("Cumulative emissions (frac. applied TAN)") +
    ylab (expression("Ammonia emissions (kg N-" * plain(NH)[3] * " ha"^{-1} * ")"))

cairo_pdf (file = file.path(figures_directory, "fig_1.pdf"), width = 12, height = 8, family = FIGURE_FONT)
fig_1
dev.off()
publish_pdf("fig_1.pdf")
