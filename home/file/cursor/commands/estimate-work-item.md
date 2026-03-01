# Estimate Work Item

Given an Azure DevOps work item ID (or a free-text task description), perform codebase reconnaissance and produce a structured effort estimate in hours with a confidence level.

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

### 2. Estimate

Follow the **estimation** skill, passing the resolved work item details (or free-text description) as input.

### 3. Present the report

Output the estimate in this format:

```
## Estimate: #<ID> — <Title>
(or "## Estimate: <task description>" if no ADO item)

**Type**: <type> | **Hours**: <N> | **Band**: <band> | **Confidence**: <level>

### Summary

<1–3 sentence summary of the task and why the estimate lands where it does>

### Calibration Note

<which size band the estimate falls into, what the empirical data says about that band, and any adjustment applied>

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

### Sprint Fit

<whether the work fits in one 2-week sprint, or how to split it>

### Risks and Open Questions

- <risk or question>
- <risk or question>

### Recommendation

<whether to proceed as-is, split the item, or address prerequisites first>
```

### 4. Offer follow-up

If appropriate, offer to:

- Update the ADO work item with the estimate (`OriginalEstimate` and `EstimationConfidenceLevel`).
- Split the work item into smaller child items if estimated at 31+ hours.
- Run the **plan-feature** command to produce a detailed commit plan.

**Wait for user approval before taking any write action** (per **external-communications** skill).

### 5. Evolve

Follow the **continuous-improvement** skill.
