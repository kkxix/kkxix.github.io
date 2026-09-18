#!/usr/bin/env bash
# Regenerate public/cv/katie-knox-cv.pdf from the /cv page.
# The PDF is printed from the site itself, so the page and the download can
# never drift apart. Run after editing src/pages/cv.astro.
set -euo pipefail
PORT="${PORT:-4331}"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
[ -x "$CHROME" ] || { echo "Chrome not found at $CHROME — set CHROME=..." >&2; exit 1; }

npm run build
npx astro preview --port "$PORT" --host 127.0.0.1 >/dev/null 2>&1 &
PREVIEW=$!
trap 'kill $PREVIEW 2>/dev/null || true' EXIT
until curl -s -o /dev/null -m 3 "http://127.0.0.1:$PORT/cv"; do sleep 1; done

mkdir -p public/cv
"$CHROME" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$PWD/public/cv/katie-knox-cv.pdf" \
  "http://127.0.0.1:$PORT/cv" 2>/dev/null
echo "Wrote public/cv/katie-knox-cv.pdf ($(du -h public/cv/katie-knox-cv.pdf | cut -f1))"
