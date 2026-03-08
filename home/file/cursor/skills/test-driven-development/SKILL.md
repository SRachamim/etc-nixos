---
name: test-driven-development
description: Test-driven development cycle adapted for functional TypeScript with fp-ts, io-ts, and fast-check. Use whenever the agent writes new functionality, fixes defects, or refactors TypeScript code -- the TDD rhythm (red/green/refactor) guides every code change.
---

# Test-Driven Development -- Functional TypeScript Edition

Based on Kent Beck's *Test-Driven Development: By Example*, translated from Java/OOP to pure functional TypeScript with fp-ts, io-ts, and fast-check.

## Two Rules

1. Write new code only when an automated test has failed.
2. Eliminate duplication.

These two rules generate the rhythm: **Red → Green → Refactor**.

## The TDD Cycle

1. **Red** -- Write a small test that fails (or does not compile). Describe the desired behaviour from the caller's perspective. Imagine the perfect API.
2. **Green** -- Make the test pass as quickly as possible. Commit whatever sins are necessary. Speed trumps design -- *just for this moment*.
3. **Refactor** -- Eliminate all duplication introduced in step 2 (between test and code, and within the code itself). Clean up while the bar is green.

The cycle is not complete without step 3. "Make it run, make it right."

## Test List

Before you begin, write down every test you know you will need. As you work:

- When a new test occurs to you, add it to the list. Do not interrupt the current red/green/refactor cycle.
- When you think of a refactoring, note it on the list.
- When an item is done, cross it off.
- Pick the next test that teaches you something *and* that you are confident you can make pass in a few minutes.

In functional TypeScript terms, a test list might look like:

```
- [ ] create branded OrderId from valid string → Right
- [ ] create branded OrderId from empty string → Left
- [ ] validate order collects all field errors (applicative)
- [ ] price order with known product → Right PricedOrder
- [ ] price order with unknown product → Left PricingError
- [ ] full workflow: command → events
```

## Strategies for Getting to Green

### Fake It ('Til You Make It)

Return a constant. Then gradually replace constants with variables and expressions until the duplication between test and code is eliminated.

In fp-ts this often means returning a hard-coded `E.right(...)` or `TE.right(...)` and then generalising.

### Triangulation

When unsure how to generalise, write a *second* example that demands a different result. Generalise only when you have two or more concrete examples. Useful for discovering the right abstraction, especially for property-based generators.

### Obvious Implementation

When the correct implementation is clear, type it in. Run the tests. If the bar stays green, move on. If you get a surprise red bar, back off and use Fake It.

### Shifting Gears

Move freely between these strategies. When everything is flowing, use Obvious Implementation. When you get an unexpected failure, shift down to Fake It. TDD is a steering process -- there is no single correct step size.

## Red Bar Patterns

### One Step Test

Pick the test that represents the smallest step from known (passing tests) toward unknown (the feature you are building). Programs grow from known to unknown.

### Starter Test

Start with the trivial case: an operation that does nothing, an empty collection, a zero-amount `Money`. This answers "where does the operation belong?" without solving the hard logic yet.

In fp-ts: start with the identity case -- `pipe(emptyOrder, validateOrder)` should return `E.right(...)` when there is nothing to validate.

### Assert First

Write the assertion before writing the rest of the test. Work backwards: what is the expected result? Where does it come from? What input produces it?

```typescript
// Start here:
expect(result).toEqual(E.right(pricedOrder))
// Then work backwards to set up `result`, `pricedOrder`, inputs, dependencies.
```

### Test Data

Use data that makes tests easy to read. If there is no conceptual difference between 1 and 2, use 1. Never reuse the same constant for different roles -- if testing `plus`, use `3 + 4`, not `2 + 2`.

### Evident Data

Show the relationship between inputs and expected outputs in the test itself, not hidden behind constants:

```typescript
// Good -- relationship is visible
expect(convert(Money.dollar(100), 'GBP', rate(2))).toEqual(Money.gbp(100 / 2))

// Bad -- 50 is magic
expect(convert(Money.dollar(100), 'GBP', rate(2))).toEqual(Money.gbp(50))
```

### Child Test

If a test turns out to be too big (too many changes needed at once), delete it, write a smaller child test that represents part of the problem, get it green, then reintroduce the larger test.

### Regression Test

When a defect is reported, write the smallest failing test first. Every regression test is a lesson about a test you should have written originally.

### Another Test

When a tangential idea arises mid-cycle, add it to the test list and return to the current test. Stay on track.

## Green Bar Patterns -- fp-ts Adaptations

