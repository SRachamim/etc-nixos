---
name: refine-draft-pr-g
description: Reviews the author's own draft pull request in a clean-context subagent with review-pr-g, weighs each finding with feedback-evaluation-g, applies the approved fixes as fixup commits, and pushes. Posts nothing to the PR or Slack. Use after /draft-feature-g, before /submit-feature-g. When NOT to use -- for feedback that human reviewers posted on PR threads, use weigh-feedback-g.
disable-model-invocation: true
---

# Refine Draft PR

Given a draft PR (or inferred from the current branch), get a clean-context review of it, judge each finding independently, apply the fixes you approve, and fold them into the draft's commits. The PR, its threads and Slack are left untouched. Nobody else has seen the draft yet, so the history is rewritten rather than appended to.

The review runs in a separate context so it does not share the assumptions the author made while writing the code. Each finding is still a second opinion, not a command: the **feedback-evaluation-g** framework decides which ones to act on.

## Steps

### 0. Mode gate

Require **Plan** mode following the **mode-gate-g** skill. Steps 1--4 are read-only: no code changes until the verdict table is approved. Switch to **Agent** mode for steps 5--6.

### 1. Resolve the PR

Determine the PR using one of the following, in priority order:

1. **Explicit argument** -- the user provided a PR ID directly.
2. **Branch name** -- find the active PR whose source branch matches the current branch.

If neither yields a PR, ask the user and stop.

The review reads `origin/<source>`, so the local branch must match it. Run `git status --porcelain` and `git fetch origin`, then compare `git rev-parse HEAD` with `git rev-parse origin/<source>`. If there are uncommitted changes or the two differ, tell the user to run `/commit-and-push-g` first and stop.

### 2. Review in a clean-context subagent

When the agent can spawn subagents, spawn a general-purpose subagent at the Standard tier (see **context-engineering-g**) with this brief:

- Follow the **review-pr-g** skill for PR `<id>` in repository `<repo>`. Where the skill is not model-invocable, read it from the agent's skills directory (Claude Code: `~/.claude/skills/review-pr-g/SKILL.md`).
- Post nothing: no PR threads, votes, Slack reactions or messages. Do not continue to `/triage-finding-g`, `/draft-review-g` or `/submit-review-g`.
- Do not run `git checkout` or `git switch` in the workspace. Read branch files with `git show origin/<source>:<path>`.
- If you cannot spawn your own reviewer subagents, evaluate inline as **review-pr-g** step 5 allows.
- Return the step 6 Raw Review output verbatim, with its `F<n>` findings.

When subagents are not available, follow the **review-pr-g** skill inline, with the same no-posting constraint. The diff then stays in the main context.

If the review is `clean`, report that, skip to step 7, and do not commit anything.

### 3. Weigh the findings

Apply the **feedback-evaluation-g** skill to each `F<n>` finding, treating the raw review as reviewer feedback. Find the governing standard for each finding, read it, and give the finding one of the five verdicts. Check every finding against the code on the branch. A finding that misreads the code is **Disagree**, whatever its severity.

### 4. Present the verdict table

| Finding | Verdict | Governing standard | Proposed action |
|---------|---------|-------------------|-----------------|
| `F<n>` [Severity] file path + line, first sentence (truncated) | One of the five verdicts | Skill/rule name + relevant section (or "general principles") | Code change summary, the reason for not acting, or the open question |

Nothing is posted, so there is no reply-text column. The user may:

- Approve all
- Approve selectively
- Override specific verdicts
- Request re-evaluation of specific findings

Do not proceed until the user approves.

### 5. Apply the fixes

In **Agent** mode, make the code changes for the approved **Agree-fix** and **Partial** verdicts. Apply the **self-review-g** skill to the resulting diff and run the repository's checks (type check, lint, tests) for the touched files.

Do not act on **Agree-defer** and **Need-context** findings. List them for the user in step 7.

### 6. Commit and push

Follow the **commit-and-push-g** skill in **fixup** mode. Each fix folds into the draft commit it belongs to. That skill asks before pushing with `--force-with-lease`.

### 7. Confirm

Print:

- PR link, still a draft
- Counts of fixed, deferred, rejected and open findings, with the deferred and open ones listed
- Commit SHAs after the autosquash
- The next step: `/submit-feature-g` when the draft is ready for review, or `/refine-draft-pr-g` again for another pass

### 8. Evolve

Follow the **capture-improvement-g** skill.
