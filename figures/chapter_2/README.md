# Figures de la thèse

Ce dossier est autonome : copiez-le tel quel dans le projet de thèse. Les données nécessaires aux tracés sont dans `data/plot_inputs.RData`. Aucun chemin vers le dépôt de l'article n'est utilisé pour générer les PDF.

## Génération

Depuis n'importe quel répertoire :

```bash
bash /chemin/vers/figures/chapter_2/render_all.sh
```

Les 18 PDF sont écrits dans `pdf/` puis copiés dans `../../manuscrit/images/chapter_2/`, avec des fichiers identiques dans les deux dossiers. Pour ne refaire qu'une figure :

```bash
Rscript /chemin/vers/figures/chapter_2/fig08.R
```

Chaque fichier `fig*.R` contient le code de tracé de sa figure, les dimensions de sortie et le nom du PDF. Les réglages communs sont dans `../common.R`. La correspondance avec les anciens PNG est dans `mapping.txt`. Le numéro `fig03` n'était pas dans la liste demandée.

## Régler les figures pour LaTeX

Travaillez chapitre par chapitre avec un fichier indépendant comme `test_chapter2.tex` (ou `check_figure_chapter_x.tex`). Il permet de vérifier les figures sans recompiler le manuscrit. Utilisez la même classe et la même géométrie de page que le manuscrit afin que `\linewidth` corresponde à la même longueur physique.

Choisissez ensuite la largeur d'insertion de chaque figure, par exemple `\includegraphics[width=0.789\linewidth]{images/chapter_2/fig09_appendix.pdf}`. Reportez le coefficient `0.789` dans `latex_linewidth` du script R. Au-delà de `1\linewidth`, centrez la figure avec une `\makebox` :

```latex
\begin{figure}
    \centering
    \makebox[\textwidth][c]{%
        \includegraphics[width=1.052\linewidth]{images/chapter_2/fig10_appendix.pdf}%
    }
    \caption{...}
\end{figure}
```

En haut du script R, **après le chargement de** `../common.R`, réglez la largeur LaTeX et la largeur d'export. `pdf_width` est exprimé en points PDF ; `cairo_pdf()` attend des pouces, d'où `width = pdf_width / 72`. `reference_size` se calibre en comparant le texte de la figure à celui du PDF LaTeX. La valeur de référence est désormais `32` afin de tenir compte de la réduction de la largeur du texte. Le facteur `layout_ratio` conserve la calibration liée aux largeurs de mise en page.

```r
latex_linewidth <- 0.789
pdf_width <- 1000
layout_ratio <- 424.06033 / 483.69687
reference_size <- 32 * layout_ratio
axis_title_size <- reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size <- 0.8 * axis_title_size
axis_y_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)

theme_update(
  axis.title.x = element_text(size = axis_title_size),
  axis.text.x = element_text(size = axis_text_size),
  axis.title.y = element_text(
    size = axis_title_size,
    margin = ggplot2::margin(r = axis_y_margin)
  ),
  axis.text.y = element_text(size = axis_text_size),
  strip.text = element_text(size = axis_title_size),
  plot.title = element_text(size = axis_title_size),
  legend.title = element_text(size = axis_title_size),
  legend.text = element_text(size = axis_title_size)
)

update_geom_defaults(
  "text",
  list(size = 0.6 * axis_text_size / ggplot2::.pt)
)
```

Les coefficients appliqués aux différents textes peuvent varier selon la figure. `theme_update()` conserve les autres propriétés du thème commun, notamment la police. `geom_text()` n'est pas un élément du thème : `update_geom_defaults()` règle sa taille par défaut, en convertissant les points en millimètres. Une taille indiquée directement dans `geom_text()` ou un `theme()` local reste prioritaire.

La formule de `axis_title_size` compense le redimensionnement du PDF à l'insertion dans LaTeX. Celle de `axis_y_margin` reprend l'écart de `fig10_appendix` : 15 pt à 1200 pt de largeur d'export et `1.2\linewidth` avec l'ancienne largeur de texte. La taille finale des textes et marges ainsi calculés dépend peu de la valeur absolue de `pdf_width`. Si largeur et hauteur d'export changent dans la même proportion, la forme et les dimensions finales de la figure restent elles aussi stables. En revanche, les tailles fixes non calculées, comme l'épaisseur des traits, la taille des points et certains espacements, changent après la mise à l'échelle LaTeX. Dans ggplot2, `linewidth` désigne l'épaisseur d'un trait ; ce n'est pas le `\linewidth` de LaTeX.

## Logiciels

R 4.4.1 et les paquets `ggplot2`, `dplyr`, `tidyr`, `gridExtra` et `paletteer` ont été utilisés. Les versions du projet source étaient respectivement 3.5.1, 1.1.4, 1.3.1, 2.3 et 1.6.0. Les scripts utilisent `cairo_pdf` avec Latin Modern Roman, la police du corps de `main.tex`, pour produire des PDF vectoriels.

## Provenance des données

`data/plot_inputs.RData` contient uniquement les données intermédiaires utilisées par les figures, extraites des résultats déjà calculés dans le dépôt de l'article. Il n'est pas nécessaire de réentraîner les modèles. Pour reconstruire cette archive à partir du dépôt original, exécutez depuis sa racine :

```bash
python3 thesis_figures/build_from_notebook.py
Rscript thesis_figures/prepare_inputs_from_project.R
```

Cette dernière étape est facultative et requiert les fichiers de résultats du dépôt original. Avec `figures/common.R`, les scripts `fig*.R` et `render_all.sh` restent autonomes vis-à-vis du dépôt de l’article.
