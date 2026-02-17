# Investigate Incident

Given a Datadog incident ID (or a description of symptoms), gather observability data and produce an investigation summary.

## Steps

### 1. Resolve the incident

Determine the incident using one of the following, in priority order:

1. **Explicit argument** — the user provided an incident ID directly.
2. **Description** — the user described symptoms. List recent incidents and find the best match, or proceed without an incident ID using the symptoms as search context.

If neither yields a starting point, ask the user and stop.

### 2. Fetch incident details

- Fetch the incident from Datadog (title, status, severity, timeline, commander, created/modified timestamps).
- Note the incident time window for subsequent queries.

### 3. Query related monitors

- List monitors in alert or warning state.
- Filter for monitors related to the incident (by tags, service name, or the user's guidance).
- Note which monitors triggered and when.

### 4. Pull logs

- Search logs within the incident time window, filtered by relevant service or tags.
- Look for error-level logs, stack traces, and anomalous patterns.
- Pull a representative sample (not the entire volume).

### 5. Query metrics

- Query key metrics around the incident window: error rates, latency percentiles, throughput, saturation.
- Compare the incident window to a baseline period (e.g., the preceding hour or day) to identify deviations.

### 6. Fetch traces (if relevant)

- If the incident involves latency or errors in a specific service, fetch APM traces from the incident window.
- Look for slow spans, error spans, or upstream/downstream failures.

### 7. Summarize findings

Follow the **incident-response** skill for investigation structure.

Present a structured summary:

```
## Incident: <title>

**Severity**: <level> | **Status**: <status> | **Started**: <time>

### Timeline

<chronological list of key events: alert fired, symptoms observed, actions taken>

### Affected Services

<list of services and how they were impacted>

### Root Cause (probable)

<concise explanation of what went wrong and why>

### Evidence

- **Monitors**: <which monitors triggered>
- **Logs**: <key log excerpts>
- **Metrics**: <notable metric deviations>
- **Traces**: <relevant trace observations, if any>

### Suggested Actions

- <immediate action>
- <follow-up action>
```

### 8. Offer follow-up

If appropriate, offer to:

- Post the summary to a Slack channel (per **require-message-approval** and **message-formatting** skills).
- Create a work item to track the fix.
- Schedule a Datadog downtime if the alert is expected during remediation.

Wait for user confirmation before taking any action.
