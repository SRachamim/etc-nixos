---
name: artifact-layering-g
description: Defines how user-level skills (suffixed with `-g`) interact with repo-level skills -- runtime reconciliation when both are loaded, and authoring conventions for structuring repo-level rules to avoid duplication. Use whenever the agent encounters overlapping user and repo instructions, or when creating/modifying workspace rules in any repository.
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

## Relationship to other skills

- **fgrepo-artifact-precedence-g**: a repo-specific specialization that adds directory-boundary scoping (the `client/` rule) on top of this general model.
- **workspace-rules-g**: covers the format dimension (portable/generated/agent-specific trichotomy). This skill covers the content-deduplication dimension.
- **agent-compatibility-g**: ensures skills are portable across agents. This skill ensures they are non-redundant across layers.
