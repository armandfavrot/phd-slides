args <- commandArgs(trailingOnly = FALSE)
script <- sub("^--file=", "", args[grepl("^--file=", args)])
setwd(dirname(normalizePath(script)))
dir.create("build", showWarnings = FALSE)
source("theme.R")
# The two panels are stacked, so the final figure keeps this 10.8-inch width.
figure_pointsize <- discussion_theme(10.8)

# Shared settings for both experiments. Use the same horizontal margins for
# the hierarchy and the curve panel so their centres match exactly.
header_margins <- c(0.1, 3.4, 0.4, 1.2)
curve_margins <- c(2.3, 3.4, 0.5, 1.2)
panel_heights <- c(0.73, 1.12)
figure_height <- 5.8
x_title_size <- 0.80
y_title_size <- x_title_size
x_tick_text_size <- 0.55
y_tick_text_size <- 0.55
x_tick_length <- -0.12
y_tick_length <- -0.08
tick_label_offset <- 0.12
x_tick_label_gap_pt <- 1.5
x_title_offset <- 1.0
y_title_offset <- 1.1

draw_axes <- function(yt) {
  axis(1, at = seq(0, 160, by = 40), col = "#6B7280", col.axis = "#3C4043",
       labels = FALSE, tcl = x_tick_length)
  # Place the top of each label a fixed physical distance below its tick.
  # axis() adds a font-dependent offset even when mgp[2] is zero.
  label_y_inches <- grconvertY(par("usr")[3], from = "user", to = "inches") -
    abs(x_tick_length) * par("csi") - x_tick_label_gap_pt / 72
  text(seq(0, 160, by = 40),
       grconvertY(label_y_inches, from = "inches", to = "user"),
       labels = seq(0, 160, by = 40), adj = c(0.5, 1),
       cex = x_tick_text_size, col = "#3C4043", xpd = NA)
  mtext("Time since application (h)", side = 1, line = x_title_offset, cex = x_title_size)
  axis(2, at = yt, labels = format(100 * yt, trim = TRUE), las = 1,
       col = "#6B7280", col.axis = "#3C4043", cex.axis = y_tick_text_size,
       tcl = y_tick_length, mgp = c(3, tick_label_offset, 0))
  mtext(expression(atop("Relative NH"[3] * " emission", "(% of applied TAN)")),
        side = 2, line = y_title_offset, cex = y_title_size)
  box(col = "#6B7280")
}

draw_treatment_box <- function(x, top, half_width, colour, label, detail,
                               title_size, detail_size) {
  # Equal physical height and line positions despite different header y scales.
  scale <- diff(par("usr")[3:4]) / (6.2 - 2.78)
  bottom <- top - 0.78 * scale
  rect(x - half_width, bottom, x + half_width, top, col = colour, border = NA)
  text(x, top - 0.24 * scale, label, col = "white", font = 2, cex = title_size)
  text(x, top - 0.57 * scale, detail, col = "white", font = 2, cex = detail_size)
  bottom
}

#!/usr/bin/env Rscript

plot_file <- file.path("data", "ALFAM2_plot.csv")
interval_file <- file.path("data", "ALFAM2_interval.csv")
output_dir <- "build"

p <- read.csv(plot_file, check.names = FALSE, stringsAsFactors = FALSE)
z <- read.csv(interval_file, check.names = FALSE, stringsAsFactors = FALSE)
p <- p[p$eid == 601, ]
z <- z[z$pid %in% p$pid & !is.na(z$ct) & !is.na(z$e.rel), ]

method_order <- c("bsth", "ts")
method_labels <- c(bsth = "Trailing hose", ts = "Trailing shoe")
method_colors <- c(bsth = "#56B4E9", ts = "#7B61A8")
p$app.method <- factor(p$app.method, levels = method_order)
p <- p[order(p$app.method, p$pid), ]
stopifnot(nrow(p) == 16L, all(table(p$app.method) == 8L))

