#!/bin/sh
set -eu
cd "$(dirname "$0")"
sh fig_01.sh
python3 fig_02.py
Rscript --vanilla fig_03.R
Rscript --vanilla fig_04.R
Rscript --vanilla fig_05.R
sh fig_06.sh
