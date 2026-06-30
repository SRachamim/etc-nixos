# Objective Communication Reference

Detailed principles, extended examples, and checklists for the **objective-communication** skill. The agent reads this on demand when composing delivered text that warrants deeper guidance.

Source: Leonard Peikoff, *Objective Communication: Writing, Speaking, and Arguing* (ed. Barry Wood).

## Epistemological Foundations

Three facts about human consciousness underpin every principle:

### Knowledge is conceptual

Concepts are mental integrations condensing vast numbers of percepts into single units (words). Unlike perception, concepts are not automatically clear, not necessarily formed correctly, and not necessarily tied to reality. When people learn words without grounding them in actual facts, the result is **floating abstractions** -- terms with no real connection to reality.

**Implication:** Clarity must be *achieved* through deliberate technique. The communicator must keep the audience tied to reality at each point -- through decisions about where to start, what to include, what order to follow, and when to give examples.

### Knowledge is contextual

Knowledge is a relational structure where each item connects to others. Every new point is understood in terms of what has come before -- its **context**. The same sentence means radically different things depending on the listener's existing knowledge and assumptions.

**Implication:** Know the audience's context before composing. What do they already know? What ideas govern how they will interpret what you say? What errors might confuse them? Structure material so each point creates the context required for the next.

### The crow epistemology

Consciousness has a specific, limited identity. It can deal with only so many units at one time. Beyond that limit, content becomes a blur and the mind cannot encompass it.

**Implication:** Economise units. Avoid overloading the reader with too many points before tying them up. Once they give up, getting them back is extremely difficult. This applies at every level -- from a single sentence to an entire document.

## Detailed Principle Elaboration

### Motivation -- Extended

The "double assignment": the communicator is responsible for both **what** (the content) and **so what** (why it matters to the audience).

Techniques:
- **Grabber** -- an intriguing opening (story, provocative question, dramatic example) that breaks through initial scepticism.
- **Anticipate sceptical questions** at the moments they will arise. Address them explicitly: "You may be thinking X -- here is why."
- **Use "you"** to make it personal and direct.
- **Periodic reminders** -- re-establish motivation throughout, not just at the outset.

### Delimitation -- Extended

Three factors determine what to include:
1. **The subject** -- certain points are indispensable by the logic of the topic (the "bare minimum").
2. **The audience** -- their knowledge level determines what you can omit and how complex you can be.
3. **The space/time available** -- a commit message, a PR description, and a design document on the same change will cover very different amounts.

Delimitation applies not only to what **topics** you cover, but to **how you word** individual statements. A careless formulation can raise questions you cannot answer within your scope.

### Structure -- Extended

"I love you; let us get married" (cause then effect) works. "Let us get married; I love you" (effect then cause) works. "Turnips taste good; let us get married" does not work.

Techniques:
- Tell the reader the structure. Preview, execute, summarise.
- Numbering helps -- readers feel relief when a numbered point ends.
- Within paragraphs, ensure a definite progression where earlier sentences prepare for later ones.
- Surprise and mystery are fine, but must be *good* mystery -- the reader must understand what they know and what they do not yet know.

### Concretisation -- Extended

The method: **shuttle** between concretes and abstractions. Give examples, tie them up abstractly, give more examples.

Two errors:
- **Floating abstractions** -- principles with no concrete grounding. The audience hears words but cannot connect them to anything real.
- **Concrete-boundness** -- a pile of examples with no unifying principle. Equally unretainable (the "fourteen causes of World War II" approach).

Inductive vs. deductive:
- **Inductive** (examples first, then principle): good for very abstract topics with unfamiliar audiences. Build up from concretes.
- **Deductive** (principle first, then examples): good when the audience already has a general sense of the topic.

Do not inundate with examples. Give enough to anchor the point, then abstract.

### Self-Containment -- Extended

The tension: you want to give a strong case (pushing you to include more), but past a certain point, you spill over into the un-self-contained. This is a balancing act.

How to judge what needs explanation:
- **Use experience** -- notice when people become baffled. Patterns emerge.
- **Use autobiography** -- ask "What was unclear to me when I first learned this?"
- **Use the audience as the standard** -- what requires explanation depends on their context.

**Glancing references:** When you must comment on something without fully covering it, explicitly acknowledge the issue and state you are not covering it here. This puts your cards on the table.

**The moral-practical integration:** When your moral point raises practical questions, address both. If you lack space, at minimum *indicate* that a practical answer exists.

**Build up to controversial conclusions.** Do not state shocking conclusions before preparing the ground. A conclusion that is luminously clear in one context is arbitrary and alienating in another.

### Objectivity -- Extended

Three categories of non-objective formulations:

1. **Arbitrary statements** (not self-contained): saying something unprepared, unexplained, and undefended. The reader does not see why you are saying it.

2. **Poor formulation** (unclear wording):
   - Vague and undefined -- key terms that could mean anything
   - Ambiguous -- multiple possible meanings
   - Misleading implications -- commits you to something you would never accept
   - Even punctuation matters

3. **Poor placement** (misleading context): the formulation is true and clear, but its position implies something unintended. Moving it eliminates the problem.

