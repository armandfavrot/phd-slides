# Métriques, évaluation puis calibration ; assemblage réalisé directement en R.
.script <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(.script)) .script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
figure_dir <- dirname(normalizePath(.script))
source(file.path(figure_dir, "..", "common.R"), local = TRUE)
init_figure_environment("chapter_1", figure_dir)

latex_linewidth <- 1  # coefficient de width=...\linewidth dans main.tex
pdf_width <- 1000       # largeur du PDF exporté, en points
pdf_height <- 720      # hauteur du PDF exporté, en points
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

d <- subset(read_data("metrics"), response == "72h cum. emission")
d$method <- model_names(d$method)
metrics <- c("Pearsons_r", "ME", "MAE", "MBE")
long <- do.call(rbind, lapply(metrics, function(m) data.frame(d[c("dataset", "method")], metric = m, value = d[[m]])))
long$metric <- factor(long$metric, levels = metrics,
                      labels = c("Pearson's r", "ME", "MAE", "MBE"))
panel <- function(dataset, legend) {
  ggplot(long[long$dataset == dataset, ], aes(metric, value, fill = method)) +
    geom_col(position = "dodge") + facet_wrap(~metric, scales = "free", nrow = 1) +
    scale_fill_manual(values = MODEL_COLORS) + labs(x = NULL, y = NULL, fill = NULL, title = dataset) +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(),
          legend.position = legend, plot.title = element_text(margin = margin(b = 20)), legend.box.spacing = grid::unit (25, "pt"), 
          plot.margin = margin(t = 5, r = 5,
                               b = if (dataset == "Evaluation subset") 35 else 0,
                               l = 5))
}
p <- gridExtra::arrangeGrob(panel("Evaluation subset", "none"), panel("Calibration subset", "bottom"),
                           ncol = 1, heights = c(1, 1.15))
export_pdf(p, "Figure_3", width = pdf_width/72, height = pdf_height/72)
