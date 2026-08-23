---
name: requirements-classification-g
description: "Distinguishes user-facing behavioral requirements (FR/NFR) from technical implementation decisions using the IEEE 830 black-box principle. Loaded whenever the agent writes, extracts, or reviews requirements -- during PRD analysis, planning, triage, or work item creation."
---

# Requirements Classification

A requirement specifies **externally visible** behavior or quality attributes of a system. A design decision specifies **how** that behavior is achieved internally. Requirements constrain the solution space; they do not dictate a specific solution.

> "A requirement specifies an externally visible function or attribute of a system. A design describes a particular subcomponent of a system and/or its interfaces with other subcomponents." -- IEEE 830-1998

## The Black-Box Test

For any candidate requirement, ask:

> Could a user, tester, or product manager verify this statement without knowing the internal architecture?

- **Yes** -- it is a requirement (FR or NFR).
- **No** -- it is a design decision. Move it to the tech design, commit plan, or decision log.

A properly written requirement limits the range of valid designs but does not specify any particular design.

## Classification Guide

| Category | What it captures | Verification perspective |
|----------|-----------------|--------------------------|
| **Functional requirement (FR)** | Observable system behavior -- actions, responses, state visible to the user | Verifiable from the outside by exercising the system |
| **Non-functional requirement (NFR)** | Quality attributes -- performance, security, availability, accessibility | Measurable externally via metrics, audits, or load tests |
| **Constraint (C)** | Externally imposed restrictions on the solution space -- regulatory, organizational, or contractual | Verifiable by inspecting the solution against the constraint source |
| **Design decision** | Internal mechanism, technology choice, data structure, or architecture pattern | Verifiable only by inspecting internals |

## Examples

| Statement | Classification | Reasoning |
|-----------|---------------|-----------|
| "The user should see the same dataset on the same tab after refresh" | FR | Externally observable behavior, verifiable by a user |
| "Save the dataset in sessionStorage" | Design decision | Specifies internal storage mechanism; the user never observes sessionStorage |
| "Page load must complete in under 2 seconds" | NFR (performance) | Externally measurable quality attribute |
| "Use Redis for caching" | Design decision | Internal technology choice |
| "System must support 500 concurrent users" | NFR (scalability) | Externally measurable capacity attribute |
| "Implement horizontal pod autoscaling" | Design decision | Internal mechanism to achieve scalability |
| "User data must not be accessible to unauthorized users" | NFR (security) | Observable policy verifiable from outside |
| "Encrypt data with AES-256 at rest" | Constraint or design decision | Restricts solution space but specifies a mechanism -- classify as C-N if imposed by policy, otherwise treat as design |
| "The system must be WCAG 2.1 AA compliant" | NFR (accessibility) | Externally auditable quality standard |
| "Use React for the frontend" | Constraint or design decision | Only a constraint if imposed by org policy; otherwise a design choice |

## Where Design Decisions Belong

When a statement fails the black-box test, do not discard it -- relocate it:

| Document section | What belongs there |
|------------------|--------------------|
| FR / NFR tables | Only black-box-verifiable statements |
| Constraints (C-N) | Externally imposed restrictions on the solution (org policy, regulatory, contractual) |
| Tech design / draft | Technology choices, architecture patterns, data structures |
| Commit plan / execution plan | Implementation approach, sequencing, refactoring strategy |
| Decision log / ADR | Significant design decisions with rationale and alternatives |

## Common Misclassifications

| Misclassification | Why it's wrong | Correct treatment |
|-------------------|---------------|-------------------|
| Naming a storage mechanism as an FR | The user doesn't care *where* data lives, only that it persists | Extract the observable behavior ("data persists across refresh") as the FR; the storage choice is a design decision |
| Specifying an API shape as an FR | API structure is internal contract between components | The FR is the user-visible capability the API enables |
| Stating a framework/library as an NFR | Framework choice is a means to achieve quality, not the quality itself | State the quality attribute ("must render in < 100ms") as NFR; framework is design |
| Calling an architecture pattern a requirement | Patterns are solutions, not problems | State the problem the pattern solves as the requirement |

## Applying This Skill

When extracting or reviewing requirements:

1. Write each candidate statement.
2. Apply the black-box test.
3. If it fails, ask: "What user-visible behavior or quality does this address?" That answer is the real requirement.
4. Move the original statement to the appropriate design section, linked to the requirement it addresses.

This ensures traceability -- every design decision maps to a requirement it satisfies, and every requirement is stated in terms a product manager can validate.

## Acceptance Criteria Boundaries

