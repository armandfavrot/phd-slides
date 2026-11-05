#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
for script in fig*.R; do
    Rscript "$script"
done
echo "Generated 18 PDF files in $(pwd)/pdf and $(pwd)/../../manuscrit/images/chapter_2"
