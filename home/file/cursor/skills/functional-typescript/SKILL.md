---
name: functional-typescript
description: Pure functional TypeScript with fp-ts — coding standards and architectural principles. Use whenever the agent writes, modifies, or reviews TypeScript code (.ts, .tsx), or reasons about TypeScript architecture.
---

# Functional TypeScript Standards

## Foundations

Apply the principles and patterns from:

- **"Structure and Interpretation of Computer Programs"** (Abelson & Sussman) — First-principles thinking; abstraction and composition as core design tools.
- **"Software Design for Flexibility"** (Hanson & Sussman) — Additive programming, combinators, generic dispatch, layering, degeneracy, and Postel's law; design systems that evolve without rewriting.
- **"Domain Modeling Made Functional"** (Scott Wlaschin) — Type-driven design with algebraic data types; model workflows as pipelines; make illegal states unrepresentable; smart constructors; explicit effects in signatures; persistence at the edges.
- **"Functional and Reactive Domain Modeling"** (Debasish Ghosh) — Algebraic API design (algebra + interpreter separation); effectful computation with functors, applicatives, and monads; applicative validation; lenses for immutable updates; event sourcing and CQRS; property-based testing of domain laws; abstract early, evaluate late.

Draw on idioms from Haskell, PureScript, and Scala when modeling problems.

## Type-Driven Domain Modeling

Model the domain with algebraic data types. The type system is the primary tool for capturing business rules.

1. **AND types (product types)** — Use `interface` / `type` records to combine fields. Every field name should use ubiquitous language.
2. **OR types (sum types)** — Use tagged discriminated unions for choices. Prefer `{ readonly _tag: 'CaseName'; ... }` with exhaustive `match` via `pipe` + `fold`/`match`.
3. **Simple branded types** — Wrap primitives (`string`, `number`) in `io-ts` branded types so `OrderId` and `CustomerId` are not interchangeable even when both are strings.
4. **Smart constructors** — Never export raw constructors for constrained types. Export a `create` function returning `Either<DomainError, T>` that validates invariants on construction. Once created, the value is trusted throughout the bounded context.
5. **Make illegal states unrepresentable** — Use distinct types for each lifecycle state (e.g., `UnvalidatedOrder`, `ValidatedOrder`, `PricedOrder`) rather than flags or optional fields. If a business rule says "X or Y but not both," model it as a union, not two optional fields.
6. **Entities vs Value Objects** — Value Objects have structural equality (all fields). Entities carry a persistent identity (`EntityId`) and are equal only by id. Reference entities from other aggregates by id, not by embedding.
7. **Aggregates** — An aggregate is a consistency boundary rooted at one entity. All mutations go through the root. An aggregate is the atomic unit of persistence and transactions.

## Coding Standards

When writing, modifying, or **reviewing** TypeScript code (including PR reviews), apply:

1. **Pure Functions Only** — No mutable state, no side effects. Model effects with `IO`, `Task`, `TaskEither`, `ReaderTaskEither`. A function returning `void`/`undefined` is a code smell — it implies hidden side effects.
2. **Use fp-ts Ecosystem** — `fp-ts`, `io-ts` (runtime validation / codecs), `monocle-ts` (optics/lenses for immutable updates), and related libraries for all functional abstractions.
3. **Composition Over Inheritance** — Build complex behavior by composing small pure functions. Use `pipe` and `flow`. Never use classes, `this`, `new`, inheritance, mutable instance state, or traditional polymorphism. Use modules (namespaces of exported functions), types, and function composition.
4. **Explicit Error Handling** — Use `Either<E, A>` and `TaskEither<E, A>` for operations that can fail. Never throw exceptions. Model domain errors as tagged unions (e.g., `type PlaceOrderError = ValidationError | PricingError | ...`).
5. **Applicative Validation** — When multiple independent validations must run and all errors should be collected, use `Apply` / `getValidation` from fp-ts (applicative style accumulates errors). Use monadic `flatMap` only when validations depend on each other sequentially.
6. **Least Powerful Abstraction** — Prefer `Functor` (map) when sufficient; use `Applicative` (independent effects) before reaching for `Monad` (sequential/dependent effects). More powerful abstractions are less reusable.
7. **Abstract Early, Evaluate Late** — Return computations (`TaskEither`, `ReaderTaskEither`), not values. Defer evaluation to the boundary. This preserves compositionality — callers compose computations, not results.
8. **Think in Expressions** — Every construct yields a value. Compose domain behaviors bottom-up from smaller expressions. Use `pipe` chains and `for`-comprehension style (`Do` notation in fp-ts) for sequencing.
9. **Lenses for Immutable Updates** — Use `monocle-ts` for updating nested immutable structures. Define a lens per field; compose lenses for deep updates. Verify lens laws (identity, retention, double-set) in tests.
10. **Skinny Domain Objects** — ADTs hold only data (structure). All behaviors live in module-level functions (services). Keep domain types lean; distribute functionality across composable service modules.
11. **Curried Invocation Ordering** — When defining or calling curried functions, order parameter groups to minimize the number of invocations while enabling composition. Within that minimum, respect this precedence:
    1. **Typeclass instances** (`Eq`, `Ord`, `Monoid`, …) — own invocation, first.
    2. **Configuration / secondary parameters** — together in a single invocation, after instances.
    3. **Main data structure** — own invocation, alone. Enables `pipe` / `flow` composition.
    4. **Reader / environment / dependencies** — own invocation, last. Use the `Has*` intersection pattern (`HasRepo & HasLogger`) for composable capability requirements.
    Skip categories that don't apply. Example: `RM.lookup(Eq)(key)(map)` — instance, selector, main data. Custom: `debit(amount)(account)` — configuration, main data for piping.

