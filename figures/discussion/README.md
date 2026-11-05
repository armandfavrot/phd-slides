# Figures de la discussion

Toutes les sources et données nécessaires sont incluses ; aucun modèle n’est réentraîné et aucun fichier du dossier d’origine n’est utilisé. Le thème R dépend également de `../common.R`, à conserver avec ce dossier dans le manuscrit.

## Thème du manuscrit

Les six figures utilisent Latin Modern Roman, comme les autres chapitres.
Les graphiques reprennent les fonds bleu très clair, les grilles blanches et
les bandeaux gris à texte noir du manuscrit. Les couleurs distinguant modèles,
traitements ou familles de choix sont conservées ; les schémas TikZ gardent leur
structure et leurs couleurs fonctionnelles.

Les tailles R et Python sont calibrées pour une insertion à `width=1\linewidth`
avec une largeur de texte de 424.06033 pt. `theme.R` centralise la calibration R ;
`thesis_theme()` dans `fig_02.py` applique son équivalent Python. Les dessins
denses emploient ponctuellement un texte plus petit pour éviter les chevauchements.
Les PDF restent dans `pdf/` et sont aussi exportés automatiquement vers
`../../manuscrit/images/discussion/`, sans changer leurs noms. Aucun texte de discussion
n'est intégré à `main.tex`.

## Régénération

Depuis ce dossier, pour refaire les six PDF :

```sh
sh run_all.sh
```

Pour refaire une seule figure :

```sh
sh fig_01.sh
python3 fig_02.py
Rscript --vanilla fig_03.R
Rscript --vanilla fig_04.R
Rscript --vanilla fig_05.R
sh fig_06.sh
```

Les scripts fonctionnent aussi depuis un autre répertoire en indiquant leur chemin. Les six PDF finaux sont écrits dans `pdf/`, copiés dans `../../manuscrit/images/discussion/` et remplacés à chaque exécution. L'export est également effectué lorsqu'on lance un seul script. L'option Python `--output` conserve sa destination personnalisée et exporte aussi une copie nommée `fig_02.pdf` pour le manuscrit. Les fichiers intermédiaires, tableaux de métriques et journaux de compilation sont placés dans `build/`.

## Correspondance et retouches

| Figure d’origine | PDF produit | Script | Source à modifier |
| --- | --- | --- | --- |
| nn_design_space.pdf | fig_01.pdf | fig_01.sh | sources/fig_01.tex |
| figure_scenarios.pdf | fig_02.pdf | fig_02.py | fig_02.py |
| metrics_plot.pdf | fig_03.pdf | fig_03.R | fig_03.R |
| figure_alfam2_structure_eid601_eid246.pdf | fig_04.pdf | fig_04.R | fig_04.R et sources/fig_04.tex |
| figure_dataman_missing_values.pdf | fig_05.pdf | fig_05.R | fig_05.R |
| multitask_alfam2_dataman_architecture_tikz.pdf | fig_06.pdf | fig_06.sh | sources/fig_06.tex |

Tous les noms utilisent un underscore entre `fig` et le numéro : `fig_01` à `fig_06`, pour les PDF, scripts et sources associés. Le nom « figure_dataman_emissing_values.pdf » de la demande correspond au fichier existant « figure_dataman_missing_values.pdf ».

Modifier les tailles, couleurs, légendes et dimensions dans les sources indiquées. La figure 04 regroupe deux tracés R (eid 601 et eid 246) assemblés par LaTeX ; son unique script réalise les trois étapes.

## Prérequis

- R >= 4.3, avec les dépendances de `../common.R` (ggplot2, dplyr >= 1.1, tidyr, gridExtra, paletteer, tibble et stringr). La figure 04 utilise aussi les graphiques de base.
- Python 3 avec matplotlib, seaborn, pandas et numpy ; fontconfig et la police Latin Modern Roman. `requirements.txt` donne les versions de l’environnement source.
- pdflatex et les packages LaTeX standalone, TikZ, lmodern et amsmath.

Installation des dépendances si nécessaire (connexion Internet requise) :

```sh
python3 -m pip install -r requirements.txt
Rscript -e 'install.packages(c("dplyr", "ggplot2", "tidyr"), repos="https://cloud.r-project.org")'
```

Le rendu peut légèrement varier avec les versions des bibliothèques, notamment ggplot2 et matplotlib.

## Données et provenance

`data/` contient les copies des CSV ALFAM2 et DATAMAN, les prédictions de scénarios à 120 h et leurs MAE de test, ainsi que les prédictions des cinq méthodes pour la figure 03. Ces résultats sont figés ; les indicateurs de la figure 03 sont recalculés à chaque exécution.

Les sources viennent de `tikz_images/nn_design_space/`, `for_phd_discussion/`, `dataman_description/`, `figure_scenarios/figure_emissions_120h/` et `metrics_plot_these/` du dossier de discussion. Ces chemins documentent la provenance et ne sont pas des dépendances.

## Validation

Après harmonisation, les six PDF ont été régénérés et inspectés visuellement.
Les données, méthodes de calcul et configurations représentées n'ont pas été
modifiées ; le rendu ne cherche plus à reproduire le thème du dossier d'origine.
