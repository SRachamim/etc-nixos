---
name: verification-strategy-g
description: Maps requirements (FR/NFR/AC) to the minimum set of verification levels that together achieve 100% confidence. Defines a six-level hierarchy (types, static analysis, property tests, unit tests, package E2E, full E2E), workspace detection, and execution protocol. Use whenever the agent plans tests, writes verification artifacts, or reviews test coverage.
---

# Verification Strategy

Map every requirement to the minimum set of verification levels that together achieve 100% confidence. Start from the cheapest level and only add costlier levels when cheaper ones leave gaps. Every verification produces a committed artifact that runs automatically in CI -- no manual verification accepted.

## The Verification Hierarchy

Six levels ordered by cost. Each level covers defect classes the previous cannot.

| Level | Mechanism | What it proves | Committed artifact | Cost |
|-------|-----------|---------------|--------------------|------|
| 1 | Type system (TypeScript strict, branded types, discriminated unions, state machine types) | Structural correctness, illegal states unrepresentable, protocol adherence | Type definitions, smart constructors | Zero runtime cost |
| 2 | Static analysis (ESLint, `eslint-plugin-fp-ts`, `eslint-plugin-functional`, custom rules) | Convention adherence, no-mutation invariants, import boundaries, accessibility | ESLint config, custom rule files | Zero runtime cost |
| 3 | Property-based tests (fast-check) | Universal invariants, algebraic laws, codec round-trips, domain rules | Test files with `fc.assert(fc.property(...))` | Fast (seconds) |
| 4 | Unit tests (Vitest/Jest) | Specific behaviour for edge cases, error paths, boundary conditions, composed function integration | Test files with `describe`/`test` | Fast (ms per test) |
| 5 | Package E2E (component tests, API tests within one package) | Component interaction, user-facing behaviour within a bounded context | Test files in the package | Medium (seconds) |
| 6 | Full E2E (Playwright, Cypress, or workspace-specific framework) | Critical user journeys across the full system | Test files in the automation/e2e directory | Slow (minutes) |

## Mapping Rules

A requirement may need **one or more levels** to reach full confidence. Walk the hierarchy top-down (cheapest first) and ask: "what aspect of this requirement does this level prove? what remains unproven?"

### Decision process per requirement

1. **Level 1** -- can the type system encode this constraint? If yes, that covers the structural aspect.
2. **Level 2** -- can a lint rule enforce a convention aspect? If yes, add it.
3. **Level 3** -- does the requirement state a universal invariant that types alone cannot prove (behavioral, not structural)? If yes, add a property test.
4. **Level 4** -- are there specific edge cases or boundary conditions that property generators are unlikely to hit, or that serve as documentation? If yes, add unit tests.
5. **Level 5** -- does correctness depend on interaction between composed components within a package? If yes, add a package E2E.
6. **Level 6** -- is this a critical cross-system user journey where confidence requires a real browser/environment? If yes, add a full E2E.

**Stop when the combined levels leave no unproven aspect.**

### Worked examples

**"Balance never goes negative after debit":**

| Level | What it proves | Artifact |
|-------|---------------|----------|
| 1 | `NonNegativeBalance` branded type -- cannot construct a negative value | `Balance.ts` smart constructor |
| 3 | For all valid `(balance, amount)` pairs where `amount > balance`, `debit` returns `Left` | `balance.property.test.ts` |
| 4 | Boundary: `debit(balance)(account)` where `amount === balance` returns `Right(zero)` | `balance.test.ts` |

Three levels, each covering a different aspect. Together: 100% confidence.

**"OrderId must be non-empty UUID":**

| Level | What it proves | Artifact |
|-------|---------------|----------|
| 1 | Branded type rejects empty/malformed strings at construction | `OrderId.ts` smart constructor |
| 3 | Codec round-trip: `decode(encode(id)) === Right(id)` for all valid IDs | `orderId.property.test.ts` |

Two levels suffice -- no unit test needed because the property test subsumes example cases.

**"User can complete checkout":**

| Level | What it proves | Artifact |
|-------|---------------|----------|
| 1 | Typed state machine: `Cart -> CheckingOut -> Confirmed` (cannot skip steps) | Type definitions |
| 4 | Each transition function handles its error cases | Unit tests per step |
| 6 | Full journey works in a real browser with real API | `automation/checkout.spec.ts` |

## Workspace Detection

Before recommending a level, verify the workspace supports it:

