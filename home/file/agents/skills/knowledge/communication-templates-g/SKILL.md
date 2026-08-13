---
name: communication-templates-g
description: "Exact structural templates for recurring delivered text, grounded in objective-communication principles. Sub-skill of **delivered-text-g** -- handles structure (layer 3). Loaded conditionally when a matching template exists for the text type."
---

# Communication Templates

Structural templates for every recurring external communication type. Each template is a fill-in-the-blank skeleton grounded in specific **objective-communication-g** principles.

This skill provides the **structure** layer (layer 3 in **delivered-text-g**). It adds fill-in-the-blank skeletons -- what goes where -- on top of the principles and voice provided by the other sub-skills.

> **Prerequisite**: This is **layer 3** of the **delivered-text-g** stack. If you reached this skill directly, load **delivered-text-g** first -- it defines scope, the priority ladder, and which other layers apply alongside this one.

## Tier selection

Every type has 2--3 named tiers. The agent selects the tier based on **observable context signals** -- not subjective judgment. Each tier's "When" section lists the signals.

For extended good/bad examples of each tier applied to realistic scenarios, see [reference.md](reference.md).

---

## 1. PR Title

**Variation dimension**: scope
**Focused principles**: Delimit, Motivate
**Register**: **writing-style-g** > PR/MR titles
**Defers to**: workspace commit/PR conventions when they exist

### Simple

**When**: the PR addresses a single concern.

```
<Imperative verb> <what> <scope>
```

Capitalized, no trailing period. Keep under 50 characters when possible.

### Compound

**When**: the PR addresses multiple concerns that can't be split into separate PRs (e.g., a refactor required by the feature it enables). This tier handles unavoidable cases -- it doesn't endorse compound PRs.

```
<Imperative verb> <primary change>; <secondary change>
```

**Anti-patterns**:

- `Fix stuff` -- violates Delimit (no scope signal) and Motivate (no "so what")
- `Refactor authentication module and add rate limiting and update tests and fix typo in readme` -- violates Delimit (should be separate PRs)
- Splitting a coherent change into separate PRs just to keep titles simple -- violates Structure (the changes are logically coupled)

---

## 2. PR Description

**Variation dimension**: complexity
**Focused principles**: all seven
**Register**: **writing-style-g** > PR/MR titles and descriptions

### Minimal

**When**: 1 commit, <=3 files changed, no new API surface, no behavioural change beyond the obvious fix.

```
<Why this change is needed -- the motivation the diff can't convey.>
```

One to two sentences. The diff speaks for itself; the description adds only what the diff can't show.

### Standard

**When**: 2--5 commits, single module or feature area, moderate complexity.

```
<Why this change is needed -- what problem or goal motivated it.>

<What changed -- net effect on the codebase, not a commit-by-commit narration.>
<Optional bullets for multi-part changes:>
- <Part 1>
- <Part 2>

<Non-obvious impact -- what the reviewer should watch for, if anything.>
```

### Thorough

**When**: 6+ commits, multiple modules touched, new architectural patterns introduced, or the reviewer can't reconstruct intent from the diff alone.

```
<Why -- the problem, opportunity, or constraint that necessitated this work.
What makes it worth the reviewer's time.> (Motivate)

<What changed -- the net effect on the codebase after the PR lands.
Describe the target state, not the journey.> (Delimit, Anti-rationalism)

<Approach -- why this design was chosen. What alternatives were
considered and why they were rejected, briefly.> (Structure, Objectivity)

<Impact -- what areas of the system are affected. What the reviewer
should pay attention to. Any behavioural changes, migration needs,
or configuration changes.> (Self-containment)

<Scope boundaries -- what was explicitly excluded and why.> (Delimit)
```

**Anti-patterns**:

