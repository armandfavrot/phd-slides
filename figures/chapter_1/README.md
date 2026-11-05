# Figures de l’article 1 — dossier autonome pour la thèse

Le dossier `figures/chapter_1/` se trouve dans le dossier commun `figures/`, à côté de `figures/common.R`. Il suffit de R et des packages `ggplot2` et `gridExtra` ; aucun chemin vers le projet d’origine ni fichier de modèle entraîné n’est nécessaire.

## Utilisation

Installer une fois, depuis R, si nécessaire :

```r
install.packages(c("ggplot2", "gridExtra"))
```

Depuis la racine du projet, pour refaire toutes les figures :

```sh
./figures/chapter_1/render_all.sh
```

Pour une seule figure :

```sh
Rscript --vanilla figures/chapter_1/Figure_2.R
```

Dans R/RStudio, on peut également exécuter :

```r
source("figures/chapter_1/Figure_2.R")
# ou :
source("figures/chapter_1/render_all.R")
```

Les chemins sont résolus à partir du script : le répertoire de travail peut être différent. Utiliser `source()` ou Rscript pour exécuter le fichier entier. Chaque PDF est créé dans `figures/chapter_1/pdf/` puis copié dans `manuscrit/images/chapter_1/`, sous le nom utilisé par `main.tex`. Les deux exemplaires sont donc identiques ; une nouvelle exécution remplace uniquement les PDF des figures exécutées dans ces deux dossiers.

## Où modifier les graphiques ?

- `Figure_1.R` à `Figure_6.R`, puis `Figure_S1.R` à `Figure_S5.R` : un script court par figure, avec le code graphique directement modifiable.
- `../common.R` : thème stable, police, palettes, lecture des données et export PDF communs aux différents chapitres.
- `latex_linewidth`, `pdf_width`, `pdf_height` et `reference_size`, en haut de chaque script : réglages de l'insertion LaTeX et de la typographie. Les rapports largeur/hauteur reprennent les figures sources, sauf l'assemblage de la figure 3, produit directement dans R.
- `data/` : données de tracé en CSV lisibles, sans objets R sérialisés ni dépendance aux packages de modélisation.

Par exemple, pour changer le titre de l’axe et la taille de sortie de la figure 2, modifiez son `labs(...)`, puis `pdf_width` et `pdf_height` en haut du script. Les figures 3, 4 et 5 utilisent `gridExtra` pour assembler leurs panneaux. Tous les tracés sont reconstruits en vectoriel : aucun script n’incorpore une image de la figure existante.

## Calibrer la taille pour le manuscrit

Les scripts du chapitre 1 reprennent le même bloc de réglage que ceux du chapitre 2. En haut de chaque script, `latex_linewidth` reprend la largeur choisie dans `main.tex` et `test_chapter1.tex`, tandis que `pdf_width` et `pdf_height` fixent les dimensions du PDF exporté en points. Le bloc calcule ensuite :

```r
layout_ratio <- 424.06033 / 483.69687
reference_size = 32 * layout_ratio
axis_title_size <- reference_size * (pdf_width / 1000) / latex_linewidth
axis_text_size = 0.8 * axis_title_size
axis_y_margin <- 15 * layout_ratio * (pdf_width / 1200) * (1.2 / latex_linewidth)
```

Le `theme_update()` et `update_geom_defaults()` juste après appliquent ces tailles aux axes, facettes, titres, légendes et textes des géométries. Pour ajuster une seule figure, modifiez les valeurs en haut de son script. `layout_ratio` conserve la même calibration de référence que dans le chapitre 2 ; `reference_size` peut être ajusté manuellement.

Pour contrôler une modification, exécutez le script de la figure, examinez son PDF dans `figures/chapter_1/pdf/`, puis recompilez `test_chapter1.tex`. Aucun `make` du manuscrit complet n'est nécessaire à cette étape.

## Contenu et données

