#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

scripts=(
  Figure_1.R
  Figure_2.R
  Figure_3.R
  Figure_4.R
  Figure_5.R
  Figure_6.R
  Figure_S1.R
  Figure_S2.R
  Figure_S3.R
  Figure_S4.R
  Figure_S5.R
)

for script in "${scripts[@]}"; do
  echo "Rendering ${script}..."
  Rscript --vanilla "$script"
done

echo "All chapter 1 figures were generated successfully."
