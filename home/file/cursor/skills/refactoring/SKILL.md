---
name: refactoring
description: Systematic refactoring of TypeScript code using techniques from Fowler's "Refactoring" book, adapted for pure functional programming with fp-ts. Use whenever the agent restructures, simplifies, or improves existing TypeScript code without changing its behavior.
---

# Refactoring -- Functional TypeScript Edition

Based on Martin Fowler's *Refactoring: Improving the Design of Existing Code*, translated from Java/OOP to pure functional TypeScript with fp-ts.

## Core Principles

1. **Preserve behavior** -- Refactoring never changes what the code does, only how it's structured.
2. **Small steps** -- Each refactoring is a single, testable transformation. Compile and test after every step.
3. **Two hats** -- Alternate between *adding function* and *refactoring*. Never do both simultaneously.
4. **Rule of three** -- Tolerate duplication once, wince twice, refactor on the third occurrence.
5. **Tests first** -- Solid tests are a precondition. If tests are missing, write them before refactoring.

## Refactoring Catalog

Each entry: **Name** -- one-line description -- when to use.

### Composing Functions

| Refactoring | Description |
|---|---|
| **Extract Function** | Pull a code fragment into its own named pure function. Use when a block needs a comment or is reused. |
| **Inline Function** | Replace a function call with its body when the body is as clear as the name. |
| **Replace Temp with Pipeline** | Convert a chain of `const` assignments into a `pipe(value, f, g, h)` expression. FP equivalent of *Replace Temp with Query*. |
| **Introduce Explaining Binding** | Name a sub-expression with `const` for clarity when `pipe` would obscure intent. Inverse of the above; use sparingly. |
| **Split Variable** | A `const` is conceptually assigned different meanings at different stages -- split into separate bindings. |
| **Substitute Algorithm** | Replace a function's implementation with a clearer or more efficient one that produces the same result. |
| **Replace Loop with Pipeline** | Convert `for`/`while` into `pipe(array, A.map(...), A.filter(...), A.reduce(...))`. |
| **Extract Combinator** | When several functions share a composition pattern (e.g., wrap-then-dispatch, validate-then-transform), extract the pattern into a higher-order combinator that takes the varying steps as parameters. Ensures primitives and combinations share the same type signature. |

### Moving Features Between Modules

| Refactoring | Description |
|---|---|
| **Move Function** | Relocate a function to the module whose data it primarily uses. |
| **Move Type** | Relocate a type definition to a more appropriate module. |
| **Extract Module** | Split a large file into two modules with clear, separate responsibilities. |
| **Inline Module** | Merge a module that no longer justifies its existence back into its consumer. |
| **Hide Delegate** | Create a wrapper function so callers don't chain through an intermediate module. |
| **Remove Middle Man** | Remove pass-through wrapper functions; let callers access the real function directly. |

### Organizing Data

| Refactoring | Description |
|---|---|
| **Introduce Branded Type** | Wrap a primitive in a branded/newtype (`Brand<string, 'Email'>`) to enforce domain semantics. Replaces *Replace Data Value with Object* and *Replace Type Code with Class*. |
| **Replace Magic Value with Constant** | Extract magic numbers/strings into named constants. |
| **Encapsulate with Optics** | Replace direct deep-access (`a.b.c`) with lenses/optionals from `monocle-ts` for immutable updates. |
| **Replace Mutable with Readonly** | Change `Array` → `ReadonlyArray`, remove `let`, ensure all data structures are immutable. |
| **Replace Record with Discriminated Union** | When a type field drives branching, introduce `type A = B | C` with a `_tag` discriminant. Replaces *Replace Type Code with Subclasses* and *Replace Type Code with State/Strategy*. |

### Simplifying Conditional Expressions

| Refactoring | Description |
|---|---|
| **Decompose Conditional** | Extract condition, then-branch, and else-branch into named functions. |
| **Consolidate Conditional** | Merge adjacent conditions that produce the same result into a single guard. |
| **Replace Nested Conditional with Guard Clause** | Flatten deep `if/else` nesting using early returns or `pipe` with `O.fromPredicate`. |
| **Replace Conditional with Fold** | Replace `switch`/`if` on a tag with a discriminated union and exhaustive `fold`/`match`. FP equivalent of *Replace Conditional with Polymorphism*. |
| **Introduce Option** | Replace nullable/undefined checks with `O.Option` and combinators. FP equivalent of *Introduce Null Object*. |
| **Introduce Assertion** | Add runtime checks (`IO` or `assert`) at module boundaries for preconditions that types can't enforce. |

