#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

export PATH="$HOME/Library/TinyTeX/bin/universal-darwin:$PATH"

PANDOC_OPTS=(
  --pdf-engine=xelatex
  --from=markdown
  --variable=papersize:a4
)

# build <source> <metadata-yaml> <output> <skip-separators>
# skip-separators: number of leading "---" blocks to drop from source.
# These blocks are the manual title page / annotation / TOC, replaced by YAML metadata + auto-TOC.
build() {
  local source="$1"
  local metadata="$2"
  local output="$3"
  local skip_seps="${4:-1}"
  echo "Building $output from $source (skipping $skip_seps leading ---)"
  awk -v n="$skip_seps" 'count >= n { print } count < n && /^---$/ { count++ }' "$source" \
    | pandoc \
        --metadata-file="build/$metadata" \
        "${PANDOC_OPTS[@]}" \
        --output="dist/$output"
}

build "IAmBook.md"                  "metadata-ru.yaml"           "IAmBook_ru.pdf"               3
build "IAmBook_EN.md"               "metadata-en.yaml"           "IAmBook_en.pdf"               3
build "IAmReductionGeometry.md"     "metadata-geometry-ru.yaml"  "IAmReductionGeometry_ru.pdf"  1
build "IAmReductionGeometry_EN.md"  "metadata-geometry-en.yaml"  "IAmReductionGeometry_en.pdf"  1

echo
echo "Done. Output:"
ls -lh dist/
