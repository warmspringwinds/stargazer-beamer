#!/usr/bin/env bash
# Build the deck and (optionally) render per-slide PNG previews.
#   ./build.sh            -> compile slides.tex
#   ./build.sh foo.tex    -> compile foo.tex
#   PREVIEW=0 ./build.sh  -> skip PNG previews
#
# Requires: tectonic  (https://tectonic-typesetting.github.io)
# Optional: pdftoppm  (poppler) for the PNG previews
set -euo pipefail

# Make Homebrew binaries visible if present (no-op elsewhere).
[ -d /opt/homebrew/bin ] && export PATH="/opt/homebrew/bin:$PATH"

DECK="${1:-slides.tex}"
BASE="${DECK%.tex}"

if ! command -v tectonic >/dev/null 2>&1; then
  echo "error: 'tectonic' not found. Install it: https://tectonic-typesetting.github.io" >&2
  exit 1
fi

echo "-> compiling ${DECK} ..."
tectonic -X compile "${DECK}" --outdir . --keep-logs >/dev/null
echo "ok  ${BASE}.pdf"

if [[ "${PREVIEW:-1}" == "1" ]] && command -v pdftoppm >/dev/null 2>&1; then
  mkdir -p build/preview
  rm -f build/preview/*.png
  pdftoppm -png -r 130 "${BASE}.pdf" build/preview/slide >/dev/null 2>&1
  echo "ok  previews -> build/preview/"
fi
