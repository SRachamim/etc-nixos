---
name: functional-typescript
description: Pure functional TypeScript with fp-ts — coding standards and architectural principles. Use whenever the agent writes, modifies, or reviews TypeScript code (.ts, .tsx), or reasons about TypeScript architecture.
---

# Functional TypeScript Standards

## Foundations

Apply the principles and patterns from:

- **"Structure and Interpretation of Computer Programs"** (Abelson & Sussman) - Build understanding from first principles; think in terms of abstraction and composition.
- **"Domain Modeling Made Functional"** (Scott Wlaschin) - Type-driven design, making illegal states unrepresentable.
- **"Functional and Reactive Domain Modeling"** (Debasish Ghosh) - Event sourcing, CQRS, and reactive patterns in functional style.

Draw on idioms from Haskell, PureScript, and Scala when modeling problems.

## Coding Standards

When writing, modifying, or **reviewing** TypeScript code (including PR reviews), apply these standards:

1. **Pure Functions Only** - No mutable state, no side effects. Use `IO`, `Task`, `TaskEither` to represent effects.
2. **Use fp-ts Ecosystem** - Leverage `fp-ts`, `io-ts`, `monocle-ts`, and related libraries for all functional abstractions.
3. **Type-Driven Design** - Model the domain with algebraic data types. Make illegal states unrepresentable.
4. **Composition Over Inheritance** - Build complex behavior by composing small, pure functions. Use `pipe` and `flow`.
5. **Explicit Error Handling** - Use `Either` and `TaskEither` for errors. Never throw exceptions.

## Architectural Principles

When planning, designing, or reasoning about architecture:

1. **Domain-Driven Design** - Separate domain logic from infrastructure. Model bounded contexts explicitly.
2. **Event-Driven & Reactive** - Prefer event sourcing and reactive streams for state management and system communication.
3. **Actor Model** - For concurrent systems, reason in terms of isolated actors with message passing.
4. **Edge-of-the-World Effects** - Push side effects to the system boundary. Keep the core pure.

## Constraints

- **Never use `effect-ts`** - All code must use the `fp-ts` ecosystem exclusively.
- **No OOP patterns** - Avoid classes, `this`, inheritance, and traditional polymorphism. Use modules, types, and functions.
