---
name: create-microservice
description: Build a new microservice from scratch, ensuring it meets all "good citizen" standards from Newman's Building Microservices. Plan mode for design, then Agent mode for implementation. Covers scope definition, boundary validation, API design, data ownership, workflows, deployment, good-citizen checklist, security, testing, and observability.
disable-model-invocation: true
---

# Create Microservice

Build a new microservice from scratch — from domain scoping through production-ready implementation. This command produces a service design plan in **Plan** mode, then implements it in **Agent** mode. Every step applies Sam Newman's *Building Microservices* principles via the **building-microservices** skill.

## Input

Accept **any** of the following:

1. **Business capability description** — what the service should own, who consumes it, and what success looks like.
2. **Ticket or design document** — Azure DevOps work item, tech design, or linked specification. Fetch via MCP when applicable.
3. **Constraints** — team ownership, timeline, regulatory scope, existing platform choices, non-functional requirements (latency, availability, scale).

When multiple inputs are provided, they supplement each other. If the scope is ambiguous, ask clarifying questions before proceeding.

## Steps

### 1. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. Steps 2–12 are read-only analysis, design, and planning — Plan mode keeps the focus on correct boundaries and interfaces before any code is written. Step 13 switches to **Agent** mode for implementation.

Apply the **objective-communication** skill to all deliverable prose in steps 2–12.

### 2. Define scope

Establish what business capability this microservice owns and the language the team will use to discuss it.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Modeling Boundaries**.
- Identify the **bounded context** this service represents. Document what is inside the boundary and what is explicitly outside.
- List the **aggregates** this service will own — real-world domain concepts with lifecycles and state machines (e.g. `Order`, `Subscription`, `Invoice`). Each aggregate has exactly one owning service.
- Document the **ubiquitous language**: terms, their precise meanings, and where the same real-world concept has different names in adjacent contexts (e.g. Customer vs Recipient).
- Answer explicitly: *What business capability does this service own?* State it in one sentence a product owner would recognise.
- Run a lightweight **event storming** exercise (desk exercise if domain experts are unavailable):
  1. **Events** (past-tense facts: `PaymentCaptured`, `AccountActivated`).
  2. **Commands** (actions that cause events).
  3. **Aggregates** (entities with lifecycle and state machines).
  4. Group into the bounded context for this service.
- Do **not** let the current (or imagined) implementation warp the domain model.

**Decision criteria:**

| Signal | In scope for this service | Out of scope |
|--------|---------------------------|--------------|
| Aggregate lifecycle | Owned here | Owned by another service |
| Ubiquitous language | Terms used within this context | Terms belonging to adjacent contexts |
| Change frequency | Features that change together | Unrelated capabilities bundled for convenience |

**Anti-patterns to flag:** CRUD wrapper with no domain behaviour; splitting one aggregate across services; three-tier horizontal layering disguised as a service boundary.

**Deliverable:** Scope document — bounded context definition, owned aggregates with state machines, ubiquitous language glossary, one-sentence capability statement.

### 3. Validate boundary

Challenge whether this should be a separate microservice or part of an existing one.

**What to do:**

- Read and apply the **building-microservices** skill, section: **North Star** and **Modeling Boundaries** (Boundary quality checklist, Coupling taxonomy).
- Run the **boundary quality checklist** for this candidate service:
  1. Can I change and deploy this service independently?
  2. Is related business behaviour co-located (strong cohesion)?
  3. Are cross-boundary assumptions minimised (loose coupling)?
  4. Is internal state hidden (information hiding)?
  5. Does one service own each aggregate's lifecycle/state machine?
- Apply the **monolith-first default**: ask explicitly — *Can this capability live in an existing service or modular monolith without undermining delivery goals?* Document the answer with evidence.
- Classify every planned relationship to other services by **coupling type**: domain, temporal, pass-through, common, content. Flag content coupling as never acceptable; flag common coupling (shared mutable state) for remediation.
- Record the **decomposition driver** that justifies a separate service (domain, volatility, data/security, technology, organisation).

**Decision criteria:**

| Outcome | Action |
|---------|--------|
| Boundary checklist passes; justified driver exists | Proceed as new microservice |
| Capability belongs in existing bounded context | Recommend extending existing service instead — stop this command |
| Independent deployability cannot be achieved | Redesign boundary or document explicit risk acceptance |
| Content or common coupling planned | Redesign before proceeding |

**Deliverable:** Boundary validation report — checklist results, coupling map, decomposition driver, explicit recommendation (new service / extend existing / reconsider decomposition).

### 4. Design API

