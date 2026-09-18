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

# PNG page images are large for photo-heavy documents (a 105-page plan book came
# to 47 MB); WebP takes the same pages to under 10 MB at visually identical quality.
if command -v cwebp >/dev/null 2>&1; then
  echo "Converting page images to WebP…"
  for png in "$OUT"/page-*.png; do
    [ -e "$png" ] || continue
    cwebp -quiet -q 82 "$png" -o "${png%.png}.webp" && rm -f "$png"
  done
  EXT=webp
else
  echo "cwebp not found — keeping PNG page images (much larger)" >&2
  EXT=png
fi

SIZE=$(du -m "$OUT/$SLUG.pdf" | cut -f1)
PAGES=$(ls "$OUT"/page-*."$EXT" 2>/dev/null | wc -l | tr -d ' ')
echo "Wrote $PAGES page images (.$EXT); PDF is ${SIZE} MB"
echo "Set pdfPages: $PAGES in the project frontmatter."
[ "$SIZE" -gt 20 ] && echo "WARNING: PDF is over 20 MB — see the brief's file-size rules." >&2
exit 0