## Workflows and Pipelines

Model business processes as typed function pipelines:

1. **Workflow = Function** — A workflow is `Command -> TaskEither<WorkflowError, readonly DomainEvent[]>`. Input is a command, output is domain events. The workflow does not publish events — it returns them.
2. **Pipeline Steps** — Decompose each workflow into typed steps: `validate :: UnvalidatedOrder -> Either<ValidationError, ValidatedOrder>`, `price :: ValidatedOrder -> TaskEither<PricingError, PricedOrder>`, etc. Each step's output type is the next step's input type.
3. **Dependency Injection via Reader** — Inject infrastructure (database access, external services) as function parameters or via `ReaderTaskEither<Dependencies, Error, Result>`. The core domain never imports infrastructure directly.
4. **Document Effects in Signatures** — If a step can fail, its return type must be `Either` or `TaskEither`. If it's async, use `Task` or `TaskEither`. If it needs context, use `Reader*`. Effects are visible in the types, never hidden.

## Architectural Principles

When planning, designing, or reasoning about architecture:

1. **Bounded Contexts** — Each context is an autonomous subsystem with its own ubiquitous language, types, and modules. Contexts communicate through domain events and DTOs — never share internal domain types across boundaries.
2. **Anti-Corruption Layers** — At context boundaries, translate between external DTOs and internal domain types using `io-ts` codecs. Validate and transform at the gate. The internal domain stays pure and uncorrupted by external models.
3. **Event-Driven Communication** — Events flow between bounded contexts. A domain event from an upstream context triggers a command in a downstream context. Within a context, avoid internal event listeners — append steps to the workflow pipeline explicitly.
4. **Event Sourcing & CQRS** — When applicable, persist domain events as the source of truth; derive current state by folding events. Separate the write model (commands → events) from the read model (projections/queries). Model commands as descriptions (consider free monads for complex command algebras).
5. **Persistence at the Edges (Onion Architecture)** — Push I/O (database, network, file system) to the outermost layer. The core domain is pure functions on pure data. All dependencies point inward. Use `ReaderTaskEither` to thread infrastructure access without polluting domain logic.
6. **Algebra / Interpreter Separation** — Define domain service APIs as abstract algebras (TypeScript interfaces with function signatures parameterized on abstract types). Provide concrete interpreters (implementations) separately. This enables testability (swap interpreters) and decouples contract from implementation.

## Flexibility Design

Principles from Hanson & Sussman's *Software Design for Flexibility* — design systems that evolve without rewriting.

1. **Additive Programming** — New functionality must be addable by writing new code, not by modifying working code. Structure modules around extension points: discriminated unions give compiler-enforced exhaustiveness (when a new variant is added, every existing use site must consciously adapt); handler registries or interpreter swaps enable open-ended extension. Treat the need to edit an existing function to support a new case as a design smell.
2. **Combinator Design** — When building a family of related operations, ensure primitives and combinations share the same type signature so a combination is usable wherever a primitive is. Use `pipe`/`flow` as the universal composition backbone; design domain functions so their input/output types chain naturally. Higher-order combinators (`(pred: Predicate<A>) => Predicate<A>`, `(f: Handler<A>) => Handler<A>`) let families of behaviors grow without changing the composition plumbing.
3. **Postel's Law (Robustness Principle)** — Accept the widest reasonable input types; return the most precise output types. Prefer `ReadonlyArray<A>` over fixed tuples, accept unions over narrow literals at module boundaries. Narrow outputs suppress noise for downstream consumers — the same principle as the digital abstraction suppressing voltage noise across logic gates.
4. **Degeneracy (Multiple Independent Paths)** — Provide more than one independent way to achieve critical results. Cross-check degenerate computations for reliability: verify algebraic laws from multiple angles in property-based tests; provide fallback interpreters for critical services; validate running totals against recomputed sums. Degeneracy is additive — each contributing path is self-contained and can produce a result alone.
5. **Layering (Metadata Independence)** — Keep metadata processing independent from base computation. The core domain (base layer) must not reference logging, tracing, metrics, or audit layers. Metadata layers may observe base-layer values but must not mutate them, affect their behavior, or depend on each other. In TypeScript: compose metadata as middleware (`ReaderTaskEither` environments, wrapper functions) that decorates functions without altering their domain signatures.
6. **Partial Information & Merging** — When combining data from multiple sources, merge rather than replace. Define a `Semigroup` or `Monoid` for each domain type that combines partial information (intersect intervals, union support sets, choose the more specific value). Use `RA.foldMap` or `concatAll` to merge collections. This is the propagation model: each cell accumulates evidence, and contradictions surface as explicit `Either.left` values rather than silently overwriting.
7. **Generate-and-Test (Exploratory Behavior)** — Separate candidate generation from candidate evaluation. The generator is independent of the tester; neither needs to know how the other works. Model search as generation (`ReadonlyArray`, `Task<ReadonlyArray<A>>`) piped through independent `Predicate<A>` filter/validator stages composed with `RA.foldMap(B.MonoidAll)`. This separation enables evolving generation and evaluation independently.
8. **Minimize Assumptions** — Defer decisions to runtime when possible. Prefer parameterized behavior (`Reader`, function arguments, configuration records) over hard-coded branching. Build each function to work correctly for a wider range of inputs than the immediate use case requires — this pays back when requirements shift and the existing code already handles the new case.

