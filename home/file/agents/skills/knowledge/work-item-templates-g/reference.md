# Work Item Templates Reference

Extended examples for each tier and type. Each example shows the ADO field content and maps to objective-communication principles.

---

## 1. Bug Examples

### Simple

**Title** (`System.Title`):

```
Order total displays as $0.00 when currency conversion times out
```

- Concretise: observable symptom ($0.00), specific location (order total), trigger (conversion timeout).

**ReproSteps** (`Microsoft.VSTS.TCM.ReproSteps`):

```
**Steps to reproduce**
1. Create an order with EUR currency
2. Disconnect from the currency conversion service (or force a 500)
3. View the order detail page

**Expected:** order total shows the EUR amount with a conversion-unavailable indicator.

**Actual:** order total shows $0.00.
```

- Self-containment: a developer can reproduce without asking questions.
- Concretise: numbered steps from a known starting state.

**Severity**: `2 - High` (affects all non-USD orders during conversion outages).

**Bad example:**

Title: `Bug in order total calculation`
- Violates Concretise (no symptom) and Delimit ("Bug" is the item type, not information).

ReproSteps: `The order total is wrong sometimes.`
- Violates Self-containment (no repro steps), Concretise (no specifics).

---

### Standard

**Title** (`System.Title`):

```
Portfolio allocation chart renders empty for accounts with 50+ holdings
```

**ReproSteps** (`Microsoft.VSTS.TCM.ReproSteps`):

```
**Environment**
Chrome 126, Windows 11, build 4.12.3, connected to staging

**Steps to reproduce**
1. Log in as `test-user-large-portfolio` (has 73 holdings)
2. Navigate to Portfolio > Allocation
3. Wait for the chart to render

**Expected:** pie chart displays allocation percentages for all holdings, grouped by asset class.

**Actual:** chart area is blank. Console shows `TypeError: Cannot read properties of undefined (reading 'map')` at `AllocationChart.tsx:142`.

**Frequency:** Always -- reproduces on every load for accounts with 50+ holdings. Accounts with fewer holdings render correctly.

**Evidence**
- Console error screenshot (attached)
- Network response shows the API returns all holdings correctly -- the issue is client-side rendering
```

- Self-containment: environment, steps, expected/actual, frequency, and evidence.
- Anti-rationalism: the frequency narrows the investigation scope. The evidence rules out the API.
- Objectivity: severity/frequency grounded in observable data (50+ threshold, every load).

---

### Investigated

**Title** (`System.Title`):

```
Portfolio allocation chart renders empty for accounts with 50+ holdings
```

**ReproSteps** (`Microsoft.VSTS.TCM.ReproSteps`): same as Standard above.

**Description** (`System.Description`):

```
**Root cause**
`AllocationChart.tsx:142` calls `.map()` on `groupedHoldings` without
a null check. The `groupByAssetClass()` utility returns `undefined`
when the input array exceeds the internal chunk size of 50 (a legacy
constant from the V1 charting library that was never updated for V2).

**Proposed fix**
Remove the chunk-size limit in `groupByAssetClass()` -- it was a
rendering optimization for canvas-based charts that doesn't apply to
the current SVG renderer. Add a null guard in `AllocationChart` as
defensive coding regardless.

Alternative considered: paginating the chart at 50 holdings. Rejected
because the business requirement is to show the full allocation at a
glance.

**Affected areas**
- `AllocationChart.tsx` -- null guard
- `groupByAssetClass.ts` -- remove chunk limit
- `AllocationChart.test.tsx` -- add test for 50+ holdings
```

- Anti-rationalism: root cause is grounded in specific code locations and observable behavior, not "something is wrong with the chart."
- Structure: root cause -> fix -> affected areas, in logical order.
- Self-containment: the description stands alone for a developer picking up the fix.

---

## 2. Task Examples

### Simple

**Title** (`System.Title`):

```
Add null guard to AllocationChart groupedHoldings mapping
```

**Description** (`System.Description`):

```
Prevent `TypeError` when `groupByAssetClass()` returns undefined for
large portfolios (50+ holdings).

**Done when:**
- `AllocationChart.tsx` handles undefined `groupedHoldings` without throwing
- Existing tests pass
```

**OriginalEstimate**: 2 hours
**Activity**: Development

---

### Standard

**Title** (`System.Title`):

```
Extract retry combinator from PricingClient for reuse in BatchProcessor
```

**Description** (`System.Description`):

