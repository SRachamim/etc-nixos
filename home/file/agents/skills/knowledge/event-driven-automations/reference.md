# Event-Driven Automations -- Platform Setup Reference

Detailed setup instructions for each platform. Load this file when configuring automations for a specific platform.

## Cursor Automations

### Access

- Web UI: [cursor.com/automations](https://cursor.com/automations)
- From a session: use the `/automate` skill -- describe the automation in plain language and Cursor configures triggers, instructions, and tools.

### Creating an automation

1. **Choose trigger(s)**: GitHub PR opened, PR pushed, CI completed, Slack message, webhook, cron schedule, Linear issue, PagerDuty incident.
2. **Write the instruction**: reference the portable skill (e.g., "Follow the `/review-pr` skill against this PR's diff. Post findings as PR comments.").
3. **Select tools**: enable MCP servers the automation needs (ADO, Slack, Datadog). Enable "Comment on PR" or "Send to Slack" built-in tools as appropriate.
4. **Select repository**: single repo or multi-repo environment. For GitHub/GitLab triggers, a repo is required.
5. **Select model**: match the tier from the automation catalogue.
6. **Activate**.

### Per-automation trigger config

| Automation | Trigger type | Filter |
|---|---|---|
| PR Review | GitHub: PR opened, PR pushed | Non-draft PRs only |
| Bug Triage | Slack: New message | Specific bug channel |
| CI Failure Diagnosis | GitHub: CI completed | Status = failure |
| Security Audit | GitHub: Push to branch | Branch = `main` or `release/*` |
| Weekly Digest | Scheduled | Cron: `0 7 * * 1` (Monday 07:00) |

### Notes

- Automations can have multiple triggers. PR Review benefits from both "PR opened" and "PR pushed."
- Use the memory tool to let the automation learn from past runs.
- Webhook triggers require a Bearer token in the request header.

---

## Claude Code Routines

### Access

- Web UI: [claude.ai/code/routines](https://claude.ai/code/routines)
- From CLI: `/schedule` creates scheduled routines conversationally.

### Creating a routine

1. **Choose trigger type(s)**: Scheduled (hourly/daily/weekly), API (`/fire` endpoint), or GitHub (PR events, releases).
2. **Write the prompt**: reference the portable skill.
3. **Connect repository**: select the target repo. GitHub triggers require the Claude GitHub App installed on the repo.
4. **Add connectors**: equivalent to MCP -- provides access to external services.
5. **Save and activate**.

### Per-automation trigger config

| Automation | Trigger type | Configuration |
|---|---|---|
| PR Review | GitHub: `pull_request.opened` | Filter to target repo |
| CI Failure Diagnosis | GitHub: `workflow_run.completed` | Filter: conclusion = failure |
| Security Audit | GitHub: `push` | Filter: branch = main |
| Weekly Digest | Scheduled | Weekly, Monday morning |
| Bug Triage | API trigger | Wire Slack webhook to the routine's `/fire` endpoint |

### Limitations (research preview, June 2026)

- GitHub events have hourly and daily rate caps per routine and per account.
- Each matching GitHub event starts a new session (no session reuse across events).
- Slack triggers are not native -- use the API trigger with a Slack webhook relay.
- Single repo only (no multi-repo environments yet).

---

## Antigravity

### Scheduled tasks (cron)

Use `/schedule` in the desktop app or CLI:

```
/schedule "Follow the /review-pr skill against open PRs" --cron "0 9 * * *"
```

Results surface in the Agent Manager when you reopen the app.

### Background Agent (overnight tasks)

For tasks that run while you're away:

1. Open a Background Agent session (separate window).
2. Provide the instruction referencing the skill.
3. Set constraints (e.g., max 3 concurrent sessions, 50-line change limit for refactoring).
4. Close the app -- the agent continues running.

Best suited for: Weekly Digest, Security Audit (on schedule), overnight code review.

### Event-driven via GitHub Actions

For GitHub event triggers (PR opened, CI failed), use `agy` in a GitHub Actions workflow:

```yaml
name: PR Review via Antigravity
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Antigravity review
        env:
          ANTIGRAVITY_TOKEN: ${{ secrets.ANTIGRAVITY_TOKEN }}
        run: |
          npx agy --headless --approve all \
            "Follow the /review-pr skill against this PR's diff. Post findings as PR comments."
```

### SDK (programmatic orchestration)

For complex or custom triggers, use the Antigravity SDK:

```typescript
import { Schedule, Agent } from '@anthropic/antigravity-sdk';

const weeklyDigest = new Schedule({
  cron: '0 7 * * 1',
  agent: new Agent({
    prompt: 'Summarise merged PRs from the past week. Post to Slack.',
    repo: 'org/repo',
  }),
});

weeklyDigest.start();
```

### Per-automation mapping

| Automation | Mechanism |
|---|---|
| PR Review | GitHub Actions + `agy --headless` |
| Bug Triage | Slack webhook → GitHub Actions → `agy` |
| CI Failure Diagnosis | GitHub Actions (on `workflow_run` completed + failure) |
| Security Audit | `/schedule` cron or GitHub Actions on push to main |
| Weekly Digest | `/schedule` cron (Monday 07:00) |

### Notes

- `ANTIGRAVITY_TOKEN` environment variable replaces the old `GEMINI_API_KEY`.
- Use `--approve all` only in trusted/isolated environments.
- Cap concurrent Background Agent sessions to preserve quota for interactive use.
