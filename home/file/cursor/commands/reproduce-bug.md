# Reproduce Bug

Given a bug work item (or a textual description of the defect), gather reproduction context and verify the bug in the running local application via the browser or direct API requests.

## Input

Accept **any** of the following:

1. **Ticket reference** -- an Azure DevOps work item ID (e.g. `12345`) or full URL. Fetch it via MCP and extract repro steps, org, environment, and attachments.
2. **Textual description** -- a plain-language description of the bug and manual reproduction steps. Treat the text as the authoritative specification.

When both a ticket and additional text are provided, the text supplements the ticket -- it does not replace it.

## Steps

### 1. Gather bug context

- **If ticket**: apply the **work-item-context** skill to fetch the work item with full details, relations, comments, and hyperlinks. Additionally, extract file attachments from the relations array -- download screenshots and note video URLs for reference. From the fetched fields, extract:
  - **Repro steps**: from `Microsoft.VSTS.TCM.ReproSteps`, the description, or comments.
  - **Org**: from `Custom.Org` (fall back to `manual` if absent).
  - **Environment**: from `Microsoft.VSTS.CMMI.FoundInEnvironment` (skip environment setup if absent).
- **If text**: restate the defective behaviour in your own words and confirm understanding before proceeding.

### 2. Reproduce via browser

Delegate to the **browser-bug-reproduction** skill, passing it:

- The reproduction steps collected in step 1.
- The org and environment (if any).
- Any reference screenshots or video URLs from the work item.

The skill handles environment configuration (via `/set-igw` if needed), dev server management, login, repro execution, and evidence capture.

### 3. Evolve

Follow the **continuous-improvement** skill.