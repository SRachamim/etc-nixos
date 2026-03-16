# Architect Thinking -- Reference

Detailed extraction from Gregor Hohpe's *The Software Architect Elevator* (O'Reilly, 2020). Organised by chapter with actionable checklists and decision frameworks. The parent [SKILL.md](SKILL.md) provides the condensed principles; this file is the deep-dive.

---

## Part I: Architects

### Chapter 1 -- The Architect Elevator

The value of an architect is measured by the number of organisational floors they span, not how high they go.

**Checklist**:
- Ride the elevator both ways -- connect the engine room (implementation) to the penthouse (strategy) and back.
- Translate technical decisions into business impact when going up; translate strategy into actionable technical direction when going down.
- Avoid becoming a "lift boy" who collects buzzwords from above without delivering substance below.
- In tall organisations, pair enterprise and technical architects to cover the full span.

### Chapter 2 -- Movie-Star Architects

Architects play multiple roles: gardener (prune, balance, evolve), guide (lead by influence, stay hands-on), and superglue (hold architecture, details, business, and people together).

**Anti-patterns**:
- The Matrix Architect (all-knowing master planner) -- information distorts as it passes through many floors.
- The Wizard of Oz (impressive projection, no substance) -- respect erodes when the curtain is pulled back.
- The Superhero (single point of failure) -- teams stop growing when they depend on one person.

### Chapter 3 -- Architects Live in the First Derivative

**Key insight**: Rate of change drives architecture. Systems that never change need little architecture.

**Checklist**:
- The build/deploy toolchain is the system's first derivative -- invest in it.
- Reduce: dependencies, friction, poor quality, fear.
- Test coverage heuristic: "Can the team delete 20 arbitrary lines and trust the tests to catch it?"
- Avoid two-speed architectures that sacrifice quality for short-term velocity.
- Separate fast-changing from slow-changing domains.

**Decision framework**:
- Optimising for local/short-term change can inhibit global/long-term change (the shantytown problem).

### Chapter 4 -- Enterprise Architect or Architect in the Enterprise?

**Key insight**: EA = business architecture + IT architecture + the glue between them.

**Checklist**:
- Map business operating model (standardisation vs. integration) to IT architecture.
- Ensure business and IT architecture are at comparable maturity.
- Make tools work for you, not the other way around -- avoid EA tools that become endless documentation without emphasis.

### Chapter 5 -- An Architect Stands on Three Legs

**Three legs**: Skill, Impact, Leadership.

| Leg | Meaning | Failure mode without it |
|-----|---------|------------------------|
| Skill | Applying knowledge to real problems | Impact without depth -- lucky coincidence |
| Impact | Benefit to the business | Skill without relevance -- ivory tower |
| Leadership | Advancing the practice (mentoring, sharing) | Impact without scaling -- single point of knowledge |

**Checklist**:
- Balance all three legs.
- Use teaching and writing to sharpen thinking.
- Scale horizontally by deploying knowledge to multiple teams.

### Chapter 6 -- Making Decisions

**Key insight**: Judge decisions by process and information available, not outcome.

**Decision frameworks**:
- Confidence intervals for A/B tests -- extend experiments until statistically significant.
- Micromort reasoning for small-probability, high-impact decisions.
- Decision trees with expected value for structured choices.
- Prospect theory: loss aversion biases decisions; account for it.

**Biases to watch**:
- Law of small numbers (tiny samples)
- Confirmation bias (seeking supporting evidence)
- Priming (anchoring to the first option)

**Best decision**: One you don't need to make. Second best: one you can change later.

### Chapter 7 -- Question Everything

**Key insight**: Chief architects know the right questions, not all answers.

**Techniques**:
- Five Whys -- stop when the answer is actionable and structural, not at "budget" or "time."
- Avoid "excuse-ism" in root-cause analysis.
- Request ADRs (Architecture Decision Records) in reviews.
- "You can avoid my review, but you cannot get a free pass." No rubber stamps.

---

## Part II: Architecture

### Chapter 8 -- Is This Architecture?

**Definition**: Architecture = nontrivial decisions with rationale.

**Tests**:
- Does the documentation contain meaningful decisions (not just "we separate frontend from backend")?
- Does the chosen option have downsides? If not, it probably isn't a real decision.
- Is the architecture fit for purpose, not just "best practice"?

