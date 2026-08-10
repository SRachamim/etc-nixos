# Building Microservices (2nd Ed.) -- Chapters 5-7 Extraction

Sam Newman, *Building Microservices: Designing Fine-Grained Systems* (O'Reilly, 2021). Coverage: **Chapter 5** (Implementing Microservice Communication), **Chapter 6** (Workflow), **Chapter 7** (Build).

---

# Chapter 5: Implementing Microservice Communication

## 1. Key Concepts and Principles

### Technology selection is downstream of communication style
- Choose technology **after** deciding: synchronous vs. asynchronous, request-response vs. event-driven (Chapter 4 framework).
- Event-driven collaboration limits you to **nonblocking asynchronous** implementations.
- A single architecture (and single microservice) can **mix** communication styles.

### Ideal technology criteria
| Criterion | Meaning |
|-----------|---------|
| **Backward compatibility** | Adding fields/operations shouldn't break clients; validate compatibility before production |
| **Explicit interface** | Clear contract of what a microservice exposes; schemas + documentation |
| **Technology agnostic** | APIs must not lock you into a stack |
| **Simple for consumers** | Low adoption cost; client libraries are a trade-off |
| **Hide implementation detail** | Don't expose internal representations |

### Technology categories
- **RPC** (SOAP, gRPC, Java RMI): local call -> remote execution; explicit IDL/schema
- **REST**: resources + HTTP verbs; builds on HTTP capabilities
- **GraphQL**: client-defined queries; aggregation/filtering at perimeter
- **Message brokers**: async via queues (point-to-point) or topics (pub/sub)

### RPC core characteristics
- Serialization protocol bundled with framework
- Schema enables client/server stub generation
- **Local calls != remote calls** -- first fallacy of distributed computing: *the network is not reliable*

### REST core characteristics
- Resources decoupled from internal storage representation
- HTTP verbs have standard semantics (GET idempotent, POST creates, etc.)
- **HATEOAS**: hypermedia controls decouple client from URI structure
- HTTP ecosystem: caching (Varnish), load balancing, security, monitoring

### Message broker concepts
- **Queues**: point-to-point, competing consumers, sender knows destination
- **Topics**: broadcast, multiple consumer groups, sender unaware of subscribers
- **Guaranteed delivery**: broker holds messages until downstream available
- **Ordering**: often partition-scoped (e.g., Kafka per-partition)
- **Exactly-once delivery**: controversial; design consumers for **at-least-once** with idempotency

### Serialization
- **Textual**: JSON (dominant), XML, Avro (schema-in-payload)
- **Binary**: protocol buffers, Thrift, Cap'n Proto, FlatBuffers, SBE
- **Schemas**: structural vs. semantic contract breakages

### Versioning and change management
- **Semantic versioning**: MAJOR = breaking, MINOR = backward-compatible feature, PATCH = bug fix
- **Expansion changes**: add, don't remove
- **Tolerant reader** (Martin Fowler): consume only needed fields; Postel's law
- **Expand and contract pattern**: support old + new, then remove old

### Breaking change options
1. Lockstep deployment
2. Coexist incompatible microservice versions
3. Emulate old interface (preferred)

### Service discovery
- Registration + lookup; must handle disposable instances
- Options: DNS, ZooKeeper (avoid for this), Consul, etcd/Kubernetes, roll-your-own

### API gateways vs. service meshes
- **API gateway**: north-south (perimeter); reverse proxy + keys, rate limiting, developer portals
- **Service mesh**: east-west (in-perimeter); sidecar proxies on same host; mTLS, correlation IDs, load balancing
- Rule: **keep pipes dumb, endpoints smart**

### Self-describing systems
- **Humane registry**: lightweight wiki -> programmatic dashboards pulling live data
- OpenAPI, CloudEvents, AsyncAPI for documentation
- Examples: Financial Times Biz Ops, Spotify Backstage

---

## 2. Best Practices and Recommendations

### Technology choice
- Let **problem + communication style** guide technology -- don't pick tech first
- **REST over HTTP** is a sensible default for service-to-service sync request-response
- **gRPC** top choice for RPC when you control both ends; use Protolock for schema validation
- **GraphQL** at perimeter for mobile/constrained clients needing aggregation
- **Message brokers** for async; read broker docs carefully for guaranteed delivery setup
- Build consumers to handle **duplicate messages** (message ID deduplication)

### Schemas
- **Strongly favor explicit schemas** for microservice endpoints
- Use schema comparison tools that **pass/fail on compatibility** in CI:
  - Protolock (protocol buffers)
  - json-schema-diff-validator (JSON Schema)
  - openapi-diff (OpenAPI)
  - Confluent Schema Registry (JSON Schema, Avro, protobuf)
- Fail CI build on incompatible schema changes
- Use **consumer-driven contract testing** (Pact) for semantic breakages
- Document events with **CloudEvents** (CNCF) or AsyncAPI

### Avoiding breaking changes
- **Add only; don't remove** (expansion changes)
- Implement **tolerant readers** -- bind only to fields you need
- Use XPath/JSONPath to extract fields without tight structural coupling
- Pick technology that supports evolution (protocol buffer field numbers, Avro dynamic schema)
- Use **OpenAPI** for REST endpoint schemas
- Catch accidental breaks early in CI

### Managing breaking changes
- **Prefer endpoint emulation** (old + new in same service) over coexisting service versions
- Use expand-and-contract; internally chain V1->V2->V3 transformations
- Route via version in URI (`/v1/customer/`) or headers
- For RPC: namespace methods (`v1.createCustomer`, `v2.createCustomer`)
- Coexisting versions OK for **short periods** (canary, blue-green) -- not weeks
- Establish **social contract** with consumers: how to raise changes, who does work, migration timeline
- **Consumer-first approach**: microservices exist to be consumed
- Log endpoint usage; require client identifiers (user-agent, API gateway keys)
- Track whether old interfaces are still used before removal

### Code reuse
- Shared libraries OK for **internal/invisible** concerns (logging)
- **Copy service templates** rather than share domain object libraries across services
- Accept multiple library versions in flight; redeploy each microservice independently
- For cross-boundary reuse needing atomic rollout -> dedicated microservice, not library

### Client libraries
- Separate transport concerns (discovery, failure) from domain API
- **Clients control upgrade timing**
- AWS model: SDKs maintained separately from API team
- Don't mandate client libraries if you want technology freedom

### Service discovery
- **DNS + load balancer** for multi-instance; avoid DNS round-robin (can't eject sick hosts)
- **Consul** for dynamic registration; SRV records; health checks; consul-template for dynamic config
- **Kubernetes** service discovery built-in for K8s workloads
- Dedicated tool (Consul) for mixed K8s + non-K8s environments
- Don't roll your own -- mature tooling exists
- Expose discovery data to **humans** via humane registries

### API gateways
- Be clear on requirements; avoid over-featured gateways
- For K8s ingress: focused products like **Ambassador**
- Separate gateways for different concerns if needed
- Use for: north-south access, API keys, rate limiting, logging
- **Don't** use for call aggregation (use GraphQL/BFF/saga)
- **Don't** use for protocol rewriting (SOAP->REST)
- **Don't** insert gateway between all east-west microservice calls (latency, tickets, handoffs)

### Service meshes
- Generic behavior only: mTLS, timeouts, correlation IDs, load balancing
- Per-service config via self-service (e.g., Istio service definitions)
- Per-microservice timeout configuration
- Evaluate when: many microservices, multiple languages, K8s platform
- **Skip** if only ~5 microservices
- Do homework -- switching meshes is painful
- Meshes don't cover broker protocols (Kafka bypasses mesh)

### Documentation
- Schemas reduce but don't replace behavioral documentation
- Auto-discover OpenAPI endpoints (Ambassador Developer Portal)
- Build humane registries pulling: health, correlation IDs, Consul, OpenAPI, CloudEvents
- Start with wiki; enrich with live data over time
- System Operability Score (FT model): enforce operability practices

---

## 3. Anti-Patterns and Warnings

| Anti-pattern | Why it's bad |
|--------------|--------------|
| Picking technology before communication style | Wrong tool for the job |
| Hiding the network in RPC abstractions | Surprise latency, failure modes, brittleness |
| **Java RMI** | Technology coupling, binary stub brittleness, lockstep releases |
| **SOAP** | Heavyweight vs modern RPC |
| Treating REST API as database wrapper (GraphQL/OData trap) | Anemic services, tight datastore coupling |
| Expensive GraphQL queries without throttling | Server overload; hard to diagnose vs SQL |
| Assuming GraphQL caching like REST | CDN/caching reverse proxies difficult |
| GraphQL for writes | Often hybrid GraphQL-read + REST-write |
| HATEOAS for microservices | Rarely practiced; chatty; concepts don't fit well |
| **Lockstep deployment** for breaking changes | Destroys independent deployability -> distributed monolith |
| **Coexisting service versions** long-term | Branch codebase, routing complexity, shared state hell; Netflix uses rarely |
| Coexisting 3+ endpoint versions | Heavy burden (author's experience -- not recommended) |
| Shared domain object libraries across services | One change -> redeploy all; queue draining |
| Client libraries with leaked server logic | Coupling; multiple client changes per server fix |
| Mandating client libraries | Technology lock-in |
| DRY across microservice boundaries | Coupling; coordinated deployments |
| API gateway call aggregation + business logic | Business process in wrong layer; ticket-driven changes |
| API gateway protocol rewriting | REST is mindset, not proxy feature |
| Smart pipes (ESB/gateway bloat) | Handoffs, coordination, slowed delivery |
| API gateway for all east-west traffic | Extra hop, latency, central bottleneck |
| Smart service mesh (business logic in mesh) | Same as ESB problems |
| Service mesh with ~5 services | Unjustified complexity |
| Rolling your own service discovery | Reinventing worse wheel |
| Stale documentation without schemas | Hard to detect drift |
| Trusting "exactly once" blindly | Build idempotent consumers anyway |
| Catastrophic failover (infinite retry without max) | Worker death loops |
| No dead letter queue / message hospital | Poison messages block system |
| Premature binary serialization optimization | Profile first; send less data, make fewer calls |
| Schemaless endpoints | Implicit schema in consumer code; testing burden |

---

## 4. Decision Frameworks and Heuristics

### Technology selection flow
```
1. Request-response or event-driven?
   -> Event-driven -> async nonblocking only
2. If request-response: sync or async?
3. Apply requirements: latency, security, scale, client diversity
4. Match to technology (Figure 5-10 in book)
5. Validate: backward compat, explicit schema, tech agnostic
```

### RPC vs REST vs gRPC
| Situation | Recommendation |
|-----------|------------------|
| Wide variety of external clients | REST over HTTP |
| Perimeter + caching + external APIs | REST |
| Control both client and server; performance | gRPC |
| Low-latency binary needs | gRPC or binary RPC |
| Compile client against server schema problematic | REST, not gRPC |

### GraphQL
| Use | Don't use |
|-----|-----------|
| Perimeter, mobile, multi-call aggregation | General microservice-to-microservice comms |
| External API needing efficient multi-resource fetch | Replace internal service mesh |

### Queue vs topic
| Pattern | Use |
|---------|-----|
| Queue | Request/response, competing consumers, known destination |
| Topic | Event broadcast, multiple independent consumers |

### Breaking change strategy
| Situation | Approach |
|-----------|----------|
| Same team owns service + all consumers | Lockstep OK as one-off |
| Need consumer migration time | Emulate old endpoint (preferred) |
| Canary/blue-green (minutes-hours) | Coexist versions briefly |
| Legacy devices (Netflix set-top boxes) | Coexist versions (rare, costly) |

### Service discovery
| Situation | Choice |
|-----------|--------|
| Single node per service | DNS direct to host |
| Multiple instances | DNS -> load balancer |
| Highly dynamic/disposable hosts | Consul or K8s native |
| Mixed K8s + non-K8s | Dedicated tool (Consul) |

### API gateway vs service mesh
| Traffic | Tool |
|---------|------|
| North-south (external -> internal) | API gateway (simple, focused) |
| East-west (service -> service) | Service mesh (sidecar on same host) |
| Call aggregation | GraphQL, BFF, or saga -- not gateway |

---

## 5. Key Quotes

> *"Make Backward Compatibility Easy"* -- technology must enable safe evolution

> *"Keep Your APIs Technology Agnostic"* -- *"The one certainty is change."*

> *"The first of the fallacies of distributed computing is 'The network is reliable'."*

> *"Local calls are not like remote calls"*

> *"REST over HTTP is a sensible default choice for service-to-service interactions."*

> *"Don't slip into thinking of your microservices as little more than an API on a database."* (GraphQL warning)

> *"Keeping the pipes dumb, and the endpoints smart."*

> Postel's law: *"Be conservative in what you do, be liberal in what you accept from others."*

> *"One of the secrets to an effective microservice architecture is to embrace a consumer-first approach."*

---

## 6. Actionable Guidance for Developers/Architects

1. **Before choosing gRPC/REST/Kafka**: document communication style (sync/async, req-resp/event) per integration point.
2. **Define OpenAPI or protobuf schemas** for every endpoint; add CI compatibility check (Protolock, openapi-diff, Schema Registry).
3. **Add Pact or CDC tests** for semantic compatibility; fail build on consumer breakage.
4. **Implement tolerant readers**: parse only required fields; ignore unknown fields.
5. **Never remove fields** without deprecation cycle; use expand-and-contract.
6. **For breaking changes**: deploy new endpoint alongside old in same service; track usage via logs/client IDs; remove old after agreed deadline.
7. **Avoid shared domain libraries** across services; copy templates; reuse only infra libraries (logging, metrics).
8. **If using client SDKs**: separate transport from API; never mandate; clients choose upgrade timing.
9. **Configure dead letter queues** and max retry limits on all async consumers.
10. **Make consumers idempotent** (message IDs) regardless of broker exactly-once claims.
11. **API gateway**: north-south only; minimal features; no business logic; no east-west proxying.
12. **Service mesh**: generic cross-cutting only (mTLS, timeouts, tracing); per-service timeout in service config.
13. **Service discovery**: Consul or K8s; DNS->LB for static; don't build custom.
14. **Humane registry**: aggregate OpenAPI, health checks, ownership, operability score from live systems.
15. **GraphQL**: perimeter/BFF layer only; throttle expensive queries; don't couple schema to DB schema.
16. **Monitor correlation IDs** across calls.
17. **Document social contract** per service: breaking change process, timelines, ownership.

---

# Chapter 6: Workflow

## 1. Key Concepts and Principles

### The core problem
- Multiple microservices collaborating on a **business process**
- Local ACID transactions per microservice; **no cross-service atomicity** by default
- Decomposing monolith -> lose guaranteed atomicity across services

### ACID (local)
- **Atomicity, Consistency, Isolation, Durability** -- each microservice uses ACID for its own DB
- Scope reduced to single microservice boundary

### Distributed transactions (2PC)
- **Two-phase commit**: voting phase -> commit phase
- Workers **lock resources** during voting to guarantee future commit
- Loses isolation -- intermediate states visible across workers
- Coordination of distributed locks; deadlock risk
- Many failure modes require manual operator intervention
- Latency grows with participants and transaction duration
- Used only for **very short-lived** operations

### Sagas
- Coordinate multiple state changes **without long-term locking**
- Model business process as **sequence of independent transactions**
- Originally for long-lived transactions (LLTs); applies equally to multi-service workflows
- **No saga-level atomicity** -- only per-step atomicity
- Provides enough state to **reason about saga progress** and handle implications
- Explicit business process modeling = major benefit

### Saga failure recovery
| Mode | Mechanism |
|------|-----------|
| **Backward recovery** | Compensating transactions (semantic rollback) |
| **Forward recovery** | Retry from failure point; requires persisted retry state |

### Business vs. technical failures
- **Business failure** (insufficient funds): saga handles via compensating flow
- **Technical failure** (timeout, 500): handle separately; saga assumes reliable components

### Compensating transactions
- Undo **already committed** steps -- not time travel
- **Semantic rollbacks**: can't unsend email; send cancellation email instead
- Rollback information may persist intentionally (audit)

### Orchestrated vs. choreographed sagas
| | Orchestration | Choreography |
|---|---------------|--------------|
| Style | Command-and-control | Trust-but-verify |
| Coordination | Central orchestrator | Distributed event reactions |
| Coupling | Higher domain coupling | Lower domain coupling |
| Visibility | Process explicit in one place | Hard to see full process |
| Communication | Request-response heavy | Events heavy |
| State tracking | Built into orchestrator | Needs correlation ID + event projection |

### Mixing styles
- Different processes can use different styles
- Single saga can mix (e.g., choreographed overall, orchestrated inside Warehouse)
- Must always know **saga state** and completed activities

---

## 2. Best Practices and Recommendations

### Avoid distributed transactions
- **Strongly avoid 2PC** across microservices
- If state needs true ACID atomicity -> **keep in single database, single service** (or monolith)
- Defer splitting transactional data until you have a saga strategy

### Saga design
- **Explicitly model business processes** as first-class concepts
- Align saga boundaries with **domain-driven microservice boundaries**
- Define **compensating actions** for each committable step
- **Reorder workflow steps** to minimize rollback scope:
  - Award loyalty points **after dispatch**, not before packaging
  - Pull failure-prone steps **earlier** to fail fast
  - Move hard-to-compensate steps **later** so they never need rollback
- Mix fail-backward and fail-forward appropriately (dispatch failure -> retry, not full rollback)
- Persist enough state for **forward recovery retries**
- Keep rollback audit data in Order service (or equivalent)

### Orchestrated sagas
- Explicit process in orchestrator aids onboarding and understanding
- Use **different orchestrators per flow** (Order Processor, Returns, Goods Receiving) to avoid mega-orchestrator
- Services remain **stateful entities with local state machines** -- not anemic pass-throughs
- If developers implement processes -> **use code**, not BPM GUI tools
- If exploring BPM: **Camunda, Zeebe** (developer-friendly orchestration)

### Choreographed sagas
- Services react to events; **don't send events to specific services** -- broadcast and subscribe
- Use **topics** for multi-consumer events
- **Correlation ID on every saga event** -- essential
- Build **projection service** consuming all events to track saga state and trigger compensations
- Prefer when **multiple teams** own saga steps

### Decision: orchestration vs. choreography
| Condition | Recommendation |
|-----------|----------------|
| One team owns entire saga | Orchestration OK |
| Multiple teams involved | Prefer choreography |
| Team unfamiliar with events | Orchestration may be easier |
| Need loose coupling + team isolation | Choreography |

---

## 3. Anti-Patterns and Warnings

| Anti-pattern | Problem |
|--------------|---------|
| **2PC across microservices** | Locks, latency, wedged apps, manual recovery, availability decreases with scale |
| Assuming saga gives ACID atomicity | It doesn't -- design for partial completion |
| Treating technical failures as saga business failures | Timeouts/500s need separate handling |
| Full rollback when only dispatch fails | Retry/queue/human intervention instead |
| **Mega-orchestrator** absorbing service logic | Anemic services; centralized business logic |
| **Traditional BPM tools** for developer-implemented flows | GUI-only changes, no version control, untestable |
| Choreography without correlation IDs | Can't track saga state or trigger compensations |
| Choreography without event projection | No central saga status visibility |
| Implicit business processes | Hidden in code across services; hard to understand/debug |
| Splitting transactional data without saga plan | Data inconsistency |

---

## 4. Decision Frameworks and Heuristics

### Distributed transaction vs. saga vs. don't split
```
Need atomic cross-service state change?
|- Can it stay in one DB/service? -> YES: don't split
|- Short-lived + willing to accept 2PC pain? -> Rarely: 2PC (avoid)
\- Long-lived or multi-service -> Saga
```

### Orchestration vs. choreography
```
Who owns the saga?
|- Single team -> Orchestration (relaxed)
\- Multiple teams -> Choreography (preferred)
```

### Failure handling per step
```
Step failed -- what kind?
|- Business rule (insufficient funds) -> Compensating transaction chain
|- Transient technical -> Retry (forward recovery)
|- Late-stage non-critical (dispatch) -> Retry/queue, not full rollback
\- Early-stage likely failure -> Reorder step earlier to fail before side effects
```

---

## 5. Key Quotes

> *"A saga does not give us atomicity in ACID terms... What a saga gives us is enough information to reason about which state it's in; it's up to us to handle the implications of this."*

> *"A saga allows us to recover from business failures, not technical failures."*

> *"If logic has a place where it can be centralized, it will become centralized!"*

> *"If you don't have a place where logic can be centralized, then it won't be centralized!"* (choreography benefit)

> *"Making the core business processes of your system a first-class concept will have a host of advantages."*

---

## 6. Actionable Guidance for Developers/Architects

1. **Never use 2PC** across microservices; flag any XA/2PC middleware in architecture reviews.
2. Before splitting transactional data: ask *"Can saga + compensations handle this?"* -- if no, defer split.
3. **Draw saga as explicit flowchart** with steps, compensations, and failure modes per step.
4. **Assign correlation ID** at saga start; propagate through all events/calls/logs.
5. For choreographed sagas: build **saga state projection service** from event stream.
6. **Reorder steps**: payment/reservation early; irreversible actions (email, loyalty) late.
7. Implement **idempotent step handlers** (safe retries for forward recovery).
8. Separate **business failure handlers** from **retry/circuit-breaker** for technical failures (Chapter 12).
9. **One orchestrator per business capability** -- not one god orchestrator.
10. Keep domain logic in services; orchestrator only coordinates -- resist logic creep.
11. Document compensating actions explicitly; test rollback paths, not just happy path.

---

# Chapter 7: Build

## 1. Key Concepts and Principles

### Continuous Integration (CI)
- Frequently integrate checked-in code with existing codebase
- CI server: compile, test, create artifacts
- **Build artifact once**; store in repository; reuse for all deployments
- Trace deployed artifact -> source code -> tests run
- Infrastructure-as-code versioned alongside service code

### Are you really doing CI? (Jez Humble's 3 questions)
1. Check in to mainline **at least once per day**
2. Have tests that **validate behavior** (not just compile)
3. Broken build = **#1 team priority** to fix

### Trunk-based development vs. feature branching
- Feature branches **delay integration** -> harder merges
- Trunk-based: everyone on same trunk; **feature flags** hide incomplete work
- DORA research: branches < 1 day lifetime, < 3 active branches, daily merge to trunk -> higher performance

### Build pipelines
- Multiple stages: fast tests first, slow tests later
- Same **artifact** progresses through pipeline
- CD: every check-in is a **release candidate**; model full path to production

### Continuous Delivery vs. Continuous Deployment
| CD | Continuous Deployment |
|----|----------------------|
| Every check-in validated as release candidate | Passing check-ins auto-deployed |
| Human gate for production OK | No human gate |

### Source code organization patterns
| Pattern | Mapping |
|---------|---------|
| **One giant repo + one giant build** | All services, one build -- worst for independent deployability |
| **Multirepo** (one repo per microservice) | 1:1 repo:service:build |
| **Monorepo** | Multiple services in one repo; folder->build mapping; graph builds (Bazel) |

### Ownership models (Fowler, revised)
- **Strong**: outsiders must ask owners to change
- **Weak**: outsiders can change; owners review/accept (PR model)
- **Collective**: anyone changes anything (~<=20 developers)

---

## 2. Best Practices and Recommendations

### CI/CD
- Actually **do CI** (3 questions), not just install Jenkins/CircleCI/Travis
- **Trunk-based development** preferred; feature flags for incomplete features
- If branches needed: **keep short** (< 1 day)
- Use **CD-native tooling** (not hacked CI tools)
- **Fix broken builds immediately** -- stop non-fix check-ins

### Artifacts
- Build once after compile + fast tests
- Same artifact through slow tests, perf tests, production
- Externalize per-environment config (log levels, DB URLs, etc.)
- Don't rebuild for production

### Multirepo (author's preference at scale)
- One repo per microservice; change triggers matching build only
- Per-repo ownership aligned with team boundaries
- Stage cross-service API changes: deploy provider first, then consumer
- Cross-repo change pain -> **signals wrong boundaries**; consider merging services

### Monorepo
- Works well: **10-20 developers** or **massive tech companies** with dedicated tooling
- Per-team monorepo: good middle ground for collective ownership teams
- Map folders -> builds; common folder changes trigger all rebuilds
- Use **Bazel** for complex dependency graphs
- **CODEOWNERS** (GitHub) for weak/strong ownership in monorepos

---

## 3. Anti-Patterns and Warnings

| Anti-pattern | Problem |
|--------------|---------|
| CI tool without CI practices | False confidence |
| Long-lived feature branches / GitFlow for daily dev | Delayed integration, merge hell |
| Rebuilding artifact per environment | Untested code may reach production |
| Config baked into artifact | Same binary can't traverse pipeline |
| **One repo + one build** for many services | One-line change rebuilds/tests all; broken build blocks everyone |
| Lockstep releases via shared build | Destroys independent deployability |
| Monorepo at scale without Bazel/graph tooling | Rebuild chaos |
| Monorepo encouraging cross-service changes | Coupling; confused ownership |
| Constant cross-repo changes | Wrong service boundaries |
| Copying Google/Microsoft monorepo without their tooling budget | Not replicable |

---

## 4. Decision Frameworks and Heuristics

### Are you doing CI?
```
[] Check in to mainline >= daily?
[] Behavioral test suite exists?
[] Broken build stops all other work?
-> All yes = CI. Any no = fix before microservices.
```

### Repo strategy
```
Team size / scale?
|- ~5-20 devs, single team -> Monorepo OR multirepo (either fine)
|- Growing, cross-service changes frequent -> Multirepo (pain signals bad boundaries)
|- Large polyglot org without Google tooling -> Multirepo (author's pick)
\- Google/Facebook scale + dedicated platform team -> Monorepo + Bazel
```

### Pipeline design
```
Stage ordering:
1. Compile
2. Fast tests -> BUILD ARTIFACT (once)
3. Deploy artifact to env -> slow tests
4. Deploy artifact -> perf tests
5. Deploy artifact -> staging/UAT (manual gate OK)
6. Deploy SAME artifact -> production
```

---

## 5. Key Quotes

> *"Using a CI tool doesn't guarantee you're actually doing CI right."*

> *"Integrate early, and integrate often. Avoid long-lived branches; consider trunk-based development."*

> *"Build an artifact once and once only... The artifact you verify should be the artifact you deploy!"*

> *"Keep your deployment artifact environment-agnostic--store environment-specific configuration elsewhere."*

> *"Atomic commits across multiple services doesn't give you atomic rollout."*

> *"If you are constantly making changes across multiple microservices, it's likely that your microservice boundaries are in the wrong place."*

> *"Your organization probably isn't Google and probably doesn't have Google-type problems, constraints, or resources."*

> Author: *"So it's multirepos for me."* (at scale)

---

## 6. Actionable Guidance for Developers/Architects

1. **Validate CI maturity** with Humble's 3 questions before scaling microservices.
2. Adopt **trunk-based development**; use feature flags; ban long-lived feature branches.
3. Pipeline: **fast tests -> build artifact once -> store in registry -> deploy same artifact everywhere**.
4. Externalize all environment config; never rebuild between stages.
5. Choose **multirepo** (1 repo = 1 microservice = 1 build) unless small team (<20) or Google-scale tooling.
6. Never use **one repo + one CI build** for independently deployable services (except day-1 prototype).
7. Cross-service API changes: **deploy provider first**, then consumer -- two commits, two deploys.
8. If cross-repo changes are frequent -> **architecture review** for boundary realignment or service merge.
9. Library shared across services: version as artifact; accept staggered rollout; never expect atomic update.
10. Broken build: **stop the line** -- no new check-ins until green.

---

# Cross-Chapter Themes (Chapters 5-7)

| Theme | Rule |
|-------|------|
| **Independent deployability** | Never lockstep deploy; never one giant build; atomic commit != atomic deploy |
| **Explicit contracts** | Schemas, social contracts, explicit sagas, explicit APIs |
| **Consumer-first** | Backward compat, tolerant readers, migration time, track usage |
| **Pipes dumb, endpoints smart** | No business logic in gateways, ESBs, or meshes |
| **Information hiding** | Hide DB/internal types; don't share domain libraries |
| **Explicit business processes** | Sagas over 2PC; model workflows first-class |
| **Integration frequency** | Trunk-based, daily merge, short branches, fix builds immediately |
| **Build once, deploy many** | Same tested artifact to all environments |
| **Boundaries signal pain** | Cross-service changes, cross-repo pain, cross-team sagas -> revisit decomposition |
| **Technology follows style** | Communication pattern before gRPC/REST/Kafka choice |
