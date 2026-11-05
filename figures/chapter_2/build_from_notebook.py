"""Rebuild the portable scripts and plotting data from the parent repository."""
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
CELLS = json.loads((ROOT / 'results.ipynb').read_text())['cells']
FIGURES = {
    25: ('fig01', 1200, 500), 50: ('fig02', 1000, 400),
    135: ('fig04', 1200, 600), 146: ('fig05', 800, 600),
    150: ('fig06', 700, 600), 154: ('fig07', 1000, 500),
    181: ('fig08', 1700, 1400), 69: ('fig09_appendix', 1000, 500),
    145: ('fig10_appendix', 1200, 600), 153: ('fig11_appendix', 700, 600),
    82: ('fig12_appendix', 1200, 400), 84: ('fig13_appendix', 1200, 700),
    115: ('fig14_appendix', 1000, 450), 114: ('fig15_appendix', 1000, 700),
    112: ('fig16_appendix', 1000, 250), 104: ('fig17_appendix', 1000, 400),
    179: ('fig18_appendix', 1000, 1000), 195: ('fig19_appendix', 1400, 1400),
}
PREP = [8,33,37,38,39,42,43,44,45,46,47,52,55,56,60,61,66,67,
        72,73,76,77,78,79,80,81,88,90,91,94,95,99,100,106,109,
        118,124,128,132,134,148,158,161,162,165,166,169,171,172,176,178]
OBJECTS = ['data','df_plot','df_selection_of_h','df_res_rnn_all','level_models',
           'df_res_static_nn','df_res_static_nn_with_normalisation',
           'df_res_rnn_with_data_augmentation','df_res_rnn_with_normalisation',
           'predictions_without_data_a_on_observed_times',
           'predictions_with_data_a_on_observed_times','df_res_all_static',
           'df_res_all_dynamic','df_efficacy_ALFAM2','df_efficacy_static_rf',
           'df_efficacy_dynamic_rf','df_efficacy_static_nn',
           'df_efficacy_rnn_data_augmentation']

def src(n):
    return ''.join(CELLS[n]['source'])

def clean(code):
    return re.sub(r'(?m)^size\s*\([^\n]*\)\s*\n', '', code)

prep = 'library(dplyr)\nlibrary(tidyr)\n'
for n in PREP:
    code = clean(src(n))
    if n == 33: code = code.split('df_efficacy$eid %>%')[0]
    if n == 43: code = code.replace('\ndf_efficacy_3\n','\n')
    if n == 44: code = code.split('df_efficacy_fix_597 %>%')[0]
    if n == 162: code = code.split('head (df_efficacy_static_rf')[0]
    prep += f'\n# Notebook cell {n}\n{code}\n'
prep += "\ndir.create('thesis_figures/data', recursive=TRUE, showWarnings=FALSE)\n"
prep += "save(" + ', '.join(OBJECTS) + ", file='thesis_figures/data/plot_inputs.RData', compress='xz')\n"
(HERE/'prepare_inputs_from_project.R').write_text(prep)

header = '''#!/usr/bin/env Rscript
# Plot code adapted from results.ipynb.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (length(arg) != 1L) stop('Run with Rscript')
setwd(dirname(normalizePath(sub('^--file=', '', arg))))
source('../common.R')
init_figure_environment('chapter_2', getwd())
load('data/plot_inputs.RData')
dir.create('pdf', showWarnings=FALSE)
'''
mapping = []
for n, (name, w, h) in FIGURES.items():
    code = src(n)
    old = re.search(r'03_images/(figure_[^" ]+\.png)', code).group(1)
    before, post = code.split('png (', 1)
    body = post.split('\n',1)[1].rsplit('dev.off()',1)[0].strip()
    before = clean(before)
    if n == 145: before = 'colors = c("#734196", "#60c67e", "#77c7e4", "#c0e5f2", "#a8e0b8")\n' + before
    if n == 153: before = 'colors = c("#734196", "#60c67e", "#77c7e4")\n' + before
    if n == 114: before = src(111) + '\n' + src(113)
    if n == 195: before = 'x = 5\ny = -20\n' + '\n'.join(clean(src(k)) for k in [190,191,192,193,194])
    before = re.sub(r'(?m)^(?:figure_[A-Za-z0-9_]+|efficacy_vs_bc_emissions_[A-Za-z0-9_]+)\s*$', '', before)
    if n not in (114,195):
        if n == 181:
            body = 'print(' + body + ')'
        else:
            body = f'print({old.removesuffix(".png")})'
    script = header + '\n' + before + '\n'
    script += f"grDevices::cairo_pdf('pdf/{name}.pdf', width={w}/72, height={h}/72, family=FIGURE_FONT, onefile=FALSE)\n"
    script += body + f"\ngrDevices::dev.off()\npublish_pdf('{name}.pdf')\n"
    (HERE/f'{name}.R').write_text(script)
    mapping.append(f'{old} => {name}.pdf')
(HERE/'mapping.txt').write_text('\n'.join(mapping)+'\n')
