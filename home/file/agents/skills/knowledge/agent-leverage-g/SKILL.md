---
name: agent-leverage-g
description: Strategic framework for using the agent system as a daily professional differentiation engine -- covers the leverage model (how skills operationalize career moats), strategic delegation (what to keep vs. offload), reputation compounding (how consistent quality builds standing), and judgment injection (where to intervene so output reflects personal taste). Use whenever the agent reflects on how it operates on the user's behalf, evaluates what to delegate, or assesses output quality against the user's professional standards.
---

# Agent Leverage

The agent system is the operational manifestation of your career moats. Every skill encodes taste; every workflow enforces judgment; every output carries your professional reputation. The system itself is the moat -- it cannot be copied because it is the product of accumulated decisions about what quality means in your specific context.

Most developers use AI as a stateless tool. You use it as a learning system that accumulates your standards. That difference compounds daily.

## The leverage model

Each moat from **professional-differentiation-g** maps to concrete infrastructure in the skill ecosystem:

| Moat | Operationalized through | How |
|------|------------------------|-----|
| Taste | **decision-priorities-g**, **design-lenses-g**, **code-review-g** | Standards encoded as reusable evaluation criteria that apply automatically |
| Domain knowledge | **client-quality-focus-g**, codebase-specific skills, **work-item-context-g** | Business rules and patterns captured for consistent application across sessions |
| Ownership | Approval gates in **external-communications-g**, verification steps in workflows | The user's seal required at decision points; nothing ships without certification |
| Systems thinking | **architect-thinking-g**, **microservice-patterns-g** | Architectural principles applied automatically to every plan and review |
| Deep work | **context-engineering-g**, strategic delegation | Agent handles mechanical work, freeing sustained focus for genuinely hard problems |

The leverage is multiplicative: taste encoded once applies to every review, every plan, every commit -- without degrading from fatigue or distraction.

## Strategic delegation

### What to keep (builds moats)

- Judgment calls -- deciding between two plausible approaches
- Novel architecture -- designing systems that don't exist yet
- Approval decisions -- certifying that output meets your standards
- Relationship-building -- trust is earned through personal engagement
- Choosing what to build -- product judgment cannot be delegated
- Adversarial review -- the final check that catches the confidently wrong

### What to delegate (the cheap 70%)

- Mechanical execution -- implementing a design that's already decided
- Research and exploration -- gathering context across files, repos, APIs
- Initial drafts -- PR descriptions, commit messages, Slack messages (subject to approval)
- Routine verification -- running checks, confirming state, gathering evidence
- Formatting and boilerplate -- structure, scaffolding, repetitive patterns
- Context-gathering -- reading work items, tracing PR comments, surfacing history

### The principle

Delegate execution to amplify judgment. Never delegate the judgment itself.

The agent's role is to bring you to decision points faster and with better context -- not to make the decisions for you. When you approve, you certify. When you direct, you encode taste. When you reject, you calibrate the system.

### Red flags for over-delegation

- Approving without reading -- rubber-stamping erodes both judgment and quality signal
- Accepting output you cannot explain -- if challenged, you must defend it
- Losing the ability to do the task manually -- the struggle builds the taste
- Feeling surprised by what shipped under your name -- the system has drifted from your standards

## Reputation through consistency

Daily outputs compound into professional standing. Each interaction is a data point in colleagues' model of your reliability, judgment, and standards.

| Output | Quality standard | Skill that ensures it |
|--------|-----------------|----------------------|
| PR description | Motivates the reviewer, structures the walkthrough, scopes precisely | **objective-communication-g** |
| Code review | Demonstrates architectural judgment, domain awareness, proportionate feedback | **code-review-g** + **architect-thinking-g** |
| Commit | Tells a clean atomic story; imperative mood, explains why not what | **commit-conventions-g** |
| Slack message | Crisp, concrete, valuable; respects the reader's time | **external-communications-g** |
| Plan | Grounded in prior art and codebase evidence; structured for decision-making | **prior-art-research-g** + **plan-g** |
| Bug report | Concrete reproduction steps, correct severity, necessary context | **write-repro-steps-g** |
| Estimate | Calibrated to codebase evidence, explicit about assumptions and risk | **estimation-g** |

