# Convert a large PDF into Markdown files (one file per page)

This document explains how to use `scripts/pdf_to_markdown.sh` to convert a big PDF into Markdown files using `markitdown`.

## Requirements
- `pdfseparate` (from `poppler-utils`) — used to split the PDF into single-page PDFs
  - Ubuntu: `sudo apt install poppler-utils`
- `markitdown` — PDF → Markdown converter
  - Recommended: `pip install --user markitdown` or `npm i -g markitdown`

## Usage

1. Make the script executable:

```bash
chmod +x scripts/pdf_to_markdown.sh
```

2. Run it:

```bash
./scripts/pdf_to_markdown.sh path/to/large.pdf path/to/output-md-dir
# e.g. ./scripts/pdf_to_markdown.sh ./thesis.pdf ./markdown
```

By default the script writes output files into `./markdown` if no output directory is provided.

Each page is converted into a Markdown file named `page-0001.md`, `page-0002.md`, etc.

## Tips
- For very large PDFs you can parallelize the conversion by splitting and converting multiple single-page PDFs at once (e.g. with `parallel`), or modify the script to run markitdown in background jobs.
- If `markitdown` fails on a specific page, check that the page PDF is valid: `pdfinfo page-0001.pdf`.

## Example

```bash
./scripts/pdf_to_markdown.sh big-report.pdf markdown
ls -1 markdown | head
# page-0001.md
# page-0002.md
# ...
```