The black-box test applies equally to acceptance criteria (AC). AC defines *what* must be true for a story to be accepted -- observable outcomes, not internal mechanics.

### AC vs. Implementation Detail

Same test as FR: "Could a user or tester verify this without knowing internals?" Implementation steps disguised as AC are the most common anti-pattern.

### AC vs. Test Case

AC defines the **outcome** (what must be true). A test case defines the **procedure** (how to verify it -- specific inputs, execution steps, expected outputs). One AC spawns multiple test cases. Writing verification procedures as AC over-constrains QA and conflates the contract with the proof.

### AC vs. FR

FR is broad, project-level ("the system must..."). AC is narrow, story-level ("this story is done when..."). AC is not a reformulation of the FR -- it is a verifiable condition proving the FR is satisfied for this unit of work.

### Examples

| Statement | Classification | Reasoning |
|-----------|---------------|-----------|
| "Given the user is on the datasets tab, when they refresh the page, then the same dataset is still displayed" | Valid AC | Observable outcome in Given/When/Then format |
| "The React component re-renders when state changes" | Implementation detail | Internal framework behavior; user never observes re-renders |
| "User service calls authentication API with JWT token" | Implementation detail | Specifies internal integration mechanism |
| "Click the login button, enter credentials, verify the database row exists" | Test case | Describes verification procedure, not acceptance condition |
| "Given an invalid password, when the user submits, then an error message is displayed within 2 seconds" | Valid AC | Observable behavior with measurable outcome |
| "Database transaction is committed after validation" | Implementation detail | Internal persistence mechanism |

### AC Checklist

A well-formed AC is:

- **Behavioral** -- describes what, not how
- **Observable** -- verifiable from outside the system
- **Testable** -- has a clear pass/fail result
- **Independent** -- one condition per criterion
- **Story-scoped** -- specific to this unit of work, not a restatement of the project-level FR

## Out of Scope Boundaries

Out-of-scope (OS) items require precision. Vague exclusions invite scope creep; overly broad exclusions hide unowned risks.

### OS Sub-Categories

Every OS item should be classified into one of:

| Sub-category | Meaning | Example |
|--------------|---------|---------|
| **Adjacent** | Related feature that exists nearby but isn't part of this work | "Notification preferences UI exists but is not being modified" |
| **Deferred** | Planned for a future phase -- include a timeframe or trigger | "SSO integration is planned for Q4 pending identity platform selection" |
| **Rejected** | Considered and explicitly excluded with rationale | "Real-time sync was evaluated and rejected due to infrastructure cost" |
| **Someone else's** | Owned by another team or system | "Payment processing is owned by the Billing team" |

### Required Attributes

Every OS item needs:

1. **Category** -- which sub-category above
2. **Reason** -- why it is excluded (not just "out of scope")
3. **Revisit trigger** -- what would reopen the decision (or explicit "permanently excluded")

"Advanced permissions are out of scope" is negotiable. "Custom roles beyond Owner, Admin, and Member are out of scope -- deferred until RBAC infrastructure lands in Q3" holds.

### OS vs. Constraint

If the exclusion *restricts how we build what's in scope*, it is a constraint (C-N), not OS. Test: does it limit the solution space for in-scope work?

| Statement | Classification | Reasoning |
|-----------|---------------|-----------|
| "Must not modify the billing service" | Constraint (C-N) | Restricts what the in-scope implementation may touch |
| "Billing enhancements are not part of this work" | OS (someone else's) | Declares ownership boundary without restricting the solution |

### OS vs. Assumption

If the exclusion depends on an unverified belief, record it as *both* OS and an assumption (A-N). The assumption carries risk -- if it proves false, the OS item may need to become in-scope.

| Statement | Classification | Reasoning |
|-----------|---------------|-----------|
| "The billing team handles payment retry logic" | OS + Assumption | Excluded because we believe another team owns it -- but if they don't, the work is unowned |
| "Mobile apps will not be supported" | OS (rejected) | Explicit product decision, not an assumption |

### Anti-pattern: Vague OS

| Vague (bad) | Precise (good) |
|-------------|----------------|
| "Advanced features are out of scope" | "Custom roles beyond Owner/Admin/Member are out of scope (deferred to Q3 RBAC work)" |
| "Performance optimization is out of scope" | "Sub-100ms response time is not a target for this phase; current P95 of 400ms is acceptable" |
| "Edge cases are out of scope" | "Concurrent editing by multiple users on the same dataset is out of scope (deferred pending conflict resolution design)" |
