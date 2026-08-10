# Communication Templates Reference

Realistic good and bad examples for each tier in the **communication-templates** skill. Each example includes the principle mapping -- why the good version works and which principle the bad version violates.

---

## 1. PR Title

### Simple

Good:

```
Prevent session expiry during active requests
```

- **Delimit**: one concern, scoped precisely (session expiry + active requests).
- **Motivate**: the reader knows this prevents a specific failure mode.

Bad:

```
Fix auth
```

- Violates **Delimit** (what about auth?) and **Motivate** (why should the reviewer care?).

### Compound

Good:

```
Extract validation pipeline; add currency conversion
```

- **Delimit**: two concerns, both visible. The semicolon signals the split.
- The refactor enables the feature -- they can't be split into separate PRs.

Bad:

```
Extract validation pipeline and add currency conversion support and update tests and fix lint errors
```

- Violates **Delimit**: tests and lint fixes aren't separate concerns worth listing -- they belong with the commits that caused them.

---

## 2. PR Description

### Minimal

Good (for a dependency bump):

```
Bumps `fp-ts` from 2.16.0 to 2.16.5 to pick up the fix for the
TaskEither inference regression that broke our pipeline combinators.
```

- **Motivate**: explains why the bump matters (not just "updated dependency").
- **Delimit**: two sentences. The diff shows the version change; this explains the reason.

Bad:

```
Updated fp-ts.
```

- Violates **Motivate**: the reviewer has no reason to spend time verifying this is safe.

### Standard

Good (for a feature adding retry logic):

```
Order submissions were failing silently when the downstream pricing
service returned transient 503s. Users saw a generic error with no
recovery path.

This adds exponential backoff retry to the pricing client with a
3-attempt ceiling. Failed attempts are logged with correlation IDs
so ops can trace them. The retry wraps only the HTTP call -- domain
validation failures still fail fast.

- `PricingClient.ts` -- retry combinator around `fetchPrice()`
- `PricingClient.test.ts` -- tests for retry, exhaustion, and non-retryable errors
- `logging.ts` -- new `retryAttempt` log event with correlation ID
```

- **Motivate**: opens with the user-facing problem.
- **Delimit**: describes the net effect, not the commit-by-commit journey.
- **Concretise**: bullets name specific files and what changed in each.
- **Self-containment**: the description stands alone -- a reviewer doesn't need to read a ticket to understand the change.

Bad:

```
## Summary
Added retry logic to pricing client.

## Changes
- Added retry
- Added tests
- Updated logging

## Test Plan
- [x] Unit tests pass
- [x] Manual testing
```

- Violates **Motivate**: no explanation of why retry is needed.
- Violates **Structure**: the section headings are arbitrary scaffolding that adds no logical structure. "Summary" restates the title; "Changes" restates the diff; "Test Plan" checkboxes say nothing useful.
- Violates **Delimit**: "Added retry" is the diff restated in prose.

### Thorough

Good (for a cross-cutting refactor):

```
The order processing pipeline had three separate error-handling
strategies: try/catch in the HTTP layer, Either returns in the
domain layer, and callback-based error propagation in the event
handlers. This made error tracing across boundaries unreliable --
correlation IDs were lost at each translation point, and ops
couldn't follow a failed order from API request to event emission.

This PR unifies error handling on TaskEither throughout the pipeline.
Every operation returns TaskEither, errors carry correlation IDs
natively, and the HTTP layer translates to HTTP status codes at the
boundary only.

The approach preserves the existing function signatures at module
boundaries -- internal implementations change but the public API is
unchanged. An alternative (migrating to Effect-TS) was considered
but rejected: it would require rewriting consumers across three
services, and the TaskEither approach solves the tracing problem
without that blast radius.

Impact:
- Error logs now include correlation IDs end-to-end. Ops can trace
  a failed order from the API handler through domain processing to
  event emission.
- The event handler error callbacks are removed. Event handlers that
  previously swallowed errors now propagate them as TaskEither.left.
- No migration needed -- the module boundaries are unchanged.

Excluded from this PR:
- Retry logic (separate PR, depends on this one landing first).
- Metrics emission (tracked in work item #4521).
```

- **Motivate**: opens with the concrete problem (unreliable error tracing), not with the solution.
- **Anti-rationalism**: the alternative consideration is grounded in a concrete trade-off (blast radius), not an abstract principle.
- **Self-containment**: "Excluded" section prevents the reviewer from asking "what about retry?" -- the question is anticipated and answered.
- **Delimit**: reports the net effect (unified on TaskEither) rather than narrating the refactoring steps.

