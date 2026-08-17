---
name: follow-up-map-g
description: Presents relevant follow-up workflow skills after completing any workflow skill. Provides a static relationship map and presentation format. Use after any workflow skill completes -- typically triggered via the capture-improvement-g skill's terminal step.
---

# Follow-Up Map

After a workflow skill completes, present the user with relevant follow-up skills they might want to execute next.

## When to apply

Apply after completing any workflow skill execution, as part of the Evolve step. Skip if:

- The completed skill already presented its own follow-up suggestions (e.g. an "Offer follow-up" or "Suggested Next Steps" section).
- The workflow was trivial or failed before producing a meaningful result.
- The user explicitly indicated they are done.

## Relationship map

| Completed | Follow-ups |
|-----------|-----------|
| `/activate-work-item-g` | `/plan-g`, `/checkout-worktree-g` |
| `/answer-slack-g` | `/create-task-g`, `/investigate-incident-g` |
| `/audit-dependencies-g` | `/submit-feature-g`, `/commit-and-push-g` |
| `/capture-improvement-g` | `/review-retrospective-g` |
| `/block-work-item-g` | `/checkout-worktree-g`, `/defer-fix-g` |
| `/checkout-worktree-g` | `/plan-g`, `/debug-g`, `/reproduce-bug-g` |
| `/close-worktree-g` | `/verify-deployment-g`, `/prune-merged-g`, `/checkout-worktree-g` |
| `/commit-and-push-g` | `/submit-feature-g` |
| `/compare-approaches-g` | `/plan-g` |
| `/create-bug-g` | `/checkout-worktree-g`, `/reproduce-bug-g`, `/write-repro-steps-g` |
| `/create-task-g` | `/checkout-worktree-g`, `/plan-g` |
| `/debug-g` | `/commit-and-push-g`, `/create-bug-g`, `/defer-fix-g` |
| `/defer-fix-g` | `/create-bug-g`, `/create-task-g`, `/checkout-worktree-g` |
| `/deliver-feature-g` | `/close-worktree-g`, `/verify-deployment-g` |
| `/design-microservice-system-g` | `/create-microservice-g`, `/plan-g` |
| `/estimate-work-item-g` | `/plan-g`, `/checkout-worktree-g` |
| `/extract-microservice-g` | `/submit-feature-g`, `/review-microservice-architecture-g` |
| `/fix-bug-g` | `/close-worktree-g`, `/verify-deployment-g` |
| `/fix-build-g` | `/commit-and-push-g`, `/submit-feature-g` |
| `/investigate-incident-g` | `/create-bug-g`, `/submit-bypass-request-g`, `/debug-g` |
| `/list-closeable-worktrees-g` | `/close-worktree-g`, `/prune-merged-g` |
| `/plan-g` | `/commit-and-push-g`, `/submit-feature-g` |
| `/prepare-release-g` | `/update-wiki-g`, `/commit-and-push-g` |
| `/plan-from-prd-intake-g` | `/submit-feature-g`, `/commit-and-push-g` |
| `/analyze-prd-g` | `/checkout-worktree-g`, `/plan-from-prd-intake-g`, `/create-task-g`, `/estimate-work-item-g`, `/plan-g` |
| `/prune-merged-g` | `/checkout-worktree-g` |
| `/report-bug-g` | `/fix-bug-g`, `/checkout-worktree-g` |
| `/reproduce-bug-g` | `/debug-g`, `/write-repro-steps-g` |
| `/review-retrospective-g` | `/plan-g`, `/create-task-g` |
| `/review-microservice-architecture-g` | `/design-microservice-system-g`, `/extract-microservice-g`, `/plan-g` |
| `/review-pr-g` | `/weigh-feedback-g`, `/trace-pr-comments-g` |
| `/review-pr-fixes-g` | `/submit-feature-g`, `/close-worktree-g` |
| `/submit-bypass-request-g` | `/triage-build-g`, `/commit-and-push-g` |
| `/submit-feature-g` | `/weigh-feedback-g`, `/review-pr-fixes-g`, `/close-worktree-g` |
| `/sweep-backlog-g` | `/checkout-worktree-g`, `/create-task-g`, `/estimate-work-item-g` |
| `/trace-pr-comments-g` | `/weigh-feedback-g`, `/review-pr-fixes-g` |
| `/triage-work-item-g` | `/plan-g`, `/checkout-worktree-g`, `/estimate-work-item-g` |
| `/triage-build-g` | `/debug-g`, `/submit-bypass-request-g`, `/create-bug-g` |
| `/update-wiki-g` | `/prepare-release-g` |
| `/verify-deployment-g` | `/close-worktree-g`, `/create-bug-g` |
| `/weigh-feedback-g` | `/review-pr-fixes-g`, `/commit-and-push-g` |
| `/write-repro-steps-g` | `/reproduce-bug-g`, `/debug-g` |

## Presentation

Present at most 3 follow-ups. Filter by context -- omit suggestions that don't apply to the current state (e.g. don't suggest `/close-worktree-g` if the PR hasn't been merged, don't suggest `/submit-feature-g` if there are no commits to submit).

Format:

```
**Next steps you might consider:**
- `/skill-name-g` -- one-line reason why it's relevant now
- `/skill-name-g` -- one-line reason
```

Each reason must be grounded in the current context -- what just happened, what state the work item is in, or what the user's likely next action is. Do not use generic filler reasons.

## Constraints

- **Max 3 suggestions** -- present the most relevant, not all possible follow-ups.
- **Context-sensitive filtering** -- omit follow-ups that don't apply to the current session state.
- **No duplication** -- if the completed skill already suggested follow-ups, skip entirely.
- **Non-blocking** -- this is informational. The user may ignore all suggestions.
- **Static map is authoritative** -- only suggest skills that appear in the relationship map above. Do not invent follow-ups not listed here.
