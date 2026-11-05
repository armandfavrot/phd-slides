#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = FALSE)
setwd(dirname(normalizePath(sub("^--file=", "", args[grepl("^--file=", args)][1]))))
source("../../common.R")
init_figure_environment("introduction", normalizePath(".."))
library(ggplot2)
library(dplyr)


latex_linewidth <- 1
pdf_width <- 1296
pdf_height <- 720
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
  legend.text = element_text(size = 0.82 * axis_title_size)
)
update_geom_defaults("text", list(size = 0.6 * axis_text_size / ggplot2::.pt))
data_nh3 <- read.csv("data.csv")
### Figure 3

data_tmp = data_nh3 %>%
    filter (notation != "IE") %>%
    filter (country %in% c ("EU27", "France"))

data_plot = data_tmp %>%
    filter (! (is.na (value))) %>%
    mutate (agriculture = ifelse (substr (sectorCode, 1, 1) == "3", "yes", "no")) %>% 
    filter (sectorName != "NATIONAL TOTAL FOR COMPLIANCE") %>%

    mutate (type = ifelse (grepl ("Manure management", sectorName), "Manure management", sectorName)) %>%
    mutate (type = ifelse (sectorName %in% c (
        "Agriculture other (please specify in the IIR)",
        "Crop residues applied to soils",
        "Cultivated crops",
        "Farm-level agricultural operations including storage, handling and transport of agricultural products",
        "Field burning of agricultural residues",
        "Indirect emissions from managed soils",
        "Off-farm storage, handling and transport of bulk agricultural products",
        "Use of pesticides"), "Other (agriculture)", type)) %>%
    mutate (type = ifelse (agriculture == "no", "Other than agriculture", type)) %>%

    mutate (type = factor (type, levels = c (
        "Inorganic N-fertilizers (includes also urea application)",
        "Animal manure applied to soils",
        "Other organic fertilisers applied to soils (including compost)",
        "Sewage sludge applied to soils",
        "Manure management",
        "Urine and dung deposited by grazing animals",
        "Other (agriculture)",
        "Other than agriculture")))

plot = data_plot %>%
    filter (year >= 2005) %>%
    summarise (value = sum (value), .by = c (type, year, country)) %>%
    mutate (value = value / 1000) %>%
    mutate (country = factor (country, levels = c ("France", "EU27"))) %>%
    ggplot () +
        geom_area (aes (x = year, y = value, fill = type), position = "stack") +
        facet_wrap (~ country, scale = "free_y") +
        theme (legend.key.spacing.x = unit (0.5, "cm"), legend.position = "bottom") +
        scale_fill_manual (
          values = Dark2,
          labels = function(x) {
            x <- sub(" \\(includes also urea application\\)$", "", x)
            sub(" \\(including compost\\)$", "", x)
          }
        ) +
        ylab ("N-NH3 emissions (Mt)") +
        guides(fill = guide_legend(nrow = 4)) +
        labs (fill = "") +
        xlab ("") +
        theme (axis.title.x = element_text (margin = margin(t = axis_x_margin, b = -20))) +
        NULL

ggsave("../pdf/nh3_emissions_dynamique.pdf", plot,
       width = pdf_width / 72, height = pdf_height / 72, device = cairo_pdf)
publish_pdf("nh3_emissions_dynamique.pdf")
