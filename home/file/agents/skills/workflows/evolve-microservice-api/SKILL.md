---
name: evolve-microservice-api
description: Safely manage API evolution, especially breaking changes. Plan mode for design, then Agent mode for implementation. Covers impact assessment, expand-and-contract pattern, consumer migration, endpoint deprecation, and validation. Based on Newman's emphasis that independent deployability lives or dies at the API boundary.
disable-model-invocation: true
---

# Evolve Microservice API

Safely evolve a microservice's external API — especially when breaking changes are unavoidable. Independent deployability lives or dies at the API boundary: a producer can deploy freely only if consumers tolerate the change. This command uses **Plan** mode for impact assessment and migration design, then **Agent** mode for implementation.

## Input

Accept **any** of the following:

1. **Change description** — what is changing, why, and which endpoint(s) or event schema(s) are affected.
2. **Ticket or design document** — Azure DevOps work item, RFC, or linked specification. Fetch via MCP when applicable.
3. **Consumer context** — known consumers, team ownership, migration deadlines, or regulatory constraints.

When the change scope is ambiguous, ask clarifying questions before proceeding.

## Steps

### 1. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. Steps 2–10 are read-only analysis, impact assessment, and migration planning. Step 11 switches to **Agent** mode for implementation of steps 5–9.

Apply the **objective-communication** skill to all deliverable prose in steps 2–10.

### 2. Understand the change

Determine exactly what is changing and whether it truly requires a breaking change.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Communication Design** (tolerant reader, expand-and-contract, semantic versioning, consumer-first).
- Document the **proposed change** precisely:
  - Which endpoint(s), event schema(s), or field(s) are affected?
  - What is the business driver (new capability, bug fix, performance, regulatory)?
  - What is the desired end state?
- Classify the change type:

| Change type | Description | Breaking? |
|-------------|-------------|-----------|
| **Expansion (additive)** | New optional field, new endpoint, new event type | No — backward compatible |
| **Contraction (removal)** | Remove field, rename field, change type, change semantics | Yes — requires migration |
| **Semantic change** | Same schema, different behaviour | Often yes — treat as breaking |

