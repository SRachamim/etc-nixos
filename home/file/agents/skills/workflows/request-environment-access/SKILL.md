---
name: request-environment-access
description: Creates a Task work item in Azure DevOps requesting environment access (assigned to TechOps) and posts a support request to the #techops-support Slack channel. Use when you need access to a specific environment and can provide a reason.
disable-model-invocation: true
---

# Request Environment Access

Create a **Task** work item in Azure DevOps requesting access to an environment, assigned to TechOps for fulfilment, then post a structured support request to **#techops-support** (`C07UN1KPDSL`).

## Inputs

| Input | Description |
|-------|-------------|
| **environment** | Free-form environment identifier (e.g. "uat261 org rbc-qa") |
| **reason** | Why the access is needed |

## Steps

### 1. Gather inputs

The user provides an environment name and a reason for needing access. If either is missing or too vague to produce a meaningful work item, ask a clarifying question. Otherwise, proceed -- don't ask the user to fill in structured fields.

### 2. Craft title and description

Apply the **objective-communication** skill.

- **Title**: `Grant <Display Name> access to <environment>` -- where `<Display Name>` is the current user's name resolved by the shared instructions.
- **Description**: a markdown paragraph stating who needs access, to which environment, and why. Keep it short and direct.

### 3. Create the work item

Follow the **create-work-item** shared instructions with:

- **workItemType**: `Task`
- **title**: the crafted title from step 2
- **typeFields**:

| Field | Value |
|-------|-------|
| `System.Description` | The crafted description (markdown) |
| `System.Tags` | `Security; user-access` |
| `Microsoft.VSTS.Scheduling.OriginalEstimate` | `1` |
| `Microsoft.VSTS.Scheduling.RemainingWork` | `1` |

- **commonFieldOverrides**:

| Field | Value |
|-------|-------|
| `System.AssignedTo` | `emmanuel.ikpe@fundguard.com` |
| `System.AreaPath` | `FundGuard\TechOps\Production` |

- **skipTriage**: `true`

### 4. Compose the Slack message

Read and apply the **external-communications** skill.

Compose a message in Slack mrkdwn matching the template used by the "Request TechOps Support" workflow in **#techops-support**:

```
cc: <!subteam^S07RZUUG66A>

*Production / UAT:*
<ENV_TYPE>

*Severity Level:*
Sev 4 - Low (Cosmetic / General question)

*ADO Ticket*:
<ADO_WORK_ITEM_URL>

*Description:*
Task <WORK_ITEM_ID>: <TITLE_FROM_STEP_2>

:point_right: *Emergency Video Sync (Optional: Only for Sev1):*
N/A
```

Field resolution:

- **ENV_TYPE** -- infer from the environment name: if it contains "prod" or "production" (case-insensitive), use "Production"; otherwise default to "UAT".
- **ADO_WORK_ITEM_URL** -- the work item URL returned by step 3 (e.g. `https://dev.azure.com/FundGuard/FundGuard/_workitems/edit/12345`).
- **WORK_ITEM_ID** and **TITLE_FROM_STEP_2** -- the ID and title from the work item created in step 3.

Present the composed message in a fenced code block for user approval before posting.

### 5. Post to #techops-support

Post the approved message to channel `C07UN1KPDSL` using `conversations_add_message`.

Report the permalink back to the user: `https://fundguard.slack.com/archives/C07UN1KPDSL/p<ts_without_dot>`.

### 6. Evolve

Follow the **continuous-improvement** skill.
