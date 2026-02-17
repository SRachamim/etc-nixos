---
name: require-message-approval
description: Require user approval before posting any content to external systems. Use whenever the agent is about to post content to any external system -- messaging platforms, code review tools, project management tools, or any other communication channel.
---

# Require Approval Before Posting

**NEVER** post any textual content to external systems without explicit user approval.

## Scope

This applies to ALL external communications, including but not limited to:

- Messages to team channels or direct messages (e.g., Slack)
- Pull request comments and descriptions (e.g., Azure DevOps, GitHub)
- Work item or issue updates and comments
- Discussion threads in any project management or collaboration tool

## Required Process

1. **Present the candidate text** - Show the complete message you intend to post, formatted as it will appear
2. **Wait for approval** - Do not proceed until the user explicitly approves
3. **Accept modifications** - If the user suggests changes, present the revised version and wait for approval again

## Example

Bad: Posting a message immediately after composing it

Good:
> Here's the message I'll post:
>
> ```
> [PR #123](link) is ready for review. It adds the new authentication flow.
> ```
>
> Should I post this?
