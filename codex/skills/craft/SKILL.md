---
name: craft
description: Quality-gated coding workflow. Use when building any application or requirement, adding features, or fixing/refactoring code with enforced best practices — SOLID, justified design patterns, code-smell discipline, and measurable gates (function length, nesting depth, cyclomatic complexity, nested anonymous callbacks). No change is done until it passes the craft-review pass.
metadata:
  short-description: Quality-gated build and refactor mode
---

You are running `craft`, a quality-gated coding workflow. Never let
"big, tangled, valid-looking" code pass. Communicate in the user's language;
write code artifacts (names, comments) in English.

The `craft-gates` skill is the rulebook (§1 hard gates, §2 smell catalog,
§3 SOLID questions, §4 pattern pressure rule, §5 artifacts by mode, §6 verdict
protocol). Consult it and obey it for the whole session.

## Phase 0 — Mode detection (state your choice in one line)

- Mode A — Full SDD: greenfield app or explicit spec-driven request →
  spec/design/tasks artifacts under the repo's existing spec convention
  (check for `specs/`, `openspec/`, docs conventions before inventing paths).
- Mode B — Spec-lite: informal requirements → one compact spec-lite page
  (§5), confirm with the user, then implement slice by slice.
- Mode C — Craft-only: fix/refactor/review/small change → no spec artifacts;
  straight to implementation + gate loop.

## Invariants (all modes)

1. Nothing is "done" until its §1 gates are MEASURED and the numbers reported
   (body lines, max nesting, complexity, anonymous-callback depth, params).
2. After each slice, run a full review pass on the changed files following the
   §6 protocol exactly — verdict block with actual numbers per function.
   Codex has no subagents, so you are both author and reviewer here: after
   writing the code, re-read every changed function as if hostile, measure it,
   and do not soften the verdict. Any BLOCKER ⇒ CHANGES_REQUIRED ⇒ fix and
   re-measure. Repeat until APPROVED with 0 BLOCKERS.
3. Line-count gates may be waived only via the `// gate-exemption: <reason>`
   comment on declarative tables/config; nesting, complexity and callback-depth
   gates have no exemptions.
4. Patterns only via §4 with a recorded `trigger: <requirement>`; an
   abstraction with no second user is speculative generality.
5. Domain logic has zero concrete IO (§3 D).
6. Out-of-scope ideas go to a "follow-ups" list, never into the code.

## Implementation discipline

Write small units that pass §1 BY CONSTRUCTION: guard clauses and early
returns, extract method, named functions instead of inline anonymous callbacks
(depth ≤ 1), async/await over `.then()` stacks, parameter objects for long
lists. Run the repo's existing tooling (typecheck/lint/tests) detected from
lockfiles/configs; for behavior-preserving refactors, prove equivalence with a
differential or side-effect test when practical.

Final report: acceptance criteria with evidence, patterns applied (triggers),
gate numbers per function, accepted MAJORS/MINORs with justification,
follow-ups.
