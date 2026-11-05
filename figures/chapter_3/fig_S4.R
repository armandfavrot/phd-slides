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
### Variability of emissions according to manure source

data_tmp = data %>%
  filter (meas_tech_origin == "micro met") %>%
  filter (fer_origin_origin %in% c ("pig", "cat")) %>%
  filter (ct_origin == max (ct_origin), .by = id) %>%
  mutate (fer_origin_origin = recode (fer_origin_origin, "pig" = "Pig", "cat" = "Cattle"))

data_tmp_quantiles = data_tmp %>%
  summarise (q = list (quantile (e_cum_origin, probs = c (0.1, 0.5, 0.9), na.rm = TRUE)),
             .by = fer_origin_origin) %>%
  unnest_longer (q, values_to = "e_cum_quantile")

data_tmp_mean = data_tmp %>%
  summarise (e_cum_mean = mean (e_cum_origin, na.rm = TRUE), .by = fer_origin_origin)

fig_S4 = data_tmp %>%
  ggplot () +
    geom_histogram (aes (x = e_cum_origin), fill = "#67c5a7", color = "white") +
    geom_vline (data = data_tmp_quantiles,
                aes (xintercept = e_cum_quantile),
                color = "red",
                linetype = "dashed",
                linewidth = 1) +
    geom_vline (data = data_tmp_mean,
                aes (xintercept = e_cum_mean),
                color = "black",
                linetype = "solid",
                linewidth = 1) +
    facet_wrap (~ fer_origin_origin, nrow = 2) +
    xlab (expression("Final cumulative emissions (kg N-" * plain(NH)[3] * " ha"^{-1} * ")")) +
    ylab ("Number of plots")

cairo_pdf (file = file.path(figures_directory, "fig_S4.pdf"), width = 10, height = 8, family = FIGURE_FONT)
fig_S4
dev.off()
publish_pdf("fig_S4.pdf")
