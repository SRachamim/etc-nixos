# Building Microservices -- Reference

Detailed chapter-by-chapter content from Sam Newman's *Building Microservices: Designing Fine-Grained Systems* (2nd ed., O'Reilly 2021). This file is the deep-reference companion to [SKILL.md](SKILL.md). The agent reads sections on demand when deeper guidance is needed.

For a quick lookup of which command or skill to use, see [guide.md](guide.md).

---

## Domain-Specific Guidance

The sections below are loaded on demand. Use the **Domain Lookup** table in [SKILL.md](SKILL.md) to find the relevant section for your decision context.

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

---

## Chapter-by-Chapter Reference

Detailed chapter-by-chapter extractions from the book. Read on demand when deeper guidance is needed.

## Chapter 1: What Are Microservices?

### Principles and patterns

- **Microservices** are independently releasable services modeled around a business domain. They encapsulate functionality and expose it via network endpoints (REST, queues, etc.). Technology-agnostic; consumers access via networked interfaces only.
- A microservice is a type of **SOA**, but opinionated about boundaries and independent deployability. SOA failed due to SOAP, vendor middleware, wrong granularity guidance, shared DBs, and deploy-together coupling. Microservices are a specific approach to doing SOA well.
- Treat each service as a **black box** from outside; internal implementation is hidden. Related to Hexagonal Architecture (Cockburn): separate internal implementation from external interfaces.
- **Information hiding** (Parnas): hide as much as possible inside; expose as little as possible via interfaces. Enables independent releasability, looser coupling, stronger cohesion.

### Decision framework: should I use microservices?

| Lean **away** | Lean **toward** |
|---------------|-----------------|
| Brand-new product / startup | Many developers, delivery contention |
| Unstable domain model | SaaS, 24/7, independent releases |
| Small team (handful of devs) | Cloud-native, match services to cloud offerings |
| Customer-deployed software | Digital transformation, unlock legacy via new channels |
| Primary goal = reduce costs | Need flexibility for unknown future |

### Monolith types

| Type | Definition |
|------|------------|
| **Single-process monolith** | All code deployed as one process |
| **Modular monolith** | Separate modules, combined for deployment; good parallel work, simpler ops |
| **Distributed monolith** | Multiple services but must deploy together; worst of both worlds |

### Advantages of microservices

- Technology heterogeneity
- Robustness (bulkheads)
- Targeted scaling
- Ease of deployment (small, independent)
- Organizational alignment (stream-aligned teams)
- Composability (multiple channels/clients)

### Pain points