### Chapter 9 -- Architecture Is Selling Options

**Key insight**: Architects sell options to defer decisions. Options gain value with uncertainty.

**Checklist**:
- Design for horizontal scaling as an option (e.g., stateless services).
- Offer options at different strike prices.
- Translate technical options into business choices.
- Use evolutionary architecture with fitness functions when options are unknown.
- Use real options: defer, abandon, expand, contract.

**Decision framework**:
- Option value = f(uncertainty, time). High uncertainty + long time horizon = high option value.
- Minimising strike price is rarely the most economical choice.
- Architects and project managers value options differently due to time horizons.

**FP/TypeScript mapping**:
- Discriminated unions: open for new variants (option to extend).
- `Reader`: defers configuration to the boundary (option to choose later).
- `Either`: models reversible choices (option to take either path).

### Chapter 10 -- Every System Is Perfect...

**Key insight**: Systems produce exactly the outcomes they were designed for. Understand the design before changing it.

**Checklist**:
- Identify feedback loops (negative = stabilising, positive = amplifying).
- Apply bounded rationality: people act rationally within their information. Look for information gaps.
- Avoid fixing symptoms -- address root causes.
- Understand the system before changing it; changes to complex systems can worsen behaviour.

**Decision framework**:
- Three domains: organised simplicity (predictable), unorganised complexity (statistical), organised complexity (systems -- structure and interaction both matter).

### Chapter 11 -- Code Fear Not!

**Key insight**: Configuration is often programming in a poorly designed language.

**Tests for visual/config tools**:
1. Can you introduce a typo and find it?
2. Can you change random elements and debug the result?

**Checklist**:
- Treat configuration as first-class: version control, validation, testing, deployment.
- "Simple things should be simple; complex things should be possible."
- Invest in the toolchain for rapid deployment instead of anticipating everything in configuration.

**FP/TypeScript mapping**:
- Validate configuration with `io-ts` codecs at the boundary.
- Use branded types for config values (`Port`, `ConnectionString`).
- Configuration with conditional logic should be promoted to proper TypeScript.

### Chapter 12 -- If You Never Kill Anything, You Will Live Among Zombies

**Key insight**: "Never touch a running system" reflects fear of change. Inability to change is a major liability.

**Checklist**:
- Balance MTBF (time between failures) and MTTR (time to recovery). Modern systems invest in both.
- "If it hurts, do it more often" -- frequent upgrades and migrations reduce risk per event.
- Include planned obsolescence in product selection: data export, logic extraction, vendor lock-in assessment.
- Don't separate "run" from "change" -- it guarantees legacy.
- Build a culture of change.

### Chapter 13 -- Never Send a Human to Do a Machine's Job

**Key insight**: Automate everything; make the rest self-service. Automation is about repeatability and resilience, not just efficiency.

**Checklist**:
- Ban infrastructure changes from GUIs; use version-controlled automation.
- Make automation idempotent.
- Make infrastructure immutable where possible.
- Use pull requests and merge for approvals.
- Tacit knowledge is a risk; encode it in scripts and tools.

### Chapter 14 -- If Software Eats the World, Better Use Version Control!

**Checklist**:
- Use version control for infrastructure.
- Add automated checks before commits (syntax, conflicts, compliance).
- "This server has been up for three years" = risk, not bragging rights.
- Re-create from scratch rather than undo (immutable infrastructure).

### Chapter 15 -- A4 Paper Doesn't Stifle Creativity

**Key insight**: Product standards restrict; interface standards enable.

**Decision framework**:
- Product standard: "use database X" (restricts choice).
- Interface standard: "all services expose OpenAPI specs" (enables interoperability).
- Platform standard: standardise lower layers; leave upper layers for innovation.

**Checklist**:
- Make standards real via tools and platforms (governance through infrastructure).
- Keep platforms up to date.
- Avoid "skipping stones" platforms (inconsistent, unreliable).

### Chapter 16 -- The IT World Is Flat

**Key insight**: Vendors distort your worldview. Develop your own map.

**Checklist**:
- Map by function and relationships, not product names.
- Describing architecture as "Microsoft SQL Server" is like describing a house as "Ytong."
- Ask vendors: "What base assumptions did you make?" and "What's the toughest problem you solved?"
- Place products on the map like Tetris: "best fit" over "best product."

