# Observations/prédictions sur le jeu d'évaluation.
.script <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(.script)) .script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
figure_dir <- dirname(normalizePath(.script))
source(file.path(figure_dir, "..", "common.R"), local = TRUE)
init_figure_environment("chapter_1", figure_dir)

latex_linewidth <- 1  # coefficient de width=...\linewidth dans main.tex
pdf_width <- 1000       # largeur du PDF exporté, en points
pdf_height <- 700      # hauteur du PDF exporté, en points
layout_ratio <- 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size <- reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.8 * axis_title_size
axis_y_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)

theme_update (axis.title.x = element_text(size = axis_title_size, margin = ggplot2::margin(t = axis_x_margin)),
       axis.text.x = element_text (size = axis_text_size),
       axis.title.y = element_text (size = axis_title_size, margin = ggplot2::margin (r = axis_y_margin)),
       axis.text.y = element_text (size = 1 * axis_text_size),
       strip.text = element_text (size = 0.9 * axis_title_size),
       plot.title = element_text (size = axis_title_size),
       legend.title = element_text(size = 1 * axis_title_size, face = "bold", margin = ggplot2::margin(r = legend_title_margin)),
       legend.text = element_text (size = axis_title_size))

update_geom_defaults(
  "text",
  list(size = 0.6 * axis_text_size / ggplot2::.pt)
)

d <- subset(read_data("predictions"), dataset == "Evaluation subset")
d$method <- model_names(d$method)
p <- ggplot(d, aes(truth_e, e, colour = method)) +
  geom_point(size = 3) + geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  facet_wrap(~method) + scale_colour_manual(values = MODEL_COLORS) +
  labs(x = "Observed values (kg/ha)", y = "Predicted values (kg/ha)") +
  theme(legend.position = "none")
export_pdf(p, "Figure_2", width = pdf_width/72, height = pdf_height/72)
