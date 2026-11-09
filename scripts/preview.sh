#!/bin/sh
# Render the HTML preview and, when Chrome is available, a PNG screenshot.
# Usage: scripts/preview.sh
set -eu
cd "$(dirname "$0")/.."

nvim --clean --headless -l scripts/preview.lua

chrome="${CHROME:-google-chrome}"
if command -v "$chrome" >/dev/null 2>&1; then
  "$chrome" --headless=new --disable-gpu --hide-scrollbars \
    --window-size=1700,1600 --screenshot=/tmp/rsms-full.png \
    "file:///tmp/rsms-preview/preview.html" >/dev/null 2>&1
  magick /tmp/rsms-full.png -fuzz 0% -trim +repage \
    -bordercolor '#202020' -border 24 assets/preview.png
  echo "wrote assets/preview.png"
else
  echo "Chrome not found; HTML preview is at /tmp/rsms-preview/preview.html"
fi
