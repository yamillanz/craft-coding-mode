# Install

One-liner for all tools found on your machine:

```bash
./install.sh
```

Or install per tool. `install.sh` does exactly the copy steps below.

## opencode

Global (recommended — available in every project):

```
~/.config/opencode/agents/craft.md
~/.config/opencode/agents/craft-reviewer.md
~/.config/opencode/skills/craft-gates/SKILL.md
~/.config/opencode/command/craft.md
~/.config/opencode/command/gates.md
```

Per-project alternative: copy `opencode/agent/` → `.opencode/agents/`,
`opencode/skills/` → `.opencode/skills/`, `opencode/command/` →
`.opencode/commands/` inside the project.

**Restart opencode after installing** (config is loaded at startup).

Usage:

- Switch to the `craft` primary agent with `Tab`, or run `/craft <request>`.
- `/gates [files]` runs a review-only pass (no specs, no edits). With no
  arguments it reviews `git status` + `git diff`.
- Optional, always-on: add `"default_agent": "craft"` to
  `~/.config/opencode/opencode.json`.

## Claude Code

Global:

```
~/.claude/agents/craft.md
~/.claude/agents/craft-reviewer.md
~/.claude/skills/craft-gates/SKILL.md
~/.claude/commands/craft.md
~/.claude/commands/gates.md
```

Project-level alternative: same tree under `.claude/` in the repo.

Usage:

- `/craft <request>` and `/gates [files]` from any session.
- To run the whole flow as the main thread: `claude --agent craft`.
- The reviewer subagent (`craft-reviewer`) is spawned via the Task tool; its
  `tools` field keeps it read-only (`Edit`/`Write` are not granted).

## Codex CLI

Codex has no file-based subagents, so the flow ships as three skills:
`craft` (workflow + self-run review pass), `craft-review` (standalone
reviewer protocol) and `craft-gates` (rulebook).

```
~/.codex/skills/craft/SKILL.md
~/.codex/skills/craft-review/SKILL.md
~/.codex/skills/craft-gates/SKILL.md
```

Optional always-on hint: append `codex/AGENTS.snippet.md` to your
`~/.codex/AGENTS.md` (or paste into a project `AGENTS.md`) so normal sessions
consult the `craft` skill for build/refactor/review work.

Usage: ask Codex anything — the skills are discovered and invoked by
description (e.g. "refactor src/orders.ts until the gates pass, preserving
behavior"). Project-level alternative: `.agents/skills/` in the repo.

## Verify the install

```bash
# in any project, inside the tool:
/gates ugly-example.ts        # opencode / Claude Code
```

Expected: `VERDICT: CHANGES_REQUIRED`, ≥ 4 BLOCKERS, and a table of actual
measured numbers (lines / nesting / complexity / callback-depth) per function.
If it says APPROVED, the gate is not loading — check the skill paths above and
restart the tool.

## Uninstall

Remove the copied files:

```bash
rm ~/.config/opencode/agents/craft*.md ~/.config/opencode/skills/craft-gates -r \
   ~/.config/opencode/command/{craft,gates}.md
rm ~/.claude/agents/craft*.md ~/.claude/skills/craft-gates -r ~/.claude/commands/{craft,gates}.md
rm ~/.codex/skills/{craft,craft-review,craft-gates} -r
```
