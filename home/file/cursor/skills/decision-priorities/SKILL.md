---
name: decision-priorities
description: Priority ordering (simplicity, correctness, changeability, DX) for choosing between approaches. Use whenever the agent evaluates alternative designs, orderings, or trade-offs -- during planning, plan review, code review, or artifact design.
---

# Decision Priorities

## Governing principle

Prefer the simpler approach. Simplicity is the primary means by which correctness is maintained, changeability is preserved, and developer experience improves. Complexity must justify itself.

*SICP: manage complexity through abstraction. Beck: do the simplest thing that could possibly work. Hohpe: emphasis over completeness.*

## Priority ladder

When two approaches are approximately equal at priority N, use N+1 as the tie-breaker.

| # | Priority | Mechanism |
|---|----------|-----------|
| 1 | **Correctness** | Prefer stronger types; then stronger behavioural guarantees. |
| 2 | **Changeability** | Prefer the approach that preserves more options. |
| 3 | **DX** | Prefer the approach that is clearer to read and maintain. |

*Brady, Wlaschin: types prove properties and make illegal states unrepresentable. Hohpe: architecture sells options; the best decision is one you can change later. Beck: tests as documentation. SICP: clean abstractions reduce cognitive load.*

## Anti-patterns

| Mistake | What it sacrifices | Book reference |
|---------|--------------------|----------------|
| Shantytown: optimise for shipping speed at the expense of structure | Changeability for short-term throughput | Hohpe -- shantytown problem |
| Silent swallowing: code looks clean but discards errors or widens types | Correctness for DX | Wlaschin -- make illegal states unrepresentable |
| Speculative abstraction: build reusable infrastructure before a concrete consumer exists | Changeability and DX for imagined future flexibility | Hohpe -- use before reuse |
| Gold-plating: over-engineer types or abstractions beyond what the current use case demands | DX and delivery speed for theoretical correctness | Beck -- do the simplest thing; Hohpe -- emphasis over completeness |

## Related skills

The priority ladder weighs the outputs of existing skills -- it does not replace them:

- **architect-thinking** -- options thinking, rate of change, decision quality
- **design-lenses** -- refactoring, flexibility, and architecture evaluation
- **functional-typescript** -- type-driven development, coding standards
- **refactoring** -- behaviour-preserving transformations
- **test-driven-development** -- red/green/refactor cycle