# Treatment means on a common time grid (linear interpolation by plot).
time_grid <- seq(0, max(z$ct, na.rm = TRUE), length.out = 250)
mean_curve <- function(code) {
  ids <- p$pid[p$app.method == code]
  curves <- sapply(ids, function(id) {
    q <- z[z$pid == id, ]; q <- q[order(q$ct), ]
    approx(c(0, q$ct), c(0, q$e.rel), xout = time_grid,
           rule = 2, ties = "ordered")$y
  })
  rowMeans(curves, na.rm = TRUE)
}

draw_figure <- function() {
  layout(matrix(c(1, 2), ncol = 1), heights = panel_heights)

  par(mar = header_margins, family = FIGURE_FONT,
      ps = 0.65 * figure_pointsize, xpd = NA)
  plot.new(); plot.window(xlim = c(0, 12), ylim = c(2.78, 6.2), yaxs = "i")
  treatment_x <- c(3.25, 8.75)
  for (x in treatment_x) segments(6, 5.25, x, 4.7, col = "#9AA0A6", lwd = 1.4)
  rect(3.2, 5.25, 8.8, 5.95, col = STRIP_FILL, border = "grey60")
  text(6, 5.60, "eid = 601  -  Denmark  -  16 plots", col = "black", font = 2, cex = 0.96)

  for (j in seq_along(method_order)) {
    code <- method_order[j]; x <- treatment_x[j]; col <- method_colors[code]
    q <- p[p$app.method == code, ]
    box_bottom <- draw_treatment_box(
      x, 4.7, 2.05, col, method_labels[code],
      paste0("Treatment ", j, "  -  8 replicates"), 0.90, 0.74)
    px <- seq(x - 2.20, x + 2.20, length.out = 8)
    for (k in seq_along(px)) {
      segments(x, box_bottom, px[k], 3.47, col = adjustcolor(col, 0.55), lwd = 0.9)
      rect(px[k] - 0.28, 2.91, px[k] + 0.28, 3.47,
           col = "white", border = col, lwd = 1.5)
      text(px[k], 3.32, "pid", col = "#5F6368", cex = 0.62)
      text(px[k], 3.07, q$pid[k], col = "#202124", font = 2, cex = 0.60)
    }
  }

  par(mar = curve_margins, cex.lab = y_title_size, cex.axis = x_tick_text_size,
      ps = figure_pointsize, family = FIGURE_FONT, xpd = FALSE)
  ymax <- max(z$e.rel, na.rm = TRUE) * 1.06
  plot(NA, xlim = c(0, 160), ylim = c(0, ymax),
       xlab = "",
       ylab = "",
       axes = FALSE)
  rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = PANEL_FILL, border = NA)
  yt <- pretty(c(0, ymax)); abline(h = yt, v = seq(0, 160, by = 40), col = "white", lwd = 0.8)
  draw_axes(yt)
  for (code in method_order) {
    for (id in p$pid[p$app.method == code]) {
      q <- z[z$pid == id, ]; q <- q[order(q$ct), ]
      lines(c(0, q$ct), c(0, q$e.rel), col = adjustcolor(method_colors[code], 0.25),
            lwd = 0.6)
      points(q$ct, q$e.rel, pch = 16, cex = 0.38,
             col = adjustcolor(method_colors[code], 0.55))
    }
    lines(time_grid, mean_curve(code), col = method_colors[code], lwd = 2)
  }
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
cairo_pdf(file.path(output_dir, "figure_alfam2_structure_replicates_eid601.pdf"),
    width = 10.8, height = figure_height, family = FIGURE_FONT, pointsize = figure_pointsize)
draw_figure(); dev.off()
message("Figure created for eid 601: 2 methods x 8 replicates.")

#!/usr/bin/env Rscript

plot_file <- file.path("data", "ALFAM2_plot.csv")
interval_file <- file.path("data", "ALFAM2_interval.csv")
output_dir <- "build"
selected_eid <- 246L
p <- read.csv(plot_file, check.names = FALSE, stringsAsFactors = FALSE)
z <- read.csv(interval_file, check.names = FALSE, stringsAsFactors = FALSE)
p <- p[p$eid == selected_eid, ]
z <- z[z$pid %in% p$pid & !is.na(z$ct) & !is.na(z$e.rel), ]

