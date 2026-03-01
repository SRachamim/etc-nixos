# Plan Feature

Observe the given input and produce a proposed list of commits to ship in a single PR.

## Input

Accept **either** of the following:

1. **Ticket reference** — an Azure DevOps work item ID (e.g. `12345`) or full URL. Fetch it via MCP and extract title, type, description, acceptance criteria, state, assignee, iteration, children, linked PRs/commits, and comments.
2. **Textual description** — a plain-language description of the feature, bug, or task. Treat the text as the authoritative specification.

When both a ticket and additional text are provided, the text supplements the ticket — it does not replace it.

## Steps

### 1. Clarify the requirement

- **If ticket**: fetch the work item with full details and relations. Extract child work items (batch), linked PRs/commits, and comments.
- **If text**: restate the requirement in your own words and confirm understanding before proceeding.
- In both cases, identify the **invariants** (what must remain true) and the **degrees of freedom** (what can vary).

### 2. Understand the codebase context

Based on the requirement, search the codebase for relevant code:

- Locate files, modules, and functions related to the change.
- Read key files to understand the current implementation.
- Identify the boundaries of the change: which modules, layers, or services are affected.
- Map existing **extension points** — tagged unions, generic dispatch sites, combinator interfaces, layered data — that the change should leverage rather than bypass.

Spend enough time here to form a concrete mental model. Don't guess — read the code.

### 3. Apply the flexibility design lens

Before drafting commits, evaluate every architectural choice through these principles (adapted from Hanson & Sussman, *Software Design for Flexibility*):

| Principle | Question to ask | FP / TypeScript idiom |
|---|---|---|
| **Additive programming** | Can this change be a pure addition — no modification to existing code? | New module, new union variant, new handler |
| **Combinators** | Do the new parts share a uniform interface so they compose freely with existing parts? | `pipe`, `flow`, same `(input) => Output` shape |
| **Generic dispatch** | Should this extend an existing discriminated union + `fold` rather than add conditionals? | Widen union, add match arm |
| **Domain-specific language** | Does this domain deserve its own set of primitives, combinators, and abstractions? | Builder functions, interpreter pattern |
| **Layering** | Can metadata (provenance, units, audit) travel alongside data without the core knowing? | Branded types, `Reader`, layered records |
| **Degeneracy** | Are there independent paths to the same result that improve robustness or testability? | Multiple codec/strategy implementations |
| **Postel's law** | Does each function accept the widest reasonable input and produce the narrowest output? | Validate with `io-ts` at the boundary; return precise types |
| **Exploratory behavior** | Is generate-and-test more appropriate than imperative control flow? | Lazy `Task` pipelines, `Array.filter` chains |
| **Propagation** | Can partial information from independent sources be merged for a better result? | `TaskEither` composition, `Semigroup` merge |
| **Minimal assumptions** | What assumptions are we baking in? Can we parameterize instead? | Generic type params, function arguments over hard-coded values |

Not every principle applies to every change. Call out the 2–3 that matter most and explain how the plan honors them.

### 4. Draft the commit plan

Design a sequence of commits following the **commit-conventions** skill.

Documentation updates must be included in the same commit that introduces the code change making them stale — never in a separate follow-up commit.

For each proposed commit, specify:

| Field | Description |
|-------|-------------|
| **#** | Sequence number |
| **Title** | Commit message following the project's conventions (per workspace rules) |
| **What** | Concise description of the change |
| **Files** | Key files expected to be touched |
| **Flexibility** | Which design-lens principle(s) this commit honors and how |
| **Validation** | How to verify this commit is valid (per workspace rules and project tooling) |

### 5. Present the plan

Output the plan in this format:

```
## Feature: <Title>

**Source**: <ticket link or "textual description"> | **Type**: <type> | **State**: <state or "n/a">

### Summary

<1–3 sentence summary of what needs to happen and why>

### Design Lens

<Which 2–3 flexibility principles matter most for this change and why>

### Proposed Commits

| # | Title | What | Key Files | Flexibility | Validation |
|---|-------|------|-----------|-------------|------------|
| 1 | `<message>` | ... | `src/...` | Additive — new variant | ... |
| 2 | `<message>` | ... | `tests/...` | Postel's law — wider input | ... |

### Notes

<Any risks, open questions, or alternatives worth mentioning>
```

### 6. Iterate

Wait for approval, modifications, or questions before implementing.

### 7. Verify all changes are committed

Follow the hygiene section of the **commit-conventions** skill. The working tree must be clean before considering the plan complete.

### 8. Evolve

Follow the **continuous-improvement** skill.
