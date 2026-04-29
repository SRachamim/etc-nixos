# Set IGW

Given a ticket ID or URL, resolve the environment and organisation from the Azure DevOps work item, look up the full environment name on Sunday, construct the Internal Gateway URL, and set `INTERNAL_GATEWAY` in the `@fg/gql-api` `.env` file.

## Input

Accept **any** of the following:

1. **Ticket ID** -- a numeric Azure DevOps work item ID (e.g. `108750`).
2. **Ticket URL** -- a full ADO URL (e.g. `https://dev.azure.com/FundGuard/.../_workitems/edit/108750`). Extract the numeric ID from the URL.

## Steps

### 1. Fetch the work item

Call `wit_get_work_item` with `project: "FundGuard"` and `fields`:

- `System.Title`
- `Microsoft.VSTS.CMMI.FoundInEnvironment`
- `Custom.Org`
- `Custom.EnvType`
- `Custom.Customer`

Extract:

| Field | Purpose |
|-------|---------|
| `Microsoft.VSTS.CMMI.FoundInEnvironment` | Short environment name (e.g. `UAT261`) |
| `Custom.Org` | Organisation (e.g. `RBC-UAT`) |

If `FoundInEnvironment` is missing or empty, ask the user which environment to target. If `Custom.Org` is missing, note it but continue -- it is informational, not required for the IGW URL.

### 2. Resolve the full environment name from Sunday

Navigate to `https://sunday.fundguard.io/fundguard/environments` in the browser. Wait for the page to load (environment cards should be visible), then use `browser_search` to find the `FoundInEnvironment` value (case-insensitive).

Read the matching environment card heading to extract the full environment name. Environment names follow the pattern `<short-name>-<region>-<date>` (e.g. `uat261-ca-central-1-2026-01-06`).

If multiple environments match the prefix (the same short name may appear in different regions or categories), present all matches and ask the user to pick one.

### 3. Construct the IGW URL

Strip the trailing date suffix (matching `-\d{4}-\d{2}-\d{2}$`) from the full environment name to get the base name. Construct the IGW URL:

```
http://internal-gateway-<base-name>.fundguard.io
```

Example: `uat261-ca-central-1-2026-01-06` → base name `uat261-ca-central-1` → `http://internal-gateway-uat261-ca-central-1.fundguard.io`.

### 4. Set INTERNAL_GATEWAY

Locate the `.env` file at `packages/apps/gql-api/.env` relative to the workspace root (the workspace is expected to be the `client` directory of an fgrepo worktree). If the file already contains an `INTERNAL_GATEWAY=` line, replace the value. Otherwise, append the line.

Set:

```
INTERNAL_GATEWAY=<constructed IGW URL>
```

### 5. Confirm

Display to the user:

```
## IGW Updated

| Field | Value |
|-------|-------|
| **Ticket** | #<id> -- <title> |
| **Environment** | <full Sunday environment name> |
| **Org** | <Custom.Org value or "not set"> |
| **IGW URL** | <constructed URL> |
| **File** | <absolute path to .env> |
```

### 6. Evolve

Follow the **continuous-improvement** skill.
