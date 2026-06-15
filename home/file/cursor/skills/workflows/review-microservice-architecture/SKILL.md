---
name: review-microservice-architecture
description: Holistic audit of an existing microservice system against Newman's principles. Plan mode workflow covering boundaries, communication, workflows, deployability, observability, resiliency, security, scaling, and organizational alignment. Delivers prioritized findings and remediation recommendations.
disable-model-invocation: true
---

# Review Microservice Architecture

Holistic audit of an existing microservice system against Sam Newman's principles. This command produces a structured audit report with prioritized findings and remediation recommendations. It does **not** implement fixes — that is a separate step.

## Input

Accept **any** of the following:

1. **System scope** — entire system or a specific subsystem to review. The user may name services, repos, or a business domain area.
2. **Architecture artifacts** — diagrams, ADRs, runbooks, service catalogues, or documentation links.
3. **Codebase access** — repository paths for services to inspect. Read code, configs, CI pipelines, and infrastructure when available.
4. **Observability access** — Datadog, logs, metrics dashboards (via MCP when configured).
5. **Ticket or incident context** — a work item or recent incident that triggered the review.

When artifacts are missing, note gaps as findings rather than guessing. Ask the user for access or documentation when needed.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. Steps 1–13 are read-only analysis — Plan mode keeps the focus on assessment rather than premature fixes.

### 1. Scope the review

Define what is being reviewed and gather baseline information.

**What to do:**

- Confirm scope: entire system or specific subsystem? Which services are in scope?
- Build a **service inventory**:
  - Service name, repository, owner/team.
  - Owned aggregates or business capabilities.
  - Data stores (databases, caches, queues).
  - External dependencies (third-party APIs, shared infrastructure).
- Map **communication paths**: which services call which, sync vs async, through what technology.
- Gather existing **architecture diagrams** if available (C4, deployment topology, data flow). Note if diagrams are missing or stale — that is itself a finding.
- Identify **entry points** (API gateways, BFFs, event sources) and **exit points** (external integrations, reporting DBs).
- Note review **trigger**: proactive health check, post-incident, pre-scaling, organisational change, or compliance audit.

**Deliverable:** Scope document — service inventory, communication map, data store map, diagram status, review trigger.

### 2. Assess boundaries

Evaluate whether each service models a proper bounded context with clear ownership.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Modeling Boundaries**.
- For **each service** in scope:
  - Does it model a **bounded context** with a clear ubiquitous language?
  - Does it **own its aggregates**? One aggregate → one owning service.
  - Run the **boundary quality checklist**:
    1. Can I change and deploy this service independently?
    2. Is related business behaviour co-located (strong cohesion)?
    3. Are cross-boundary assumptions minimised (loose coupling)?
    4. Is internal state hidden (information hiding)?
    5. Does one service own each aggregate's lifecycle/state machine?
- At **every boundary**, classify coupling type:
  - **Domain** — unavoidable; check downstream fan-out count.
  - **Temporal** — both must be up; flag for async decoupling.
  - **Pass-through** — data forwarded for a third consumer; flag for remediation.
  - **Common** — shared DB/filesystem/memory; flag shared mutable state.
  - **Content** — external service modifies another's DB; **critical finding**.
- Flag **shared databases** — any mutable data accessed by more than one service.
- Identify **CRUD wrapper services** with behaviour leaked to consumers.
- Check for **premature fine-grained decomposition** — services with no clear domain identity.

**Decision criteria:**

- Independent deployability is the north star — any boundary that undermines it is a finding.
- Content coupling is never acceptable.
- Common coupling (shared mutable DB) destroys independent deployability.

**Deliverable:** Boundary assessment — per-service checklist results, coupling map with types, shared database inventory, aggregate ownership matrix.

### 3. Assess communication

Evaluate whether inter-service communication follows style-before-technology discipline.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Communication Design**.
- Map **all inter-service interactions**:
  - Source → target, sync/async, technology, schema (explicit or implicit).
- For each interaction, verify:
  - Was **communication style chosen before technology**? (Flag Kafka-for-request-response, gRPC where REST suffices, etc.)
  - Is the **schema explicit**? (OpenAPI, protobuf, AsyncAPI — or ad hoc JSON?)
  - Is **schema evolution** managed? (Versioning, expand-and-contract, deprecation policy?)
