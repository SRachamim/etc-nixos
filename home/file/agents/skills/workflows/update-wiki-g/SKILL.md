---
name: update-wiki-g
description: Detect documentation drift and update ADO wiki pages to reflect current codebase state. Use when documentation is stale, after major refactors, or for periodic wiki maintenance.
---

# Update Wiki

Compare wiki documentation against the current codebase to identify stale sections, then draft and publish updates.

## Input

The user specifies (or the agent infers):
- **Scope**: a specific wiki page path, a topic area, or "all pages related to [component]"
- **Mode**: audit-only (report drift) or update (draft + publish)

## Steps

### 0. Mode gate

Follow the **mode-gate-g** skill -- require Plan mode for the audit phase.

### 1. Fetch current wiki content

Using ADO MCP tools (`search_wiki`, `get_wiki_page`):
- Retrieve the target wiki page(s)
- Parse their structure: headings, code examples, API references, configuration snippets

### 2. Compare against codebase

For each section of the wiki:
- **API references**: grep the codebase for the mentioned endpoints/functions -- do they still exist? Have signatures changed?
- **Configuration examples**: compare wiki snippets against actual config files or schema definitions
- **Architecture descriptions**: check if mentioned files/modules still exist in the described structure
- **Setup instructions**: verify commands and paths still work

### 3. Identify drift

Classify each finding:

| Drift type | Example |
|-----------|---------|
| **Removed** | Wiki documents a feature/API that no longer exists |
| **Changed** | Function signature, config format, or file path changed |
| **Missing** | New feature/API exists in code but not in wiki |
| **Stale example** | Code snippet in wiki doesn't compile/run |

### 4. Present audit results

If mode is audit-only, present findings and stop.

If mode is update, present findings and proposed changes for approval.

### 5. Draft updates

For each approved finding:
- Write the corrected section following existing wiki style and structure
- Preserve any custom annotations or team-specific notes
- Mark sections as "Last verified: [date]" if the wiki uses that convention

Follow **delivered-text-g** for writing quality.

### 6. Publish

Using ADO MCP (`create_or_update_wiki_page`):
- Apply the updates
- Add a comment noting what changed and why

### 7. Evolve

Follow the **capture-improvement-g** skill.
