---
name: architect-thinking
description: Architectural thinking principles from "The Software Architect Elevator" (Hohpe) -- options thinking, rate of change, systems thinking, decision quality, communication, organisational awareness, and flow. Use whenever the agent plans features, reviews code or plans, designs artifacts, estimates work, or investigates incidents.
---

# Architect Thinking

Principles extracted from Gregor Hohpe's *The Software Architect Elevator*, organised into seven categories. Each section lists the core principles, when to apply them, and (where relevant) how they map to functional TypeScript with fp-ts.

For detailed chapter-by-chapter content, examples, and checklists, see [reference.md](reference.md).

## Options Thinking

Architecture sells options. The value of an option increases with uncertainty and time.

- **Defer irreversible decisions** -- design so that commitments can be made later, when more information is available. If a decision is easily reversible, make it now; if not, keep the option open.
- **Options have a cost** -- keeping an option available (e.g., supporting multiple backends) is not free. Evaluate the "strike price": what does it cost to maintain the option vs. committing now?
- **Present technical options as business choices** -- translate architectural alternatives into cost, time, and risk trade-offs that stakeholders can evaluate.
- **Evolutionary architecture** -- when the option space is unknown, use fitness functions (automated tests that verify architectural properties) instead of trying to predict the future.

**FP/TypeScript adaptation**: discriminated unions keep the type system open for new variants (additive extension). `Reader` defers configuration choices to the boundary. `Either` models reversible choices where both paths remain available until evaluation.

**When to apply**: `/plan` (Architecture lens), `/review-plan` (Architecture lens evaluation), code reviews (Architecture dimension), `/add-cursor-behavior` (Architectural alignment).

## Rate of Change

Architecture exists because things change. The first derivative of a software system is its build and deployment toolchain.

- **Design for change** -- reduce dependencies, friction, poor quality, and fear. These are the four brakes on delivery speed.
- **Confidence brings speed** -- tests, automation, and type safety let teams change code without fear. Test coverage is adequate when teams can delete 20 arbitrary lines and trust the suite to catch regressions.
- **"If it hurts, do it more often"** -- painful processes (deployments, upgrades, migrations) should be automated and run frequently, not avoided. Avoidance increases MTTR and risk.
- **Planned obsolescence** -- when selecting dependencies, evaluate: can data be exported? Can business logic be extracted? How deep is the lock-in? Include upgrade and migration cost in the total cost of ownership.
- **Multispeed architecture** -- different domains change at different rates. Separate fast-changing from slow-changing concerns so one doesn't constrain the other.

**FP/TypeScript adaptation**: additive programming and combinator design (from the **functional-typescript** skill) are the structural enablers of high rate of change. Type-driven development provides the compiler as an instant feedback loop -- the fastest "test suite" available.

**When to apply**: `/plan` (Architecture lens -- rate of change), code reviews (does the change make future changes easier or harder?), `/debug` (is the root cause a fear-of-change problem?).

## Systems Thinking

Structure is a means to achieve desired behaviour. Focus on behaviour, not just structure.

- **"Every system is perfect"** -- a system produces exactly the outcomes it was designed (or evolved) to produce. Understand what it was optimised for before proposing changes.
- **Feedback loops** -- negative feedback loops stabilise (thermostats, circuit breakers); positive feedback loops amplify (retry storms, cascading failures). Identify which loops are present and whether they're helping or hurting.
- **Bounded rationality** -- people act rationally within the information available to them. When behaviour seems irrational, look for information gaps (missing dashboards, unclear documentation, invisible consequences) rather than assuming incompetence.
- **Systems resist change** -- complex systems settle into local optima and actively resist perturbation. Small changes can make things worse before they improve. Anticipate resistance and plan for it.
- **Organised complexity** -- real systems are neither simple (predictable) nor chaotic (purely statistical). Structure and interaction both matter. Model the relationships, not just the components.

**FP/TypeScript adaptation**: bounded contexts and anti-corruption layers (from the **functional-typescript** skill) model system boundaries. Event-driven communication models feedback loops explicitly. Property-based testing verifies system invariants across many states.

**When to apply**: `/investigate-incident` (Systemic Factors), `/debug` (Five Whys -- look for systemic causes), incident response (Systems Thinking section), `/plan` (Systems effects question).

## Decision Quality

Judge decisions by process and available information, not by outcome alone.

- **Architecture = nontrivial decisions with rationale** -- if a decision has no meaningful downsides, it probably isn't architectural. Document the trade-offs, not just the choice.
- **Five Whys** -- ask "why" repeatedly to move from symptoms to root causes. Stop when the answer is actionable and structural, not when you reach "budget" or "time."
- **Question assumptions** -- unstated assumptions are the root of much evil, especially when the environment changes. Make them explicit and revisit them.
- **Fit for purpose** -- architecture is not "good" or "bad" in the abstract. It is appropriate or inappropriate for the actual constraints, context, and goals.
- **Avoid bias** -- watch for the law of small numbers (drawing conclusions from tiny samples), confirmation bias (seeking evidence that supports your hypothesis), and priming (being influenced by the first option presented).
- **Minimise irreversibility** -- the best decision is one you don't need to make. The second best is one you can change later.

