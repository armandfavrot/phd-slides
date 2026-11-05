#!/usr/bin/env Rscript
# Plot code adapted from results.ipynb.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (length(arg) != 1L) stop('Run with Rscript')
setwd(dirname(normalizePath(sub('^--file=', '', arg))))
source('../common.R')
init_figure_environment('chapter_2', getwd())

latex_linewidth = 0.9
pdf_width = 1000
# Conserver la calibration visuelle du test avec une largeur de texte de 424.06033 pt.
layout_ratio <- 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size <- reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.8 * axis_title_size
axis_y_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
axis_x_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
legend_title_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)

theme_update(
  axis.title.x = element_text(size = axis_title_size, margin = ggplot2::margin(t = axis_x_margin)),
  axis.text.x = element_text(size = axis_text_size),
  axis.title.y = element_text(size = axis_title_size, margin = ggplot2::margin(r = -30)),
  axis.text.y = element_text(size = 0.9 * axis_title_size),
  axis.title.y.right = element_text(size = axis_title_size, margin = ggplot2::margin(l = axis_y_margin)),
  axis.text.y.right = element_text(size = axis_text_size),
  strip.text = element_text(size = 0.9 * axis_title_size),
  plot.title = element_text (size = axis_title_size),
  legend.title = element_text(size = 1 * axis_title_size, face = "bold", margin = ggplot2::margin(r = legend_title_margin)),
  legend.text = element_text(size = axis_title_size),
  plot.margin = margin (r = 50),
)

update_geom_defaults("text", list(size = 0.6 * axis_text_size / ggplot2::.pt))

load('data/plot_inputs.RData')
dir.create('pdf', showWarnings=FALSE)

df_plot2 = df_plot %>%
    filter (app.mthd != "bc none") %>%

    mutate (Ordonnee = recode (app.mthd, 
                               "cs none" = "1",
                               "os none" = "2",
                               "bsth none" = "4",
                               "ts none" = "3",
                               "bc deep" = "5",
                               "bc shallow" = "6")) %>%

    mutate (app.mthd = recode (app.mthd, 
                               "cs none" = "Closed slot",
                               "os none" = "Open slot",
                               "ts none" = "Trailing shoe",
                               "bsth none" = "Trailing hose",
                               "bc shallow" = "Shallow incorporation",
                               "bc deep" = "Deep incorporation")) %>%

    mutate (app.mthd = factor (app.mthd, levels = c ("Closed slot", "Open slot", "Trailing shoe", "Trailing hose", "Deep incorporation", "Shallow incorporation"))) %>%
    mutate (Ordonnee = as.numeric (Ordonnee)) %>%
    {.}


labels = c("Closed slot", "Open slot", "Trailing shoe", "Trailing hose", "Deep incorporation", "Shallow incorporation")
breaks = c(1 : 6)
number_of_obs = as.character (c (4, 34, 41, 7, 3, 34))


figure_empirical_efficacies = df_plot2 %>%
    ggplot () +
        geom_boxplot (aes (x = efficacy, y = Ordonnee, group = Ordonnee), fill = "#ffeb9d", varwidth = TRUE) +
        geom_vline (aes (xintercept = 0), linetype = 2) +
        scale_y_continuous(
            breaks = breaks, 
            labels = labels,
            sec.axis = sec_axis(~., breaks = breaks, labels = number_of_obs, name = "Number of trials")
        ) +        
        xlab ("Efficacy (%)") +
        ylab ("")


grDevices::cairo_pdf('pdf/fig02.pdf', width=pdf_width/72, height=400/72, family=FIGURE_FONT, onefile=FALSE)
print(figure_empirical_efficacies)
grDevices::dev.off()
publish_pdf('fig02.pdf')
