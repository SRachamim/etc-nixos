---
name: code-review
description: Standards for performing code reviews. Use whenever the agent reviews a pull request, diff, or code change.

# Code Review Standards

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

Every review comment must be **actionable**, **line-anchored**, and **artifact-traced**:

- **Actionable** -- the comment identifies a concrete problem, risk, or improvement and tells the author what to change. Comments that merely summarize what the code does, restate the PR description, or praise without requesting a change are not actionable and must not be drafted.
- **Line-anchored** -- the comment references at least one specific line in at least one specific file in the diff. Free-floating observations that cannot be tied to a code location do not belong as review comments.
- **Artifact-traced** -- the comment cites the agent artifact(s) that govern the finding (the standard the code violates or should follow). This makes findings auditable, disputable, and gap-revealing -- analogous to how linters cite a rule ID for every diagnostic.

### Artifact traceability

Each review comment must end with a `Governed by:` line identifying the artifact(s) the finding derives from. Citable artifacts include knowledge skills, workspace rules (`.cursor/rules/*.mdc`, `.claude/rules/*.md`, `AGENTS.md`), workflow skills (when a workflow step defines the standard), and subagent prompts.

**Citation format** -- use the path relative to the skills root (for skills) or repo root (for workspace rules), plus the line range of the specific criterion:

```
Governed by: `knowledge/functional-typescript/SKILL.md` (lines 42–48)
```

```
Governed by: `.cursor/rules/api-validation.mdc` (lines 12–18)
```

When multiple artifacts jointly govern a finding, list them:

```
Governed by:
- `knowledge/code-review/SKILL.md` (lines 8–10)
- `knowledge/functional-typescript/SKILL.md` (lines 42–48)
```

**Gap signal** -- when a finding is sound but no existing artifact covers it, note:

```
No governing artifact — candidate for a new standard.
```

Uncitable findings are gaps in the standards. This feeds into the **continuous-improvement** skill's "Discovery" signal so the gap can be addressed after the review.

**Precise location** -- the citation must include a line range, not just a filename. Read the artifact to identify the specific section or criterion that applies. If the artifact is already in context, use the known line numbers directly.

## Tone

Apply the **writing-style** skill to all review comments, using the "Code review comments (inline on diffs)" register.

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