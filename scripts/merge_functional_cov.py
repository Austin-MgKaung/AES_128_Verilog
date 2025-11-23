#!/usr/bin/env python3
import sys, os, glob, yaml, shutil
from collections import defaultdict

IN_DIR  = "build/coverage/functional"
OUT_DIR = "build/reports/functional_cov"
RAW_DIR = os.path.join(OUT_DIR, "yaml")
os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(RAW_DIR, exist_ok=True)

files = sorted(glob.glob(os.path.join(IN_DIR, "*.yaml")))
if not files:
    print(f"No YAML coverage files found in {IN_DIR}")
    # still create a minimal index
    with open(os.path.join(OUT_DIR, "index.html"), "w") as f:
        f.write("<html><body><h1>Functional Coverage</h1><p>No files found.</p></body></html>")
    sys.exit(0)

# Copy raw files for browsing/download
for p in files:
    shutil.copy2(p, RAW_DIR)

# Lightweight merge: sum bin counts per coverpoint
merged = {}
for path in files:
    with open(path) as f:
        data = yaml.safe_load(f) or {}
    cps = data.get("coverpoints", {})
    for cp_name, cp in cps.items():
        mb = merged.setdefault(cp_name, defaultdict(int))
        for bname, meta in cp.get("bins", {}).items():
            mb[bname] += int(meta.get("count", 0))

# Write merged YAML
merged_yaml = {"coverpoints": {}}
lines = []
for cp_name, bins in merged.items():
    merged_yaml["coverpoints"][cp_name] = {"bins": {k: {"count": v} for k, v in bins.items()}}
    total = len(bins)
    hit = sum(1 for v in bins.values() if v > 0)
    pct = (100.0 * hit / total) if total else 100.0
    lines.append(f"{cp_name}: {hit}/{total} bins hit ({pct:.1f}%)")

with open(os.path.join(OUT_DIR, "merged.yaml"), "w") as f:
    yaml.safe_dump(merged_yaml, f, sort_keys=True)

# HTML summary with links
html = ["<html><head><meta charset='utf-8'><title>Functional Coverage</title></head><body>",
        "<h1>Functional Coverage Summary</h1>",
        "<ul>"]
for line in lines:
    html.append(f"<li>{line}</li>")
html += [
    "</ul>",
    "<h2>Downloads</h2>",
    f"<p><a href='merged.yaml'>Merged YAML</a></p>",
    "<h3>Raw YAMLs</h3><ul>"
]
for p in sorted(os.listdir(RAW_DIR)):
    html.append(f"<li><a href='yaml/{p}'>{p}</a></li>")
html += ["</ul></body></html>"]

with open(os.path.join(OUT_DIR, "index.html"), "w") as f:
    f.write("\n".join(html))

print("Functional coverage report:", os.path.join(OUT_DIR, "index.html"))
