---
name: incident-response
description: Framework for investigating production incidents. Use whenever the agent analyzes alerts, outages, or performance degradations.
---

# Incident Response

## Investigation Order

Work from symptoms inward:

1. **What is the impact?** — Which users, services, or regions are affected? What is the severity?
2. **When did it start?** — Establish the incident time window. Check for correlating events (deployments, config changes, upstream outages).
3. **Where is the failure?** — Narrow from service to endpoint to code path. Use metrics and logs to isolate the component.
4. **Why is it failing?** — Root cause analysis. Read error logs, traces, and recent changes to the affected code.

## Data Gathering Checklist

For each incident, collect:

- **Timeline** — When symptoms first appeared, when alerts fired, when mitigation began.
- **Affected services** — Which services show errors or degraded performance.
- **Error rates and latency** — Compare the incident window to a recent baseline.
- **Recent deployments** — Check for deployments or config changes in the hours preceding the incident.
- **Logs** — Error-level logs and stack traces from the affected services.
- **Traces** — Slow or errored spans in the affected request paths.
- **Downstream dependencies** — Check if the root cause is upstream (database, third-party API, infrastructure).

## Correlation

Always check for **changes in the incident window**:

- Code deployments (commits, PRs merged)
- Configuration changes (feature flags, environment variables)
- Infrastructure changes (scaling events, certificate rotations, DNS updates)
- Upstream incidents (cloud provider status, third-party service outages)

A deployment that coincides with the incident start is the most common root cause.

## Communication

When sharing findings externally, follow the **message-formatting** skill and structure updates as:

- **What we know** — observed symptoms, confirmed impact, probable cause.
- **What we are doing** — current mitigation steps, who is investigating.
- **Next update** — when the team will provide the next status update.

Keep updates factual and concise. Avoid speculation — state confidence levels explicitly.
