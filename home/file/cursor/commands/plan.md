# Plan

Observe the given input and produce a proposed sequence of commits to ship in a single PR. When the codebase needs structural preparation, the plan includes behaviour-preserving refactoring commits before feature commits, ordered so that each commit is independently valid.

Fowler's two-hats rule says to alternate between restructuring and adding behaviour -- never both at once. This command produces a single plan that may contain both kinds of commit, with refactorings preceding the feature work they enable.

## Input

Accept **any** of the following:

1. **Ticket reference** -- an Azure DevOps work item ID (e.g. `12345`) or full URL. Fetch it via MCP and extract title, type, description, acceptance criteria, state, assignee, iteration, children, linked PRs/commits, and comments.
2. **Textual description** -- a plain-language description of the feature, bug, or task (e.g. "separate the pricing logic from the order module so we can reuse it in the subscription flow"). Treat the text as the authoritative specification.
3. **Tech design or plan** -- a document, plan output, or inline specification describing the desired architecture.

When multiple inputs are provided, they supplement each other. When both a ticket and additional text are provided, the text supplements the ticket -- it does not replace it.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. The planning phase (steps 1--7) is read-only analysis and design -- Plan mode keeps the focus on discussion rather than edits. The user will switch back to Agent mode when they approve and want implementation to begin.

### 1. Clarify the goal

- **If ticket**: apply the **work-item-context** skill to gather the full picture -- the work item itself, its relations, linked PRs, hyperlinks, and comments. Use the skill's structured summary as the authoritative context for the rest of the plan.
  - **Successor awareness**: identify successor work items -- items whose Predecessor link points to this item, i.e. work blocked on the current item's completion. For each successor, fetch its description and acceptance criteria (batch-fetch via `wit_get_work_items_batch_by_ids` if not already retrieved). Note what each successor expects the current item to deliver: interfaces, modules, data shapes, or capabilities it will build upon. Treat these expectations as additional constraints on the target state.
- **If text or design**: restate the target state or requirement in your own words and confirm understanding before proceeding.
- Identify what the code should look like after the change -- which modules exist, how responsibilities are distributed, what types and interfaces are in play.
- Identify the **invariants** (what must remain true) and the **degrees of freedom** (what can vary).

### 2. Understand the codebase

Based on the goal, search the codebase for relevant code:

- Locate files, modules, and functions in the affected area.
- Read key files to understand the current implementation.
- Identify the boundaries of the change: which modules, layers, or services are affected.
- Map existing **extension points** -- tagged unions, generic dispatch sites, combinator interfaces, layered data -- that the change should leverage rather than bypass.
- Identify the **gap** between the current structure and the target state.

Spend enough time here to form a concrete mental model. Don't guess -- read the code.

### 3. Apply the design lenses

Apply the **design-lenses** skill using the **planning framing** for all three lenses (refactoring, flexibility, architecture). Not every principle will be relevant to every change.

### 4. Draft the plan

Design a sequence of **steps** to ship the change. Most steps are commits; some may be non-commit actions (e.g. creating a follow-up task for TODO comments, updating a work item state). Every step will become a TODO item during implementation (step 8).

Design commits following the **commit-conventions** skill. Documentation updates must be included in the same commit that introduces the code change making them stale -- never in a separate follow-up commit. For restructuring commits, each commit applies one refactoring and must leave the codebase compiling and tests passing.

Order commits so that earlier refactorings enable later ones. Test-addition commits go first.

For each step, specify:

| Field | Description |
|-------|-------------|
| **#** | Sequence number |
| **Type** | `commit` or `action` |
| **Title** | Commit message following the project's conventions (per workspace rules), or short description (for actions) |
| **What** | Concise description of the change or action |
| **Key Files** | Files expected to be touched (commits only; `--` for actions) |
| **Technique** | Which catalog refactoring technique it applies (`--` for non-refactoring commits and actions) |
| **Flexibility** | Which design-lens principle(s) this step honours and how (optional for actions) |
| **Validation** | How to verify this step is correct (per workspace rules and project tooling) |

### 5. Validate against successors

When successor work items were identified in step 1, verify that the planned design accommodates their needs:

- For each successor, check that the plan's target state provides the interfaces, modules, data shapes, or capabilities the successor expects.
- If the plan introduces an abstraction or API boundary, confirm the successor's requirements can be met through that boundary without requiring further restructuring.
- If a gap is found, either adjust the plan to close it (e.g. widen an interface, add an extension point) or note it explicitly in the plan's Notes section as a known limitation.

Skip this step when no successor work items exist or when the input was not a ticket.

### 6. Present the plan

Apply the **writing-style** skill to all plan text -- summaries, design-lens commentary, notes, and any prose in the table cells.

Output the plan in this format:

```
## Plan: <Title>

**Source**: <ticket link, design reference, or "textual description"> | **Type**: <type> | **State**: <state or "n/a">

### Summary

<1–3 sentence summary of what needs to happen and why>

### Target State

<Include when restructuring is involved. Description of the desired structure after the restructuring commits are applied.>

### Design Lens

<Which 2–3 principles matter most for this change and why>

### Implementation Steps

| # | Type | Title | What | Key Files | Technique | Flexibility | Validation |
|---|------|-------|------|-----------|-----------|-------------|------------|
| 1 | commit | `test: add missing tests for pricing module` | ... | `tests/...` | (prerequisite) | -- | ... |
| 2 | commit | `refactor: extract pricing into dedicated module` | ... | `src/...` | Extract Module | Additive -- new module | ... |
| 3 | commit | `feat: add subscription pricing support` | ... | `src/...` | -- | Postel's law -- wider input | ... |
| 4 | action | Create task for TODO comments | ... | -- | -- | -- | Task exists in ADO |

### Notes

<Any risks, open questions, or alternatives worth mentioning>
```

### 7. Iterate

Wait for approval, modifications, or questions before implementing.

### 8. Implement the plan

Once the user approves, implement the plan **in the exact sequence presented**. Build the TODO list and execute each item following the **plan-execution** skill.

### 9. Evolve

Follow the **continuous-improvement** skill.
