---
name: azure-devops-formatting
description: Formatting guidelines for Azure DevOps interactions. Use whenever the agent creates or updates PR descriptions, work item comments, or any Azure DevOps content.
---

# Azure DevOps Formatting

When interacting with Azure DevOps, use proper formatting:

## Code & Technical Terms

- Use backticks for: branch names, file paths, function names, variable names, CLI commands
- Example: "Merge `feature/auth` into `master` after fixing `AuthService.ts`"

## Always Link Resources

Link PRs, pipelines, and work items when mentioning them:

- PRs: "[PR #12345](https://dev.azure.com/org/project/_git/repo/pullrequest/12345)"
- Pipelines: "[Pipeline 927888](https://dev.azure.com/org/project/_build/results?buildId=927888)"
- Work items: "[Bug #5678](https://dev.azure.com/org/project/_workitems/edit/5678)"
- Files: "[`src/api/client.ts`](https://dev.azure.com/org/project/_git/repo?path=/src/api/client.ts&version=GBfeature/auth)" (use the relevant branch, or the project's default branch if not branch-specific)

## Links

Link nouns, not verbs. Avoid calls to action.

- Bad: "The build failed. [View Pipeline](link)"
- Good: "[Pipeline 927888](link) failed."

- Bad: "I created a work item. [Click here](link)"
- Good: "[Bug #5678](link) tracks this issue."
