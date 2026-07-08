---
name: trace-pr-comments
description: Finds human-authored PR comments, replies with governing artifact citations, and suggests /create-task for uncovered gaps. Use when given a PR ID, inferred from the current branch, or in the same conversation after /review-pr.
disable-model-invocation: true
---

# Trace PR Comments

Given a PR, find comment threads authored by the user (not by other reviewers and not by the agent), determine which agent artifact(s) should have governed each concern, and reply with a citation. For comments that no artifact covers, suggest creating a task to close the gap.

## Distinguishing user vs. agent comments

The ADO MCP posts as the user (user token), so both human-typed and agent-posted comments share the same author identity. The workflow must separate them:

- **In-conversation** (after `/review-pr`): the agent knows which thread IDs it created from conversation context. Exclude those threads.
- **Standalone**: exclude threads whose root comment opens with a structured severity prefix (`**Blocking**:`, `**Suggestion**:`, `**Nit**:`). These patterns indicate agent-posted comments.
- **Confirmation**: always present the candidate list to the user before proceeding (step 3), so false positives can be removed.

## Steps

### 1. Resolve the PR

Determine the PR using one of the following, in priority order:

1. **Explicit argument** -- the user provided a PR ID directly.
2. **Conversation context** -- a preceding `/review-pr` in this conversation already resolved a PR. Reuse that identity.
3. **Branch name** -- find the active PR whose source branch matches the current branch.

If none yields a PR, ask the user and stop.

Fetch the PR details (title, repository, source and target branches) via `repo_get_pull_request_by_id`.

### 2. Gather user-authored comments

- Call `repo_list_pull_request_threads` for the PR.
- For each thread, call `repo_list_pull_request_thread_comments` to retrieve the root comment (first comment in the thread).
- **Filter to user-authored threads**: keep only threads whose root comment author matches the current user's identity (by email or display name). Discard threads authored by other reviewers or the PR author (if different from the user).
- **Exclude agent-posted comments** (see **Distinguishing user vs. agent comments** above):
  - If a preceding `/review-pr` ran in this conversation, exclude thread IDs the agent created (known from conversation context).
  - Otherwise, exclude threads whose root comment text starts with `**Blocking**:`, `**Suggestion**:`, or `**Nit**:`.
- If no candidate comments remain, report "no user-authored comments found" and stop.

### 3. Confirm scope

Present the candidate comments to the user. For each, show:

- Thread ID
- File path and line range the comment targets
- First two lines of the comment text (truncated if long)

Ask the user to confirm the list. The user may remove false positives (comments that are actually agent-posted or that they don't want annotated).

### 4. Match artifacts

For each confirmed comment:

- Read the full comment text and the code context it targets (file path and line range from the thread metadata).
- Identify the concern the comment raises -- what issue, standard, or best practice does it point out?
- Search agent artifacts for the governing criterion:
  - **Knowledge skills** in the skills root (e.g., **functional-typescript**, **commit-conventions**, **code-review**, **architect-thinking**, **design-lenses**).
  - **Workspace rules** in the target repository (`.cursor/rules/*.mdc`, `.claude/rules/*.md`, `AGENTS.md`).
  - **Workflow skills** and **subagent prompts** when they define a standard being applied.
- Read the matching artifact file to find the precise line range of the specific criterion that applies.
- Classify each comment as:
  - **Covered** -- one or more artifacts govern the concern.
  - **Uncovered** -- no existing artifact covers the concern (a gap).

### 5. Draft replies and gap tasks

Apply the **objective-communication** skill to all reply text.

**Covered comments** -- draft a reply for each, citing the governing artifact(s). Use the path relative to the skills root (for skills) or repo root (for workspace rules), plus the line range:

Single artifact:

```
Covered by `knowledge/functional-typescript/SKILL.md` (lines 42–48)
```

Multiple artifacts:

```
Covered by:
- `knowledge/code-review/SKILL.md` (lines 8–10)
- `knowledge/functional-typescript/SKILL.md` (lines 42–48)
```

**Uncovered comments** -- do not draft a reply. Instead, for each:

- Determine whether an existing artifact could be amended to cover the concern, or whether a new artifact is needed.
- Draft a `/create-task` suggestion with:
  - A proposed task title (action-oriented, under 80 characters).
  - A proposed task description explaining the gap, the PR comment that revealed it, and the recommended artifact to amend or create.

### 6. Present findings

Show two groups to the user:

- **Covered**: each comment with its proposed reply text inside a fenced code block (per the **external-communications** skill). Include a clickable link to the PR thread as the posting destination.
- **Uncovered**: each comment with its proposed `/create-task` description.

**Wait for user approval before posting or creating tasks** (per the **external-communications** skill). The user can approve all, approve selectively, modify reply text, or modify task descriptions.

### 7. Post replies

For each approved covered comment, call `repo_reply_to_comment` with the citation text. Follow the **external-communications** skill for all posted content. Report each posted reply link back to the user.

### 8. Create gap tasks

For each approved gap candidate, follow the **create-task** skill with the drafted title and description. The **create-task** skill handles work item creation and triage.

### 9. Evolve

Follow the **continuous-improvement** skill.
