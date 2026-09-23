---
name: client-quality-focus-g
description: Non-functional requirements concentration for the FundGuard client monorepo. Loaded whenever the agent works in fgrepo client/ -- ensures every plan, implementation unit, review, and NFR-related debugging hypothesis is checked against quality attributes by a clean-context quality-reviewer subagent. Use whenever the agent operates on code under the fgrepo client directory.
---

# Client Quality Focus

Concentrate on non-functional requirements when working in the FundGuard client monorepo. This skill makes sure NFRs get proportional weight in every decision. It does this by having an **independent, clean-context reviewer** check the work at fixed checkpoints, not by steering the main agent's own reasoning.

The quality-attribute checklist lives in [reference.md](reference.md). Only the **quality-reviewer** subagent reads it. The main agent does not evaluate against it inline.

## Why delegate

- **Independence.** LLM evaluators favour output that feels familiar or self-generated. A reviewer that shares the author's context, reasoning, or rubric agrees with the author more than it should. A fresh context with only the artifact and the criteria gives a real second view.
- **Verification-subagent pattern.** A dedicated agent validates the work without needing to know how it was built. The boundary between the two agents is an explicit brief (see below), so exactly what crosses it is controlled.
- **Context budget.** The checklist is loaded only when it is used, not in every client session (per **context-engineering-g**, "Select").

## Detection

This skill applies when working in the FundGuard client monorepo, identified by any of:

- The workspace path contains `client/` alongside sibling directories like `devops/`, `automation/`, or `backend/`.
- The git remote URL contains `fgrepo`.
- The pnpm workspace name is `fg` with `@fg/*` scoped packages.

## Checkpoints

Spawn the **quality-reviewer** subagent (`subagents/quality-reviewer.md`) at each checkpoint below:

| Activity | Checkpoint | Artifact under review |
|----------|-----------|-----------------------|
| Planning (`/plan-g`, `/plan-from-prd-intake-g`, `/analyze-prd-g`) | After drafting the plan, before presenting it to the user | Plan text + requirements/ACs |
| Plan review (`/review-plan-g`) | In parallel with the main review | Plan text + requirements/ACs |
| Implementation | Once per logical unit (a commit's worth), after **self-review-g** and before the commit's validation step | `git diff` for the unit + the plan step it implements |
| PR review (`/review-pr-g`, `/draft-review-g`) | In parallel with the main review | PR diff + PR description / linked ACs |
| Debugging (`/debug-g`) | When a hypothesis could be an NFR violation (performance, accessibility, security, observability) | Symptom description + suspect code paths |

**Skip** the checkpoint for trivial changes: typos, renames, comment-only edits, or diffs with no runtime effect.

## Isolation brief

The brief is the only thing that crosses the boundary. Keep it minimal and factual.

**Send:**

- **Activity**: one of planning, implementation, review, or debugging.
- **Artifact**: the plan text, the diff (or a file list and base ref the subagent can diff itself), or the symptom and suspect paths.
- **Requirements**: the functional requirements or acceptance criteria the artifact is meant to satisfy.
- **Repo path**: so the subagent can read the surrounding code.

**Do not send:**

- The main agent's reasoning, design rationale, or alternatives it rejected.
- Chat history or earlier drafts.
- The main agent's own view of quality ("I think this is fine", "I already handled a11y").

Anything in the second list anchors the reviewer and cancels the independence you are delegating for.

## Integrating findings

Treat the subagent's report as an independent second opinion, not as instructions:

1. For each finding, decide **accept**, **adapt**, or **reject**, with a one-line reason. Apply the evaluation protocol of the **feedback-evaluation-g** skill.
2. Fix or incorporate accepted **blocking** findings before moving past the checkpoint. In planning, this means updating the plan. In implementation, it means amending the diff.
3. Surface rejected blocking findings to the user, with the reason, so they can judge the call.
4. Re-check **at most once** after fixes, and only when blocking findings were addressed. Don't loop.
5. Mention the checkpoint outcome in chat briefly, e.g. "Quality review: 1 blocking (fixed), 2 minor (1 accepted, 1 rejected: out of scope)".

## Degradation

If the agent cannot spawn subagents, run the check inline as a separate pass. Finish the current step first. Then read [reference.md](reference.md) fresh and evaluate only the artifact against the requirements, as if seeing it for the first time. Say in chat that the check was not independent.

## Relationship to Other Skills

- **context-engineering-g**: "Isolate" and "Select" are the reason for delegating. The isolation brief applies "give each subagent the narrowest context that lets it complete its task".
- **self-review-g**: runs first, inline, for general code-review dimensions. The quality-reviewer checkpoint follows it for NFRs, with a clean context.
- **feedback-evaluation-g**: the protocol for weighing the subagent's findings.
- **functional-typescript-g**: provides the maintainability foundation through type-driven design, purity, and algebraic modeling. The reference checklist adds *why* those patterns matter as NFR enablers.
- **architect-thinking-g**: Options Thinking preserves future NFR improvements. Rate of Change ensures the architecture supports evolving quality targets.
- **code-review-g**: its Performance, Security, and Flexibility dimensions are weighted higher when this skill is active, and Accessibility is elevated to a blocking dimension. The quality-reviewer applies this weighting.
- **test-driven-development-g**: property-based testing with fast-check directly serves the Reliability and Maintainability attributes.
- **microservice-patterns-g**: the Resiliency patterns (circuit breakers, bulkheads, timeouts) apply to the gql-api layer's interactions with downstream services.
