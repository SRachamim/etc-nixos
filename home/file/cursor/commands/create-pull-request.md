# Create Pull Request — Shared Instructions

Common steps for creating an Azure DevOps pull request, optionally linked to a work item.

This file is not a standalone command. It is referenced by the **submit-feature** command (and any future command that needs to open a PR), which supplies the work item ID.

## Inputs (provided by the calling command)

| Input | Description |
|-------|-------------|
| **workItemId** | *(optional)* An Azure DevOps work item ID to link to the PR and use for context. |

## Steps

### 1. Identify the repository and default branch

- List Azure DevOps projects and locate the repository that matches the current git remote (`git remote get-url origin`).
- Determine the PR target branch. Consult the **gitflow-branching** skill: feature branches target `develop`, release and hotfix branches target `main`. Fall back to the repository's **default branch** if the branching model doesn't apply or `develop` does not exist.

### 2. Gather context for the PR

- If a **workItemId** was provided, fetch the work item to get its **title**, **description**, and **acceptance criteria**.
- Run `git log --oneline <default-branch>..HEAD` to collect the commits that will be in the PR.
- Run `git diff <default-branch>...HEAD --stat` to summarize changed files.

### 3. Compose the PR description

Draft a PR description with a short summary of the change (derived from the work item and commits).

Follow the **external-communications** skill for all formatting.

**Present the PR title and description to the user for approval before creating the PR.**

### 4. Create the pull request

- Push the current branch to the remote if it has not been pushed yet (`git push -u origin HEAD`).
- Create the PR targeting the default branch using the approved title and description. If a **workItemId** was provided, pass it via the `workItems` parameter to link it at creation time.
- **Present the PR link to the user.**

### 5. Evolve

Follow the **continuous-improvement** skill.
