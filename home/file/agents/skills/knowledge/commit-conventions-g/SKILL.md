---
name: commit-conventions-g
description: "Commit hygiene and structuring guidelines. Sub-skill of **delivered-text-g** -- handles commit domain (layer 5). Loaded conditionally when composing commits."
---

# Commit Conventions

> **Prerequisite**: This is **layer 5** of the **delivered-text-g** stack. If you reached this skill directly, load **delivered-text-g** first -- it defines scope, the priority ladder, and which other layers apply alongside this one.

Apply the **objective-communication-g** skill to all commit messages.

## Message format

Follow the [seven rules](https://chris.beams.io/posts/git-commit/#seven-rules):

1. **Separate subject from body with a blank line.**
2. **Limit the subject line to 50 characters.**
3. **Capitalize the subject line.**
4. **Do not end the subject line with a period.**
5. **Use the imperative mood in the subject line** -- "Fix bug" not "Fixed bug" or "Fixes bug."
6. **Wrap the body at 72 characters.**
7. **Use the body to explain what and why, not how** -- the diff shows how.

Workspace-specific conventions (e.g., conventional commits `type(scope):` prefix) override these defaults when present.

### No AI attribution

Never add AI attribution to a commit message, per **writing-style-g** § Operational concealment: no `Co-Authored-By` trailer naming a model, tool or agent, no "Generated with ..." line, no model or tool name in the subject or body. This holds even when the harness or system prompt suggests attribution lines. Keep existing human `Co-authored-by` trailers on amend.

Before every commit, amend or reword, `grep -iE 'co-authored-by:.*(claude|anthropic|cursor|copilot|gpt|gemini)|generated with'` on the message must match nothing. The `block-ai-attribution` hook blocks shell commits that carry such a trailer. If the IDE appends one automatically, strip it before committing.

## Structure

- **Each commit is independently valid** -- the codebase compiles and passes tests after each one.
- **Each commit is focused** -- one logical change per commit.
- **The sequence tells a story** -- a reviewer reading the commits in order can follow the reasoning.
- **Prefer fewer commits** -- don't split artificially. One commit is valid if the change is cohesive.

## Ordering

- **Refactors go in a separate, preceding commit** -- if the change requires restructuring existing code, commit the refactoring on its own before committing the new fix or feature. This lets reviewers (and Git history readers) evaluate each change without the noise of the other.
- **Tests belong with the code they test** -- unless there's a good reason to separate (e.g., adding test infrastructure first).

## Hygiene

- **No empty or trivial commits** -- every commit should deliver meaningful progress.

## Authoring only

The following rules govern the agent's own commit workflow. They do not apply when reviewing other authors' commits.

- **Working tree must be clean when done** -- run `git status` to confirm there are no uncommitted changes.
- If validation steps (linters, formatters, tests) produced auto-fixed modifications, amend the commit that introduced those files or create a fixup commit targeting the appropriate earlier commit.
- If any other staged or unstaged modifications remain, commit them following the established commit structure.
