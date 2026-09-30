---
name: artifact-layering-g
description: Defines how user-level skills (suffixed with `-g`) interact with repo-level skills -- runtime reconciliation when both are loaded, and authoring conventions for structuring repo-level rules to avoid duplication. Includes the fgrepo rule that user-level artifacts override conflicting repo artifacts outside `client/`. Use whenever the agent encounters overlapping user and repo instructions, operates in fgrepo, or creates/modifies workspace rules in any repository.
---

# Artifact Layering

User-level skills are deployed globally from the dotfiles repository and are identifiable by their `-g` suffix. Repositories may contain their own skills, rules, or instructions that overlap with user-level skills. This skill defines how to reconcile those layers at runtime and how to author repo-level rules that avoid duplication.

## The `-g` suffix convention

All user-level skills end in `-g` (global). This makes layer identification trivial:

- Any skill ending in `-g` is **user-level** (personal, global, deployed via Nix).
- Any skill NOT ending in `-g` is **repo-level** (or third-party).

This naming convention eliminates ambiguity in agent UIs, name-based resolution, and cross-references.

## Runtime reconciliation

When the agent's context contains both a `-g` skill and a repo-level artifact covering the same topic, apply this precedence model:

| Situation | Agent behavior |
|-----------|---------------|
| **Exact duplicate** of a `-g` skill exists in repo | Follow the `-g` skill. Ignore the repo copy -- it adds no information and may have drifted. |
| **Adjusted version** exists in repo | Follow the `-g` skill for shared parts. Additive repo-specific extensions are followed only when they do not contradict the `-g` skill. |
| **Partial overlap** exists in repo | The `-g` skill wins on overlapping topics. The repo artifact wins on topics where the `-g` skill is silent. |
| **Repo-only artifact** (no `-g` equivalent) | Follow the repo artifact normally -- no conflict exists. |

### Detection heuristic

Overlap exists when a repo-level artifact addresses the same concern as a `-g` skill:

- Same topic coverage (e.g., both prescribe commit message format, both define code review standards).
- Shared phrasing or structure suggesting the repo artifact was copied from the user skill.
- Contradictory directives on the same subject.

### Conflict resolution

When instructions conflict, follow the `-g` skill silently. Do not flag the conflict unless the user asks. When the repo artifact provides guidance on a topic the `-g` skill does not address, follow it -- there is no conflict.

## Authoring conventions

When creating or modifying repo-level rules in repositories you control, choose one of three interaction modes:

### Reference

The repo needs the same behavior as a `-g` skill. Do not copy the skill content into the repo. Instead, add a one-line mention in the repo's `AGENTS.md` or workspace rule:

```markdown
Follow the **commit-conventions-g** skill for all git commits.
```

The agent already has the `-g` skill loaded globally. Repeating its content creates a second source of truth that drifts.

### Extend

The repo needs the `-g` skill's behavior PLUS repo-specific additions. Create a thin repo-level rule containing only the delta:

```markdown
In addition to the **code-review-g** skill:

- All PRs must include a migration guide if schema changes are present.
- Tag the DBA team as reviewer for any query changes.
```

The rule adds repo-specific requirements without duplicating the base skill's content.

### Override

The repo fundamentally diverges from the `-g` skill on a specific topic. Create a self-contained repo rule and note that it supersedes the global skill:

```markdown
This repository does NOT follow **functional-typescript-g** for the legacy `services/` directory.
Use class-based patterns with NestJS decorators instead.
```

Override should be rare and explicit. Document why the divergence exists.

## Choosing the interaction mode

| Signal | Mode |
|--------|------|
| Repo has no special requirements beyond the `-g` skill | Reference |
| Repo adds requirements but agrees with the `-g` skill's foundation | Extend |
| Repo's constraints are incompatible with the `-g` skill | Override |
| You cannot modify the repo's rules (maintained by another team) | N/A -- rely on runtime reconciliation |

## fgrepo: user-level artifacts win outside `client/`

In `fgrepo` the `client/` directory is the user's workspace. The other top-level directories (`devops/`, `automation/`, `backend/`, …) carry artifacts maintained by other teams that may conflict with the user's.

- **Detection:** the git remote URL contains `fgrepo`, or the workspace has `client/` alongside `devops/`, `automation/` or `backend/`.
- **Rule:** when a repo-level artifact (workspace rule, skill, subagent prompt) found **outside** `client/` contradicts a user-level artifact, the user-level artifact wins. Examples: a root `.cursor/rules/` file mandating classes against **functional-typescript-g**, or a repo skill with commit conventions that differ from **commit-conventions-g**.
- **Scope:** artifacts under `client/` are workspace-local and follow the normal reconciliation above.
- **Behaviour:** follow the user-level artifact silently unless the user asks about the conflict. Follow a repo-level artifact outside `client/` wherever the user's artifacts are silent. Never modify repo-level artifacts outside `client/` to resolve a conflict.

## Relationship to other skills

- **workspace-rules-g**: covers the format dimension (portable/generated/agent-specific trichotomy). This skill covers the content-deduplication dimension.
- **agent-compatibility-g**: ensures skills are portable across agents. This skill ensures they are non-redundant across layers.
