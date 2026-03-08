# Plan Refactoring

Observe the given input and produce a proposed sequence of behavior-preserving refactoring commits that reshape the code toward the described target state.

This is the "first hat" from Fowler's two-hats rule: refactor the code to make the next change easy, then add the new behavior (via **plan-feature**). Use this command when the codebase needs structural preparation before a feature can be cleanly implemented.

## Input

Accept **any** of the following:

1. **Ticket reference** -- an Azure DevOps work item ID (e.g. `12345`) or full URL. Fetch it via MCP and extract title, type, description, acceptance criteria, state, assignee, iteration, children, linked PRs/commits, and comments.
2. **Textual description** -- a plain-language description of the target state or structural goal (e.g. "separate the pricing logic from the order module so we can reuse it in the subscription flow").
3. **Tech design or plan** -- a document, plan output, or inline specification describing the desired architecture.

When multiple inputs are provided, they supplement each other.

## Stop conditions

Pause and ask the user before continuing if any of these arise:

- The target state cannot be restated as a single clear sentence.
- The blast radius exceeds the complexity budget (see step 2) and the user hasn't confirmed full scope.
- A new codepath has no identifiable testable property (likely a design flaw -- see **test-strategy** skill).
- The scope audit (step 6) flags more than half the planned work as deferrable.

## Steps

### 0. Enter Plan mode

Switch to Cursor **Plan mode** (`SwitchMode` with `target_mode_id: "plan"`). The planning phase (steps 1--8) is read-only analysis and design -- Plan mode keeps the focus on discussion rather than edits. The user will switch back to Agent mode when they approve and want implementation to begin.

### 1. Clarify the target state

- **If ticket**: fetch the work item with full details and relations. Extract child work items (batch), linked PRs/commits, and comments.
- **If text or design**: restate the target structural state in your own words and confirm understanding before proceeding.
- Identify what the code should look like **after** the refactoring -- which modules exist, how responsibilities are distributed, what types and interfaces are in play.
- Identify the **invariants** (what behavior must remain unchanged) and the **degrees of freedom** (how the structure can vary).

### 2. Understand the current codebase

Based on the target state, search the codebase for the code that needs restructuring:

- Locate files, modules, and functions in the affected area.
- Read key files to understand the current implementation.
- Identify the boundaries of the change: which modules, layers, or services are affected.
- Map existing **extension points** -- tagged unions, generic dispatch sites, combinator interfaces, layered data -- that the refactoring should leverage rather than bypass.
- Identify the **gap** between the current structure and the target state.

Spend enough time here to form a concrete mental model. Don't guess -- read the code.

#### Complexity budget

After exploration, assess the blast radius. If the refactoring will touch more than **8 files** or introduce more than **2 new modules**, present a scoped-down alternative alongside the full scope and ask the user to confirm before proceeding.

#### Parallel exploration (optional)

For complex refactorings, consider spawning sub-agents in parallel to accelerate exploration. Available sub-agent prompts live in `home/file/cursor/subagents/`:

- **architecture-explorer** -- maps data flow, dependency graphs, side-effect boundaries, and failure modes.
- **scope-auditor** -- challenges the plan for unnecessary work (can also run after step 5).

Pass each sub-agent the confirmed target state and the existing-code inventory from this step. Synthesise their outputs into the subsequent steps. This is optional -- for small refactorings, sequential single-agent planning is fine.

### 3. Apply the refactoring lens

Before drafting commits, evaluate the structural transformation through the **refactoring** skill's core principles:

| Principle | Question to ask |
|---|---|
| **Preserve behavior** | Does every step keep the code doing exactly what it does today? |
| **Small steps** | Is each transformation a single, testable change? |
| **Two hats** | Are we purely restructuring -- no new behavior mixed in? |
| **Tests first** | Do adequate tests exist to catch regressions? If not, add them first. |

Also apply the flexibility design lens from **plan-feature** -- evaluate which of these principles matter most for the target state:

