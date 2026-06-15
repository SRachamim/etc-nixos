---
name: design-microservice-system
description: Design a new microservice architecture from scratch. Plan mode workflow covering domain modeling, service boundaries, communication, workflows, deployment, observability, security, resiliency, scaling, and validation against Newman's principles.
disable-model-invocation: true
---

# Design Microservice System

Design a new microservice architecture from scratch. This command produces an architecture document with diagrams, decision rationale, and a value-first implementation sequence. It does **not** implement code — that is a separate step after the user approves the design.

## Input

Accept **any** of the following:

1. **Business goal or product brief** — plain-language description of what the system must achieve, who the users are, and what success looks like.
2. **Ticket or design document** — an Azure DevOps work item, tech design, or linked specification. Fetch via MCP when applicable.
3. **Constraints** — regulatory requirements, team size, timeline, budget, existing technology commitments, or non-functional requirements (latency, availability, scale).

When multiple inputs are provided, they supplement each other. If the goal is ambiguous, ask clarifying questions before proceeding.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. Steps 1–13 are read-only analysis and design — Plan mode keeps the focus on discussion rather than premature implementation. The user will switch to Agent mode separately when they want to build.

### 1. Understand the goal

Establish why microservices are being considered and what business outcomes must be achieved.

**What to do:**

- Restate the business goal in your own words. Identify measurable outcomes (revenue, time-to-market, availability, compliance, team throughput).
- Capture **constraints**: team size and structure, budget, regulatory scope, existing tech stack, deployment environment, timeline.
- List **non-functional requirements**: expected load, latency budgets, availability targets, data residency, security classification.
- Apply the **monolith-first default**: read and apply the **building-microservices** skill, section: **North Star**. Ask explicitly: *Can a monolith or modular monolith achieve these outcomes?* Document the answer with evidence.
- If microservices are justified, record the specific drivers (delivery contention, independent scaling, technology heterogeneity, organisational alignment). If not justified, recommend the simpler approach and stop this command.

**Decision criteria:**

| Signal | Lean away from microservices | Lean toward microservices |
|--------|------------------------------|---------------------------|
| Product maturity | Brand-new product, unstable domain | Stable domain, SaaS / 24×7 |
| Team size | Small team (handful of devs) | Many developers, delivery contention |
| Primary goal | Cost reduction alone | Independent releases, team autonomy, targeted scaling |
| Ops readiness | No log aggregation or CI maturity | CI/CD, observability foundations in place |

Read **building-microservices** [reference.md](reference.md), Chapter 1: *Decision framework: should I use microservices?* for the full checklist.

**Deliverable:** A one-paragraph goal statement, a constraints table, and an explicit microservices vs monolith recommendation with rationale.

### 2. Model the domain

Discover service boundaries from the business domain, not from technical layers.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Modeling Boundaries**.
- Run an **event storming** exercise (even as a desk exercise if domain experts are unavailable):
  1. **Events** (past tense facts: `OrderPlaced`, `PaymentCaptured`) — orange sticky notes.
  2. **Commands** (actions that cause events) — blue sticky notes.
  3. **Aggregates** (entities with lifecycle and state machines) — yellow sticky notes.
  4. **Bounded contexts** — group aggregates that share ubiquitous language and change together.
- Document the **ubiquitous language**: terms, their meanings, and where the same concept has different names across contexts (e.g. Customer vs Recipient).
- Identify **decomposition drivers** beyond pure domain: volatility hotspots, data/security zones (PCI, GDPR), technology constraints, organisational ownership.
- Do **not** let the current (or imagined) implementation warp the domain model.

**Decision criteria:**

- Each aggregate has a clear lifecycle and state machine.
- Bounded contexts hide internal complexity behind an explicit external interface.
- No aggregate is split across contexts at this stage.

**Anti-patterns to flag:** CRUD wrapper services, three-tier horizontal layering as boundaries, premature fine-grained decomposition.

**Deliverable:** Domain model summary — events, commands, aggregates, bounded contexts, ubiquitous language glossary.

### 3. Define service boundaries

