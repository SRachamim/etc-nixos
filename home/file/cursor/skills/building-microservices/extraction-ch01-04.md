# Building Microservices (2nd Ed.) -- Chapters 1-4 Extraction

Sam Newman, *Building Microservices: Designing Fine-Grained Systems* (O'Reilly, 2021). Coverage: **Part I: Foundation** -- Chapters 1-4.

---

# Chapter 1: What Are Microservices?

## 1. Key Concepts and Principles

**Definition**
- Microservices are **independently releasable services modeled around a business domain**
- A service encapsulates functionality and exposes it via **network endpoints** (REST, queues, etc.)
- Technology-agnostic; consumers access via networked interfaces only
- A type of **SOA**, but opinionated about boundaries and **independent deployability**
- Treated as a **black box** from outside; internal implementation hidden

**Information hiding (Parnas)**
- Hide as much as possible inside; expose as little as possible via interfaces
- Enables **independent releasability**, **looser coupling**, **stronger cohesion**
- Related to **Hexagonal Architecture** (Cockburn): separate internal implementation from external interfaces

**Core concepts**
| Concept | Meaning |
|--------|---------|
| **Independent deployability** | Change, deploy, and release one microservice without deploying others; this is the default release discipline |
| **Modeled around business domain** | Use DDD; end-to-end business slices, not horizontal tech layers |
| **Owning their own state** | Each service encapsulates its own database; no shared DBs in most cases |
| **Size** | Least interesting aspect; "as big as your head" (understandable); "as small an interface as possible" (Richardson) |
| **Flexibility** | "Microservices buy you options" (James Lewis)--at a cost; turn a dial, not flip a switch |

**SOA vs microservices**
- SOA failed due to SOAP, vendor middleware, wrong granularity guidance, shared DBs, deploy-together coupling
- Microservices = **specific approach to doing SOA well** (like XP/Scrum to Agile)

**Architecture <-> organization (Conway's Law)**
- Three-tier architecture mirrors **tech-siloed teams** (DBAs, Java devs, frontend)
- Microservices align with **poly-skilled, stream-aligned teams** owning end-to-end slices
- **Team Topologies**: stream-aligned team = one valuable stream, empowered to deliver without handoffs

**Monolith types**
| Type | Definition |
|------|------------|
| **Single-process monolith** | All code deployed as one process |
| **Modular monolith** | Separate modules, combined for deployment; good parallel work, simpler ops (Shopify example) |
| **Distributed monolith** | Multiple services but **must deploy together**; worst of both worlds (Lamport quote on distributed failure) |

**Delivery contention**
- More people in one codebase -> conflicts, deployment fights, confused ownership
- Microservices provide **concrete ownership boundaries**

**Enabling technology** (intro only)
- Log aggregation + correlation IDs; distributed tracing (Jaeger, Honeycomb, Lightstep)
- Containers/Kubernetes (don't rush; use managed K8s)
- Streaming (Kafka, Flink, Debezium)
- Public cloud / serverless / FaaS

**Advantages**
- Technology heterogeneity; robustness (bulkheads); targeted scaling; ease of deployment; organizational alignment; composability (multiple channels)

**Pain points**
- Developer experience (can't run all services locally); technology overload; cost; reporting; monitoring; security; testing; latency; data consistency

---

## 2. Best Practices and Recommendations

- **#1 takeaway**: Embrace **independent deployability** as a forcing function
- **Don't share databases** unless absolutely necessary--and avoid even then
- Focus on **how many services you can handle** and **boundary definition**, not size
- **Incremental adoption**--turn the dial gradually
- Organize around **business functionality cohesion**, not tech-layer cohesion
- **Monolith is the sensible default**; look for reasons to use microservices, not reasons to avoid monoliths
- **Modular monolith** is underused and often excellent; decompose DB along module lines if possible
- **Log aggregation is a prerequisite** before adopting microservices
- Use **correlation IDs** across service calls
- Don't rush to Kubernetes/containers with only a few services; prefer managed K8s
- Don't adopt lots of new technology at start--address distributed pain as it appears
- Place **constraints on language choices** if needed (Netflix/Twitter JVM example) but don't mandate one stack
- Limit team size per codebase for productivity

---

## 3. Anti-patterns and Warnings

- **Shared databases** -- "one of the worst things" for independent deployability
- **Distributed monolith** -- SOA in name only; coupled, deploy-together
- **Layered (three-tier) architecture** for microservices -- changes span presentation/app/data tiers
- **Microservices as default for everything** -- complexity must be warranted
- **"Develop in the cloud"** when local dev breaks -- bad feedback cycles
- **Technology fetishism** -- adopting microservices + vast new alien tech simultaneously
- **Treating monolith as legacy/inherently bad**
- **Big-bang microservice adoption**
- **Microservices for cost-cutting** -- poor fit; cost-center mentality drags adoption
- **Microservices for startups/new products** -- unstable domain -> expensive boundary changes
- **"Microservice tax"** -- ops overhead disproportionate on small teams
- **Customer-deployed software + microservices** -- customers won't run K8s pods
- **Assuming end-to-end tests scale** -- diminishing returns as architecture grows
- **Assuming DB transactions work the same** -- need sagas, eventual consistency
- **Migration making system less robust** -- if network failure handling ignored

---

## 4. Decision Frameworks and Heuristics

**Should I use microservices?**

| Lean **away** | Lean **toward** |
|---------------|-----------------|
| Brand-new product / startup | Many developers, delivery contention |
| Unstable domain model | SaaS, 24/7, independent releases |
| Small team (handful of devs) | Cloud-native, match services to cloud offerings |
| Customer-deployed software | Digital transformation, unlock legacy via new channels |
| Primary goal = reduce costs | Need flexibility for unknown future |

**When evaluating**
- Assess problem space, skills, technology landscape, goals
- Microservices are **an architectural choice**, not *the* architectural approach
- Simpler approaches may deliver more easily

**Monolith vs microservices**
- Default to monolith unless justified
- Single-process monolith makes sense for smaller orgs (DHH/Rails)
- Choose microservices when scaling **people** and **delivery**, not hypothetical future scale

**Flexibility dial**
- More microservices -> more flexibility **and** more pain; assess impact incrementally

---

## 5. Key Quotes

> "If you take only one thing from this book... ensure that you embrace the concept of independent deployability."

> "Don't share databases unless you really need to. And even then do everything you can to avoid it."

> "Organizations which design systems...are constrained to produce designs which are copies of the communication structures of these organizations." -- Melvin Conway

> "A stream-aligned team is a team aligned to a single, valuable stream of work... empowered to build and deliver customer or user value as quickly, safely, and independently as possible." -- Team Topologies

> "Microservices buy you options." -- James Lewis

> "A distributed system is one in which the failure of a computer you didn't even know existed can render your own computer unusable." -- Leslie Lamport

> "A microservice should be as big as your head." -- James Lewis (understandable size)

> "The goal of microservices is to have as small an interface as possible." -- Chris Richardson

> "I am looking for a reason to be convinced to use microservices, rather than looking for a reason not to use them."

> "The bulk of this book is about dealing with the pain, suffering, and horror of owning a microservice architecture."

---

## 6. Actionable Guidance for Developers/Architects

1. Before any decomposition: implement **log aggregation** and **correlation IDs**
2. Draw service boundaries around **business capabilities**, not layers
3. Each service owns its data; cross-service access via **API calls**, not shared tables
4. Align teams to **vertical business slices** (stream-aligned)
5. Start with **1-2 microservices**, deploy to production, reflect on whether goals were met
6. Measure **end-to-end latency** before/after changes; distributed tracing required
7. Plan for **reporting** (streaming, data lakes, central reporting DB)--monolithic SQL joins won't work
8. Shift testing toward **contract tests**, **testing in production**, **canary/parallel runs**
9. For startups: build monolith first; decompose when domain stabilizes and pain points are known
10. For SaaS: exploit independent deployability for safe, frequent releases

---

# Chapter 2: How to Model Microservices

## 1. Key Concepts and Principles

**Good boundary = independent change/deploy**
- Microservices are **modular decomposition with network interaction**
- Build on structured programming: **information hiding, cohesion, coupling**

**Information hiding (Parnas)**
- Benefits: improved development time, comprehensibility, flexibility
- "The connections between modules are the **assumptions** which the modules make about each other"
- Fewer assumptions -> easier safe change -> independent deployment amplifies benefits

**Cohesion**
- "**The code that changes together, stays together**"
- Optimize for **ease of changing business functionality**
- Related behavior together; unrelated elsewhere
- **Strong cohesion** of business functionality over tech functionality

**Coupling**
- Loose coupling: change one service without changing another
- Limit number and chattiness of cross-service calls
- **Constantine's law**: "A structure is stable if cohesion is strong and coupling is low"
- Cohesion = relationships **inside** boundary; coupling = relationships **across** boundaries

**Types of coupling** (low -> high)

| Type | Description | Severity |
|------|-------------|----------|
| **Domain coupling** | Service A needs B's functionality | Loose; unavoidable but minimize downstream dependencies |
| **Temporal coupling** | Both services must be up simultaneously (sync HTTP) | Awareness required; async messaging mitigates |
| **Pass-through coupling** | A passes data to B only because C needs it | Very problematic; leaks implementation |
| **Common coupling** | Shared DB/memory/filesystem | Undesirable; static read-only ref data sometimes OK |
| **Content coupling** | External service directly modifies another's DB | **Pathological**; avoid entirely |

**DDD essentials**
- **Ubiquitous language**: same terms in code and domain
- **Aggregate**: real-world concept (Order, Invoice); lifecycle/state machine; one aggregate managed by one microservice (one service can own many aggregates)
- **Bounded context**: organizational boundary hiding complexity; contains aggregates; explicit external interface
- **Shared models** across contexts may have different names/meanings (Customer vs Recipient)
- Cross-service aggregate refs: use explicit URIs or pseudo-URIs (`soundcloud:tracks:123`)

**Mapping to microservices**
- Start with **entire bounded contexts** as services
- **Never split one aggregate across microservices**
- Nested bounded contexts ("turtles all the way down"); hide internal splits behind coarse API
- **Event storming** (Brandolini): events (orange) -> commands (blue) -> aggregates (yellow) -> bounded contexts

**Alternative decomposition drivers**
- **Volatility**: extract frequently changing parts (not sole driver; beware bimodal IT)
- **Data/PII/PCI**: segregate sensitive data zones (PaymentCo green/red zones)
- **Technology**: different runtimes (Rust vs Kotlin) force splits; beware three-tier trap
- **Organizational**: boundaries crossing teams -> delivery contention; shared ownership is fraught

---

## 2. Best Practices and Recommendations

- Share only what you must; send **minimum data** (information hiding)
- Treat downstream calls as **requests that can be rejected**
- Single microservice should **own state transitions** for its aggregates (finite state machine)
- Hide pass-through details inside intermediary (e.g., Warehouse builds Shipping Manifest)
- Use **opaque blobs** for pass-through data intermediary doesn't parse
- Static reference data in shared DB: relatively benign if **read-only** and rarely changing
- One aggregate -> one microservice; start with **coarse bounded contexts**
- Hide internal service splits from external consumers (facade/coarse API)
- Use **event storming** with all stakeholders in room; don't let current implementation warp domain model
- DDD + stream-aligned teams fit naturally together
- **Mix decomposition models** pragmatically; domain-oriented as default starting point
- Layering **inside** a microservice is fine; **layering as service boundaries** is not
- Vertical (business) slices for geographically distributed teams, not horizontal RPC layers
- Prefer **fully detailed events** if you'd share same data via API
- Use explicit cross-service references (URI/pseudo-URI) over implicit foreign keys

---

## 3. Anti-patterns and Warnings

- **Pass-through coupling** -- caller knows downstream's downstream; lockstep rollouts
- **Shared database (common coupling)** -- schema changes break multiple services; resource contention
- **Content coupling / pathological coupling** -- direct DB access bypasses service logic
- **CRUD wrapper microservice** -- behavior leaked to consumers; weak cohesion
- **Splitting aggregate across services**
- **Three-tier / horizontal layering as boundaries** -- high cohesion of tech, low of business
- **"Onion architecture"** -- geo-split front/back with chatty brittle RPC batching
- **Bimodal IT (Mode 1/Mode 2)** -- dump hard-to-change into "Mode 1"; slow and slower
- **Volatility-only decomposition** when scaling is the real driver
- **Technology-only decomposition** -> three-tier repeat
- **Organizational split along technical seams** instead of business seams
- **Dogma**: "The only way is X"
- **Premature fine-grained decomposition** before domain understood (Snap CI: merged back to monolith)
- **IBM banking model / generic data model** polluting ubiquitous language

---

## 4. Decision Frameworks and Heuristics

**Boundary quality checklist**
1. Can I change and deploy this service independently?
2. Is related business behavior co-located (strong cohesion)?
3. Are cross-boundary assumptions minimized (loose coupling)?
4. Is internal state hidden (information hiding)?
5. Does one service own aggregate lifecycle/state machine?

**Coupling remediation**
- Pass-through -> bypass intermediary, hide in intermediary, or opaque blob pass-through
- Common coupling on mutable shared state -> **single owner service** for state transitions
- Content coupling -> route through owning service's API

**Decomposition driver selection**
| Driver | When it fits |
|--------|--------------|
| Domain (DDD) | Default; business-aligned change isolation |
| Volatility | Fast time-to-market; frequently changing features |
| Data/security | PCI, GDPR, PII segregation |
| Technology | Different runtime/DB requirements |
| Organization | Match team ownership; avoid cross-team services |

**Mix models** when constraints conflict (e.g., domain boundary but different languages -> subdivide)

**Event storming flow**
Events -> Commands -> Aggregates -> Bounded contexts -> (optional) map to services

---

## 5. Key Quotes

> "The connections between modules are the assumptions which the modules make about each other." -- David Parnas

> "The code that changes together, stays together."

> "A structure is stable if cohesion is strong and coupling is low." -- Constantine (via Endres & Rombach)

> "Make sure you see a request that is sent to a microservice as something that the downstream microservice can reject if it is invalid."

> "If you see a microservice that just looks like a thin wrapper around database CRUD operations, that is a sign that you may have weak cohesion and tighter coupling."

> "In short, avoid content coupling."

> "If someone says 'The only way to do this is X!' they are likely just selling you more dogma."

---

## 6. Actionable Guidance for Developers/Architects

1. Before drawing boundaries: run **event storming** with domain experts
2. Map **aggregates first**, group into **bounded contexts**, assign contexts to services initially
3. Audit existing integrations for **coupling type** (domain -> content spectrum)
4. Replace shared mutable tables with **single owner + request/reject** pattern
5. For cross-service refs, use **explicit URIs**, not implicit ID columns
6. When splitting a bounded context later, keep **external API stable**; internal split is implementation detail
7. PCI/sensitive data: draw **hard network/data zone boundaries**; never leak sensitive data to exempt zones
8. For volatile code: extract to separate service **only if** it doesn't cross team boundaries
9. Reject horizontal "frontend service + backend RPC data store" splits; use **vertical slices per team**
10. Revisit boundaries when requirements change--stability isn't always possible

---

# Chapter 3: Splitting the Monolith

## 1. Key Concepts and Principles

**Migration mindset**
- Microservices are **not the goal**; activity != outcome
- Need **clear end goal** before starting
- **Incremental migration** (Fowler: big-bang rewrite = big bang)
- Monolith often **remains in diminished form** (e.g., 90% stays after extracting 10% bottleneck)
- Real architecture is **messy and evolving**, not laminated ideal

**Premature decomposition**
- Unclear domain -> wrong boundaries -> expensive cross-service changes
- Snap CI: merged to monolith, waited ~1 year, then split with stable boundaries
- Existing codebase to decompose is **easier** than greenfield microservices

**What to split first**
- Balance: **ease of extraction vs benefit toward goal**
- Scale bottleneck -> extract constraining functionality
- Time-to-market -> extract **volatile** parts (CodeScene hotspots)
- First services: **low-hanging fruit** with some impact; build momentum
- If easiest extraction fails -> reconsider whether microservices fit

**Decomposition by layer**
- Extract **backend code + data together** (both in scope)
- UI decomposition often lags but **must not be ignored**--sometimes biggest benefit
- **Code first** (common): easier short-term; must plan data extraction upfront
- **Data first** (less common): de-risks hard DB split; surfaces integrity/transaction issues early

**Patterns** (overview; detail in *Monolith to Microservices*)
- **Strangler fig**: intercept calls; route to new service or monolith; monolith unchanged
- **Parallel run**: run old + new side-by-side, compare results
- **Feature toggle**: switch between monolith and microservice implementations

**Data decomposition concerns**
- **Performance**: DB joins become service calls + multiple SELECTs; latency increases
- **Data integrity**: no cross-DB foreign keys; soft delete, denormalize at write time
- **Transactions**: lose single-DB ACID; distributed transactions problematic; use **sagas**
- **Tooling**: DB changes harder than code (Flyway, Liquibase, Rails migrations)

**Reporting database pattern**
- Dedicated external DB; microservice **pushes** subset of internal data
- Treat reporting DB like any **service endpoint**--maintain compatibility
- Tailor schema for consumers; may differ entirely from internal storage

---

## 2. Best Practices and Recommendations

- **Have a goal**; track progress against it; change course as needed
- **Try simple stuff first** (scale monolith behind load balancer before decomposing)
- **Incremental extraction**: one service at a time; assess in production
- Start **small** (1-2 areas); deploy; reflect
- Don't view monolith as enemy; focus on **benefits of change**
- Know **when to stop** decomposing
- First extractions: lean toward **easy** for quick wins and momentum
- Before code-first extraction: **sketch data extraction plan** (legwork upfront)
- Use **strangler fig** to avoid monolith changes initially
- Use **parallel run** for critical functionality migration
- Use **feature toggles** at proxy layer for strangler routing
- Mitigate join latency: **bulk lookups**, **caching**, accept slower ops if still "fast enough"
- Schema migrations: version-controlled **idempotent delta scripts**
- Reporting DB: expose **minimum data**; owner maintains mapping from internal state

---

## 3. Anti-patterns and Warnings

- **Microservices as the goal** (creating services without asking why)
- **Big-bang rewrite/decomposition**
- **Premature decomposition** with immature domain (Snap CI pattern)
- **Backend-only decomposition** ignoring UI silos
- **Code extracted, data left in monolith** without a plan (stores up pain)
- **Assuming DB will enforce cross-service integrity**
- **Distributed transactions** as ACID replacement -- complex, insufficient guarantees
- **Extracting hardest/critical piece first** before lessons learned
- **Ignoring production reality**: "You won't appreciate the true horror... until you are running in production"
- **Expecting clean architecture** post-migration

---

## 4. Decision Frameworks and Heuristics

**Before starting**
1. What is the end goal? (scale, time-to-market, team autonomy, etc.)
2. Can simpler approaches achieve it? (load balancer, modular monolith, etc.)
3. Is domain stable enough for boundaries?

**Prioritization matrix**
```
Priority = f(benefit toward goal, extraction difficulty)
First picks: moderate benefit + low difficulty (quick wins)
Later: high benefit + high difficulty (after experience)
```

**Code first vs data first**
| Approach | When |
|----------|------|
| Code first | Default; faster short-term value; must validate data path |
| Data first | Uncertain if data separates cleanly; de-risk integrity early |

**Stop conditions**
- Goal achieved with partial decomposition
- Monolith handles remaining 90% fine
- Only hard requirement for full removal: dead tech, retiring infra, ditching expensive third-party

**Migration patterns by risk**
| Risk level | Pattern |
|------------|---------|
| Low impact on monolith | Strangler fig + feature toggle |
| Critical functionality | Parallel run |
| Schema change | Flyway/Liquibase incremental deltas |

---

## 5. Key Quotes

> "Microservices are not the goal. You don't 'win' by having microservices."

> "Microservices aren't easy. Try the simple stuff first."

> "If you do a big-bang rewrite, the only thing you're guaranteed of is a big bang." -- Martin Fowler

> "You won't appreciate the true horror, pain, and suffering that a microservice architecture can bring until you are running in production."

> "The monolith is rarely the enemy."

> "Real system architecture is a constantly evolving thing that must adapt as needs and knowledge change."

> "Think of our monolith as a block of marble... It makes much more sense to just chip away at it incrementally."

---

## 6. Actionable Guidance for Developers/Architects

1. Write down the **migration goal** and success metrics before touching code
2. Attempt **horizontal scaling / modular monolith** first if they satisfy the goal
3. Use **CodeScene** (or similar) to find volatility hotspots for split candidates
4. First split: pick **self-contained, low-risk** functionality
5. Plan **both code and data extraction** before starting either
6. Implement **strangler proxy** at edge; route with **feature flags**
7. For critical paths: **parallel run** old vs new; compare outputs
8. Replace DB joins with service calls; add **bulk APIs** and **caching** where needed
9. Accept **eventual consistency**; design **sagas** for cross-service state (Ch. 6)
10. Stand up **reporting database** with push model for analytics/reporting needs
11. Use **Flyway/Liquibase** for all schema changes during extraction
12. After each extraction: **measure in production**, adjust strategy

---

# Chapter 4: Microservice Communication Styles

## 1. Key Concepts and Principles

**In-process vs inter-process**
- Network calls: serialization, latency, failure modes fundamentally different
- **Don't map object method calls 1:1 to microservice calls**
- Abstractions must not hide that a **network call is happening**

**Performance differences**
- Inter-process: measurable ms round-trips; no inlining optimizations
- Payload size matters; data actually copied/serialized
- Rethink chatty APIs (1000 local calls != 1000 network calls)

**Changing interfaces**
- Monolith: atomic deploy of caller + callee; IDE refactoring
- Microservices: **separate deployables**; backward-incompatible changes need lockstep or phased rollout

**Failure modes** (Tanenbaum & Steen, simplified)
| Mode | Example |
|------|---------|
| Crash | Server died |
| Omission | No response; downstream stopped emitting |
| Timing | Too late/early |
| Response | Wrong/missing data in response |
| Arbitrary (Byzantine) | Participants can't agree failure occurred |

- Many failures are **transient**; need rich error semantics (HTTP 4xx vs 5xx)
- 404 -> don't retry; 503 -> maybe retry; 501 -> retry won't help

**Communication model dimensions**
```
Style axis:     Synchronous blocking  <->  Asynchronous nonblocking
Pattern axis:   Request-response      <->  Event-driven
Also:           Common data (shared store)
Mix all styles in one architecture (norm)
```

**Patterns covered**

| Pattern | Nature | Key trait |
|---------|--------|-----------|
| **Sync blocking** | Request-response, usually | Temporal coupling; familiar; cascade failures |
| **Async nonblocking** | Multiple sub-patterns | Decouples availability in time |
| **Common data** | Async via shared store | File, DB, data lake/warehouse |
| **Request-response** | Sync or async | Caller expects result; can reject request |
| **Event-driven** | Async only | Emitter broadcasts facts; unaware of consumers |

**Temporal coupling**
- Sync: both services + both **specific instances** must be alive (response on same connection)

**Event vs request intent inversion**
- Request: caller knows what should happen; **greater domain coupling**
- Event: emitter states fact; consumers decide reaction; **looser coupling**

**Event payload strategies**
- **ID only**: consumers callback -> domain coupling + thundering herd
- **Fully detailed** (preferred): include all data you'd expose via API; enables audit/event sourcing; watch size/PII

**Async request-response**
- Consumer must know where to route response (queues)
- Store request state in DB for correlation when response arrives at different instance
- **Timeouts required** always

**Common data**
- Data lake (loose structure) vs data warehouse (structured; producers know schema)
- **Bidirectional shared DB read/write** = common coupling (bad)
- Good for: interoperability, large volumes, legacy/COTS integration

---

## 2. Best Practices and Recommendations

**Technology selection**
1. Decide **request-response vs event-driven** first
2. Then **sync vs async** (if request-response)
3. Then pick technology (Ch. 5)
- Don't pick tech first (Kafka for request-response, Angular for backend, etc.)

**Sync blocking**
- OK for **simple** architectures and teams new to distributed systems
- Avoid **long call chains**; restructure workflow (move Fraud Detection off critical path)
- Prefer **parallel over sequential** multi-call operations

**Async**
- Use for **long-running processes** (hours/days)
- Use when call chains can't be restructured
- Implement **timeouts**, **correlation IDs**, **monitoring**
- Message brokers: **keep middleware dumb, smarts in endpoints**
- Prefer message broker over rolling your own on Atom/HTTP polling
- **Fully detailed events** if data would be shared via API anyway
- Split events for **PII** vs non-PII if needed
- Use **requests** not **commands** (requests can be rejected)
- Async request-response: persist state for correlation; any instance can handle response
- **Idempotency** for retries (Ch. 12)
- Dead letter queue / **message hospital** for failed messages; max retry limits
- Read **Enterprise Integration Patterns** (Hohpe & Woolf)

**Event-driven**
- Start with **one event**; don't go all-in immediately
- Mix styles in same architecture
- Newman's bias: more teams replace request-response **with** events than reverse

**Common data**
- Unidirectional flow preferred
- Combine with notification call for lower latency if needed
- For real-time large volume: **Kafka/streaming** over file polling

---

## 3. Anti-patterns and Warnings

- **Hiding network calls** behind overly opaque abstractions -> performance surprises
- **Chatty synchronous chains** -> cascade failure, connection exhaustion, latency sum
- **Kafka for request-response**
- **Picking familiar/shiny tech** without matching communication style
- **Enterprise service bus** -- smarts pushed into middleware
- **Atom/HTTP polling** reinventing message broker features (competing consumers, etc.)
- **Pass-through / command mindset** -- "commands must be obeyed" vs rejectable requests
- **ID-only events** causing callback storms to emitter
- **Synchronous blocking for long operations** (hours/days warehouse dispatch)
- **async/await blocking on promises** -- still synchronous from code's perspective
- **Catastrophic failover** -- poison message infinite retry crashing all workers (2006 pricing system tale)
- **No max retry limit** on queues
- **No dead letter queue / replay UI**
- **Shared DB read/write** as integration (common coupling)
- **Assuming sync is simpler for failure handling** -- timeouts equally ambiguous (did request arrive? did response get lost?)

**Sync timeout ambiguity**
- Retry risk: duplicate processing if original succeeded -> need idempotency

---

## 4. Decision Frameworks and Heuristics

**Communication style selection**

```
Need result before continuing?     -> Request-response
OK to broadcast fact, invert intent? -> Event-driven

If request-response:
  Short chain, simple system, team new to distributed? -> Sync blocking OK
  Long chain / long process / availability decoupling?   -> Async nonblocking

If large batch / legacy interop / multi-GB:            -> Common data
If real-time large volume:                              -> Streaming (Kafka)
```

**Sync blocking red flags**
- Chains of 3+ services (Fraud Detection example)
- Downstream slowness blocking upstream
- Critical path with many temporal dependencies

**Event payload decision**
| Approach | Pros | Cons |
|----------|------|------|
| ID only | Small message | Callback coupling, load on emitter |
| Fully detailed | Loose coupling, audit trail | Size, PII exposure, contract rigidity |
| Hybrid | Balance | Complexity |

**Failure handling checklist**
- Max retries configured?
- Dead letter queue?
- Correlation IDs for tracing?
- Idempotent handlers?
- Timeout handling?
- Monitoring for async flows?

---

## 5. Key Quotes

> "A developer needs to be aware if they are doing something that will result in a network call; otherwise, you should not be surprised if you end up with some nasty performance bottlenecks."

> "Keep your middleware dumb, and keep the smarts in the endpoints."

> "A request implies something that can be rejected... A command implies a directive that must be obeyed."

> "An event is a fact... A message is a thing we send over an asynchronous communication mechanism."

> "I see far more teams replacing request-response interactions with event-driven interactions than the reverse."

> "This was a classic example of what Martin Fowler calls a catastrophic failover." (poison message on transacted queue)

---

## 6. Actionable Guidance for Developers/Architects

1. **Never hide network calls** from developers in APIs/libraries
2. Document which operations trigger remote calls and expected latency
3. Before choosing gRPC/REST/Kafka: answer **request-response or event-driven?** then **sync or async?**
4. Audit call graphs; **shorten chains** or move non-critical steps async/off critical path
5. For 3+ sequential sync calls: refactor workflow or switch to async/events
6. Run independent calls **in parallel** (reactive extensions, async/await with care)
7. Design APIs for **bulk operations** where monolith DB joins were replaced by N+1 service calls
8. Implement **HTTP-style error semantics** even on non-HTTP protocols
9. Events: include **full payload** you'd return from GET; use separate PII/non-PII event types if needed
10. Async queues: **max retries**, **DLQ/message hospital**, replay tooling from day one
11. Use **correlation IDs** on all async and sync flows
12. Prefer **message broker** (RabbitMQ, Kafka) over DIY HTTP event feeds unless requirements are simple
13. One microservice can expose **REST API + emit events** simultaneously
14. Start event-driven with **one event**; expand as team gains experience
15. Plan for **timeout + idempotency** on all request-response (sync ambiguity = same as async)

---

# Cross-Chapter Synthesis for Cursor Behavior

If encoding this into agent/architect behavior, prioritize these **non-negotiables** across Chapters 1-4:

| Priority | Rule |
|----------|------|
| 1 | **Independent deployability** is the north star |
| 2 | **No shared mutable databases** across services |
| 3 | **Business-domain boundaries**, not tech-layer boundaries |
| 4 | **Information hiding** at every boundary (API, events, reporting DB) |
| 5 | **Monolith/modular monolith first**; microservices only with justified goal |
| 6 | **Incremental migration**; measure in production |
| 7 | **Pick communication style before technology** |
| 8 | **Reject content coupling and pass-through coupling** aggressively |
| 9 | **One aggregate, one owner service** |
| 10 | **Requests/events can be rejected**; services own state machines |
| 11 | **Log aggregation + correlation IDs** before scaling service count |
| 12 | **Avoid long sync call chains**; prefer events/async for decoupling |
| 13 | **Don't decompose unstable domains** (startups/greenfield) |
| 14 | **Mix decomposition drivers** pragmatically--avoid dogma |
