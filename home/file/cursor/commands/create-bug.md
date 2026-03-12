# Create Bug

Create a new **Bug** work item in Azure DevOps, assigned to the current user on the current iteration.

## Steps

### 1. Understand the issue

The user provides a free-form description of a bug they encountered. If the description is too vague to understand what is broken (e.g. just "it doesn't work"), ask a clarifying question. Otherwise, proceed -- do not ask the user to fill in structured fields.

### 2. Craft the title and repro steps

From the user's input, produce:

- **Title** -- a concise summary that identifies the broken behavior. Follow the pattern `<Component/Area>: <what is wrong>` (e.g. "Portfolio API: returns 500 when account ID contains special characters"). Keep it under 80 characters.
- **Repro steps** -- structured HTML with these sections:

  - **Steps to reproduce**: numbered list of actions to trigger the bug. Omit if the user didn't describe a specific flow.
  - **Expected behavior**: what should happen.
  - **Actual behavior**: what happens instead.
  - **Additional context**: environment details, error messages, screenshots, or links the user mentioned.

  Omit sections the user's input doesn't cover -- don't invent details.

- **Severity** -- infer from the user's description:
  - `1 - Critical` -- data loss, security breach, or complete service outage.
  - `2 - High` -- major feature broken with no workaround.
  - `3 - Medium` -- feature broken but workaround exists, or non-critical degradation.
  - `4 - Low` -- cosmetic issue or minor inconvenience.

  Default to `3 - Medium` when severity is unclear.

### 3. Create the work item

Follow the **create-work-item** shared instructions with:

- **workItemType**: `Bug`
- **title**: the crafted title from step 2
- **typeFields**:

| Field | Value | Condition |
|-------|-------|-----------|
| `Microsoft.VSTS.TCM.ReproSteps` | The crafted repro steps (HTML format) | Always |
| `Microsoft.VSTS.Common.Severity` | The inferred severity | Always |

### 4. Triage the work item

Follow the **work-item-triage** skill, passing the newly created work item's ID.