### Making Function Calls Simpler

| Refactoring | Description |
|---|---|
| **Rename** | Change a function, type, or binding name to better reveal intent. |
| **Introduce Parameter Object** | Group related params into a single record type. |
| **Preserve Whole Object** | Pass the entire record instead of extracting fields as separate args. |
| **Separate Query from Command** | Split a function that both computes a value and performs an effect into two: a pure query and an effectful command. |
| **Parameterize Function** | Merge near-duplicate functions by adding a parameter for the varying part. |
| **Replace Parameter with Specific Functions** | When a function's behavior branches on a parameter, split into distinct named functions. |
| **Replace Constructor with Smart Constructor** | Use `Option`/`Either`-returning factory functions to enforce domain invariants at creation time. |
| **Replace Error Code with Either** | Return `E.Either<Error, A>` / `TE.TaskEither<Error, A>` instead of error codes, null, or thrown exceptions. |

### Dealing with Generalization (Composition Patterns)

OOP inheritance maps to composition and discriminated unions in FP.

| Refactoring | Description |
|---|---|
| **Extract Shared Function** | Pull common logic from multiple functions into a shared helper. FP equivalent of *Pull Up Method*. |
| **Push Down Variant Logic** | Move behavior specific to one discriminated-union variant into a function dedicated to that variant. FP equivalent of *Push Down Method*. |
| **Widen Union** | Add a new variant to a discriminated union. FP equivalent of *Extract Subclass*. |
| **Narrow Union** | Remove a variant that's no longer needed. FP equivalent of *Collapse Hierarchy*. |
| **Extract Interface Type** | Define a structural type (TypeScript interface/type alias) that multiple record types satisfy. |
| **Replace Delegation with Direct Composition** | When a wrapper function adds nothing, compose the inner function directly. FP equivalent of *Replace Delegation with Inheritance*. |
| **Form Higher-Order Function** | Extract varying steps of a fixed algorithm into function parameters. FP equivalent of *Form Template Method*. |
| **Introduce Handler Registry** | Replace a closed `switch`/`if-else` dispatch on a string or literal with a `ReadonlyMap<Key, Handler>` and a `register` function, enabling additive extension without modifying the dispatch function. |

### Big Refactorings

| Refactoring | Description |
|---|---|
| **Separate Domain from Infrastructure** | Push side effects (IO, network, DB) to the boundary; keep the core as pure functions over domain types. |
| **Tease Apart Modules** | Untangle a module serving two concerns into two independent modules. |
| **Extract Type Hierarchy** | When a flat type with many optional fields is unwieldy, reshape it into a discriminated union. |
| **Extract Domain Language** | When a module contains many related operations with implicit composition rules, extract a set of typed primitives and combinators that form a small embedded DSL, making the domain structure explicit and composition unlimited. |
| **Separate Base from Metadata Layer** | When logging, tracing, metrics, or audit logic is interleaved with domain logic, extract each concern into an independent wrapper/middleware that composes around the pure base function without altering its signature. |
| **Introduce Generate-and-Test** | When candidate generation and validation are tangled in a single loop, separate into an independent generator (producing candidates) piped through independent filter/validator stages. Either side can evolve without affecting the other. |

## Refactoring Workflow

```
Task Progress:
- [ ] 1. Ensure tests pass (green)
- [ ] 2. Identify the smell
- [ ] 3. Pick the smallest applicable refactoring
- [ ] 4. Apply the transformation
- [ ] 5. Compile and test (must stay green)
- [ ] 6. Commit the refactoring (one refactoring per commit)
- [ ] 7. Repeat -- or stop if the smell is gone
```

## FP-Specific Guidance

The coding standards, type-driven modeling rules, and architectural principles that govern *what good FP TypeScript looks like* live in the **functional-typescript** skill. This catalog focuses on the *mechanics* of getting there -- the step-by-step transformations. Consult both skills together: functional-typescript tells you where to aim; this catalog tells you how to move.

## Additional Resources

For detailed before/after TypeScript examples of each refactoring, see [reference.md](reference.md).