- Narrating intermediate approaches or abandoned paths -- violates Delimit (report net effect only, per **objective-communication-g** > Summarising Changes)
- `## Summary` / `## Test Plan` section headings -- violates Structure (these are arbitrary scaffolding, not logical structure; write prose that flows)
- Restating every commit message as a bullet list -- violates Delimit (the commit log already exists)
- A one-line description for a 10-commit architectural change -- violates Self-containment (raises questions it doesn't answer)

---

## 3. Commit Message

**Variation dimension**: scope and non-obviousness
**Focused principles**: Delimit, Structure, Self-containment
**Register**: **writing-style-g** > Commit messages
**Defers to**: **commit-conventions-g** for hygiene, ordering, and workspace-specific format

### Subject-only

**When**: 1 file changed, the reason is obvious from the diff (typo, import fix, formatting).

```
<Capitalized imperative summary>
```

No body needed. Subject <=50 characters, no trailing period.

### Subject + body

**When**: 2+ files changed, or the reason for the change isn't obvious from the diff.

```
<Capitalized imperative summary>

<Why this change is necessary -- the problem or constraint.
Wrap at 72 characters.>
<Why this approach -- what makes it the right fix.>
```

Blank line between subject and body. Body explains what and why, not how.

### Subject + body + context

**When**: refactoring commit, architectural decision, or a change that sets precedent for future code.

```
<Capitalized imperative summary>

<Why this change is necessary -- the problem or constraint.>

<Why this approach -- the reasoning chain.>
<What alternatives were considered, briefly.>
<What precedent this sets, if any.>
```

**Anti-patterns**:

- Restating the diff in prose ("Change `foo` to `bar` in `utils.ts`") -- violates Delimit (the diff already shows this; the body should explain why)
- A body that raises questions the diff can't answer ("This is part of a larger migration") without explaining what migration or linking to context -- violates Self-containment
- Subject line over 50 characters -- violates rule 2 (keep the subject scannable)
- Trailing period on the subject line -- violates rule 4 (the subject is a title, not a sentence)
- Lowercase subject -- violates rule 3 (capitalize)
- Empty body on a multi-file refactor -- violates Self-containment (the reader can't reconstruct intent)

---

## 4. Review Request (Slack)

**Variation dimension**: urgency
**Focused principles**: Motivate, Delimit, Concretise
**Register**: **writing-style-g** > Slack and casual messages

### Routine

**When**: standard velocity, no deadline pressure, no specific areas of concern.

```
<PR link> -- <one-line summary of what the change does>
```

### Focused

**When**: specific areas need attention, known risks, or the reviewer benefits from guidance on where to look.

```
<PR link> -- <one-line summary>

<What to focus on -- specific files, patterns, or concerns>
```

### Urgent

**When**: blocking a deployment, hotfix for production, or hard deadline within 24 hours.

```
<PR link> -- <one-line summary>

<Why it's urgent -- what's blocked or at risk>
<Deadline, if any>
<What to prioritise in the review -- where to spend limited time>
```

**Anti-patterns**:

- `PTAL` with no context -- violates Motivate (gives the reviewer no reason to prioritise this over other work)
- Pasting the full PR description into Slack -- violates Delimit (the PR link already has the description; the Slack message should add only what the link doesn't provide)
- Marking everything as urgent -- violates Objectivity (if everything is urgent, nothing is)

---

## 5. PR Review Comment

**Variation dimension**: severity
**Focused principles**: Objectivity, Concretise, Anti-rationalism
**Register**: **writing-style-g** > Code review comments
**Defers to**: **code-review-g** for severity definitions, actionability, and thread status rules

### Nit

**When**: style preference, naming suggestion, minor readability improvement. Non-blocking.

```
nit: <what to change>, <optionally why in a few words>
```

### Suggestion

**When**: recommended improvement that makes the code better but doesn't block merge. Non-blocking.

```
<What the problem is -- observable, specific>

<Why it matters -- what it affects (readability, maintainability, performance)>

<Concrete alternative -- code sketch, technique name, or description
of how to restructure>
```

### Blocking

**When**: correctness bug, security issue, data loss risk, or spec violation. Must resolve before merge.

```
<What the problem is -- observable, specific> (Objectivity: formulation)

<Evidence -- link to failing test, spec, observable behaviour,
or reproduction steps> (Anti-rationalism: grounded in facts)

<Why it matters -- what breaks if unaddressed> (Objectivity: defence)

<Concrete alternative -- code sketch or approach that fixes it> (Concretise: pay the IOU)
```

**Anti-patterns**:

- `This is wrong` without showing what's right -- violates Concretise (every abstraction is an IOU; the alternative pays it off)
- Objecting based on a principle without grounding in the specific code ("We should never use mutation") -- violates Anti-rationalism (floating principle disconnected from the observable context)
- Omitting severity -- violates Objectivity (the author can't tell whether this blocks merge)
- Praise comments ("Nice refactor here") -- violates Delimit (not actionable; the **code-review-g** skill forbids them)

---

## 6. PR Review Reply

**Variation dimension**: alignment
**Focused principles**: Anti-rationalism, Objectivity
**Register**: **writing-style-g** > PR/MR comments

### Agree

**When**: the reviewer's point is valid and you'll act on it.

```
<Confirmation, optionally with reasoning -- why you agree or what you learned>
```

Don't describe the code change -- the reviewer sees the updated diff. Reasoning about *why* you agree or *why* the suggestion is better is welcome. "Fixed." or "Good point -- the old approach swallowed errors." are both fine.

### Disagree

**When**: you have evidence that the current approach is correct or preferable.

```
<Acknowledge the reviewer's concern -- the substance, not the conclusion>

<Counter-evidence -- grounded in code, tests, specs, or observable behaviour.
Not "I think" or "I feel" -- point to facts.>

<Proposed resolution -- keep as-is with stated reason, or offer a compromise>
```

Apply the argumentation rules from **objective-communication-g** > Arguing in Reviews -- especially "do not concede premises you reject."

### Clarify

**When**: you're not sure what the reviewer is asking for, or the objection could mean multiple things.

```
<Restate your understanding of the reviewer's point>

<Specific question to disambiguate>
```

Don't guess and defend against a misunderstood objection. Ask first.

**Anti-patterns**:

- Describing the code change ("Renamed `foo` to `bar` and updated the callers") -- the diff shows this; confirm and optionally reason, don't narrate
- Responding to every comment with the same tone and length -- violates the crow epistemology (monotone energy is an LLM tell; vary by importance)
- "I think maybe we could consider..." -- violates Objectivity (state your position or ask a question; don't hedge)
- Conceding a premise for the sake of argument ("You're right that X, but...") when you don't believe X -- violates Anti-rationalism (per **objective-communication-g** > Arguing in Reviews)

---

## 7. Work Item Title

**Variation dimension**: item type
**Focused principles**: Delimit, Self-containment
**Register**: **writing-style-g** > Work-item descriptions

Other item types (Epic, User Story) follow their own workflows -- see the **prd-intake-g** skill.

### Bug

**When**: creating a Bug work item.

```
<Observable symptom> <where it occurs> <when it occurs>
```

Describe what the user sees, not the implementation cause.

### Feature

**When**: creating a Feature or User Story work item.

```
<Verb> <user-facing outcome> <scope/context>
```

Outcome-oriented. "Support browsing large order lists" not "Handle pagination in OrderList component."

### Task

**When**: creating a Task work item.

```
<Verb> <what to deliver> <context/parent scope>
```

Action-oriented, scoped to a concrete deliverable.

**Anti-patterns**:

- `Refactor OrderService` -- violates Motivate (why? what's the outcome?) and Delimit (refactor everything? or a specific aspect?)
- `Improve performance` -- violates Delimit (which performance? where? how much?) and Self-containment (can't stand alone without reading a parent item)
- `Fix bug` -- violates Delimit (which bug?) and Concretise (no observable symptom)
- `Investigate issue with deployments` -- violates Self-containment if the "issue" isn't described (the reader must chase context elsewhere)

---

## 8. Work Item Description

**Variation dimension**: item type and complexity
**Focused principles**: Motivate, Delimit, Concretise, Self-containment
**Register**: **writing-style-g** > Work-item descriptions

### Bug (minimal)

**When**: clear reproduction, no investigation done yet.

```
<What happens -- the observable symptom> (Concretise)

<Steps to reproduce -- numbered, minimal, verifiable> (Concretise, Self-containment)

<Expected behaviour vs. actual behaviour> (Objectivity)

<Severity/frequency -- how often, who's affected> (Motivate)
```

### Bug (investigated)

**When**: root cause is known or suspected, a fix approach exists.

```
<What happens -- the observable symptom> (Concretise)

<Steps to reproduce> (Concretise, Self-containment)

<Expected vs. actual> (Objectivity)

<Root cause -- what's going wrong in the code and why> (Anti-rationalism)

<Proposed fix approach -- what to change and why this approach> (Structure)

<Affected areas -- what else might break or need updating> (Self-containment)
```

### Feature

**When**: creating a feature or user story work item.

```
<Problem or opportunity -- why this work matters to users.
What pain point or value gap exists.> (Motivate)

<Scope -- what's included and what's explicitly excluded.
Boundaries the implementer should respect.> (Delimit)

<Acceptance criteria -- observable, testable conditions
that define done.> (Concretise, Self-containment)
```

### Task

**When**: creating a task (typically a child of a feature or bug).

```
<What needs to happen -- the concrete deliverable> (Delimit)

<Why -- how this connects to the parent work item.
Link to the parent.> (Motivate, Structure)

<Done criteria -- how to verify completion> (Concretise)
```

**Anti-patterns**:

- Copying a PRD verbatim into the description -- violates Delimit (the work item's scope is narrower than the PRD's)
- A description that requires reading a separate document to understand -- violates Self-containment (the item should stand on its own)
- Acceptance criteria like "works correctly" -- violates Concretise (not observable or testable)
- Bug descriptions without reproduction steps -- violates Self-containment (the reader can't verify or investigate without them)

---

## 9. Slack Status Update

**Variation dimension**: significance
**Focused principles**: Motivate, Concretise, Delimit
**Register**: **writing-style-g** > Slack and casual messages

### Routine

**When**: the recipient has context (e.g., they're following the work), and the update is expected.

```
<What happened> -- <link>
```

One line. No elaboration needed.

### Significant

**When**: the update has consequences the recipient needs to act on, or the context isn't obvious.

```
<What happened -- the net effect> -- <link>

<Impact or consequence -- what changes for the recipient>
<Next step or ask, if any>
```

**Anti-patterns**:

- Restating everything the recipient already knows -- violates Delimit (update, don't recap)
- An update with no link -- violates Concretise (the reader can't verify or follow up)
- Burying the ask at the end of a long paragraph -- violates Structure (lead with what the reader needs to do)

---

## 10. Slack Thread Answer

**Variation dimension**: answer complexity
**Focused principles**: Concretise, Structure, Self-containment
**Register**: **writing-style-g** > Slack and casual messages

### Quick

**When**: the question has a direct, verifiable answer that fits in 1--2 sentences.

```
<Direct answer> -- <link or evidence>
```

No preamble. Don't bury the answer.

### Detailed

**When**: the answer requires explanation, multiple pieces of evidence, or the questioner's assumptions need correction.

```
<Direct answer -- don't bury the lede> (Structure)

<Supporting evidence -- link, code reference, screenshot,
or observable fact> (Concretise, Anti-rationalism)

<Elaboration -- additional context, caveats, or related
information the questioner didn't ask about but needs> (Self-containment)
```

**Anti-patterns**:

- Hedging without evidence ("I think maybe it's...") -- violates Objectivity (state what you know, qualify with a reason if uncertain, don't hedge with timidity)
- Answering a different question than what was asked -- violates Objectivity (check formulation: what did they actually ask?)
- A wall of text with no structure -- violates the crow epistemology (break into short paragraphs or bullets)
- Providing only a link with no summary -- violates Self-containment (the reader shouldn't have to click through to get the answer)
