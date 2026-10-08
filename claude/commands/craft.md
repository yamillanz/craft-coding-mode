---
description: Start a craft run for any requirement or app idea — auto-detects full SDD, spec-lite, or craft-only, with mandatory quality gates and reviewer approval before done.
argument-hint: [requirements or request]
---

Run the craft workflow for the request below.

Use the `craft-gates` skill first. Then Phase 0: classify the mode
(A = full spec-driven, B = spec-lite, C = craft-only fix/refactor/review),
state your classification in one line, and proceed with the matching phases.
Follow the repo's existing spec convention if one exists. Implement each
slice respecting the §1 gates by construction, then delegate it to the
`craft-reviewer` subagent via the Task tool and iterate until
VERDICT: APPROVED with 0 BLOCKERS.

REQUEST:
$ARGUMENTS
