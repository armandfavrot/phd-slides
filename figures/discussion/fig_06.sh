#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p build pdf
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build sources/fig_06.tex > build/fig_06.compile.log
cp build/fig_06.pdf pdf/fig_06.pdf
mkdir -p ../../manuscrit/images/discussion
cp pdf/fig_06.pdf ../../manuscrit/images/discussion/fig_06.pdf
