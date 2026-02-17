---
name: code-review
description: Standards for performing code reviews. Use whenever the agent reviews a pull request, diff, or code change.
---

# Code Review Standards

## What to Evaluate

When reviewing code, assess each change against these dimensions:

- **Correctness** — Does the code do what it claims? Are edge cases handled?
- **Clarity** — Can a reader understand the intent without extra explanation? Are names descriptive?
- **Design** — Is the abstraction level appropriate? Are responsibilities well-separated?
- **Test coverage** — Are new behaviors tested? Are edge cases and error paths covered?
- **Performance** — Are there obvious inefficiencies, unnecessary allocations, or N+1 patterns?
- **Security** — Are inputs validated? Are secrets handled safely? Are there injection risks?

## Comment Severity

Categorize every review comment:

- **Blocking** — Must be resolved before merge. Correctness bugs, security issues, data loss risks.
- **Suggestion** — Recommended improvement. Better naming, clearer structure, missing test. Non-blocking.
- **Nit** — Minor style or preference. Formatting, word choice, import order. Non-blocking.
- **Praise** — Highlight good patterns worth reinforcing. Encourages good habits.

Always state the severity explicitly so the author knows what requires action.

## Tone

- Be **constructive** — frame comments as improvements, not criticisms.
- Be **specific** — reference the exact line, variable, or pattern. Avoid vague feedback.
- Be **actionable** — explain *why* something is a problem and suggest a concrete alternative.
- **Ask questions** when intent is unclear rather than assuming a mistake.
- Acknowledge good work — praise is part of the review.

## Verdicts

- **Approve** — No blocking comments. The change is ready to merge.
- **Request changes** — One or more blocking comments exist. The author must address them.
- **Comment only** — Feedback provided, but no strong opinion on merge readiness (e.g., reviewing a subset of the change).

## Commit Structure

Apply the **commit-conventions** skill to evaluate whether commits are well-structured, independently valid, and tell a coherent story.
