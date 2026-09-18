#!/usr/bin/env bash
# Convert Jupyter notebooks to self-contained HTML for embedding.
#   ./scripts/notebooks-to-html.sh <notebook-dir> <slug>
# Writes to public/reports/<slug>/<notebook>.html
#
# Notebooks that carry stale `widgets` metadata without a `state` key crash
# nbconvert with KeyError: 'state'. The metadata is stripped into a temp copy
# first; the source notebooks are never modified.
set -euo pipefail

SRC="${1:?usage: notebooks-to-html.sh <notebook-dir> <slug>}"
SLUG="${2:?missing slug}"
OUT="public/reports/$SLUG"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"

shopt -s nullglob
for nb in "$SRC"/*.ipynb; do
  base="$(basename "$nb" .ipynb)"
  python3 - "$nb" "$TMP/$base.ipynb" <<'PY'
import json, sys
nb = json.load(open(sys.argv[1]))
nb.get('metadata', {}).pop('widgets', None)      # the KeyError: 'state' crash
for cell in nb.get('cells', []):
    cell.get('metadata', {}).pop('widgets', None)
json.dump(nb, open(sys.argv[2], 'w'))
PY
  echo "converting $base…"
  jupyter nbconvert --to html --embed-images \
    --output-dir "$OUT" --output "$base" "$TMP/$base.ipynb" 2>&1 \
    | grep -vE "Alternative text is missing|^\[NbConvertApp\] Converting" || true
done

echo
ls -lh "$OUT"/*.html | awk '{printf "  %-8s %s\n", $5, $9}'
echo "  total: $(du -sh "$OUT" | cut -f1)"
