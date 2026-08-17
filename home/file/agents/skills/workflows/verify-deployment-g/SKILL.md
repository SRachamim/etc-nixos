---
name: verify-deployment-g
description: Verify that a merged change deployed successfully and works in the target environment. Use after a PR merges to confirm deployment health, run smoke checks, and transition the work item to Done.
---

# Verify Deployment

After a PR merges and deploys, verify the change works in the target environment. If healthy, mark the work item as Done. If failing, alert the team and create a hotfix bug.

## Input

The user specifies (or the agent infers):
- **Work item or PR**: the change to verify
- **Environment**: which environment to check (auto-detect from work item's iteration/tags, or user-specified)

## Steps

### 1. Determine deployment target

From the work item or PR:
- Identify the target environment (dev, staging, production)
- Get the expected deployment pipeline using Sunday MCP (`sunday_get_pipeline_status`, `sunday_find_deployments`)
- Confirm the deployment completed (pipeline succeeded, no rollback)

If deployment is still in progress, wait and re-check (up to 3 attempts with 2-minute intervals).

### 2. Check environment health

Using available MCP tools:
- **Sunday**: `sunday_get_environment` for overall environment health
- **Thanos**: `thanos_environment_health` for metrics
- **Coralogix**: `coralogix_search_logs` for error spikes since deployment

Look for:
- HTTP 5xx spike after deployment timestamp
- New error patterns in logs not present before deployment
- Health endpoint failures

### 3. Verify the specific change

Based on the PR's scope:
- If API change: verify the new/modified endpoint responds correctly
- If config change: verify the config is picked up (check logs for config load)
- If bug fix: verify the original bug symptom no longer occurs

### 4. Report result

**If healthy:**
- Transition work item to Done state
- Post a confirmation comment on the work item: "Verified in [env] at [timestamp]"
- Inform the user: "Deployment verified, work item marked Done"

**If unhealthy:**
- DO NOT mark as Done
- Create a hotfix bug via `/create-bug-g` with the failure evidence
- Alert team in Slack (if configured)
- Inform the user with the failure details and recommended action

### 5. Evolve

Follow the **continuous-improvement-g** skill.
