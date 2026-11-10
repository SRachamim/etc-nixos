---
name: refine-draft-pr-g
description: Reviews the author's own draft pull request in a clean-context subagent with review-pr-g, merges the author's queued /triage-finding-g notes, weighs each finding with feedback-evaluation-g, commits approved agent improvements before the feature commits, applies the approved fixes as fixup commits, and pushes. Posts nothing to the PR or Slack. Use after /draft-feature-g, before /submit-feature-g. When NOT to use -- for feedback that human reviewers posted on PR threads, use weigh-feedback-g.
disable-model-invocation: true
---

# Refine Draft PR

Given a draft PR (or inferred from the current branch), get a clean-context review of it, judge each finding independently, apply the fixes you approve, and fold them into the draft's commits. The PR, its threads and Slack are left untouched. Nobody else has seen the draft yet, so the history is rewritten rather than appended to.

The review runs in a separate context so it does not share the assumptions the author made while writing the code. Each finding is still a second opinion, not a command: the **feedback-evaluation-g** framework decides which ones to act on.

## Steps

### 0. Mode gate

Require **Plan** mode following the **mode-gate-g** skill. Steps 1--4 are read-only: no code changes until the verdict tables are approved. Switch to **Agent** mode for steps 5--7.

### 1. Resolve the PR

Determine the PR using one of the following, in priority order:

1. **Explicit argument** -- the user provided a PR ID directly.
2. **Branch name** -- find the active PR whose source branch matches the current branch.

If neither yields a PR, ask the user and stop.

The review reads `origin/<source>`, so the local branch must match it. Run `git status --porcelain` and `git fetch origin`, then compare `git rev-parse HEAD` with `git rev-parse origin/<source>`. If there are uncommitted changes or the two differ, tell the user to run `/commit-and-push-g` first and stop.

### 2. Review in a clean-context subagent

When the agent can spawn subagents, spawn a general-purpose subagent at the Standard tier (see **context-engineering-g**) with this brief:

- Follow the **review-pr-g** skill for PR `<id>` in repository `<repo>`. Where the skill is not model-invocable, read it from the agent's skills directory (Claude Code: `~/.claude/skills/review-pr-g/SKILL.md`).
- Post nothing: no PR threads, votes, Slack reactions or messages. Do not run `/triage-finding-g`, `/draft-review-g` or `/submit-review-g` yourself: the author's notes are triaged in the main context.
- Do not run `git checkout` or `git switch` in the workspace. Read branch files with `git show origin/<source>:<path>`.
- If you cannot spawn your own reviewer subagents, evaluate inline as **review-pr-g** step 5 allows.
- Return the step 6 Raw Review output verbatim, with its `F<n>` findings.

When subagents are not available, follow the **review-pr-g** skill inline, with the same no-posting constraint. The diff then stays in the main context.

While the review runs, the author can queue their own notes as `/triage-finding-g <note>`. When the raw review returns, process the queued notes in order, following that skill, before step 3. Each note adds or enriches `F<n>` feature fixes and may add `L<n>` agent improvements.

If the review is `clean` and no author notes added findings, report that, skip to step 8, and do not commit anything.

### 3. Weigh the findings

Apply the **feedback-evaluation-g** skill to each `F<n>` finding, treating the raw review as reviewer feedback. Find the governing standard for each finding, read it, and give the finding one of the five verdicts. Check every finding against the code on the branch. A finding that misreads the code is **Disagree**, whatever its severity.

Findings tagged `Source: author note` start at **Agree-fix**: the author is the authority on their own intent (see the hierarchy of authority in **feedback-evaluation-g**). Move one to **Disagree** or **Need-context** only when the code on the branch contradicts it, and say how.

### 4. Present the verdict tables

**Feature fixes**

| Finding | Verdict | Governing standard | Proposed action | Lesson |
|---------|---------|-------------------|-----------------|--------|
| `F<n>` [Severity] file path + line, first sentence (truncated) | One of the five verdicts | Skill/rule name + relevant section (or "general principles") | Code change summary, the reason for not acting, or the open question | `L<n>` from **triage-finding-g**, or `—` |

**Agent improvements** -- only when `/triage-finding-g` recorded lessons:

| Lesson | Target artifact(s) | Route | Explains | Proposed change |
|--------|-------------------|-------|----------|-----------------|
| `L<n>` | Workspace path(s), or the `-g` skill name | Preceding commit (workspace) or observation file (user-level) | `F<n>`, ... | One-line summary; the diff was shown at triage time |

Nothing is posted, so there is no reply-text column. The user approves each table separately and may:

- Approve all
- Approve selectively
- Override specific verdicts
- Request re-evaluation of specific findings

Do not proceed until the user approves.

### 5. Apply the fixes

In **Agent** mode, make the code changes for the approved **Agree-fix** and **Partial** verdicts, and the artifact changes for the approved workspace lessons. Apply the **self-review-g** skill to the resulting diff and run the repository's checks (type check, lint, tests) for the touched files.

Do not act on **Agree-defer** and **Need-context** findings. List them for the user in step 8.

### 6. Commit and push

Keep agent improvements and feature fixes in separate commits. Never put an artifact change in a feature fixup, or a code fix in a refactoring commit.

1. **Agent improvements.** Follow the **commit-and-push-g** skill in **precede** mode with the approved workspace lessons, one refactoring commit per lesson. A lesson that touches several artifacts is still one commit, and unrelated lessons are separate commits, so each can be reviewed or reverted on its own. Each commit body states what went wrong in this draft and why the change prevents it from happening again. For approved user-level lessons, write observation files following **capture-improvement-g** Path 1, with `source-skill: triage-finding-g` and `observed-during: refine-draft-pr-g`.
2. **Feature fixes.** Continue in **fixup** mode in the same **commit-and-push-g** run. Each fix folds into the draft commit it belongs to.
3. **Push** once, at the end. **commit-and-push-g** asks before pushing with `--force-with-lease`.

When there are no approved lessons, run **fixup** mode alone.

### 7. Learn from the review miss

Skip this step when no author note was classified as merge or add.

Otherwise, follow the **codify-review-miss-g** skill. A merged or added author note means the clean-context review missed something. That lesson concerns the review skills, while the step 6 lessons concern the artifacts that led to the defect, so they don't overlap.

### 8. Confirm

Print:

- PR link, still a draft
- Counts of fixed, deferred, rejected and open findings, with the deferred and open ones listed
- Refactoring commit SHAs for agent improvements, and paths of any observation files written
- Commit SHAs after the autosquash
- The next step: `/submit-feature-g` when the draft is ready for review, or `/refine-draft-pr-g` again for another pass

### 9. Evolve

Follow the **capture-improvement-g** skill.