| Script | Graphique | Données |
| --- | --- | --- |
| `Figure_1.R` | Dynamiques des émissions relatives | `Figure_1.csv` |
| `Figure_2.R` | Observé/prédit, jeu d’évaluation | `predictions.csv` |
| `Figure_3.R` | Quatre métriques, évaluation et calibration | `metrics.csv` |
| `Figure_4.R` | Importance des variables | `Figure_4.csv` |
| `Figure_5.R` | Valeurs SHAP des dix principales variables | `Figure_5.csv` |
| `Figure_6.R` | Efficacité des techniques, 128 scénarios par combinaison modèle/technique | `Figure_6.csv` |
| `Figure_S1.R` | TAN par type de lisier | `Figure_S1.csv` |
| `Figure_S2.R` | Scénarios à efficacité positive avec gradient boosting | `Figure_S2.csv` |
| `Figure_S3.R` | Résidus sur l’ensemble des données | `predictions.csv` |
| `Figure_S4.R` | Résidus sur le jeu d’évaluation | `predictions.csv` |
| `Figure_S5.R` | Distribution des températures | `Figure_S5.csv` |

Les figures S1 à S5 correspondent respectivement aux anciennes figures 7, 8, 10, 11 et 9 de `manuscript.qmd`. La figure 3 assemble les deux graphiques de métriques qui étaient auparavant assemblés dans un fichier de dessin.

## Provenance et fidélité

Les CSV ont été reconstitués à partir de `manuscript.qmd`, des fichiers `scripts/processed_data/*.Rdata` et de la feuille 2 de `Supplementary_Table_3_use2775.xlsx`. Le script de maintenance `prepare_thesis_figure_data.R`, placé **à côté de ce dossier dans le projet d’origine**, documente cette extraction et permet de la refaire depuis la racine de ce projet. Il n’est pas nécessaire de le copier dans la thèse.

La préparation utilise notamment ALFAM2 3.7 et XGBoost 1.7.6.1, présents dans l’environnement historique du projet, ainsi que les graines aléatoires du manuscrit. `data/preparation_session.txt` consigne les versions et `data/source_checksums.csv` identifie les fichiers sources. Le tracé seul a été vérifié avec R 4.4.1, ggplot2 3.5.1 et gridExtra 2.3. Utiliser ggplot2 3.5.0 ou ultérieur pour le réglage vectoriel de la barre de couleurs SHAP.

Les CSV figent les résultats numériques : refaire une figure ne réentraîne pas les modèles et ne recalcule pas les SHAP. Pour modifier l’analyse scientifique ou les modèles, il faut revenir au projet d’origine. Les valeurs SHAP et les valeurs de prédicteurs normalisées restent disponibles ; `y_beeswarm` mémorise seulement le placement vertical des points afin de ne pas dépendre de `shapviz`/`ggbeeswarm` pour le tracé.

La reconstruction retrouve les RMSE d’évaluation de **4.51, 6.19 et 7.30** pour random forest, gradient boosting et lasso. Elle ne garantit pas l’identité numérique exacte avec tous les résultats intermédiaires utilisés pour les figures publiées : le code disponible donne notamment une MAE gradient boosting de **4.09**, contre **4.10** dans le texte publié. Les valeurs sont celles recalculées par le code, pas des chiffres retouchés pour imiter les images. La reconstruction finale retrouve aussi le classement des variables SHAP des figures fournies. La typographie et la disposition peuvent aussi différer selon la version de ggplot2 ou la disponibilité de Latin Modern Roman.

Certains choix du code d’origine sont conservés pour ne pas modifier l’analyse :

- S1 conserve toutes les lignes temporelles ALFAM2, sans dédupliquer les essais.
- Les SHAP random forest sont évaluées sur les 490 lignes de calibration, après entraînement sur l’ensemble ; celles de gradient boosting sur 538 lignes, comme dans `manuscript.qmd`.
- La métrique MBE est `prediction - observation` ; les résidus S3/S4 sont `observation - prediction`, normalisés par TAN.
- Les métriques du tableau d’entrée sont arrondies à deux décimales comme dans le manuscrit.
- Les efficacités lasso reprennent le calcul sur la sortie du modèle tel qu’il apparaît dans le script d’origine ; aucune correction scientifique implicite n’est appliquée.

## Vérification du dossier portable

Les onze scripts ont été exécutés, les PDF contrôlés et comparés visuellement aux figures sources. Le dossier a également été copié dans un répertoire temporaire indépendant pour vérifier qu’il fonctionne sans accès relatif au projet d’origine. Les onze PDF sont des documents d’une page, avec texte sélectionnable et tracés vectoriels.
