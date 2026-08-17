---
name: sweep-backlog-g
description: Batch-process stale or unrefined backlog items -- classify, estimate, close duplicates, and route actionable work. Use when the user wants to clean up the backlog, triage a batch of items, or groom before sprint planning.
---

# Sweep Backlog

Process a batch of backlog items that need attention: stale items, items missing fields, duplicates, or unestimated work. Produces a summary with proposed actions and applies them after human approval.

## Input

The user specifies (or the agent infers):
- **Query criteria**: e.g. "stale >30 days", "unassigned bugs", "missing effort", "my team's backlog"
- **Actions allowed**: classify, estimate, close-stale, mark-duplicate, route, or all
- **Batch size**: max items to process (default: 20)

## Steps

### 0. Mode gate

Follow the **mode-gate-g** skill -- require Plan mode for the classification phase.

### 1. Query backlog

Use ADO MCP tools (`search_workitems` or `batch_search_workitems`) to retrieve items matching the criteria. Collect:
- Work item ID, title, type, state, assigned to
- Last updated date
- Tags, area path, iteration

Cap at the specified batch size.

### 2. Classify each item

For each item, read its description and comments, then classify:

| Classification | Criteria | Proposed action |
|---------------|----------|-----------------|
| **Actionable** | Clear requirements, reproducible (if bug) | Estimate + route |
| **Needs refinement** | Vague description, missing acceptance criteria | Comment asking for clarification |
| **Duplicate** | Substantially same as another open item | Link as duplicate, propose close |
| **Stale** | No activity >60 days, no linked PRs, not blocked | Propose close with reason |
| **Blocked** | Depends on unresolved predecessor | Mark blocked via `/block-work-item-g` |

For Actionable items, run a lightweight estimation (codebase grep for affected areas, compare to similar completed items).

### 3. Present sweep summary

Format as a table:

```
Sweep results (N items processed):
- Actionable: X (estimated, ready to plan)
- Needs refinement: X (comments drafted)
- Duplicate: X (proposed close)
- Stale: X (proposed close)
- Blocked: X (predecessors identified)

Proposed state changes require your approval.
```

### 4. Human gate

Present each proposed state change grouped by action type. Wait for user to approve, modify, or skip each group.

### 5. Apply approved actions

For each approved action:
- **Close stale/duplicate**: Update state, add closing comment with reason
- **Estimate**: Set effort field on the work item
- **Route**: Assign to appropriate team member based on area path
- **Comment**: Post the refinement request
- **Block**: Invoke `/block-work-item-g` internally

### 6. Summary

Print final counts: items processed, actions taken, items skipped.

### 7. Evolve

Follow the **capture-improvement-g** skill.
