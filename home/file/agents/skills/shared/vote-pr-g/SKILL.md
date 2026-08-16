---
name: vote-pr-g
description: Casts a vote on an Azure DevOps pull request, recovering from the "valid reviewer" error by adding the current user as a reviewer before retrying. Called by review-pr-g and review-pr-fixes-g — not invoked directly by the user.
disable-model-invocation: true
---

# Vote PR

Cast a vote on an Azure DevOps pull request via `repo_vote_pull_request`, with automatic recovery when the API rejects the call because the user is not yet a reviewer.

This file is a shared skill. It is referenced by the **review-pr-g** and **review-pr-fixes-g** skills, which supply the PR identity and desired vote value.

## Inputs (provided by the calling skill)

| Input | Description |
| ----- | ----------- |
| **pullRequestId** | The numeric PR ID |
| **repositoryId** | The repository ID or name |
| **vote** | Vote value: `approve` (10), `approve-with-suggestions` (5), `wait` (-5), `reject` (-10) |

## Steps

### 1. Cast the vote

Call `repo_vote_pull_request` with the PR ID, repository, and vote value.

If the call succeeds, the vote is recorded -- return success to the caller.

### 2. Recover from "valid reviewer" error

If step 1 fails with an error containing **"A valid reviewer must be supplied"**:

1. Call `core_get_identity_ids` with the current user's email to obtain their identity GUID.
2. Call `repo_update_pull_request_reviewers` with that GUID and `action: "add"` to register the user as a reviewer on the PR.
3. Retry `repo_vote_pull_request` with the same parameters as step 1.

If the retry succeeds, return success to the caller.

### 3. Handle persistent failure

If the retry in step 2 also fails, or if step 1 failed with a different error:

- Report the error message to the user.
- Do not retry further -- stop and let the user intervene.
