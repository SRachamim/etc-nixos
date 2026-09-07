---
name: create-bug-g
description: Creates a new Bug work item in Azure DevOps with title, repro steps, and severity, assigned to the current user. Use when reporting a bug from a free-form description of broken behavior.
disable-model-invocation: true
---

# Create Bug

Create a new **Bug** work item in Azure DevOps, assigned to the current user on the next iteration.

## Steps

### 1. Understand the issue

The user provides a free-form description of a bug they encountered. If the description is too vague to understand what is broken (e.g. just "it doesn't work"), ask a clarifying question. Otherwise, proceed -- do not ask the user to fill in structured fields.

### 2. Select tier and craft content

Follow the **work-item-templates-g** Bug templates for tier selection and field structure.

**Tier selection** (based on observable signals from the user's input):

- **Simple** -- clear reproduction, single symptom, no investigation done. The user described a straightforward bug with enough detail to reproduce.
- **Standard** -- reproduction requires multiple steps, involves specific environment conditions, or the user provided frequency/evidence data. Default when severity is 2-High or above.
- **Investigated** -- root cause is known or strongly suspected. The user (or earlier analysis) identified the code location and proposed a fix.

From the user's input, produce:

- **Title** -- a concise summary of the observable symptom. Follow the pattern `<Observable symptom> <where it occurs> <when/trigger>` (e.g. "Portfolio API returns 500 when account ID contains special characters"). Keep it under 80 characters.
- **Repro steps** (`Microsoft.VSTS.TCM.ReproSteps`) -- structured per the tier template in **work-item-templates-g**:

  - **Environment** (Standard/Investigated tiers): OS, browser, build version, network conditions. Omit for Simple tier unless the user mentioned them.
  - **Steps to reproduce**: numbered list from a known starting state. Omit if the user didn't describe a specific flow.
  - **Expected behavior**: what should happen. **Always include** -- infer from context if the user didn't state it explicitly.
  - **Actual behavior**: what happens instead. **Always include** -- infer from context if the user didn't state it explicitly.
  - **Frequency** (Standard/Investigated): Always / Sometimes / Once / Unable to determine.
  - **Evidence** (Standard/Investigated): console errors, network logs, screenshots, correlation IDs. Omit if unavailable.

  All repro information lives exclusively in `Microsoft.VSTS.TCM.ReproSteps` -- don't duplicate it into `System.Description` or any other field.

- **Description** (`System.Description`) -- **only for Investigated tier**:
  - **Root cause**: what is going wrong in the code and why, grounded in observable evidence.
  - **Proposed fix**: what to change and why this approach.
  - **Affected areas**: what else might break or need updating.

  Do NOT use `System.Description` for Simple or Standard tiers.

- **Severity** -- infer from the user's description:
  - `1 - Critical` -- data loss, security breach, or complete service outage.
  - `2 - High` -- major feature broken with no workaround.
  - `3 - Medium` -- feature broken but workaround exists, or non-critical degradation.
  - `4 - Low` -- cosmetic issue or minor inconvenience.

  Default to `3 - Medium` when severity is unclear.

- **Found in build** (`Microsoft.VSTS.Build.FoundIn`) -- extract from the user's input if they mention a build number or version. Omit if not mentioned.

### 3. Create the work item

Follow the **create-work-item-g** shared instructions with:

- **workItemType**: `Bug`
- **title**: the crafted title from step 2
- **typeFields**:

| Field | Value | Condition |
|-------|-------|-----------|
| `Microsoft.VSTS.TCM.ReproSteps` | The crafted repro steps (markdown) | Always |
| `Microsoft.VSTS.Common.Severity` | The inferred severity | Always |
| `System.Description` | Root cause, proposed fix, affected areas | Investigated tier only |
| `Microsoft.VSTS.Build.FoundIn` | Build/version where observed | When mentioned by user |

- **commonFieldOverrides**:

| Field | Value |
|-------|-------|
| `System.AreaPath` | `FundGuard\Platform\Web\CInfra` |

### 4. Triage the work item

If the work item is not assigned to the current user, skip this step — triaging is the assignee's responsibility.

Otherwise, follow the **triage-transition-g** skill, passing the newly created work item's ID.