Define the external interface other services and clients will depend on.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Communication Design**.
- For **every** external interaction this service exposes or consumes, document in order:
  1. **Business need** — what functionality or fact is being exchanged?
  2. **Communication style** — synchronous request-response or asynchronous event-driven?
  3. **Sync/async variant** — if request-response: blocking sync or async nonblocking?
  4. **Technology** — only after steps 1–3 (REST default for sync, gRPC when both ends controlled and performance matters, message broker for events).
- Apply the decision framework:
  - Need result before continuing? → Request-response.
  - Broadcasting a fact; consumers decide reaction? → Event-driven.
  - Short chain, simple system? → Sync blocking may be OK.
  - Long chain / availability decoupling? → Async nonblocking.
- Define **schemas** with explicit contracts:
  - REST → OpenAPI specification.
  - gRPC → protobuf definitions.
  - Events → AsyncAPI / CloudEvents payloads. Prefer fully detailed payloads over ID-only callbacks.
- Plan **versioning strategy**: expand-and-contract pattern, semantic versioning (MAJOR = breaking, MINOR = compatible, PATCH = fix).
- Apply **consumer-first design**: identify expected consumers, required client identifiers, and how breaking changes will be communicated.
- Plan **consumer-driven contracts** (Pact) where consumers are cross-team.
- Identify infrastructure needs: API gateway (north-south only), correlation ID propagation at every entry point.

**Decision criteria:**

- No interaction picks technology before style.
- No synchronous call chains longer than **two hops** (three services in series) without explicit justification.
- No shared domain object libraries across service boundaries.
- Keep pipes dumb, endpoints smart — no business logic in gateways, ESBs, or meshes.

**Deliverable:** API design document — interaction catalogue (style, pattern, technology, schema reference), OpenAPI/protobuf/AsyncAPI specs, versioning strategy, consumer list, CDC plan.

### 5. Design data ownership

Ensure this service owns its data exclusively and propagates facts to consumers appropriately.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Modeling Boundaries** (information hiding, Coupling taxonomy).
- Assign **one database per service** — this service owns its schema entirely. No shared tables, no cross-service foreign keys, no other service writing to this database.
- If analytics or reporting is needed:
  - Plan a **separate reporting database** (push model: events or ETL feed data out).
  - Do **not** grant other services read access to the operational database.
- Plan **event-driven data propagation** for consumers that need derived views:
  - Publish domain events with fully detailed payloads where possible.
  - Consumers maintain their own projections; this service does not query consumer databases.
- Document **data classification** per field (public, internal, confidential, restricted) for later security hardening.
- Apply **data frugality**: collect and store only the minimum data required for the service's capability.

**Decision criteria:**

| Pattern | Acceptable? | Notes |
|---------|-------------|-------|
| Own database, exclusive write access | Yes | Default |
| Read-only reference data replicated from another service | Sometimes | Must be explicitly read-only; source owns mutations |
| Shared mutable database | **Never** | Destroys independent deployability |
| Other service queries this service's DB directly | **Never** | Route through API or events |

**Deliverable:** Data ownership plan — database choice, schema outline, event publication catalogue, reporting/ETL approach if needed, data classification matrix.

### 6. Design workflows

Identify cross-service business processes this service participates in and define saga responsibilities.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Workflow and Sagas**.
- List every **cross-service business process** this service participates in (order fulfilment, onboarding, payment settlement, etc.).
- For each process, determine **saga participation**:
  - Is this service the **orchestrator** (one team owns the entire saga; need process visibility)?
  - Is this service a **participant** in a choreographed saga (multiple teams; loose coupling)?
- Define **local transactions** for this service's steps in each saga. Order steps optimally: fail-fast steps early, hard-to-compensate steps late.
- Define **compensating transactions** for every committable step this service performs. Compensations are semantic rollbacks (send cancellation email, not unsend).
- Plan **idempotent handlers** for every saga step and event consumer — duplicate delivery must not duplicate effects.
- Assign **correlation IDs** to every saga event this service emits or consumes — mandatory.
- **Never** plan 2PC/XA across microservices.

**Decision criteria:**

| Condition | Recommendation |
|-----------|----------------|
| One team owns entire saga | Orchestration OK |
| Multiple teams involved | Prefer choreography |
| This service only executes local steps | Participant |
| Need process visibility in one place | Orchestrator (if team owns full saga) |

**Anti-patterns:** mega-orchestrator absorbing domain logic; implicit processes hidden across services; choreography without correlation IDs.

**Deliverable:** Workflow catalogue — process name, saga style, this service's role (orchestrator/participant), step sequence, compensating actions, idempotency strategy, correlation ID plan.

### 7. Set up project