### Chapter 17 -- Your Coffee Shop Doesn't Use Two-Phase Commit

**Key insight**: The real world is mostly asynchronous. Design distributed systems accordingly.

**Patterns**:
- Correlation identifiers for out-of-order delivery.
- Error strategies: write-off (loss is small), retry (intermittent errors), compensating action (undo).
- Backpressure when queues grow.
- Conversation patterns: short synchronous handoff + longer asynchronous processing.
- Optimise for the happy path; don't burden every transaction for rare failures.

**FP/TypeScript mapping**:
- `TaskEither` for async operations that can fail.
- Retry with `TaskEither` combinators; compensating actions as explicit undo pipelines.
- Backpressure modelled as queue-depth-aware `Task` scheduling.

---

## Part III: Communication

### Chapter 18 -- Explaining Stuff

**Ramp vs. cliff**: A ramp lets the audience draw conclusions step by step. A cliff dumps context-free jargon.

**Checklist**:
- First establish a basic mental model using plain vocabulary (no product names, no acronyms).
- Maintain a consistent level of detail -- don't jump between high-level and low-level.
- Use "teach back": have someone unfamiliar explain what you said to find gaps.

### Chapter 19 -- Show the Kids the Pirate Ship!

**Key insight**: Show the whole product (pirate ship), not just the components (LEGO bricks). Focus on purpose and value.

**Checklist**:
- Don't start with a table of contents; start with the pirate ship.
- Show the system in its natural habitat (context), not just internal design.
- Use Aristotle's three modes: logos (facts), ethos (trust), pathos (emotion). Most technical presentations are 90% logos -- add ethos and pathos.

### Chapter 20 -- Writing for Busy People

**Key insight**: The reader decides whether to turn the page based on what they've read so far.

**Checklist**:
- Use storytelling headings instead of "Introduction" / "Conclusion."
- Apply the Pyramid Principle: hierarchical content as a tree, breadth-first disclosure.
- Ensure parallelism in lists (same grammatical structure).
- Each paragraph: one topic, introduced at the beginning.
- Avoid forward references (topological sort on the topic graph).
- Aim for 20--30% word reduction in editing.
- Hold writer's workshops: attendees discuss the paper while the author listens silently.

### Chapter 21 -- Emphasis Over Completeness

**Key insight**: Diagrams are models. All models are wrong; some are useful.

**Checklist**:
- Five-second test: show a slide for five seconds; can the audience describe the main point?
- Pop quiz: blank the slide and have someone recap. It tests the presenter, not the audience.
- Avoid ant fonts; use sans-serif, decent size, good contrast. Zoom to 25% to check readability.
- Maximise signal-to-noise: align elements, use consistent form and shape.
- Use full-sentence titles for technical presentations.
- 20 slides should tell one story; use Outline View to check cohesion.

### Chapter 22 -- Diagram-Driven Design

**Key insight**: If you can't draw a good diagram (and skill isn't the issue), the system structure may be wrong.

**Checklist**:
- Establish a consistent visual vocabulary: box = X, solid line = Y, dashed line = Z.
- Limit levels of abstraction; draw one level at a time.
- Match precision to accuracy; avoid precise-looking slides when accuracy is low.
- Use hand-drawn sketches for discussion; blueprint style for agreed, critical detail.

### Chapter 23 -- Drawing the Line

**Key insight**: The lines are more interesting than the boxes. Integration and coupling live between components.

**Checklist**:
- Reject architecture diagrams without connecting lines.
- Depict relationships with explicit semantics (data flow, control flow, dependencies).
- Use at most two or three line semantics; keep each intuitive.
- Any visual variation should have meaning; eliminate meaningless variation.

### Chapter 24 -- Sketching Bank Robbers

**Key insight**: Act as a police sketch artist -- ask questions the witness can answer, draw, get feedback.

**Checklist**:
- Start with the system metaphor: what kind of "thing" is it?
- Drive toward discriminating, defining features, not generic ones.
- Treat "That's wrong!" as useful feedback -- it reveals mismatches.

### Chapter 25 -- Software Is Collaboration

**Key insight**: Apply software delivery practices to documents. Documents are a form of software.

