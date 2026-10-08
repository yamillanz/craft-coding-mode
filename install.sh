#!/usr/bin/env bash
# craft-coding-mode installer — copies the mode into opencode / Claude Code /
# Codex CLI directories. Usage: ./install.sh [opencode|claude|codex|all]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Registry — trigger: three known ports with install/detect operations that
# must stay in sync (§2 duplicated switch; extension = one new entry + one
# install_<name> function).
declare -A PORT_DEST=([opencode]="$HOME/.config/opencode" [claude]="$HOME/.claude" [codex]="$HOME/.codex")

install_opencode() {
  local dest="${PORT_DEST[opencode]}"
  mkdir -p "$dest/agents" "$dest/skills" "$dest/command"
  cp "$ROOT"/opencode/agent/craft.md "$ROOT"/opencode/agent/craft-reviewer.md "$dest/agents/"
  rm -rf "$dest/skills/craft-gates"
  cp -R "$ROOT/opencode/skills/craft-gates" "$dest/skills/"
  cp "$ROOT"/opencode/command/craft.md "$ROOT"/opencode/command/gates.md "$dest/command/"
  echo "opencode: installed into $dest — restart opencode to load it"
}

install_claude() {
  local dest="${PORT_DEST[claude]}"
  mkdir -p "$dest/agents" "$dest/skills" "$dest/commands"
  cp "$ROOT"/claude/agents/craft.md "$ROOT"/claude/agents/craft-reviewer.md "$dest/agents/"
  rm -rf "$dest/skills/craft-gates"
  cp -R "$ROOT/claude/skills/craft-gates" "$dest/skills/"
  cp "$ROOT"/claude/commands/craft.md "$ROOT"/claude/commands/gates.md "$dest/commands/"
  echo "claude: installed into $dest — use /craft and /gates, or run: claude --agent craft"
}

install_codex() {
  local dest="${PORT_DEST[codex]}"
  mkdir -p "$dest/skills"
  local skill
  for skill in craft craft-review craft-gates; do
    rm -rf "$dest/skills/$skill"
    cp -R "$ROOT/codex/skills/$skill" "$dest/skills/"
  done
  echo "codex: installed skills craft + craft-review + craft-gates into $dest/skills"
  echo "codex: optional — append $ROOT/codex/AGENTS.snippet.md to $dest/AGENTS.md"
}

install_one() {
  local name="$1"
  if ! declare -F "install_$name" >/dev/null; then
    echo "unknown tool: $name (valid: ${!PORT_DEST[*]} | all)" >&2
    return 1
  fi
  "install_$name"
}

detect_tools() {
  local name found=()
  for name in "${!PORT_DEST[@]}"; do
    if [ -d "${PORT_DEST[$name]}" ]; then
      found+=("$name")
    fi
  done
  if [ "${#found[@]}" -eq 0 ]; then
    echo "no supported tool directory found (${PORT_DEST[*]})." >&2
    echo "install explicitly: ./install.sh ${!PORT_DEST[*]} | all" >&2
    return 1
  fi
  printf '%s\n' "${found[@]}"
}

main() {
  local target="${1:-all}"
  if [ "$target" != "all" ]; then
    install_one "$target"
    return
  fi
  local detected tool
  if ! detected="$(detect_tools)"; then
    return 1
  fi
  while read -r tool; do
    install_one "$tool"
  done <<< "$detected"
}

main "$@"
