# Figures de l’introduction

Dossier autonome correspondant aux **13 figures incluses dans `projet_latex/main.tex`**, dans leur ordre d’apparition (état du 18 septembre 2026). Copier tout ce dossier dans le dossier de rédaction.

## Utilisation

```sh
python3 refaire_tout.py       # toutes les figures
python3 refaire_tout.py 09   # une seule figure
```

On peut aussi lancer chaque `figure.R` avec Rscript ou chaque `figure.py` avec Python, depuis n’importe quel répertoire. Chaque résultat est exporté dans **pdf/** et copié dans **../../manuscrit/images/introduction/** sous le nom utilisé par le manuscrit. Les fichiers auxiliaires LaTeX sont temporaires. Les PNG présents sont des images sources, jamais des exports.

Le lanceur `render_all.sh` régénère toutes les figures hors TikZ :

```sh
./figures/introduction/render_all.sh
```

Les figures TikZ 04, 06, 07 et 08 restent volontairement exclues de ce lanceur.

Dépendances : Python 3, matplotlib ; R avec ggplot2, dplyr et patchwork ; pdflatex avec standalone et TikZ. LibreOffice est facultatif pour réexporter les dessins ODG. Aucune connexion réseau, aucun chemin vers le projet initial.

## Modifier une figure

| N° | Figure | Source à modifier |
|---|---|---|
| 01 | Cycle de l’azote | image source + figure.tex (cadrage/taille) |
| 02 | Émissions France/UE | figure.R, data.csv |
| 03 | Engrais FAOSTAT | figure.py, deux CSV FAOSTAT |
| 04 | Variables de volatilisation | figure.tex (TikZ) |
| 05 | Distribution des pertes NH₃ | figure.R, alfam.csv, hutchings.csv |
| 06 | MLP | figure.tex (TikZ) |
| 07 | RNN | figure.tex (TikZ) |
| 08 | Transfert d’apprentissage | figure.tex (TikZ) |
| 09 | Publications par année | figure.R, data.csv |
| 10 | Superposition et histogramme | figure.tex, histogram.R, source.odg |
| 11 | Hétérogénéité temporelle | figure.R, data.csv (graine, nombre d’essais, dimensions et style) |
| 12 | Dispositif au champ | image source + figure.tex (cadrage/taille) |
| 13 | Caract’Air | source.odg + figure.tex |

Les tailles et styles sont dans chaque script ; les figures TikZ se compilent avec leur `figure.py`. Les scripts R reprennent les styles existants en supprimant les bibliothèques et fonctions inutilisées.

Les figures 02, 03, 05, 09 et 11 utilisent la calibration commune fondée sur
`latex_linewidth` et `pdf_width`. Modifier ces deux valeurs au début du
script permet de conserver une taille de texte cohérente avec le manuscrit.
`latex_linewidth` doit correspondre à la largeur passée à
`includegraphics` dans le fichier TeX ; `pdf_width` doit correspondre à la
largeur réellement utilisée lors de l’export.

Pour le panneau gauche de la figure 10, modifier **la page 2** de source.odg avec LibreOffice Draw, puis lancer :
```sh
python3 10_superposition_and_overlap_histogram/figure.py --draw
python3 13_caract_air/figure.py --draw
```
Sans `--draw`, ces deux scripts utilisent les PDF sources fournis pour conserver le rendu actuellement utilisé dans le manuscrit. Les dessins ODG sont inclus avec leurs ressources incorporées ; leur réexport peut dépendre des polices installées.

## Données et limites

- 02 : extrait local EEA, NH₃, France/UE27 ; le script conserve les filtres et regroupements d’origine. Données d’inventaire en kt, conversion en Mt par division par 1000.
- 03 : fichiers FAOSTAT originaux ; seules les courbes du graphique utilisé dans l’introduction sont produites.
- 05 : seules les colonnes nécessaires ont été extraites des données ALFAM2 et Hutchings du script d’origine. Filtre Outdoor pour Hutchings ; pertes conservées entre 0 et 100 %. Dénominateurs distincts : TAN pour ALFAM2, N total pour Hutchings.
- 09 : comptages déjà dédoublonnés incluant Hutchings ; 630 composantes bibliographiques, 627 avec année (1959–2023). `publications.csv` conserve la traçabilité des regroupements ; `data.csv` contient le résultat annuel. Ce kit sert au **retracé** : il ne refait pas les rapprochements bibliographiques à partir des bases brutes.
- 10 : tableau d’effectifs de plots fourni, dont 2620 pour Hutchings. La superposition est un dessin manuel ; les chiffres s’éditent dans Draw.
- 11 : script original fourni dans `fig_time_heterogeneity/`, désormais intégré et simplifié. Les trois colonnes nécessaires (`id`, `ct_origin`, `e_cum_origin`) de toutes les observations sont conservées dans leur ordre initial. Tirage de 30 essais avec la graine 4, puis ajout du point (0, 0) pour chaque essai, comme dans le script original. Modifier `seed`, `n_trials`, `width` et `height` dans `figure.R`. Dépendances : ggplot2 et dplyr ; export uniquement en PDF.
- 01 et 12 : illustrations importées, sans source vectorielle identifiée ; l’export PDF n’augmente pas leur résolution.

Pour utiliser uniquement les nouveaux PDF dans la thèse, remplacer aussi les extensions `.png` de `nitrogen_cycle` et `field_data_image` dans les commandes includegraphics (ou omettre les extensions). Le manuscrit original n’est pas modifié.

Les données sont des copies locales destinées à reproduire ces figures ; conserver les citations et conditions de réutilisation des sources originales.
