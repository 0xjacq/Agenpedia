#!/usr/bin/env bash
# Pre-commit wiki lint: checks for broken wikilinks in wiki/*.md
# Exit 0 = clean, Exit 2 = broken wikilinks found (blocks commit)
# Install: git config core.hooksPath scripts/hooks

set -euo pipefail

WIKI_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}/wiki"

if [ ! -d "$WIKI_DIR" ]; then
  exit 0
fi

broken=()

for file in "$WIKI_DIR"/*.md; do
  [ -f "$file" ] || continue

  # Extract all [[wikilinks]] from the file
  while IFS= read -r link; do
    # Strip display text from [[target|display]] format
    target="${link%%|*}"
    target_file="$WIKI_DIR/${target}.md"
    if [ ! -f "$target_file" ]; then
      basename=$(basename "$file")
      broken+=("$basename: [[${link}]] -> ${target}.md not found")
    fi
  done < <(grep -o '\[\[[^]]*\]\]' "$file" 2>/dev/null | sed 's/^\[\[//;s/\]\]$//' || true)
done

if [ ${#broken[@]} -gt 0 ]; then
  echo "Pre-commit wiki lint FAILED: broken wikilinks found"
  echo ""
  for msg in "${broken[@]}"; do
    echo "  - $msg"
  done
  echo ""
  echo "Fix broken wikilinks or run the lint skill for a full check."
  exit 2
fi

exit 0