Plan repository structure, CI/CD, deployment, and infrastructure before writing domain code.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Build and Deployment**.
- Assess **CI maturity** (Jez Humble gate): daily mainline commits, behavioural tests, broken build is #1 priority. If any answer is no, plan CI fixes first.
- Define **repository strategy**: **multirepo default** — one repo = one microservice = one build. Cross-repo change pain signals wrong boundaries.
- Define **CI/CD pipeline** for this service:
  - Build artifact once (compile + fast tests → artifact → registry).
  - Deploy same artifact everywhere; never rebuild per environment.
  - Environment-agnostic artifacts with externalised config (DB URLs, log levels, feature flags).
- Choose **deployment model** using Sam's Rules of Thumb:
  - FaaS if workload fits → PaaS → containers + orchestration → VMs.
  - Don't adopt Kubernetes "because everyone else is."
- Plan **zero-downtime deployment**: rolling upgrades, blue-green, or orchestrator-native strategies. Separate deployment from release.
- Plan **progressive delivery**: feature toggles → canary → blue-green. Start with feature toggles.
- Use **trunk-based development** with feature flags for incomplete work.
- Plan **IaC** for infrastructure this service needs (database, message broker topics, secrets, networking).

**Decision criteria:**

- This service must deploy without deploying any other service.
- No lockstep releases, no metaversioning, no single repo + single build shared with other services.

**Deliverable:** Project setup plan — repo name/structure, CI/CD pipeline definition, deployment model, IaC outline, CI maturity assessment, progressive delivery approach.

### 8. Implement good-citizen checklist

Plan the operational baseline every microservice in the organisation must meet. This is the "by the book" core from Newman's good-citizen checklist.

**What to do:**

- Read and apply the **building-microservices** skill, sections: **Resiliency** and **Observability** (prerequisites), plus **Organisation and Architecture** (good-citizen checklist).
- Plan implementation of each mandatory item:

