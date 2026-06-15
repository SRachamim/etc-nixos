# Building Microservices (2nd Ed.) -- Chapters 14-16 Extraction

Sam Newman, *Building Microservices: Designing Fine-Grained Systems* (O'Reilly, 2021). Coverage: **Part III: People** -- **Chapter 14** (User Interfaces), **Chapter 15** (Organizational Structures), **Chapter 16** (The Evolutionary Architect), and **Afterword**.

---

# Chapter 14: User Interfaces

## 1. Key Concepts and Principles

**Digital, not channel-specific**
- Move from treating web/mobile separately to thinking about **digital holistically**.
- The UI is where you **weave together microservice capabilities** into something customers understand.

**Organizational alignment**
- Traditional **layered architecture + dedicated frontend team** creates cross-team coordination for even simple UI changes.
- Preferred model: **stream-aligned teams** own UI **and** the server-side functionality behind it.
- **Conway's law** applies: UI organization shapes UI architecture.

**Technical UI decomposition patterns**
- **Monolithic frontend**: all UI in one deployable unit; calls backing microservices for data.
- **Micro frontends**: independently deliverable frontend applications composed into a greater whole.
- **Page-based decomposition**: different page groups served by different microservices; leverages native web navigation.
- **Widget-based decomposition**: independently changeable UI widgets on a screen; needs container/assembly layer.
- **Central aggregating gateway**: single server-side filter/aggregate point.
- **Backend for frontend (BFF)**: single-purpose aggregating backend per UI/experience.
- **GraphQL**: client-specified queries; can implement aggregation/BFF behavior dynamically.

**Constraints and device diversity**
- Desktop, mobile, accessibility, battery, bandwidth, interaction models all impose different constraints.
- UK Equality Act 2010 and W3C accessibility guidelines -- legal/ethical imperatives.

---

## 2. Best Practices and Recommendations

- Prefer **end-to-end stream-aligned teams** owning UI + backing services.
- **Embed specialists** or use **enabling teams** instead of dedicated frontend teams.
- Create **UI communities of practice** for cross-team skill sharing.
- Use **shared living style guides** and **shared UI components** for consistency without siloing.
- For **websites**, default to **page-based decomposition**.
- For **SPAs** (React/Angular/Vue), default to **micro frontends via widget decomposition**.
- Use **custom browser events** for inter-widget communication.
- Monitor **page weight** with automated alerts.
- Use **BFF per client type** as default ("One experience, one BFF" -- Stewart Gleadow).
- Shared BFF acceptable when **same team owns all clients** and experiences are very similar.
- Extract duplicated BFF logic into a **new microservice** when used in 3+ places (rule of three).
- **Strongly consider BFFs from the outset** for mobile and third-party integrations.
- Keep aggregation logic **out of** generic gateway products.
- Keep **business logic in domain microservices**, not smeared across intermediate layers.
- Before choosing SPA, ask: **would a multi-page website be simpler?**

---

## 3. Anti-Patterns and Warnings

- **Dedicated frontend team** when optimizing throughput -- creates handoff points.
- **Monolithic frontend shared by multiple teams** -- contention source.
- **Monolithic SPA** when a multi-page website would be simpler and better.
- **iFrames** for widget splicing -- sizing, communication, UX problems.
- **Central aggregating gateway** with multiple teams -- ownership ambiguity, bottleneck.
- **Vendor API gateway for aggregation logic** -- baked into third-party config, hard to extract.
- **Shared libraries for BFF client code** -- prime source of coupling.
- **Over-fetching** from microservices when mobile needs 10 fields but gets 100.

---

## 4. Decision Frameworks and Heuristics

| Decision | Guidance |
|----------|----------|
| Monolithic frontend | OK for **single team**; avoid with multiple teams |
| Micro frontends | Essential for stream-aligned teams with large frontend |
| Page vs widget decomposition | **Pages** for websites; **widgets** for SPAs |
| Central gateway vs BFF | Central gateway for **single team**; BFF for **multiple teams/clients** |
| How many BFFs? | **One per client type** (strict); shared only if same team |
| BFF duplication | Tolerate; extract to **new microservice** at ~3 uses |
| GraphQL vs BFF | GraphQL reduces server-side change for query variations |
| Consistency vs autonomy | Explicit organizational choice: polish (FT) vs speed (Amazon) |

---

## 5. Key Quotes

> "A stream-aligned team is a team aligned to a single, valuable stream of work... empowered to build and deliver customer or user value as quickly, safely, and independently as possible." -- Skelton & Pais

> "An architectural style where independently deliverable frontend applications are composed into a greater whole." -- Cam Jackson (micro frontends)

> "One experience, one BFF." -- Stewart Gleadow

> "Speed of delivery trumps a consistency of user experience, at least as far as AWS is concerned." -- Newman on Amazon

---

## 6. Actionable Guidance

- Ensure **one team** can change UI + backend without cross-team coordination.
- Decompose UIs using **pages** (web) or **widgets** (SPA).
- For mobile: implement **BFF per platform** with server-side aggregation/filtering.
- Put **rendering + caching** in BFF when using server-side templating.
- Automate **page weight budgets** for widget-heavy SPAs.
- Use **enabling teams** for design systems, not a delivery-blocking frontend silo.
- Keep domain logic in **domain microservices**; BFFs only aggregate/filter/route.

---

# Chapter 15: Organizational Structures

## 1. Key Concepts and Principles

**Loosely coupled organization <-> loosely coupled architecture**
- Microservices without organizational change **blunt ROI**.
- **Accelerate** checklist for loosely coupled teams:
  1. Make large-scale design changes **without external permission**?
  2. Make large-scale design changes **without depending on other teams**?
  3. Complete work **without coordinating** outside the team?
  4. **Deploy on demand** regardless of dependencies?
  5. Do most testing **on demand** without integrated test environments?
  6. Deploy during **business hours with negligible downtime**?

**Conway's Law**
- System design mirrors organizational communication structure.
- Loosely coupled orgs -> modular systems; tightly coupled orgs -> less modular systems.

**Team size**
- Optimal: **5-10 people**; productivity worst at >=9.
- Amazon **two-pizza teams** (~8-10): autonomous, own full lifecycle.
- **Brooks's Law**: adding people to late projects makes them later.

**Ownership models**
- **Strong ownership**: one team owns a microservice; controls code, standards, tech, deployment.
- **Full life-cycle ownership**: design -> build -> deploy -> operate -> decommission.
- **Collective ownership**: any team changes any service; requires high consistency, undermines independent deployability.
- Balance: collective ownership -> global consistency; strong ownership -> local optimization.

**Enabling teams**
- Support stream-aligned teams in cross-cutting areas.
- Architects as **enabling function**, not command-and-control.

**Communities of Practice (CoPs)**
- Cross-cutting peer learning forums.
- CoP != enabling team (CoP = learning; enabling team = action).

**Platform / Paved road**
- Self-service tools for stream-aligned teams.
- Optional paved road **incentivizes** platform team to solve real problems.
- **Govern via platform mandate** -> teams bypass it and do wrong things.
- Restrictions must be **clearly communicated with reasons**; platform makes compliance easy.

**Shared microservices**
- Default: **one microservice, one team**.
- **Internal open source**: core committers vet pull requests from untrusted committers.
- Many inbound pull requests = microservice shared by multiple teams -- consider ownership change or split.

---

## 2. Best Practices and Recommendations

- Align org structure with **stream-aligned, end-to-end teams** before/alongside microservices.
- Target **strong ownership**; one service, one team.
- Aim for **full life-cycle ownership** incrementally over years.
- Create **enabling teams** for specialists -- embed or consult, don't silo.
- Build **CoPs** for learning; pair with enabling teams for action.
- Invest in a **platform/paved road** that is **optional** and measured by adoption OKRs.
- For shared codebases: **internal open source** with core committers.
- **Change ownership** when one team dominates pull requests to a service.
- Consider **splitting microservices** to resolve delivery bottlenecks.
- Use **peer code review** (pairing preferred); avoid external approval gates.
- Make **product owners accountable for technical debt**.
- Geographical boundaries should inform **team and software boundaries**.

---

## 3. Anti-Patterns and Warnings

- Microservices adoption **without org change** -- pay cost, miss benefits.
- **Collective ownership at scale** -- high coordination, coupled architecture.
- **Copying Spotify/Amazon models** without understanding context.
- **Platform mandates** instead of paved road -- bypass and shadow IT.
- **External code review gates** -- lower delivery performance (Accelerate).
- **Ensemble programming** without accommodating neurodiversity.
- **Ignoring geographical/time-zone boundaries** when defining teams.

---

## 4. Decision Frameworks and Heuristics

| Situation | Heuristic |
|-----------|-----------|
| Team size | **5-10** people |
| Ownership at org level | **Strong** for microservices at scale |
| Ownership within team | **Collective** for collaboration |
| Shared microservice bottleneck | Wait -> add people -> split service -> change ownership -> internal OSS |
| Platform adoption | **Optional** + OKRs on adoption, not mandates |
| Geographical split | Same timezone for distributed team; geo boundaries = team/service boundaries |

---

## 5. Key Quotes

> "Organizations which design systems...are constrained to produce designs which are copies of the communication structures of these organizations." -- Melvin Conway

> "Adding manpower to a late software project makes it later." -- Fred Brooks

> "Microservices buy you options." -- James Lewis (collective ownership reduces options)

> "No matter how it looks at first, it's always a people problem." -- Gerry Weinberg

> "We didn't change our organisation because we wanted to use Kubernetes; we used Kubernetes because we wanted to change our organization." -- Paul Ingles

---

## 6. Actionable Guidance

- Use the **Accelerate 6-point checklist** to assess team autonomy.
- Define your team's **Team API**: interfaces, practices, backlog visibility, PR response norms.
- Build **self-service platform capabilities** before demanding team autonomy.
- Make paved-road adoption **easier than workarounds**; never mandate without explaining why.
- Review code via **pairing** or **immediate synchronous peer review**.
- When opening a new geo office, **actively decide which system parts move there**.

---

# Chapter 16: The Evolutionary Architect

## 1. Key Concepts and Principles

**Software architecture defined**
- Ralph Johnson: "Architecture is about the important stuff. Whatever that is."
- Architecture is a **social construct** -- shared understanding among expert developers.
- Martin Fowler: architecture = "things people perceive as hard to change."
- Architecture is also about **creating space for change**.

**Evolutionary architect vs ivory tower**
- Software changes continuously; architects must create a **framework for emergence**.
- **Town planner metaphor** (Erik Doernenburg): define **zones** (constraints), not specific buildings.
- **Seagram Building**: flexible interior within fixed structural core -- designed **while under construction**.

**System boundaries**
- Worry about **what happens between boxes**, be **liberal inside boxes**.
- Technology choice inside zones may vary; **between services** standardize integration.

**Habitability**
- Richard Gabriel: source code understandable and changeable comfortably by later programmers.
- Architects must **spend time with teams**, ideally **pairing**.

**Principles, practices, and goals framework**
- **Strategic goals**: where the business is going.
- **Principles**: <10 rules aligning work to goals.
- **Practices**: detailed, technology-specific, change more often.

**Required standard for "good citizen" microservices**
- **Monitoring**: standardized health/metrics emission; centralized logging.
- **Interfaces**: small number of integration styles (1-2 OK, 20 bad).
- **Architectural safety**: circuit breakers, proper timeouts, correct HTTP status codes.

**Governance**
- Governance group must be predominantly **people doing the work**.
- **Paved road** over policing.
- **Exemplars**: real running microservices that get things right.
- **Tailored microservice templates**: optional; mandated frameworks can destroy morale.
- **Technical debt**: conscious shortcuts vs vision drift; track via gentle guidance.
- **Exception handling**: log exceptions; enough exceptions -> change principle/practice.

**Core architect responsibilities**
1. **Vision** -- clearly communicated technical vision.
2. **Empathy** -- understand impact on customers and colleagues.
3. **Collaboration** -- engage peers to define/refine/execute vision.
4. **Adaptability** -- change vision as customers/org change.
5. **Autonomy** -- balance standardization vs team freedom.
6. **Governance** -- system fits vision; make doing the right thing easy.

---

## 2. Best Practices and Recommendations

- Think **town planner**, not building architect.
- Define **principles (<10)** and **practices** with clear mapping; revisit regularly.
- Be **embedded** with delivery teams routinely -- pairing > calls > reading code.
- Use **fitness functions** for measurable architectural characteristics.
- Form **architecture guilds** for collective governance at scale.
- Ensure **habitability**: collaborative tool/tech selection.
- Standardize **between services** (integration), allow variation **within team boundaries**.
- Define **good citizen microservice** attributes.
- Use **paved road + optional platform** for governance, not mandates.
- Provide **exemplar services** and **microservice templates** (optional adoption).
- Track **technical debt** consciously; involve product owners.
- Override team decisions **rarely** and only for systemic harm.

---

## 3. Anti-Patterns and Warnings

- **Ivory tower architect** -- detailed plans devoid of implementation understanding.
- **Technology selected by non-users** -- uninhabitable systems.
- **Mandated microservice frameworks** thrust on teams.
- **DRY across microservices via shared libraries** -- coupling.
- **Governance via platform mandate** -- bypass and noncompliance.
- **Too many principles** -- overlap and contradiction.
- **Fitness functions without human collaboration** -- incomplete picture.

---

## 4. Decision Frameworks and Heuristics

| Decision | Framework |
|----------|-----------|
| What architect focuses on | **Between zones/services**, not inside them |
| Technology diversity | Liberal inside team zone; **standardize integration between services** |
| When to override team | Only for systemic harm; default to group wisdom |
| Principles count | **<10**, memorable, non-overlapping |
| Governance mechanism | Informal (small) -> guild (large); always include doers |
| Compliance | **Paved road > policing**; exemplars + templates + platform |
| Exceptions to principles | Log -> pattern -> **update principle** |

---

## 5. Key Quotes

> "Architecture is about the important stuff. Whatever that is." -- Ralph Johnson

> "Architecture is what happens, not what is planned." -- Newman

> "Habitability is the characteristic of source code that enables programmers coming to the code later...to change it comfortably and confidently." -- Richard Gabriel

> "Be worried about what happens between the boxes, and be liberal in what happens inside." -- Newman

> "Rules are for the obedience of fools and the guidance of wise men." -- Douglas Bader

> "It needs to be a cohesive system made of many small parts with autonomous life cycles but all coming together." -- Ben Christensen

---

## 6. Actionable Guidance

- Document **<10 principles** mapped to practices.
- Run **fitness functions** in CI or production for critical NFRs.
- Schedule **regular embedded time** with each delivery team.
- Define and publish **"good citizen microservice" checklist**.
- Build **exemplar microservices** in production that teams can imitate.
- Create **optional** language-specific microservice templates.
- Use **architecture guild** with delivery team representatives.
- When a team wants an exception: **log it**; if recurring, **update the principle**.
- Never govern through **"you must use the platform"** -- govern through **"here's why, and here's the easy path."**

---

# Afterword: Bringing It All Together

## Consolidated Principles

**User Interfaces**
- Don't leave UI monolithic while decomposing backend.
- Use **stream-aligned teams** owning end-to-end slices including UI.
- **Micro frontends** for SPA decomposition; **BFFs** for mobile; **GraphQL** as alternative.

**Organization**
- Shift from **horizontally siloed teams** to **stream-aligned teams** supported by **enabling teams**.
- **Platform = paved road**: easy, optional, adoption-measured.
- Autonomy requires **self-service tools**.

**Architecture (Evolutionary)**
- Architecture is **not fixed** -- must continually change.
- **Collaborative technical vision** replaces ivory-tower architect.
- Architects/principal engineers: **support, connect, spot patterns, embed with teams**.

## Final Warnings and Wisdom

- Many adopt microservices because **everyone else is**, not because it fits.
- **Critical thinking** about fit > hype.
- You **won't get all decisions right** -- make each decision **small in scope** so mistakes are contained.
- Embrace **evolutionary architecture** -- series of changes over time, not big-bang rewrites.
- **"Change is inevitable. Embrace it."** -- the most important lesson of the book.
- Microservices = **journey, not destination**; go **incrementally**.

---

# Cross-Chapter Meta-Patterns (Chapters 14-16 + Afterword)

1. **Align org <-> architecture <-> UI** (Conway's law everywhere).
2. **Reduce coordination** -- the primary enemy of speed at scale.
3. **Stream-aligned ownership end-to-end** -- including UI, ops, and lifecycle.
4. **Enabling teams + optional paved road platform** -- support, don't block.
5. **Strong microservice ownership** -- one team, one service; internal OSS as fallback.
6. **Liberal inside boundaries, strict at interfaces** -- teams, services, and zones.
7. **Evolution over perfection** -- town planner, fitness functions, small decisions.
8. **Embed architects/leads with teams** -- architecture is a social construct.
9. **Make the right thing easy** -- paved road, exemplars, templates, BFFs.
10. **People first** -- autonomy requires capability, tooling, and cultural readiness.
