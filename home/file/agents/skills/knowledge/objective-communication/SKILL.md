---
name: objective-communication
description: Communication principles derived from Peikoff's epistemological framework -- motivation, delimitation, structure, concretisation, self-containment, objectivity, and anti-rationalism. Use whenever the agent composes text that will be committed, posted, or published -- PR descriptions, commit messages, Slack messages, plans, technical designs, PRDs, documentation, READMEs, code comments, work-item descriptions, review comments, wiki pages. Do NOT use for agent-to-user conversation in the IDE.
---

# Objective Communication

Effective communication rests on the nature of human consciousness: knowledge is **conceptual** (shorthand for concretes that must be deliberately tied back to reality), **contextual** (understood only in relation to what has come before), and **limited** (the crow epistemology -- consciousness can hold only so many units at once). These facts yield seven actionable principles.

## Scope

This skill applies to **delivered text** -- text that leaves the agent-user conversation (committed, posted, published). It does NOT apply to agent-to-user chat (replies, explanations, plan discussions, clarifying questions in the IDE).

## Seven Principles

### 1. Motivate

Answer "so what?" for the reader. You are asking for their time, effort, and thought -- they will not give it causelessly.

- Attach the subject to the reader's values -- show how it advances what they care about.
- Define the audience before composing: Who are they? What do they know? What do they care about?
- Address scepticism head-on rather than condemning it.
- In longer pieces, provide periodic motivational reminders -- not just at the outset.

### 2. Delimit

Cover only what fits. All knowledge is interconnected, so trying to say everything about any topic would require omniscience. Selectivity is mandatory.

- Identify the **bare minimum** -- points indispensable by the logic of the topic.
- Identify **optional** elaborations -- include if space/time permits.
- Guiltlessly exclude everything else.
- Delimitation applies to **individual formulations** too, not just topic selection -- do not word a sentence in a way that raises issues you cannot address.

### 3. Structure

Each point must rest on the preceding and prepare for the next. There is no single mandatory order, but there must be a **defensible reason** for the order you chose.

- Create an outline before composing, even a "matchbox outline" of 3--5 key words.
- Test the structure: if switching two points makes the material confusing, the current order is doing important work.
- Make the structure visible to the reader -- signal transitions, number points, preview what is coming.
- Within paragraphs, ensure earlier sentences prepare for later ones.

### 4. Concretise

Every key abstraction must be accompanied by concretes (examples, instances), and every cluster of concretes must be tied up with an integrating abstraction. **Shuttle** between levels.

- Treat every abstraction as an IOU -- pay it off with a concrete example immediately.
- Avoid concrete-boundness (a pile of examples with no unifying principle -- equally unretainable).
- Match approach to audience familiarity: inductive (examples first) for unfamiliar topics, deductive (principle first) for familiar ones.
- The more abstract the subject, the more concretisation is needed.

### 5. Self-Containment

Include only what you can explain within this scope. Do not include statements or examples that directly raise legitimate questions you cannot deal with here.

- Only **directly** raised questions count -- every piece indirectly raises every question.
- Only questions from a **rational** audience count -- no piece is impregnable against hostile distortion.
- When you must touch something without fully covering it, make a **glancing reference**: explicitly acknowledge the issue and state you are not covering it here.
- Test every individual **formulation**, not just your topic list -- a single careless sentence can raise unanswerable questions.
- Pitch arguments at the right level of abstraction -- do not go deeper than you have room to explain.

### 6. Objectivity

An objective presentation **stands on its own** -- the author does not have to rush in and explain "I actually meant X." Check three things:

- **Formulation** -- What does this sentence actually say? Is it vague, ambiguous, or misleading?
- **Defence** -- Why does it say it? Important claims need at least some reason, even briefly.
- **Placement** -- Does its position in the text imply something unintended? The same true statement can mislead if placed before the necessary context is established.

Method: write freely first, then switch to editing as a stranger. Ask: "What has this person actually said? What could a rational reader legitimately misinterpret?"

### 7. Anti-Rationalism