- Developer experience (can't run all services locally)
- Technology overload
- Cost
- Reporting (no SQL joins across services)
- Monitoring and security complexity
- Testing complexity
- Latency
- Data consistency

### Anti-patterns

- **Shared databases** -- "one of the worst things" for independent deployability
- **Distributed monolith** -- SOA in name only; coupled, deploy-together
- **Layered (three-tier) architecture** for microservices -- changes span presentation/app/data tiers
- **Microservices as default** -- complexity must be warranted
- **Technology fetishism** -- adopting microservices + vast new alien tech simultaneously
- **Treating monolith as legacy/inherently bad**
- **Big-bang microservice adoption**
- **Microservices for cost-cutting** -- poor fit; cost-center mentality drags adoption
- **Microservices for startups/new products** -- unstable domain -> expensive boundary changes
- **Customer-deployed software + microservices** -- customers won't run K8s pods

### Key quotes

> "If you take only one thing from this book... ensure that you embrace the concept of independent deployability."

> "Don't share databases unless you really need to. And even then do everything you can to avoid it."

> "Microservices buy you options." -- James Lewis

> "A distributed system is one in which the failure of a computer you didn't even know existed can render your own computer unusable." -- Leslie Lamport

> "I am looking for a reason to be convinced to use microservices, rather than looking for a reason not to use them."

### Checklist: before adopting microservices

- [ ] Is log aggregation in place?
- [ ] Are correlation IDs implemented?
- [ ] Is the domain model stable enough for boundaries?
- [ ] Is there a clear goal (scale, time-to-market, team autonomy)?
- [ ] Is the team prepared for distributed system complexity?
- [ ] Has the monolith been evaluated (modular monolith, scaling behind LB)?

---

## Chapter 2: How to Model Microservices

### Principles and patterns

- **Good boundary** = independent change and deploy. Microservices are modular decomposition with network interaction.
- **Information hiding** (Parnas): "The connections between modules are the assumptions which the modules make about each other." Fewer assumptions -> easier safe change -> independent deployment amplifies benefits.
- **Cohesion**: "The code that changes together, stays together." Optimize for ease of changing business functionality.
- **Coupling**: loose coupling means changing one service without changing another. Limit number and chattiness of cross-service calls. "A structure is stable if cohesion is strong and coupling is low." -- Constantine.

### Coupling taxonomy

| Type | Description | Severity | Action |
|------|-------------|----------|--------|
| **Domain** | Service A calls B for B's functionality | Lowest; unavoidable | Minimize downstream fan-out |
| **Temporal** | Both services must be up simultaneously | Moderate | Use async messaging to decouple |
| **Pass-through** | A passes data to B only because C needs it | High | Hide in intermediary or use opaque blob |
| **Common** | Shared DB, filesystem, or memory | High | Single owner for mutable state |
| **Content** | External service directly modifies another's DB | Pathological | **Never acceptable** |

### Coupling remediation

| Coupling type | Remediation |
|---------------|-------------|
| Pass-through | Bypass intermediary, hide in intermediary, or opaque blob |
| Common (mutable) | Single owner service for state transitions |
| Content | Route through owning service's API |

### DDD essentials

- **Ubiquitous language**: same terms in code and domain conversations.
- **Aggregate**: real-world concept (Order, Invoice) with lifecycle and state machine. One aggregate managed by one microservice; one service can own many aggregates.
- **Bounded context**: organisational boundary hiding complexity. Contains aggregates. Exposes explicit external interface.
- Shared models across contexts may have different names/meanings (Customer vs Recipient).
- Cross-service aggregate refs: use explicit URIs or pseudo-URIs (`soundcloud:tracks:123`).

### Mapping to microservices

- Start with **entire bounded contexts** as services.
- **Never split one aggregate across microservices.**
- Nested bounded contexts; hide internal splits behind coarse API.
- **Event storming** (Brandolini): Events (orange) -> Commands (blue) -> Aggregates (yellow) -> Bounded contexts -> Map to services. Run with domain experts; don't let current implementation warp the domain model.

### Decomposition drivers

| Driver | When it fits |
|--------|--------------|
| **Domain (DDD)** | Default; business-aligned change isolation |
| **Volatility** | Fast time-to-market; frequently changing features |
| **Data/security** | PCI, GDPR, PII segregation into security zones |
| **Technology** | Different runtime/DB requirements |
| **Organisation** | Match team ownership; avoid cross-team services |

Mix models pragmatically; domain-oriented as default starting point.

### Boundary quality checklist

1. Can I change and deploy this service independently?
2. Is related business behaviour co-located (strong cohesion)?
3. Are cross-boundary assumptions minimised (loose coupling)?
4. Is internal state hidden (information hiding)?
5. Does one service own each aggregate's lifecycle/state machine?

### Anti-patterns

- **CRUD wrapper microservice** -- behaviour leaked to consumers; weak cohesion
- **Splitting aggregate across services**
- **Three-tier / horizontal layering** as service boundaries
- **Premature fine-grained decomposition** before domain understood (Snap CI merged back to monolith)
- **Bimodal IT** -- dump hard-to-change into "Mode 1"
- **Organisational split along technical seams** instead of business seams

### Key quotes

> "The connections between modules are the assumptions which the modules make about each other." -- David Parnas

> "The code that changes together, stays together."

> "If someone says 'The only way to do this is X!' they are likely just selling you more dogma."

---

## Chapter 3: Splitting the Monolith

### Principles and patterns

- **Migration mindset**: microservices are not the goal; activity != outcome. Need a clear end goal before starting.
- **Incremental migration** (Fowler: "If you do a big-bang rewrite, the only thing you're guaranteed of is a big bang.")
- Monolith often **remains in diminished form** (90% stays after extracting 10% bottleneck).
- **Premature decomposition**: unclear domain -> wrong boundaries -> expensive cross-service changes. Snap CI merged to monolith, waited ~1 year, then split with stable boundaries.

### Prioritisation matrix

```
Priority = f(benefit toward goal, extraction difficulty)
First picks: moderate benefit + low difficulty (quick wins)
Later: high benefit + high difficulty (after experience)
```

### What to split first

- Balance: ease of extraction vs benefit toward goal.
- Scale bottleneck -> extract constraining functionality.
- Time-to-market -> extract volatile parts (CodeScene hotspots).
- First services: low-hanging fruit with some impact; build momentum.
- If easiest extraction fails -> reconsider whether microservices fit.

### Code first vs data first

| Approach | When |
|----------|------|
| **Code first** | Default; faster short-term value; must validate data path upfront |
| **Data first** | Uncertain if data separates cleanly; de-risk integrity early |

### Decomposition patterns

- **Strangler fig**: intercept calls; route to new service or monolith; monolith unchanged.
- **Parallel run**: run old + new side-by-side, compare results. For critical functionality.
- **Feature toggle**: switch between monolith and microservice implementations.

### Data decomposition concerns

- **Performance**: DB joins become service calls + multiple SELECTs; latency increases. Mitigate with bulk lookups and caching.
- **Data integrity**: no cross-DB foreign keys; soft delete, denormalize at write time.
- **Transactions**: lose single-DB ACID; distributed transactions problematic; use sagas.
- **Tooling**: DB changes harder than code (Flyway, Liquibase, Rails migrations).

### Reporting database pattern

- Dedicated external DB; microservice pushes subset of internal data.
- Treat reporting DB like any service endpoint -- maintain compatibility.
- Tailor schema for consumers; may differ entirely from internal storage.

### Stop conditions

- Goal achieved with partial decomposition.
- Monolith handles remaining 90% fine.
- Only hard requirement for full removal: dead tech, retiring infra, ditching expensive third-party.

### Anti-patterns

- **Microservices as the goal** -- creating services without asking why
- **Big-bang rewrite/decomposition**
- **Backend-only decomposition** ignoring UI silos
- **Code extracted, data left in monolith** without a plan
- **Extracting hardest/critical piece first** before lessons learned

### Key quotes

> "Microservices are not the goal. You don't 'win' by having microservices."

> "Microservices aren't easy. Try the simple stuff first."

> "If you do a big-bang rewrite, the only thing you're guaranteed of is a big bang." -- Martin Fowler

> "The monolith is rarely the enemy."

### Checklist: before splitting

- [ ] Migration goal and success metrics written down
- [ ] Horizontal scaling / modular monolith evaluated
- [ ] Domain boundaries stable enough
- [ ] Both code and data extraction planned
- [ ] Strangler proxy or feature flag mechanism ready
- [ ] Reporting/analytics strategy defined

---

## Chapter 4: Microservice Communication Styles

### Principles and patterns

- **In-process vs inter-process**: network calls involve serialization, latency, and failure modes fundamentally different from local calls. Don't map object methods 1:1 to microservice calls. Abstractions must not hide that a network call is happening.
- **Performance**: measurable ms round-trips; no inlining optimizations. Payload size matters. Rethink chatty APIs (1000 local calls != 1000 network calls).
- **Failure modes** (Tanenbaum & Steen): crash, omission, timing, response, arbitrary (Byzantine). Many failures are transient; need rich error semantics (HTTP 4xx vs 5xx).

### Communication style decision framework

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

### Sync blocking red flags

- Chains of 3+ sequential sync services
- Downstream slowness blocking upstream
- Critical path with many temporal dependencies

### Event payload strategies

| Approach | Pros | Cons |
|----------|------|------|
| **ID only** | Small message | Callback coupling, load on emitter |
| **Fully detailed** (preferred) | Loose coupling, audit trail | Size, PII exposure, contract rigidity |
| **Hybrid** | Balance | Complexity |

### Async failure handling checklist

- [ ] Max retries configured
- [ ] Dead letter queue in place
- [ ] Correlation IDs for tracing
- [ ] Idempotent handlers
- [ ] Timeout handling
- [ ] Monitoring for async flows

### Anti-patterns

- **Hiding network calls** behind overly opaque abstractions
- **Chatty synchronous chains** -> cascade failure, connection exhaustion
- **Kafka for request-response**
- **Picking technology first** (Kafka, gRPC) without deciding communication style
- **Enterprise service bus** -- smarts pushed into middleware
- **ID-only events** causing callback storms
- **No max retry limit** on queues
- **No dead letter queue / replay UI**
- **Shared DB read/write** as integration (common coupling)

### Key quotes

> "A developer needs to be aware if they are doing something that will result in a network call."

> "Keep your middleware dumb, and keep the smarts in the endpoints."

> "A request implies something that can be rejected... A command implies a directive that must be obeyed."

> "I see far more teams replacing request-response interactions with event-driven interactions than the reverse."

---

## Chapter 5: Implementing Microservice Communication

### Principles and patterns

- Choose technology **after** deciding communication style.
- A single architecture (and single microservice) can **mix** communication styles.

### Ideal technology criteria

| Criterion | Meaning |
|-----------|---------|
| **Backward compatibility** | Adding fields/operations shouldn't break clients |
| **Explicit interface** | Clear contract via schemas + documentation |
| **Technology agnostic** | APIs must not lock into a stack |
| **Simple for consumers** | Low adoption cost |
| **Hide implementation detail** | Don't expose internal representations |

### Technology selection

| Situation | Recommendation |
|-----------|----------------|
| Wide variety of external clients | REST over HTTP |
| Perimeter + caching + external APIs | REST |
| Control both client and server; performance | gRPC |
| Compile client against server schema problematic | REST, not gRPC |
| Perimeter, mobile, multi-call aggregation | GraphQL (at perimeter only) |
| Async event-driven | Message broker topics |
| Async request-response | Message broker with reply queue |

### Schema management

- **Strongly favor explicit schemas** for all microservice endpoints.
- OpenAPI for REST, protobuf for gRPC, AsyncAPI/CloudEvents for events.
- CI compatibility checks: Protolock (protobuf), json-schema-diff-validator, openapi-diff, Confluent Schema Registry.
- **Fail CI build** on incompatible schema changes.
- Use **consumer-driven contract testing** (Pact) for semantic breakages.

### Breaking change strategies

| Situation | Approach |
|-----------|----------|
| Same team owns service + all consumers | Lockstep OK as one-off |
| Need consumer migration time | **Endpoint emulation** (old + new in same service; preferred) |
| Canary/blue-green (minutes-hours) | Coexist versions briefly |
| Legacy devices (Netflix set-top boxes) | Coexist versions (rare, costly) |

- Use **expand and contract**: deploy new endpoint alongside old; internally chain V1->V2->V3 transformations.
- Route via version in URI (`/v1/customer/`) or headers.
- **Avoid coexisting 3+ endpoint versions.**
- Establish **social contract** with consumers: what changes, why, migration timeline, who does the work, how to raise concerns.
- Log endpoint usage; require client identifiers (user-agent, API gateway keys).

### Code reuse across services

- Shared libraries OK for **internal/invisible** concerns (logging, metrics).
- **Copy service templates** rather than share domain object libraries across services.
- Accept multiple library versions in flight; redeploy each microservice independently.
- DRY across microservice boundaries = coupling.

### API gateways

- **North-south (perimeter) only**: API keys, rate limiting, TLS termination, developer portals.
- Do NOT use for: call aggregation (use GraphQL/BFF/saga), protocol rewriting (SOAP->REST), east-west traffic between microservices.
- **No business logic** in gateways.

### Service meshes

- **East-west (internal)**: sidecar proxies; mTLS, timeouts, correlation IDs, load balancing.
- **Generic cross-cutting only** -- no business logic.
- Per-microservice timeout configuration via self-service.
- Skip if fewer than ~5 microservices.
- Meshes don't cover broker protocols (Kafka bypasses mesh).

### Self-describing systems

- **Humane registry**: aggregate OpenAPI, health checks, ownership, operability score from live systems.
- Start with wiki; enrich with live data over time.
- Financial Times Biz Ops, Spotify Backstage as examples.

### Anti-patterns

- **Lockstep deployment** for breaking changes -- destroys independent deployability
- **Coexisting service versions** long-term -- branch codebase, routing complexity
- **Shared domain object libraries** across services -- one change -> redeploy all
- **DRY across microservice boundaries**
- **API gateway call aggregation + business logic**
- **Smart pipes** (ESB/gateway bloat)
- **Trusting "exactly once" blindly** -- build idempotent consumers anyway
- **Schemaless endpoints** -- implicit schema in consumer code

### Key quotes

> "Make Backward Compatibility Easy."

> "The first of the fallacies of distributed computing is 'The network is reliable.'"

> "Don't slip into thinking of your microservices as little more than an API on a database."

> "Keeping the pipes dumb, and the endpoints smart."

> Postel's law: "Be conservative in what you do, be liberal in what you accept from others."

> "One of the secrets to an effective microservice architecture is to embrace a consumer-first approach."

---

## Chapter 6: Workflow

### Principles and patterns

- Multiple microservices collaborating on a business process. Local ACID per microservice; no cross-service atomicity by default.
- **2PC (Two-phase commit)**: voting phase -> commit phase. Workers lock resources during voting. Loses isolation; deadlock risk; many failure modes require manual intervention. Latency grows with participants. Used only for very short-lived operations. **Strongly avoid across microservices.**
- **Sagas**: coordinate multiple state changes without long-term locking. Sequence of independent transactions with compensating actions. No saga-level atomicity. Originally for long-lived transactions (LLTs).

### Saga failure recovery

| Mode | Mechanism |
|------|-----------|
| **Backward recovery** | Compensating transactions (semantic rollback) |
| **Forward recovery** | Retry from failure point; requires persisted retry state |

### Compensating transactions

- Undo already committed steps -- not time travel.
- Semantic rollbacks: can't unsend email; send cancellation email instead.
- Rollback information may persist intentionally (audit).

### Orchestration vs choreography

| Aspect | Orchestration | Choreography |
|--------|---------------|--------------|
| Style | Command-and-control | Trust-but-verify |
| Coordination | Central orchestrator | Distributed event reactions |
| Coupling | Higher domain coupling | Lower domain coupling |
| Visibility | Process explicit in one place | Hard to see full process |
| Communication | Request-response heavy | Events heavy |
| State tracking | Built into orchestrator | Needs correlation ID + event projection |

### Decision table: orchestration vs choreography

| Condition | Recommendation |
|-----------|----------------|
| One team owns entire saga | Orchestration OK |
| Multiple teams involved | Prefer choreography |
| Team unfamiliar with events | Orchestration may be easier |
| Need loose coupling + team isolation | Choreography |

### Saga design heuristics

- **Reorder steps**: pull failure-prone steps earlier (fail fast); push hard-to-compensate steps later (rarely need rollback).
- **One orchestrator per business capability** -- never a mega-orchestrator.
- **Correlation ID on every saga event** -- mandatory.
- Choreographed sagas: build **projection service** consuming all events to track saga state.
- Separate **business failures** (saga handles via compensation) from **technical failures** (retries, circuit breakers).

### Decision tree: distributed state management

```
Need atomic cross-service state change?
├── Can it stay in one DB/service? -> YES: don't split
├── Short-lived + willing to accept 2PC pain? -> Rarely: 2PC (avoid)
└── Long-lived or multi-service -> Saga
```

### Anti-patterns

- **2PC across microservices** -- locks, latency, wedged apps, manual recovery
- **Assuming saga gives ACID atomicity** -- design for partial completion
- **Mega-orchestrator** absorbing service logic -- anemic services
- **Traditional BPM tools** for developer-implemented flows -- no version control, untestable
- **Choreography without correlation IDs** -- can't track saga state
- **Implicit business processes** hidden in code across services

### Key quotes

> "A saga does not give us atomicity in ACID terms... What a saga gives us is enough information to reason about which state it's in; it's up to us to handle the implications of this."

> "A saga allows us to recover from business failures, not technical failures."

> "If logic has a place where it can be centralized, it will become centralized!"

> "Making the core business processes of your system a first-class concept will have a host of advantages."

---

## Chapter 7: Build

### Principles and patterns

- **Continuous Integration (CI)**: frequently integrate code; CI server compiles, tests, creates artifacts. Build artifact once; store in repository; reuse for all deployments.
- **Continuous Delivery (CD)**: every check-in is a release candidate; model full path to production.
- **Continuous Deployment**: passing check-ins auto-deployed; no human gate.

### CI maturity gate (Jez Humble)

Three questions -- if any answer is "no," fix CI before adding more services:

1. Do you check in to mainline at least once per day?
2. Do you have tests that validate behaviour (not just compile)?
3. Is a broken build the team's #1 priority to fix?

### Trunk-based development

- Feature branches delay integration -> harder merges.
- Trunk-based: everyone on same trunk; feature flags hide incomplete work.
- DORA research: branches < 1 day lifetime, < 3 active branches, daily merge to trunk -> higher performance.

### Build pipeline stages

```
1. Compile
2. Fast tests -> BUILD ARTIFACT (once)
3. Deploy artifact -> slow tests
4. Deploy artifact -> performance tests
5. Deploy artifact -> staging/UAT (manual gate OK)
6. Deploy SAME artifact -> production
```

### Source code organisation

| Pattern | Mapping | Assessment |
|---------|---------|------------|
| **One repo + one build** | All services, one build | Worst for independent deployability |
| **Multirepo** | One repo per microservice | Author's preference at scale; 1:1 repo:service:build |
| **Monorepo** | Multiple services, one repo, folder->build mapping | Works for small teams or Google-scale tooling |

### Repo strategy decision

```
~5-20 devs, single team -> Monorepo OR multirepo (either fine)
Growing, cross-service changes frequent -> Multirepo (pain signals bad boundaries)
Large polyglot org without Google tooling -> Multirepo
Google/Facebook scale + dedicated platform team -> Monorepo + Bazel
```

### Anti-patterns

- **CI tool without CI practices** -- false confidence
- **Long-lived feature branches / GitFlow** for daily dev
- **Rebuilding artifact per environment** -- untested code may reach production
- **Config baked into artifact**
- **One repo + one build** for many services
- **Lockstep releases** via shared build
- **Constant cross-repo changes** -- wrong service boundaries

### Key quotes

> "Using a CI tool doesn't guarantee you're actually doing CI right."

> "Build an artifact once and once only... The artifact you verify should be the artifact you deploy!"

> "If you are constantly making changes across multiple microservices, it's likely that your microservice boundaries are in the wrong place."

> "So it's multirepos for me." -- Newman (at scale)

---

## Chapter 8: Deployment

### Principles and patterns

- **Logical vs physical topology**: multiple instances of same logical microservice share one database (not a violation; sharing is across instances of same service, not different services).
- Software moves through environments; build artifacts once; environment-specific config must be external.

### Five core deployment principles

1. **Isolated execution** -- each instance gets own compute resources.
2. **Focus on automation** -- essential as microservice count grows.
3. **Infrastructure as code** -- machine-readable, version-controlled, repeatable.
4. **Zero-downtime deployment** -- upstream consumers should not notice releases.
5. **Desired state management** -- declare desired state; platform maintains it.

### Deployment option selection (spectrum of abstraction)

Physical machine -> VM -> container -> application container -> PaaS -> FaaS/serverless.

### Sam's Rules of Thumb

1. **If it ain't broke, don't fix it.**
2. **Give up as much control as you feel happy with, then give away a little bit more.** Offload to PaaS/FaaS when possible.
3. **Containerise microservices** as default. Expect Kubernetes in your future for orchestration at scale.

### Decision table: deployment approach

| Decision | Guidance |
|----------|----------|
| Change deployment? | Only if current approach doesn't work (Rule 1) |
| How much control? | Offload to PaaS/FaaS when fit (Rule 2) |
| Default path | Containers; orchestration when scale warrants (Rule 3) |
| Cloud + FaaS workload | FaaS first, skip K8s |
| When to adopt K8s | After basics mastered; many processes to manage; prefer managed |
| Zero-downtime mechanism | Rolling upgrades / blue-green / K8s deployment |
| FaaS fit | Low/unpredictable load, short-running, stateless |

### Progressive delivery

Separate **deployment** (install to environment) from **release** (make available to users).

| Technique | Description |
|-----------|-------------|
| **Feature toggles** | Config-driven; start with config file; graduate to LaunchDarkly/Split |
| **Blue-green** | Two identical environments; switch traffic |
| **Canary releases** | Manual percentage ramp -> automated metric-driven ramp |
| **Parallel runs** | Old + new side-by-side; compare results |

### FaaS mapping

| Granularity | Assessment |
|-------------|------------|
| Function per microservice | Good starting point |
| Function per aggregate | OK if DDD aggregates diverge |
| Function per state transition | **Avoid** -- saga complexity at wrong granularity |

### Anti-patterns

- **Multiple microservices per host** without isolation
- **Kubernetes "because everyone else is"**
- **K8s for small teams/few services** -- huge overkill
- **Self-managed K8s without skilled platform team**
- **Function-per-state-transition** -- integrity violated
- **Retrofitting zero-downtime** onto architecture not designed for it
- **"Go fast and break stuff"** -- contradicted by Accelerate data

### Key quotes

> "The goal here is that upstream consumers shouldn't notice at all when you do a release."

> "If it ain't broke, don't fix it."

> "Deployment is what happens when you install some version of your software into a particular environment... Release is when you make a system or some part of it available to users." -- Jez Humble

---

## Chapter 9: Testing

### Principles and patterns

- Testing in microservices adds complexity: distributed calls, multiple deployables, cross-team boundaries.
- Balance: speed to production vs quality assurance.

### Test pyramid (Mike Cohn, adapted)

| Level | Scope | Speed | Volume |
|-------|-------|-------|--------|
| **Unit** | Single function/method | Fastest | Most numerous |
| **Service** | One microservice; stub externals | Medium | Medium |
| **End-to-end** | Full system via UI/API | Slowest | Fewest |

Target ratio: ~10x more tests descending the pyramid (e.g., 4000 unit : 1000 service : 60 E2E).

### Consumer-driven contracts (CDCs)

- Consumer writes tests specifying expected producer behaviour.
- Producer runs all consumer contracts on every build.
- Same pyramid level as service tests but different focus: cross-service compatibility.
- Catches semantic (not just structural) breakages.
- Use **Pact Broker** for contract storage, validation tracking, dependency mapping.
- CDCs replace most need for cross-team E2E tests.

### MTBF vs MTTR

- Cannot catch all problems preproduction in distributed systems.
- Optimizing mean time to repair (fast rollback + monitoring) may beat adding more functional tests.
- Accelerate: high performers test on-demand without integrated test environments.

### Production testing

| Technique | Description |
|-----------|-------------|
| **Synthetic transactions** | Inject fake users with known data; guard against side effects |
| **Canary releases** | Production validation with metric-driven automated ramp |
| **Parallel runs** | Old + new side-by-side comparison |

### Developer local setup

- Run only your team's microservices locally. Stub everything else.
- Never require running the full system locally.

### Flaky test remediation (Martin Fowler)

1. Track down flaky tests.
2. Can't fix immediately -> remove from suite.
3. Rewrite to avoid multi-threaded nondeterminism.
4. Stabilize environment.
5. Replace with smaller-scoped test.

### Anti-patterns

- **Test snow cone** (inverted pyramid) -- all coverage in E2E; glacial CI
- **Flaky tests left in suite** -- "normalization of deviance"; erodes trust
- **Dedicated E2E test team** -- distances developers from tests
- **The Great Pile-Up** -- long E2E breaks block deploys; changes accumulate
- **Metaversion / system versioning** -- couples services
- **Shared integrated test environments** -- constrained, fragile
- **Running all microservices locally** -- unsustainable at scale
- **Deferring performance testing** -- network multiplication makes latency critical

### Key quotes

> "If you currently carry out large amounts of manual testing, I would suggest you address that before proceeding too far down the path of microservices."

> "Now you have 2.1.0 problems." -- Brandon Byars, on system-wide versioning

> "Not testing in prod is like not practicing with the full orchestra because your solo sounded fine at home." -- Charity Majors

---

## Chapter 10: From Monitoring to Observability

### Principles and patterns

- **Observability**: property of the system -- extent to which internal state is understandable from external outputs. Observable systems have rich external outputs you can interrogate ad hoc.
- **Monitoring**: activity -- something we do (look at the system).
- **"Three pillars" critique** (metrics, logs, traces / MELT): overly reductive. Generic unifying concept: events. Project from event streams: traces, searchable indexes, aggregations.

### Building blocks (progressive implementation)

| Stage | What to implement |
|-------|-------------------|
| **Before any microservices** | Log aggregation |
| **Early** | Correlation IDs, host metrics, response times, downstream call logging |
| **Growing complexity** | Distributed tracing (managed preferred), high-cardinality tooling |
| **Mature** | SLOs/error budgets, semantic monitoring, synthetic transactions |

### Log aggregation

- **Prerequisite** for microservice architecture (organisational readiness test).
- Standard log format internally.
- **Correlation IDs**: generated at entry point, propagated through all calls, fixed position in log lines. Easy at the start, hard to retrofit.
- Clock skew: logs unreliable for ordering/causality across machines; use distributed tracing for accurate timing.

### Metrics

- Baselines over weeks/months to know "good" vs "bad."
- Aggregate at system, service, and instance levels with metadata tags.
- Standard metric names across all services.
- Low cardinality (Prometheus) vs high cardinality (Honeycomb/Lightstep).

### Distributed tracing

- Spans correlated by ID -> assembled into traces by central collector.
- OpenTracing/OpenTelemetry for instrumentation.
- Sampling required: all errors, sparse successes.
- Start with correlation IDs in logs; add tracing when complexity warrants.

### SRE concepts

| Concept | Definition |
|---------|------------|
| **SLA** | Agreement with users; minimum bar |
| **SLO** | Team-level objectives; achieving all SLOs exceeds SLAs |
| **SLI** | Measured indicator |
| **Error budget** | Allowed downtime/errors per period; enables risk decisions |

### Alerting (EEMUA criteria)

Good alerts must be: **Relevant, Unique, Timely, Prioritised, Understandable, Diagnostic, Advisory, Focusing**.

- Not all problems equal; ask "Should this wake someone at 3 a.m.?"
- Alert fatigue: Three Mile Island, 737 Max.
- Alert on **SLO violations**, not every metric threshold.

### Semantic monitoring

- "Is the system behaving as we expect?" not "Are there errors?"
- Synthetic transactions: inject fake user behaviour with known inputs/outputs.

### Anti-patterns

- **SSH/grep across hosts** as primary log strategy
- **Skipping log aggregation** -- "If your org can't implement this, microservices will likely overwhelm them"
- **No correlation IDs** -- painful to retrofit
- **Trusting log timestamps** for cross-service ordering
- **Three pillars checkbox mentality** -- buying tools without outcome focus
- **Alerting on every metric threshold** -- alert fatigue
- **Binary up/down health thinking**
- **Logging sensitive data** -- logs become attack targets
- **Inconsistent metric names** across services

### Key quotes

> "Before you do anything else to build out your microservice architecture, get a log aggregation tool up and running."

> "Once you have log aggregation, get correlation IDs in as soon as possible. Easy to do at the start and hard to retrofit later."

> "We replaced our monolith with micro services so that every outage could be more like a murder mystery."

---

## Chapter 11: Security

### Principles and patterns

- **Microservices security paradox**: increase attack surface (more network traffic, more infrastructure) but enable defense in depth (finer boundaries, limited scope, reduced blast radius).
- **Principle of least privilege**: grant minimum access needed, for minimum time needed.
- **Defense in depth**: multiple layered protections.
- **Shift-left security**: build into delivery from the start.

### Three types of security controls

1. **Preventative** -- encryption, auth, secure secrets storage
2. **Detective** -- firewalls, intrusion detection, log aggregation
3. **Responsive** -- automated rebuild, backups, comms plans

### NIST five functions

1. **Identify** -- attackers, targets, vulnerabilities
2. **Protect** -- safeguard assets
3. **Detect** -- know when breach occurs
4. **Respond** -- limit damage, communicate
5. **Recover** -- restore, learn

### Trust models

| Model | Description | When |
|-------|-------------|------|
| **Implicit trust** | Assume intra-perimeter calls safe | Common but risky; conscious decision |
| **Zero trust** | Assume compromised; verify every call | PII/secret data always |
| **Spectrum** | Vary by data sensitivity | Pragmatic default |

### Data classification

| Level | Example | Controls |
|-------|---------|----------|
| **Public** | Marketing pages | Minimal |
| **Private** | User profiles | Auth required |
| **Secret** | Health records, PII | Strictest; zero trust |

### Authentication and authorisation

- **OpenID Connect** for SSO (over SAML).
- Per-request JWTs at gateway; downstream services validate and authorise locally.
- Coarse-grained roles modeled on org structure.
- Fine-grained authorisation pushed into the owning microservice.

### JWT strategy

```
Per-request JWT at gateway (preferred)
IF authorization logic too complex for JWT -> JWT for coarse check + DB lookup for fine-grained
IF async flow exceeds token TTL -> scoped long-lived token OR stop using token mid-flow
```

### Secrets management

- Vault, K8s Secrets, AWS Secrets Manager. Never check keys into Git.
- Rotate frequently; automate rotation.
- Per-service, per-instance credentials. Time-limited tokens.

### CI security scanning

| Tool type | Examples |
|-----------|---------|
| Dependency scanning | Snyk |
| Secret scanning | gitleaks, git-secrets |
| Dynamic testing | ZAP |

### Anti-patterns

- **JWT/mTLS focus while ignoring basics** -- "secure front door, open back door"
- **Threat modeling only 1-2 services**
- **Shared broad-privilege credentials** across services
- **Checking keys into Git**
- **Backups in same cloud account** as production (Code Spaces incident)
- **Schrödinger backups** (never tested restore)
- **Implicit trust inside perimeter** (unconscious)
- **Centralized upstream authorization** -- breaks independent deployability
- **Long-lived JWTs** for async multi-day flows
- **Implementing your own encryption**
- **Storing encryption keys in same DB** as encrypted data

### Key quotes

> "You're only as secure as your least secure aspect."

> "Zero trust, fundamentally, is a mindset."

> "Friends don't let friends write their own crypto."

> "If you don't store it, no one can steal it."

---

## Chapter 12: Resiliency

### Principles and patterns

- **David D. Woods' four concepts of resilience**: robustness (absorb expected), rebound (recover after trauma), graceful extensibility (handle unexpected), sustained adaptability (continually adapt).
- Microservices primarily help robustness -- only one facet.
- **Resiliency is people, processes, and organisation**, not just software.
- At scale, failure is a **statistical certainty**, not an edge case.

### Stability patterns (mandatory)

| Pattern | When | Details |
|---------|------|---------|
| **Timeouts** | ALWAYS on all out-of-process calls | Set based on healthy p99 + SLA budget; include pool wait timeout |
| **Separate connection pools** | ALWAYS per downstream (bulkhead minimum) | One slow service must not exhaust all workers |
| **Circuit breakers** | ALWAYS on all synchronous downstream calls | Fail fast when downstream unhealthy; manually open during maintenance |

### Stability patterns (conditional)

| Pattern | When | Details |
|---------|------|---------|
| **Retries with backoff** | Transient failures | Factor retry time into total timeout budget |
| **Idempotency** | Before enabling retries on mutations | Include business keys |
| **Isolation** | Based on blast radius analysis | Separate hosts/containers/DB infra |
| **Redundancy** | All services | Multiple instances across AZs |

### Timeout formula

```
downstream_timeout = min(
  healthy_p99_response_time * safety_factor,
  user_facing_sla_remaining_budget
)
```

### Operation-level timeout budget

Pass remaining time to downstream calls. Skip retries if budget exhausted.

### Graceful degradation decision tree

```
FOR each user-facing flow:
  FOR each dependency:
    IF dependency down:
      WHAT is business-acceptable fallback?
        - hide feature
        - show stale/cached data
        - alternative channel (phone number)
        - close entire site (last resort)
```

### CAP per capability

```
IF stale_data_acceptable(duration) -> AP (eventually consistent)
ELIF consistency_required -> CP (accept unavailability during partition)
PER service, PER operation -> different trade-offs OK
Don't build your own CP datastore.
```

### Chaos engineering

- System = people + processes + culture + software + infrastructure.
- **Game Days**: surprise drills for people/processes.
- Running a chaos tool doesn't make you resilient.

### Anti-patterns

- **Shared HTTP connection pool** for all downstreams -- one slow service exhausts all workers
- **Disabled pool wait timeout** (default!) -- threads block forever; cascading failure
- **Long timeouts on user-facing paths** -- user refreshes -> duplicate requests -> amplifies load
- **Retrying without backoff** on overloaded service
- **Retries without idempotency** -- duplicate business effects
- **Sticky sessions** -- limits load balancing
- **Blame culture** -- hidden failures, repeat outages
- **Writing your own distributed consistent datastore**

### Key quotes

> "At scale, even if you buy the best kit, the most expensive hardware, you cannot avoid the fact that things can and will fail."

> "In a distributed system, latency kills."

> "Failing fast is always better than failing slow."

> "Friends don't let friends write their own distributed consistent data store."

> "Running a chaos engineering tool doesn't make you resilient."

---

## Chapter 13: Scaling

### Principles and patterns

- **Four axes of scaling** (Scale Cube + vertical): vertical, horizontal duplication, data partitioning, functional decomposition.

### Four axes (try in order)

| # | Axis | Description | Assessment |
|---|------|-------------|------------|
| 1 | **Vertical** | Bigger machine | Fastest; lowest risk on cloud; doesn't improve robustness |
| 2 | **Horizontal duplication** | Multiple copies + LB | Default for stateless services |
| 3 | **Data partitioning** | Shard by data attribute | When write-constrained; choose partition keys carefully |
| 4 | **Functional decomposition** | Extract independently scalable service | Highest code/data impact; try other axes first |

### Caching

- Cache in **as few places as possible**. Ideal = zero caches; add only with measured bottleneck.
- Prefer TTL as starting point. Don't nest caches without understanding compounded staleness.
- Never `Expires: Never` on HTTP responses unless intentional.
- Three purposes: performance, scale (reduce origin contention), robustness (serve stale if origin down).

| Location | Use when |
|----------|----------|
| Client-side | Optimizing end-to-end latency for one consumer |
| Server-side / shared | Many consumers, consistent cached view |
| Request cache | Specific expensive query repeated |

### Autoscaling

- **Predictive**: scale on known patterns.
- **Reactive**: scale on load spikes or instance failure.
- Start with **failure-based autoscaling** (min N instances). Add load-based only with validated data.
- Scale down cautiously -- better to have excess capacity.

### Anti-patterns

- **Premature optimization / scaling** -- complexity without measured need (Knuth)
- **Building for massive scale from day one** -- delays product validation
- **Vertical scaling for robustness** -- single point of failure remains
- **Sticky session load balancing**
- **Bad partition key** (surname A-M/N-Z) -- uneven load
- **Changing partition scheme** after the fact -- multi-day outages
- **CQRS/event sourcing** as first read-scaling move -- very complex
- **Autoscaling down too aggressively**

### Key quotes

> "Premature optimization is the root of all evil (or at least most of it) in programming." -- Donald Knuth

> "There are only two hard things in Computer Science: cache invalidation and naming things." -- Phil Karlton

> "The need to change our systems to deal with scale isn't a sign of failure. It is a sign of success."

---

## Chapter 14: User Interfaces

### Principles and patterns

- Move from channel-specific to **digital holistically**. The UI is where microservice capabilities are woven into customer experience.
- Traditional layered architecture + dedicated frontend team creates cross-team coordination for even simple UI changes.
- Preferred: **stream-aligned teams** own UI and backing services end-to-end.

### UI decomposition patterns

| Pattern | When |
|---------|------|
| **Monolithic frontend** | Single team; avoid with multiple teams |
| **Page-based decomposition** | Websites; different page groups served by different services |
| **Widget-based / micro frontends** | SPAs; independently deliverable frontend apps composed together |
| **Central aggregating gateway** | Single team only; avoid with multiple teams |
| **BFF per client type** | Multiple teams/clients; "One experience, one BFF" |
| **GraphQL** | Perimeter; client-specified queries; reduces server-side changes |

### BFF guidance

- "One experience, one BFF" (Stewart Gleadow).
- Shared BFF acceptable when same team owns all clients.
- Extract duplicated BFF logic into a new microservice at ~3 uses (rule of three).
- Keep domain logic in domain microservices; BFFs only aggregate, filter, route.

### Micro frontends

- Independently deliverable frontend applications composed into a greater whole.
- Use custom browser events for inter-widget communication.
- Monitor page weight with automated alerts.

### Consistency vs autonomy

Explicit organisational choice: shared style guides + UI components for polish (Financial Times model) vs accept inconsistency for delivery speed (Amazon model).

### Anti-patterns

- **Dedicated frontend team** when optimizing throughput -- handoff bottleneck
- **Monolithic frontend shared by multiple teams** -- contention
- **iFrames** for widget splicing -- sizing, communication, UX problems
- **Vendor API gateway for aggregation logic**
- **Shared libraries for BFF client code** -- coupling
- **Over-fetching** from microservices

### Key quotes

> "A stream-aligned team is a team aligned to a single, valuable stream of work... empowered to build and deliver customer or user value as quickly, safely, and independently as possible." -- Skelton & Pais

> "One experience, one BFF." -- Stewart Gleadow

> "Speed of delivery trumps a consistency of user experience, at least as far as AWS is concerned."

---

## Chapter 15: Organisational Structures

### Principles and patterns

- **Conway's Law**: system design mirrors organisational communication structure. Loosely coupled orgs -> modular systems.
- Microservices without organisational change blunt ROI.

### Accelerate checklist for loosely coupled teams

1. Make large-scale design changes without external permission?
2. Make large-scale design changes without depending on other teams?
3. Complete work without coordinating outside the team?
4. Deploy on demand regardless of dependencies?
5. Do most testing on demand without integrated test environments?
6. Deploy during business hours with negligible downtime?

### Team structure

- Optimal: **5-10 people**; productivity worst at >=9. Amazon two-pizza teams.
- **Strong ownership**: one team owns a microservice; controls code, standards, tech, deployment.
- **Full life-cycle ownership**: design -> build -> deploy -> operate -> decommission.
- **Collective ownership**: any team changes any service; requires high consistency; undermines independent deployability at scale.

### Enabling teams and platform

- Support stream-aligned teams in cross-cutting areas (security, UI, platform).
- Embed or consult; don't silo.
- **Paved road**: make the right way easy, not mandatory. Measure by adoption OKRs, not mandates.
- "You must use the platform" -> bypass and shadow IT.

### Shared microservices

- Default: one microservice, one team.
- **Internal open source**: core committers vet pull requests from untrusted committers.
- Many inbound PRs = consider ownership change or split.

### Anti-patterns

- Microservices **without org change** -- pay cost, miss benefits
- **Collective ownership at scale** -- high coordination
- **Copying Spotify/Amazon models** without understanding context
- **Platform mandates** -- bypass and noncompliance
- **External code review gates** -- lower delivery performance (Accelerate)
- **Ignoring geographical/time-zone boundaries**

### Key quotes

> "Organizations which design systems...are constrained to produce designs which are copies of the communication structures of these organizations." -- Melvin Conway

> "Adding manpower to a late software project makes it later." -- Fred Brooks

> "No matter how it looks at first, it's always a people problem." -- Gerry Weinberg

> "We didn't change our organisation because we wanted to use Kubernetes; we used Kubernetes because we wanted to change our organization." -- Paul Ingles

---

## Chapter 16: The Evolutionary Architect

### Principles and patterns

- **Architecture defined**: "Architecture is about the important stuff. Whatever that is." (Ralph Johnson). Architecture is a social construct -- shared understanding among expert developers.
- **Evolutionary architect** vs ivory tower: create a framework for emergence, not detailed plans. **Town planner metaphor** (Erik Doernenburg): define zones (constraints), not specific buildings.
- **System boundaries**: worry about what happens **between boxes**, be liberal **inside boxes**. Standardise integration; allow variation inside teams.
- **Habitability** (Richard Gabriel): source code understandable and changeable comfortably by later programmers.

### Principles, practices, and goals framework

| Level | Description |
|-------|-------------|
| **Strategic goals** | Where the business is going |
| **Principles** | < 10 rules aligning work to goals |
| **Practices** | Detailed, technology-specific; change more often |

### Good-citizen microservice standard

- **Monitoring**: standardised health/metrics emission; centralised logging.
- **Interfaces**: small number of integration styles (1-2 OK, 20 bad).
- **Architectural safety**: circuit breakers, proper timeouts, correct HTTP status codes (2XX/4XX/5XX).
- Correlation IDs propagated.

### Governance

- Group must be predominantly people doing the work.
- **Paved road** over policing.
- **Exemplars**: real running microservices that get things right. Optional templates; never mandated frameworks.
- **Fitness functions**: automated checks that architectural characteristics stay within bounds.
- **Technical debt**: conscious shortcuts vs vision drift. Make product owners accountable.
- **Exception handling**: log exceptions; enough exceptions -> update the principle.

### Core architect responsibilities

1. **Vision** -- clearly communicated technical vision
2. **Empathy** -- understand impact on customers and colleagues
3. **Collaboration** -- engage peers to define/refine/execute vision
4. **Adaptability** -- change vision as customers/org change
5. **Autonomy** -- balance standardisation vs team freedom
6. **Governance** -- system fits vision; make doing the right thing easy

### Anti-patterns

- **Ivory tower architect** -- detailed plans devoid of implementation understanding
- **Technology selected by non-users** -- uninhabitable systems
- **Mandated microservice frameworks** thrust on teams
- **DRY across microservices** via shared libraries -- coupling
- **Governance via platform mandate** -- bypass
- **Too many principles** -- overlap and contradiction

### Key quotes

> "Architecture is about the important stuff. Whatever that is." -- Ralph Johnson

> "Be worried about what happens between the boxes, and be liberal in what happens inside."

> "Habitability is the characteristic of source code that enables programmers coming to the code later... to change it comfortably and confidently." -- Richard Gabriel

> "Rules are for the obedience of fools and the guidance of wise men." -- Douglas Bader

> "It needs to be a cohesive system made of many small parts with autonomous life cycles but all coming together." -- Ben Christensen

---

## Afterword: Bringing It All Together

### Consolidated principles

- Don't leave UI monolithic while decomposing backend.
- Shift from horizontally siloed teams to stream-aligned teams supported by enabling teams.
- Platform = paved road: easy, optional, adoption-measured.
- Architecture is not fixed -- must continually change.
- Collaborative technical vision replaces ivory-tower architect.
- Architects/principal engineers: support, connect, spot patterns, embed with teams.

### Final warnings

- Many adopt microservices because "everyone else is," not because it fits.
- **Critical thinking** about fit > hype.
- You won't get all decisions right -- make each decision **small in scope** so mistakes are contained.
- Embrace **evolutionary architecture** -- series of changes over time, not big-bang rewrites.
- Microservices = journey, not destination; go incrementally.

> "Change is inevitable. Embrace it."

---

## Cross-Cutting Non-Negotiables

The following rules apply across all chapters. Flag any violation immediately during planning or review:

| # | Rule | Source |
|---|------|--------|
| 1 | Independent deployability is the north star | Ch 1, 7, 8 |
| 2 | No shared mutable databases across services | Ch 1, 2 |
| 3 | Business-domain boundaries, not tech-layer boundaries | Ch 2 |
| 4 | Information hiding at every boundary | Ch 1, 2, 5 |
| 5 | Monolith/modular monolith first; microservices with justified goal | Ch 1, 3 |
| 6 | Incremental migration; measure in production | Ch 3 |
| 7 | Pick communication style before technology | Ch 4, 5 |
| 8 | Reject content coupling and pass-through coupling aggressively | Ch 2 |
| 9 | One aggregate, one owner service | Ch 2 |
| 10 | Log aggregation + correlation IDs before scaling service count | Ch 1, 10 |
| 11 | Avoid long sync call chains (3+ services) | Ch 4 |
| 12 | Sagas over 2PC for cross-service state changes | Ch 6 |
| 13 | Timeouts on all external calls; circuit breakers on all sync calls | Ch 12 |
| 14 | Conway's law: align team and service boundaries | Ch 1, 15 |
| 15 | Evolutionary architecture: town planner, not building architect | Ch 16 |
