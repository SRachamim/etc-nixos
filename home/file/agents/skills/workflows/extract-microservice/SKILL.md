---
name: extract-microservice
description: Extract a microservice from a monolith or existing system. Plan mode for analysis, then Agent mode for implementation. Covers goal definition, monolith assessment, candidate selection, strangler fig pattern, data extraction, and validation.
disable-model-invocation: true
---

# Extract Microservice

Extract a microservice from a monolith or existing system using incremental, production-validated steps. This command plans the extraction in Plan mode, then implements it in Agent mode after user approval.

## Input

Accept **any** of the following:

1. **Extraction goal** — why extract? (scale bottleneck, time-to-market, team autonomy, tech modernization, compliance isolation).
2. **Monolith context** — repository path, service name, or description of the existing system.
3. **Candidate hint** — a module, bounded context, or feature area the user believes should be extracted first (optional).
4. **Ticket or design document** — Azure DevOps work item or linked specification. Fetch via MCP when applicable.

When the monolith codebase is accessible, read it. When it is not, work from the user's description and ask for access or key files.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. Steps 1–10 are read-only analysis and planning. The user will switch to Agent mode at step 11 for implementation.

### 1. Define the goal

Establish why extraction is needed and whether microservices are the right tool.

**What to do:**

- Read and apply the **building-microservices** skill, section: **North Star**.
- Restate the extraction goal with measurable success criteria. Common drivers:
  - **Scale** — a specific bottleneck constraining throughput or latency.
  - **Time-to-market** — volatile features blocked by monolith release cadence.
  - **Team autonomy** — delivery contention across teams sharing one codebase.
  - **Tech modernization** — need different runtime, database, or deployment model for one area.
- Apply the **monolith-first default**: evaluate simpler alternatives first:
  - Horizontal scaling behind a load balancer?
  - Modular monolith with clearer module boundaries?
  - Feature flags and trunk-based development to reduce release contention?
- If simpler approaches suffice, **recommend them** and stop this command. Microservices are not the goal — activity ≠ outcome.
- If extraction is justified, write down migration goal and success metrics. Define **stop conditions** (goal achieved with partial decomposition; monolith handles remaining 90% fine).

**Decision criteria:**

Read **building-microservices** [reference.md](reference.md), Chapter 3: *Migration mindset* and *Stop conditions*.

- "Microservices are not the goal. You don't 'win' by having microservices."
- Need a clear end goal before starting; incremental migration, not big-bang rewrite.

**Deliverable:** Goal statement, success metrics, stop conditions, simpler-alternatives assessment.

### 2. Assess the monolith

