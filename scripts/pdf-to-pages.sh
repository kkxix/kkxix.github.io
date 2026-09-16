#!/usr/bin/env bash
# Render a PDF to page images and a compressed copy for the site.
#   ./scripts/pdf-to-pages.sh <input.pdf> <slug> [first] [last]
# Writes page PNGs and <slug>.pdf to public/pdfs/<slug>/.
set -euo pipefail

PDF="${1:?usage: pdf-to-pages.sh <input.pdf> <slug> [first] [last]}"
SLUG="${2:?missing slug}"
FIRST="${3:-1}"
LAST="${4:-}"

OUT="public/pdfs/$SLUG"
mkdir -p "$OUT"

echo "Rendering pages to PNG (110 dpi)…"
if [ -n "$LAST" ]; then
  pdftoppm -r 110 -png -f "$FIRST" -l "$LAST" "$PDF" "$OUT/page"
else
  pdftoppm -r 110 -png -f "$FIRST" "$PDF" "$OUT/page"
fi

if command -v gs >/dev/null 2>&1; then
  echo "Compressing PDF (ghostscript /ebook)…"
  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
     -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$OUT/$SLUG.pdf" "$PDF"
else
  echo "ghostscript not found — copying the PDF uncompressed" >&2
  cp "$PDF" "$OUT/$SLUG.pdf"
fi

SIZE=$(du -m "$OUT/$SLUG.pdf" | cut -f1)
echo "Wrote $(ls "$OUT"/page-*.png 2>/dev/null | wc -l | tr -d ' ') page images; PDF is ${SIZE} MB"
[ "$SIZE" -gt 20 ] && echo "WARNING: PDF is over 20 MB — see the brief's file-size rules." >&2
exit 0
