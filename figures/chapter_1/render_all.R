# Rscript --vanilla render_all.R (fonctionne aussi depuis un autre répertoire).
.script <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(.script)) .script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
bundle_dir <- dirname(normalizePath(.script))
for (file in list.files(bundle_dir, pattern = "^Figure_(S?[0-9]+)\\.R$", full.names = TRUE)) {
  message("Figure : ", basename(file))
  source(file, local = new.env(parent = globalenv()), chdir = FALSE)
}
