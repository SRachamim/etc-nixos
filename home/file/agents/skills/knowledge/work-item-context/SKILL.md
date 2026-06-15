---
name: work-item-context
description: Deeply gather context from an Azure DevOps work item by following its relations, linked PRs, hyperlinks, and comments. Use whenever a command needs the full picture behind a work item -- planning features, reviewing PRs, triaging, or estimating.
---

# Work Item Context

Given a work item ID, build a rich understanding of the item by fetching the item itself and following its linked artefacts. Return a structured summary that the calling command can use as authoritative context.

## Steps

### 1. Fetch the root work item

Call `wit_get_work_item` with `expand: "relations"` to retrieve fields, relations, and linked resources in a single call.

Extract the core fields: title, type, state, description, acceptance criteria, repro steps (if present), assigned-to, iteration, and area path.

### 2. Follow work-item relations

Extract IDs from the relations array, grouped by link type:

- **Parent**
- **Child**
- **Related**
- **Predecessor / Successor**

Batch-fetch all linked work items via `wit_get_work_items_batch_by_ids`. For each, note its ID, title, type, and state.

Limit traversal to **one hop** -- do not recurse into the linked items' own relations.

### 3. Follow linked pull requests

Extract pull-request links from the relations array (`vstfs:///Git/PullRequestId/...`). Fetch each via `repo_get_pull_request_by_id` and note the PR ID, title, status, source branch, and target branch.

### 4. Follow hyperlinks

Scan the description, acceptance criteria, and repro-steps fields for URLs. Categorise and fetch:

| URL pattern | Action |
|---|---|
| ADO wiki link | Fetch via `wiki_get_page_content` |
| Other HTTP(S) URL | Fetch via `WebFetch` (best-effort; skip on failure) |

Skip URLs that clearly point to images, videos, or binary assets.

### 5. Read comments

Call `wit_list_work_item_comments` and incorporate any decisions, clarifications, or additional context.

### 6. Summarise

Produce a structured summary for the calling command:

```
## Work Item Context: #<ID> -- <Title>

**Type**: <type> | **State**: <state> | **Iteration**: <iteration>

### Goal
<Restated goal from description and acceptance criteria>

### Acceptance Criteria
<Bullet list, verbatim or lightly reformatted>

### Key Decisions (from comments)
<Bullet list of decisions, clarifications, or scope changes>

### Related Work Items
| ID | Title | Type | State | Relation |
|----|-------|------|-------|----------|

### Linked PRs
| ID | Title | Status | Branch |
|----|-------|--------|--------|

### Supplementary Material
<Summaries of fetched hyperlinks and wiki pages>
```

Omit any section that has no content rather than showing an empty table.
