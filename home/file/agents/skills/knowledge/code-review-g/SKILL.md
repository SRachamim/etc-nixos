---
name: code-review-g
description: "Standards for performing code reviews. Sub-skill of **delivered-text-g** -- handles review domain (layer 5). Loaded conditionally when reviewing code."
---

# Code Review

> **Prerequisite**: This is **layer 5** of the **delivered-text-g** stack. If you reached this skill directly, load **delivered-text-g** first -- it defines scope, the priority ladder, and which other layers apply alongside this one.

## Review Inputs

A code review evaluates what the code does and how the commits tell the story. Only these inputs are review signals:

- **Code diff** -- file modifications, additions, and deletions. The primary source of truth.
- **Commit topology** -- the ordering, grouping, and dependency structure of commits.
- **Commit messages** -- summary line, body, and trailers. These express intent per change.

The following are **not** review signals -- they serve navigational or administrative purposes and must not influence the review assessment:

- PR title and description.
- Linked work items, acceptance criteria, and ticket metadata.

The PR is transient -- it disappears from history once merged, while the code and commits persist. Don't spend review effort on PR metadata: never raise findings about the PR title, description, or linked items (missing sections, template compliance, wording), and don't re-check them on a re-review. Anything a future reader needs must live in the code or the commit messages -- if intent is only explained in the PR description, that is a commit-message finding.

The reviewer reconstructs intent exclusively from the code and commits. If the commits don't tell a coherent story, that is itself a finding.

## What to Evaluate

When reviewing code, assess each change against these dimensions. Dimensions are listed in priority order -- verify the change achieves its behavioral goal before assessing implementation quality. A syntactically correct implementation that doesn't produce the intended behavioral effect is a blocking finding, not a style nit.

