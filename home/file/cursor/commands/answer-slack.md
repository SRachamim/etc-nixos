# Answer Slack

Given a Slack message link, fetch the conversation context, analyse the topic, research using relevant Cursor artifacts and MCP tools, and present findings to the user. The user digests the information and decides whether to ask for a Slack reply draft.

## Input

A Slack message permalink in the form:

```
https://<workspace>.slack.com/archives/<channel_id>/p<ts_without_dot>
```

## Steps

### 0. Recommended mode: Ask

Require **Ask** mode following the **mode-gate** skill. This command is primarily informational -- it researches a Slack conversation and presents findings without making changes. If the user later wants to post a Slack reply (step 7), they should switch to Agent mode for that.

### 1. Parse the Slack link

Extract `channel_id` and reconstruct `thread_ts` from the URL:

- `channel_id` is the path segment after `/archives/`.
- `thread_ts` is derived from the `p`-prefixed timestamp by inserting a dot before the last 6 digits (e.g. `p1234567890123456` becomes `1234567890.123456`).

If the link is malformed or missing, ask the user and stop.

### 2. Fetch message context

- Call `slack_get_thread_replies` with the extracted `channel_id` and `thread_ts` to retrieve the full thread.
- If the message has no thread replies, fall back to `slack_get_channel_history` scoped around the timestamp to capture surrounding messages.
- Resolve participant names by calling `slack_get_user_profile` for each unique user ID that appears in the messages.

### 3. Follow embedded links

Scan the messages for links to external resources and fetch each one to build a complete picture:

| Link type | How to resolve |
|-----------|----------------|
| Slack message permalink (`/archives/<channel>/p<ts>`) | Parse the link (same logic as step 1) and call `slack_get_thread_replies` to pull that thread |
| Azure DevOps work item (`_workitems/edit/<id>`) | Extract the ID and fetch via `wit_get_work_item` |
| Azure DevOps pull request (`_git/<repo>/pullrequest/<id>`) | Extract the ID and fetch via `git_get_pull_request` |
| Azure DevOps build / pipeline (`_build/results?buildId=<id>`) | Extract the ID and fetch via `build_get_build` |
| Datadog incident or monitor URL | Extract the ID and fetch via the Datadog MCP tools |
| GitHub PR or issue | Extract the owner/repo/number and fetch via `gh` CLI or GitHub MCP |
| Generic URL | Fetch with `WebFetch` if the content is likely to add useful context |

Stop recursing when a linked resource doesn't itself contain further actionable links, or when the same resource has already been fetched.

### 4. Analyse the conversation

Read the thread and determine:

- **What is being asked or discussed** -- the core question, request, or topic.
- **Who is asking** -- the person(s) expecting a response.
- **Domain** -- which area the message touches (code, incident, build failure, process, tooling, general discussion, etc.).
- **Urgency** -- whether the tone or context suggests time pressure.
- **Whether a response is expected from the user** -- some threads are informational; not all require a reply.

### 5. Select and apply relevant artifacts

Based on the domain identified in step 4, use the appropriate Cursor artifacts and MCP tools to research. Explain which artifacts were selected and why.

| Domain | Artifacts / tools to consider |
|--------|-------------------------------|
| Code questions | Search the codebase; apply the **functional-typescript** skill for TypeScript questions |
| Incidents | Follow the **incident-response** skill's investigation structure; query Datadog via MCP |
| Build failures | Follow the **triage-build** command's investigation pattern; query Azure DevOps and Currents via MCP |
| Work items | Fetch details from Azure DevOps via MCP |
| Process / tooling | Search existing commands and skills for relevant guidance |
| General | Research using available MCP tools and codebase search |

When a topic spans multiple domains, investigate each relevant angle.

### 6. Present findings

Present a structured summary **to the user** (not as a Slack message draft):

```
## Slack Thread: <channel name> -- <brief topic>

**From**: <who asked> | **Domain**: <domain> | **Response expected**: yes / no

### Context

<concise summary of the conversation so far>

### Research

<findings from step 5 -- evidence, code references, data points>

### Suggested Answer Direction

<bullet points outlining what a good reply would cover, without composing the reply itself>
```

### 7. Offer to draft a reply

After presenting findings, offer to compose a Slack reply. If the user accepts:

1. Draft the reply following the **external-communications** and **writing-style** skills.
2. Present the draft for approval.
3. Post via `slack_reply_to_thread` only after explicit approval.

Wait for user confirmation before taking any action.

### 8. Evolve

Follow the **continuous-improvement** skill.
