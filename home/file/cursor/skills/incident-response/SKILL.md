---
name: incident-response
description: Framework for investigating production incidents. Use whenever the agent analyzes alerts, outages, or performance degradations.
---

# Incident Response

## Investigation Order

Work from symptoms inward:

1. **What is the impact?** -- Which users, services, or regions are affected? What is the severity?
2. **When did it start?** -- Establish the incident time window. Check for correlating events (deployments, config changes, upstream outages).
3. **Where is the failure?** -- Narrow from service to endpoint to code path. Use metrics and logs to isolate the component.
4. **Why is it failing?** -- Root cause analysis. Read error logs, traces, and recent changes to the affected code.

## Data Gathering Checklist

For each incident, collect:

- **Timeline** -- When symptoms first appeared, when alerts fired, when mitigation began.
- **Affected services** -- Which services show errors or degraded performance.
- **Error rates and latency** -- Compare the incident window to a recent baseline.
- **Recent deployments** -- Check for deployments or config changes in the hours preceding the incident.
- **Logs** -- Error-level logs and stack traces from the affected services.
- **Traces** -- Slow or errored spans in the affected request paths.
- **Downstream dependencies** -- Check if the root cause is upstream (database, third-party API, infrastructure).

## Correlation

Always check for **changes in the incident window**:

- Code deployments (commits, PRs merged)
- Configuration changes (feature flags, environment variables)
- Infrastructure changes (scaling events, certificate rotations, DNS updates)
- Upstream incidents (cloud provider status, third-party service outages)

A deployment that coincides with the incident start is the most common root cause.

## Systems Thinking

Apply the **architect-thinking** skill's systems-thinking principles during investigation:

- **"Every system is perfect"** -- the system is behaving exactly as designed. Understand what it was optimised for before proposing changes.
- **Feedback loops** -- identify whether the incident involves a runaway positive feedback loop (e.g., retry storms, cascading failures) or a missing negative feedback loop (e.g., no backpressure, no circuit breaker).
- **Bounded rationality** -- operators and developers acted rationally given the information they had. Look for information gaps (missing dashboards, unclear runbooks) rather than blame.
- **Root causes are systemic** -- the proximate trigger (a bad deploy, a config change) is rarely the only cause. Ask what made the system fragile to that trigger.

## Communication

When sharing findings externally, follow the **external-communications** skill and structure updates as:

- **What we know** -- observed symptoms, confirmed impact, probable cause.
- **What we are doing** -- current mitigation steps, who is investigating.
- **Next update** -- when the team will provide the next status update.

Keep updates factual and concise. Avoid speculation -- state confidence levels explicitly.
