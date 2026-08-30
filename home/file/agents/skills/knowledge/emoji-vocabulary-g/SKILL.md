---
name: emoji-vocabulary-g
description: "Consistent emoji-to-concept mapping for visual markers in delivered text. Defines canonical emoji for entity types (PRs, bugs, tasks), status indicators, colours, and acknowledgments. Supplements text for scanability -- emoji never replaces words. Use whenever the agent composes delivered text that references these concepts."
---

# Emoji Vocabulary

Canonical emoji-to-concept mapping for visual markers in delivered text. Emoji are **semantic markers** -- they anchor the reader's eye to key concepts for scanability. They are not decoration, personality, or filler.

## Prerequisite

> This skill is part of the **delivered-text-g** stack. If you reached it directly, load **delivered-text-g** first -- it defines scope, the priority ladder, and which other layers apply alongside this one.

## Core principle

Every emoji in delivered text must satisfy **Concretise** (adds a visual anchor for a concept) or **Structure** (creates visual hierarchy) from **objective-communication-g**. If it doesn't serve one of these functions, omit it.

Emoji supplements text -- it never replaces it. The text must be fully readable and self-contained with all emoji stripped.

**Subordination**: **objective-communication-g** takes absolute precedence (priority 1 in the **delivered-text-g** ladder). If an emoji violates Delimit (noise), Self-containment (meaning depends on emoji alone), or Anti-rationalism (inflates significance), drop it.

## Vocabulary

One emoji per concept. One concept per emoji. Consistency across all delivered text.

### Entity types

Place the emoji **before** the entity reference.

| Concept | Emoji | Example |
|---------|-------|---------|
| Pull request | 🔗 | 🔗 PR #4523 |
| Bug (work item) | 🐛 | 🐛 Bug #12345 |
| Task (work item) | 📋 | 📋 Task #67890 |
| Feature (work item) | ✨ | ✨ Feature #11111 |
| Build / pipeline | 🏗️ | 🏗️ Build #999 |
| Deployment | 🚀 | 🚀 deployed to staging |
| Configuration | 🔧 | 🔧 updated config |

### Status indicators

Place the emoji **before** the status word or phrase.

| Concept | Emoji | Example |
|---------|-------|---------|
| Passed / success / done / approved | ✅ | ✅ tests green |
| Failed / rejected / blocked | ❌ | ❌ build failed |
| Warning / risk / caution | ⚠️ | ⚠️ flaky test |
| In progress / reviewing | 👀 | 👀 reviewing now |

### Colour words

Place the emoji **before** the colour word. Use only when the colour itself carries meaning -- CI status, severity level, health indicator.

| Colour | Emoji |
|--------|-------|
| Green | 🟢 |
| Red | 🔴 |
| Yellow / amber | 🟡 |
| Blue | 🔵 |
| Orange | 🟠 |

### Acknowledgment

Place the emoji **after** the sentence or phrase.

| Concept | Emoji | Example |
|---------|-------|---------|
| Gratitude / thanks | 🙏 | thanks for the quick review 🙏 |
| Approval / agreement | 👍 | LGTM 👍 |
| Peer acknowledgment | 👊 | solid work on the migration 👊 |
| Precise catch | 🎯 | good catch on the off-by-one 🎯 |

## Density limits

Grounded in the **Delimit** principle and accessibility research (screen readers read every emoji's Unicode name aloud -- excessive emoji creates auditory clutter).

- Max **3 emoji per message** (Slack, PR comment, review comment).
- Max **1 emoji per bullet point**.
- Max **1 emoji per heading**.
- **0 emoji** in: commit subjects, code comments, formal specifications.
- Never stack multiple emoji in sequence.
- If a paragraph would have more than 2 emoji, restructure or drop the less important ones.

## Placement rules

1. Entity-type and status emoji go **before** the concept they mark.
2. Acknowledgment emoji go **after** the sentence.
3. Never place emoji mid-word or between a preposition and its object.
4. Never stack multiple emoji in sequence.

## What this skill does NOT override

- **writing-style-g** voice rules still apply. Don't use politeness softeners just to attach an emoji to them.
- **objective-communication-g** principles take absolute precedence at every point.
- **commit-conventions-g** format -- no emoji in commit subjects.
- Platform-specific conventions that ban emoji (formal external client communications per **external-communications-g**).

## Anti-patterns

| Anti-pattern | Why it fails |
|-------------|-------------|
| Using emoji not in the vocabulary | Breaks consistency -- the reader can't learn the visual language |
| Different emoji for the same concept across messages | Breaks the one-emoji-per-concept rule |
| Emoji as sole indicator of meaning (e.g. "🔴" without "red" or "failing") | Violates Self-containment -- text must stand alone |
| Emoji in every sentence | Violates Delimit -- visual noise, no scanability benefit |
| Decorative emoji not mapped to a concept (🎉, 🥳, 💯, 🔥) | Not a semantic marker -- this is personality, which **writing-style-g** bans |
| Emoji in commit subjects or code comments | Violates the density limits and platform conventions |
