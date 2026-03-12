# Request Environment Access

Create a **Task** work item in Azure DevOps requesting access to an environment, assigned to TechOps for fulfilment.

## Inputs

| Input | Description |
|-------|-------------|
| **environment** | Free-form environment identifier (e.g. "uat261 org rbc-qa") |
| **reason** | Why the access is needed |

## Steps

### 1. Gather inputs

The user provides an environment name and a reason for needing access. If either is missing or too vague to produce a meaningful work item, ask a clarifying question. Otherwise, proceed -- don't ask the user to fill in structured fields.

### 2. Craft title and description

Apply the **writing-style** skill (using the "Work-item descriptions and comments" register).

- **Title**: `<Display Name> access to <environment>` -- where `<Display Name>` is the current user's name resolved by the shared instructions.
- **Description**: an HTML paragraph stating who needs access, to which environment, and why. Keep it short and direct.

### 3. Create the work item

Follow the **create-work-item** shared instructions with:

- **workItemType**: `Task`
- **title**: the crafted title from step 2
- **typeFields**:

| Field | Value |
|-------|-------|
| `System.Description` | The crafted description (HTML) |
| `System.Tags` | `Security; user-access` |
| `Microsoft.VSTS.Scheduling.OriginalEstimate` | `1` |
| `Microsoft.VSTS.Scheduling.RemainingWork` | `1` |

- **commonFieldOverrides**:

| Field | Value |
|-------|-------|
| `System.AssignedTo` | `sophia.andrianopoulos@fundguard.com` |
| `System.AreaPath` | `FundGuard\TechOps\Production` |

- **skipTriage**: `true`
