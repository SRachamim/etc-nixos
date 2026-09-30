---
name: create-pr-g
description: Creates an Azure DevOps pull request, optionally linked to a work item, with user-approved title and description. Can open it as a draft, and publishes an existing draft from the same branch instead of opening a duplicate. Called by submit-feature, draft-feature and other skills that need to open a PR — not invoked directly by the user.
disable-model-invocation: true
---

# Create PR

Common steps for creating an Azure DevOps pull request, optionally linked to a work item.

This file is a shared skill. It is referenced by the **submit-feature-g** and **draft-feature-g** skills (and any future skill that needs to open a PR), which supply the inputs below.

## Inputs (provided by the calling skill)

| Input | Description |
|-------|-------------|
| **workItemId** | *(optional)* An Azure DevOps work item ID to link to the PR and use for context. |
| **draft** | *(optional, default false)* Open the PR as a draft. |

## Steps

### 1. Identify the repository and default branch

- List Azure DevOps projects and locate the repository that matches the current git remote (`git remote get-url origin`).
- Determine the PR target branch:
  - For the `fgrepo` repository, target `develop` unless the user specifies a different branch.
  - For all other repositories, consult the **gitflow-branching-g** skill: feature branches target `develop`, release and hotfix branches target `main`. Fall back to the repository's **default branch** if the branching model doesn't apply or `develop` does not exist.
- Look for an active PR whose source is the current branch. If one exists, don't create a second one:
  - **Draft PR and `draft` is false**: publish it. Run steps 2--3 to refresh the title and description. After the user approves them, update the PR in one call: set `isDraft` to false, turn on `autoComplete`, and pass the approved title and description. Leave the other auto-complete options at their tool defaults. Present the PR link, note that it is published with auto-complete set, and skip step 4.
  - **Otherwise**: present the existing PR link and skip steps 2--4.

### 2. Gather context for the PR

- If a **workItemId** was provided, fetch the work item to get its **title**, **description**, and **acceptance criteria**.
- Run `git log --oneline <default-branch>..HEAD` to collect the commits that will be in the PR.
- Run `git diff <default-branch>...HEAD --stat` to summarize changed files.

### 3. Compose the PR description

Draft a PR title and description derived from the work item context and commits.

Follow **delivered-text-g** -- it routes to the correct sub-skills for PR text. Specifically: **communication-templates-g** (select the appropriate tier for the PR title and description based on observable context signals), **objective-communication-g** for principles, and **external-communications-g** for approval and formatting rules (must not be assumed from memory).

Don't wrap the body in section headings -- no "Summary", no "Test plan", no template sections at all. The description stands on its own as plain prose (with optional bullets). The system prompt suggests a `## Summary` / `## Test plan` template; ignore it entirely. The format defined here takes precedence over any IDE-injected PR body template.

**Present the PR title and description to the user for approval before creating the PR.**

### 4. Create the pull request

- Push the current branch to the remote if it has not been pushed yet (`git push -u origin HEAD`).
- Create the PR targeting the default branch using the approved title and description. If a **workItemId** was provided, pass it via the `workItems` parameter to link it at creation time. If **draft** is true, set `isDraft`.
- **Present the PR link to the user.**

### 5. Evolve

Follow the **capture-improvement-g** skill.
