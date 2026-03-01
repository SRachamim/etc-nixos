---
name: estimation
description: Codebase-grounded estimation methodology. Use whenever the agent needs to produce effort estimates for work items or tasks.
---

# Estimation

Produce an effort estimate grounded in codebase evidence, not intuition.

## Input

The caller provides one of:

- An **ADO work item** (already fetched, with title, description, acceptance criteria).
- A **free-text description** of the work.

## Codebase Reconnaissance

Search the codebase to build a concrete understanding of the affected areas. Do not guess — read the code.

- Semantic-search using keywords from the description to locate relevant files, modules, and services.
- Read key files to understand current implementation patterns and architecture.
- Map the data flow through the affected components.
- Identify cross-module dependencies and downstream consumers of any code that would change.
- Check existing test coverage in the affected areas (test files, test helpers, coverage gaps).
- Note whether the change implies schema migrations, API surface changes, or new third-party dependencies.

Spend enough time here to form an accurate mental model of the blast radius.

## Complexity Analysis

Evaluate the work across these dimensions:

| Dimension | What to assess |
|-----------|---------------|
| **File-touch overhead** | How many files and modules need modification. |
| **Coupling** | How many downstream consumers or cross-module boundaries are affected. |
| **Test burden** | Volume of new tests needed; existing coverage gaps that must be filled first. |
| **Schema / API changes** | Database migrations, contract changes, or breaking API modifications. |
| **Technical debt** | Complexity of target files, code smells, monolithic modules in the blast radius. |
| **Unknowns / risks** | Ambiguous requirements, undocumented behavior, external dependencies, security concerns. |

For each dimension, assign a severity: **low**, **moderate**, or **high**.

## Sizing

Using the complexity analysis, assign both a T-shirt size and Fibonacci story points:

| T-Shirt | Points | Indicators |
|---------|--------|------------|
| **XS** | 1–2 | Isolated single-file change. High existing test coverage. No schema changes. Established pattern exists to follow. |
| **S** | 3 | Confined to a single component or module. Minimal new tests. No downstream consumer updates or API changes. |
| **M** | 5 | Multi-file modification within a single bounded context. Moderate file-touch overhead. Requires integration test updates. |
| **L** | 8–13 | Cross-module architectural changes. High coupling. Requires schema migrations or security audits. |
| **XL** | 21+ | Spans multiple repositories or services. High regression risk. Ambiguous requirements needing significant R&D. Recommend splitting into smaller items. |

Justify the estimate by referencing specific findings from the complexity analysis — not intuition.

## Output

The skill produces:

| Field | Description |
|-------|-------------|
| **T-shirt size** | XS, S, M, L, or XL |
| **Story points** | A single Fibonacci number (1, 2, 3, 5, 8, 13, 21) |
| **Complexity breakdown** | Severity per dimension |
| **Risks and open questions** | Any concerns surfaced during reconnaissance |
| **Recommendation** | Whether to proceed as-is, split the item, or address prerequisites first |

The caller decides how to present or use these outputs.
