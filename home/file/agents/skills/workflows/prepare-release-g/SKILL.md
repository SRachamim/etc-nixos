---
name: prepare-release-g
description: Collect merged PRs since the last release, classify changes, draft release notes, and optionally update wiki/changelog. Use when preparing a release, writing a changelog, or tagging a new version.
---

# Prepare Release

Collect all changes since the last release boundary, classify them, draft user-facing release notes, and prepare for tagging.

## Input

The user specifies (or the agent infers):
- **Version**: the new version number (or "next patch/minor/major")
- **Boundary**: last tag, last release branch, or a specific commit/date
- **Output**: release notes only, wiki update, or both

## Steps

### 0. Mode gate

Follow the **mode-gate-g** skill -- require Plan mode for the research phase.

### 1. Determine release boundary

Find the last release point:
- Check `git tag --sort=-version:refname` for the latest semver tag
- Or use the branch specified by the user (e.g. `release/1.2.0`)
- Record the boundary commit SHA

### 2. Collect merged PRs

Using ADO MCP tools:
- List PRs merged to the default branch since the boundary commit
- For each PR: title, description, linked work items, author
- Group by work item type (Feature, Bug, Task)

### 3. Classify changes

Categorize each PR into:

| Category | Criteria |
|----------|----------|
| **Features** | Linked to a Feature/User Story work item, or PR title starts with "Add/Implement" |
| **Fixes** | Linked to a Bug work item, or PR title starts with "Fix" |
| **Breaking** | PR description mentions breaking changes, or linked work item has "breaking" tag |
| **Internal** | Infrastructure, CI, refactoring, dependency updates -- no user-facing impact |

### 4. Draft release notes

Produce a structured document:

```
## [version] - YYYY-MM-DD

### Breaking Changes
- Description (PR #N)

### Features
- Description (PR #N, Work Item #M)

### Fixes
- Description (PR #N, Work Item #M)

### Internal
- Description (PR #N)
```

Each description should explain the user-facing value, not repeat the commit message. Follow **delivered-text-g** for tone.

### 5. Present for review

Show the draft to the user. Wait for approval or edits.

### 6. Publish

Based on user preference:
- **Wiki**: Update the ADO wiki release notes page via `search_wiki` / `create_or_update_wiki_page`
- **Changelog file**: Prepend to CHANGELOG.md in the repo
- **Tag**: Create a git tag with the release notes as annotation
- **All of the above**

### 7. Evolve

Follow the **capture-improvement-g** skill.