**When to apply**: `/plan` (Fit for purpose, Options), `/review-plan` (Are assumptions questioned?), `/debug` (Five Whys), code reviews (does the decision have documented rationale?), `/estimate-work-item` (avoid small-sample bias in calibration).

## Communication

Architects bridge technical staff and leadership. Clear communication is a force multiplier.

- **Build ramps, not cliffs** -- establish a basic mental model in plain vocabulary before introducing technical terms. The audience should be able to reason about the decision at each step, not just the final conclusion.
- **Show the pirate ship** -- lead with purpose and value (the assembled product), not components and effort (the LEGO bricks). Focus on what the system does, not how much work it took.
- **Emphasis over completeness** -- diagrams and documents are models. Scope them to be big enough to be meaningful, small enough to be comprehensible. All models are wrong; some are useful.
- **Five-second test** -- show a slide or summary for five seconds. Can the reader describe the main point? If not, restructure.
- **Writing for busy people** -- use storytelling headings (not "Introduction" / "Conclusion"), the pyramid principle (hierarchical content, breadth-first disclosure), and brevity. Aim for 20--30% word reduction in editing.
- **Documents are software** -- apply version control, collaboration, single source of truth, iteration, and trunk-based development to documents. Work iteratively (rough whole story first), not incrementally (polished half-story).

**When to apply**: **writing-style** skill (Technical Communication section), **external-communications** skill, `/plan` (Present the plan step), `/review-pr` (overall summary).

## Organisational Awareness

Architects navigate organisations, not just codebases. Technical decisions exist within organisational systems.

- **Reverse-engineer beliefs** -- observe behaviour, infer the belief that would make it rational, then address the belief. You cannot change behaviour by telling people their beliefs are wrong; demonstrate a better alternative.
- **Autonomy = strategy + feedback + enablement** -- autonomy without any of the three is anarchy. Strategy provides direction; feedback shows consequences; enablement removes friction.
- **Use before reuse** -- build from a concrete use case first. Let common functionality "sift down" into shared layers from actual, proven use. Speculative reuse wastes effort and creates wrong abstractions.
- **Black markets indicate friction** -- when the official process is too slow, people route around it. The fix is a better "white market" (self-service, automation), not more control.
- **Minimise sync points** -- meetings are synchronisation points and throughput killers. Prefer async communication, searchable knowledge bases, and self-service interfaces.
- **Governance through inception** -- make the standard path clearly better than the alternatives. Innovate faster than the teams so guidance exists when need arises. Standards enforced by decree are brittle; standards enabled by infrastructure stick.

**FP/TypeScript adaptation**: "use before reuse" maps directly to the Rule of Three in the **refactoring** skill -- tolerate duplication twice, extract on the third occurrence. Start with concrete types, extract abstractions only when patterns emerge.

**When to apply**: `/add-cursor-behavior` (Architectural alignment -- governance through inception), `/plan` (Use before reuse), code reviews (is speculative abstraction being introduced?).

## Flow and Transformation

Speed and quality reinforce each other. Optimise flow, not just individual activities.

- **Flow efficiency over processing efficiency** -- workstations can be 100% utilised while customers wait. Measure end-to-end flow time, not just individual step duration.
- **Cost of delay** -- add cost of delay to development cost. For high-revenue features, delay cost can exceed development cost. Ship an MVP sooner rather than a complete feature later.
- **Look between activities** -- queues and wait time (approvals, environment provisioning, review cycles) often dominate elapsed time. Reducing wait time has a larger impact than optimising work.
- **Speed as a forcing function** -- faster cycles force automation, discipline, and quality. Manual processes that are tolerable at monthly cadence become painful at daily cadence, driving improvement.
- **Build-Measure-Learn** -- the main KPI is learning per unit of time or cost. Form teams with full responsibility from concept to operations. Keep internal staff inside the learning loop.
- **Speed and quality can coexist** -- automation can make faster delivery higher quality (fewer manual errors). The curve between speed and quality can be shifted, not just traversed.

**FP/TypeScript adaptation**: TDD's Red/Green/Refactor cycle is a tight Build-Measure-Learn loop at the code level. Property-based testing accelerates learning by exploring the input space automatically. Type-driven development catches design errors at compile time, eliminating an entire class of runtime queues.

**When to apply**: `/estimate-work-item` (Cost of Delay and Flow section), `/plan` (Cost of delay question), **continuous-improvement** skill (recurring friction, cost of inaction).
