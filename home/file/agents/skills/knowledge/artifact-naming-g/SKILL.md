---
name: artifact-naming-g
description: Naming conventions for agent skills, subagent prompts, and related artifacts. Covers format rules, part-of-speech by type, verb vocabulary, suffix conventions, and anti-patterns. Use whenever the agent names a new artifact, renames an existing one, or reviews artifact naming in a PR or skill.
---

# Artifact Naming

Standard naming conventions for agent artifacts managed in this dotfiles repository. Names serve two audiences: humans (typing, recall, slash-command invocation) and agents (routing, auto-discovery). The `name` field optimizes for humans; the `description` field optimizes for agents.

## Format rules

Hard constraints from the [Agent Skills specification](https://agentskills.io/specification):

- Lowercase letters, numbers, and hyphens only.
- 1--64 characters.
- Must not start or end with a hyphen.
- Must not contain consecutive hyphens.
- Regex: `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`
- The `name:` frontmatter field must match the parent directory name exactly.

### Derived conventions

- **H1 title**: Title Case, suffix stripped. `artifact-naming-g` becomes `# Artifact Naming`.
- **Cross-references in prose**: bold the full name including suffix -- `**artifact-naming-g**`. Never use the filesystem path as the identifier.
- **Catalog display**: strip the suffix, Title Case. `/deliver-feature-g` appears as "Deliver Feature".

## Part of speech by artifact type

Each artifact type has a natural part of speech. Consistency within a type creates a predictable mental model for both invocation and discovery.

| Type | Part of speech | Pattern | Examples |
|------|---------------|---------|----------|
| Workflow skill | Verb or verb-phrase | `{verb}-{object}[-{qualifier}]` | `fix-bug-g`, `review-pr-g`, `deliver-feature-g` |
| Knowledge skill | Noun or noun-compound | `{domain}-{concept}` | `commit-conventions-g`, `architect-thinking-g`, `artifact-naming-g` |
| Shared skill | Verb-phrase (helper) | `{verb}-{object}` | `create-work-item-g`, `vote-pr-g`, `resolve-current-work-item-g` |
| Subagent prompt | Role-noun | `{role}` or `{role-qualifier}` | `reviewer`, `test-writer`, `implementer` |

Maintain part-of-speech consistency within a type. Workflows start with verbs. Knowledge skills start with nouns. Subagents are role-nouns. Never cross these boundaries.

## Suffix convention

- **`-g`** on all skills (workflow, knowledge, shared) -- signals user-level / global scope, deployed from this dotfiles repo.
- **No `-g`** on subagent prompts -- they are identified by filename stem, not slash-command.
- Skills **without** `-g` are repo-level, defined in project repositories, not this repo.

## Verb vocabulary for workflows

Standardized verbs prevent ambiguous siblings. Pick from this vocabulary before inventing a new verb.

| Verb | When to use |
|------|------------|
| `review` | Evaluate existing content or artifacts |
| `create` | Produce a new structured artifact |
| `fix` | Resolve a defect or failure |
| `deliver` | End-to-end feature completion |
| `plan` | Design a sequence of changes |
| `triage` | Categorize and prioritize inbound items |
| `submit` | Send an artifact for external approval |
| `verify` | Confirm a deployment or outcome |
| `close` | Tear down completed work |
| `list` | Enumerate matching items |
| `set` | Configure a value or state |
| `sweep` | Scheduled bulk hygiene pass |
| `debug` | Investigate defective behaviour |
| `investigate` | Gather evidence for an incident |
| `commit` | Stage and persist changes |
| `checkout` | Set up a new working context |
| `estimate` | Produce an effort assessment |
| `reproduce` | Verify a reported defect |
| `activate` | Transition to an active state |
| `block` | Mark as blocked on a dependency |
| `defer` | Postpone and record for later |
| `extract` | Pull out from a larger whole |
| `prune` | Remove stale or merged artifacts |
| `trace` | Follow references across systems |
| `prepare` | Ready for a specific event |
| `write` | Produce long-form prose |
| `report` | File a structured report |
| `design` | Architect a new system or component |
| `answer` | Research and respond to a question |
| `request` | Ask an external party for something |
| `evolve` | Improve an API or interface |

When no vocabulary verb fits, use the most specific imperative verb that describes the action. Avoid generic verbs: `run`, `do`, `process`, `handle`, `manage`, `check`.

## Length and word count

- **Target**: 1--3 hyphen-separated tokens before the `-g` suffix.
- **Maximum**: 4 tokens (e.g., `review-microservice-architecture-g`).
- If you need more than 4 tokens, the scope is probably too broad -- split the skill.

## Anti-patterns

| Anti-pattern | Why it fails | Fix |
|-------------|-------------|-----|
| Overly generic (`helper`, `utils`, `run`) | Invisible to routing, no recall | Add domain context |
| Ambiguous siblings (`update` vs `upgrade`) | Users cannot distinguish | Use distinct verbs with clear boundaries |
| Namespace stuttering (`agent-agent-foo-g`) | Redundant prefix | Drop the repeated scope |
| Adjective-noun for workflows (`new-feature-g`) | Wrong part of speech | Use verb: `create-feature-g` |
| Verb-phrase for knowledge (`review-standards-g`) | Reads as a workflow | Use noun: `code-review-g` |
| More than 4 tokens before suffix | Untypable, exceeds mental model | Split the skill |
| Gerund form (`reviewing-code-g`) | Ambiguous -- is it a skill or a state? | Use bare verb: `review-code-g` |

## Description convention

The `description` field is the primary signal for agent routing. It carries the entire burden of discoverability at the metadata stage (~100 tokens per skill).

- **Third person**: "Covers X. Use whenever the agent Y."
- **Include WHAT** (capability) and **WHEN** (trigger condition).
- **Include WHEN NOT** if the skill could be confused with a sibling.
- **Max 1024 characters** (spec constraint).
- Put domain keywords in the description, not the name. The name is for humans; the description is for agents.
