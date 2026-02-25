---
name: external-communications
description: Formatting and approval guidelines for external messages. Use whenever the agent composes or posts content to messaging platforms, pull request descriptions, work item comments, or other external communications.
---

# External Communications

## Approval

**NEVER** post any textual content to external systems without explicit user approval.

This applies to ALL external communications, including but not limited to:

- Messages to team channels or direct messages (e.g., Slack)
- Pull request comments and descriptions (e.g., Azure DevOps, GitHub)
- Work item or issue updates and comments
- Discussion threads in any project management or collaboration tool

Before posting:

1. **Present the candidate text** — Show the complete message you intend to post, formatted as it will appear
2. **Wait for approval** — Do not proceed until the user explicitly approves
3. **Accept modifications** — If the user suggests changes, present the revised version and wait for approval again

## Formatting

### Code & Technical Terms

- Use backticks for: branch names, file paths, function names, variable names, CLI commands, class names, package names
- Example: "Merge `feature/auth` into `master` after fixing `AuthService.ts`"

### Links

Link nouns, not verbs. Avoid calls to action.

- Bad: "The build failed. [View Pipeline](link)"
- Good: "[Pipeline 927888](link) failed."

- Bad: "I created a work item. [Click here](link)"
- Good: "[Bug #5678](link) tracks this issue."

### Always Link Resources

When mentioning PRs, builds, work items, or files, always link them. Examples using Azure DevOps:

- PRs: "[PR #12345](https://dev.azure.com/org/project/_git/repo/pullrequest/12345)"
- Pipelines: "[Pipeline 927888](https://dev.azure.com/org/project/_build/results?buildId=927888)"
- Work items: "[Bug #5678](https://dev.azure.com/org/project/_workitems/edit/5678)"
- Files: "[`src/api/client.ts`](https://dev.azure.com/org/project/_git/repo?path=/src/api/client.ts&version=GBfeature/auth)" (use the relevant branch, or the project's default branch if not branch-specific)

### Slack

When composing Slack messages, use mrkdwn syntax:

- `*bold*` for emphasis or important terms
- `_italic_` for subtle emphasis
- `` `code` `` for inline code
- `~strikethrough~` for corrections
- `>` for quotes

Best practices:

- Keep messages concise and scannable
- Use bullet points for lists
- Mention users with `@name` only when their attention is needed
