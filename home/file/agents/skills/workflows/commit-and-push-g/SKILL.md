---
name: commit-and-push-g
description: Stages thread-relevant changes, commits them as new commits or fixups, and pushes to the remote. Use when committing and pushing work from the current agent thread, including fixup autosquash mode.
disable-model-invocation: true
---

# Commit and Push

Stage changes made in the current thread, commit them (as new commits or as fixups into existing commits), and push to the remote. When multiple agent threads work in parallel, only changes from the current thread are staged.

## Input

The user specifies (or the agent infers) the desired mode:


| Mode                 | When to use                                                                |
| -------------------- | -------------------------------------------------------------------------- |
| **commit** (default) | Create one or more new commits with the staged changes.                    |
| **fixup**            | Create fixup commits targeting relevant existing commits, then autosquash. |


## Steps

### 1. Identify thread-relevant changes

Run `git status --porcelain` to list all uncommitted changes (staged and unstaged).

Determine which changes belong to the current thread by reviewing the files you created or modified during this conversation. Only include changes that you made -- leave unrelated modifications unstaged.

If no relevant changes are found, inform the user and stop.

### 2. Stage relevant changes

Stage only the identified files using `git add` with explicit paths. **Never** use `git add .` or `git add -A`.

Run `git diff --cached --stat` and show the user what will be committed.

If the index already holds changes from another thread, leave them staged and commit with explicit paths (`git commit -- <paths>`, or `git commit --fixup=<sha> -- <paths>`) so only this thread's files go into the commit. Never unstage or reset another thread's changes.

When only some hunks of a file belong in a commit -- the file's changes are split across several commits, or it mixes this thread's hunks with another thread's -- explicit paths would commit the whole file. Write the hunks that belong in the commit to a patch and stage it with `git apply --cached <patch>`. If the real index already holds another thread's changes, stage into a temporary index so theirs stays as it is:

```sh
GIT_INDEX_FILE=<scratch>/index git read-tree HEAD
GIT_INDEX_FILE=<scratch>/index git apply --cached <patch>
GIT_INDEX_FILE=<scratch>/index git commit ...
```

Check `git diff --cached --stat` (with the same `GIT_INDEX_FILE`) before each commit. If a commit fails (e.g. a commit-msg hook), fix the cause and retry with the same index -- never re-stage with a broader `git add`. Stage the next commit's hunks only after the previous commit succeeds.

### 3a. Commit (default mode)

Draft one or more commit messages following the **commit-conventions-g** skill and commit immediately.

### 3b. Fixup into existing commits

Determine the merge base with the default branch (e.g. `git merge-base HEAD origin/main`). Only commits **after** the merge base are fixup candidates -- never rewrite commits that are already in the default branch.

Run `git log --oneline <merge-base>..HEAD` to list candidate commits.

For each candidate, verify authorship (`git log --format='%ae' -1 <sha>`). Only target commits authored by you. If a commit belongs to someone else, skip it and inform the user.

For each staged file (or hunk), determine which eligible commit it logically belongs to based on the commit's scope.

Group the staged changes by target commit and create a `git commit --fixup=<sha>` for each group.

Then autosquash with:

```sh
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>
```

where `<base>` is the parent of the earliest fixup target.

If the rebase encounters conflicts, abort, inform the user, and stop.

**Empty-commit edge case**: if the fixup fully reverts its target (i.e., the staged diff is the exact inverse of the target commit's diff), skip the fixup workflow entirely. Instead, drop the commit with `git reset HEAD~1`, discard the leftover unstaged changes with `git checkout -- <files>`, and note the dropped commit in the summary.

### 4. Push

Before pushing, verify the upstream is correct: run `git rev-parse --abbrev-ref --symbolic-full-name @{upstream}` and compare the upstream branch name to the local branch name. If the upstream points to a different branch (e.g., the local branch is `feature/123` but upstream is `origin/main`), treat it as a stale upstream -- unset it with `git branch --unset-upstream` and then use `git push -u origin HEAD`.

Run `git push` to push the current branch to the remote.

- If the branch has no upstream, use `git push -u origin HEAD`.
- If the fixup rebase rewrote history, **warn the user** and use `git push --force-with-lease` only after they confirm.

### 5. Confirm

Run `git status` to verify the working tree is clean for the changes that were committed.

Print a summary: files committed, commit SHA(s), and remote branch.

### 6. Evolve

Follow the **capture-improvement-g** skill.