Map bounded contexts to candidate microservices.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Modeling Boundaries** (Mapping to microservices, Boundary quality checklist, Coupling taxonomy).
- Start **coarse**: one bounded context ≈ one service. Hide internal splits behind a coarse API until experience warrants finer decomposition.
- For each candidate service, run the **boundary quality checklist**:
  1. Can I change and deploy this service independently?
  2. Is related business behaviour co-located (strong cohesion)?
  3. Are cross-boundary assumptions minimised (loose coupling)?
  4. Is internal state hidden (information hiding)?
  5. Does one service own each aggregate's lifecycle/state machine?
- Classify every planned inter-service relationship by **coupling type**: domain, temporal, pass-through, common, content. Flag content coupling as never acceptable; flag common coupling (shared mutable state) for remediation.
- Record which **decomposition driver** justified each boundary.

**Decision criteria:**

- **Independent deployability** is the default release discipline — any design that undermines it requires explicit justification.
- One aggregate → exactly one owning service. One service may own many aggregates.
- Prefer domain-oriented boundaries; mix other drivers pragmatically.

**Deliverable:** Service catalogue — name, owned aggregates, bounded context, decomposition driver, boundary checklist results, coupling map between services.

### 4. Design communication

For each inter-service interaction, choose style and pattern before technology.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Communication Design**.
- For **every** service-to-service interaction, document:
  1. **Business need** — what functionality or fact is being exchanged?
  2. **Style** — synchronous request-response or asynchronous event-driven?
  3. **Pattern** — direct call, pub/sub, request-reply queue, bulk data transfer?
  4. **Technology** — only after steps 1–3 are decided (REST default for sync, gRPC when both ends controlled and performance matters, message broker for events).
- Apply the decision framework:
  - Need result before continuing? → Request-response.
  - Broadcasting a fact; consumers decide reaction? → Event-driven.
  - Short chain, simple system? → Sync blocking may be OK.
  - Long chain / availability decoupling? → Async nonblocking.
- Design **API schemas** (OpenAPI for REST, protobuf for gRPC) and **event payloads** (AsyncAPI/CloudEvents). Prefer fully detailed event payloads over ID-only callbacks.
- Plan schema evolution: expand-and-contract, semantic versioning, consumer-driven contracts where cross-team.
- Identify infrastructure needs: API gateway (north-south only), service mesh (east-west, only if ~5+ services), correlation ID propagation.

**Decision criteria:**

- No interaction should pick technology before style.
- No synchronous call chains longer than **two hops** (three services in series) without explicit justification.
- No shared domain object libraries across service boundaries.
- Keep pipes dumb, endpoints smart — no business logic in gateways, ESBs, or meshes.

**Deliverable:** Communication matrix — source, target, style, pattern, technology, schema reference, coupling type, versioning strategy.

### 5. Design workflows

Model cross-service business processes explicitly.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Workflow and Sagas**.
- Identify every **cross-service business process** (order fulfilment, account onboarding, payment settlement, etc.).
- For each process, choose **saga style**:
  - **Orchestration** — one team owns the entire saga; need process visibility in one place.
  - **Choreography** — multiple teams involved; need loose coupling and team isolation.
- Define the **saga steps**: local transactions per service, in optimal order (fail-fast steps early, hard-to-compensate steps late).
- Define **compensating transactions** for every committable step. Compensations are semantic rollbacks (send cancellation email, not unsend).
- Assign **correlation IDs** to every saga event — mandatory.
- For choreographed sagas, plan a projection service to track saga state from events.
- **Never** use 2PC/XA across microservices.

**Decision criteria:**

| Condition | Recommendation |
|-----------|----------------|
| One team owns entire saga | Orchestration OK |
| Multiple teams involved | Prefer choreography |
| Need process visibility in one place | Orchestration |
| Need loose coupling + team isolation | Choreography |

**Anti-patterns:** mega-orchestrator absorbing domain logic; implicit processes hidden across services; choreography without correlation IDs.

**Deliverable:** Workflow catalogue — process name, saga style, step sequence, compensating actions, correlation strategy, failure handling (business vs technical).

### 6. Plan deployment

Design how each service is built, stored, and released independently.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Build and Deployment**.
- Assess **CI maturity** (Jez Humble gate): daily mainline commits, behavioural tests, broken build is #1 priority. If any answer is no, plan CI fixes before scaling service count.
- Define **repo strategy**: multirepo default (one repo = one microservice = one build). Cross-repo change pain signals wrong boundaries.
- Define **CI/CD pipeline per service**: build artifact once, store in registry, deploy same artifact everywhere. Environment-agnostic artifacts with externalised config.
- Choose **deployment model** per service using Sam's Rules of Thumb:
  - FaaS if workload fits → PaaS → containers + orchestration → VMs.
  - Don't adopt Kubernetes "because everyone else is."