Ground every chain of reasoning in observable reality. Rationalism -- deduction without reference to reality -- produces impressive-looking logical structures that float free of facts.

- Before constructing a deductive chain, ask: "What facts am I starting from? Can I point to them?"
- Watch for the signature: high abstraction + deductive chain + collapse when you ask "Why?" at a premise.
- Give **positive** arguments grounded in observable facts, not just negative refutations showing the opponent contradicts himself.
- After constructing a logical chain, check: does the conclusion match what you can observe?

## Platform Application

| Output type | Primary principles | Notes |
|---|---|---|
| **PR title** | Delimit, Motivate | State the *what* and *why* in one line. Scope signal, not a sentence. |
| **PR description** | All seven | Full application -- motivate the reviewer, delimit scope, structure the walkthrough, concretise with code references, keep self-contained, check objectivity. |
| **Commit message** | Delimit, Structure, Self-containment | Defer to **commit-conventions** for format. Subject delimits; body structures the reasoning; avoid raising questions the diff cannot answer. |
| **Code comment** | Delimit, Self-containment, Objectivity | Explain only what the code cannot convey. Do not raise questions the surrounding code does not answer. |
| **Slack message** | Motivate, Delimit, Concretise | Lead with why the reader should care. Scope tightly. Use concrete examples over abstractions. |
| **PR / code review comment** | Objectivity, Concretise, Anti-rationalism | State what the problem is (formulation), why it matters (defence), and show a concrete alternative. Ground feedback in observable code, not floating principles. |
| **Plan / technical design** | All seven | Heavy emphasis on Structure (defensible ordering), Concretise (examples for each design decision), and Self-containment (do not reference unexplained concepts). |
| **PRD** | Motivate, Delimit, Structure, Concretise | Lead with user value, scope ruthlessly, structure requirements logically, concretise with user stories and acceptance criteria. |
| **Documentation / README** | Motivate, Structure, Concretise, Self-containment | Answer "why should I read this?" early. Structure for scanability. Every concept gets an example. Do not assume context the reader lacks. |
| **Work-item description** | Motivate, Delimit, Self-containment | State why the work matters, scope it precisely, include enough context that the item stands on its own. |

## Arguing in Reviews

When defending or challenging a position in PR reviews, design discussions, or technical debates, apply these principles from Peikoff's argumentation framework:

- **Detect premises.** When a reviewer objects, ask "Why?" until you reach the foundational disagreement. Concrete disputes often mask deeper differences about architecture, performance, or maintainability.
- **Do not concede premises you reject.** If you accept a false premise "for the sake of argument," you lose the ability to appeal to the facts that settle the question. Challenge directly.
- **Select one essential from a barrage.** If multiple objections arrive at once, pick the most fundamental and address it. Sweepingly acknowledge the rest: "I disagree with these other points too, but let me address X first."
- **Isolate philosophy from facts.** When confronted with dubious benchmarks, studies, or claims, ask: "If this data were different, would you change your position?" If not, the data is a tactic -- address the underlying design principle instead.
- **Invoke onus of proof.** The burden is on whoever asserts. An unsupported claim deserves a flat denial, not a defensive rebuttal.

## Editing Discipline

- **Separate performance from evaluation.** When composing, focus on getting content out. When editing, switch to evaluating as a stranger.
- **Read as a stranger.** Cut yourself off from everything in your mind that you did not put on paper. Ask: "What has this person actually said?"
- **Check formulations individually.** For each statement: What does it say? What does it commit me to? What could be legitimately misinterpreted?
- **Check placement.** Would the same sentence mean something different if placed earlier or later?

## Crow Epistemology Check

Before finalising any delivered text, count the unresolved units you are asking the reader to hold simultaneously. If you are giving them more than they can retain before tying things up:

- Summarise or integrate accumulated points before introducing new ones.
- Break long sequences into numbered sections.
- Reduce the number of concepts in play at any one time.

## Additional Resources

For detailed principle elaboration, extended examples, speaking/arguing adaptations, and the full master checklist, see [reference.md](reference.md).
