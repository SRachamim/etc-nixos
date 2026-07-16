---
name: code-review
description: Standards for performing code reviews. Use whenever the agent reviews a pull request, diff, or code change.

# Code Review Standards

## Review Inputs

A code review evaluates what the code does and how the commits tell the story. Only these inputs are review signals:

- **Code diff** -- file modifications, additions, and deletions. The primary source of truth.
- **Commit topology** -- the ordering, grouping, and dependency structure of commits.
- **Commit messages** -- summary line, body, and trailers. These express intent per change.

The following are **not** review signals -- they serve navigational or administrative purposes and must not influence the review assessment:

- PR title and description.
- Linked work items, acceptance criteria, and ticket metadata.

The reviewer reconstructs intent exclusively from the code and commits. If the commits don't tell a coherent story, that is itself a finding.

## What to Evaluate

When reviewing code, assess each change against these dimensions:

- **Correctness** -- Does the code do what it claims? Are edge cases handled?
- **Clarity** -- Can a reader understand the intent without extra explanation? Are names descriptive?
- **Design** -- Is the abstraction level appropriate? Are responsibilities well-separated?
- **Architecture** -- Is the overall solution approach sound? Do component boundaries, module decomposition, and dependency directions make sense? Does the change align with (or intentionally evolve) the system's existing architectural patterns, or does it introduce unnecessary coupling? Apply the **architect-thinking** skill: does the change preserve options or lock in decisions unnecessarily? Does it increase or decrease the rate of future change in the affected area? Is configuration treated as code (version-controlled, validated, tested)? Are cross-boundary effects and feedback loops considered?
- **Test coverage** -- Are new behaviors tested? Are edge cases and error paths covered?
- **Performance** -- Are there obvious inefficiencies, unnecessary allocations, or N+1 patterns?
- **Security** -- Are inputs validated? Are secrets handled safely? Are there injection risks?
- **Flexibility** -- Is the code additive (new behavior can be added without modifying existing code)? Do functions follow Postel's law (wide inputs, narrow outputs)? Are cross-cutting concerns (logging, metrics) layered independently from domain logic? Are generation and evaluation separated where applicable? Are combinators used so that primitives and combinations share the same interface?

## Comment Severity

Categorize every review comment:

- **Blocking** -- Must be resolved before merge. Correctness bugs, security issues, data loss risks.
- **Suggestion** -- Recommended improvement. Better naming, clearer structure, missing test. Non-blocking.
- **Nit** -- Minor style or preference. Formatting, word choice, import order. Non-blocking.

Always state the severity explicitly so the author knows what requires action.

## Comment Constraints

Every review comment must be **actionable** and **line-anchored**:

- **Actionable** -- the comment identifies a concrete problem, risk, or improvement and tells the author what to change. Comments that merely summarize what the code does, restate the PR description, or praise without requesting a change are not actionable and must not be drafted.
- **Line-anchored** -- the comment references at least one specific line in at least one specific file in the diff. Free-floating observations that cannot be tied to a code location do not belong as review comments.

## Thread Status

The reviewer creates comments; the author resolves them. This separation ensures the author reads, considers, and addresses each comment on their own terms.

- **Always create threads as Active.** Both `create_pr_comment` and `post_review_findings` default to `Closed` status -- you must explicitly pass `status: "Active"` on every finding. Never set status to `Fixed`, `WontFix`, `ByDesign`, or any resolved state when creating a comment thread.
- **Never change a thread's status.** Do not use `update_pr_thread_status` (or any platform equivalent) to resolve, close, or transition a thread the reviewer created. The author owns the lifecycle.
- **Follow-ups stay Active too.** When revisiting a thread (e.g. during `/review-pr-fixes`), reply with the evaluation -- acknowledge if the fix is adequate, push back if it isn't -- but leave the thread status unchanged. The author resolves the thread when they're satisfied.

## Tone

Apply the **objective-communication** skill to all review comments.

- Be **constructive** -- frame comments as improvements, not criticisms.
- Be **specific** -- reference the exact line, variable, or pattern. Avoid vague feedback.
- Be **actionable** -- explain *why* something is a problem and suggest a concrete alternative.
- When a suggestion involves refactoring (renaming, extracting, moving, restructuring existing code), **mention casually** that the change belongs in a preceding refactoring commit -- e.g. "Rename `processItems` to `applyTransformations` in a preceding refactoring commit." This reinforces the ordering rule from the **commit-conventions** skill without sounding prescriptive or formal.
- **Ask questions** when intent is unclear rather than assuming a mistake.
- Do not draft comments for praise or summary observations.

## Presenting Findings

### Draft-first

Every finding must include the literal text that will be posted externally, formatted inside a fenced code block so the user can review and approve it. Draft this on the first review iteration -- never wait for the user to ask "now draft the replies." The review output should be ready to post after a single approval step.

### Inline diff context

When a finding references a specific code modification, include the relevant diff hunk as a fenced code block with `diff` syntax highlighting. Show only the affected hunk (not the entire file diff) so the reader can see the exact context inline without navigating to the file.

## Verdicts

- **Approve** -- No blocking comments. The change is ready to merge.
- **Request changes** -- One or more blocking comments exist. The author must address them.
- **Comment only** -- Feedback provided, but no strong opinion on merge readiness (e.g., reviewing a subset of the change).

## Commit Structure

Apply the **commit-conventions** skill to evaluate whether commits are well-structured, independently valid, and tell a coherent story.