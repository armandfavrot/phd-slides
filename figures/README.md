# Figures du manuscrit

Toutes les sources de figures sont regroupées ici :

- `introduction/`
- `chapter_1/`
- `chapter_2/`
- `chapter_3/`

`common.R` centralise la police, les palettes, les fonds, le style stable des
facettes et les fonctions d'export. Les dimensions, les calculs typographiques
et le `theme_update()` restent visibles dans chaque script afin de permettre
les ajustements figure par figure.

Pour régénérer toutes les figures prises en charge par les lanceurs :

```sh
./figures/render_all.sh
```

Les figures TikZ de l'introduction sont volontairement exclues. Chaque
`render_all.sh` de sous-dossier peut aussi être lancé séparément.

Les PDF de contrôle restent dans le sous-dossier du chapitre et sont copiés
automatiquement dans `manuscrit/images/`, où ils sont directement utilisés par LaTeX.
