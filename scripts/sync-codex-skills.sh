#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/.codex/skills"
TARGET_DIR="${CODEX_HOME:-$HOME/.codex}/skills"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "No project skills found: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

for skill_dir in "$SOURCE_DIR"/*; do
  [[ -d "$skill_dir" ]] || continue
  skill_name="$(basename "$skill_dir")"
  rm -rf "$TARGET_DIR/$skill_name"
  cp -R "$skill_dir" "$TARGET_DIR/$skill_name"
  echo "Synced $skill_name -> $TARGET_DIR/$skill_name"
done

echo "Restart Codex to pick up synced skills."
