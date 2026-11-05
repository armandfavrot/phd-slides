#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

# TikZ figures (04, 06, 07 and 08) are intentionally excluded.
figures=(
  01_nitrogen_cycle
  02_nh3_emissions_dynamique
  03_10_synthetic_fertilizers_and_manure_absolute
  05_nh3_emission_factor_distributions_hutchings
  09_combined_unique_publications_by_year
  10_superposition_and_overlap_histogram
  11_fig_time_heterogeneity
  12_field_data_image
  13_caract_air
)

for figure in "${figures[@]}"; do
  echo "Rendering ${figure}..."
  python3 refaire_tout.py "$figure"
done

echo "All non-TikZ introduction figures were generated successfully."
