---
name: suggest-next-g
description: Present relevant follow-up workflow skills after completing any workflow skill. Provides a static relationship map and presentation format. Use after any workflow skill completes -- typically triggered via the continuous-improvement-g skill's terminal step.
---

# Suggest Next

After a workflow skill completes, present the user with relevant follow-up skills they might want to execute next.

## When to apply

Apply after completing any workflow skill execution, as part of the Evolve step. Skip if:

- The completed skill already presented its own follow-up suggestions (e.g. an "Offer follow-up" or "Suggested Next Steps" section).
- The workflow was trivial or failed before producing a meaningful result.
- The user explicitly indicated they are done.

## Relationship map

| Completed | Follow-ups |
|-----------|-----------|
| `/activate-work-item` | `/plan`, `/checkout-worktree` |
| `/answer-slack` | `/create-task`, `/investigate-incident` |
| `/block-work-item` | `/checkout-worktree`, `/defer-fix` |
| `/checkout-worktree` | `/plan`, `/debug`, `/reproduce-bug` |
| `/close-worktree` | `/prune-merged`, `/checkout-worktree` |
| `/commit-and-push` | `/submit-feature` |
| `/compare-approaches` | `/plan` |
| `/create-bug` | `/checkout-worktree`, `/reproduce-bug`, `/write-repro-steps` |
| `/create-task` | `/checkout-worktree`, `/plan` |
| `/debug` | `/commit-and-push`, `/create-bug`, `/defer-fix` |
| `/defer-fix` | `/create-bug`, `/create-task`, `/checkout-worktree` |
| `/design-microservice-system` | `/create-microservice`, `/plan` |
| `/estimate-work-item` | `/plan`, `/checkout-worktree` |
| `/extract-microservice` | `/submit-feature`, `/review-microservice-architecture` |
| `/investigate-incident` | `/create-bug`, `/submit-bypass-request`, `/debug` |
| `/list-closeable-worktrees` | `/close-worktree`, `/prune-merged` |
| `/plan` | `/commit-and-push`, `/submit-feature` |
| `/plan-from-prd-intake` | `/submit-feature`, `/commit-and-push` |
| `/prd-intake` | `/checkout-worktree`, `/plan-from-prd-intake`, `/create-task`, `/estimate-work-item`, `/plan` |
| `/prune-merged` | `/checkout-worktree` |
| `/reproduce-bug` | `/debug`, `/write-repro-steps` |
| `/retrospective` | `/plan`, `/create-task` |
| `/review-microservice-architecture` | `/design-microservice-system`, `/extract-microservice`, `/plan` |
| `/review-pr` | `/weigh-feedback`, `/trace-pr-comments` |
| `/review-pr-fixes` | `/submit-feature`, `/close-worktree` |
| `/submit-bypass-request` | `/triage-build`, `/commit-and-push` |
| `/submit-feature` | `/weigh-feedback`, `/review-pr-fixes`, `/close-worktree` |
| `/trace-pr-comments` | `/weigh-feedback`, `/review-pr-fixes` |
| `/triage` | `/plan`, `/checkout-worktree`, `/estimate-work-item` |
| `/triage-build` | `/debug`, `/submit-bypass-request`, `/create-bug` |
| `/weigh-feedback` | `/review-pr-fixes`, `/commit-and-push` |
| `/write-repro-steps` | `/reproduce-bug`, `/debug` |

## Presentation

Present at most 3 follow-ups. Filter by context -- omit suggestions that don't apply to the current state (e.g. don't suggest `/close-worktree` if the PR hasn't been merged, don't suggest `/submit-feature` if there are no commits to submit).

Format:

```
**Next steps you might consider:**
- `/skill-name` -- one-line reason why it's relevant now
- `/skill-name` -- one-line reason
```

Each reason must be grounded in the current context -- what just happened, what state the work item is in, or what the user's likely next action is. Do not use generic filler reasons.

## Constraints

- **Max 3 suggestions** -- present the most relevant, not all possible follow-ups.
- **Context-sensitive filtering** -- omit follow-ups that don't apply to the current session state.
- **No duplication** -- if the completed skill already suggested follow-ups, skip entirely.
- **Non-blocking** -- this is informational. The user may ignore all suggestions.
- **Static map is authoritative** -- only suggest skills that appear in the relationship map above. Do not invent follow-ups not listed here.