- Apply Newman's rule: **"Add only; don't remove."** Ask explicitly: *Can this be an expansion (additive) change instead of a breaking change?*
  - Can the new behaviour be exposed via a new optional field with a default?
  - Can a new endpoint coexist alongside the old one?
  - Can consumers use tolerant reader (Postel's law) — consume only needed fields, ignore unknown fields?
- If the change is additive, plan expansion only — skip to step 6 (implement new capability) without deprecation workflow.
- Assign **semantic version** impact: MAJOR = breaking, MINOR = backward-compatible addition, PATCH = bug fix.

**Decision criteria:**

| Question | If yes | If no |
|----------|--------|-------|
| Can old consumers continue working unchanged? | Expansion path — no migration needed | Breaking change path — continue to step 3 |
| Is removal/rename/type-change involved? | Breaking — plan expand-and-contract | — |
| Does behaviour change for existing fields? | Treat as breaking unless proven compatible | — |

**Deliverable:** Change classification — proposed change description, expansion vs breaking determination, semantic version impact, rationale for classification.

### 3. Assess impact

Identify every consumer that would break if the change shipped today.

**What to do:**

- Enumerate **all consumers** of the affected endpoint(s) or event schema(s):
  - Internal microservices (check service catalogue, architecture docs, dependency graphs).
  - Client applications (mobile, web, BFFs).
  - Third-party integrations.
- Gather evidence of consumer usage:
  - **API gateway logs** — request paths, client identifiers, traffic volume per consumer.
  - **Client identifiers** — require and review `X-Client-Id`, `User-Agent`, or equivalent headers already captured in logs.
  - **CDC test coverage** — which consumers have Pact contracts? Which consumers lack contract coverage (higher risk)?
  - **Code search** — find direct references to affected endpoints/schemas across repositories.
- For each consumer, document:
  - Team ownership and contact.
  - Usage volume (requests/day or events/day).
  - Whether they would break on the proposed change.
  - Estimated migration effort.
- Produce a **breakage matrix**: every consumer × every affected endpoint, with break/not-break determination.

**Decision criteria:**

- If consumer list is incomplete, treat unknown consumers as potential breakages — do not proceed to removal without usage monitoring.
- Consumers without CDC coverage are higher risk — flag for manual verification or new contract creation.
- Zero-traffic endpoints may still have dormant integrations — check historical logs, not just recent traffic.

**Deliverable:** Impact assessment — consumer inventory, breakage matrix, usage data sources, CDC coverage gaps, risk-ranked consumer list.

### 4. Choose strategy

Select the migration approach based on team ownership and required migration timeline.

**What to do:**

- Apply the **breaking change decision table**:

| Situation | Strategy | Notes |
|-----------|----------|-------|
| Same team owns service **and** all consumers | **Lockstep release** OK as one-off | Acceptable only when one team controls entire blast radius; not a pattern to repeat |
| Need consumer migration time (days–weeks) | **Endpoint emulation** (old + new in same service) | **Preferred approach** — deploy new endpoint alongside old; migrate consumers at their pace |
| Canary/blue-green deployment (minutes–hours) | **Coexist service versions** briefly | Deploy V1 and V2 service instances simultaneously; route traffic by version header or path |
| Any situation | **Avoid coexisting 3+ endpoint versions** | Complexity compounds; two versions (old + new) is the maximum sustainable state |

- For **endpoint emulation** (preferred):
  - New endpoint (e.g. `/v2/orders`) deployed alongside old (`/v1/orders`) in the **same service**.
  - Old endpoint may internally delegate to new logic with transformation, or maintain separate code paths temporarily.
  - Old endpoint removed only after confirmed zero traffic (step 9).
- For **expand-and-contract** on schemas (non-URI changes):
  1. **Expand** — add new field/endpoint; old consumers unaffected.
  2. **Migrate** — consumers adopt new field/endpoint.
  3. **Contract** — remove old field/endpoint after migration complete.
- Document the chosen strategy with rationale tied to the impact assessment from step 3.

**Decision criteria:**

| Factor | Lean toward endpoint emulation | Lean toward lockstep |
|--------|-------------------------------|-------------------|
| Consumer teams | Multiple teams | Single team owns all |
| Migration timeline | Weeks or more | Same-day deploy |
| Consumer count | Many | One or two |
| Traffic volume | High — blast radius matters | Low — controlled rollout |

**Anti-patterns:** removing old endpoint before consumers migrate; deploying breaking change without migration plan; maintaining 3+ concurrent API versions indefinitely.

**Deliverable:** Strategy document — chosen approach, timeline, version coexistence plan, expand-and-contract phases if applicable.

### 5. Define social contract

Document the change and migration expectations for all consumer teams before any implementation begins.

**What to do:**

- Apply **consumer-first approach** from the **building-microservices** skill, section: **Communication Design**.
- Draft a **social contract** document containing:
  - **What is changing** — precise description of old vs new behaviour/schema.
  - **Why** — business justification consumers need to prioritise migration.
  - **Migration timeline** — start date, deadline for consumer migration, deadline for old endpoint removal.
  - **Who does the migration work** — which team updates each consumer (usually the consumer team for their client; producer team for shared SDKs).
  - **How to raise concerns** — channel, contact person, escalation path.
  - **Support offered** — migration guide, office hours, SDK updates, test environment access.
  - **Deadline for old endpoint removal** — explicit date; never open-ended.
- Apply the **external-communications** skill for drafting:
  - Present the complete message for user approval before posting to any channel.
  - Post to affected consumer team channels, work items, or mailing lists only after approval.
- Version the social contract — update it if timeline or scope changes.

**Decision criteria:**

- No implementation of breaking changes without a communicated social contract (unless lockstep with same team).
- Timeline must include buffer for consumer testing — not just code changes.
- Consumer teams must acknowledge receipt or confirm migration plan before old endpoint removal date is finalised.

**Deliverable:** Social contract document — ready for approval and distribution to all affected consumer teams.

### 6. Implement new endpoint

Plan the new API surface alongside the old one, with schema compatibility enforcement in CI.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Communication Design** (expand-and-contract, explicit schemas).
- Deploy the **new endpoint alongside the old** in the same service:
  - Version via URI path (e.g. `/v2/orders`) **or** via headers (e.g. `Accept: application/vnd.company.orders.v2+json`). Prefer URI versioning for clarity.
  - Old endpoint continues serving existing consumers unchanged.
- Add **schema compatibility checks to CI**:
  - REST/OpenAPI → `openapi-diff`, oasdiff, or equivalent; fail CI on incompatible changes without explicit override.
  - gRPC/protobuf → Protolock or buf breaking change detection.
  - Events → AsyncAPI diff or schema registry compatibility checks.
  - CDC → Pact provider verification for all consumer contracts.
- **Update CDC tests** for the new contract:
  - Existing consumers keep their V1 contracts passing against the old endpoint.
  - New V2 contracts added for migrated consumers.
  - Producer CI runs all contracts on every build.
- Implement **tolerant reader** on the new endpoint if it consumes data from other services.
- Ensure **good-citizen baseline** on the new endpoint: health, logging, metrics, circuit breakers, timeouts, idempotency keys, correct status codes.

**Decision criteria:**

- New endpoint must not break old endpoint behaviour.
- CI must fail on accidental breaking schema changes.
- Both endpoints must appear in observability dashboards with separate metric tags (version label).

**Deliverable:** New endpoint specification — URI/header versioning choice, schema definitions, CI compatibility check configuration, CDC test plan.

### 7. Track migration

Monitor consumer adoption of the new endpoint and old endpoint traffic decline.

**What to do:**

- Ensure **client identifiers** are logged on every request to both old and new endpoints (`X-Client-Id`, `User-Agent`, API key metadata).
- Build or configure a **migration dashboard** showing:
  - Traffic volume per endpoint version (V1 vs V2) over time.
  - Per-consumer breakdown — which consumers still call V1?
  - Migration progress percentage (consumers migrated / total consumers).
  - Error rates on both endpoints.
- Set **alerts for deadline proximity**:
  - Alert when deadline is N days away and V1 traffic remains above threshold.
  - Alert when a consumer unexpectedly resumes V1 traffic after migrating.
- Review dashboard weekly (or daily near deadline) and share progress with consumer teams.

**Decision criteria:**

| Signal | Action |
|--------|--------|
| Consumer still on V1, deadline approaching | Escalate to consumer team lead |
| V1 traffic at zero for 7+ consecutive days | Candidate for deprecation (step 9) |
| New consumer appears on V1 after V2 launch | Investigate — may be undeclared consumer from step 3 |
| V2 error rate elevated | Pause migration promotion; fix before encouraging more consumers |

**Deliverable:** Migration tracking plan — dashboard queries/panels, alert rules, review cadence, escalation triggers.

### 8. Support consumer migration

Help consumers move to the new endpoint at their own pace (within the agreed deadline).

**What to do:**

- Publish a **migration guide** containing:
  - Side-by-side comparison of old vs new endpoint (request/response examples).
  - Field mapping table for schema changes.
  - Code examples for common client languages/frameworks.
  - Known behavioural differences and edge cases.
  - Testing instructions (how to verify migration in staging).
- **Update client SDKs** if the organisation maintains shared SDKs:
  - SDK consumers control upgrade timing — publish new SDK version; do not force upgrade until deadline.
  - Maintain SDK support for both V1 and V2 until deprecation.
- **Run consumer CDC tests** against the new endpoint:
  - Help consumer teams write V2 Pact contracts.
  - Verify consumer contracts pass against V2 in CI before they switch production traffic.
- Offer **test environment access** with both endpoints available for consumer integration testing.
- Track migration status per consumer in the dashboard from step 7.

**Decision criteria:**

- Producer team supports migration; consumer team executes their client changes (unless same team — then producer does both).
- No consumer should be forced to migrate without a working migration guide and test environment.
- SDK updates must be backward compatible until V1 deprecation.

**Deliverable:** Migration guide, updated SDKs (if applicable), consumer migration status tracker, CDC test results per consumer.

### 9. Deprecate old endpoint

Remove the old endpoint only after confirmed migration completion.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Communication Design** (expand-and-contract contraction phase, consumer-first).
- **Pre-removal checklist** — all must be true before removing the old endpoint:
  1. Zero traffic on old endpoint for a sustained period (minimum 7 consecutive days, or agreed threshold).
  2. **Or** deadline reached **with explicit consumer agreement** that remaining consumers accept breakage.
  3. All CDC V1 contracts removed or migrated to V2.
  4. Migration dashboard confirms no active consumers on V1.
  5. Social contract deadline has passed or been explicitly extended with re-communication.
- **Never remove while consumers are still calling** — this destroys independent deployability for those consumers.
- Removal steps:
  1. Announce final removal date (minimum 48 hours notice even after zero traffic confirmed).
  2. Remove old endpoint route/handler.
  3. Clean up internal V1→V2 transformation chains, adapter code, and dual-path logic.
  4. Remove V1 schema definitions and V1 CDC contracts.
  5. Update documentation, SDKs, and API catalogue to reflect V2 only.
- Deploy removal as a normal service deployment — monitor error rates post-removal.

**Decision criteria:**

| Condition | Proceed with removal? |
|-----------|----------------------|
| Zero V1 traffic for 7+ days | Yes |
| V1 traffic from unknown client | No — investigate first |
| Deadline reached, consumer agreed | Yes, with documented agreement |
| Deadline reached, consumer silent but still calling | No — escalate, do not remove |
| V1 traffic from known consumer near deadline | No — direct outreach required |

**Anti-patterns:** removing endpoint because the code is messy; removing before checking gateway logs; assuming silence equals migration complete.

**Deliverable:** Deprecation execution plan — pre-removal checklist results, removal announcement, cleanup scope, post-removal monitoring plan.

### 10. Validate

Confirm the API evolution completed without consumer breakage.

**What to do:**

- Read and apply the **building-microservices** skill, section: **Critical Anti-Patterns (Cross-Cutting)** and **Communication Design**.
- Verify **all CDC tests pass** — V2 contracts green on producer CI; no orphaned V1 contracts failing.
- Confirm **no consumer breakage**:
  - Check error rates across all known consumers post-migration and post-removal.
  - Review support channels for migration-related incidents.
  - Confirm API gateway logs show expected V2-only traffic.
- Monitor **error rates post-removal** for 48–72 hours:
  - 404 spikes may indicate undeclared consumers still calling V1.
  - 5XX spikes may indicate V2 bugs exposed by increased traffic.
- Re-run the **independent deployability check**: can this service now deploy API changes without coordinating with consumers (for future additive changes)?

**Decision criteria:**

- If 404s appear on removed V1 paths after deprecation, treat as incident — investigate undeclared consumer and assess rollback options.
- Validation is not complete until post-removal monitoring window passes without anomalies.

**Deliverable:** Validation report — CDC results, consumer error rate summary, post-removal monitoring results, lessons learned.

### 11. Switch to Agent mode

Transition from planning to implementation of the migration work.

**What to do:**

- Require **Agent** mode following the **mode-gate** skill. Verify the mode switch before proceeding.
- Present the complete plan from steps 2–10 for user approval. Wait for approval before writing code.
- Implement steps **5 through 9** following the **plan-execution** skill:
  1. Build a TODO list with one `[commit]` item per logical commit and `[action]` items for non-commit work (e.g. post social contract, configure dashboard).
  2. Execute in order:
     - **Step 5** — draft and get approval for social contract (`[action]`); distribute after approval.
     - **Step 6** — implement new endpoint, CI compatibility checks, CDC tests (`[commit]` items).
     - **Step 7** — configure migration tracking dashboard and alerts (`[action]` or `[commit]`).
     - **Step 8** — publish migration guide, update SDKs (`[action]` and `[commit]` items).
     - **Step 9** — deprecate old endpoint only when pre-removal checklist passes (`[commit]`).
  3. Do not remove the old endpoint in the same commit as adding the new one — separate commits for expand and contract phases.
  4. Run validation (step 10) after implementation completes.

**Decision criteria:**

- Steps 2–4 and 10 remain Plan-mode analysis even in Agent mode if revisited — do not skip impact assessment because implementation has started.
- Do not mark the command complete until step 10 validation passes.

**Deliverable:** Evolved API with consumers migrated, old endpoint removed (or migration in progress with tracking active), all tests green.

### 12. Evolve

Follow the **continuous-improvement** skill.
