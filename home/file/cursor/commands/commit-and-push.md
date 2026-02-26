# Commit and Push

Stage changes made in the current thread, commit them (as new commits or as fixups into existing commits), and push to the remote. When multiple agent threads work in parallel, only changes from the current thread are staged.

## Input

The user specifies (or the agent infers) the desired mode:

| Mode | When to use |
|------|-------------|
| **commit** (default) | Create one or more new commits with the staged changes. |
| **fixup** | Create fixup commits targeting relevant existing commits, then autosquash. |

## Steps

### 1. Identify thread-relevant changes

Run `git status --porcelain` to list all uncommitted changes (staged and unstaged).

Determine which changes belong to the current thread by reviewing the files you created or modified during this conversation. Only include changes that you made — leave unrelated modifications unstaged.

If no relevant changes are found, inform the user and stop.

### 2. Stage relevant changes

Stage only the identified files using `git add` with explicit paths. **Never** use `git add .` or `git add -A`.

Run `git diff --cached --stat` and show the user what will be committed.

### 3a. Commit (default mode)

Draft one or more commit messages following the **commit-conventions** skill.

**Present the commit message(s) to the user for approval before committing.**

Create the commit(s).

### 3b. Fixup into existing commits

Determine the merge base with the default branch (e.g. `git merge-base HEAD origin/main`). Only commits **after** the merge base are fixup candidates — never rewrite commits that are already in the default branch.

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

### 4. Push

Run `git push` to push the current branch to the remote.

- If the branch has no upstream, use `git push -u origin HEAD`.
- If the fixup rebase rewrote history, **warn the user** and use `git push --force-with-lease` only after they confirm.

### 5. Confirm

Run `git status` to verify the working tree is clean for the changes that were committed.

Print a summary: files committed, commit SHA(s), and remote branch.

### 6. Evolve

Follow the **continuous-improvement** skill.
