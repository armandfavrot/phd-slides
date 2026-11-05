#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"

for figure in fig_*.R; do
    printf 'Creating %s\n' "$figure"
    Rscript --vanilla "$figure"
done

printf 'Creating TikZ figures\n'
make
printf 'All figures are in pdf/ and ../../manuscrit/images/chapter_3/\n'