- Identify **long synchronous call chains** (3+ services in series). Trace user-facing request paths end-to-end.
- Check **event usage**: are events used where broadcasting facts would decouple consumers? Are event payloads fully detailed or ID-only (causing callback storms)?
- Flag **shared domain libraries** across services — coordinated redeploy on every change.
- Check infrastructure:
  - API gateway scope (north-south only? business logic leaked in?)
  - Service mesh necessity (~5+ services? generic cross-cutting only?)
  - Smart middleware anti-pattern (business logic in gateways, ESBs, meshes).

**Decision criteria:**

- Chatty synchronous chains (3+ services) → cascade failure and latency multiplication.
- Shared domain object libraries → coordinated redeploy destroys independent deployability.
- DRY across service boundaries is an anti-pattern.

**Deliverable:** Communication assessment — interaction map, sync chain analysis, schema audit, shared library inventory, infrastructure scope review.

### 4. Assess workflows

Evaluate whether cross-service business processes are modeled explicitly.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Workflow and Sagas**.
- Identify **cross-service business processes** (order fulfilment, onboarding, billing, etc.).
- For each process:
  - Is it modeled **explicitly** (saga with defined steps) or **implicit** (hidden across services with no coordination)?
  - Saga style: orchestration or choreography? Is the choice appropriate for team ownership?
  - Are **compensating transactions** defined for every committable step?
  - Are **correlation IDs** present on every saga event?
  - Is there a **projection service** tracking saga state (for choreographed sagas)?
- Check for **2PC/XA** anywhere in the system — critical finding.
- Check for **mega-orchestrator** absorbing domain logic from multiple services.
- Separate **business failures** (saga compensations) from **technical failures** (circuit breakers, retries).

**Decision criteria:**

- Never 2PC across microservices.
- Implicit business processes hidden across services → untraceable failures.
- Choreography without correlation IDs → impossible to track or compensate.

**Deliverable:** Workflow assessment — process catalogue, saga modeling status, 2PC scan, compensating transaction coverage, correlation ID audit.

### 5. Assess independent deployability

Verify that services can deploy independently in practice, not just in theory.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Build and Deployment**.
- For each service, verify in practice:
  - **Separate CI/CD pipeline**? Or shared build for multiple services?
  - **Separate repo**? Or monorepo with coupled builds?
  - **Can deploy without deploying other services**? Check recent deployment history if available.
  - **Lockstep releases**? Do services share release trains or metaversioning?
  - **Feature flags and progressive delivery**? Can changes be released dark?
- Assess **CI maturity** (Jez Humble gate):
  1. Check in to mainline at least once per day?
  2. Tests validate behaviour (not just compile)?
  3. Broken build is #1 priority?
- Check for **distributed monolith** signals: must deploy together, shared versioning, coordinated releases.
- Check **build practices**: artifact built once and deployed everywhere? Or rebuilt per environment?

**Decision criteria:**

- Multirepo default: one repo = one microservice = one build.
- Lockstep releases and metaversioning are anti-patterns.
- CI tool without CI practices is an anti-pattern.

**Deliverable:** Deployability assessment — per-service CI/CD status, repo layout, release coupling analysis, CI maturity score, distributed monolith risk.

### 6. Assess observability

Evaluate whether the system can be understood and debugged in production.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Observability**.
- Check **prerequisites**:
  - **Log aggregation** in place? Can you search logs across all services from one place?
  - **Correlation IDs** propagated through all calls? Generated at entry points? Fixed position in log lines?
- Check **metrics**:
  - Standard metric names across services?
  - Tagged with service, instance, host?
  - Baselines established over weeks/months?
- Check **distributed tracing**: OpenTelemetry or equivalent? Dynamic sampling (all errors, sparse successes)?
- Check **SLOs and error budgets**:
  - Defined per service or team?
  - Error budget gates risky changes?
  - Shift from binary up/down to nuanced health?
- Check **alerting quality** (EEMUA criteria): Relevant, Unique, Timely, Prioritised, Understandable, Diagnostic, Advisory, Focusing.
  - Alert on SLO violations or every metric threshold (alert fatigue)?
- Check **semantic monitoring**: synthetic transactions for critical business flows?

**Decision criteria:**

- SSH/grep across hosts → critical ops gap.
- No correlation IDs → critical debugging gap.
- Alerting on every threshold → alert fatigue, missed real incidents.
- Inconsistent metric names → impossible to compare services.

