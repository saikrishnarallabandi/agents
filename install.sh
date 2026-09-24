#!/usr/bin/env bash
#
# install.sh — install the agent definitions on this machine.
#
#   git clone https://github.com/saikrishnarallabandi/agents.git
#   cd agents && ./install.sh
#
# By default installs for both Claude Code and GitHub Copilot (VS Code).
# Flags: --claude-only | --copilot-only | --help
#
# What it does (copies only, never deletes or overwrites blindly):
#   Claude Code : agents/*/*.md        -> ~/.claude/agents/
#   Copilot     : agents/*/*.agent.md  -> ~/.copilot/agents/
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/agents"

INSTALL_CLAUDE=true
INSTALL_COPILOT=true

for arg in "$@"; do
  case "$arg" in
    --claude-only)  INSTALL_COPILOT=false ;;
    --copilot-only) INSTALL_CLAUDE=false ;;
    --help|-h)
      echo "Usage: ./install.sh [--claude-only | --copilot-only]"
      exit 0 ;;
    *) echo "Unknown flag: $arg (see --help)" >&2; exit 1 ;;
  esac
done

if $INSTALL_CLAUDE; then
  DEST="$HOME/.claude/agents"
  mkdir -p "$DEST"
  count=0
  while IFS= read -r f; do cp "$f" "$DEST/"; count=$((count+1)); done \
    < <(find "$SRC" -name "*.md" ! -name "*.agent.md")
  echo "Claude Code : installed $count agents to $DEST"
  echo "              invoke via the Task tool, e.g. subagent_type: \"paper-writer\""
fi

if $INSTALL_COPILOT; then
  DEST="$HOME/.copilot/agents"
  mkdir -p "$DEST"
  count=0
  while IFS= read -r f; do cp "$f" "$DEST/"; count=$((count+1)); done \
    < <(find "$SRC" -name "*.agent.md")
  echo "GitHub Copilot: installed $count agents to $DEST"
  echo "              pick them from the agent dropdown in Copilot Chat."
  echo "              If VS Code doesn't list them, add this folder to the"
  echo "              'chat.agentFilesLocations' setting."
fi

echo "Done."
