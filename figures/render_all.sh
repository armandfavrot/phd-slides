#!/usr/bin/env bash
set -euo pipefail

figures_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

for section in introduction chapter_1 chapter_2 chapter_3; do
  echo "Rendering ${section} figures..."
  bash "${figures_dir}/${section}/render_all.sh"
done

echo "All manuscript figures were generated successfully."
