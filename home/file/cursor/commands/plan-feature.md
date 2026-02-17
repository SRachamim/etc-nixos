# Plan Feature

Observe the given Azure DevOps work item and produce a proposed list of commits to ship in a single PR.

## Steps

### 1. Fetch the work item

Retrieve the work item with full details and relations.

Extract and note:
- **Title** and **Type** (Bug, Task, User Story, etc.)
- **Description** and **Acceptance Criteria**
- **State**, **Assigned To**, **Iteration Path**
- **Child work items** (if any — fetch them in batch)
- **Linked PRs or commits** (for context on prior work)
- **Comments** (if any)

### 2. Understand the codebase context

Based on the work item description, search the codebase for relevant code:

- Locate files, modules, and functions related to the work item.
- Read key files to understand the current implementation.
- Identify the boundaries of the change: which modules, layers, or services are affected.

Spend enough time here to form a concrete mental model. Don't guess — read the code.

### 3. Draft the commit plan

Design a sequence of commits following the **commit-conventions** skill.

For each proposed commit, specify:

| Field | Description |
|-------|-------------|
| **#** | Sequence number |
| **Title** | Commit message following the project's conventions (per workspace rules) |
| **What** | Concise description of the change |
| **Files** | Key files expected to be touched |
| **Validation** | How to verify this commit is valid (per workspace rules and project tooling) |

### 4. Present the plan

Output the plan in this format:

```
## Work Item: #<ID> — <Title>

**Type**: <type> | **State**: <state>

### Summary

<1–3 sentence summary of what needs to happen and why>

### Proposed Commits

| # | Title | What | Key Files | Validation |
|---|-------|------|-----------|------------|
| 1 | `<message>` | ... | `src/...` | ... |
| 2 | `<message>` | ... | `tests/...` | ... |

### Notes

<Any risks, open questions, or alternatives worth mentioning>
```

### 5. Iterate

Wait for approval, modifications, or questions before implementing.

### 6. Verify all changes are committed

Follow the hygiene section of the **commit-conventions** skill. The working tree must be clean before considering the plan complete.
