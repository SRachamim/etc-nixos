---
name: test-strategy
description: Property-based test planning for fp-ts TypeScript code. Identifies testable properties, maps coverage to codepaths, flags gaps, and justifies any example-based tests. Use whenever the agent plans, designs, or reviews test coverage for new or changed code.
---

# Test Strategy

Plan tests around **properties**, not examples. This skill complements the Testing section of the **functional-typescript** skill -- that skill says *what* to test (algebraic laws, domain invariants, custom interpreters); this skill says *how to plan* the coverage before writing code.

## Property Identification

For every new or changed function, identify its testable properties. Think in these categories:

| Category | What to look for | fast-check pattern |
|----------|-----------------|-------------------|
| **Round-trip** | encode then decode (or serialize/deserialize, create/parse) returns the original | `fc.assert(fc.property(arbA, a => deepEqual(decode(encode(a)), a)))` |
| **Idempotency** | applying the function twice yields the same result as once | `fc.assert(fc.property(arbA, a => deepEqual(f(f(a)), f(a))))` |
| **Commutativity** | order of arguments or operations doesn't affect the result | `fc.assert(fc.property(arbA, arbB, (a, b) => deepEqual(f(a, b), f(b, a))))` |
| **Associativity** | grouping doesn't matter -- `f(f(a, b), c) === f(a, f(b, c))` | `fc.assert(fc.property(arbA, arbB, arbC, ...))` |
| **Identity element** | combining with the identity leaves the value unchanged | `fc.assert(fc.property(arbA, a => deepEqual(f(a, empty), a)))` |
| **Invariant preservation** | output satisfies a predicate for all valid inputs | `fc.assert(fc.property(arbA, a => predicate(f(a))))` |
| **No-crash** | function doesn't throw on arbitrary valid input | `fc.assert(fc.property(arbA, a => { f(a); return true; }))` |
| **Monotonicity** | ordering is preserved -- if `a <= b` then `f(a) <= f(b)` | `fc.assert(fc.property(arbOrdered, ([a, b]) => f(a) <= f(b)))` |
| **Distributivity** | `f(a, g(b, c)) === g(f(a, b), f(a, c))` | Useful for operations over collections |
| **Lens laws** | get-put, put-get, put-put for every lens | `fc.assert(fc.property(arbS, arbA, ...))` |
| **Codec laws** | `decode(encode(a))` succeeds and equals `a`; `encode(decode(raw))` round-trips | Same as round-trip, applied to `io-ts` codecs |

Not every category applies to every function. Pick the ones that match the function's algebraic structure.

## Arbitraries and Generators

Build generators from domain smart constructors -- never from raw primitives. If `OrderId` is a branded `string`, the arbitrary should produce valid `OrderId` values via the smart constructor, discarding invalid draws with `fc.pre()` or using `fc.filter()`.

Compose generators to match the composition of domain types: if `Order` contains `ReadonlyArray<LineItem>`, build `arbOrder` from `arbLineItem`.

## Coverage Mapping

Map every new codepath to at least one property:

| Codepath / function | Property | Category | Arbitrary |
|---------------------|----------|----------|-----------|
| `validateOrder` | valid input produces `Right`; invalid produces `Left` with correct tag | Invariant preservation | `arbUnvalidatedOrder` |
| `priceOrder` | total equals sum of line prices | Invariant preservation | `arbValidatedOrder` |
| ... | ... | ... | ... |

Flag any codepath with no identified property as a **coverage gap**.

## Coverage Gaps

When a codepath has no testable property, determine the cause:

1. **Design flaw** -- the function does too many things or has hidden side effects. Recommend splitting or restructuring before writing tests.
2. **External contract** -- the behaviour depends on a third-party API or format that can't be expressed as a universal property. This is the only valid reason for an example-based test.
3. **Missing domain knowledge** -- the property exists but isn't obvious yet. Flag for discussion rather than defaulting to examples.

## Example Test Justification

Example-based tests (specific input/output pairs) are permitted only when a property genuinely cannot cover the behaviour. Each example test must carry a one-line justification explaining why no property suffices.

Valid justifications:
- "Snapshot of third-party JSON schema -- property would reimplement the parser."
- "Regression for a specific production incident (ticket #1234) -- the invariant is too complex to generalise."

Invalid justifications:
- "Easier to write." (Not a reason.)
- "Property would be slow." (Use `fc.configureGlobal` to limit runs.)

## Integration and Pipeline Tests

For workflow pipelines (`Command -> TaskEither<Error, Events>`), test the pipeline contract:
- Valid command produces expected event types (invariant preservation).
- Invalid command produces expected error types with correct tags.
- Pipeline is compositional -- running sub-pipelines independently and composing results equals running the full pipeline.

Use custom in-memory interpreters (per **functional-typescript** skill) to isolate domain logic from infrastructure.

## Output Format

When producing a test strategy as part of a plan, use this structure:

```
### Test Strategy

| Codepath | Property | Category | Arbitrary | Notes |
|----------|----------|----------|-----------|-------|
| `fn1` | description | Round-trip | `arbX` | |
| `fn2` | description | Invariant | `arbY` | |
| `fn3` | -- | **GAP** | -- | Design flaw: does X and Y; split first |

**Example tests** (with justification):
- `testSpecificFormat`: Snapshot of third-party CSV schema -- property would reimplement the parser.

**Gaps requiring resolution:**
- `fn3` needs restructuring before tests can be planned.
```

Skip this section (with a brief "N/A" note) when the change is clearly too simple to warrant it -- e.g. a single-field addition following an established pattern with existing test coverage.
