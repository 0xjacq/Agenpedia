#!/usr/bin/env bash
# Download Obsidian community plugin binaries (not committed to git).
# Run this once after cloning: ./scripts/setup-obsidian.sh
# Requires: curl, jq

set -euo pipefail

PLUGIN_DIR="$(git rev-parse --show-toplevel)/wiki/.obsidian/plugins"

# Format: "plugin-id|github-owner/repo"
PLUGINS=(
  "dataview|blacksmithgu/obsidian-dataview"
  "obsidian-minimal-settings|kepano/obsidian-minimal-settings"
  "obsidian-style-settings|mgmeyers/obsidian-style-settings"
  "graph-banner|ras0q/graph-banner"
  "sync-graph-settings|Xallt/sync-graph-settings"
)

check_deps() {
  for cmd in curl jq; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Error: '$cmd' is required. Install it and retry." >&2
      exit 1
    fi
  done
}

install_plugin() {
  local id="$1"
  local repo="$2"
  local dir="$PLUGIN_DIR/$id"

  echo "  → $id"

  local tag
  tag=$(curl -sf "https://api.github.com/repos/$repo/releases/latest" | jq -r '.tag_name')
  if [ -z "$tag" ] || [ "$tag" = "null" ]; then
    echo "    Warning: no release found for $repo, skipping." >&2
    return
  fi

  mkdir -p "$dir"

  local base="https://github.com/$repo/releases/download/$tag"
  curl -sfL "$base/main.js"      -o "$dir/main.js"      || { echo "    Warning: main.js not found for $id" >&2; }
  curl -sfL "$base/styles.css"   -o "$dir/styles.css"   2>/dev/null || true
}

main() {
  check_deps

  echo "Installing Obsidian community plugins into wiki/.obsidian/plugins/"
  echo ""

  for entry in "${PLUGINS[@]}"; do
    local id="${entry%%|*}"
    local repo="${entry##*|}"
    install_plugin "$id" "$repo"
  done

  echo ""
  echo "Done. Plugins installed."
  echo ""
  echo "Next steps:"
  echo "  1. Open wiki/ as a vault in Obsidian."
  echo "  2. Settings → Community plugins → Enable 'Allow community plugins' → enable each plugin."
  echo "  3. Settings → Appearance → Browse → search 'Minimal' → install and enable the theme."
}

main "$@"