**Deliverable:** Observability assessment — log aggregation status, correlation ID coverage, metrics/tracing maturity, SLO inventory, alerting quality review, semantic monitoring status.

### 7. Assess resiliency

Evaluate whether the system handles failure gracefully.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Resiliency**.
- For **every synchronous downstream call** across all services, verify:
  - **Timeouts** configured? Based on healthy p99 and user-facing SLA budget?
  - **Circuit breakers** in place? Fail fast when downstream unhealthy?
  - **Separate connection pools** per downstream (bulkhead)?
  - **Operation-level timeout budget** passed to downstream calls?
- Check **conditional patterns**:
  - Retries with backoff — only for transient failures? Factored into total timeout budget?
  - **Idempotency keys** on mutations — mandatory before retries enabled?
- Check **degradation behaviour**: for each user-facing flow, for each dependency, is the business-acceptable fallback defined? Or do failures cascade to total outage?
- Check **CAP trade-offs** per capability: AP vs CP decisions documented?
- Assess **resilience culture**: blameless post-mortems? Game Days? Or blame culture and surprise outages?

**Decision criteria:**

- Shared connection pool for all downstreams → one slow service exhausts all workers.
- Long timeouts on user-facing paths → cascade latency.
- Retries without idempotency → duplicate effects.
- No degradation matrix → business-unacceptable outage patterns.

**Deliverable:** Resiliency assessment — timeout/circuit breaker/bulkhead coverage matrix, idempotency audit, degradation matrix status, CAP documentation, culture assessment.

### 8. Assess security

Evaluate the system's security posture holistically.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Security**.
- Check **threat modeling**: holistic threat model done (not per-service in isolation)? External parties included?
- Check **trust model**: zero-trust spectrum applied? PII/secret data gets mutual auth and encryption?
- Check **authentication**: OpenID Connect? Per-request JWTs? Downstream validation?
- Check **authorisation**: coarse at gateway, fine-grained in owning service? Or centralized upstream auth breaking independent deployability?
- Check **secrets management**: Vault/cloud secrets manager? Keys in Git (critical finding)? Rotation automated?
- Check **data classification**: PII identified and protected? Data frugality applied (minimum collection/storage)?
- Check **encryption**: TLS everywhere (internal too)? Encryption at rest? mTLS for service-to-service?
- Check **CI security scanning**: dependency scanning, secret scanning, DAST?
- Check **backups**: separate account/region from production? Restoration tested?

**Decision criteria:**

- JWT/mTLS focus while ignoring basics (secrets in Git, no threat model) → misplaced effort.
- Shared broad-privilege credentials → blast radius finding.
- Centralized authorization breaking independent deployability → architectural finding.

**Deliverable:** Security assessment — threat model status, trust model, auth/authz review, secrets management audit, data classification, CI scanning coverage, encryption status.

### 9. Assess scaling posture

Evaluate whether services scale appropriately without premature optimisation.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Scaling**.
- For each service, identify current **scaling axis**:
  1. Vertical (bigger machine)?
  2. Horizontal duplication (load balancers, read replicas)?
  3. Data partitioning (sharding)?
  4. Functional decomposition (already a separate service)?
- Check **caching strategy**:
  - How many cache layers? Compounded staleness risk?
  - TTL-based or `Expires: Never` (problematic)?
  - Caches added with measured bottleneck or speculatively?
- Check **autoscaling**:
  - Failure-based (min N instances) or load-based?
  - Scale-down policy cautious enough?
- Identify **known bottlenecks**: CPU, memory, DB connections, queue depth, network.
- Check whether scaling decisions are **measured** or speculative.

**Decision criteria:**

- Measure before optimising — premature optimisation is the root of all evil.
- Functional decomposition as first scaling move → may indicate wrong service boundaries.
- Nested caches without understanding compounded staleness → data consistency risk.

**Deliverable:** Scaling assessment — per-service scaling axis, caching inventory, autoscaling configuration, bottleneck list, measurement maturity.

### 10. Assess organizational alignment

Evaluate whether team structure supports the architecture.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Organisation and Architecture**.
- Check **Conway's law alignment**: do team boundaries match service boundaries? Or do services span multiple teams (coordination tax)?
- Check **ownership model**:
  - Strong ownership: one team owns one service (code, standards, tech, deployment)?
  - Or shared ownership with no clear accountable team?