## Testing

1. **Property-Based Testing** — Verify algebraic laws and domain invariants with property-based tests (e.g., fast-check). Generate domain data through composable generators using smart constructors. Properties encode business rules declaratively and are more exhaustive than example-based tests.
2. **Algebra Laws** — When defining abstractions (e.g., a lens, a codec, a service algebra), state and verify their laws. Example: for any account `a`, `pipe(a, credit(x), E.flatMap(debit(x)))` must leave the balance unchanged.
3. **Custom Interpreters for Testing** — Provide in-memory or stub interpreters of domain service algebras for unit tests. The algebra/interpreter split makes domain logic testable without infrastructure.

## Code Smells

Recognize these smells during reviews or while working in a codebase. The "Primary Remedies" column references the **refactoring** skill's catalog.

| Smell | FP Manifestation | Primary Remedies |
|---|---|---|
| **Duplicated Code** | Same logic in multiple functions/modules | Extract Function, Extract Module |
| **Long Function** | Function with many steps or deep nesting | Extract Function, Replace Temp with Pipeline, Decompose Conditional |
| **Large Module** | File with too many exports, mixed concerns | Extract Module, Move Function |
| **Long Parameter List** | Function taking 4+ args | Introduce Parameter Object (record type), Preserve Whole Object |
| **Divergent Change** | One module changes for unrelated reasons | Extract Module |
| **Shotgun Surgery** | One logical change touches many modules | Move Function, Move Type, Inline Module |
| **Feature Envy** | Function uses data from another module more than its own | Move Function |
| **Data Clumps** | Same group of fields passed together repeatedly | Extract type (record/branded) |
| **Primitive Obsession** | Raw `string`, `number` where a domain type belongs | Introduce Branded Type / Newtype |
| **Switch on Literal** | `if/else` or `switch` on string/number tags | Replace Conditional with Discriminated Union + `fold` |
| **Lazy Module** | Module that barely justifies its existence | Inline Module |
| **Speculative Generality** | Unused abstractions, generic params nobody needs | Remove unused type param, Inline Function |
| **Temp Variable Chains** | Long sequences of `const x = ...; const y = f(x); ...` | Replace Temp with Pipeline (`pipe`/`flow`) |
| **Message Chains** | Deep property drilling: `a.b.c.d` | Use optics (`monocle-ts`), Hide Delegate |
| **Middle Man** | Function that only delegates to another | Inline Function, Remove Middle Man |
| **Inappropriate Intimacy** | Circular imports or modules reaching into each other's internals | Move Function, Extract Module, break cycle |
| **Data Module** | Module exporting only types with no behavior | Move behavior into the module |
| **Comments as Deodorant** | Comment explains *what* unclear code does | Extract Function with intention-revealing name, Rename |
| **Rigid Dispatch** | Adding a new case requires editing an existing `switch`/`if-else` function | Introduce Handler Registry, Widen Union |
| **Tangled Layers** | Domain logic interleaved with logging, tracing, metrics, or audit code | Separate Base from Metadata Layer |
| **Monolithic Generation** | Candidate generation and validation fused in one loop/function; can't evolve independently | Introduce Generate-and-Test |
| **Repeated Composition Pattern** | Same wrap-dispatch or validate-transform shape duplicated across multiple functions | Extract Combinator |

## Constraints

- **Never use `effect-ts`** — All code must use the `fp-ts` ecosystem exclusively.
- **Never use `newtype-ts`** — Use `io-ts` branded types for opaque/newtype wrappers instead.
- **Never use `as` type assertions** — except `as const` for literal narrowing and `as BrandedType` inside smart constructor / brand creator functions. All other `as` casts bypass the type system. Use explicit return types, constructor functions, or `satisfies` instead.

## Additional Resources

For detailed before/after TypeScript examples of each pattern, see [reference.md](reference.md).