**Checklist**:
- Version control for documents (Markdown in Git).
- Single source of truth.
- Trunk-based development for documents; keep branches short.
- Work iteratively (rough whole story first), not incrementally (polished half-story).
- Transparency: visible build status, migration progress, compliance metrics.
- Pair PowerPointing over long review cycles.

---

## Part IV: Organisations

### Chapter 26 -- Reverse-Engineering Organisations

**Key insight**: To change behaviour, change the system. For organisations, that means shared beliefs.

**Technique**:
1. Observe behaviour and unexpected decisions.
2. Infer which belief would make them rational.
3. Ask "why" to uncover drivers.
4. Acknowledge past usefulness, then explain what has changed.
5. Define new beliefs and demonstrate with real projects.

**Common IT beliefs to challenge**:
- Speed and quality are opposed ("quick and dirty").
- Quality can be added later.
- All problems can be solved with more people or money.
- Following a proven process leads to proven good results.
- Late changes are expensive or impossible.
- Agility opposes discipline.
- The unexpected is undesired.

### Chapter 27 -- Control Is an Illusion

**Key insight**: Three gaps between intention and reality: knowledge (what you know vs. want to know), alignment (plans vs. actions), effects (expected vs. actual). Accept them; don't try to eliminate them.

**Framework -- Autonomy vs. Anarchy**:

| Enabler | Present | Absent |
|---------|---------|--------|
| Strategy | Teams know where to go | Random motion |
| Feedback | Teams see consequences | Flying blind |
| Enablement | Teams can act on decisions | Frustrated autonomy |

All three required. Missing any one produces dysfunction, not autonomy.

**Checklist**:
- Prefer hard data and live dashboards over status reports.
- Use Auftragstaktik (mission command): communicate intent, not detailed orders.
- Autonomous teams need stronger management and leadership, not less.

### Chapter 28 -- They Don't Build 'Em Quite Like That Anymore

**Key insight**: Build from the top down. Use before reuse.

**Checklist**:
- Start with a specific application that delivers customer value.
- Let common functionality sift down into lower layers from actual use.
- Use transparency (shared repo, service registry) to spot duplication early.
- Avoid inverse pyramids (more managers than workers).
- Empower communities of practice with clear goals.

**FP/TypeScript mapping**: Rule of Three in the **refactoring** skill. Start with concrete types; extract abstractions only when patterns emerge from real use.

### Chapter 29 -- Black Markets Are Not Efficient

**Key insight**: Black markets arise when official processes hinder progress. The fix is a better white market.

**Detection**: "How long to get a server?" -- if the answer depends on who's asking, there's a black market.

**Checklist**:
- Use self-service to give everyone equal access.
- Force process designers to use their own processes.
- Measure the cost of black markets.

### Chapter 30 -- Scaling an Organisation

**Key insight**: Apply system scaling concepts -- minimise sync points, use async, build a cache.

**Checklist**:
- Minimise meetings; prefer async communication.
- Build a cache: answer questions in searchable forums.
- Set domain boundaries well (Bounded Contexts) to reduce cross-boundary communication.
- Automate processes; provide self-service interfaces.
- Reserve face-to-face time for brainstorming, negotiation, and bonding.

### Chapter 31 -- Slow Chaos Is Not Order

**Key insight**: Agile means hitting the right target through frequent recalibration, not just moving fast.

**Test**: Request precise documentation of "proven processes." If no one can produce it, the process is slow chaos, not order.

**Checklist**:
- Speed requires discipline; lack of discipline at high speed leads to disaster.
- Speed is a forcing function for automation and discipline.
- Avoid "frozen zones" that block deployment when it matters most.

### Chapter 32 -- Governance Through Inception

**Key insight**: Governance by decree is brittle. Governance through superior infrastructure sticks.

**Decision framework**:
- Interface vs. product standards: does the standard enable interchangeability and network effects?
- Connecting vs. endpoint standards: version control and monitoring (connecting) vs. laptops and IDEs (endpoints).
- Is central IT ahead so it can set direction before need is widespread (inception)?

**Checklist**:
- Standardise interfaces, not products.
- Use governance through infrastructure: make the standard path clearly better.
- Force decision makers to use the tools they standardise.
- Avoid vaporware standards that exist mainly in slide decks.

---

## Part V: Transformation

### Chapter 33 -- No Pain, No Change!