| Requirement | Implementation guidance |
|-------------|------------------------|
| **Health endpoint** | Standardised format across org (e.g. `/health` returning service name, version, dependency status). Used by load balancers and orchestrators. |
| **Structured logging** | JSON or structured format; **correlation ID** generated at entry point and propagated through all outbound calls; fixed position in log lines. |
| **Metrics emission** | Standard metric names across org; tag with service, instance, host. Emit request count, latency, error rate per endpoint. |
| **Circuit breakers** | On **ALL** outbound synchronous calls. Fail fast when downstream unhealthy. Manually openable for planned maintenance. |
| **Timeouts** | On **ALL** external calls — both call timeout and connection pool wait timeout. Set from healthy p99 and user-facing SLA budget. Pass operation-level timeout budget to downstream calls. |
| **Bulkhead (connection pools)** | Separate connection pool per downstream service. One slow downstream must not exhaust all workers. |
| **Idempotency keys** | On all mutation endpoints. Mandatory before enabling retries on mutations. |
| **Correct HTTP status codes** | 2XX success, 4XX client error (don't retry), 5XX server error (retryable for transient failures). Enables automated failure detection. |

- Build a **degradation matrix**: for each user-facing flow and each dependency, define the business-acceptable fallback (hide feature, stale cache, alternative channel).

**Decision criteria:**

- No synchronous outbound call without timeout + circuit breaker + separate pool.
- No mutation endpoint without idempotency support if retries are possible.
- Correlation IDs are easy at the start, hard to retrofit — implement from day one.

**Deliverable:** Good-citizen implementation checklist — concrete library/framework choices, configuration values, endpoint specs, metric names, logging format.

### 9. Implement security

Plan authentication, authorisation, secrets, and data protection before handling production data.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Security**.
- Perform a **threat model** for this service (include external parties for outside-in perspective).
- Define **authentication strategy**:
  - Validate JWTs **at this service**, not only at the gateway. Downstream services must not trust upstream blindly.
  - OpenID Connect for SSO where applicable.
- Define **authorisation strategy**:
  - Coarse-grained roles at gateway; fine-grained authorisation in this service for resources it owns.
- Plan **mTLS** for service-to-service communication in zero-trust contexts (PII/secret-classified data always gets zero trust).
- Plan **secrets management**: Vault, cloud secrets manager, or K8s Secrets. Never check keys into Git. Automate rotation.
- Apply **data classification** from step 5: encrypt confidential/restricted data at rest; TLS everywhere (internal too).
- Apply **least privilege**: per-service, per-instance credentials; time-limited tokens.
- Plan **CI security scanning**: dependency scanning, secret scanning (gitleaks/git-secrets), DAST where applicable.

**Decision criteria:**

- Defense in depth at every layer: preventative + detective + responsive.
- Centralized upstream authorization that breaks independent deployability is an anti-pattern.
- If you don't store PII, it can't be stolen — apply data frugality.

**Deliverable:** Security plan — threat model summary, auth/authz approach, mTLS requirements, secrets management, data classification enforcement, CI scanning setup.

### 10. Set up testing

Plan the test pyramid and contract verification before scaling consumer dependencies.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Testing Strategy**.
- Plan **unit tests** — most numerous; fastest feedback; run on file change. Target ~10× more unit tests than service tests.
- Plan **service tests** — test this microservice in isolation with **stubbed downstreams** (prefer stubs over mocks). Cover happy paths, error paths, and saga compensations.
- Plan **consumer-driven contracts (CDC)**:
  - Define contracts for each consumer of this service's API.
  - Verify producer contracts on every CI build (Pact Broker for storage and dependency mapping).
  - CDCs replace most need for cross-team E2E tests.
- Plan **performance test baseline** — establish p50/p95/p99 latency and throughput under expected load before production. Do not defer performance testing.
- Plan **developer local setup**: run only this service locally; stub everything else. Never require the full system locally.

**Decision criteria:**

| Test type | Relative volume | When it runs |
|-----------|-----------------|--------------|
| Unit | Highest | Every file change / commit |
| Service | Medium | Every CI build |
| CDC | Per consumer | Every CI build (producer side) |
| E2E | Lowest | Minimise; prefer CDC + production testing |

**Anti-patterns:** inverted test pyramid (test snow cone); flaky tests left in suite; shared integrated test environments required for local dev.

**Deliverable:** Testing plan — test structure, stub strategy, CDC contracts to define, performance baseline targets, CI test stages.

### 11. Plan observability

Ensure the service can be understood and operated in production from day one.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Observability**.
- Work with the product owner to define **SLOs** for this service: uptime target, p99 latency, error rate. Establish **error budgets** that gate risky changes.
- Plan **alerting** using EEMUA criteria: Relevant, Unique, Timely, Prioritised, Understandable, Diagnostic, Advisory, Focusing. Alert on SLO violations, not every metric threshold.
- Plan **semantic monitoring**: synthetic transactions for critical business flows this service owns ("Is the system behaving as we expect?" not just "Are there errors?").
- Plan **distributed tracing**: start with correlation IDs in logs (from step 8); add OpenTelemetry instrumentation when complexity warrants. Dynamic sampling: all errors, sparse successes.
- Confirm **log aggregation** is available organisationally — if not, flag as a blocker before production.

**Decision criteria:**

- If the organisation cannot implement log aggregation, microservices will overwhelm it — flag this as a blocker.
- Metrics must use standard names consistent with other services in the org.
- Never log sensitive data (PII, secrets, full request bodies with classified data).

**Deliverable:** Observability plan — SLO definitions, alerting rules, synthetic monitoring flows, tracing instrumentation plan, dashboard outline.

### 12. Validate

Cross-check the entire service design before switching to implementation.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Critical Anti-Patterns (Cross-Cutting)**.
- Verify **independent deployability**: can this service change, deploy, and release without deploying any other service?
- Confirm none of these exist in the design:
  1. Shared mutable database across services.
  2. Distributed transactions (2PC/XA) across microservices.
  3. Long synchronous call chains (3+ services in series).
  4. Content coupling (external service directly modifying this service's DB).
  5. Shared domain libraries across services.
  6. Metaversioning (system-wide version number).
  7. Smart middleware (business logic in gateways, ESBs, meshes).
  8. Missing circuit breakers on synchronous outbound calls.
  9. Missing correlation ID propagation.
  10. Incomplete good-citizen checklist (step 8).
- Re-run the **boundary quality checklist** from step 3.
- Review coupling taxonomy — no pass-through or common coupling without remediation plan.
- If any anti-pattern is present, either redesign to eliminate it or document explicit justification and accepted risk.

**Deliverable:** Validation report — checklist results, anti-pattern scan, independent deployability verification, open risks, go/no-go recommendation for implementation.

### 13. Switch to Agent mode

Transition from design to implementation.

**What to do:**

- Require **Agent** mode following the **mode-gate** skill. Verify the mode switch before proceeding.
- Present the complete design from steps 2–12 for user approval. Wait for approval, modifications, or questions.
- Once approved, implement following the **plan-execution** skill:
  1. Build a TODO list with one `[commit]` item per logical commit and `[action]` items for non-commit work.
  2. Execute items in order — one commit per `[commit]` item, validation before each commit.
  3. Implement in value-first order: project skeleton → domain logic → API → good-citizen baseline → security → tests → observability instrumentation.
  4. Do not batch commits; do not skip validation steps.

**Decision criteria:**

- Do not write production code in Plan mode.
- Do not mark the command complete until the good-citizen checklist, security baseline, tests, and observability instrumentation are implemented — not just planned.

**Deliverable:** Working microservice in its repository with CI passing, good-citizen endpoints operational, tests green, observability wired.

### 14. Evolve

Follow the **continuous-improvement** skill.
