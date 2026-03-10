# Block Work Item

Mark an Azure DevOps work item as **Blocked** and record the blocking dependency by linking it to its predecessor (the blocker).

## Input

The user specifies two work items:

| Input | Description |
|-------|-------------|
| **blocked ID** | The work item that cannot proceed. |
| **blocker ID** | The work item that must be completed first (the predecessor). |

The user may phrase this as "block 12345 on 12346", "12345 is blocked by 12346", or similar. Infer which is which from context. If ambiguous, ask.

## Steps

### 1. Resolve both work items

Fetch both work items in parallel using `wit_get_work_item` (with `expand: "relations"` on the blocked item so existing links are visible).

If either ID does not exist, inform the user and stop.

### 2. Validate

- If the blocked work item is already in the **Blocked** state *and* already has a predecessor link to the blocker, inform the user that the relationship already exists and stop.
- If a predecessor link to the blocker already exists but the state is not **Blocked**, proceed with only the state change (step 3).
- If the state is already **Blocked** but no predecessor link exists, proceed with only the link (step 4).

### 3. Transition to Blocked

Call `wit_update_work_item` with:

- **id**: the blocked work item's ID
- **updates**:

```json
[
  { "op": "add", "path": "/fields/System.State", "value": "Blocked" }
]
```

Skip this step if the work item is already in the **Blocked** state.

### 4. Link as predecessor

Call `wit_work_items_link` with:

- **project**: `FundGuard`
- **updates**:

```json
[
  {
    "id": <blocked ID>,
    "linkToId": <blocker ID>,
    "type": "predecessor"
  }
]
```

Skip this step if the predecessor link already exists.

### 5. Confirm

Print:

- Blocked work item: **ID**, **title**, new **state**.
- Blocker (predecessor): **ID**, **title**.
- A direct link to the blocked work item in Azure DevOps.

### 6. Evolve

Follow the **continuous-improvement** skill.
