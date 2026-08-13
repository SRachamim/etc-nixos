---
name: external-communications-g
description: "MANDATORY rules for all external messages -- approval workflow, formatting, post-action linking, Slack mechanics. Sub-skill of **delivered-text-g** -- handles operations (layer 4). Loaded conditionally when posting to an external platform. Content evolves; never assume from memory."
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

See **delivered-text-g** for the full skill stack. The orchestrator loads **objective-communication-g** and **writing-style-g** unconditionally alongside this skill.

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

#### Content Type Selection

The `conversations_add_message` tool defaults to `content_type: "text/markdown"`, which collapses newlines in multi-line messages.

Use `content_type: "text/plain"` when the message contains any of:

- Bullet lists (`*`, `-`, or `•`)
- Multiple paragraphs separated by blank lines
- Structured sections with bold pseudo-headers

Slack's native mrkdwn rendering still applies in plain-text mode -- `*bold*`, `<url|text>` links, `` `code` ``, `_italic_`, `~strikethrough~`, and `>` quotes all work.

Use `content_type: "text/markdown"` only for single-paragraph messages with no list formatting.

#### Slack Identity

The Slack MCP server is configured with a **user token** (`xoxp-`), not a bot token. Messages, replies, and every other action appear as the user -- there is no bot involved.

When reporting Slack actions back to the user, never say "the bot posted" or "posted as a bot". Say "posted" or "sent" -- the message comes from the user's own account.

Constraints:

- Assume all Slack output is attributable to the user. The agent must not reveal that output was AI-generated -- no AI attribution markers, no self-disclosure, no tool or model references in external text.
- Treat `already_reacted` errors from `reactions_add` as idempotent success.

#### Resolving Slack Users

When looking up a user to message, use `users_search` with their name or email as the query.

#### Resolving Slack Channels

When looking up a channel by name, use `channels_me` first -- the target
channel is almost always one the user is a member of, and `channels_me`
returns results reliably. Fall back to `channels_list` only if the channel
is not in the user's membership list.

#### Sharing in Slack

When the user asks to "share" a message with a second channel (as opposed to "sending" to both), post the original message first using `conversations_add_message`, then construct a permalink from the response and post it to the second channel.

Slack permalink format: `https://<workspace>.slack.com/archives/<channel_id>/p<ts_without_dot>`

where `<ts_without_dot>` is the message timestamp with the period removed (e.g., `1234567890.123456` becomes `1234567890123456`).

Example workflow for "Send to #team and share with #announcements":

1. `conversations_add_message` to `#team` → response includes `ts`
2. Build permalink from the channel ID and `ts`
3. `conversations_add_message` to `#announcements` with the permalink as the message body (optionally with brief context)

#### Thread Reuse in Slack

When sending a message to a person or channel, check whether an earlier message in the current session was already sent to the same destination about the same topic (e.g. the same PR, work item, or incident). If so, reply in that existing thread (`thread_ts`) rather than posting a new top-level message.

This avoids fragmenting related updates into separate conversations and keeps the recipient's DM/channel history clean.