- **Level 1**: Check for `tsconfig.json` with `strict: true`. Always available in TypeScript projects.
- **Level 2**: Check for `.eslintrc.*` or `eslint.config.*`. Check which plugins are installed.
- **Level 3**: Check for `fast-check` in `package.json` dependencies. Do NOT suggest adding it if absent.
- **Level 4**: Check for test runner (`vitest`, `jest`) in dependencies.
- **Level 5**: Check for package-level test infrastructure (test config, test utils).
- **Level 6**: Check for E2E framework directory (e.g. `automation/` in fgrepo, `e2e/`, `tests/`). Identify the specific framework and its conventions.

**Rule**: If a level is unavailable, skip it and use the next available level. Never write infrastructure that does not exist. Never suggest adding dependencies unless the user explicitly requests it.

## Verification Mapping Table

When producing test mappings (in **analyze-prd-g** step 5, **plan-g** commit planning, etc.), use this format. A single requirement appears on **multiple rows** -- one per verification level needed:

| Req ID | Requirement | Level | Mechanism | Artifact | What it proves |
|--------|-------------|-------|-----------|----------|----------------|

**Completeness check**: After filling the table, verify that every requirement has at least one row and that the combined levels for each requirement leave no unproven aspect. Flag any requirement where confidence is below 100% with a note explaining what cannot be verified automatically.

## Verification Execution

Every verification artifact must be **executed locally** before the PR is submitted. Writing tests without running them only asserts correctness on paper -- execution provides evidence.

### Execution timing

- **Levels 1-2** (types, lint): Run implicitly on every commit via `tsc --noEmit` and `eslint`. Already covered by **plan-execution-g**'s validation step.
- **Levels 3-4** (property + unit tests): Run after the commit that adds them. Scope: only the new/modified test files.
- **Level 5** (package E2E): Run after all commits in the affected package are complete. Scope: the package's test suite or just the new test files.
- **Level 6** (full E2E): Run after all implementation commits are complete, before PR submission (the **deliver-feature-g** step 3.5 gate). Scope: only the new E2E spec files, not the full suite.

### Discovery protocol

The agent does NOT hardcode test commands. Before running any test, discover the correct command by checking (in order):

1. **Workspace rules and skills** -- check for repo-level rules that specify how to run tests (e.g. `AGENTS.md`, `.cursor/rules/`, `.claude/rules/`).
2. **package.json `scripts`** -- look for `test`, `test:unit`, `test:e2e`, `test:property`, or similar.
3. **README / CONTRIBUTING** -- read the project's docs for test instructions.
4. **Framework config files** -- `vitest.config.ts`, `jest.config.ts`, `playwright.config.ts`, `cypress.config.ts`, etc.
5. **Existing test file patterns** -- look at how existing tests in the same directory are structured and run.

For Level 6, also discover:
- Whether a dev server needs to be running.
- Which environment variables are needed.
- How to scope the run to specific spec files (e.g. `--spec`, `--grep`, file path arguments).

### Failure handling

- If a verification artifact fails when executed: fix the implementation (not the test), re-run, iterate.
- If a Level 6 test cannot run locally (e.g. requires infrastructure unavailable locally): document this explicitly in the PR description. The test is still committed -- it will run in CI. Flag the risk: "Level 6 verification deferred to CI -- local execution not possible because [reason]."

## No Manual Verification

Every verification must produce a committed artifact that runs automatically:

- Level 1: Type definitions compile (CI type-check step catches regressions).
- Level 2: Lint rules run in CI.
- Levels 3-6: Test files run in CI.

Manual verification (e.g. "I checked it in the browser") is not accepted as a verification strategy for any requirement.

## Relationship to Other Skills

| Skill | Relationship |
|-------|-------------|
| **test-driven-development-g** | Defines the TDD *process* (red/green/refactor). This skill defines *which verification level* to use -- TDD governs how to write it. |
| **functional-typescript-g** | Provides the type-driven modeling that makes Level 1 verification powerful (branded types, state machines, smart constructors). |
| **client-quality-focus-g** | Provides quality-attribute guidance specific to the FundGuard client monorepo. This skill is workspace-agnostic. |
| **self-review-g** | Uses this skill's framework when evaluating the "test coverage" dimension. |
| **plan-execution-g** | Executes per-commit validation using this skill's discovery protocol. |
| **deliver-feature-g** | Runs the Level 5-6 verification gate (step 3.5) before PR submission. |
| **analyze-prd-g** | Produces the verification mapping table (step 5) using this skill's format. |
