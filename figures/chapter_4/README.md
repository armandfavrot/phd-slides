# Figures du chapitre 4

Ce dossier peut être déplacé tel quel dans le dossier de la thèse. Chaque figure
a son propre script, ses données locales et son PDF dans le sous-dossier `pdf/`. Les scripts n'utilisent
ni le dépôt d'origine, ni les modèles entraînés, ni PyTorch. Dans le manuscrit,
chaque PDF est également exporté dans `manuscrit/images/chapter_4/`.

## Correspondance des noms

| Figure d'origine | Nouveau PDF | Script |
|---|---|---|
| `fold_0_selected_non_physical_pmids_absolute_emissions.pdf` | `fig_01.pdf` | `plot_fig_01.py` |
| `fold_0_pmid_3481_1463_time_extensions_480h.pdf` | `fig_02.pdf` | `plot_fig_02.py` |
| `test_final_relative_emissions_above_one_by_model.pdf` | `fig_03.pdf` | `plot_fig_03.py` |
| `test_negative_flux_distribution_by_model.pdf` | `fig_04.pdf` | `plot_fig_04.py` |
| `application_method_dynamics_by_model_fold_0_996h.pdf` | `fig_05.pdf` | `plot_fig_05.py` |
| `test_mae_boxplot_by_model.pdf` | `fig_06.pdf` | `plot_fig_06.py` |
| Prédictions du modèle physique du package jusqu’à 500 h | `fig_08.pdf` | `plot_fig_08.py` |

La figure 7 compare les MAE selon la population d'entraînement
(`plot_fig_07.py`, données `data/fig_07.csv`).

## Utilisation

Avec les dépendances installées, depuis ce dossier :

```bash
sh run_all.sh
```

Ou pour ne régénérer qu'une figure :

```bash
python plot_fig_01.py
python plot_fig_02.py
python plot_fig_03.py
python plot_fig_04.py
python plot_fig_05.py
python plot_fig_06.py
python plot_fig_07.py
python plot_fig_08.py
```

Chaque commande régénère le PDF correspondant dans le sous-dossier `pdf/`,
créé automatiquement si nécessaire, et copie le même PDF dans
`../../manuscrit/images/chapter_4/`. Cet export est aussi effectué avec `--output`.
Les scripts
retrouvent leurs données relativement à leur propre fichier et peuvent aussi
être lancés depuis un autre répertoire. Pour choisir une destination :

```bash
python plot_fig_01.py --output images/fig_01.pdf
```

Si nécessaire, créer un environnement Python dédié (Python 3.11 ou ultérieur) :

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

Les versions de `requirements.txt` sont celles utilisées pour la vérification.

## Corrections de forme

Le thème reprend la calibration du script Python de l'introduction
`03_10_synthetic_fertilizers_and_manure_absolute/figure.py`, sans reprendre
le thème R : police Latin Modern Roman, fond blanc et grille discrète.
Fontconfig (`fc-match`) et la police Latin Modern Roman doivent être disponibles.

Les premières lignes de chaque script permettent de modifier `latex_linewidth`
(actuellement **1**), `pdf_width`, `pdf_height`, `reference_size`,
`axis_title_size`, `axis_text_size` et les marges des axes. Les tailles de texte
sont proportionnelles à la largeur du PDF pour conserver une taille comparable
après insertion à `1\linewidth`. Les panneaux denses utilisent des coefficients
locaux pour les titres et les graduations. Les figures 3 et 4 sont disposées
en deux lignes de trois panneaux, dans le même ordre que les figures originales.

`_theme.py` applique les réglages de police et gère les deux exports. Il doit
rester à côté des scripts. La largeur du canevas est conservée à l'export
(sans `bbox_inches="tight"`) pour respecter cette calibration.

Tout le tracé est dans le script de chaque figure. Modifier les couleurs
(`color` ou `ORIGINS`), les tailles (`figsize`, `fontsize`, `labelsize`), les
libellés (`set_title`, `set_ylabel`, `supxlabel`, `supylabel`, `MODELS`), les
styles de lignes et la légende, puis relancer le script concerné.

