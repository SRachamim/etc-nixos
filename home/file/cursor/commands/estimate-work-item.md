# Estimate Work Item

Given an Azure DevOps work item ID (or a free-text task description), perform codebase reconnaissance and produce a structured effort estimate with T-shirt sizing and Fibonacci story points.

## Steps

### 1. Resolve the work item

Determine the work item using one of the following, in priority order:

1. **Explicit ADO ID** — the user provided a work item ID directly. Fetch it with full details and relations.
2. **Free-text description** — the user described a task. Use `search_workitem` to find a matching ADO item. If a match is found, fetch it. If not, proceed using the description alone.

When fetching from ADO, extract and note:

- **Title** and **Type** (Bug, Task, User Story, etc.)
- **Description** and **Acceptance Criteria**
- **State**, **Assigned To**, **Iteration Path**
- **Child work items** (if any — fetch them in batch)
- **Parent work item** (for broader context)
- **Linked PRs or commits** (for context on prior work)

If neither input path yields a starting point, ask the user and stop.

### 2. Codebase reconnaissance

Search the codebase to build a concrete understanding of the affected areas. Do not guess — read the code.

- Semantic-search using keywords from the work item description to locate relevant files, modules, and services.
- Read key files to understand current implementation patterns and architecture.
- Map the data flow through the affected components.
- Identify cross-module dependencies and downstream consumers of any code that would change.
- Check existing test coverage in the affected areas (test files, test helpers, coverage gaps).
- Note whether the change implies schema migrations, API surface changes, or new third-party dependencies.

Spend enough time here to form an accurate mental model of the blast radius.

### 3. Complexity analysis

Evaluate the work item across these dimensions:

| Dimension | What to assess |
|-----------|---------------|
| **File-touch overhead** | How many files and modules need modification. |
| **Coupling** | How many downstream consumers or cross-module boundaries are affected. |
| **Test burden** | Volume of new tests needed; existing coverage gaps that must be filled first. |
| **Schema / API changes** | Database migrations, contract changes, or breaking API modifications. |
| **Technical debt** | Complexity of target files, code smells, monolithic modules in the blast radius. |
| **Unknowns / risks** | Ambiguous requirements, undocumented behavior, external dependencies, security concerns. |

For each dimension, assign a severity: **low**, **moderate**, or **high**.

### 4. Generate the estimate

Using the complexity analysis, assign both a T-shirt size and Fibonacci story points:

| T-Shirt | Points | Indicators |
|---------|--------|------------|
| **XS** | 1–2 | Isolated single-file change. High existing test coverage. No schema changes. Established pattern exists to follow. |
| **S** | 3 | Confined to a single component or module. Minimal new tests. No downstream consumer updates or API changes. |
| **M** | 5 | Multi-file modification within a single bounded context. Moderate file-touch overhead. Requires integration test updates. |
| **L** | 8–13 | Cross-module architectural changes. High coupling. Requires schema migrations or security audits. |
| **XL** | 21+ | Spans multiple repositories or services. High regression risk. Ambiguous requirements needing significant R&D. Recommend splitting into smaller items. |

Justify the estimate by referencing specific findings from the complexity analysis — not intuition.

### 5. Present the report

Output the estimate in this format:

```
## Estimate: #<ID> — <Title>
(or "## Estimate: <task description>" if no ADO item)

**Type**: <type> | **T-Shirt**: <size> | **Story Points**: <points>

### Summary

<1–3 sentence summary of the task and why the estimate lands where it does>

### Affected Areas

| Area | Files / Modules | Impact |
|------|----------------|--------|
| <area> | `src/...` | <what changes> |

### Complexity Breakdown

| Dimension | Severity | Notes |
|-----------|----------|-------|
| File-touch overhead | <low/moderate/high> | <detail> |
| Coupling | <low/moderate/high> | <detail> |
| Test burden | <low/moderate/high> | <detail> |
| Schema / API changes | <low/moderate/high> | <detail> |
| Technical debt | <low/moderate/high> | <detail> |
| Unknowns / risks | <low/moderate/high> | <detail> |

### Risks and Open Questions

- <risk or question>
- <risk or question>

### Recommendation

<whether to proceed as-is, split the item, or address prerequisites first>
```

### 6. Offer follow-up

If appropriate, offer to:

- Update the ADO work item with the estimate (story points and/or T-shirt size).
- Split the work item into smaller child items if sized XL.
- Run the **plan-feature** command to produce a detailed commit plan.

**Wait for user approval before taking any write action** (per **external-communications** skill).
