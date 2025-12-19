#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<-EOF
Usage: $0 INPUT_PDF [OUTPUT_DIR]

Converts INPUT_PDF into one Markdown file per PDF page using markitdown.
- INPUT_PDF: path to the large PDF to convert
- OUTPUT_DIR: directory to write markdown files (default: ./markdown)

This script requires: pdfseparate (poppler-utils) and markitdown (pip or npm).
EOF
}

if [ $# -lt 1 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  show_help
  exit 1
fi

INPUT="$1"
OUTPUT_DIR="${2:-markdown}"

if [ ! -f "$INPUT" ]; then
  echo "ERROR: INPUT file '$INPUT' does not exist." >&2
  exit 2
fi

mkdir -p "$OUTPUT_DIR"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# Check dependencies
if ! command -v pdfseparate >/dev/null 2>&1; then
  echo "ERROR: 'pdfseparate' not found. Install it (Ubuntu: sudo apt install poppler-utils)." >&2
  exit 3
fi

if ! command -v markitdown >/dev/null 2>&1; then
  echo "'markitdown' not found. Trying to install via pip (user install)..."
  if command -v python3 >/dev/null 2>&1 && python3 -m pip install --user markitdown >/dev/null 2>&1; then
    export PATH="$HOME/.local/bin:$PATH"
    echo "Installed markitdown via pip to ~/.local/bin (added to PATH for this run)."
  else
    echo "Automatic install failed. Please install manually: 'pip install --user markitdown' or 'npm i -g markitdown'." >&2
    exit 4
  fi
fi

# Split PDF into pages
echo "Splitting PDF into pages..."
pdfseparate "$INPUT" "$TMPDIR/page-%04d.pdf"

# Convert each single-page PDF to markdown
printf "Converting pages to Markdown in '%s'...\n" "$OUTPUT_DIR"
count=0
for page in "$TMPDIR"/page-*.pdf; do
  basename="$(basename "$page" .pdf)"
  idx="${basename#page-}"
  outfile="$OUTPUT_DIR/$idx.md"
  printf "  - page %s -> %s\n" "$idx" "$outfile"

  # Try markitdown writing directly to file (try -o first, then stdout fallback)
  if markitdown "$page" -o "$outfile" >/dev/null 2>&1; then
    :
  else
    if markitdown "$page" > "$outfile" 2>/dev/null; then
      :
    else
      echo "ERROR: markitdown failed on '$page'" >&2
      exit 5
    fi
  fi

  count=$((count+1))
done

printf "Done: %d page(s) converted. Markdown files are in '%s'\n" "$count" "$OUTPUT_DIR"

exit 0