**Package deals:** An undefined key term can combine two distinct concepts under one label. Without defining the term, you can oscillate between attacking one and the other without confronting the contradiction.

**Moral:** If a term is central to your presentation, have a firm definition in your own mind. Otherwise you can say contradictory things while appearing consistent.

### Anti-Rationalism -- Extended

Two forms:
1. **Positive rationalism:** Using deduction from arbitrary premises to "prove" your position. The conclusion defies reality but is defended as logically necessary.
2. **Negative rationalism (rationalist polemics):** Accepting the opponent's premise and showing he contradicts himself. Inadvisable because you train yourself to fight on his turf and widen the breach between your mind and reality.

How to detect rationalism:
- Very abstract content disconnected from concrete observation
- A deductive chain ("if this, then this; therefore...")
- Collapse when you ask "Why?" at a crucial premise

The proper approach: start from reality, state positively what is the case, and show why the opponent's arguments fail when measured against actual facts.

## Speaking Principles Adapted for Real-Time Written Exchanges

These principles from Part III apply to Slack threads, PR comment threads, and any back-and-forth written exchange:

### Pace

Readers in real-time exchanges are closer to listeners than to careful document readers. They skim, they are context-switching, they are under time pressure.

- Simplify language. Short sentences, common words.
- Repeat key points in different formulations when the thread is long.
- Signal transitions explicitly: "Separate issue:" or "Back to the original point:"

### Circling around

In real-time exchanges, imprecise first formulations are normal. The skill is in self-monitoring and self-correction: say something, realise it could be misinterpreted, and immediately restate.

### Monitoring

In Slack, monitor reactions and follow-up questions for signs of confusion or disengagement. Adapt:
- If the reader seems confused: add an example, insert a summary, rephrase more simply.
- If the reader seems ahead of you: cut elaboration and get to the point.
- If interest is flagging: reestablish motivation -- explain why this matters.

## Arguing Principles Adapted for Technical Disagreements

### Detect premises

Push past the surface objection to the underlying concern. "This function is too complex" might mean "I value readability over performance" or "I worry about maintainability" or "I do not understand the algorithm." The fix depends on the premise.

### Do not concede false premises

If a reviewer says "We should never use mutation" and you believe controlled mutation is appropriate here, do not say "I agree mutation is bad, but in this case..." Instead, challenge the premise directly with evidence.

### Select one essential

When a review has twelve comments, identify the one that is architecturally significant. Address it first. The others often resolve as consequences.

### Isolate philosophy from facts

When someone cites a benchmark, a blog post, or a "best practice" to justify an objection, ask whether the objection stands independently of that source. If it does not, the source is doing all the work -- evaluate the source, not the conclusion.

### Onus of proof

"This might cause a performance problem" -- the burden is on the claimant to demonstrate it. You are not obligated to prove a negative.

### When stumped

Admit it to yourself. Say "I need to think about that" rather than improvising a weak response. Come back with a considered answer.

## Master Action-Item Checklist

### Before composing (planning)

- [ ] Define the audience. Who are they? What do they know? What do they care about? What errors might confuse them?
- [ ] Identify the "so what?" -- why should this audience care? Prepare a motivational statement.
- [ ] Delimit ruthlessly. List the bare minimum (must include) and optional (can cut). Exclude everything else.
- [ ] Create an outline. Even a matchbox outline of 3--5 key words. Know the logical order and be able to defend it.
- [ ] Check self-containment. For each point: does this raise questions I cannot answer here? If yes, reformulate, glancing-reference, or excise.
- [ ] Plan concretisation. For each key abstraction, prepare at least one concrete example. For each group of examples, prepare an integrating abstraction.

### While composing

- [ ] Write freely first. Get content out without self-censorship. Do not edit while creating.
- [ ] Then edit as a stranger. Read your work as if written by someone else. Ask: What has this person actually said? What could be legitimately misinterpreted?
- [ ] Check formulations. Is every statement clear, specific, and free of misleading implications?
- [ ] Check placement. Does each statement's position imply only what you intend?
- [ ] Check for rationalism. Does every deductive chain start from observed reality? Does the conclusion match facts?
- [ ] Check for floating abstractions. Can you point to concrete instances for every key term?

### Crow epistemology check

- [ ] Count unresolved units. How many concepts is the reader holding before you tie them up?
- [ ] Summarise or integrate before introducing new points.
- [ ] Break long sequences into numbered sections.

### Arguing (in reviews and discussions)

- [ ] Push toward fundamentals. Keep asking "Why?" until you reach the basic disagreement.
- [ ] Never concede a premise you reject, even "for the sake of argument."
- [ ] Select one essential from any barrage and deny the rest sweepingly.
- [ ] Isolate philosophy from facts. Ask: "If the facts were different, would you change your position?"
- [ ] Invoke onus of proof. You do not have to prove a negative.
- [ ] Conduct a private post-mortem after every argument.

### Always

- [ ] Separate performance from evaluation. When composing, forget the rules. When editing, apply them.
- [ ] Learn one principle at a time. Do not try to hold all principles in mind simultaneously.
