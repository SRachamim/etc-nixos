---
name: conversation-naming
description: Convention for naming agent conversations with a branch prefix for traceability. Use whenever the agent names or renames a chat thread.
---

# Conversation Naming

Prefix conversation titles with the current git branch name so threads are traceable to the work they belong to.

## Format

```
<branch>: <title>
```

Example: `feature/123: Implement auth middleware`

The title portion should be concise (3--6 words) and describe the work being done in the conversation.

## Skip conditions

Omit the branch prefix when any of the following is true:

- The current branch is a default branch (`main`, `master`, `develop`).
- HEAD is detached (no branch name available).
- The workspace is not a git repository.

## Determining the branch

Use `git branch --show-current`. It returns an empty string on detached HEAD, which triggers the skip condition above.

## Idempotency

If the conversation title is already prefixed with the current branch, do not double-prefix. When the branch changes (e.g. after a checkout), update the prefix to reflect the new branch.

## Agent compatibility

This skill describes a naming convention. Agents apply it using whatever rename mechanism is available to them. Agents without a conversation-rename capability gracefully skip this convention -- no error or fallback is needed.