**Key insight**: Organisations rarely change without pain. Practices do not work outside their context.

**10-stage transformation model**:
- Critical transitions: awareness (1 to 2), overcoming disillusionment (5 to 6), wanting instead of forcing (7 to 8).
- Probability of success = product of transition probabilities (e.g., 70% per step across 10 steps = ~4%).

**Checklist**:
- Change the system (people and organisation), not just surface behaviour.
- Build internal skill to use products as far "right" on the innovation spectrum as possible.
- Treat consultants/vendors as co-opetition: useful to start, but not to finish.

### Chapter 34 -- Leading Change

**Key insight**: Demonstrate positive results from a different way of working in a small team.

**Checklist**:
- Set visible, measurable targets aligned with strategy.
- Avoid goals that incentivise hiding problems.
- Recruit in waves: early adopters, pragmatists, sceptics.
- For skunkworks: real product, streamlined (not bypassed) processes, acceptance by the mainland.
- Secure management support for setbacks.

### Chapter 35 -- Economies of Speed

**Key insight**: In times of rapid change, economies of speed beat economies of scale.

**Decision framework**:
- Flow efficiency (end-to-end flow) matters more than processing efficiency (individual steps).
- Cost of delay: add it to development cost. For high-revenue products, delay cost can exceed development cost.
- Predictability has a cost; budgets that favour predictability over speed may destroy value.
- Duplication can be cheaper than coordination.

### Chapter 36 -- The Infinite Loop

**Key insight**: The main KPI is learning per dollar or time spent (revolutions through Build-Measure-Learn).

**Checklist**:
- Form teams with full responsibility from concept to operations ("you build it, you run it").
- Keep teams small (two-pizza teams).
- Internal staff must be inside the learning loop; externals coach, not replace.
- Transform HR and recruiting first.

### Chapter 37 -- You Can't Fake IT

**Key insight**: You can't be digital on the outside without transforming internal IT.

**Stack fallacy**: Moving up the stack (infra to platform to application) is hard. Successful infra players often fail at applications.

**Checklist**:
- Ensure IT can deliver digital capabilities before promising them.
- Cocreate services with customers instead of pushing via governance.
- Dogfooding: use employees as early customers.
- Foster a maker mindset: build solutions, not only follow rule books.

### Chapter 38 -- Money Can't Buy Love

**Key insight**: Transformation cannot be bought as a SKU. Culture change must come from within.

**PARC framework**: People, Architecture (structures), Routines (processes), Culture. Culture is the hardest to change.

**Checklist**:
- Drive transformation from inside the organisation.
- Avoid hollowing out IT; keep core technology skills in-house.
- Use externals to coach, not to own delivery.
- Be aware of the Innovator's Dilemma: IRR-based budgeting favours cash cows over early-stage innovations.

### Chapter 39 -- Who Likes Standing in Line?

**Key insight**: To speed up, look between activities (queues and wait time), not only at activities.

**Decision framework**:
- Little's Law: T = N / lambda (total time = items in system / processing rate).
- Utilisation from 60% to 80% can almost triple average queue length.
- Single queue, multiple servers is often better than multiple queues.

**Checklist**:
- Measure and make queues visible.
- Reduce wait time instead of only optimising work.
- Avoid driving utilisation toward 100%; leave slack for responsiveness.
- Identify queues in: calendars, steering meetings, email, releases, workflows.

### Chapter 40 -- Thinking in Four Dimensions

**Key insight**: Quality and speed are two dimensions, not a single line. The curve between them can be shifted.

**Checklist**:
- Ask "what would shift the curve?" (automation, resilience, end-to-end optimisation).
- Faster delivery can improve quality when manual work is a major error source.
- Traditional "quality" (conformance to spec) is a proxy; observe customer behaviour instead.
- Turn problems into software problems so they can be automated.

---

## Part VI: Epilogue

### Chapter 41 -- All I Have to Offer Is the Truth

**Key insight**: Transformation is about survival, not convenience. Adopting digital practices requires understanding their interdependencies.

**Checklist**:
- Understand interdependencies before adopting practices from digital leaders (e.g., monorepo needs world-class build systems).
- Start communication gently and escalate when there is persistent inaction.
- Expect transformation to be demanding: new tech, higher complexity, faster pace.
- Seek peer support and share experiences.
