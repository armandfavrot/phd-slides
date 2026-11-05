#!/bin/sh
set -eu
cd "$(dirname "$0")"
for figure in plot_fig_*.py; do
    python3 "$figure"
done
