# Submit Bypass Request

Given a PR and a failed pipeline build, compose and post a bypass request to the **#pipeline-gated** Slack channel (`C03R4T6L6J2`).

The channel uses a Slack Workflow Builder form ("Submit a Bypass Request") that posts a structured message. Since the workflow form can't be triggered programmatically, this command posts a message in the identical format.

## Inputs

| Input | Description |
|-------|-------------|
| **prUrl** | *(optional)* Azure DevOps pull request URL. Resolved automatically from the current branch if omitted. |
| **buildId** | *(optional)* Azure DevOps build ID for the failed pipeline. Resolved from the PR's latest build if omitted. |
| **stabilityOwner** | *(optional)* Name or Slack handle of the stability owner to ping. |

## Conversation context

This command is often invoked after **triage-build** in the same conversation. When prior triage context is available (build ID, pipeline URL, test failures, commit summary), reuse it -- don't re-fetch from APIs. Steps below note where conversation context can substitute for a fresh lookup.

## Steps

### 1. Resolve the PR

Determine the PR using one of the following, in priority order:

1. **Explicit argument** -- the user provided a PR URL directly.
2. **Current branch** -- query Azure DevOps for an active PR from the current branch (`git branch --show-current`).

If neither yields a PR, ask the user and stop.

### 2. Resolve the failed pipeline

Determine the build using one of the following, in priority order:

1. **Conversation context** -- a build was already resolved by a prior triage-build in this conversation.
2. **Explicit argument** -- the user provided a build ID or pipeline URL directly.
3. **PR builds** -- fetch the latest build associated with the PR.

If the build succeeded, warn the user that there's nothing to bypass and confirm they want to proceed.

### 3. Gather context

Collect the information needed for the bypass request fields:

- **PR link** -- the Azure DevOps PR URL. The path segment is `_git` (with underscore): `https://dev.azure.com/<org>/<project>/_git/<repo>/pullrequest/<id>`.
- **Pipeline link** -- the Azure DevOps build results URL. The path segment is `_build` (with underscore): `https://dev.azure.com/<org>/<project>/_build/results?buildId=<id>&view=results`.
- **Which branch am I rebased on?** -- the rebase source is *not* necessarily the PR target branch. Determine it by checking which well-known branch the current branch diverged from most recently:
  1. Run `git merge-base HEAD origin/latest-stable` and `git merge-base HEAD origin/develop`.
  2. The merge-base with the *newer* commit (higher timestamp) is the rebase source -- the branch whose history this branch most recently incorporated.
  3. If the rebase source is `latest-stable` --> "Latest-stable"
  4. If the rebase source is `develop` --> "Develop"
  5. If neither merge-base is an ancestor of the other, or the branch targets a release branch, --> "A Release Branch"
  6. Otherwise, use the detected branch name verbatim.
- **What changed** -- if triage-build already ran, use its "Changes in This Build" section. Otherwise, use the PR description if available, or list the commit messages (`git log --oneline <target>..HEAD`).
- **What tests failed** -- if triage-build already ran, use its "Failed Tests" and "Error Summary" sections as the basis. Otherwise, fetch the build timeline to find the failed stage/job, then fetch test results. If the project uses Currents, search for the corresponding run by branch name and time window. Either way, summarise which tests failed and include Currents links where available.
- **Stability owner** -- the stability owner is the client FE user listed in the channel's topic. The topic follows the format `FE: <@USER_ID>` among other area entries. Resolve in priority order:
  1. **Explicit argument** -- the user provided a name or handle.
  2. **Channel topic** -- call `slack_list_channels` (the channel is in `SLACK_CHANNEL_IDS`), find `C03R4T6L6J2`, and extract the user ID from the `FE:` line in the `topic` field.
  3. **Ask the user** -- if the topic doesn't contain an `FE:` entry.

### 4. Compose the bypass request message

Format the message in Slack mrkdwn, matching the structure the workflow bot posts. The template below is **verbatim** -- field labels must be wrapped in `*` for bold rendering in Slack:

```
Submitted by: <@SLACK_USER_ID>
*PR Link:*
<PR_URL>
*Pipeline link*
<PIPELINE_URL>
*Which branch am I rebased on?*
<BRANCH>
*Roughly, what did I change in the PR?*
<CHANGES_SUMMARY>
*What tests failed, and why do I think it isn't due to my changes?*
<TEST_FAILURE_EXPLANATION>
*Ping the relevant stability owner*
<@STABILITY_OWNER_SLACK_ID>
```

The "Submitted by" field should be the current user. Look up the user's Slack ID by matching their name or email (from `git config user.email`) via `slack_get_users`.

Follow the **writing-style** skill (using the "Slack and casual messages" register) for the free-text fields (changes summary and test-failure explanation). Follow the **external-communications** skill: present the composed message to the user for approval before posting. The user may want to edit the test-failure explanation or change details.

### 5. Post to #pipeline-gated

Post the approved message to channel `C03R4T6L6J2` using `slack_post_message`.

Present a confirmation with a permalink to the posted message (`https://fundguard.slack.com/archives/C03R4T6L6J2/p<ts_without_dot>`).

### 6. Evolve

Follow the **continuous-improvement** skill.
