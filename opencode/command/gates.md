---
description: Quality-gate review only — no specs. Pass files/paths, or nothing to review the working tree (git diff).
agent: craft
---

Mode C, review-only. Load the `craft-gates` skill and run the
`craft-reviewer` subagent over the target below (if empty: the current working
tree changes — `git status` + `git diff`). Do NOT create any spec artifacts
and do NOT modify code in this pass.

Report the reviewer's verdict block verbatim (VERDICT, gate numbers per
function, findings with severities). End with a one-line offer: apply the
fixes or not.

TARGET:
$ARGUMENTS