| Principle | Question to ask | FP / TypeScript idiom |
|---|---|---|
| **Additive programming** | Can this change be a pure addition -- no modification to existing code? | New module, new union variant, new handler |
| **Combinators** | Do the new parts share a uniform interface so they compose freely with existing parts? | `pipe`, `flow`, same `(input) => Output` shape |
| **Generic dispatch** | Should this extend an existing discriminated union + `fold` rather than add conditionals? | Widen union, add match arm |
| **Layering** | Can metadata travel alongside data without the core knowing? | Branded types, `Reader`, layered records |
| **Postel's law** | Does each function accept the widest reasonable input and produce the narrowest output? | Validate with `io-ts` at the boundary; return precise types |

Not every principle applies to every change. Call out the 2–3 that matter most and explain how the plan honors them.

### 4. Select refactoring techniques

For each structural change needed to close the gap, select techniques from the **refactoring** skill catalog:

- Reference each technique by its catalog name (e.g. Extract Module, Move Function, Introduce Branded Type).
- Apply the **functional-typescript** skill to ensure the target structure aligns with fp-ts standards and architectural principles.

### 5. Draft the commit plan

Design a sequence of commits following the **commit-conventions** skill. Each commit applies one refactoring and must leave the codebase compiling and tests passing.

For each proposed commit, specify:

| Field | Description |
|-------|-------------|
| **#** | Sequence number |
| **Title** | Commit message following the project's conventions (per workspace rules) |
| **What** | Concise description of the transformation |
| **Key Files** | Files expected to be touched |
| **Technique** | Which catalog refactoring technique it applies |
| **Flexibility** | Which design-lens principle(s) this commit honors and how |
| **Validation** | How to verify this commit is correct (per workspace rules and project tooling) |

Order commits so that earlier refactorings enable later ones. Test-addition commits go first.

### 6. Audit scope

Review the drafted plan for unnecessary work. For each new abstraction, module, or function the plan introduces, ask: "what breaks if we skip this?" Cross-check against the existing-code inventory from step 2 -- flag anything being rebuilt that already exists or could be extended with less effort.

If a **scope-auditor** sub-agent was spawned in step 2, incorporate its output here. Otherwise, perform the audit inline.

This step feeds the NOT-in-scope and Deferred-work sections of the plan output.

### 7. Present the plan

Apply the **writing-style** skill to all plan text -- summaries, design-lens commentary, notes, and any prose in the table cells.

Output the plan in this format:

```
## Refactoring: <Title>

**Source**: <ticket link, design reference, or "textual description"> | **Type**: <type> | **State**: <state or "n/a">

### Summary

<1–3 sentence summary of the current state, the target state, and what the refactoring achieves>

### Target State

<Description of the desired structure after all refactoring commits are applied>

### Design Lens

<Which 2–3 flexibility and refactoring principles matter most for this change and why>

### Proposed Commits

| # | Title | What | Key Files | Technique | Flexibility | Validation |
|---|-------|------|-----------|-----------|-------------|------------|
| 1 | `test: add missing tests for pricing module` | ... | `tests/...` | (prerequisite) | -- | ... |
| 2 | `refactor: extract pricing into dedicated module` | ... | `src/...` | Extract Module | Additive -- new module | ... |

### Data Flow

(Mermaid diagram showing the structural transformation -- before and after.
Skip with "N/A -- change is localised" when the refactoring doesn't alter data flow.)

### Test Strategy

(Apply the **test-strategy** skill. Map refactored codepaths to properties, flag gaps, justify any example tests.
Skip with "N/A" for trivial refactorings with adequate existing coverage.)

### Failure Modes

(For each new integration point or side-effect boundary:

| Codepath | Failure scenario | Test covers it? | Error handling? | User sees? |
|----------|-----------------|----------------|----------------|------------|

Skip with "N/A" when the refactoring introduces no new side-effect boundaries.)

### NOT in Scope

(Items considered and explicitly deferred, each with a one-line rationale. From step 6.
Skip with "N/A" when scope is self-evident.)

### Deferred Work

(Valuable items that don't belong in this change but are worth tracking.
Each item: What / Why / Context / Depends on.
Skip with "N/A" when nothing worth deferring was identified.)

### Notes

<Any risks, open questions, or alternatives worth mentioning>
```

### 8. Iterate

Wait for approval, modifications, or questions before implementing.

### 9. Verify all changes are committed

Follow the hygiene section of the **commit-conventions** skill. The working tree must be clean before considering the plan complete.

### 10. Evolve

Follow the **continuous-improvement** skill.