method_order <- c("bc", "bsth", "ts", "os")
method_labels <- c(bc = "Broadcast", bsth = "Trailing hose",
                   ts = "Trailing shoe", os = "Open-slot")
method_colors <- c(bc = "#E69F00", bsth = "#56B4E9",
                   ts = "#7B61A8", os = "#009E73")
p$app.method <- factor(p$app.method, levels = method_order)
p <- p[order(p$app.method, p$pid), ]
stopifnot(nrow(p) == 4L, all(table(p$app.method) == 1L), nrow(z) > 4L)

draw_figure <- function() {
  layout(matrix(c(1, 2), ncol = 1), heights = panel_heights)
  par(mar = header_margins, family = FIGURE_FONT,
      ps = 0.65 * figure_pointsize, xpd = NA)
  plot.new(); plot.window(xlim = c(0, 12), ylim = c(2.62, 6.4), yaxs = "i")
  treatment_x <- seq(1.7, 10.3, length.out = 4)
  for (x in treatment_x) segments(6, 5.45, x, 4.9, col = "#9AA0A6", lwd = 1.4)
  rect(3.2, 5.45, 8.8, 6.15, col = STRIP_FILL, border = "grey60")
  text(6, 5.80, "eid = 246  -  Switzerland  -  4 plots", col = "black", font = 2, cex = 0.96)
  for (j in seq_along(method_order)) {
    code <- method_order[j]; q <- p[p$app.method == code, ]
    x <- treatment_x[j]; col <- method_colors[code]
    box_bottom <- draw_treatment_box(
      x, 4.9, 1.18, col, method_labels[code], paste0("Treatment ", j), 0.84, 0.71)
    segments(x, box_bottom, x, 3.45, col = adjustcolor(col, 0.6), lwd = 1.2)
    rect(x - 0.48, 2.75, x + 0.48, 3.45, col = "white", border = col, lwd = 2)
    text(x, 3.23, "pid", col = "#5F6368", cex = 0.64)
    text(x, 2.94, q$pid, col = "#202124", font = 2, cex = 0.65)
  }

  par(mar = curve_margins, cex.lab = y_title_size, cex.axis = x_tick_text_size,
      ps = figure_pointsize, family = FIGURE_FONT, xpd = FALSE)
  ymax <- max(z$e.rel, na.rm = TRUE) * 1.08
  plot(NA, xlim = c(0, 160), ylim = c(0, ymax),
       xlab = "",
       ylab = "",
       axes = FALSE)
  rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = PANEL_FILL, border = NA)
  yt <- pretty(c(0, ymax)); abline(h = yt, v = seq(0, 160, by = 40), col = "white", lwd = 0.8)
  draw_axes(yt)
  for (code in method_order) {
    pid <- p$pid[p$app.method == code]; q <- z[z$pid == pid, ]; q <- q[order(q$ct), ]
    lines(c(0, q$ct), c(0, q$e.rel), col = method_colors[code], lwd = 1.8)
    points(q$ct, q$e.rel, pch = 21, bg = "white", col = method_colors[code],
           lwd = 1.0, cex = 0.50)
  }
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
cairo_pdf(file.path(output_dir, "figure_alfam2_structure_emission_dynamics.pdf"),
    width = 10.8, height = figure_height, family = FIGURE_FONT, pointsize = figure_pointsize)
draw_figure(); dev.off()
message("Figure created for eid 246.")

status <- system2("pdflatex", c("-interaction=nonstopmode", "-halt-on-error", "-output-directory=build", "sources/fig_04.tex"), stdout = "build/fig_04.compile.log", stderr = "build/fig_04.compile.log")
stopifnot(status == 0L)
dir.create("pdf", showWarnings = FALSE)
stopifnot(file.copy("build/fig_04.pdf", "pdf/fig_04.pdf", overwrite = TRUE))
publish_pdf("fig_04.pdf")
