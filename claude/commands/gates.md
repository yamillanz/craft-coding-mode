---
description: Quality-gate review only — no specs, no edits. Pass files/paths, or nothing to review the working tree (git status + git diff).
argument-hint: [files or paths]
---

Read-only quality pass. Use the `craft-gates` skill, then spawn the
`craft-reviewer` subagent via the Task tool on the target below (if empty:
`git status` + `git diff`). Do NOT create spec artifacts and do NOT modify
code in this pass.

Report the reviewer's verdict block verbatim (VERDICT, gate numbers per
function, findings with severities). End with a one-line offer: apply the
fixes or not.

TARGET:
$ARGUMENTS
