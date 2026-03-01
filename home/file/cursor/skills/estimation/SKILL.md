---
name: estimation
description: Codebase-grounded estimation methodology. Use whenever the agent needs to produce effort estimates for work items or tasks.
---

# Estimation

Produce an effort estimate **in hours** grounded in codebase evidence and empirical calibration data — not intuition.

FundGuard ADO tracks effort with three fields on every Task and Bug:

- `OriginalEstimate` — planned hours (what this skill produces)
- `CompletedWork` — actual hours spent (filled during/after work)
- `RemainingWork` — hours left (updated as work progresses)

Plus a custom field:

- `EstimationConfidenceLevel` — a scale from `1.0: Absolute` to `2.0: Very Low`

## Input

The caller provides one of:

- An **ADO work item** (already fetched, with title, description, acceptance criteria).
- A **free-text description** of the work.

## Empirical Calibration (last updated 2026-03-01, N=94)

The following bias data was computed from 94 resolved FundGuard work items (50 Tasks, 44 Bugs). Use it to adjust raw estimates instead of querying ADO each time.

### Accuracy by size band

| Band | N | Median actual/est | Mean | Overrun rate | Key pattern |
|------|---|-------------------|------|-------------|-------------|
| **Trivial (1–2 h)** | 18 | 1.00 | 1.22 | 11 % | Almost always accurate; occasional outlier. No adjustment needed. |
| **Small (3–5 h)** | 33 | **0.60** | 0.70 | 9 % | **Systematically over-padded.** Only 9 % overrun; 64 % finish well under estimate. Aim for the low end of the band. |
| **Medium (6–15 h)** | 23 | 1.00 | 0.83 | 13 % | Well-calibrated on median, moderate variance (±50 %). |
| **Large (16–30 h)** | 17 | 1.00 | 1.07 | **41 %** | Median is accurate but **highest overrun risk**: 41 % exceed the estimate. Budget a buffer or split. |
| **XL (31+ h)** | 3 | 0.67 | 0.74 | 33 % | Too few data points. Always recommend splitting. |

### Accuracy by confidence level

| Confidence | N | Median | Std | Note |
|-----------|---|--------|-----|------|
| 1.0: Absolute | 46 | 1.00 | 0.72 | Most common value but has the **widest variance** — often a default rather than a thoughtful assessment. |
| 1.2–1.4 | 8 | 1.00 | 0.71 | Small sample; roughly accurate. |
| 1.6: Medium | 3 | 1.00 | 0.00 | Perfect calibration in sample (small N). |
| 2.0: Very Low | 36 | 0.80 | 0.49 | Items flagged as uncertain are actually **over-padded on average**. |

### Adjustment rules

1. **Trivial / Medium / Large**: use the raw codebase-grounded estimate as-is.
2. **Small (3–5 h)**: after codebase reconnaissance, ask whether the work truly fills 3–5 h or whether the scope is closer to 2 h. Prefer the lower end unless there are concrete unknowns.
3. **Large (16–30 h)**: add an explicit **risk buffer of +25 %** or recommend splitting into sub-tasks — the 41 % overrun rate is the highest of any band.
4. **XL (31+ h)**: always recommend splitting. Do not ship a single estimate above 30 h without decomposition.

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

After deriving the raw hour estimate, apply the **adjustment rules** from the calibration section. For Small-band items, lean toward the lower end. For Large-band items, add the risk buffer or recommend splitting.

## Estimation Confidence Level

FundGuard ADO supports a six-point scale. Historical data shows "1.0: Absolute" is over-used as a default and carries just as much variance as "2.0: Very Low". **Be deliberate** — reserve 1.0 for genuinely trivial, pattern-following changes.

| Level | When to assign |
|-------|---------------|
| **1.0: Absolute** | Trivial change following an established pattern. Zero ambiguity, zero unknowns. |
| **1.2: Very High** | Requirements are clear and the approach is well-understood, but the scope is non-trivial. |
| **1.4: High** | Good understanding of the approach; minor open questions that are unlikely to change the estimate significantly. |
| **1.6: Medium** | Some ambiguity exists but the general approach is known; moderate unknowns. |
| **1.8: Low** | Multiple unknowns; the approach is partially defined but significant discovery is expected. |
| **2.0: Very Low** | Significant unknowns, undocumented behavior, new territory, or external dependencies. Expect the estimate to shift. |

## Sprint Fit

FundGuard uses **2-week sprints** (~80 working hours per person). Flag if the estimate exceeds one sprint for a single assignee. If it does, recommend splitting into sprint-sized sub-tasks or note the expected spill.

## Output

The skill produces:

| Field | Description |
|-------|-------------|
| **Original Estimate** | A single number in hours, suitable for the `OriginalEstimate` ADO field |
| **Estimation Confidence Level** | One of the six-point scale values (`1.0` through `2.0`) |
| **Size band** | Which calibration band the estimate falls into, and whether an adjustment was applied |
| **Complexity breakdown** | Severity per dimension |
| **Risks and open questions** | Any concerns surfaced during reconnaissance |
| **Sprint fit** | Whether the work fits in one sprint, or how to split it |
| **Recommendation** | Whether to proceed as-is, split the item, or address prerequisites first |

The caller decides how to present or use these outputs.

## Refreshing the Calibration Data

The empirical data above was extracted on **2026-03-01** from 94 resolved items across recent sprints. Re-run the calibration periodically (every ~6 months or after a process change) by fetching a fresh batch of resolved Tasks and Bugs from ADO and recomputing the size-band and confidence-level statistics.
