args <- commandArgs(trailingOnly = FALSE)
script <- sub("^--file=", "", args[grepl("^--file=", args)])
setwd(dirname(normalizePath(script)))
dir.create("build", showWarnings = FALSE)
source("theme.R")
axis_size <- discussion_theme(12)
#!/usr/bin/env Rscript

input <- file.path("data", "DataManField.csv")
output_dir <- "build"
figure_output_dir <- "pdf"
d <- read.csv(input, check.names = FALSE, stringsAsFactors = FALSE,
              na.strings = c("", "NA"))
d <- d[d$GasMeasured == "NH3", ]

variables <- c(
  "CumulatEmission", "NH3CumulEmission72h", "DurationOfEmissionMeasurement",
  "EmissionMeasTechnique", "ManureApplicMethod", "ManureDM",
  "ManurePH", "ManureApplicRate", "ManureTANApplicRate",
  "ManureSoilIncorporation", "SoilClay", "SoilPH", "SoilTexture", "CropType",
  "NH3CropHeight", "NH3AirTemperature24hAvg", "NH3RainIrrigation1h",
  "NH3RainIrrigation6h", "NH3WindSpeed12h"
)
stopifnot(all(variables %in% names(d)))
missing_n <- vapply(d[variables], function(x) sum(is.na(x)), integer(1))
missing_pct <- 100 * missing_n / nrow(d)
variable_labels <- c(
  CumulatEmission = "Cumulative emission",
  NH3CumulEmission72h = "Cumulative emission at 72 h",
  DurationOfEmissionMeasurement = "Emission measurement duration",
  EmissionMeasTechnique = "Emission measurement technique",
  ManureApplicMethod = "Manure application method",
  ManureDM = "Manure dry matter",
  ManurePH = "Manure pH",
  ManureApplicRate = "Manure application rate",
  ManureTANApplicRate = "Manure TAN application rate",
  ManureSoilIncorporation = "Manure soil incorporation",
  SoilClay = "Soil clay content",
  SoilPH = "Soil pH",
  SoilTexture = "Soil texture",
  CropType = "Crop type",
  NH3CropHeight = "Crop height",
  NH3AirTemperature24hAvg = "Mean air temperature over 24 h",
  NH3RainIrrigation1h = "Rainfall or irrigation within 1 h",
  NH3RainIrrigation6h = "Rainfall or irrigation within 6 h",
  NH3WindSpeed12h = "Mean wind speed over 12 h"
)
stopifnot(all(variables %in% names(variable_labels)))
plot_variables <- rev(unname(variable_labels[variables]))
plot_n <- rev(missing_n)
plot_pct <- rev(missing_pct)

plot_data <- data.frame(
  variable = factor(plot_variables, levels = plot_variables),
  missing_pct = plot_pct,
  missing_n = plot_n,
  category = ifelse(plot_pct < 10, "low", ifelse(plot_pct < 40, "medium", "high"))
)
missing_plot <- ggplot(plot_data, aes(missing_pct, variable)) +
  geom_col(aes(fill = category), width = 0.8) +
  geom_text(aes(
    x = missing_pct + 1.2,
    label = sprintf("%.1f%%  (n = %s)", missing_pct, format(missing_n, big.mark = ",", trim = TRUE))
  ), hjust = 0, colour = "grey30") +
  scale_fill_manual(values = c(low = "#1B9E77", medium = "#E6AB02", high = "#D95F02")) +
  scale_x_continuous(breaks = seq(0, 100, 20), labels = function(x) paste0(x, "%")) +
  coord_cartesian(xlim = c(0, 125), clip = "off") +
  labs(x = "Missing values (%)", y = NULL) +
  theme(
    legend.position = "none",
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 0.7 * axis_size),
    axis.text.y = element_text(size = 0.7 * axis_size),
    axis.title.x = element_text(size = 0.85 * axis_size)
  )

dir.create(figure_output_dir, recursive = TRUE, showWarnings = FALSE)
ggsave(file.path(figure_output_dir, "fig_05.pdf"), missing_plot,
       width = 12, height = 9.8, device = cairo_pdf, family = FIGURE_FONT)
publish_pdf("fig_05.pdf")


write.csv(data.frame(variable = variables, missing_n = missing_n,
                     missing_pct = round(missing_pct, 1)),
          file.path(output_dir, "dataman_missing_values_summary.csv"),
          row.names = FALSE)
