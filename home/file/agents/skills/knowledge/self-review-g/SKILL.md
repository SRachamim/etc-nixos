---
name: self-review-g
description: Iterative quality gate the agent applies to its own code changes during implementation. Evaluates the current diff against code-review-g dimensions before staging, fixes issues in-place, and re-evaluates until clean or iteration limit reached. Use whenever the agent is implementing code changes -- within plan-execution-g, deliver-feature-g, or ad-hoc.
---

# Self-Review

Before staging and committing code changes, the agent reviews its own diff against the evaluation dimensions from **code-review-g**, fixes issues in-place, and re-evaluates until the output is clean. This is an iterative quality gate -- an evaluator-optimizer loop applied to the agent's own work.

## When to trigger

Apply self-review during any implementation that produces code changes -- whether executing a plan via **plan-execution-g**, delivering a feature via **deliver-feature-g**, or making ad-hoc changes.

The trigger point is: after writing all changes for a logical unit of work (typically a commit's worth of changes) but before staging and committing. In **plan-execution-g**, this is the step immediately before the commit's validation step.

## Review protocol

### Pass 1: Evaluate

1. **Generate the diff.** Run `git diff` for unstaged changes or `git diff --cached` if already staged. Read the full diff -- do not sample or skip files.
2. **Evaluate against code-review-g dimensions.** Apply the following dimensions from **code-review-g** in priority order. Stop at the first blocking issue found in each dimension before moving to the next:
   - **Behavioral effect** -- Does the change achieve its stated goal? Trace data/control flow from the change site through its callers to the observable outcome. Ask: "If I'm the caller, what do I experience after this change?"
   - **Correctness** -- Is the implementation free of bugs? Are edge cases handled? Are error paths covered at every level of the call stack?
   - **Security** -- Are inputs validated? Are secrets handled safely? Are there injection risks?
   - **Design** -- Is the abstraction level appropriate? Are responsibilities well-separated?
   - **Test coverage** -- Are new behaviors tested? Are edge cases and error paths covered?
   - **Clarity** -- Can a reader understand the intent without extra explanation? Are names descriptive?
3. **Fix issues in-place.** For each issue found, fix the code directly. No need to draft comments or create threads -- this is self-review, not external review. Just fix the code.

### Pass 2: Re-evaluate

After fixing, re-read the diff and evaluate again. Focus on:

- Whether the fixes resolved the original issues.
- Whether the fixes introduced new issues.

If all issues are resolved, proceed to the deterministic backstop. If issues remain, apply the no-progress guard (see below).

### Dimensions to skip

The following **code-review-g** dimensions are not applicable during self-review:

- **Architecture** -- architectural decisions were made during planning, not implementation.
- **Performance** -- skip unless an obvious inefficiency is spotted (N+1 queries, unnecessary allocations in a hot path).
- **Flexibility** -- a design-time concern evaluated during planning.
- **Comment severity, Thread status, Tone, Presenting findings** -- external review mechanics that do not apply when the agent reviews its own work.

## Iteration limits

- **Maximum 2 review passes.** Quality gains flatten by the third round. If issues remain after the second fix cycle, flag them to the user with a brief summary of what was found and what could not be resolved, rather than continuing to iterate.
- **No-progress guard.** If a review pass finds the same issues as the previous pass (the fixes did not resolve them), stop immediately and flag to the user. Do not retry the same fix.

## Deterministic backstop

After the self-review loop passes, run the commit's validation step (build, tests, linters). Self-review complements but does not replace deterministic validation. The LLM-based review catches semantic and design issues; the deterministic checks catch mechanical issues.

## Scope boundary

- **Not a replacement for PR review.** Self-review catches obvious issues before they reach a human reviewer. It does not substitute for an independent external review.
- **Not a style pass.** Linters and formatters handle formatting and style. Focus on behavioral correctness and design, not whitespace or import order.