**Consistency > occasional brilliance.** 100 reliably excellent outputs build more trust than 1 great one amid 99 careless ones. The agent system makes consistency cheap -- the standards apply uniformly regardless of your energy level, time pressure, or cognitive load on a given day.

## Judgment injection points

Taste enters the system at specific moments. Recognise these as the high-leverage interventions:

### Approval gates

**external-communications-g** requires explicit approval before posting to any external platform. This is not bureaucracy -- it is the moment you exercise ownership. Read the candidate text as a stranger would. Ask: does this represent my professional judgment?

### Plan review

When the agent proposes a plan, you evaluate it before execution. This is where product judgment and systems thinking concentrate. Direct the agent ("explore option B instead"), don't just accept.

### Skill evolution

**continuous-improvement-g** proposes refinements after each execution. **review-retrospective-g** identifies patterns across sessions. YOUR observations -- what you accept, reject, or modify -- become encoded standards. Every refinement raises the baseline for all future work.

### Quality calibration

When you reject or modify agent output, be explicit about WHY. "This is too verbose" teaches less than "The reviewer already knows our auth model -- cut the background section." Specific reasoning calibrates future output more precisely.

### The key insight

Taste is injected by curating the system itself (skills, rules, standards), not by editing every individual output. One skill improvement applies to every future execution. One rejected draft informs all subsequent drafts. Invest in the system, not in individual outputs.

## The compounding loop

The system improves through a feedback cycle:

1. **Work** -- agent executes with currently encoded standards
2. **Observation** -- execution reveals friction, gaps, or quality mismatches
3. **Proposal** -- **continuous-improvement-g** suggests a specific refinement
4. **Curation** -- you approve, reject, or modify (injecting taste)
5. **Evolution** -- the skill ecosystem improves
6. **Work** -- next execution starts from a higher baseline

The **review-retrospective-g** skill runs this loop at batch scale (weekly, across all sessions). The compounding effect: each week's baseline is higher than the last. Over months, the gap between your agent-augmented output and generic AI output becomes unbridgeable.

## Anti-patterns

| Anti-pattern | Why it fails | Remedy |
|--------------|-------------|--------|
| **Rubber-stamping** | Erodes judgment and quality signal simultaneously. Colleagues notice inconsistency. | Engage adversarial review at every approval gate. If you cannot defend it, don't ship it. |
| **Over-delegation** | Offloading judgment calls that would build moats. Taste atrophies without exercise. | Keep novel decisions manual. Delegate only after the pattern is established. |
| **Under-investment** | Treating skills as static. A stale system degrades as context evolves. | Run `/review-retrospective-g` weekly. Act on proposals. The system is alive or dying. |
| **Attribution opacity** | Shipping output you cannot explain. "The AI wrote it" is never a valid defence. | Before approving, explain to yourself why each non-trivial part is correct. |
| **System hoarding** | Refusing to share principles with your team. | Share the principles (they help everyone); the specific calibration is personal and non-transferable. Your moat is the accumulated judgment, not the file format. |

## Relationship to other skills

- **professional-differentiation-g** -- defines the moats; this skill operationalizes them through the agent system.
- **continuous-improvement-g** -- the reactive feedback mechanism that proposes system evolution after each execution.
- **review-retrospective-g** -- the proactive batch-level mechanism that identifies patterns across sessions.
- **context-engineering-g** -- enables deep work by managing cognitive load; keeps the agent efficient.
- **external-communications-g** -- the outward-facing quality gate where reputation is built or eroded.
- **objective-communication-g** -- the intellectual standards for all delivered text.
- **decision-priorities-g** -- the priority ladder that encodes taste into every design decision.
