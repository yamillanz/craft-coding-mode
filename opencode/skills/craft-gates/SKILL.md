---
name: craft-gates
description: Quantitative quality-gate rulebook for building or reviewing any code — hard thresholds for function length, nesting depth, cyclomatic complexity, nested anonymous callbacks; code-smell catalog; SOLID checks; design-pattern pressure rule; spec-lite and review verdict templates. Load at the start of any craft-mode design, implementation, or review pass.
---

# Craft Gates — Quality Gate Rulebook

This rulebook is the single source of truth for both the `craft` agent and the
`craft-reviewer` subagent. Severity levels: **BLOCKER** (must fix, never ship),
**MAJOR** (must fix unless explicitly justified in writing), **MINOR** (fix if
cheap). It applies to every mode — full spec-driven, spec-lite, or a plain
refactor/review of existing code.

## 1. Hard gates (measurable, non-negotiable)

| Metric | Target | MAJOR | BLOCKER |
| --- | --- | --- | --- |
| Function/method body lines (excl. signature, braces, blank) | ≤ 40 | 41–60 | > 60 |
| Nesting depth (if/for/try/callback levels) | ≤ 2 | 3 | ≥ 4 |
| Cyclomatic complexity per function | ≤ 6 | 7–10 | > 10 |
| Nested anonymous functions (JS/TS: closure-in-closure-in-closure) | ≤ 1 level | 2 | ≥ 3 levels |
| Parameters per function | ≤ 3 | 4–5 | > 5 |
| File lines | ≤ 200 | 201–400 | > 400 |
| Chained dependency `a.b.c.d` / `getA().getB().getC()` (Law of Demeter) | ≤ 2 hops | 3 | > 3 |

Exemption protocol: a declarative data table, config map, or generated file may
exceed the LINE gates ONLY if flagged with a one-line comment
`// gate-exemption: <reason>` AND mentioned in the review response. No
exemption exists for nesting, complexity, or callback-depth gates. Never mark
a unit "done" while a BLOCKER stands.

Refactor moves when a gate trips (in order of preference):
1. **Guard clauses / early return** to flatten nesting.
2. **Extract method** — one level of abstraction per function (the compiler
   and the HTTP client do not belong in the same function).
3. **Named function instead of inline anonymous callback**; lift callbacks out
   of chains (`map(toX)`, `flatMap(findOrderById)`). `async/await` beats
   `.then()` stacks; Promise combinators beat nested callbacks.
4. **Parameter object** for long parameter lists / data clumps.
5. **Strategy/polymorphism** instead of switch/if-chains on type or state.

## 2. Code smells catalog

MAJOR: Long Parameter List, Boolean Flag Argument (param that switches control
flow), Duplicated Code (>3 near-identical lines), Feature Envy (method uses
another class's data more than its own), Data Class / Anemic Domain Model, God
Object, Shotgun Surgery (one change ripples across many files), Divergent
Change (one module edited for several unrelated reasons), Primitive Obsession
(raw strings/numbers where a domain type pays), Magic Numbers/Strings,
`if/switch` on type with ≥ 3 branches, Temp variables used once (just inline
them), Comments that explain WHAT instead of WHY, Dead Code, Speculative
Generality (abstraction with no second user).

MINOR: Inconsistent naming for the same concept, `Util`/`Helper`/`Manager`/
`Data`/`Info` catch-all names, Yoda conditions, redundant boolean comparisons
(`if (x === true)`), unnecessary intermediate collection allocations, mixed
camelCase/snake_case within a boundary.

## 3. SOLID — five questions per unit (class, module, or function group)

- **S** — How many reasons does this unit have to change? > 1 → split by
  responsibility.
- **O** — Does adding a variant require editing an existing `switch`/`if`
  chain? → introduce Strategy / Registry / polymorphism so extension = new
  file.
- **L** — Does any subtype ignore, override-to-noop, or assert-downcast the
  parent? → replace inheritance with composition.
- **I** — Do consumers stub methods they never call? → split the interface at
  each consumption site.
- **D** — Does domain logic import concrete IO (`fs`, `http`, DB driver,
  `Date.now`, `Math.random`)? → receive that capability as an injected
  port/parameter; concrete adapters live at the boundary (`adapters/`,
  `infra/`, `ports/`).

## 4. Design patterns — the pressure rule

Apply a pattern ONLY when a stated requirement or existing code shows the
pressure, and record the trigger as: `Pattern X — trigger: <requirement>`.
No pattern = no ceremony: an interface with one implementation and no boundary
value is speculative generality. Prefer plain functions/modules when state +
behavior don't justify a class.

Common trigger → pattern map:
- Interchangeable algorithm variants / conditional family → **Strategy**
- Many optional construction args / validated multi-step setup → **Builder**
- Object creation branches on input type → **Factory / Factory Method**
- Incompatible external API polluting domain code → **Adapter**
- Cross-cutting enhancement (caching, retry, logging, auth) on one component →
  **Decorator** (or middleware pipeline)
- Many subscribers to one event / fan-out → **Observer**
- Persistence isolated from domain → **Repository** (+ Unit of Work)
- Behavior keyed on lifecycle state with large conditionals → **State**
- Undo / queueing / parameterized operations → **Command**
- Traversal without exposing the structure → **Iterator**
- One instance per process is genuinely required → module-level singleton, NOT
  mutable global/class-static state; mutable globals are MAJOR.

## 5. Workflow artifacts by mode

**Mode A — full spec-driven** (greenfield or explicit request): every feature
gets `specs/<feature-slug>/`:
- `spec.md` — problem, users, functional requirements, Given/When/Then
  acceptance criteria, non-goals, constraints.
- `design.md` — architecture, module boundaries, dependency direction
  (domain → ports ← adapters), data flow, pattern decisions with triggers,
  error-handling and testing strategy.
- `tasks.md` — vertical slices, each implementable and reviewable in one pass;
  each with acceptance criteria + DoD including "craft-reviewer verdict
  APPROVED".

**Mode B — spec-lite** (informal requirements exist): ONE page, inline in chat
or `specs/<slug>/spec-lite.md` if the user wants it saved:

```
# <feature> — spec-lite
Goal: <one sentence>
Requirements: R1..Rn (short imperatives)
Acceptance: Given/When/Then per requirement (1 minimum)
Out of scope: <explicit non-goals>
Assumptions: <what you decided without asking>
Slices: <1–2 vertical slices with DoD = reviewer APPROVED>
```

**Mode C — craft-only** (fix/refactor/review): no spec artifacts. The "task"
is the diff itself; acceptance = original behavior preserved (tests or
side-by-side check) + all gates green.

## 6. Review verdict protocol (for craft-reviewer)

Output format, always:

```
VERDICT: APPROVED | CHANGES_REQUIRED
BLOCKERS: <n>  MAJORS: <n>  MINORS: <n>

GATES CHECKED (per function):
- file.ts:funcName — lines: X, nesting: Y, complexity: Z, callback-depth: W  [ok|VIOLATION]

FINDINGS:
- [BLOCKER|MAJOR|MINOR] file:line — <smell/gate name> — <concrete fix>

ACCEPTANCE CRITERIA: <met | not met (which ones)>
```

Any BLOCKER ⇒ CHANGES_REQUIRED. APPROVED with open MAJORS requires a written
justification per Major. Every finding cites a section (§1 gate, §2 smell,
§3 SOLID question, §4 pressure rule) — uncited opinions are noise.
