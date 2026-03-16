---
name: design-lenses
description: Three design lenses (refactoring, flexibility, architecture) for evaluating structural changes. Provides a planning framing for generating plans and a review framing for evaluating plans or PRs. Use whenever the agent plans, reviews a plan, or reviews a PR that warrants design-level evaluation.
---

# Design Lenses

Three lenses for evaluating the design of a structural change. Each lens examines a different dimension; not every principle within a lens will be relevant to every change.

Commands that generate plans use the **planning framing** (principles and questions). Commands that evaluate plans or PRs use the **review framing** (questions and red flags).

## Refactoring lens

Evaluates structural transformations through the **refactoring** skill's core principles.

### Planning framing

| Principle | Question to ask |
|---|---|
| **Preserve behavior** | Does every step keep the code doing exactly what it does today? |
| **Small steps** | Is each transformation a single, testable change? |
| **Two hats** | Are we purely restructuring -- no new behavior mixed in? |
| **Tests first** | Do adequate tests exist to catch regressions? If not, add them first. |

For each structural change, select techniques from the **refactoring** skill catalog. Reference each technique by its catalog name (e.g. Extract Module, Move Function, Introduce Branded Type). Apply the **functional-typescript** skill to ensure the target structure aligns with fp-ts standards and architectural principles.

### Review framing

| Question | Red flag |
|----------|----------|
| Does it preserve behaviour? | Commit description implies new behaviour alongside restructuring |
| Is it a single, testable transformation? | Commit bundles multiple refactoring techniques |
| Does it name a recognised technique from the **refactoring** skill? | Technique column is blank or vague |
| Are prerequisite tests in place before the refactoring commits? | Test commits come after the refactorings they protect |

## Flexibility lens

Evaluates architectural choices through principles adapted from Hanson & Sussman, *Software Design for Flexibility*.

### Planning framing

| Principle | Question to ask | FP / TypeScript idiom |
|---|---|---|
| **Additive programming** | Can this change be a pure addition -- no modification to existing code? | New module, new union variant, new handler |
| **Combinators** | Do the new parts share a uniform interface so they compose freely with existing parts? | `pipe`, `flow`, same `(input) => Output` shape |
| **Generic dispatch** | Should this extend an existing discriminated union + `fold` rather than add conditionals? | Widen union, add match arm |
| **Domain-specific language** | Does this domain deserve its own set of primitives, combinators, and abstractions? | Builder functions, interpreter pattern |
| **Layering** | Can metadata (provenance, units, audit) travel alongside data without the core knowing? | Branded types, `Reader`, layered records |
| **Degeneracy** | Are there independent paths to the same result that improve robustness or testability? | Multiple codec/strategy implementations |
| **Postel's law** | Does each function accept the widest reasonable input and produce the narrowest output? | Validate with `io-ts` at the boundary; return precise types |
| **Exploratory behavior** | Is generate-and-test more appropriate than imperative control flow? | Lazy `Task` pipelines, `Array.filter` chains |
| **Propagation** | Can partial information from independent sources be merged for a better result? | `TaskEither` composition, `Semigroup` merge |
| **Minimal assumptions** | What assumptions are we baking in? Can we parameterize instead? | Generic type params, function arguments over hard-coded values |

Not every principle applies to every change. Call out the 2--3 that matter most and explain how the plan honours them.

### Review framing

- Are the chosen principles (2--3) genuinely the most relevant for this change?
- Does the plan or PR honour them in practice, or only name-drop them?
- Are there principles that should have been applied but weren't?

## Architecture lens

Evaluates significant design choices through principles from the **architect-thinking** skill.

### Planning framing

| Principle | Question to ask |
|---|---|
| **Options** | Does this design preserve future options? Are irreversible decisions deferred or minimised? |
| **Rate of change** | Does this area change frequently? Does the plan reduce friction for future changes here? |
| **Fit for purpose** | Is the architecture appropriate for the actual constraints, not just "good practice"? |
| **Use before reuse** | Are we building from a concrete use case, or speculatively creating reusable infrastructure? |
| **Systems effects** | Could this change trigger unintended feedback loops or system-level side effects? |
| **Cost of delay** | Does the plan sequence work to deliver value early, or does it front-load infrastructure? |

Not every principle applies to every change. Call out those that matter most and explain how the plan honours them.

### Review framing

| Question | Red flag |
|----------|----------|
| Are irreversible decisions minimised? | Locks in a technology, schema, or API shape that could have been deferred |
| Are stated assumptions questioned? | Accepts "requirements" at face value without asking why |
| Is it built top-down from a use case? | Starts with infrastructure or reusable components before a concrete consumer exists |
| Is cost of delay considered in sequencing? | High-value steps are buried behind preparatory work that could be parallelised |
| Are systems effects acknowledged? | Changes a shared component without assessing downstream impact or feedback loops |
