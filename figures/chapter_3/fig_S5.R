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
### Distribution of manure characteristics for cattle vs non-cattle
data_fer_characteristics_base = data %>%
  select (id, meas_tech_origin, fer_origin_origin,
          fer_dm_origin, fer_ph_origin, tan_app_origin,
          app_rate_origin, soil_water_origin, soil_ph_origin,
          soil_dens_origin, soil_oc_origin, crop_z_origin) %>%
  distinct (id, .keep_all = TRUE) %>%
  pivot_longer (cols = c (fer_dm_origin, fer_ph_origin, tan_app_origin,
                          app_rate_origin, soil_water_origin, soil_ph_origin,
                          soil_dens_origin, soil_oc_origin, crop_z_origin),
                names_to = "variable",
                values_to = "value") %>%
  filter (!is.na (value)) %>%
  mutate (variable = recode (variable,
                             "fer_dm_origin" = "Fertilizer dry matter (%)",
                             "fer_ph_origin" = "Fertilizer pH",
                             "tan_app_origin" = "Applied TAN (kg N-NH3/ha)",
                             "app_rate_origin" = "Application rate (t/ha)",
                             "soil_water_origin" = "Soil water (fraction of volume)",
                             "soil_ph_origin" = "Soil pH",
                             "soil_dens_origin" = "Soil bulk density",
                             "soil_oc_origin" = "Soil organic carbon (%)",
                             "crop_z_origin" = "Crop height (cm)")) %>%
  mutate (variable = factor (variable,
                             levels = c ("Fertilizer dry matter (%)", "Fertilizer pH", "Applied TAN (kg N-NH3/ha)",
                                        "Application rate (t/ha)", "Soil water (fraction of volume)", "Soil pH",
                                        "Soil bulk density", "Soil organic carbon (%)", "Crop height (cm)")))

data_fer_characteristics_cattle = data_fer_characteristics_base %>%
  filter (! (fer_origin_origin == "cat" & meas_tech_origin != "micro met")) %>%
  mutate (fer_origin_group = if_else (fer_origin_origin == "cat", "mm cattle", "non-cattle")) %>%
  mutate (fer_origin_group = factor (fer_origin_group, levels = c ("mm cattle", "non-cattle")))

fig_S5 = data_fer_characteristics_cattle %>%
  ggplot (aes (x = fer_origin_group, y = value, fill = fer_origin_group)) +
    geom_boxplot (varwidth = TRUE) +
    facet_wrap (~ variable, scales = "free", ncol = 2) +
    xlab (NULL) +
    ylab (NULL) +
    guides (fill = "none")

cairo_pdf (file = file.path(figures_directory, "fig_S5.pdf"), width = 14, height = 18, family = FIGURE_FONT)
fig_S5
dev.off()
publish_pdf("fig_S5.pdf")
