# Building Microservices (2nd Ed.) -- Chapters 8-10 Extraction

Sam Newman, *Building Microservices: Designing Fine-Grained Systems* (O'Reilly, 2021). Coverage: **Chapter 8** (Deployment), **Chapter 9** (Testing), **Chapter 10** (From Monitoring to Observability).

---

## Chapter 8: Deployment

### 1. Key concepts and principles

**Logical vs. physical topology**
- Logical architecture diagrams hide deployment complexity: multiple instances, load balancers, databases, environments, and cross-data-center distribution.
- Multiple instances of the same logical microservice share one database (not a violation of "don't share databases" -- sharing is across instances of the *same* service, not across different services).
- Read replicas scale reads; write scaling for relational DBs is harder (often requires sharding).

**Environments and pipelines**
- Software moves through preproduction environments (laptop -> CI -> preprod -> production); each serves a different purpose.
- Build service artifacts once; environment-specific config must be external to the artifact.

**Five core deployment principles**
1. **Isolated execution** -- each instance gets its own compute resources; execution must not impact neighbors.
2. **Focus on automation** -- essential as microservice count grows; enables developer self-service.
3. **Infrastructure as code (IaC)** -- machine-readable, version-controlled, repeatable infrastructure config.
4. **Zero-downtime deployment** -- upstream consumers should not notice releases.
5. **Desired state management** -- declare desired state; platform maintains it (replace failed instances, scale on demand).

**GitOps**
- Desired state defined in code, stored in source control; tooling applies changes to running systems.

**Deployment options (spectrum of abstraction)**
- Physical machine -> VM -> container -> application container (IIS/Tomcat) -> PaaS -> FaaS/serverless.
- Containers share kernel (lighter than VMs); isolation improved but historically weaker than full VMs.
- Docker images hide implementation; identical images for local dev and production.
- Kubernetes: cluster = nodes + control plane; pod (1+ containers) -> service (stable routing) -> deployment (rolling upgrades, rollbacks, scaling).
- FaaS: pay-per-use, implicit HA, hidden container runtime; stateless by default.
- FaaS mapping: function-per-microservice, function-per-aggregate (coarser external interface), avoid function-per-state-transition.

**Progressive delivery**
- Separate **deployment** (install to environment) from **release** (make available to users) -- Jez Humble's core principle.
- Progressive delivery = "continuous delivery with fine-grained control over blast radius" (James Governor).
- Techniques: blue-green, feature toggles/flags, canary releases, parallel runs.

### 2. Best practices and recommendations

- Understand foundational deployment principles before chasing new technology.
- Front-load automation tooling.
- Version-control all infrastructure config; enables audit trails and environment recreation.
- Implement zero-downtime deployment; enables daytime releases and higher release frequency.
- Use rolling upgrades, blue-green, or Kubernetes deployments for zero-downtime.
- Default to one microservice per isolated execution environment (container or VM).
- Run instances across multiple availability zones.
- Docker images should be identical locally and in production.

**Sam's Really Basic Rules of Thumb**
1. **If it ain't broke, don't fix it.**
2. **Give up as much control as you feel happy with, then give away a little bit more.** Offload to PaaS (Heroku) or FaaS when possible.
3. **Containerize microservices** -- good isolation/cost compromise; expect Kubernetes in your future for orchestration at scale.

- Public cloud + problem fits FaaS -> use FaaS, skip Kubernetes.
- Don't let fear of lock-in trap you in self-managed complexity.
- Mix deployment models: BBC uses Lambda + EC2 where Lambda would be too expensive.
- Use fully managed Kubernetes clusters when possible.
- Evaluate Kubernetes with minikube/MicroK8s locally before committing.
- Handful of developers + few microservices -> Kubernetes is likely overkill even managed.
- Deploy frequently with lower failure rates (Accelerate evidence).
- Start by separating deployment from release; then add safe frequent deployment techniques.
- Feature toggles: start with config file; graduate to LaunchDarkly/Split.
- Canary: manual percentage ramp -> automated metric-driven ramp (Spinnaker).

### 3. Anti-patterns and warnings

- **Multiple microservices per host** without isolation -- uneven load affects all services; undermines independent deployability.
- **Application containers (IIS/Tomcat/Weblogic)** -- constrains tech choice; insufficient monitoring for microservices.
- **Kubernetes "because everyone else is"** -- same danger as microservices-by-fashion.
- **Kubernetes for small teams/few services** -- huge overkill.
- **Self-managed Kubernetes without skilled platform team** -- poor developer experience.
- **Function-per-state-transition** -- saga complexity at wrong granularity; inconsistency risk.
- **Breaking microservice into too many functions** -- explosion of functions; aggregate integrity violated.
- **Retrofitting zero-downtime** onto architecture not designed for it -- much harder than building it in.
- **"Go fast and break stuff"** -- contradicted by Accelerate data (fast deploy + low failure rates go together).

### 4. Decision frameworks and heuristics

| Decision | Framework |
|----------|-----------|
| Change deployment approach? | Rule 1: only if current approach doesn't work |
| How much control to retain? | Rule 2: offload to PaaS/FaaS when fit |
| Default deployment path | Rule 3: containers; orchestration when scale warrants |
| Cloud + FaaS-suitable workload | FaaS first, skip K8s |
| When to adopt Kubernetes | After basics mastered; when many processes to manage; prefer managed |
| Zero-downtime mechanism | Async messaging = trivial; sync = rolling upgrades/blue-green/K8s deployment |
| FaaS fit | Low/unpredictable load, short-running, stateless |
| Function granularity | Start function-per-microservice; function-per-aggregate if DDD aggregates diverge; never per state transition |

### 5. Key quotes

> "Independent deployability is really important. It is, however, also not an absolute quality."

> "The goal here is that upstream consumers shouldn't notice at all when you do a release." -- on zero-downtime deployment

> "If it ain't broke, don't fix it." -- Sam's Rule 1

> "Give up as much control as you feel happy with, and then give away just a little bit more." -- Sam's Rule 2

> "Deployment is what happens when you install some version of your software into a particular environment... Release is when you make a system or some part of it available to users." -- Jez Humble

> "Don't get trapped into thinking that you have to have Kubernetes 'because everyone else is doing it.'"

---

## Chapter 9: Testing

### 1. Key concepts and principles

**Testing in microservices vs. monoliths**
- Added complexity: distributed calls, multiple deployables, cross-team boundaries.
- Balance opposing forces: speed to production vs. quality assurance.

**Mike Cohn's test pyramid (adapted)**
- **Unit tests:** single function/method; fastest feedback; most numerous.
- **Service tests:** test one microservice directly; stub external collaborators.
- **End-to-end tests:** drive through UI/API across entire system; highest confidence, slowest, most brittle.
- Target ratio: ~10x more tests as you descend the pyramid (e.g., 4000 unit : 1000 service : 60 E2E).

**Consumer-driven contracts (CDCs)**
- Consumer writes tests specifying expected producer behavior.
- Producer runs consumer contracts on every build.
- Same pyramid level as service tests but different focus: cross-service compatibility.
- Catches semantic (not just structural) breakages.
- Explicit codification of inter-team communication (Conway's law).

**End-to-end test problems at scale**
- Flaky tests from moving parts, network glitches, race conditions.
- Ownership ambiguity with fan-in pipelines.
- "Metaversion" -- versioning whole system together destroys independent deployability.
- Cartesian explosion of scenarios with many services.

**MTBF vs. MTTR trade-off**
- Cannot catch all problems preproduction in distributed systems.
- Optimizing mean time to repair (fast rollback + good monitoring) may beat adding more functional tests.
- Accelerate: high performers test on-demand without integrated test environments.

### 2. Best practices and recommendations

- Automate repetitive testing; fix manual testing bottlenecks *before* microservices migration.
- Optimize for fast feedback; separate test types accordingly.
- When broad tests fail, write narrower unit tests to catch regression sooner.
- Replace slow broad tests with fast narrow tests when possible.
- Large quantity unit tests; run on file change for interpreted languages.
- Prefer stubs over mocks for service tests.
- Passing service tests != safe to deploy without checking upstream consumers -- use CDCs.
- Collaborate across consumer/producer teams when writing contracts.
- Producer runs all consumer contract tests on every build.
- Use Pact Broker for contract storage, validation tracking, dependency mapping.
- Actively remove overlapping E2E tests.
- Keep E2E as "training wheels" while building CDCs, production monitoring, progressive delivery -- then reduce reliance.
- Developer runs only microservices their team owns locally; stub out-of-scope dependencies.
- Do test in production -- safely (synthetic transactions, canary, parallel run).
- Start performance testing early; don't defer until pre-launch.
- Define SLO-based targets or fail on delta from previous build.

### 3. Anti-patterns and warnings

- **Test snow cone / inverted pyramid** -- few/no unit tests, all coverage in E2E; glacial CI.
- **Flaky tests left in suite** -- "normalization of deviance"; rerun until pass; erodes trust.
- **Dedicated E2E test team** -- distances developers from tests; increases cycle time.
- **The Great Pile-Up** -- long E2E breaks block deploys; changes accumulate; fixing gets harder.
- **Metaversion / system versioning** -- "Now you have 2.1.0 problems"; couples services.
- **Shared integrated test environments** -- constrained, fragile, blocks independent teams.
- **Running all microservices locally** -- unsustainable at scale.
- **Deferring performance testing** -- network multiplication makes latency critical.
- **Large manual testing before microservices** -- blocks benefits of fast delivery.

### 4. Decision frameworks and heuristics

| Question | Heuristic |
|----------|-----------|
| How many of each test type? | ~10x ratio descending pyramid |
| E2E test failing -- what to do? | Write unit test for specific breakage; consider replacing E2E |
| Bug in production -- what to do? | Missing test at some scope; add it |
| Cross-team E2E at scale? | Move away from cross-team E2E; use CDCs + schemas + production testing |
| MTBF vs. MTTR investment? | If heavy preproduction testing but no monitoring/recovery -- rebalance toward MTTR |
| Developer local setup? | Own team's services + stubs for everything else |
| Performance test frequency? | As regular as feasible; daily subset + weekly full |

**Flaky test remediation (Martin Fowler)**
1. Track down flaky tests.
2. Can't fix immediately -> remove from suite.
3. Rewrite to avoid multi-threaded nondeterminism.
4. Stabilize environment.
5. Replace with smaller-scoped test.

### 5. Key quotes

> "If you currently carry out large amounts of manual testing, I would suggest you address that before proceeding too far down the path of microservices."

> "Now you have 2.1.0 problems." -- Brandon Byars, on system-wide versioning

> "CDCs are just like [Agile stories being] a placeholder for a conversation."

> "Not testing in prod is like not practicing with the full orchestra because your solo sounded fine at home." -- Charity Majors

> "Sometimes expending the same effort on getting better at fixing problems when they occur can be significantly more beneficial than adding more automated functional tests."

---

## Chapter 10: From Monitoring to Observability

### 1. Key concepts and principles

**Observability vs. monitoring**
- **Observability:** property of the system -- extent to which internal state is understandable from external outputs.
- **Monitoring:** activity -- something we *do* (look at the system).
- Observable systems: rich external outputs you can interrogate ad hoc; ask questions you didn't anticipate.

**"Three pillars" critique (metrics, logs, traces / MELT)**
- Overly reductive; conflates property with implementation.
- Generic unifying concept: **events** -- any external output.
- Project from event streams: traces, searchable indexes, aggregations.

**Building blocks**
1. Log aggregation
2. Metrics aggregation
3. Distributed tracing
4. SLAs / SLOs / SLIs / error budgets
5. Alerting
6. Semantic monitoring
7. Testing in production

**Log aggregation**
- Prerequisite for microservice architecture (organizational readiness test).
- Standard log format internally.
- **Correlation IDs:** generated at entry point, propagated through all calls, fixed position in log lines.
- Clock skew -- logs unreliable for ordering/causality across machines; use distributed tracing for accurate timing.

**Metrics aggregation**
- Need baselines over time to know "good" vs. "bad."
- Aggregate at system, service, and instance levels with metadata tags.
- **Low cardinality** (Prometheus model) vs **high cardinality** (Honeycomb/Lightstep) -- enables ad hoc investigation.

**Distributed tracing**
- Spans correlated by ID -> assembled into traces by central collector.
- OpenTracing/OpenTelemetry for instrumentation.
- Sampling required (performance impact): all errors, sparse successes.

**SRE concepts**
- **SLA:** agreement with users; minimum bar.
- **SLO:** team-level objectives; achieving all SLOs exceeds SLAs.
- **SLI:** measured indicator.
- **Error budget:** allowed downtime/errors per period; enables risk decisions.

**Alerting philosophy**
- Not all problems equal; ask "Should this wake someone at 3 a.m.?"
- Alert fatigue: Three Mile Island, 737 Max -- too many alerts overwhelm operators.
- Good alerts (EEMUA): Relevant, Unique, Timely, Prioritized, Understandable, Diagnostic, Advisory, Focusing.

**Semantic monitoring**
- Model of acceptable system semantics.
- Question: "Is the system behaving as we expect?" not "Are there errors?"
- **Synthetic transactions:** inject fake user behavior with known inputs/outputs.

### 2. Best practices and recommendations

**Getting started (minimum viable observability)**
- Log aggregation first -- before anything else in microservice buildout.
- Correlation IDs from day one (hard to retrofit).
- Capture host metrics mapped to microservice instances.
- Capture response times per service interface.
- Log all downstream calls and major business process steps.

**Metrics**
- Collect baselines over weeks/months before knowing panic thresholds.
- Tag metrics with service, instance, host metadata.
- Prometheus for traditional low-cardinality; Honeycomb/Lightstep for high-cardinality observability.

**Distributed tracing**
- Start with correlation IDs in logs; add tracing when system complexity warrants.
- Prefer managed tracing services.
- Use OpenTelemetry for vendor portability.

**SLOs and error budgets**
- Define team SLOs aligned with but exceeding SLAs.
- Calculate error budgets from SLOs.
- Use budget status to gate risky changes.

**Alerting**
- Prioritize alerts: routine vs. urgent vs. 3 a.m. page-worthy.
- Follow EEMUA quality criteria for every alert.
- Alert on SLO violations, not every metric threshold breach.
- Semantic monitoring > low-level metric alerting.

**Standardization**
- One log format, one metrics store, standard metric naming across all services.
- Platform team provides observability building blocks.
- Use same observability tools in dev, test, and production (democratic tooling).

### 3. Anti-patterns and warnings

- **SSH/grep across multiple hosts as primary log strategy**
- **Skipping log aggregation** -- if org can't implement this, microservices will likely overwhelm them.
- **No correlation IDs** -- painful to retrofit.
- **Trusting log timestamps for cross-service ordering** -- clock skew.
- **Treating Elasticsearch as source-of-truth database**
- **Three pillars checkbox mentality** -- buying separate tools without outcome focus.
- **Low-cardinality tools for high-cardinality questions** -- Prometheus with user ID labels.
- **Alerting on every metric threshold** -- alert fatigue.
- **Binary up/down health thinking** -- meaningless for distributed systems.
- **AI/ML "expert in the machine" promises** -- human expertise still essential.
- **Logging sensitive data** -- logs become attack targets.
- **Monitoring without observability mindset** -- static dashboards miss unknown unknowns.
- **Inconsistent metric names across services**

### 4. Decision frameworks and heuristics

| Stage | What to implement |
|-------|-------------------|
| Before any microservices | Log aggregation |
| Early | Correlation IDs, host metrics, response times, downstream call logging |
| Growing complexity | Distributed tracing (managed preferred), high-cardinality tooling |
| Mature | SLOs/error budgets, semantic monitoring, synthetic transactions |

| Question | Heuristic |
|----------|-----------|
| Monitoring vs. observability? | Monitoring = activity; observability = system property |
| When to page someone? | SLO breach or semantic model violation |
| Log vs. trace for timing? | Logs unreliable across machines; tracing for latency/causality |
| Can we skip tracing initially? | Yes; correlation IDs + logs first |
| Error budget exhausted? | Defer risky releases; focus on reliability |

**EEMUA alert quality checklist**
- Relevant -> Unique -> Timely -> Prioritized -> Understandable -> Diagnostic -> Advisory -> Focusing

### 5. Key quotes

> "You won't truly appreciate the potential pain, suffering, and anguish caused by a microservice architecture until you have it running in production and serving real traffic."

> "We replaced our monolith with micro services so that every outage could be more like a murder mystery."

> "Before you do anything else to build out your microservice architecture, get a log aggregation tool up and running."

> "Once you have log aggregation, get correlation IDs in as soon as possible. Easy to do at the start and hard to retrofit later."

> "Not testing in prod is like not practicing with the full orchestra because your solo sounded fine at home." -- Charity Majors

> "The expert in the system is, and will remain for some time, a human."

> "Get good at handling the unknown."

---

## Cross-chapter themes (Chapters 8-10)

1. **Independent deployability is the north star** -- isolation, zero-downtime, no metaversioning, CDCs over cross-team E2E, deploy/release separation, progressive delivery.
2. **Automate relentlessly** -- IaC, CI/CD, self-service provisioning, desired-state platforms.
3. **Fast feedback over exhaustive preproduction testing** -- test pyramid, stub locally, CDCs for contracts, production testing + MTTR for the rest.
4. **Log aggregation + correlation IDs before microservices** -- non-negotiable prerequisite.
5. **Observability > monitoring** -- design for unknown questions; semantic monitoring over metric thresholds.
6. **Offload when possible** -- FaaS/PaaS before self-managed K8s; managed clusters before on-prem.
7. **Human expertise remains essential** -- in testing trade-offs, alert triage, incident response.
8. **Standardize cross-cutting concerns** -- logs, metrics names, correlation IDs, observability tooling.