- Plan **zero-downtime deployment**: rolling upgrades, blue-green, or orchestrator-native strategies. Separate deployment from release.
- Plan **progressive delivery**: feature toggles → canary → blue-green. Start with feature toggles.
- Use **trunk-based development** with feature flags for incomplete work.

**Decision criteria:**

- Each service must deploy without deploying any other service.
- No lockstep releases, no metaversioning, no single repo + single build for many services.

**Deliverable:** Deployment plan — repo layout, CI/CD per service, deployment model, zero-downtime strategy, progressive delivery approach, CI maturity assessment.

### 7. Plan observability

Ensure the system can be understood in production before scaling service count.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Observability**.
- Plan **prerequisites** (implement before scaling):
  1. **Log aggregation** — organisational readiness test.
  2. **Correlation IDs** — generated at entry point, propagated through all calls, fixed position in log lines.
- Plan **metrics**: standard names across services, tagged with service/instance/host, baselines over weeks/months.
- Plan **distributed tracing**: start with correlation IDs in logs; add OpenTelemetry when complexity warrants.
- Define **SLOs and error budgets** per service or team: uptime, p99 latency. Error budget gates risky changes.
- Plan **alerting** using EEMUA criteria: Relevant, Unique, Timely, Prioritised, Understandable, Diagnostic, Advisory, Focusing. Alert on SLO violations, not every threshold.
- Plan **semantic monitoring**: synthetic transactions for critical business flows.

**Decision criteria:**

- If the organisation cannot implement log aggregation, microservices will overwhelm it — flag this as a blocker.
- Correlation IDs are easy at the start, hard to retrofit — plan them now.

**Deliverable:** Observability plan — log aggregation approach, correlation ID strategy, metrics/tracing, SLOs per service, alerting rules, synthetic monitoring flows.

### 8. Plan security

Threat-model the system holistically before per-service hardening.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Security**.
- Perform a **holistic threat model** (not per-microservice in isolation). Include external parties for outside-in perspective.
- Define the **trust model** on the zero-trust spectrum: which interactions require mutual auth, mTLS, per-request authorization? PII/secret-classified data always gets zero trust.
- Plan **authentication**: OpenID Connect for SSO; per-request JWTs at gateway; downstream services validate locally.
- Plan **authorisation**: coarse-grained roles at gateway; fine-grained pushed into owning microservice.
- Plan **secrets management**: Vault, cloud secrets managers, or K8s Secrets. Never check keys into Git. Automate rotation.
- Plan **data classification**: what data is public, internal, confidential, restricted? Apply **data frugality** — collect/store minimum PII needed.
- Plan **CI security scanning**: dependency scanning, secret scanning, DAST.
- Plan **encryption**: TLS everywhere (internal too), encryption at rest, backups in separate account/region.

**Decision criteria:**

- Defense in depth at every layer: preventative + detective + responsive.
- Least privilege: per-service, per-instance credentials, time-limited tokens.
- Centralized upstream authorization that breaks independent deployability is an anti-pattern.

**Deliverable:** Security plan — threat model summary, trust model, auth strategy, secrets management, data classification matrix, CI scanning, encryption requirements.

### 9. Plan resiliency

Design for failure from the start — distributed systems fail.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Resiliency**.
- Define **SLOs per service** that drive timeout and circuit breaker settings.
- Apply **mandatory stability patterns** to every synchronous downstream call:
  - Timeouts on ALL out-of-process calls (based on healthy p99 and user-facing SLA budget).
  - Separate connection pool per downstream (bulkhead minimum).
  - Circuit breakers on ALL synchronous downstream calls.
  - Operation-level timeout budget passed to downstream calls.
- Plan **conditional patterns**: retries with backoff (transient failures only), idempotency keys on mutations (mandatory before retries).
- Build a **degradation matrix**: for each user-facing flow, for each dependency, define the business-acceptable fallback (hide feature, stale cache, alternative channel, close site as last resort). This is a **business decision**, not purely technical.
- Apply **CAP per capability**: stale data acceptable → AP; consistency required → CP. Different trade-offs per service, per operation.