| Beck Pattern | fp-ts Translation |
|---|---|
| **Fake It** | Return a hard-coded `E.right(value)` or `TE.right(value)`. Replace constants with `pipe` expressions as you remove duplication. |
| **Triangulation** | Add a second `fc.property(...)` assertion or a second example-based test with different data. Generalise only when forced. |
| **Obvious Implementation** | Type in the real `pipe(input, validate, E.flatMap(price), E.map(createEvents))` when it's clear. |
| **One to Many** | Implement for a single value first, then generalise to `ReadonlyArray`. Use `RA.map`, `RA.traverse`, `RA.foldMap` to scale up. |

## Testing Patterns -- fp-ts Adaptations

### Custom Interpreters (Mock Object)

The **functional-typescript** skill's algebra/interpreter separation provides the natural mock boundary. Define a test interpreter that returns canned values from `E.right(...)` or `TE.right(...)`. No mocking library needed.

### Self Shunt

The test module itself can implement a dependency interface. In fp-ts, pass a record of functions as the `Reader` environment:

```typescript
const testDeps: Deps = {
  findAccount: (id) => TE.right(testAccount),
  saveAccount: (a) => TE.right(undefined),
}
```

### Log String

When testing that operations occur in a specific order (e.g. pipeline steps), accumulate a log:

```typescript
const log: string[] = []
const deps: Deps = {
  validate: (o) => { log.push('validate'); return E.right(validated) },
  price:    (o) => { log.push('price');    return TE.right(priced) },
}
// After running the workflow:
expect(log).toEqual(['validate', 'price'])
```

### Crash Test Dummy

Override a single dependency function to return `E.left(...)` or `TE.left(...)`, exercising error paths without needing real failures:

```typescript
const failingDeps: Deps = {
  ...happyDeps,
  chargeCard: () => TE.left({ _tag: 'PaymentDeclined' as const }),
}
```

## Property-Based Testing with fast-check

Property-based tests encode business rules declaratively. They are *more* aligned with TDD than example tests because each property is a universally quantified assertion -- a stronger claim.

### When to Use Properties vs Examples

| Situation | Prefer |
|---|---|
| Exploring a new API, finding the right shape | Example-based tests (fast feedback, easy to read) |
| Algebraic laws (identity, commutativity, round-trip) | Property-based |
| Business invariants ("balance never negative after credit") | Property-based |
| Edge cases you can enumerate | Example-based |
| Edge cases you might miss | Property-based (generation finds surprises) |

Use both together: example tests as documentation, property tests as safety net.

### Composable Generators via Smart Constructors

Build generators from the domain's smart constructors. This guarantees generated values satisfy invariants:

```typescript
const orderIdArb: fc.Arbitrary<OrderId> = fc
  .stringOf(fc.alphaNumeric(), { minLength: 1, maxLength: 36 })
  .filter((s) => E.isRight(OrderId.create(s)))
  .map((s) => pipe(OrderId.create(s), E.getOrElseW(() => { throw Error('unreachable') })))
```

### Verifying Algebraic Laws

State and verify laws whenever you define an abstraction:

- **Codec round-trip**: `decode(encode(a)) ≡ Right(a)` for all `a`
- **Lens laws**: get-set, set-get, set-set
- **Monoid laws**: left identity, right identity, associativity
- **Semigroup law**: associativity
- **Domain laws**: e.g. `credit(x) >> debit(x)` preserves balance

### Degeneracy (Cross-Verification)

When two independent paths should produce the same result, property-test their equivalence. This catches subtle bugs that single-path tests miss.

## Step Size

TDD is not about always taking tiny steps. It is about *being able to* take tiny steps.

- When everything is flowing: take larger steps, use Obvious Implementation.
- When you get a surprise failure: shift down to Fake It, take smaller steps.
- When you're unsure about the abstraction: use Triangulation.
- When you're lost: throw away the code and start over (Do Over).
- When you're tired: take a break.

## Relation to Other Skills

| Skill | Relationship |
|---|---|
| **functional-typescript** | Defines *what good code looks like*: types, patterns, architecture. TDD drives you toward that code through failing tests. |
| **refactoring** | Defines *how to transform code*. Refactoring is step 3 of the TDD cycle. Every refactoring happens under a green bar. |

## Constraints

- **Never use `effect-ts`** -- all tests and production code use the `fp-ts` ecosystem.
- **Never use `newtype-ts`** -- use `io-ts` branded types for domain wrappers.
- **Test framework**: Vitest or Jest with `fast-check` for property-based testing. No custom test harnesses.
- **No test-after** -- every new behaviour starts with a failing test. The only exception is `toString`/debug-only helpers during active debugging (note it and move on, as Beck recommends).

## Additional Resources

For detailed before/after TypeScript examples of each TDD pattern, see [reference.md](reference.md).