- **Behavioral effect** -- Does the change achieve its claimed goal? Before examining code quality, trace the data/control flow from the change site through its callers to the observable outcome. Ask: "If I'm the caller, what do I experience after this change?" For example: does an async operation fire-and-forget or block? Does an error propagate or get swallowed? Does a cache write happen before or after the response? If the answer contradicts the stated intent, stop -- nothing else matters until this is resolved.
- **Correctness** -- Given that the behavioral goal is met, is the implementation free of bugs? Are edge cases handled? Are error paths covered at every level of the call stack? When the change adds nested styled-components selectors (`&&`, `&` inside another component's block, `${Other}` overrides), verify the compiled selector matches the intended element -- `&` in a nested block expands to the full parent selector, so render the styles with the repo's own styled-components version when in doubt.
- **Security** -- Are inputs validated? Are secrets handled safely? Are there injection risks?
- **Design** -- Is the abstraction level appropriate? Are responsibilities well-separated? When the PR introduces a new abstraction (component, hook, module, utility, type, interface), search the codebase for existing abstractions that solve the same problem -- can they be reused, composed, or generalized instead of reimplemented? A parallel implementation of an existing pattern is a design finding even when the new version is well-written. This includes a styled element that rebuilds a control another component provides, and a style override that reaches into another component's internals (`${Other} button`) -- the default question is whether the target should own a variant. A styled-component that gains layout declarations (flex, alignment, gap, sizing) its parent or a layout primitive already provides is duplication too. The same applies to capabilities of libraries already in use -- when hand-rolled code works around a configuration option or API the library provides (e.g. building HTML strings to get behaviour a UI library offers natively), name the built-in and rate the workaround at least as severe as the worst finding it causes. When new inline code in a component or function is self-contained (produces a small set of outputs without depending on surrounding state), flag the extraction opportunity -- a hook, utility, or helper that encapsulates the logic reduces complexity. When a consumer adds a fallback (`?? x`, `O.getOrElse`) for a value the decoder or constructor already guarantees, the type is looser than the runtime invariant -- propose tightening the type (e.g. move an io-ts field from `t.partial` to `t.type`) rather than deduplicating the fallback. The input-side mirror: when a spec uses `unsafeCoerce`, `as unknown as`, or `jest.mock` only to build a function's argument, the function takes a wider type than it reads -- propose narrowing the parameter (e.g. a `Predicate<string>` instead of `Env`) so tests pass plain values. When a doc, rule, or comment change records a quirk in the code ("X also exports Y"), verifying the claim is not enough -- ask whether the quirk is a defect, and when the code is cheap to fix (e.g. an export with no consumers), propose fixing it and dropping the note.
- **Architecture** -- Is the overall solution approach sound? Do component boundaries, module decomposition, and dependency directions make sense? Does the change align with (or intentionally evolve) the system's existing architectural patterns, or does it introduce unnecessary coupling? Apply the **architect-thinking-g** skill: does the change preserve options or lock in decisions unnecessarily? Does it increase or decrease the rate of future change in the affected area? Is configuration treated as code (version-controlled, validated, tested)? Are cross-boundary effects and feedback loops considered?
- **Test coverage** -- Are new behaviors tested? Are edge cases and error paths covered? For new test files, read the project's testing-standards rule and check the `describe` tree against it line by line -- the root `describe` names the file under test uniquely within its package (qualify with the parent folder when the basename repeats, e.g. `reference/resolvers`), each nested `describe` names one tested function as the rule prescribes (e.g. `Alias.fnName` with a namespace import), and `it` titles follow the rule's wording (e.g. start with "should"). When a spec needs heavy setup to verify a small rule (`render`/`renderHook`, `fireEvent`, providers, several internal `jest.mock`s, fake timers, mock call history), the setup is the finding: propose extracting the logic into a pure function or reducer with time and IO passed in, and replacing the spec with plain unit tests of it. Specs of structural code (styled-components, theme tokens, config), specs that read source files and match their text (`fs.readFileSync`), and specs that only check framework behaviour are not coverage -- propose deleting them, never a replacement test. Codec tests must exercise what the codec adds over its base: each nullable or optional field's `null`/absent case and a wrong-type rejection. Are property-based tests used where hand-rolled fixtures would miss edge cases or silently drift when types evolve? Do test file names and locations match their source modules?
- **Performance** -- Are there obvious inefficiencies, unnecessary allocations, or N+1 patterns?
- **Flexibility** -- Is the code additive (new behavior can be added without modifying existing code)? Do functions follow Postel's law (wide inputs, narrow outputs)? Are cross-cutting concerns (logging, metrics) layered independently from domain logic? Are generation and evaluation separated where applicable? Are combinators used so that primitives and combinations share the same interface?
- **Clarity** -- Can a reader understand the intent without extra explanation? Are names descriptive?
- **Convention compliance** -- Does new code follow the project's loaded workspace rules? Check every conditional rule loaded in the rule-loading step against relevant changed files. When an always-applied rule (naming, fp-ts patterns, module anatomy) applies to a changed file, verify compliance. For new files, for new exported functions, types, or constants added to existing files, and for existing files that gain a second type's operations (a lookup table, a key type and functions over it): verify they don't violate module placement rules -- when the project defines function-to-module ownership conventions, functions belong to the module of their primary input type, not in satellite files. The primary input type can be a single field of a wider type (a function taking `Pick<Descriptor, 'type'>` belongs with the field's type) or a third-party type (`Highcharts.Options` -> `HighchartsOptions.ts`). A file named after a single function, or holding only one value named after the file, is never a valid home -- move the value to the module that owns its concept, and when it only aliases an existing token, use the token directly. Fixture builders in specs that construct a domain value (e.g. a local `toFund` returning an `EntityBase`) are constructors for that type -- propose them on the type's module under its existing constructor convention (`zero`, `of`). Apply the same test to type declarations: a type that names a domain concept belongs beside the domain types it composes, not in the transport, resolver, or translation module that first consumes it. Warning signs: it is exported but imported nowhere else, or importing it would make a lower layer depend on a higher one. Check whether binary operations on a domain type form an algebraic structure (Semigroup, Monoid) that belongs on the type's module rather than inline in a consumer. Do not dismiss findings because surrounding code has the same violation -- new code converges toward the standard regardless of existing debt. A violation the PR moves, splits, or duplicates into added lines is new code, even when the value existed before (e.g. one hardcoded `fontSize` becoming two after a style object is split per mode). When the PR edits rules, skills, or other normative guidance, list each removed or reworded normative statement (must, never, always, checks, limits) next to its replacement and flag every loosened, tightened, or dropped requirement the PR's goal doesn't explicitly cover -- rewording that changes agent behaviour counts. When inline requirements are replaced with a pointer to another source, check each removed item against the target: it must state the same requirement and must not allow what the removed item forbade.

## Comment Severity (internal only)

Classify every finding internally to determine the review verdict:

- **Blocking** -- Must be resolved before merge. Correctness bugs, security issues, data loss risks.
- **Suggestion** -- Recommended improvement. Better naming, clearer structure, missing test. Non-blocking.
- **Nit** -- Minor style or preference. Formatting, word choice, import order. Non-blocking.

