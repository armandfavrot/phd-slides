# Configuration commune aux figures du manuscrit.
#
# Chaque script conserve ses dimensions, ses calculs de tailles et son
# theme_update(). Ce fichier centralise uniquement les dépendances, la police,
# les éléments visuels stables et la publication vers images/.

# Find this file even when sourced through a chapter-specific theme helper.
.common_script <- tryCatch({
  source_files <- vapply(sys.frames(), function(frame) {
    if (is.null(frame$ofile)) "" else frame$ofile
  }, character(1))
  common_files <- source_files[basename(source_files) == "common.R"]
  if (length(common_files)) tail(common_files, 1) else NULL
}, error = function(e) NULL)
if (is.null(.common_script) || !nzchar(.common_script)) {
  stop("figures/common.R doit être chargé avec source().")
}

FIGURES_ROOT <- dirname(normalizePath(.common_script))
PROJECT_ROOT <- dirname(FIGURES_ROOT)
MANUSCRIPT_ROOT <- file.path(PROJECT_ROOT, "manuscrit")
FIGURE_FONT <- "Latin Modern Roman"
FONT <- FIGURE_FONT
STRIP_FILL <- "#e5e5e5"
PANEL_FILL <- "#f3faff"

MODEL_LEVELS <- c("ALFAM2", "Lasso", "Random forest", "Gradient boosting")
MODEL_COLORS <- setNames(
  c("#D95F02", "#66A61E", "#E6AB02", "#666666"),
  MODEL_LEVELS
)
METHOD_LEVELS <- c(
  "Broadcast", "Trailing hoses", "Trailing shoes", "Open slot injection"
)

model_names <- function(x) {
  map <- c(
    alfam2 = "ALFAM2",
    lasso = "Lasso",
    "random forest" = "Random forest",
    xgboost = "Gradient boosting"
  )
  mapped <- unname(map[x])
  mapped[is.na(mapped)] <- x[is.na(mapped)]
  factor(mapped, levels = MODEL_LEVELS)
}

method_names <- function(x) {
  factor(
    unname(c(
      bc = "Broadcast",
      bsth = "Trailing hoses",
      ts = "Trailing shoes",
      os = "Open slot injection"
    )[x]),
    levels = METHOD_LEVELS
  )
}

register_manuscript_font <- function() {
  if (!(FIGURE_FONT %in% names(grDevices::pdfFonts())) &&
      nzchar(Sys.which("kpsewhich"))) {
    afm <- vapply(
      c("lmr10.afm", "lmbx10.afm", "lmri10.afm", "lmbxi10.afm", "lmsy10.afm"),
      function(name) system2("kpsewhich", name, stdout = TRUE),
      character(1)
    )
    if (length(afm) == 5L && all(file.exists(afm))) {
      grDevices::pdfFonts(
        "Latin Modern Roman" = grDevices::Type1Font(FIGURE_FONT, unname(afm))
      )
    }
  }
}

load_figure_packages <- function() {
  packages <- c(
    "ggplot2", "dplyr", "tidyr", "gridExtra",
    "paletteer", "tibble", "stringr"
  )
  suppressWarnings(suppressMessages(
    invisible(lapply(packages, function(package) {
      library(package, character.only = TRUE)
    }))
  ))
}

init_figure_environment <- function(profile, figure_dir) {
  valid_profiles <- c("introduction", "chapter_1", "chapter_2", "chapter_3", "discussion")
  if (!(profile %in% valid_profiles)) {
    stop("Profil de figure inconnu : ", profile)
  }
  figure_dir <- normalizePath(figure_dir)
  options(
    manuscript.figure_profile = profile,
    manuscript.figure_dir = figure_dir
  )
  load_figure_packages()
  register_manuscript_font()

  Dark2 <<- paletteer::paletteer_d("RColorBrewer::Dark2")
  Couleurs <<- list(Dark2 = Dark2)
  size <<- function(x, y) invisible(NULL)

  theme_set(theme_gray(base_family = FIGURE_FONT) + theme(
    axis.text = element_text(colour = "grey30"),
    plot.title = element_text(face = "bold", hjust = 0),
    strip.text = element_text(
      face = "bold", colour = "black",
      margin = margin(8, 0, 8, 0)
    ),
    strip.background = element_rect(fill = STRIP_FILL, colour = "grey60"),
    panel.background = element_rect(fill = PANEL_FILL),
    panel.border = element_rect(
      fill = NA, colour = "grey60", linewidth = 0.3
    ),
    panel.grid.major = element_line(colour = "white"),
    panel.spacing = grid::unit(2, "lines")
  ))

  options(
    ggplot2.discrete.fill = Dark2,
    ggplot2.discrete.colour = Dark2
  )
  update_geom_defaults("point", list(size = 3))
  update_geom_defaults("line", list(linewidth = 1.3))

  invisible(NULL)
}

read_data <- function(name) {
  figure_dir <- getOption("manuscript.figure_dir")
  read.csv(
    file.path(figure_dir, "data", paste0(name, ".csv")),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

export_pdf <- function(plot, name, width, height) {
  profile <- getOption("manuscript.figure_profile")
  if (!identical(profile, "chapter_1")) {
    stop("export_pdf() est réservé au profil chapter_1.")
  }
  figure_dir <- getOption("manuscript.figure_dir")
  review_dir <- file.path(figure_dir, "pdf")
  manuscript_dir <- file.path(MANUSCRIPT_ROOT, "images", "chapter_1")
  dir.create(review_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(manuscript_dir, recursive = TRUE, showWarnings = FALSE)
  review_file <- file.path(review_dir, paste0(name, ".pdf"))
  manuscript_file <- file.path(manuscript_dir, paste0(name, ".pdf"))
  device <- if (capabilities("cairo")) grDevices::cairo_pdf else grDevices::pdf
  ggsave(
    review_file, plot = plot, device = device,
    width = width, height = height, units = "in",
    family = FIGURE_FONT, bg = "white"
  )
  if (!file.copy(review_file, manuscript_file, overwrite = TRUE)) {
    stop("Impossible de copier la figure vers ", manuscript_file)
  }
  message("Export : ", review_file, " et ", manuscript_file)
  invisible(plot)
}

publish_pdf <- function(name) {
  profile <- getOption("manuscript.figure_profile")
  figure_dir <- getOption("manuscript.figure_dir")

  if (profile == "introduction") {
    source_file <- file.path(figure_dir, "pdf", name)
    destination_dir <- file.path(MANUSCRIPT_ROOT, "images", "introduction")
  } else if (profile == "chapter_2") {
    source_file <- file.path(figure_dir, "pdf", name)
    destination_dir <- file.path(MANUSCRIPT_ROOT, "images", "chapter_2")
  } else if (profile == "chapter_3") {
    source_file <- file.path(figure_dir, "pdf", name)
    destination_dir <- file.path(MANUSCRIPT_ROOT, "images", "chapter_3")
  } else if (profile == "discussion") {
    source_file <- file.path(figure_dir, "pdf", name)
    destination_dir <- file.path(MANUSCRIPT_ROOT, "images", "discussion")
  } else {
    stop("publish_pdf() n'est pas défini pour le profil ", profile)
  }

  source_file <- normalizePath(source_file, mustWork = TRUE)
  dir.create(destination_dir, recursive = TRUE, showWarnings = FALSE)
  destination <- file.path(destination_dir, name)
  if (!file.copy(source_file, destination, overwrite = TRUE)) {
    stop("Impossible de copier la figure vers ", destination)
  }
  message("Export : ", source_file, " et ", normalizePath(destination))
  invisible(destination)
}