Map the existing system's structure, hotspots, and coupling.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Modeling Boundaries**.
- Map **domain boundaries** in the monolith: modules, packages, bounded contexts, aggregates. Identify ubiquitous language terms and where they diverge.
- Identify **hotspots** — frequently changed code (volatility). Use CodeScene or change-frequency analysis when available; otherwise grep git history for churn.
- Map **data ownership**: which tables/entities belong to which domain area? Where are cross-module joins?
- Assess **current coupling**:
  - Domain coupling (expected, minimise fan-out).
  - Temporal coupling (both modules must be up).
  - Pass-through coupling (data forwarded only for a third consumer).
  - Common coupling (shared mutable database tables).
  - Content coupling (one module directly writes another's tables) — never acceptable.
- Note **UI silos** — backend-only decomposition that ignores frontend boundaries creates hidden coupling.
- Evaluate whether the **domain model is stable enough** for boundaries. Premature decomposition with unclear domain → wrong boundaries → expensive cross-service changes.

**Decision criteria:**

- Start with domain-oriented boundaries; mix volatility, data/security, technology, and organisation drivers pragmatically.
- The monolith often remains in diminished form (90% stays after extracting 10% bottleneck).

**Deliverable:** Monolith assessment — domain map, hotspot list, data ownership map, coupling inventory, stability assessment.

### 3. Select extraction candidate

Choose the first service to extract using a prioritisation matrix.

**What to do:**

- Read and apply the **building-microservices** [reference.md](reference.md), Chapter 3: **Prioritisation matrix** and **What to split first**.
- For each candidate area, score:
  - **Benefit toward goal** (low / moderate / high).
  - **Extraction difficulty** (low / moderate / high).
- Apply the matrix:
  ```
  Priority = f(benefit toward goal, extraction difficulty)
  First picks: moderate benefit + low difficulty (quick wins)
  Later: high benefit + high difficulty (after experience)
  ```
- **Start with low-risk, moderate-benefit** candidate to build momentum and learn extraction patterns.
- Match candidate to goal driver:
  - Scale bottleneck → extract constraining functionality.
  - Time-to-market → extract volatile parts (hotspots).
  - Team autonomy → extract area owned by the most frustrated team.
  - Compliance → extract data requiring segregation (PCI, GDPR).
- If the easiest extraction candidate still looks too hard, reconsider whether microservices fit.

**Decision criteria:**

- Do **not** extract the hardest/critical piece first before lessons learned.
- First extraction failure → reconsider whether microservices fit.

**Anti-patterns:** extracting backend without planning UI impact; code extracted with data left in monolith without a plan.

**Deliverable:** Candidate comparison table with benefit/difficulty scores, recommended first extraction with rationale.

### 4. Plan code extraction

Design how code moves out of the monolith incrementally.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Build and Deployment** (progressive delivery, feature toggles, trunk-based development).
- Default to the **strangler fig pattern**:
  1. Intercept calls to the candidate functionality at the monolith boundary (proxy, API gateway, or routing layer).
  2. Route traffic to the new microservice **or** the monolith based on feature toggle.
  3. Incrementally move implementation behind the intercept; monolith code shrinks but remains deployable throughout.
- Plan **proxy/routing**: where interception happens, how routing decisions are made, how rollback works.
- Plan **feature toggle** for traffic switching: toggle off = monolith handles request; toggle on = new service handles request. Enables instant rollback.
- Consider **parallel run** for critical functionality: run old + new side-by side, compare results before cutover.
- Plan **repo strategy**: new repo for extracted service (multirepo default). Monolith repo loses code incrementally.
- Ensure **CI maturity** before extraction proceeds (daily mainline commits, behavioural tests, broken build is #1 priority).

**Decision criteria:**

- Incremental migration — never big-bang rewrite ("the only thing you're guaranteed of is a big bang" — Fowler).
- Zero-downtime: upstream consumers must not notice releases.
- Separate deployment from release; use progressive delivery.

**Deliverable:** Code extraction plan — strangler fig intercept points, routing diagram, feature toggle strategy, repo layout, rollback procedure.

### 5. Plan data extraction

Sketch data separation upfront even if code moves first.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Workflow and Sagas**.
- Read **building-microservices** [reference.md](reference.md), Chapter 3: **Code first vs data first**, **Data decomposition concerns**, **Reporting database pattern**.
- Decide extraction order:
  - **Code first** (default) — faster short-term value; must validate data path upfront.
  - **Data first** — when uncertain if data separates cleanly; de-risk integrity early.
- For the candidate's data:
  - Identify tables/entities that move to the new service's database.
  - Identify **join replacements**: DB joins become service calls. Plan bulk lookup APIs and caching to mitigate latency.
  - Plan **data integrity**: no cross-DB foreign keys; soft delete, denormalize at write time.
  - Plan **transaction replacement**: lose single-DB ACID; design sagas for cross-boundary state changes with compensating transactions.
  - Plan **reporting**: dedicated reporting DB if analytics consumers need joined views; microservice pushes subset of data.
- Sketch the **target data model** for the new service even if migration is phased.

**Decision criteria:**

- Performance: DB joins → service calls + multiple SELECTs; latency increases. Mitigate with bulk APIs and caching.
- Never leave code extracted with data in the monolith without an explicit migration plan.
- Never use 2PC/XA across the new boundary.

**Deliverable:** Data extraction plan — ownership map, migration phases, join replacements, saga design for cross-boundary transactions, reporting strategy.

### 6. Design communication

Define the interface between the new service and the remaining monolith.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Communication Design**.
- Design the **API contract** between new service and monolith:
  - Choose style before technology (sync request-response vs async events).
  - Define explicit schemas (OpenAPI, protobuf, AsyncAPI).
  - Plan **versioning**: semantic versioning, expand-and-contract for schema changes.
  - Plan **backward compatibility**: monolith consumers must not break when the new service evolves independently.
- Define **event payloads** if using event-driven communication at the boundary.
- Plan **consumer-driven contracts** if multiple consumers depend on the new service's API.
- Ensure **correlation IDs** propagate across the new boundary from day one.
- Classify boundary coupling type and confirm no content or pass-through coupling.

**Decision criteria:**

- Tolerant reader (Postel's law): consume only needed fields; ignore unknown fields.
- No shared domain object libraries across the boundary.
- Keep the intercept layer dumb — routing only, no business logic.

**Deliverable:** Interface specification — API schemas, event schemas, versioning strategy, compatibility guarantees, coupling classification.

### 7. Plan observability and resiliency

Ensure the new boundary is observable and resilient from the first production deployment.

**What to do:**

- Read and apply the **building-microservices** skill, sections: **Observability** and **Resiliency**.
- **Observability at the new boundary:**
  - Correlation IDs generated at intercept point, propagated through monolith ↔ new service calls.
  - Log aggregation includes both monolith and new service from first deployment.
  - Metrics and SLOs for the new service and the intercept/routing layer.
  - Synthetic transaction through the strangler fig path before cutover.
- **Resiliency at the new boundary:**
  - Timeouts on all calls between monolith and new service (based on healthy p99).
  - Circuit breakers on synchronous calls — fail fast to monolith fallback when new service unhealthy.
  - Separate connection pools per downstream.
  - **Degradation matrix**: if new service fails, feature toggle routes back to monolith (instant rollback).
  - Idempotency keys on mutations before enabling retries.

**Decision criteria:**

- The strangler fig's feature toggle **is** the primary degradation mechanism — plan it explicitly.
- Correlation IDs are easy at the start, hard to retrofit — implement before first production traffic.

**Deliverable:** Observability and resiliency plan — correlation strategy, metrics/SLOs, circuit breaker settings, degradation matrix, rollback triggers.

### 8. Validate

Verify the extraction plan meets Newman's principles.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Modeling Boundaries** (Boundary quality checklist, Coupling taxonomy).
- Read **building-microservices** skill, section: **Critical Anti-Patterns (Cross-Cutting)**.
- Run the **boundary quality checklist** on the planned new service:
  1. Can I change and deploy this service independently?
  2. Is related business behaviour co-located?
  3. Are cross-boundary assumptions minimised?
  4. Is internal state hidden?
  5. Does one service own each aggregate's lifecycle?
- Verify **independent deployability**: new service deploys without monolith deploy, and vice versa (during strangler fig phase).
- Check for **shared database traps**: no shared mutable tables without a migration timeline.
- Confirm no content coupling, no 2PC, no long sync chains introduced by the extraction.
- Validate that the plan is **incremental** — each step delivers production value and can be measured.

**Deliverable:** Validation report — checklist results, anti-pattern scan, shared-database risk assessment, incremental step verification.

### 9. Present extraction plan

Deliver the plan as a commit/action sequence for incremental extraction.

**What to do:**

- Apply **commit-conventions** and **objective-communication** skills to all plan text.
- Output the extraction plan in this structure:

```
## Extraction Plan: <Service Name> from <Monolith>

**Goal**: <one sentence> | **Candidate**: <area> | **Pattern**: strangler fig

### Summary

<1–3 sentences: what gets extracted, why, and expected outcome>

### Current State

<Monolith structure, candidate area, data ownership, coupling>

### Target State

<New service boundaries, data ownership, interface with monolith>

### Extraction Phases

| Phase | Type | Title | What | Key Files | Validation |
|-------|------|-------|------|-----------|------------|
| 1 | commit | `feat: add intercept proxy for <area>` | ... | ... | ... |
| 2 | commit | `feat: scaffold <service> with API contract` | ... | ... | ... |
| 3 | commit | `feat: route read traffic to <service> via toggle` | ... | ... | ... |
| ... | ... | ... | ... | ... | ... |

### Data Migration

<Phases, join replacements, saga design>

### Rollback Procedure

<Feature toggle off → monolith handles all traffic. Circuit breaker open → same.>

### Success Metrics

<How to measure each phase in production>

### Risks and Open Questions

<Explicit unknowns, stop conditions>
```

- Order phases **value-first** with **cost of delay** — ship the smallest increment that validates the extraction approach in production.
- Wait for approval before switching to Agent mode.

### 10. Switch to Agent mode

Once the user approves the extraction plan, switch to implementation.

**What to do:**

- Require **Agent** mode following the **mode-gate** skill. This is a mid-command mode transition — apply the full gate protocol (attempt, verify, stop if not active).
- Build the TODO list from the extraction plan following the **plan-execution** skill:
  - One `[commit]` TODO per planned commit, preserving order.
  - One `[action]` TODO per non-commit action.
- Execute each item in sequence. Do not batch commits.
- **Measure in production after each step**: deploy, observe metrics/logs, validate success criteria before proceeding to the next phase.
- If a step fails in production, stop and reassess — do not continue blindly. Feature toggle rollback is the first recovery action.

**Decision criteria:**

- Incremental adoption: turn the dial, don't flip the switch (building-microservices North Star).
- Each phase must leave the system in a deployable, working state.

### 11. Evolve

Follow the **continuous-improvement** skill.
