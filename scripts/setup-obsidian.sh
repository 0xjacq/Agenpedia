#!/usr/bin/env bash
# Download Obsidian community plugin and theme assets (not committed to git).
# Run this once after cloning: ./scripts/setup-obsidian.sh
# Requires: curl, jq

set -euo pipefail

PLUGIN_DIR="$(git rev-parse --show-toplevel)/wiki/.obsidian/plugins"
THEME_DIR="$(git rev-parse --show-toplevel)/wiki/.obsidian/themes"
THEME_NAME="Minimal"
THEME_REPO="kepano/obsidian-minimal"

# Format: "plugin-id|github-owner/repo"
PLUGINS=(
  "dataview|blacksmithgu/obsidian-dataview"
  "obsidian-minimal-settings|kepano/obsidian-minimal-settings"
  "obsidian-style-settings|mgmeyers/obsidian-style-settings"
  "graph-banner|ras0q/obsidian-graph-banner"
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

  local release_json tag
  release_json=$(curl -sfL "https://api.github.com/repos/$repo/releases/latest" || true)
  if [ -z "$release_json" ]; then
    echo "    Warning: could not fetch latest release for $repo, skipping." >&2
    return
  fi

  tag=$(printf '%s' "$release_json" | jq -r '.tag_name')
  if [ -z "$tag" ] || [ "$tag" = "null" ]; then
    echo "    Warning: no release found for $repo, skipping." >&2
    return
  fi

  mkdir -p "$dir"

  local base="https://github.com/$repo/releases/download/$tag"
  curl -sfL "$base/main.js"      -o "$dir/main.js"      || { echo "    Warning: main.js not found for $id" >&2; }
  curl -sfL "$base/styles.css"   -o "$dir/styles.css"   2>/dev/null || true
}

install_theme() {
  local dir="$THEME_DIR/$THEME_NAME"

  echo ""
  echo "Installing Obsidian theme into wiki/.obsidian/themes/"
  echo "  → $THEME_NAME"

  local release_json tag
  release_json=$(curl -sfL "https://api.github.com/repos/$THEME_REPO/releases/latest" || true)
  if [ -z "$release_json" ]; then
    echo "    Warning: could not fetch latest release for $THEME_REPO, skipping theme install." >&2
    return
  fi

  tag=$(printf '%s' "$release_json" | jq -r '.tag_name')
  if [ -z "$tag" ] || [ "$tag" = "null" ]; then
    echo "    Warning: no release found for $THEME_REPO, skipping theme install." >&2
    return
  fi

  mkdir -p "$dir"

  local base="https://github.com/$THEME_REPO/releases/download/$tag"
  curl -sfL "$base/theme.css"      -o "$dir/theme.css"      || { echo "    Warning: theme.css not found for $THEME_NAME" >&2; }
  curl -sfL "$base/manifest.json"  -o "$dir/manifest.json"  || { echo "    Warning: manifest.json not found for $THEME_NAME" >&2; }
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

  install_theme

  echo ""
  echo "Done. Plugins and theme installed."
  echo ""
  echo "Next steps:"
  echo "  1. Open wiki/ as a vault in Obsidian."
  echo "  2. Settings → Community plugins → Enable 'Allow community plugins' → enable each plugin."
  echo "  3. Settings → Appearance → select 'Minimal' if it is not already active."
}

main "$@"
