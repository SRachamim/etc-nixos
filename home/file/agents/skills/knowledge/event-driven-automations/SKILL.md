---
name: event-driven-automations
description: Catalogue of recommended event-driven automations with portable skill references and platform compatibility guidance. Use when setting up background automations on any platform (Cursor, Claude Code, Antigravity) or when deciding which automations to activate for a project.
---

# Event-Driven Automations

Background automations run without human initiation -- triggered by events (PR opened, Slack message, CI failure) or schedules (cron). The automation logic lives in portable skills; the trigger mechanism is platform-specific and cheap to recreate.

## Setup principles

- **Instructions reference skills, not inline logic.** The automation instruction is: "Follow the `/review-pr` skill against this diff." When the skill evolves, all automations benefit automatically.
- **One automation per concern.** Don't combine unrelated triggers into a single automation.
- **Tier matches model routing.** Select the model tier from `AGENTS.md` Model Routing that matches the automation's cognitive demand.
- **Fail silently, report loudly.** Automations that can't complete should post a summary of what blocked them rather than retrying indefinitely.

## Automation catalogue

| Automation | Trigger | Skill reference | Tier | Output |
|---|---|---|---|---|
| PR Review | PR opened or pushed | `/review-pr` | Standard | PR comments with structured findings |
| Bug Triage | Slack message in bug channel | `/triage` | Standard | ADO work item + Slack thread reply |
| CI Failure Diagnosis | CI check failed on PR | `/triage-build` | Standard | PR comment with root cause and suggested fix |
| Security Audit | Push to main or release branch | **code-review** (security focus) | Frontier | Slack post with high-risk findings |
| Weekly Digest | Cron (weekly, Monday morning) | Custom prompt | Volume | Slack summary of merged PRs, new tech debt, dependency updates |

### Instruction templates

Each automation's instruction follows this pattern:

> You are an automated agent. Follow the `<skill>` skill. Your input is: `<event payload description>`. Post results to: `<output channel>`. If you cannot complete the task, post a brief explanation of what blocked you.

Adapt per automation:

- **PR Review**: "Follow the `/review-pr` skill. The diff is the PR that triggered this automation. Post findings as PR comments."
- **Bug Triage**: "Follow the `/triage` skill. The work item to create comes from the Slack message content. Reply in the Slack thread with a summary."
- **CI Failure Diagnosis**: "Follow the `/triage-build` skill. The failing CI check is on the triggering PR. Post root cause as a PR comment."
- **Security Audit**: "Follow the **code-review** skill with a security focus. Review the diff pushed to main. Post high-risk findings to the designated Slack channel."
- **Weekly Digest**: "Summarise merged PRs from the past week, noting new tech debt and dependency changes. Post to the team Slack channel."

## Platform compatibility

| Capability | Cursor | Claude Code | Antigravity |
|---|---|---|---|
| GitHub/GitLab triggers | Native | Native (GitHub only) | Via GitHub Actions calling `agy` |
| Slack triggers | Native | Not yet | Via webhook or GitHub Actions |
| Scheduled (cron) | Native | Native | Native (`/schedule`) |
| Webhook/API triggers | Native | Native (`/fire` endpoint) | SDK TriggerRunner |
| MCP access | Yes | Yes (connectors) | Via `AGENTS.md` + tools |
| Multi-repo | Yes | Single repo | Single repo |

### Platform selection guidance

- **Richest integration set**: Cursor Automations (GitHub, GitLab, Slack, Linear, PagerDuty, Sentry, webhooks, cron).
- **GitHub-centric workflows**: Claude Code Routines or Cursor -- both have native GitHub triggers.
- **Scheduled/overnight tasks**: All three support cron. Pick whichever platform you use most for that project.
- **Non-GitHub event sources** (Slack, PagerDuty, Linear): Cursor Automations is currently the only platform with native support for these. For others, wire via webhook.

## When to activate automations

Activate automations incrementally, not all at once:

1. **Start with PR Review** -- highest immediate value, lowest risk. Validates the automation pipeline.
2. **Add CI Failure Diagnosis** -- reduces incident response time on failed checks.
3. **Add Security Audit** -- catches vulnerabilities before they reach production.
4. **Add scheduled tasks** (Weekly Digest) -- low urgency, confirm cron reliability.
5. **Add Slack-triggered tasks** (Bug Triage) -- requires Slack integration setup; do last.

## Platform-specific setup

Load the **reference.md** companion file for detailed platform-specific instructions on configuring each automation in Cursor, Claude Code, and Antigravity.
