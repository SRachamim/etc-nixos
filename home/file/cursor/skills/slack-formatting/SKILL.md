---
name: slack-formatting
description: Formatting guidelines for composing Slack messages. Use whenever the agent composes, drafts, or posts a Slack message.
---

# Slack Message Formatting

When composing Slack messages, use proper formatting:

## Code & Technical Terms

- Use backticks for: code snippets, function names, variable names, file paths, CLI commands, class names, package names
- Example: "The `fetchData` function in `src/api/client.ts` returns a `Promise`"

## Formatting Syntax

- `*bold*` for emphasis or important terms
- `_italic_` for subtle emphasis
- `` `code` `` for inline code
- `~strikethrough~` for corrections
- `>` for quotes

## Links

Link nouns, not verbs. Avoid calls to action.

- Bad: "Pipeline 927888 is running. [View Pipeline](link)"
- Good: "[Pipeline 927888](link) is running."

- Bad: "I opened a PR. [Click here to review](link)"
- Good: "[PR #123](link) is ready for review."

## Azure DevOps Resources

Always link to Azure DevOps resources when mentioning them:

- PRs: "[PR #12345](https://dev.azure.com/org/project/_git/repo/pullrequest/12345)"
- Pipelines: "[Pipeline 927888](https://dev.azure.com/org/project/_build/results?buildId=927888)"
- Work items: "[Bug #5678](https://dev.azure.com/org/project/_workitems/edit/5678)"
- Files: "[`src/api/client.ts`](https://dev.azure.com/org/project/_git/repo?path=/src/api/client.ts&version=GBfeature/auth)" (use the relevant branch, or the project's default branch if not branch-specific)

## Best Practices

- Keep messages concise and scannable
- Use bullet points for lists
- Mention users with `@name` only when their attention is needed
