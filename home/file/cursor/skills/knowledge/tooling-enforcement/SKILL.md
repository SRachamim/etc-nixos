---
name: tooling-enforcement
description: Check whether a Cursor convention can also be enforced with the project's existing tooling -- TypeScript compiler, linter rules, automated tests, CI checks, or pre-commit hooks. Use whenever the agent creates or modifies a Cursor artifact (command, skill, rule, subagent prompt) in any repository that has testing or auditing tools.
---

# Tooling Enforcement

Conventions enforced by tooling are more durable than conventions enforced solely by AI instructions. Tooling catches violations mechanically -- regardless of whether the agent is involved, regardless of which IDE the developer uses, and regardless of whether the developer has read the Cursor artifact. This is "governance through inception" from the **architect-thinking** skill: make the right path the easy path.

When creating or modifying a Cursor artifact that introduces or encodes a convention, always evaluate whether the convention can also be enforced with tools the project already uses (or could reasonably adopt).

## Survey the project's enforcement tooling

Before designing the artifact, check what enforcement tools the project has:

- **TypeScript compiler** -- `tsconfig.json` strict flags (`strict`, `noImplicitAny`, `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`, etc.), path aliases, module resolution settings.
- **Linters** -- ESLint, Biome, or other linters. Check the config for installed plugins and enabled rules. Consider whether a built-in rule, an existing plugin rule, or a community plugin covers the convention.
- **Test frameworks** -- Jest, Vitest, or similar. Architectural tests (e.g. "no module in layer A imports from layer B") and convention tests (e.g. "all exported functions have JSDoc") are powerful enforcement mechanisms.
- **CI pipeline** -- custom scripts, checks, branch policies, code-quality gates.
- **Pre-commit hooks** -- Husky, lint-staged, lefthook, or similar.
- **Other auditing tools** -- dependency scanners, licence checkers, bundlesize monitors, type-coverage tools.

If the project has none of these, skip the rest of this skill -- the Cursor artifact is the sole guardrail, which is still valuable.

## Enforcement tiers

Prefer the highest tier that fits the convention. Higher tiers provide faster, harder-to-bypass feedback.

| Tier | Mechanism | Feedback speed | Bypassability |
|------|-----------|---------------|---------------|
| 1 | **Compiler** -- `tsconfig.json` flag, type-level encoding | Instant (editor + build) | Very low |
| 2 | **Linter rule** -- built-in, existing plugin, or community plugin | Instant (editor) + CI | Low |
| 3 | **Automated test** -- unit/integration test asserting an invariant | On test run + CI | Low |
| 4 | **CI check** -- custom script, codeowners, branch policy | On push/PR | Medium |
| 5 | **Pre-commit hook** -- lint-staged, Husky | On commit | Higher (can skip with `--no-verify`) |

## What to do

**If enforcement is viable:**

1. Include the enforcement change alongside the Cursor artifact -- add the linter rule, enable the compiler flag, write the architectural test, or adjust the CI script.
2. If adoption requires a user decision (e.g. adding a new ESLint plugin dependency), present it as an explicit recommendation and wait for confirmation before proceeding.
3. Note the enforcement in the Cursor artifact itself so future readers understand that both the artifact and the tooling enforce the convention.

**If no mechanical enforcement is possible:**

- Note this explicitly in the Cursor artifact, e.g. "No linter rule or compiler flag covers this convention -- this skill is the sole guardrail."
- This is still valuable -- not every convention can be encoded in tooling, and the Cursor artifact provides guidance the tooling cannot.
