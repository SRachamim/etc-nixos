# Review Plan

Given a plan authored by another person (pasted inline, linked in a document, or attached to a work item), evaluate it against the design lenses, commit conventions, and quality standards defined in the `/plan` command. Identify gaps, risks, and suggested improvements.

## Input

Accept **any** of the following:

1. **Inline plan** -- the user pastes or quotes the plan text directly in the conversation.
2. **Document or link** -- a plan document, tech design, or PR description the user points to.
3. **Ticket reference** -- an Azure DevOps work item ID or URL. Fetch it via MCP; if the work item description or a linked document contains the plan, use that as the plan under review. The ticket's acceptance criteria provide the authoritative goal against which the plan is evaluated.

The plan may use any format -- it need not follow the `/plan` output template. The review normalises it before evaluation (see step 1).

## Steps

### 0. Enter Plan mode

Switch to Cursor **Plan mode** (`SwitchMode` with `target_mode_id: "plan"`). The review is read-only analysis -- Plan mode keeps the focus on discussion rather than edits.

### 1. Parse the plan

Extract the plan's structure:

- Summary and goal
- Target state (if present)
- Design-lens commentary
- Implementation steps (commits and actions)
- Notes, risks, open questions

Most plans will not follow the `/plan` output template. Restate the steps in a normalised form (sequence of commits and actions with titles, descriptions, and key files) before evaluating.

### 2. Clarify the goal

Understand the intent behind the plan:

- **If ticket provided**: fetch the work item with full details and relations. Extract title, description, acceptance criteria, state, and linked items. These anchor the review -- the plan must address the ticket's requirements.
- **If no ticket**: infer the goal from the plan's own summary, context, or stated objectives. Ask the user to clarify if the goal is ambiguous.

Identify the **invariants** (what must remain true) and the **degrees of freedom** (what can vary).

### 3. Understand the codebase

Read the code that the plan targets:

- Locate the key files listed in the plan's implementation steps.
- Verify they exist and match the plan's assumptions about current structure.
- Identify anything the plan misses -- files that should be touched but aren't listed, or modules that would be affected by the proposed changes.

Spend enough time here to form a concrete mental model. Don't guess -- read the code.

### 4. Evaluate against design lenses

Apply the same lenses from the `/plan` command.

#### Refactoring lens

For each restructuring commit, check:

| Question | Red flag |
|----------|----------|
| Does it preserve behaviour? | Commit description implies new behaviour alongside restructuring |
| Is it a single, testable transformation? | Commit bundles multiple refactoring techniques |
| Does it name a recognised technique from the **refactoring** skill? | Technique column is blank or vague |
| Are prerequisite tests in place before the refactoring commits? | Test commits come after the refactorings they protect |

#### Flexibility lens

Review the plan's design-lens commentary:

- Are the chosen principles (2--3) genuinely the most relevant for this change?
- Does the plan honour them in practice, or only name-drop them?
- Are there principles the plan should have applied but didn't?

### 5. Evaluate commit structure

Apply the **commit-conventions** skill:

- Are commit messages well-formed (per workspace rules)?
- Is each commit independently valid (compiles, tests pass)?
- Is the ordering correct (tests first, refactorings before features)?
- Are documentation updates bundled with the commits that make them necessary?
- Is each commit appropriately scoped -- not too broad, not too narrow?

### 6. Check for gaps

Look for:

- **Missing steps** -- work the plan implies but doesn't list (e.g. a config change needed for a new module, a migration, updating exports).
- **Missing validation** -- commits with no validation strategy, or validation that doesn't match the project tooling.
- **Risks not acknowledged** -- breaking changes, performance implications, edge cases.
- **Ticket misalignment** -- if a ticket was provided, acceptance criteria that the plan doesn't address.

### 7. Present the review

Apply the **writing-style** skill to all review text.

Output the review in this format:

```
## Plan Review: <Plan Title>

### Verdict

<approve / request changes / comment-only>

### Summary

<1–3 sentences on the plan's overall quality and fitness for purpose>

### Findings

#### Blocking

<Issues that must be resolved before implementation. Each finding references the specific step # and explains what is wrong and how to fix it. Omit this section if there are none.>

#### Suggestions

<Recommended improvements that would strengthen the plan but are not strictly required. Omit if there are none.>

#### Observations

<Neutral notes -- things that are fine but worth highlighting, alternative approaches considered, praise for strong design choices. Omit if there are none.>

### Suggested Revised Steps

<If blocking issues exist, present the corrected step table using the /plan format. Otherwise omit this section.>
```

### 8. Iterate

Wait for questions, discussion, or amendments before considering the review complete. If the user revises the plan, re-evaluate only the changed portions.

### 9. Evolve

Follow the **continuous-improvement** skill.