**Decision criteria:**

- One slow service must not exhaust all workers (bulkhead).
- Retries without idempotency on mutations is an anti-pattern.
- Resilience is people, processes, and culture — plan blameless post-mortems and Game Days.

**Deliverable:** Resiliency plan — SLOs, stability patterns per interaction, degradation matrix, CAP trade-offs, incident response culture.

### 10. Plan scaling

Plan how each service scales without premature optimisation.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Scaling**.
- For each service, define the **initial scaling strategy** using the four axes (try in order):
  1. Vertical — bigger machine (quick win, doesn't improve robustness).
  2. Horizontal duplication — load balancers, read replicas, competing consumers (default for stateless).
  3. Data partitioning — shard by attribute with even distribution.
  4. Functional decomposition — extract independently scalable service (highest impact; try other axes first).
- Plan **caching strategy**: cache in as few places as possible. Ideal = zero caches; add only with measured bottleneck. Prefer TTL. Don't nest caches without understanding compounded staleness.
- Plan **autoscaling**: start with failure-based autoscaling (min N instances). Add load-based rules only with validated data. Scale down cautiously.
- **Measure before optimising** — don't build for massive scale before validating the product.

**Decision criteria:**

- Rearchitecture at tipping points is a sign of success, not failure.
- Functional decomposition (new service) is the last scaling axis, not the first.

**Deliverable:** Scaling plan — per-service scaling axis, caching strategy, autoscaling rules, known bottlenecks and measurement approach.

### 11. Validate

Cross-check the entire design against Newman's principles and anti-patterns.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Critical Anti-Patterns (Cross-Cutting)**.
- Verify **independent deployability** for every service: can each service change, deploy, and release without deploying any other?
- Confirm none of these exist in the design:
  1. Shared mutable database across services.
  2. Distributed transactions (2PC/XA) across microservices.
  3. Long synchronous call chains (3+ services in series).
  4. Content coupling (external service directly modifying another's DB).
  5. Shared domain libraries across services.
  6. Metaversioning (system-wide version number).
  7. Smart middleware (business logic in gateways, ESBs, meshes).
  8. Microservices as the goal (activity without outcome).
  9. Big-bang decomposition.
  10. Technology before communication style.
- Re-run the **boundary quality checklist** on every service.
- Review coupling taxonomy — no pass-through or common coupling without remediation plan.
- If any anti-pattern is present, either redesign to eliminate it or document explicit justification and accepted risk.

**Deliverable:** Validation report — checklist results, anti-pattern scan, independent deployability verification, open risks.

### 12. Present

Deliver the architecture document for review and approval.

**What to do:**

- Apply the **architect-thinking** skill, section: **Communication** (build ramps not cliffs, show the pirate ship, emphasis over completeness, five-second test, writing for busy people).
- Apply the **writing-style** skill to all composed text.
- Output the architecture document in this structure:

```
## Architecture: <System Name>

**Goal**: <one sentence> | **Recommendation**: microservices / modular monolith / monolith

### Executive Summary

<Show the pirate ship — what the system does for users, not how many services it has>

### Domain Model

<Bounded contexts, aggregates, ubiquitous language glossary>

### Service Catalogue

| Service | Aggregates | Driver | Deployable independently? |
|---------|-----------|--------|----------------------------|

### Communication Design

<Matrix or diagram — style before technology for every interaction>

### Workflows

<Saga catalogue with orchestration/choreography choices>

### Cross-Cutting Concerns

<Deployment, observability, security, resiliency, scaling — summary with pointers to detail>

### Diagrams

<C4 context/container diagrams, sequence diagrams for key workflows, deployment topology>

### Decision Log

| Decision | Options considered | Choice | Rationale |
|----------|-------------------|--------|-----------|

### Implementation Sequence

<Value-first ordering using cost of delay — ship highest-value, lowest-risk services first>

| Phase | Services / capabilities | Value delivered | Dependencies |
|-------|------------------------|-----------------|--------------|

### Risks and Open Questions

<Explicit unknowns, assumptions to validate, stop conditions>
```

- Wait for approval, modifications, or questions before any implementation begins.

### 13. Evolve

Follow the **continuous-improvement** skill.
