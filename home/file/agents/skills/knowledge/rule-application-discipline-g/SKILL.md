---
name: rule-application-discipline-g
description: Pre-write protocol that mandates consulting loaded workspace rules and scanning for prior art before writing code. Prevents write-first/check-later behaviour where conventions are applied reactively after user corrections instead of proactively. Use whenever the agent is about to implement code changes.
---

# Rule Application Discipline

Treat loaded workspace rules and knowledge skills as a mandatory pre-flight checklist -- not as reference documentation to consult after user rejection. Every convention violation that a loaded rule already covers is a preventable round-trip.

## When to apply

Before writing or modifying code in any file. This includes:

- Implementing a planned commit (via **plan-execution-g**).
- Making ad-hoc changes outside a formal plan.
- Fixing code after a self-review finding or user correction.

## Protocol

### 1. Identify governing conventions

Before writing code in a file, determine which loaded workspace rules and knowledge skills govern the change:

1. **Module conventions** -- rules about file placement, module boundaries, function ownership.
2. **Naming conventions** -- rules about function names, variable names, import aliases.
3. **Import conventions** -- rules about import style (namespace vs named, type aliases).
4. **Coding patterns** -- rules about invocation shape, composition style, error handling.
5. **Test conventions** -- rules about test style, assertion patterns, test data construction.

Read the relevant rule sections **fully**. Do not read the minimum to answer one question -- adjacent requirements in the same section frequently apply to the same change.

### 2. Scan for prior art

Before creating a new file or introducing a new pattern:

1. **Glob for existing examples.** Search the codebase for files that follow the same convention (e.g., `*.arbitrary.ts`, `*.codec.ts`, similar module structures). Use the results to adopt the established pattern.
2. **Inspect 2-3 examples.** Read representative files to extract the concrete conventions: import style, export patterns, naming, structure.
3. **Adopt or justify.** Follow the established pattern unless a loaded workspace rule explicitly directs otherwise. If deviating, state why in the commit message.

### 3. Write with conventions applied

Implement the change with the identified conventions applied from the first draft. The goal is zero convention violations in the initial code -- self-review should catch semantic and design issues, not import style or function placement.

### 4. Full-section re-reads on correction

When a convention violation surfaces during self-review or user feedback:

1. Re-read the **entire section** of the governing rule -- not just the sentence that covers the current issue.
2. Check whether adjacent requirements in the same section also apply to the current change.
3. Fix all related violations in a single pass rather than one at a time.

## Anti-patterns

| Anti-pattern | Correct behaviour |
|---|---|
| Write code from general knowledge, consult rules only after rejection | Consult rules before writing the first line |
| Read the minimum rule text to fix one reported issue | Read the full rule section to catch adjacent requirements |
| Create a new file without checking existing examples | Glob for prior art and adopt the established pattern |
| Fix one convention violation per round-trip with the user | Fix all violations from the same rule section in one pass |

## Scope

This skill governs the **discipline of consulting conventions**, not the conventions themselves. Specific coding conventions (import style, function placement, invocation patterns, test style) are defined by workspace rules and other knowledge skills. This skill ensures those conventions are applied proactively rather than reactively.
