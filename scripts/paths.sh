#!/usr/bin/env bash
# Resolve this plugin's user data directory (the overlay that survives plugin
# updates) and look up files in it, overlay first, then the plugin's seeds.
#
#   scripts/paths.sh             -> data dir, rule that picked it, overlay status
#   scripts/paths.sh dir         -> data dir only
#   scripts/paths.sh init        -> create the overlay and copy in any missing
#                                   override stubs; never overwrites a file
#   scripts/paths.sh backends    -> every backend: <name>\t<user|builtin>\t<path>
#   scripts/paths.sh backend N   -> path of backend N (user copy wins), exit 1 if none
#   scripts/paths.sh override S  -> path of the user's override for skill S, exit 1 if none
#   scripts/paths.sh template    -> recipe template dir (user copy wins)
#
# Data dir: $CUSTOM_MODEL_PLANNING_HOME if set, otherwise
# ${CLAUDE_USER_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/claude-plugins}/custom-model-planning
# (the same folder that holds config.json).
set -euo pipefail

NAME=custom-model-planning
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
if [[ -n "${CUSTOM_MODEL_PLANNING_HOME:-}" ]]; then
  DIR="$CUSTOM_MODEL_PLANNING_HOME"; RULE="CUSTOM_MODEL_PLANNING_HOME"
elif [[ -n "${CLAUDE_USER_DATA:-}" ]]; then
  DIR="$CLAUDE_USER_DATA/$NAME"; RULE="CLAUDE_USER_DATA"
else
  DIR="${XDG_DATA_HOME:-$HOME/.local/share}/claude-plugins/$NAME"; RULE="default"
fi

case "${1:-}" in
  dir) echo "$DIR" ;;
  init)
    mkdir -p "$DIR/overrides" "$DIR/backends" "$DIR/recipe-template"
    for f in "$PLUGIN_ROOT"/seeds/overrides/*.md; do
      t="$DIR/overrides/$(basename "$f")"
      [[ -e "$t" ]] || cp "$f" "$t"
    done
    echo "$DIR" ;;
  backends)
    declare -A seen=()
    for f in "$DIR"/backends/*.md; do
      [[ -e "$f" ]] || continue
      b=$(basename "$f" .md); seen[$b]=1
      printf '%s\tuser\t%s\n' "$b" "$f"
    done
    for f in "$PLUGIN_ROOT"/seeds/backends/*.md; do
      b=$(basename "$f" .md)
      [[ -n "${seen[$b]:-}" ]] && continue
      printf '%s\tbuiltin\t%s\n' "$b" "$f"
    done ;;
  backend)
    n="${2:?backend name}"
    if [[ -f "$DIR/backends/$n.md" ]]; then echo "$DIR/backends/$n.md"
    elif [[ -f "$PLUGIN_ROOT/seeds/backends/$n.md" ]]; then echo "$PLUGIN_ROOT/seeds/backends/$n.md"
    else echo "no backend named '$n'" >&2; exit 1; fi ;;
  override)
    s="${2:?skill name}"
    if [[ -f "$DIR/overrides/$s.md" ]]; then echo "$DIR/overrides/$s.md"; else exit 1; fi ;;
  template)
    if [[ -f "$DIR/recipe-template/recipe.yaml" ]]; then echo "$DIR/recipe-template"
    else echo "$PLUGIN_ROOT/seeds/recipe-template"; fi ;;
  "")
    echo "data_dir: $DIR"
    echo "rule: $RULE"
    echo "plugin_root: $PLUGIN_ROOT"
    echo "overlay: $([[ -d "$DIR/overrides" ]] && echo present || echo 'missing (run: paths.sh init)')" ;;
  *) echo "usage: $0 [dir|init|backends|backend NAME|override SKILL|template]" >&2; exit 2 ;;
esac
