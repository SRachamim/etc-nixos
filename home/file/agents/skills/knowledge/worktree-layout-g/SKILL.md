---
name: worktree-layout-g
description: Conventions for git worktree paths and branch naming. Use whenever the agent creates, navigates, or removes worktrees.
---

# Worktree Layout

This skill operates within the broader **gitflow-branching-g** model. It overrides Gitflow's defaults for physical layout and starting-point branch.

## Branch Naming

- Features: `feature/<work-item-id>-<slug>`
- Hotfixes: `hotfix/<work-item-id>-<slug>`

The `<slug>` is a short, human-readable summary derived from the work item title. It makes branch names immediately understandable without looking up the ID.

Examples:
- `feature/12345-add-auth-middleware`
- `hotfix/67890-fix-login-crash-empty-email`

## Slugification

Derive the slug from the work item title:

1. Lowercase the entire title.
2. Replace non-alphanumeric characters (spaces, punctuation, special chars) with hyphens.
3. Collapse consecutive hyphens to a single hyphen.
4. Strip leading and trailing hyphens.
5. Truncate to **3--5 words** (drop trailing words beyond 5). Prefer a natural break point that preserves meaning.

If the resulting slug is fewer than 3 words and the original title was longer, include up to 5 words before truncating.

### Examples

| Work item title | Slug |
|-----------------|------|
| Add authentication middleware to API gateway | `add-auth-middleware` |
| Login page crashes on empty email | `login-page-crashes-empty-email` |
| Refactor portfolio valuation engine | `refactor-portfolio-valuation-engine` |
| Update README | `update-readme` |

## Choosing the Prefix

| Starting ref matches | Prefix |
|----------------------|--------|
| `release/*` or `origin/release/*` | `hotfix` |
| Anything else | `feature` |

The prefix determines the branch name (`<prefix>/<id>-<slug>`) and the worktree path (`<root-repo>/<prefix>/<id>-<slug>`).

## Worktree Paths

- Resolve the **bare root** or **main worktree** via `git worktree list`. This is the `<root-repo>`.
- Feature worktrees live at: `<root-repo>/feature/<id>-<slug>`
- Hotfix worktrees live at: `<root-repo>/hotfix/<id>-<slug>`

## Creation

- Never overwrite an existing worktree or branch. If either exists, inform the user and stop.
- Determine the **starting ref**:
  - For the `fgrepo` repository, always use `origin/develop`.
  - For all other repositories, determine the default branch (e.g. `main`, `master`) via `git remote show origin` or equivalent and use `origin/<default-branch>`.
- If the user explicitly requests a different starting point, use that instead of the default branch.
- Determine the **prefix** from the starting ref using the table in **Choosing the Prefix** above.
- Derive the **slug** from the work item title using the **Slugification** algorithm above.
- Fetch the latest state of the starting ref before branching: `git fetch origin <branch>`.
- Create the worktree from the fetched ref: `git worktree add -b "<prefix>/<id>-<slug>" "<root-repo>/<prefix>/<id>-<slug>" "<starting-ref>"`.
- Unset the auto-configured upstream so the branch does not track the starting ref:
  `git branch --unset-upstream "<prefix>/<id>-<slug>"`.
  This ensures the first push (with `-u`) sets the correct upstream to `origin/<prefix>/<id>-<slug>`.

## Parsing the Work Item ID

Branch names follow the pattern `^(feature|hotfix)/(\d+)-(.+)$`. Group 2 is the numeric work item ID. The legacy format `<prefix>/<id>` (without slug) is also recognized for backward compatibility.

## Cleanup

- Remove the worktree first: `git worktree remove "<root-repo>/<prefix>/<id>-<slug>"`.
- Then delete the branch: `git branch -d "<prefix>/<id>-<slug>"`.
- Use `-d` (not `-D`) so git refuses if the branch has unmerged changes.
- If the current directory is inside the worktree being removed, switch to the main worktree first.
