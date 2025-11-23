#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="build/reports/verilator_cov"
mkdir -p "$OUT_DIR"

# Gather candidate coverage .dat files without using 'mapfile'
tmp_list="$(mktemp)"
# Include the default Verilator output if present
[ -f "sim_build/coverage.dat" ] && printf '%s\0' "sim_build/coverage.dat" >> "$tmp_list"
# Include any other .dat files under build/
find build -type f -name '*.dat' -print0 >> "$tmp_list" || true

# If nothing found, exit gracefully (don't fail the whole 'make all')
bytes=$(wc -c < "$tmp_list" | tr -d '[:space:]')
if [ "${bytes:-0}" -eq 0 ]; then
  echo "No Verilator .dat coverage files found. Skipping RTL coverage merge."
  rm -f "$tmp_list"
  exit 0
fi

# Merge coverage files
xargs -0 verilator_coverage --write "$OUT_DIR/merged.dat" < "$tmp_list"

# Create LCOV info
verilator_coverage --write-info "$OUT_DIR/merged.info" "$OUT_DIR/merged.dat" || {
  echo "Warning: couldn't generate LCOV info (older verilator_coverage?)."
}

# Generate HTML (needs lcov's genhtml)
if command -v genhtml >/dev/null 2>&1; then
  genhtml "$OUT_DIR/merged.info" --output-directory "$OUT_DIR/html" >/dev/null
  echo "Verilator coverage report: $OUT_DIR/html/index.html"
else
  echo "genhtml not found; install lcov (e.g., 'brew install lcov') to get HTML."
fi

rm -f "$tmp_list"