- Check **team types**:
  - Stream-aligned teams (5–10 people, end-to-end ownership)?
  - Enabling teams (support, don't silo)?
  - Platform team with paved road (adopted by choice, not mandate)?
- Run the **Accelerate checklist** for loosely coupled teams:
  1. Make large-scale design changes without external permission?
  2. Make large-scale design changes without depending on other teams?
  3. Complete work without coordinating outside the team?
  4. Deploy on demand regardless of dependencies?
  5. Do most testing on demand without integrated test environments?
  6. Deploy during business hours with negligible downtime?
- Check **evolutionary architect practices**: principles documented (< 10)? Exemplars exist? Fitness functions automated? Technical debt visible to product owners?

**Decision criteria:**

- Cross-team services → coordination overhead, slow delivery.
- "You must use the platform" → bypass and shadow IT.
- No strong ownership → nobody maintains, nobody decommissions.

**Deliverable:** Organisational assessment — Conway's law alignment, ownership matrix, team structure review, Accelerate checklist results, governance maturity.

### 11. Synthesize findings

Consolidate all assessments into prioritized, actionable findings.

**What to do:**

- Collect every finding from steps 2–10.
- For each finding, assign:
  - **Severity**: critical (blocks independent deployability, security breach, data loss risk), moderate (degrades reliability/velocity), low (improvement opportunity).
  - **Effort**: quick-win (< 1 sprint), medium (1–3 sprints), major (programme-level).
  - **Principle violated**: map to specific **building-microservices** section and anti-pattern.
- Group findings by category: boundaries, communication, workflows, deployability, observability, resiliency, security, scaling, organisation.
- Identify **patterns**: findings that share a root cause (e.g. shared database causing boundary + deployability + workflow findings).
- Rank recommendations using **value-first ordering** and **cost of delay** — highest-impact, lowest-effort first.

**Decision criteria:**

| Severity | Examples |
|----------|---------|
| Critical | Shared mutable DB, 2PC, content coupling, secrets in Git, no correlation IDs |
| Moderate | Long sync chains, missing circuit breakers, no SLOs, lockstep releases |
| Low | Missing synthetic monitoring, suboptimal caching, stale architecture diagrams |

**Deliverable:** Findings register — categorized, severity/effort scored, principle mapping, root cause patterns.

### 12. Present

Deliver the structured audit report.

**What to do:**

- Apply the **architect-thinking** skill, section: **Communication** (build ramps not cliffs, show the pirate ship, emphasis over completeness, five-second test).
- Apply the **writing-style** skill to all composed text.
- Output the audit report in this structure:

```
## Architecture Audit: <System Name>

**Scope**: <services reviewed> | **Trigger**: <why reviewed> | **Date**: <today>

### Executive Summary

<5-second test: main health verdict in 2–3 sentences. Show the pirate ship — system purpose, not service count.>

### Health Scorecard

| Category | Status | Critical | Moderate | Low |
|----------|--------|----------|----------|-----|
| Boundaries | 🔴/🟡/🟢 | n | n | n |
| Communication | ... | ... | ... | ... |
| Workflows | ... | ... | ... | ... |
| Deployability | ... | ... | ... | ... |
| Observability | ... | ... | ... | ... |
| Resiliency | ... | ... | ... | ... |
| Security | ... | ... | ... | ... |
| Scaling | ... | ... | ... | ... |
| Organisation | ... | ... | ... | ... |

### Critical Findings

<Findings that block independent deployability, pose security/data loss risk>

| # | Finding | Principle violated | Effort | Recommendation |
|---|---------|-------------------|--------|----------------|

### Moderate Findings

<Findings that degrade reliability or velocity>

### Quick Wins

<Low-effort, high-impact improvements>

### Prioritized Recommendations

<Value-first ordering with cost of delay>

| Priority | Recommendation | Category | Effort | Expected impact |
|----------|---------------|----------|--------|-----------------|

### Suggested Next Commands

| Finding area | Command to run |
|-------------|---------------|
| Need new service design | `/design-microservice-system` |
| Need to extract from monolith | `/extract-microservice` |
| Need implementation plan for fix | `/plan` |
| Need to debug production issue | `/debug` or `/investigate-incident` |

### Appendix

<Detailed per-service assessments, coupling maps, diagrams referenced>
```

### 13. Evolve

Follow the **continuous-improvement** skill.
