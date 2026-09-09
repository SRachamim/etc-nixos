---
name: draft-review-g
description: "Compose the final delivered text for all consolidated review findings and present the complete review output, ready for posting via /submit-review-g. Reads raw findings from the conversation (output of /review-pr-g, /review-pr-fixes-g, or /triage-finding-g). Use after the review and optional triage steps, before /submit-review-g."
disable-model-invocation: true
---

# Draft Review

Compose the final delivered text for all consolidated findings and present the complete review output, ready for posting.

This skill absorbs the drafting work that was previously in `/review-pr-g` (steps 6--7) and `/review-pr-fixes-g` (steps 7--8). The heavy **delivered-text-g** composition happens here, not during the review itself -- saving time when the agent and user are working in parallel.

## Steps

### 1. Load delivered-text stack

Load **delivered-text-g** and follow its routing table for text type "PR review comment." Load all applicable layers before composing any text.

### 2. Read raw findings from context

Collect the authoritative findings list from the conversation:

- If `/triage-finding-g` was invoked one or more times, the most recent findings list (after all triage decisions) is authoritative.
- Otherwise, the raw findings output from `/review-pr-g` or `/review-pr-fixes-g` is authoritative.

If the conversation contains no raw findings from a preceding review skill, tell the user and stop.

### 3. Compose comment text

For each finding, compose the literal ADO comment text:

- Follow the **communication-templates-g** PR Review Comment template (Brief / Standard / Thorough tiers based on the depth the issue needs).
- Include diff hunks per the **code-review-g** inline-diff-context rule.
- Internally classify each finding per the **code-review-g** skill (Blocking / Suggestion / Nit) for verdict logic, but do not include severity labels in the comment text.
- Each comment must include the specific file path and line range.
- Do not include praise -- every comment must be actionable.

### 4. Compose review summary

Produce an overall summary:

- **Verdict**: request changes (one or more blocking findings) or comment-only (no blocking findings).
- **Design evaluation highlights** (when the preceding review included a design evaluation): the reconstructed plan (goal, approach, commit strategy) and design-level findings.
- **Findings count by internal severity**: N blocking, N suggestions, N nits.

### 5. Compose follow-up actions (when preceded by `/review-pr-fixes-g`)

When the preceding review was a follow-up (`/review-pr-fixes-g`), also compose thread resolution actions:

- **Threads to resolve** (`Fixed`): list thread IDs. No reply needed -- the status change is sufficient.
- **Threads to reactivate** (`Active`): compose the follow-up reply text for each, explaining what's still missing. Present each reply in a fenced code block.
- **Threads unchanged**: list thread IDs. No action needed.

### 6. Compose Slack actions (when the review was Slack-originated)

When the original `/review-pr-g` was triggered from a Slack message, compose:

- **Reaction**: the emoji to add (`:speech_balloon:` for comment/suggest, `:leftwards_arrow_with_hook:` for reject, `:white_check_mark:` for approve). The exact reaction depends on the anticipated verdict from step 4 -- present the default and note that `/submit-review-g` will use the actual verdict keyword.
- **Thread reply**: a bare verdict word per the Slack reaction signals convention. Present the draft reply text.

### 7. Present the complete review

Show everything to the user:

- The overall summary and verdict from step 4.
- Every finding with its literal post text in a fenced code block.
- Thread resolution actions (if follow-up review, from step 5).
- Slack actions (if Slack-originated, from step 6).

This is the single approval gate for the review content. The user can request edits to any finding's text before proceeding to `/submit-review-g`.

**Wait for user approval** before the user proceeds to `/submit-review-g`. The approval covers the review content. The posting action and vote are confirmed separately in `/submit-review-g`.

### 8. Evolve

Follow the **capture-improvement-g** skill.