Bad:

```
I started by trying to use Effect-TS but it was too complex so I
switched to TaskEither. First I refactored the HTTP layer, then
the domain layer, then the event handlers. I had to fix a bunch
of type errors along the way. The tests needed updating too.
```

- Violates **Delimit**: narrates the journey instead of the destination (per **objective-communication** > Summarising Changes).
- Violates **Anti-rationalism**: "too complex" is a floating assessment -- what specifically was complex and why does it matter?
- Violates **Structure**: chronological narration of implementation steps isn't a logical structure.

---

## 3. Commit Message

### Subject-only

Good:

```
Correct off-by-one in date range calculation
```

- **Delimit**: names the exact defect and location.
- Subject is capitalized, imperative, no period, well under 50 characters.

Bad:

```
fix bug
```

- Violates **Delimit**: which bug? where?
- Violates rule 3: not capitalized.

### Subject + body

Good:

```
Add exponential backoff retry to pricing client

The pricing service returns transient 503s under load. Without
retry, these surface as user-facing errors with no recovery path.
Exponential backoff with a 3-attempt ceiling balances reliability
against latency -- the total worst-case delay is 7 seconds, which
is within the order submission SLA.
```

- **Self-containment**: the body answers "why retry?" and "why these parameters?" without requiring external context.
- **Structure**: first paragraph states the problem, second states the solution rationale.
- Body wraps at 72 characters, explains what and why (not how).

Bad:

```
Add retry logic

Added retry to pricing client.
```

- Violates **Self-containment**: the body restates the subject instead of explaining why.
- Violates **Delimit**: "retry logic" -- what kind? with what parameters?
- Violates rule 5: body uses past tense ("Added") instead of explaining the reasoning.

### Subject + body + context

Good:

```
Unify error handling on TaskEither

Three error-handling strategies coexisted: try/catch (HTTP layer),
Either returns (domain), and callbacks (event handlers). Correlation
IDs were lost at translation points.

TaskEither throughout the pipeline was chosen over Effect-TS because
it solves the tracing problem without requiring consumer rewrites
across three services. The public API at module boundaries is
unchanged -- only internal implementations migrate.

This sets the precedent that all new domain operations return
TaskEither. The pricing retry PR (next in sequence) depends on
this pattern being in place.
```

- **Structure**: problem -> approach rationale -> precedent, in logical order.
- **Anti-rationalism**: the alternative rejection is grounded in a concrete trade-off (consumer rewrites), not "Effect-TS is over-engineered."
- **Self-containment**: the precedent statement prevents future readers from asking "should I use this pattern too?"

---

## 4. Review Request (Slack)

### Routine

Good:

```
*PR #4523* -- adds exponential backoff retry to the pricing client
```

Bad:

```
PTAL
```

- Violates **Motivate**: the reviewer has zero context about what they're reviewing or why.

### Focused

Good:

```
*PR #4523* -- unifies error handling on TaskEither across the order pipeline

I'd appreciate a close look at the event handler migration in
`OrderEventHandler.ts` -- the callback removal changes the error
propagation path and I want to make sure I haven't missed an edge case.
```

- **Concretise**: names the specific file and concern.
- **Delimit**: scopes the ask to one area, not "please review everything."

### Urgent

Good:

```
*PR #4530* -- hotfix: prevent double-charge on order retry timeout

Production issue -- three customers were double-charged today when
the pricing service timed out during retry. This fixes the idempotency
check that was skipped on retry attempts.

Deploying to staging now; aiming to ship to prod by EOD. Could you
prioritise the retry logic in `PricingClient.ts` lines 45-80? The
rest is test coverage.
```

- **Motivate**: real customer impact makes the urgency concrete, not performative.
- **Delimit**: tells the reviewer where to spend limited time.
- **Concretise**: specific file and line range.

Bad:

```
URGENT PLEASE REVIEW ASAP!!!
*PR #4530*
```

- Violates **Motivate**: urgency without reason is noise. Why is it urgent? What's at stake?
- Violates **Concretise**: no summary, no guidance on where to focus.

---

## 5. PR Review Comment

### Nit

Good:

```
nit: `calculateTotal` -- `computeOrderTotal` would be clearer given
there are three other `calculate*` functions with different semantics
```

Bad:

```
nit: rename this
```

