# craft — quality-gated coding mode

A coding mode for **opencode**, **Claude Code** and **Codex CLI** that builds any
application or requirement with **enforced** quality gates. Not a suggestion
list — measurable thresholds and a read-only reviewer that must return
`VERDICT: APPROVED` before any change counts as done.

## Why

AI coding agents happily ship a 90-line function with 6 nesting levels, three
callbacks-in-callbacks, and a 7-parameter signature, and call it valid. `craft`
makes that impossible: every unit is **measured** and **reviewed** before it is
accepted.

```
function body lines      ≤ 40 target · > 60 BLOCKER
nesting depth            ≤ 2 target · ≥ 4 BLOCKER
cyclomatic complexity    ≤ 6 target · > 10 BLOCKER
nested anonymous funcs   ≤ 1 level · ≥ 3 BLOCKER
parameters               ≤ 3 target · > 5 BLOCKER
file lines               ≤ 200 · > 400 BLOCKER
```

Plus a code-smell catalog (duplicated code, feature envy, primitive obsession,
boolean flag args, magic numbers…), the five SOLID questions applied per unit,
and a **design-pattern pressure rule**: patterns are applied only when a
requirement shows the pressure (recorded as `Pattern X — trigger: <requirement>`),
and an abstraction with no second user is flagged as speculative generality.

## How it works

Every run starts the same way:

1. **Load the gate rulebook** (`craft-gates` skill) — mandatory step 1.
2. **Phase 0 — mode detection**, no ceremony forced:
   - **A · Full SDD** — greenfield or explicit spec-driven request → spec/design/tasks artifacts (following the repo's existing spec convention if it has one: OpenSpec, `specs/`, etc.).
   - **B · Spec-lite** — informal requirements → one compact page (requirements, Given/When/Then acceptance, out-of-scope), confirmed, then implement.
   - **C · Craft-only** — fix/refactor/review → zero docs, straight to the gate loop.
3. **Implement in small units that pass the gates by construction** (guard
   clauses, extract method, named functions over inline callbacks, async/await
   over `.then()` stacks).
4. **Nothing is "done"** until the `craft-reviewer` (a read-only subagent)
   reports actual measured numbers per function and returns `APPROVED` with
   0 BLOCKERS. MAJORS require written justification; exemptions for line gates
   require a `// gate-exemption: <reason>` comment.

## Install

```bash
git clone https://github.com/yamillanz/craft-coding-mode && cd craft-coding-mode
./install.sh            # installs into every tool it finds
# or selectively:
./install.sh opencode
./install.sh claude
./install.sh codex
```

Restart the tool afterwards (config is read at startup). Full instructions:
[INSTALL.md](INSTALL.md).

## Use

| Tool | Start a run | Review-only pass | Full-flow agent |
| --- | --- | --- | --- |
| opencode | `/craft <request>` or switch agent `craft` (Tab) | `/gates [files]` | `craft` (primary) + `craft-reviewer` (subagent) |
| Claude Code | `/craft <request>` | `/gates [files]` | `claude --agent craft` |
| Codex CLI | ask anything — `craft` skill triggers, or invoke it explicitly | `use the craft-review skill on X` | skills `craft` + `craft-review` + `craft-gates` |

## Repository layout

```
opencode/     agent/{craft,craft-reviewer}.md · skills/craft-gates/ · command/{craft,gates}.md
claude/       agents/{craft,craft-reviewer}.md · skills/craft-gates/ · commands/{craft,gates}.md
codex/        skills/{craft,craft-review,craft-gates}/ · AGENTS.snippet.md
```

`craft-gates/SKILL.md` (the rulebook) is the single source of truth and is
byte-identical across ports; only the adapters differ.

## Notes & limitations

- The reviewer BLOCKER set is intentionally narrow (hard gates, failed
  acceptance criteria, IO in the domain layer) so verdicts stay consistent.
- In **Codex** there are no native subagent files: `craft` runs the
  `craft-review` pass itself, following the same §6 verdict protocol and
  measurement obligations.
- Refusing to pass gates on a hot path: every rule can be waived for line-count
  gates on declarative tables with the written exemption protocol; nesting,
  complexity and callback-depth gates have **no** exemptions.
- Test the enforcement: `ugly-example.ts` (in the repo root) is seeded with five
  guaranteed BLOCKERS — run `/gates ugly-example.ts` and you must get
  `CHANGES_REQUIRED` with the measured numbers.

## License

MIT
