#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p build pdf
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=build sources/fig_01.tex > build/fig_01.compile.log
cp build/fig_01.pdf pdf/fig_01.pdf
mkdir -p ../../manuscrit/images/discussion
cp pdf/fig_01.pdf ../../manuscrit/images/discussion/fig_01.pdf
