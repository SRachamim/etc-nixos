---
name: building-microservices
description: Microservice architecture principles, patterns, and practices from Sam Newman's "Building Microservices" (2nd ed.). Covers boundary design, communication, sagas, deployment, testing, observability, security, resiliency, scaling, UI decomposition, and organizational alignment. Use when creating, modifying, evolving, extracting, reviewing, or designing microservices or microservice systems.
---

# Building Microservices

Principles and practices from Sam Newman's *Building Microservices: Designing Fine-Grained Systems* (2nd ed., O'Reilly 2021), organised by decision context. For detailed chapter-by-chapter content, see [reference.md](reference.md). For a quick lookup of which command or skill to use, see [guide.md](guide.md).

## North Star

Independent deployability is the single most important concept. Everything else follows from it.

- **Independent deployability**: change, deploy, and release one microservice without deploying any other. This is not aspirational -- it is the default release discipline.
- **Information hiding** (Parnas): hide as much as possible inside a service; expose as little as possible via external interfaces. Implementation changes must not break upstream consumers.
- **Monolith-first default**: microservices are not the goal. Default to a monolith (or modular monolith) unless there is a justified reason to decompose. Reasons include: delivery contention across many teams, need for independent scaling, or need for technology heterogeneity.
- **Incremental adoption**: turn the dial, don't flip the switch. Extract one service, deploy to production, assess, then decide whether to continue.
- **Microservices buy you options** (James Lewis) -- at a cost. Every option has a strike price. Evaluate the cost of maintaining each option.

**When to apply**: every microservice decision. If a design choice undermines independent deployability, it requires explicit justification.

## Modeling Boundaries

Use domain-driven design to find service boundaries that maximise cohesion and minimise coupling.

### Core concepts

- **Bounded context**: organisational boundary hiding internal complexity; contains one or more aggregates; exposes an explicit external interface.
- **Aggregate**: real-world domain concept with a lifecycle and state machine (Order, Invoice). One aggregate is managed by exactly one microservice. One microservice can own many aggregates.
- **Ubiquitous language**: use the same terms in code and domain conversations. Shared models across contexts may have different names (Customer vs Recipient).

### Coupling taxonomy (low to high)

| Type | Description | Action |
|------|-------------|--------|
| **Domain** | Service A calls B for B's functionality | Unavoidable; minimise downstream fan-out |
| **Temporal** | Both services must be up simultaneously | Use async messaging to decouple availability |
| **Pass-through** | A passes data to B only because C needs it | Hide in intermediary or use opaque blob |
| **Common** | Shared DB, filesystem, or memory | Single owner for mutable state; read-only ref data sometimes OK |
| **Content** | External service directly modifies another's DB | **Never acceptable**; route through owning service's API |

### Boundary quality checklist

1. Can I change and deploy this service independently?
2. Is related business behaviour co-located (strong cohesion)?
3. Are cross-boundary assumptions minimised (loose coupling)?
4. Is internal state hidden (information hiding)?
5. Does one service own each aggregate's lifecycle/state machine?

### Decomposition drivers

Default to **domain-oriented** boundaries. Mix other drivers pragmatically:

| Driver | When it fits |
|--------|--------------|
| Domain (DDD) | Default; business-aligned change isolation |
| Volatility | Fast time-to-market; frequently changing features |
| Data/security | PCI, GDPR, PII segregation into security zones |
| Technology | Different runtime/DB requirements |
| Organisation | Match team ownership; avoid cross-team services |

### Event storming

Events (orange) -> Commands (blue) -> Aggregates (yellow) -> Bounded contexts -> map to services. Run with domain experts; don't let current implementation warp the domain model.

**Anti-patterns**: splitting an aggregate across services; CRUD wrapper services with behaviour leaked to consumers; three-tier horizontal layering as service boundaries; premature fine-grained decomposition before the domain is understood.

**When to apply**: `/design-microservice-system`, `/create-microservice`, `/extract-microservice`, `/review-microservice-architecture`, and any `/plan` involving service boundaries.

## Communication Design

Choose communication **style** before **technology**. Never pick technology first.

### Decision framework

