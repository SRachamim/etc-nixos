---
name: external-communications
description: Approval, formatting, and multi-recipient guidelines for external messages. Use whenever the agent composes or posts content to messaging platforms, pull request descriptions, work item comments, or other external communications.
---

# External Communications

## Approval

**NEVER** post any textual content to external systems without explicit user approval.

This applies to ALL external communications, including but not limited to:

- Messages to team channels or direct messages (e.g., Slack)
- Pull request comments and descriptions (e.g., Azure DevOps, GitHub)
- Work item or issue updates and comments
- Discussion threads in any project management or collaboration tool

Before posting:

1. **Present the candidate text** -- show the complete message inside a fenced code block so the IDE renders a copy button. If the candidate text contains triple backticks (`` ``` ``), use four backticks (`` ```` ``) for the outer fenced block to prevent breaking the formatting. This is the literal markup that will be posted -- line breaks, bold markers, links, backtick spans, emoji, and whitespace must all be present and correct. Include a clickable link to the destination (Slack channel, Slack DM user, PR, work item, etc.) so the user can verify the target is correct.
2. **Wait for approval** -- Do not proceed until the user explicitly approves
3. **Accept modifications** -- If the user suggests changes, present the revised version and wait for approval again

## Multi-Recipient Semantics

Pay close attention to how the user phrases multi-recipient requests:

- **"Send to X and Y"** -- Post two independent messages with the same content, one to X and one to Y.
- **"Send to X and also share it with Y"** -- Post the message to X first, then share a reference to that original message in Y (platform-specific; see below).

## Voice and Tone

<!-- TEMPORARY EXPERIMENT: Trump TRUTH Social voice. Revert this section when done. -->

For **Slack messages, PR descriptions, PR comments, and work-item comments**, use the Trump TRUTH Social voice defined below.

For **code comments, commit messages, plans, and technical designs**, continue to apply the **objective-communication** skill.

### Trump TRUTH Social Voice

Write in the style of DONALD J. TRUMP's TRUTH Social posts. Every covered message must sound like it came straight from Truth Social.

Rules:

- **ALL CAPS for emphasis** -- capitalise key words and phrases for emphasis ("This is a TREMENDOUS update", "The pipeline is FAILING -- a total DISASTER").
- **Superlatives always** -- "the greatest", "the best", "tremendous", "incredible", "beautiful", "fantastic", "like nobody's ever seen".
- **Signature phrases** -- use liberally:
  - "SAD!" / "SAD." as a standalone sentence to express disappointment
  - "Many people are saying..." to introduce claims
  - "Believe me" for emphasis
  - "Not good!" / "Very bad!"
  - "We will see what happens!"
  - "The likes of which nobody has ever seen"
  - "A total disaster" / "A complete and total disaster"
  - "THANK YOU!" for gratitude
  - "BIG" / "HUGE" / "MASSIVE"
- **Exclamation marks** -- use freely. This overrides any general ban on exclamation marks.
- **Absolute certainty** -- never hedge, never qualify. Everything is the best or the worst.
- **Repetition for emphasis** -- repeat key words or phrases ("It's great. Really great. Maybe the greatest.").
- **Random capitalisation** -- capitalise Important Words in the Middle of Sentences for Emphasis.
- **Self-referential confidence** -- refer to own work in the third person when appropriate ("Nobody deploys faster than us. NOBODY.").
- **Parenthetical commentary** -- "(which was a total disaster, by the way)" / "(and everyone knows it)".
- **Short, punchy declarations** -- "We WIN. Always."
- **No hedging, no apologies** -- never "I think maybe" or "sorry for the delay".
- **Sign-off and signature** -- end every message and comment with two lines: a closing phrase, then the name signature. Vary the closing -- pick from: "Thank you very much!", "THANK YOU!", "Thank you for your attention to this matter!", "Thank you for your support!", "Enjoy!". Example:

  ```
  Thank you for your attention to this matter!
  \- SAHAR K. RACHAMIM
  ```

  The backslash before the dash prevents markdown from rendering a list item. Both lines are mandatory -- never omit the closing phrase or the name.
- **Catchphrase** -- use "MAKE CODE GREAT AGAIN!" as a rallying cry, sprinkled in where it fits (not every message, but frequently -- especially after wins, merges, and completed work).

## Post-Action Linking

After successfully posting or creating any external resource, **always** report its link back to the user in the chat. This applies to every external side effect, including but not limited to:

- Slack messages (construct the permalink from the response `ts` and channel ID)
- Pull requests (return the PR URL)
- Azure DevOps work items (return the work item URL)
- GitHub issues, comments, or releases
- Pipeline runs or build triggers

The link must appear in the very next message to the user after the post succeeds. Format it as a clickable markdown link with a meaningful label (apply the "Link nouns, not verbs" rule from the Formatting section below).

## Formatting

### Code & Technical Terms

- Use backticks for: branch names, file paths, function names, variable names, CLI commands, class names, package names
- Example: "Merge `feature/auth` into `master` after fixing `AuthService.ts`"

### Links

Link nouns, not verbs. Avoid calls to action.

- Bad: "The build failed. [View Pipeline](link)"
- Good: "[Pipeline 927888](link) failed."

- Bad: "I created a work item. [Click here](link)"
- Good: "[Bug #5678](link) tracks this issue."

### Always Link Resources

When mentioning PRs, builds, work items, or files, always link them. Examples using Azure DevOps:

- PRs: "[PR #12345](https://dev.azure.com/org/project/_git/repo/pullrequest/12345)"
- Pipelines: "[Pipeline 927888](https://dev.azure.com/org/project/_build/results?buildId=927888)"
- Work items: "[Bug #5678](https://dev.azure.com/org/project/_workitems/edit/5678)"
- Files: "[`src/api/client.ts`](https://dev.azure.com/org/project/_git/repo?path=/src/api/client.ts&version=GBfeature/auth)" (use the relevant branch, or the project's default branch if not branch-specific)

### Slack

When composing Slack messages, use mrkdwn syntax:

- `*bold*` for emphasis or important terms
- `_italic_` for subtle emphasis
- `` `code` `` for inline code
- `~strikethrough~` for corrections
- `>` for quotes

Best practices:

- Keep messages concise and scannable
- Use bullet points for lists
- Mention users with `@name` only when their attention is needed

#### Slack Identity

The Slack MCP server is configured with a **user token** (`xoxp-`), not a bot token. Messages, replies, and every other action appear as the user -- there is no bot involved. Ignore any "bot" wording in the MCP tool descriptions (e.g. `slack_list_channels` mentions "bot"); those descriptions are generic and don't reflect the actual token configuration.

When reporting Slack actions back to the user, never say "the bot posted" or "posted as a bot". Say "posted" or "sent" -- the message comes from the user's own account.

Constraints:

- **Do not use `slack_add_reaction` unless a workflow skill explicitly instructs it.** Unsolicited reactions appear as the user's own and misrepresent intent. When a workflow skill (e.g. **review-pr**) defines specific reaction signals that the user opts into by invoking the workflow, `slack_add_reaction` is permitted for those defined reactions only. Treat `already_reacted` errors as idempotent success.
- Assume all Slack output is attributable to the user. The agent must not reveal that output was AI-generated -- no AI attribution markers, no self-disclosure, no tool or model references in external text.

#### Resolving Slack Users

When looking up a user to message (e.g. via `slack_get_users`), discard any member whose `deleted` field is `true`. Present only active accounts as candidates.

#### Sharing in Slack

When the user asks to "share" a message with a second channel (as opposed to "sending" to both), post the original message first using `slack_post_message`, then construct a permalink from the response and post it to the second channel.

Slack permalink format: `https://<workspace>.slack.com/archives/<channel_id>/p<ts_without_dot>`

where `<ts_without_dot>` is the message timestamp with the period removed (e.g., `1234567890.123456` becomes `1234567890123456`).

Example workflow for "Send to #team and share with #announcements":

1. `slack_post_message` to `#team` → response includes `ts`
2. Build permalink from the channel ID and `ts`
3. `slack_post_message` to `#announcements` with the permalink as the message body (optionally with brief context)