This classification is for **verdict logic only** -- it determines whether the outcome is Request Changes or Comment Only. Do not include severity labels, prefixes, or tier names in the posted comment text. The author should treat every comment as equally worthy of consideration.

## Comment Constraints

Every review comment must be **actionable** and **line-anchored**:

- **Actionable** -- the comment identifies a concrete problem, risk, or improvement **and shows how to solve it differently**. Naming the problem is not enough -- the comment must include the alternative approach (inline code, a description of the technique, or a reference to the applicable pattern). "Remove this `useEffect`" is not actionable; "Derive this value inline during render instead of syncing it through an effect" is. Comments that merely summarize what the code does, restate the PR description, or praise without requesting a change are not actionable and must not be drafted. Before proposing an alternative, check how sibling modules already solve the same problem and propose that idiom rather than an ad-hoc one. Escape hatches don't count as idioms: never propose `as`, `unsafeCoerce`, `@ts-expect-error`, or an eslint suppression as the fix for a type problem -- narrow the function's input to what it reads, or build a fully typed value with the domain's own constructors.
- **Line-anchored** -- the comment references at least one specific line in at least one specific file in the diff. Free-floating observations that cannot be tied to a code location do not belong as review comments.

## Thread Status

The reviewer creates comments; the author resolves them. This separation ensures the author reads, considers, and addresses each comment on their own terms.

- **Always create threads as Active.** Use `repo_create_pull_request_thread` from the native Azure DevOps MCP -- it defaults to `Active` status. Never set status to `Fixed`, `WontFix`, `ByDesign`, or any resolved state when creating a comment thread.
- **Never change a thread's status during initial review.** Do not use `repo_update_pull_request_thread` (or any platform equivalent) to resolve, close, or transition a thread the reviewer created. The author owns the lifecycle.

**Exception -- follow-up reviews:** During `/review-pr-fixes-g`, the reviewer changes thread status to reflect verification outcomes. Threads whose fixes are verified adequate are resolved (status -> `Fixed`). Threads whose fixes are inadequate or missing are reactivated (status -> `Active`). This is the only context where the reviewer manages thread lifecycle. See the `/review-pr-fixes-g` skill for the full protocol.

## Tone

Apply the **objective-communication-g** skill to all review comments.

- Be **constructive** -- frame comments as improvements, not criticisms.
- Be **specific** -- reference the exact line, variable, or pattern. Avoid vague feedback.
- Be **actionable** -- explain *why* something is a problem and **describe the alternative implementation approach**. Don't stop at "don't do X" -- show *how* to achieve the same goal without X. When the alternative is non-trivial, include a brief code sketch.
- When a suggestion involves refactoring (renaming, extracting, moving, restructuring existing code), **mention casually** that the change belongs in a preceding refactoring commit -- e.g. "Rename `processItems` to `applyTransformations` in a preceding refactoring commit." This reinforces the ordering rule from the **commit-conventions-g** skill without sounding prescriptive or formal.
- **Ask questions** when intent is unclear rather than assuming a mistake.
- Do not draft comments for praise or summary observations.

## Presenting Findings

### Draft-first

Every finding must include the literal text that will be posted externally, formatted inside a fenced code block so the user can review and approve it. Draft this on the first review iteration -- never wait for the user to ask "now draft the replies." The review output should be ready to post after a single approval step.

### Inline diff context

When a finding references a specific code modification, include the relevant diff hunk as a fenced code block with `diff` syntax highlighting. Show only the affected hunk (not the entire file diff) so the reader can see the exact context inline without navigating to the file.

This context is for the agent-to-user presentation. The literal comment text posted to the review platform does not include diff hunks -- the platform already anchors the comment to the relevant code.

## Verdicts

- **Request changes** -- One or more blocking comments exist. The author must address them.
- **Comment only** -- Feedback provided, but no strong opinion on merge readiness (e.g., reviewing a subset of the change).

The agent **never** approves a PR. It reviews and comments, but the approval vote is the user's responsibility. Do not offer, suggest, or cast an approval vote -- even when the review has no blocking findings. A clean review produces a "Comment only" verdict (or no comments at all), and the user decides whether to approve.

## Commit Structure

Apply the **commit-conventions-g** skill to evaluate whether commits are well-structured, independently valid, and tell a coherent story. Flag commits that mix infrastructure refactoring (e.g. client migration, import reorganization, cache strategy changes to existing code) with feature work -- these belong in a preceding refactoring commit.