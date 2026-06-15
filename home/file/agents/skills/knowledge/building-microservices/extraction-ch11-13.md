# Building Microservices (2nd Ed.) -- Chapters 11-13 Extraction

Sam Newman, *Building Microservices: Designing Fine-Grained Systems* (O'Reilly, 2021). Coverage: **Chapter 11** (Security), **Chapter 12** (Resiliency), **Chapter 13** (Scaling).

---

# Chapter 11: Security

## 1. Key Concepts and Principles

### The microservices security paradox
- Microservices **increase attack surface**: more network traffic, more infrastructure.
- Microservices **also enable defense in depth**: finer boundaries, limited scope of access, reduced blast radius.

### Core principles
| Principle | Meaning |
|-----------|---------|
| **Principle of least privilege** | Grant minimum access needed, for minimum time needed. |
| **Defense in depth** | Multiple layered protections; no single point of failure in security. |
| **Automation** | Essential for managing complexity, rotation, detection, recovery. |
| **Shift-left security** | Security must be built into delivery from the start. |

### Three types of security controls
1. **Preventative** -- stop attacks (encryption, auth, secure secrets storage)
2. **Detective** -- detect attacks (firewalls, intrusion detection, log aggregation)
3. **Responsive** -- respond/recover (automated rebuild, backups, comms plans)

### NIST five functions of cybersecurity
1. **Identify** -- who attackers are, what they want, where you're vulnerable
2. **Protect** -- safeguard key assets
3. **Detect** -- know when breach occurs
4. **Respond** -- limit damage, communicate properly
5. **Recover** -- restore systems, apply lessons learned

### Trust models
- **Implicit trust** -- assume intra-perimeter calls are safe (common but risky)
- **Zero trust** -- assume environment is already compromised; verify every call; encrypt everything
- **Spectrum** -- trust posture can vary by data sensitivity

### Data classification (MedicalCo example)
- **Public** -- freely shareable
- **Private** -- logged-in users only
- **Secret** -- highly sensitive; strictest controls

### Authentication vs. authorization
- **Authentication** -- confirm identity of principal
- **Authorization** -- map principal to permitted actions
- **SSO** -- authenticate once per session across multiple services
- **Confused deputy problem** -- upstream service tricked into acting on behalf of attacker

---

## 2. Best Practices and Recommendations

- Have **application security experts** on hand.
- Perform **threat modeling holistically** -- not per-microservice in isolation.
- **Integrate security tools into CI**: ZAP (dynamic), Brakeman/Snyk (static/dependencies), git-secrets/gitleaks (pre-commit).
- Use **password managers** and **long passwords**; avoid mandated regular password changes (NIST/NCSC).
- Use **MFA** for vital services.
- **Rotate credentials frequently**; prefer **time-limited credentials** (Vault-generated DB creds).
- **Limit scope** of every credential -- per-service, per-instance where feasible.
- Use centralized secrets management: **Vault**, **Kubernetes Secrets**, **AWS Secrets Manager**.
- Store backups in **separate accounts/regions/providers** from production.
- **Test backup restoration regularly**.
- **Rebuild from source control** routinely.
- Patch **all layers**: OS, container base images, Kubernetes, application code, third-party libraries.
- **Encrypt data at rest**; never roll your own crypto.
- Use **salted password hashing**.
- **Encrypt on first sight; decrypt on demand only.**
- Practice **Datensparsamkeit** (data frugality) -- collect/store minimum PII needed.
- Use **HTTPS/TLS everywhere** internally too.
- Use **mutual TLS** for service-to-service in zero-trust environments.
- Prefer **OpenID Connect** over SAML for SSO.
- Use **coarse-grained roles** modeled on org structure.
- Push **fine-grained authorization into the microservice** that owns the functionality.
- Generate **per-request JWTs** at gateway (not long-lived session JWTs on client).

---

## 3. Anti-Patterns and Warnings

| Anti-pattern | Why it's dangerous |
|--------------|-------------------|
| Focusing on JWT/mTLS while ignoring basics | "Secure front door, open back door" |
| Threat modeling only 1-2 microservices | False sense of security |
| Shared broad-privilege credentials across services | Massive blast radius on compromise |
| Checking private keys into Git | Extremely common leak vector |
| Backups in same cloud account as production | Attacker destroyed everything including backups (Code Spaces) |
| Schrödinger backups (never tested restore) | Backups may be useless |
| Implicit trust inside perimeter (unconscious) | Attacker inside network = total compromise |
| Fine-grained roles in directory service | Nightmare to maintain; couples services |
| Centralized upstream authorization | Breaks independent deployability |
| Long-lived JWTs for async multi-day flows | Token misuse window |
| Implementing your own encryption | "Badly implemented encryption worse than none" |
| Storing encryption keys in same DB as encrypted data | Defeats purpose |

---

## 4. Decision Frameworks and Heuristics

### Zero trust vs. implicit trust
```
IF data is PII/secret-classified -> zero trust (mutual auth, encryption, per-request authorization)
ELIF threat model justifies cost -> zero trust
ELSE -> may relax, but make it a CONSCIOUS decision
```

### JWT strategy
```
Per-request JWT at gateway (preferred)
IF authorization logic too complex for JWT -> JWT for coarse check + DB lookup for fine-grained
IF async flow exceeds token TTL -> scoped long-lived token OR stop using token mid-flow
```

### Gateway usage
```
Use gateway for: SSO handshake, coarse auth, TLS termination
Do NOT use gateway for: all fine-grained authorization (push to services)
Do NOT let gateway become: monolithic coupling point
```

---

## 5. Key Quotes

> "You're only as secure as your least secure aspect."

> "Zero trust, fundamentally, is a mindset. It's not something you can magically implement using a product or tool."

> "Friends don't let friends write their own crypto."

> "Encrypt data when you first see it. Only decrypt on demand."

> "If you don't store it, no one can steal it."

> "Building a secure system isn't about doing one thing. It necessitates a holistic view of your system."

---

## 6. Actionable Guidance

1. **Start every security discussion with threat modeling**, not JWT/mTLS.
2. **Implement least privilege everywhere**: DB creds per service instance, read-only where possible, time-limited tokens.
3. **Add to CI pipeline**: secret scanning, dependency scanning, DAST.
4. **Set up Vault or cloud secrets manager** before you have 10+ microservices.
5. **Store backups off-account, off-region**; restore them monthly.
6. **Make rebuild = deploy**: infrastructure as code, immutable containers.
7. **Classify data** (public/private/secret) and match security zones accordingly.
8. **Use HTTPS + mTLS** for all inter-service communication in sensitive contexts.
9. **Gateway generates per-request JWTs**; downstream services validate and authorize locally.
10. **Minimize PII collection**; anonymize logs; encrypt at rest and in backups.

---

# Chapter 12: Resiliency

## 1. Key Concepts and Principles

### David D. Woods' four concepts of resilience

| Concept | Definition |
|---------|------------|
| **Robustness** | Absorb **expected** perturbations |
| **Rebound** | Recover after traumatic events |
| **Graceful extensibility** | Handle **unexpected** situations/surprises |
| **Sustained adaptability** | Continually adapt to changing environments |

- Microservices primarily help **robustness** -- only one facet.
- Resiliency is a property of **people, processes, and organization**, not just software.

### Failure is inevitable at scale
- At scale, failure is a **statistical certainty**, not an edge case.

### Stability patterns (from Release It! / Nygard)
1. **Time-outs** -- on every out-of-process call + overall operation budget
2. **Retries** -- for transient failures, with backoff; account for retry time in timeout budget
3. **Bulkheads** -- isolate failure domains (separate connection pools, microservice boundaries, load shedding)
4. **Circuit breakers** -- fail fast when downstream unhealthy; auto-recover
5. **Isolation** -- temporal (middleware/buffers) and physical (separate hosts/containers/DB infra)
6. **Redundancy** -- multiple instances, multiple AZs, backup on-call people
7. **Idempotency** -- safe retries; business operation idempotent

### CAP theorem
- **AP** -- available + partition tolerant, eventually consistent
- **CP** -- consistent + partition tolerant, sacrifice availability
- **Per-service, per-capability** trade-offs -- not system-wide

### Chaos engineering
- System = people + processes + culture + software + infrastructure
- **Game Days** -- surprise drills for people/processes
- Tools: Chaos Toolkit, Gremlin -- but **running a tool != being resilient**

### Blame culture
- Blame -> fear -> hidden failures -> no learning -> repeat incidents
- **Blameless post-mortems** essential for sustained adaptability

---

## 2. Best Practices and Recommendations

- **Assume failure** in all design decisions.
- **Put time-outs on ALL out-of-process calls** with a sensible default.
- Set time-outs based on **healthy downstream response times** and **user-facing SLA**.
- Implement **overall operation time-out budget**; pass remaining time downstream.
- Retry **transient failures** with **delay/backoff**; factor retry time into total timeout budget.
- **Separate connection pool per downstream service** (bulkhead minimum).
- **Mandate circuit breakers for all synchronous downstream calls.**
- **Manually open breakers** during planned maintenance.
- Run microservices on **independent hosts/containers** with ring-fenced resources.
- Multiple instances across **multiple availability zones**.
- Include **business keys** for idempotency so duplicate calls don't duplicate effects.
- Map each UI page: which services required, which optional. Define **business-approved degradation**.
- Ask per capability: **"Is 5 minutes stale OK?"** -- if yes, AP; if no, CP.
- Don't build your own CP datastore.
- Run **Game Days** regularly.
- **Blameless post-mortems** after every significant incident.
- Match techniques to **actual cross-functional requirements** per service.

---

## 3. Anti-Patterns and Warnings

| Anti-pattern | Consequence |
|--------------|-------------|
| Shared HTTP connection pool for all downstreams | One slow service exhausts all workers |
| Disabled pool wait timeout (default!) | Threads block forever; cascading failure |
| Long time-outs on user-facing paths | User refreshes -> duplicate requests -> amplifies load |
| No circuit breaker on unhealthy downstream | Keep hammering failing service |
| Retrying without backoff on overloaded service | Makes overload worse |
| Retries without idempotency | Duplicate business effects |
| Sticky sessions / session affinity | Limits load balancing; avoid |
| Building for massive scale from day one | Wasted effort |
| Blame culture / "embarrassing human error" | Hidden failures, repeat outages |
| "Running chaos tool = resilient" | Tool without culture/process is meaningless |
| Writing your own distributed consistent datastore | "Get a PhD, spend years getting it wrong" |

---

## 4. Decision Frameworks and Heuristics

### Stability pattern selection
```
ALWAYS: time-outs on all external calls
ALWAYS: separate connection pools per downstream (bulkhead minimum)
ALWAYS: circuit breakers on all synchronous downstream calls
CONSIDER: retries with backoff for transient errors (within timeout budget)
CONSIDER: idempotency keys for any retried mutation
CONSIDER: isolation (separate hosts/AZs) based on blast radius analysis
```

### Time-out setting
```
downstream_timeout = min(
  healthy_p99_response_time * safety_factor,
  user_facing_sla_remaining_budget
)
```

### Degradation decision tree
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
```

---

## 5. Key Quotes

> "At scale, even if you buy the best kit, the most expensive hardware, you cannot avoid the fact that things can and will fail."

> "In a distributed system, latency kills."

> "Failing fast is always better than failing slow."

> "Friends don't let friends write their own distributed consistent data store."

> "Running a chaos engineering tool doesn't make you resilient."

> "Automation can't handle surprise -- our ability to gracefully extend our system... comes from having people in place with the right skills, experience, and responsibility."

---

## 6. Actionable Guidance

1. **Define SLOs per service** before choosing patterns.
2. **Audit all outbound calls**: verify time-outs exist on call AND pool wait.
3. **Separate connection pool per downstream service** immediately if shared today.
4. **Add circuit breakers** to every synchronous inter-service call.
5. **Implement operation-level timeout budgets**; propagate deadline to downstream calls.
6. **Make all mutations idempotent** with business keys before enabling retries.
7. **Map every user flow** to dependencies; document degradation behavior with product owners.
8. **Deploy across multiple AZs** minimum.
9. **Test backup restore** and **rebuild-from-scratch** regularly.
10. **Run Game Days** -- include "key person unavailable" scenarios.
11. **Conduct blameless post-mortems**.
12. **Don't over-engineer** resiliency for low-criticality services.

---

# Chapter 13: Scaling

## 1. Key Concepts and Principles

### Four axes of scaling (Scale Cube + vertical)
| Axis | Description |
|------|-------------|
| **Vertical scaling** | Bigger machine (more CPU/RAM/I/O) |
| **Horizontal duplication** | Multiple copies doing same work |
| **Data partitioning** | Split by data attribute (shard) |
| **Functional decomposition** | Split by function/type |

### Caching
Three purposes: **performance**, **scale** (reduce origin contention), **robustness** (serve stale if origin down).

Cache locations: client-side, server-side, request cache.

Invalidation mechanisms: TTL, conditional GET (ETags), notification-based (events), write-through, write-behind.

**Golden rule**: cache in as few places as possible; ideal = zero caches unless needed.

### Autoscaling
- **Predictive** -- scale on known patterns
- **Reactive** -- scale on load spikes or instance failure
- Scale down cautiously -- **better to have excess capacity than too little**.

### Starting again
- Architecture that starts you != architecture that scales you.
- Rearchitect at tipping point = **sign of success**, not failure.
- **Don't build for massive scale upfront** -- validate product first.

---

## 2. Best Practices and Recommendations

### Scaling strategy (order of attempt)
1. **Vertical scaling** -- fastest, lowest risk on cloud
2. **Horizontal duplication** -- load balancers, read replicas, competing consumers
3. **Caching** -- fewest cache layers
4. **Data partitioning** -- when write-constrained
5. **Functional decomposition** -- when other axes exhausted OR org needs microservices too
6. **CQRS/event sourcing** -- last resort for read/write scaling complexity

- **Never use sticky sessions** -- refactor to stateless or externalize session state.
- Choose partition keys for **even distribution** -- unique IDs, NOT surname ranges.
- Treat partitioning as **internal implementation detail**.
- **Start with zero caches**; add only when measured bottleneck exists.
- Prefer **TTL as starting point**; tune per resource type.
- **Don't nest caches** without understanding compounded staleness.
- Use **automated load tests**: baseline -> change -> measure.
- Start with **failure-based autoscaling** while collecting load data.
- Accept rearchitecture at growth milestones as normal and successful.

---

## 3. Anti-Patterns and Warnings

| Anti-pattern | Problem |
|--------------|---------|
| Premature optimization / scaling | Complexity without measured need (Knuth) |
| Building for massive scale from day one | Delays product validation |
| Vertical scaling for robustness | Single point of failure remains |
| Sticky session load balancing | Limits options; causes problems |
| Bad partition key (surname A-M/N-Z) | Uneven load |
| Changing partition scheme after the fact | Multi-day outages possible |
| CQRS/event sourcing as first read-scaling move | Very complex; read replicas simpler |
| Caching in too many places | Compounded staleness |
| `Expires: Never` on HTTP responses | Cache poisoning |
| Autoscaling down too aggressively | Insufficient capacity during spikes |

---

## 4. Decision Frameworks and Heuristics

### Which scaling axis?
```
IF need quick win AND on cloud -> vertical scaling
ELIF need more throughput/redundancy AND stateless -> horizontal duplication
ELIF write-constrained AND partition key gives even distribution -> data partitioning
ELIF specific functionality is bottleneck AND other axes exhausted -> functional decomposition
IF read-constrained -> read replicas / caching BEFORE CQRS
```

### Cache placement
```
IF optimizing end-to-end latency for one consumer -> client-side cache
IF many consumers, want consistent cached view -> server-side or shared cache
IF specific expensive query repeated -> request cache
IDEAL number of cache layers: 0 -> add only with measured need
```

---

## 5. Key Quotes

> Donald Knuth: "Premature optimization is the root of all evil (or at least most of it) in programming."

> Phil Karlton: "There are only two hard things in Computer Science: cache invalidation and naming things."

> "The need to change our systems to deal with scale isn't a sign of failure. It is a sign of success."

---

## 6. Actionable Guidance

1. **Identify your constraint** (CPU, memory, I/O, writes, reads) before choosing axis.
2. **Try vertical scaling first** on cloud.
3. **Add horizontal duplication** for stateless services.
4. **Choose partition keys carefully** -- immutable unique IDs.
5. **Cache minimally** -- one layer max where possible.
6. **Set HTTP cache headers consciously** -- never `Expires: Never` unless intentional.
7. **Run load tests**: baseline -> change -> measure -> confirm hypothesis.
8. **Exhaust vertical + horizontal + caching before microservice extraction** for scaling alone.
9. **Autoscale for failures first**; add load-based rules only with validated data.
10. **Plan for rearchitecture** at success tipping points.

---

# Cross-Chapter Themes (Chapters 11-13)

| Theme | Implication |
|-------|-------------|
| **Holistic thinking** | Security, resiliency, scaling aren't single-tool fixes |
| **Threat/requirements first** | Model threats and SLOs before picking patterns |
| **Defense in depth / bulkheads** | Layer protections; isolate failure domains |
| **Automation** | Rotate secrets, rebuild infra, run CI security scans, autoscale |
| **Least privilege + short TTL** | Credentials, tokens, access scopes |
| **Fail fast > fail slow** | Time-outs, circuit breakers, load shedding |
| **Graceful degradation** | Partial failure is normal; design business-aligned fallbacks |
| **Measure before optimizing** | Load tests, baselines, scientific experimentation |
| **Complexity has cost** | Every robustness/scaling pattern adds new failure modes |
| **People and culture** | Blameless learning, Game Days, sustained adaptability |
| **Independent deployability** | Decentralized auth, hidden implementation details |
| **Don't build for hypothetical scale/security** | Match investment to actual risk and load |
