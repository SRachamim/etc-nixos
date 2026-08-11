---
name: delivered-text-g
description: Single entry point for all writing and communication skills. Defines scope (delivered text only), priority ladder, and routes to the right sub-skills by text type. Use whenever the agent composes text that will be committed, posted, published, or otherwise leave the agent-user conversation -- commit messages, PR titles, PR descriptions, PR comments, code review comments, Slack messages, work-item descriptions, code comments, documentation, wiki pages.
---

# Delivered Text

Orchestrator for all communication and writing skills. Read this skill first; it routes to the right sub-skills and resolves conflicts between them.

## Scope

**Delivered text** = text that will be committed, posted, published, or otherwise leave the agent-user conversation.

This skill and all sub-skills it references do **not** apply to:

- **Agent-to-user chat** -- replies, explanations, plan discussions, clarifying questions in the IDE. Write naturally here; don't perform the voice.
- **LLM-facing artifacts** -- Cursor rules, skills, commands, and subagent prompts are instructions *for* the LLM, not output *from* it. Clarity and effectiveness for the LLM reader come first; every writing-style rule is secondary in that context. The exception: the **keyboard characters only** rule (no em-dashes, curly quotes, etc.) still applies to LLM-facing artifacts.

## Priority ladder

When communication rules from different sub-skills conflict, the higher-priority concern wins:

| # | Priority | Governs | Source |
|---|----------|---------|--------|
| 1 | **Objectivist epistemology** | What to say, how to organise it -- grounding in reality, anti-rationalism, concretisation, self-containment | **objective-communication-g** |
| 2 | **Human/personal voice** | How to say it -- distinctive non-LLM voice, anti-LLM tells, active voice, contractions, positions | **writing-style-g** |
| 3 | **Simplicity** | Simpler formulation wins when two options are epistemologically and voice-equivalent | **decision-priorities-g** applied to prose |
| 4 | **International clarity** | Prefer common words, avoid idioms and figurative language, accessible to non-native speakers | **writing-style-g** > "simple, international English" |

## Routing table

Load sub-skills based on the text type being composed. "Always" skills are loaded unconditionally for every delivered text. "Conditional" skills are loaded when the text type matches.

| Text type | Always | Conditional |
|-----------|--------|-------------|
| **Any delivered text** | **objective-communication-g**, **writing-style-g** | -- |
| PR title, PR description | -- | **communication-templates-g** (sections 1--2) |
| Commit message | -- | **communication-templates-g** (section 3), **commit-conventions-g** |
| PR review comment | -- | **communication-templates-g** (section 5), **code-review-g** |
| PR review reply | -- | **communication-templates-g** (section 6), **code-review-g** |
| Work-item title/description | -- | **communication-templates-g** (sections 7--8) |
| Slack message | -- | **communication-templates-g** (sections 4, 9--10), **external-communications-g** |
| Any external platform post | -- | **external-communications-g** (approval, formatting, post-action linking) |
| Code comment | -- | **writing-style-g** reference.md > Code comments |

### Slack boundary clarification

For Slack messages, two skills cover different concerns:

- **writing-style-g** reference.md governs *tone* -- dry parenthetical asides, understatement, rhetorical questions, no-politeness-softeners, compression.
- **external-communications-g** governs *mechanics* -- approval workflow, mrkdwn formatting, content type selection, Slack identity, thread reuse, permalink construction.

## Sub-skill inventory

| Layer | Skill | Role |
|-------|-------|------|
| 1 | **objective-communication-g** | Epistemology: what to say, how to organise (Peikoff's seven principles) |
| 2 | **writing-style-g** | Voice: how to say it (anti-LLM tells, banned vocabulary, platform registers) |
| 3 | **communication-templates-g** | Structure: fill-in-the-blank skeletons per text type |
| 4 | **external-communications-g** | Operations: approval workflow, formatting, platform API mechanics |
| 5 | **commit-conventions-g** | Domain: commit message format, ordering, hygiene |
| 5 | **code-review-g** | Domain: review severity, actionability, thread status |