Les scripts reprennent les fonctions de tracé originales. Les textes anglais,
les noms des modèles et les données sont conservés ; seules la typographie
et la mise en page ont été adaptées au manuscrit.
Dans `plot_fig_01.py`, `SELECTED_PMIDS` détermine l'ordre des quatre panneaux.
Dans `plot_fig_02.py`, `styles` règle les courbes des différentes extensions.
Dans `plot_fig_06.py`, la graine aléatoire reste fixée à 42 pour conserver
la position horizontale des points.

Les sorties sont des PDF. Dans la figure 5, les trajectoires individuelles,
les médianes et les textes sont vectoriels. La rasterisation des trajectoires
fines et transparentes a été désactivée pour éviter des segments presque
invisibles ou apparemment coupés dans le rendu PDF, sans modifier leurs valeurs
ou leur transparence. L'épaisseur des trajectoires individuelles est réglée à
0.3 (contre 0.55 dans l'original rasterisé) pour mieux les distinguer des
médianes, dont l'épaisseur reste à 2.0.

## Données et provenance

Les fichiers dans `data/` contiennent uniquement les valeurs nécessaires aux
tracés. Les CSV sont lus avec `float_precision="round_trip"` pour conserver
la précision des nombres exportés. `fig_05.csv.gz` est un CSV compressé que
pandas lit directement.

| Données | Contenu | Nombre de lignes |
|---|---|---:|
| `fig_01.csv` | Observations et prédictions du Benchmark, fold 0, pour les PMIDs 1463, 1454, 1141 et 3481 ; flux pour les marqueurs négatifs | 51 |
| `fig_02.csv` | Prédictions des PMIDs 3481 et 1463 pour les séquences originales et les extensions à 120, 240 et 480 h | 231 |
| `fig_03.csv` | Émissions relatives finales supérieures à 1, par architecture | 181 |
| `fig_04.csv` | Flux prédits négatifs, par architecture | 21 728 |
| `fig_05.csv.gz` | Trajectoires des scénarios à 996 h, fold 0, pour les six architectures et les quatre méthodes représentées | 238 464 |
| `fig_06.csv` | MAE de test des dix folds pour chacune des six architectures | 60 |

Sources dans le dépôt d'origine, à partir de `scripts/model_selection_2/` :

- Figures 1 et 2 : fonctions de `01_benchmark/non_physical_examples.py`,
  données `00_prep/data.csv`, normalisation `00_prep/normalisation_values.pkl`
  et checkpoint `01_benchmark/results/models/model_benchmark_fold_0.pth`.
  Les prédictions utiles ont été recalculées une fois sur CPU et exportées.
  La règle originale d'extension des séquences est conservée.
- Figures 3 et 4 : tableaux `above_one` et `negative_flux` du cache
  `all_data_nonphysical_values.pkl`. Malgré le préfixe historique `test` des
  noms des PDF, ces tracés concernent tous les PMIDs micro-météorologiques
  prédits par chacun des dix folds, comme dans les scripts actuels.
- Figure 5 : fichiers `results/list_predictions_scenarios_996h.pkl` des
  six expériences ; sélection du fold 0 et exclusion des méthodes `bsth`
  et `cs`, comme dans `plot_application_method_dynamics_996h.py`.
- Figure 6 : fichiers `results/list_mae.pkl` des six expériences, comme
  dans `plot_test_mae_boxplot_by_model.py`.

L'ordre des architectures reste : Benchmark, Unidirectional, Relative emission,
Flux, Joint, Reservoir. Les CSV figent les résultats actuels pour permettre
des corrections de forme sans recalcul des modèles.

## Vérification

Les six scripts ont été exécutés après harmonisation du thème, et leurs PDF
ont été vérifiés visuellement. Les copies dans `manuscrit/images/chapter_4/` sont
identiques aux PDF correspondants dans `pdf/`. Les données et les calculs
scientifiques ne sont pas modifiés par cette harmonisation.