```
1. Request-response or event-driven?
   - Need result before continuing? -> Request-response
   - Broadcasting a fact; consumers decide reaction? -> Event-driven (looser coupling)

2. If request-response: sync or async?
   - Short chain, simple system, team new to distributed? -> Sync blocking OK
   - Long chain / long process / availability decoupling? -> Async nonblocking

3. Then pick technology:
   - Sync request-response: REST (default), gRPC (performance, both ends controlled)
   - Async request-response: message broker with reply queue
   - Event-driven: message broker topics (Kafka, RabbitMQ)
   - Large batch / legacy interop: common data (data lake, shared file)
```

### API design principles

- **Explicit schemas**: OpenAPI for REST, protobuf for gRPC, AsyncAPI/CloudEvents for events. Fail CI on incompatible schema changes.
- **Tolerant reader** (Postel's law): consume only needed fields; ignore unknown fields.
- **Expand and contract**: add new fields/endpoints first (expansion), migrate consumers, then remove old (contraction). Never remove without deprecation.
- **Semantic versioning**: MAJOR = breaking, MINOR = backward-compatible, PATCH = bug fix.
- **Consumer-first**: microservices exist to be consumed. Track endpoint usage; require client identifiers. Establish social contracts for breaking changes.
- **Consumer-driven contracts** (Pact): consumer writes tests specifying expected producer behaviour; producer runs all consumer contracts on every build.

### Event payload strategies

- **Fully detailed** (preferred): include all data you'd expose via API. Enables audit/event sourcing; reduces callback coupling.
- **ID only**: small message but causes callback storms to emitter. Avoid unless payload would be very large.

### Infrastructure

- **API gateway**: north-south (perimeter) only. API keys, rate limiting, TLS termination. No business logic, no east-west proxying.
- **Service mesh**: east-west (internal). Generic cross-cutting only -- mTLS, timeouts, correlation IDs, load balancing. Skip if fewer than ~5 services.
- **Keep pipes dumb, endpoints smart**: no business logic in gateways, ESBs, or meshes.

**Anti-patterns**: hiding network calls behind opaque abstractions; chatty synchronous chains (3+ services); Kafka for request-response; shared domain object libraries across services; DRY across service boundaries; smart middleware.

**When to apply**: `/create-microservice` (step 3), `/design-microservice-system` (step 4), `/evolve-microservice-api`, and any `/plan` involving inter-service communication.

## Workflow and Sagas

Coordinate cross-service state changes with sagas, never with distributed transactions.

- **Never use 2PC/XA across microservices**: locks, latency, wedged applications, manual recovery. Availability decreases with each added participant.
- **Sagas**: sequence of independent local transactions with compensating actions for rollback. No saga-level atomicity -- design for partial completion.
- **Compensating transactions**: semantic rollbacks (can't unsend an email; send a cancellation instead). Define for every committable step.

### Orchestration vs choreography

| Condition | Recommendation |
|-----------|----------------|
| One team owns entire saga | Orchestration OK |
| Multiple teams involved | Prefer choreography |
| Need process visibility in one place | Orchestration |
| Need loose coupling + team isolation | Choreography |

### Design heuristics

- **Reorder steps**: move failure-prone steps earlier (fail fast); move hard-to-compensate steps later (so they rarely need rollback).
- **One orchestrator per business capability** -- never a mega-orchestrator absorbing service logic.
- **Correlation ID on every saga event** -- mandatory for tracking state and triggering compensations.
- **Choreographed sagas**: build a projection service consuming all events to track saga state.
- **Separate business failures from technical failures**: saga compensations handle business rules; circuit breakers and retries handle transient technical failures.

**Anti-patterns**: 2PC across microservices; mega-orchestrator absorbing domain logic; implicit business processes hidden across services; traditional BPM GUI tools for developer-implemented flows; choreography without correlation IDs.

**When to apply**: `/create-microservice` (step 5), `/design-microservice-system` (step 5), `/extract-microservice` (step 5), and any `/plan` involving cross-service workflows.

## Build and Deployment

### CI maturity gate (Jez Humble)

Before scaling microservices, answer three questions honestly:
1. Do you check in to mainline at least once per day?
2. Do you have tests that validate behaviour (not just compile)?
3. Is a broken build the team's #1 priority to fix?

If any answer is no, fix CI before adding more services.

### Build practices

- **Trunk-based development**: feature flags for incomplete work. Branches < 1 day lifetime (DORA research).
- **Build artifact once**: compile + fast tests -> build artifact -> store in registry -> deploy same artifact everywhere. Never rebuild per environment.
- **Environment-agnostic artifacts**: externalize all config (DB URLs, log levels, feature flags).
- **Multirepo default**: one repo = one microservice = one build. Cross-repo change pain signals wrong boundaries.

### Deployment practices

- **Zero-downtime deployment**: upstream consumers must not notice releases. Use rolling upgrades, blue-green, or Kubernetes deployments.
- **Separate deployment from release** (Jez Humble): deployment = install to environment; release = make available to users. Progressive delivery = CD with fine-grained blast radius control.
- **Progressive delivery**: feature toggles -> canary releases -> blue-green -> parallel runs. Start with feature toggles.
- **Sam's Rules of Thumb**: (1) if it ain't broke, don't fix it; (2) offload to PaaS/FaaS when possible; (3) containerise microservices as default.
- **Deployment option selection**: FaaS (if workload fits) > PaaS > containers + orchestration > VMs. Don't adopt Kubernetes "because everyone else is."

**Anti-patterns**: CI tool without CI practices; long-lived feature branches; one repo + one build for many services; rebuilding artifacts per environment; lockstep releases; Kubernetes for a handful of services.

**When to apply**: `/create-microservice` (step 6), `/design-microservice-system` (step 6), `/extract-microservice` (step 4), and any `/plan` involving build/deploy changes.

## Testing Strategy

### Test pyramid

- **Unit tests**: most numerous; fastest feedback; run on file change.
- **Service tests**: test one microservice with stubbed downstreams. Prefer stubs over mocks.
- **End-to-end tests**: fewest; slowest; most brittle. Minimise and plan to replace with CDCs + production testing.
- **Target ratio**: ~10x more tests descending the pyramid.

### Consumer-driven contracts (CDCs)

- Consumer writes tests specifying expected producer behaviour.
- Producer runs all consumer contracts on every build.
- Same scope as service tests, but cross-service compatibility focus.
- Use Pact Broker for contract storage and dependency mapping.
- CDCs replace most need for cross-team E2E tests.

### Production testing

- **MTBF vs MTTR**: invest in fast rollback + monitoring alongside preproduction tests. Cannot catch all distributed problems before production.
- **Synthetic transactions**: inject fake users with known data for critical business flows. Guard against side effects.
- **Canary releases**: production validation with metric-driven automated ramp.

### Developer local setup

- Run only your team's microservices locally. Stub everything else.
- Never require running the full system locally.

**Anti-patterns**: test snow cone (inverted pyramid); flaky tests left in suite; dedicated E2E test team; metaversion / system-wide versioning; shared integrated test environments; deferring performance testing.

**When to apply**: `/create-microservice` (step 9), `/review-microservice-architecture` (step 6), and any `/plan` involving test strategy.

## Observability

### Prerequisites (implement before scaling service count)

1. **Log aggregation** -- organisational readiness test. If your org can't implement this, microservices will overwhelm it.
2. **Correlation IDs** -- generated at entry point, propagated through all calls, fixed position in log lines. Easy at the start, hard to retrofit.

### Beyond prerequisites

- **Metrics**: baselines over weeks/months. Tag with service, instance, host metadata. Standard metric names across all services.
- **Distributed tracing**: start with correlation IDs in logs; add tracing (OpenTelemetry) when complexity warrants. Dynamic sampling: all errors, sparse successes.
- **SLOs and error budgets**: team-level objectives (uptime, p99 latency). Error budget gates risky changes. Shift from binary up/down to nuanced health.
- **Alerting** (EEMUA criteria): Relevant, Unique, Timely, Prioritised, Understandable, Diagnostic, Advisory, Focusing. Alert on SLO violations, not every metric threshold.
- **Semantic monitoring**: "Is the system behaving as we expect?" not "Are there errors?" Use synthetic transactions for critical flows.

**Anti-patterns**: SSH/grep across hosts; no correlation IDs; alerting on every threshold (alert fatigue); binary up/down health thinking; inconsistent metric names; logging sensitive data.

**When to apply**: `/create-microservice` (step 10), `/review-microservice-architecture` (step 7), and any `/plan` involving monitoring or alerting.

## Security

### Approach

- **Threat model first**: holistic, not per-microservice. Consider external parties for outside-in perspective.
- **Defense in depth**: preventative + detective + responsive controls at every layer.
- **Least privilege**: minimum access, minimum time. Per-service, per-instance credentials. Time-limited tokens.
- **Zero trust as spectrum**: implicit trust is a conscious risk decision, not the default. PII/secret-classified data always gets zero trust (mutual auth, encryption, per-request authorization).

### Practices

- **Secrets management**: Vault, K8s Secrets, cloud secrets managers. Never check keys into Git. Rotate frequently; automate rotation.
- **Encryption**: HTTPS/TLS everywhere (internal too). mTLS for service-to-service in zero-trust contexts. Encrypt at rest. Never roll your own crypto.
- **Authentication**: OpenID Connect for SSO (over SAML). Per-request JWTs at gateway; downstream services validate and authorise locally.
- **Authorisation**: coarse-grained roles modeled on org structure. Fine-grained authorisation pushed into the owning microservice.
- **Data frugality** (Datensparsamkeit): collect/store minimum PII needed. Anonymise logs. If you don't store it, it can't be stolen.
- **CI scanning**: dependency scanning (Snyk), secret scanning (gitleaks/git-secrets), DAST (ZAP).
- **Backups**: separate account/region/provider from production. Test restoration regularly.

**Anti-patterns**: JWT/mTLS focus while ignoring basics; threat modeling only 1-2 services; shared broad-privilege credentials; backups in same cloud account; centralized upstream authorization breaking independent deployability; implementing your own encryption.

**When to apply**: `/create-microservice` (step 8), `/review-microservice-architecture` (step 9), and any `/plan` involving security changes.

## Resiliency

### Stability patterns (mandatory)

- **Timeouts on ALL out-of-process calls**: set based on healthy p99 response time and user-facing SLA budget. Include pool wait timeout.
- **Separate connection pool per downstream** (bulkhead minimum): one slow service must not exhaust all workers.
- **Circuit breakers on ALL synchronous downstream calls**: fail fast when downstream unhealthy. Manually open during planned maintenance.
- **Operation-level timeout budget**: pass remaining time to downstream calls. Skip retries if budget exhausted.

### Stability patterns (conditional)

- **Retries with backoff**: for transient failures only. Factor retry time into total timeout budget.
- **Idempotency**: include business keys so duplicate calls don't duplicate effects. Mandatory before enabling retries on mutations.
- **Isolation**: separate hosts/containers/DB infra for critical services based on blast radius analysis.
- **Redundancy**: multiple instances across multiple availability zones. No SLA for a single instance.

### Graceful degradation

For each user-facing flow, for each dependency: **what is the business-acceptable fallback?** This is a business decision, not technical.
- Hide feature; show stale/cached data; offer alternative channel (phone number); close site (last resort).

### CAP per capability

- Stale data acceptable? -> AP (eventually consistent)
- Consistency required? -> CP (accept unavailability during partition)
- **Per service, per operation**: different trade-offs OK. Don't build your own CP datastore.

### Resilience culture

- **Blameless post-mortems**: blame -> fear -> hidden failures -> repeat incidents.
- **Game Days**: surprise drills for people/processes, not just machines.
- Running a chaos tool doesn't make you resilient. Resilience is people, processes, and culture, not just software.

**Anti-patterns**: shared connection pool for all downstreams; long timeouts on user-facing paths; retries without idempotency; sticky sessions; blame culture; over-engineering resiliency for low-criticality services.

**When to apply**: `/create-microservice` (step 7), `/review-microservice-architecture` (step 8), `/debug`, and any `/plan` involving failure handling.

## Scaling

### Four axes (try in order)

1. **Vertical**: bigger machine. Quick win on cloud. Doesn't improve robustness.
2. **Horizontal duplication**: load balancers, read replicas, competing consumers. Default for stateless services.
3. **Data partitioning**: shard by data attribute. Choose partition keys for even distribution (unique IDs, not surname ranges). Internal implementation detail.
4. **Functional decomposition**: extract into independently scalable service. Highest code/data impact. Try other axes first.

### Caching

- Cache in **as few places as possible**. Ideal = zero caches; add only with measured bottleneck.
- Prefer TTL as starting point. Don't nest caches without understanding compounded staleness.
- Never `Expires: Never` on HTTP responses unless intentional.

### Autoscaling

- Start with failure-based autoscaling (min N instances). Add load-based rules only with validated data.
- Scale down cautiously -- better to have excess capacity.

### Scaling mindset

- **Measure before optimising** (Knuth): premature optimisation is the root of all evil.
- Rearchitecture at tipping points is a **sign of success**, not failure.
- Don't build for massive scale before validating the product.

**When to apply**: `/review-microservice-architecture` (step 10), and any `/plan` involving performance or scaling.

## User Interfaces

- **Stream-aligned team ownership**: teams own UI + backing services end-to-end. Avoid dedicated frontend teams creating handoff bottlenecks.
- **Micro frontends** for SPAs: independently deliverable frontend applications composed into a greater whole. Use custom browser events for inter-widget communication.
- **Page-based decomposition** for websites: different page groups served by different services. Simpler than SPAs when sufficient.
- **BFF per client type**: "One experience, one BFF" (Stewart Gleadow). Server-side aggregation and filtering for mobile. Extract duplicated BFF logic into a new microservice at ~3 uses (rule of three).
- **Keep domain logic in domain microservices**: BFFs and gateways only aggregate, filter, and route.
- **Consistency vs autonomy**: explicit organisational choice. Shared style guides + UI components for polish; or accept inconsistency for delivery speed (Amazon model).

**When to apply**: `/design-microservice-system`, `/create-microservice`, and any `/plan` involving UI architecture.

## Organisation and Architecture

### Conway's law

System design mirrors organisational communication structure. Align team boundaries with service boundaries. Loosely coupled orgs produce modular systems.

### Team structure

- **Stream-aligned teams**: 5--10 people, end-to-end ownership (design -> build -> deploy -> operate -> decommission).
- **Strong ownership**: one team owns one microservice. Controls code, standards, tech, deployment.
- **Enabling teams**: support stream-aligned teams in cross-cutting areas (security, UI, platform). Embed or consult; don't silo.
- **Paved road**: make the right way easy, not mandatory. Measure by adoption OKRs, not mandates. "You must use the platform" leads to bypass and shadow IT.

### Evolutionary architect

- Think **town planner**, not building architect: define zones (constraints) and connections, not internal details.
- Be **liberal inside service boundaries**, strict at interfaces between services. Standardise integration (1--2 styles); allow variation inside teams.
- **< 10 principles** mapped to practices; revisit regularly. Log exceptions; enough exceptions -> update the principle.
- **Embed with teams**: pair or ensemble program regularly. Architecture is a social construct.
- **Good-citizen microservice checklist**: standardised health/metrics, 1--2 integration styles, circuit breakers, correct HTTP status codes, correlation IDs.
- **Exemplars**: real running microservices that get things right. Optional templates, never mandated frameworks.
- **Fitness functions**: automated checks that architectural characteristics stay within bounds.
- **Technical debt**: conscious shortcuts vs vision drift. Make product owners accountable for debt, not just feature delivery.

### Accelerate checklist for loosely coupled teams

1. Make large-scale design changes without external permission?
2. Make large-scale design changes without depending on other teams?
3. Complete work without coordinating outside the team?
4. Deploy on demand regardless of dependencies?
5. Do most testing on demand without integrated test environments?
6. Deploy during business hours with negligible downtime?

**When to apply**: `/review-microservice-architecture` (step 11), `/design-microservice-system`, and any architectural decision involving team structure or governance.

## Critical Anti-Patterns (Cross-Cutting)

These are the most dangerous mistakes across all areas. Flag any of these immediately:

1. **Shared mutable database** across services -- destroys independent deployability
2. **Distributed transactions (2PC/XA)** across microservices -- locks, latency, availability death
3. **Long synchronous call chains** (3+ services) -- cascade failure, latency multiplication
4. **Content coupling** -- external service directly modifying another's DB
5. **Shared domain libraries** across services -- coordinated redeploy on every change
6. **Metaversioning** -- system-wide version number coupling all services
7. **Smart middleware** -- business logic in gateways, ESBs, or service meshes
8. **Microservices as the goal** -- activity without outcome; "you don't win by having microservices"
9. **Big-bang decomposition** -- "the only thing you're guaranteed of is a big bang" (Fowler)
10. **Technology before communication style** -- picking Kafka/gRPC before deciding event-driven vs request-response
