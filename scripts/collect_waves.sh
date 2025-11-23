#!/usr/bin/env bash
set -euo pipefail
OUT="build/reports/waves"
mkdir -p "$OUT"

# Copy waveforms with path-based names to avoid clashes
i=0
while IFS= read -r -d '' f; do
  base="$(echo "$f" | sed 's#^\./##; s#[/ ]#_#g')"
  cp -f "$f" "$OUT/$base"
  i=$((i+1))
done < <(find . -type f \( -name "*.fst" -o -name "*.vcd" \) -print0)

# Make a simple HTML listing
{
  echo "<html><head><meta charset='utf-8'><title>Waveforms</title></head><body>"
  echo "<h1>Waveforms</h1>"
  echo "<p>Download and open locally with GTKWave (or your viewer).</p>"
  echo "<ul>"
  for f in "$OUT"/*; do
    bn="$(basename "$f")"
    echo "<li><a href=\"$bn\">$bn</a></li>"
  done
  echo "</ul></body></html>"
} > "$OUT/index.html"

echo "Collected $i waveform(s) to $OUT"
