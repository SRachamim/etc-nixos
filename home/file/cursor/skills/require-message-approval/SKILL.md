---
name: require-message-approval
description: Require user approval before posting any content to external systems. Use whenever the agent is about to post a Slack message, PR comment, PR description, work item comment, or any external communication.
---

# Require Approval Before Posting

**NEVER** post any textual content to external systems without explicit user approval.

## Scope

This applies to ALL external communications, including but not limited to:

- Slack messages
- PR comments and descriptions
- Work item descriptions and comments
- GitHub/Azure DevOps discussions
- Any other external messaging system

## Required Process

1. **Present the candidate text** - Show the complete message you intend to post, formatted as it will appear
2. **Wait for approval** - Do not proceed until the user explicitly approves
3. **Accept modifications** - If the user suggests changes, present the revised version and wait for approval again

## Example

Bad: Posting a Slack message immediately after composing it

Good:
> Here's the message I'll post to Slack:
>
> ```
> [PR #123](link) is ready for review. It adds the new authentication flow.
> ```
>
> Should I post this?