```
**Goal:** make the exponential-backoff retry logic in `PricingClient`
reusable across HTTP clients. `BatchProcessor` needs the same retry
pattern with different ceiling and backoff parameters.

**Context:** both `PricingClient` and `BatchProcessor` independently
implement retry with slight variations. Consolidating reduces
duplication and ensures consistent retry behavior (correlation IDs,
logging, backoff curve).

**Approach:** extract a generic `withRetry` combinator as a
`TaskEither` wrapper. Parameterize ceiling, backoff base, and
retryable-error predicate. Replace inline retry in both clients.

**Scope:**
- In scope: extraction, replacement in PricingClient and BatchProcessor
- Excluded: retry for WebSocket connections (different reconnect pattern)

**Done when:**
- `withRetry` combinator exists with configurable ceiling/backoff
- `PricingClient` and `BatchProcessor` use the combinator
- Unit tests cover retry, exhaustion, and non-retryable error paths
```

**OriginalEstimate**: 6 hours
**Activity**: Development

---

### Complex (decomposed)

When a task is Complex, the agent recommends decomposition. The original task becomes a container with child subtasks:

**Original (too large):**

Title: `Unify error handling across the order processing pipeline`

The agent would recommend splitting into:

1. Task: `Migrate HTTP layer error handling from try/catch to TaskEither` (4h)
2. Task: `Migrate domain layer from Either returns to TaskEither` (6h)
3. Task: `Replace event handler callbacks with TaskEither propagation` (6h)
4. Task: `Add end-to-end correlation ID threading through TaskEither chain` (4h)

Each subtask is independently deliverable and under 8 hours.

---

## 3. User Story Examples

### Simple

**Title** (`System.Title`):

```
Display last-updated timestamp on portfolio summary page
```

- Motivate: user-facing outcome (seeing when data was refreshed).
- Delimit: scoped to one page (portfolio summary).

**Description** (`System.Description`):

```
Users checking their portfolio have no way to tell how fresh the data
is. During market hours, stale data could lead to incorrect trading
decisions.
```

- Motivate: opens with the user pain, not the solution.
- Delimit: states the problem, not the implementation.

**AcceptanceCriteria** (`Microsoft.VSTS.Common.AcceptanceCriteria`):

```
- [ ] Portfolio summary page shows a "Last updated: <timestamp>" label
- [ ] Timestamp reflects the most recent data fetch, not page load time
- [ ] Timestamp updates when the user manually refreshes
```

---

### Standard

**Title** (`System.Title`):

```
Support browsing large order lists with cursor-based pagination
```

**Description** (`System.Description`):

```
Users with 500+ orders can't find specific orders without scrolling
through the full list. The current implementation loads all orders on
page render, causing 3--5 second load times for large accounts and
browser memory pressure above 1000 orders.

**Scope**
- Add cursor-based pagination to the order list endpoint and UI
- Load 50 orders per page with infinite scroll
- Preserve existing sort and filter behavior within paginated results

**Excluded:** search/typeahead (separate work item), export (not affected).
```

- Motivate: opens with measurable user pain (3--5s load, memory pressure).
- Delimit: explicit scope and exclusions.
- Self-containment: an implementer can start without chasing context.

**AcceptanceCriteria** (`Microsoft.VSTS.Common.AcceptanceCriteria`):

```
**Core flow**
Given a user with 500+ orders
When they open the order list
Then the first 50 orders load in under 500ms

Given the user scrolls to the bottom of the loaded orders
When more orders exist
Then the next 50 orders load without a full page re-render

**Additional conditions**
- [ ] Sort and filter controls operate on the server-side query, not the loaded page
- [ ] "No more orders" state is visually indicated when the last page is reached
- [ ] Existing bookmarked URLs with filter parameters continue to work
```

- Concretise: AC are observable and testable (500ms, 50 orders, no re-render).
- Given/When/Then for state-dependent behavior (scrolling triggers load).
- Checklist for independent rules (sort, empty state, URL compatibility).

---

### Complex (split)

**Original (too large):**

Title: `Enable multi-currency support for order management`

This would fail INVEST (Small) at 13+ story points. The agent would recommend vertical splits:

1. Story: `Display order totals in the order's native currency` (3 pts)
2. Story: `Convert order totals to the user's preferred display currency` (3 pts)
3. Story: `Show currency conversion rate and source on order detail` (2 pts)
4. Story: `Handle currency conversion service unavailability gracefully` (3 pts)
5. Spike: `Evaluate real-time vs. daily-rate conversion trade-offs` (time-boxed 4h)

Each slice is independently valuable and testable. The spike resolves unknowns before the implementation stories enter a sprint.

---

## Tier selection decision tree

```
Is the item's scope obvious from the title alone?
  +-- YES: Can it be completed in under 4h (Task) / 3 pts (Story)?
  |     +-- YES --> Simple
  |     +-- NO --> Standard
  +-- NO: Does it span multiple layers, contexts, or have 5+ AC?
        +-- YES --> Complex (decompose/split)
        +-- NO --> Standard
```

For Bugs, the tier depends on investigation state:
- No investigation done, clear repro -> Simple
- Full environmental context, frequency data -> Standard
- Root cause identified, fix proposed -> Investigated