- Violates **Concretise**: rename to what?

### Suggestion

Good:

```
`retryCount` is tracked as mutable state that's incremented in the
catch block and checked in the while condition. This couples the
retry logic to the imperative loop structure.

A recursive approach with `retryCount` as a parameter would make
the retry ceiling explicit in the type signature and eliminate the
mutable state:

```ts
const withRetry = (n: number) => (fa: TE.TaskEither<E, A>):
  TE.TaskEither<E, A> =>
  n <= 0 ? fa : pipe(fa, TE.orElse(() => withRetry(n - 1)(fa)))
```
```

- **Objectivity**: states the problem (mutable state coupling) and why it matters.
- **Concretise**: shows the alternative as code, not just a description.

### Blocking

Good:

```
The idempotency key is generated from `orderId + timestamp`. On retry,
the timestamp changes, so each attempt gets a different idempotency
key. This means the downstream service treats retries as new requests.

In the current retry logic (`PricingClient.ts:52`), a 503 followed
by a successful retry will process the order twice if the first
attempt actually succeeded server-side but the response was lost.

The idempotency key should be generated once before the retry loop
and reused across attempts:

```ts
const idempotencyKey = generateKey(orderId, requestId) // stable across retries
```

Without this fix, every transient failure on a successful-but-unacknowledged
request results in a double-charge.
```

- **Objectivity (formulation)**: precisely describes what's wrong.
- **Anti-rationalism (evidence)**: traces the specific failure path rather than asserting "this is unsafe."
- **Objectivity (defence)**: states the consequence (double-charge).
- **Concretise**: shows the fix.

Bad:

```
This doesn't look safe.
```

- Violates **Concretise**: no alternative. Every abstraction is an IOU -- "unsafe" needs to be paid off with the specific failure mode and a fix.
- Violates **Objectivity**: no formulation (what specifically is unsafe?) and no defence (why does it matter?).

---

## 6. PR Review Reply

### Agree

Good:

```
Good catch -- renamed in abc1234.
```

```
Fixed. The recursive version is cleaner.
```

Bad:

```
Thank you for the excellent suggestion! You're absolutely right that
the mutable state approach couples the retry logic to the imperative
loop structure. I've gone ahead and refactored it to use the recursive
approach you suggested, which indeed makes the retry ceiling explicit
in the type signature. The updated code is in commit abc1234.
```

- Violates **Delimit**: restates the reviewer's entire point (they know what they said) and inflates a simple action into a paragraph.

### Disagree

Good:

```
The mutable state concern is valid in general, but here the retry
combinator is internal to `PricingClient` and the `retryCount`
scope is limited to a single function body (6 lines). The recursive
version adds a stack frame per attempt, which under our 100-attempt
ceiling for batch operations would risk a stack overflow.

I'd rather keep the loop here and extract it into a tested utility
if we need retry elsewhere.
```

- **Anti-rationalism**: the counter-argument is grounded in observable facts (stack frame risk at 100 attempts), not "I disagree with the principle."
- **Objectivity**: acknowledges the substance ("valid in general") without conceding the conclusion.

Bad:

```
I agree mutation is generally bad, but I think it's fine here.
```

- Violates **Anti-rationalism**: concedes the premise ("mutation is bad") then claims an exception without evidence. Either challenge the premise or provide specific evidence for why this case differs.

### Clarify

Good:

```
I'm not sure I follow -- are you saying the idempotency key should
be derived from the request payload instead of the orderId, or that
the key generation should happen outside the retry loop?
```

Bad:

```
I don't think that's an issue because the idempotency key is generated
correctly and the retry logic handles all edge cases.
```

- Violates **Objectivity**: asserting correctness against an objection you haven't understood. The reviewer may be pointing at a real problem -- ask first.

---

## 7. Work Item Title

### Bug

Good:

```
Order total displays as $0.00 when currency conversion fails silently
```

- **Concretise**: observable symptom ($0.00), specific location (order total), trigger condition (currency conversion failure).

Bad:

```
Bug in order total calculation
```

- Violates **Concretise**: no observable symptom. "Bug" is the item type -- repeating it in the title is noise.

### Feature

Good:

```
Support browsing large order lists with cursor-based pagination
```

- **Motivate**: user-facing outcome (browsing large lists).
- **Delimit**: scoped to a specific technique (cursor-based pagination).

Bad:

```
Add pagination to OrderList
```

