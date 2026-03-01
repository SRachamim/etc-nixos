---
name: estimation
description: Codebase-grounded estimation methodology. Use whenever the agent needs to produce effort estimates for work items or tasks.
---

# Estimation

Produce an effort estimate **in hours** grounded in codebase evidence and historical calibration — not intuition.

FundGuard ADO tracks effort with three fields on every Task and Bug:

- `OriginalEstimate` — planned hours (what this skill produces)
- `CompletedWork` — actual hours spent (filled during/after work)
- `RemainingWork` — hours left (updated as work progresses)

Plus a custom field:

- `EstimationConfidenceLevel` — one of `1.0: Absolute`, `1.6: Medium`, `2.0: Very Low`

## Input

The caller provides one of:

- An **ADO work item** (already fetched, with title, description, acceptance criteria).
- A **free-text description** of the work.

## Historical Calibration

Before estimating, search ADO for 3–5 recently resolved work items that are structurally similar (same area path, same type, or similar keywords). For each, note:

| Field | Purpose |
|-------|---------|
| `OriginalEstimate` | What was planned |
| `CompletedWork` | What actually happened |
| Overrun ratio | `CompletedWork / OriginalEstimate` |
| `EstimationConfidenceLevel` | How confident the original estimator was |
| Sprint spill tags | Whether the item carried `Planned and not completed` tags across sprints |

Compute the **median overrun ratio** for the comparable set. Use this as a reality-check multiplier on your raw estimate.

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

## Hour Estimate

Derive a concrete hour estimate using the complexity analysis:

| Band | Hours | Indicators |
|------|-------|------------|
| **Trivial** | 1–2 | Isolated single-file change. High existing test coverage. No schema changes. Established pattern to follow. |
| **Small** | 3–5 | Confined to a single component or module. Minimal new tests. No downstream consumer updates. |
| **Medium** | 6–15 | Multi-file modification within a single bounded context. Moderate file-touch overhead. Requires integration test updates. |
| **Large** | 16–30 | Cross-module changes. High coupling. Requires schema migrations or security audits. May span more than one sprint. |
| **Extra-Large** | 31+ | Spans multiple services or repositories. High regression risk. Ambiguous requirements needing R&D. **Recommend splitting into smaller items.** |

After deriving the raw hour estimate, apply the **historical overrun multiplier** from the calibration step. If the comparable set shows a median 1.5x overrun, inflate accordingly — or explicitly flag the gap as a risk.

## Estimation Confidence Level

Assign a confidence level based on the unknowns dimension and overall uncertainty:

| Level | When to assign |
|-------|---------------|
| **1.0: Absolute** | Requirements are crystal clear, the pattern is well-established, no unknowns. |
| **1.6: Medium** | Some ambiguity exists but the general approach is known; moderate unknowns. |
| **2.0: Very Low** | Significant unknowns, undocumented behavior, new territory, or external dependencies. |

## Sprint Fit

FundGuard uses **2-week sprints** (~80 working hours per person). Flag if the estimate exceeds one sprint for a single assignee. If it does, recommend splitting into sprint-sized sub-tasks or note the expected spill.

## Output

The skill produces:

| Field | Description |
|-------|-------------|
| **Original Estimate** | A single number in hours, suitable for the `OriginalEstimate` ADO field |
| **Estimation Confidence Level** | `1.0: Absolute`, `1.6: Medium`, or `2.0: Very Low` |
| **Complexity breakdown** | Severity per dimension |
| **Historical comparables** | The 3–5 similar items used for calibration, with their overrun ratios |
| **Risks and open questions** | Any concerns surfaced during reconnaissance |
| **Sprint fit** | Whether the work fits in one sprint, or how to split it |
| **Recommendation** | Whether to proceed as-is, split the item, or address prerequisites first |

The caller decides how to present or use these outputs.