- Violates **Motivate**: no user-facing outcome. Why does the user care about pagination?
- Describes implementation (`OrderList` component), not the outcome.

### Task

Good:

```
Extract retry combinator from PricingClient for reuse in BatchProcessor
```

- **Delimit**: scoped to a specific deliverable (extract and reuse in one named location).

Bad:

```
Refactor retry logic
```

- Violates **Delimit**: refactor how? for what purpose? The title is self-contained only if the reader already knows the context.

---

## 8. Work Item Description

### Bug (minimal)

Good:

```
When a user views an order with a non-USD currency and the currency
conversion API returns a 500, the order total displays as $0.00
instead of showing the unconverted amount with a warning.

Repro:
1. Create an order with EUR currency
2. Disconnect from the currency conversion service (or return 500)
3. View the order detail page

Expected: order total shows the EUR amount with a conversion
unavailable indicator.
Actual: order total shows $0.00.

Severity: high -- affects all non-USD orders during conversion
service outages (last one was 3 hours on Monday).
```

- **Concretise**: exact symptom, numbered repro steps, expected vs. actual.
- **Motivate**: severity grounded in a real incident (Monday's outage), not abstract urgency.
- **Self-containment**: a developer can reproduce this without asking any questions.

### Feature

Good:

```
Users with 500+ orders can't find specific orders without scrolling
through the full list. The current implementation loads all orders
on page render, which causes 3-5 second load times for large
accounts and browser memory pressure above 1000 orders.

Scope:
- Add cursor-based pagination to the order list endpoint and UI.
- Load 50 orders per page with infinite scroll.
- Preserve existing sort and filter behaviour within paginated results.
- Excluded: search/typeahead (separate work item), export (not affected).

Acceptance criteria:
- Order list loads <=50 orders initially, with a < 500ms response time.
- Scrolling to the bottom loads the next page without a full re-render.
- Sort and filter controls operate on the server-side query, not the
  loaded page.
- The "no more orders" state is visually indicated.
```

- **Motivate**: opens with the user pain (can't find orders, slow load times).
- **Delimit**: explicit scope boundaries and exclusions.
- **Concretise**: acceptance criteria are observable and testable (500ms, 50 orders, no re-render).
- **Self-containment**: an implementer can start work without chasing context.

---

## 9. Slack Status Update

### Routine

Good:

```
Merged *PR #4523* -- retry logic is on `develop`.
```

### Significant

Good:

```
*PR #4530* is on staging -- the double-charge hotfix.

The idempotency key is now stable across retries, so the pricing
service won't process duplicate requests. Need a sign-off from ops
before pushing to prod. @jane can you verify the order logs look
clean on staging?
```

- **Motivate**: explains what changed and why the recipient should act.
- **Concretise**: names the specific fix and the verification ask.
- **Delimit**: doesn't recap the entire investigation -- the recipient has context from the earlier thread.

Bad:

```
So we had this issue where customers were getting double-charged
because the idempotency key was being regenerated on each retry
attempt. The root cause was that the key included a timestamp
component which changed between retries. I fixed this by generating
the key once before the retry loop and passing it through. The PR
is #4530 and it's been deployed to staging. Please review when you
get a chance.
```

- Violates **Delimit**: recaps the entire investigation that the recipient already followed in the previous thread.
- Violates **Structure**: the ask (review) is buried at the end.

---

## 10. Slack Thread Answer

### Quick

Good:

```
`PricingClient.ts:52` -- the retry ceiling is set in `MAX_RETRIES`.
```

Bad:

```
That's a great question! So the retry ceiling is configured in the
PricingClient module. Let me walk you through how it works...
```

- Violates **Delimit**: the questioner asked where, not how.
- Violates **writing-style**: "Great question!" is a banned helpful-assistant pattern.

### Detailed

Good:

```
The retry doesn't trigger for 4xx errors -- only 5xx and network
timeouts.

The check is in `PricingClient.ts:58`:
```ts
const isRetryable = (e: Error): boolean =>
  e instanceof NetworkError || (e instanceof HttpError && e.status >= 500)
```

4xx errors (including 429 rate limits) fall through to the error
handler without retry. If we want to retry 429s, that's a separate
change -- the backoff timing should respect the `Retry-After` header
rather than using our exponential schedule.
```

- **Structure**: direct answer first, then evidence, then elaboration.
- **Concretise**: shows the exact code that governs the behaviour.
- **Self-containment**: anticipates the follow-up question (what about 429s?) and addresses it.
