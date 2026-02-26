# Create Task

Create a new **Task** work item in Azure DevOps, assigned to the current user on the current iteration.

## Steps

### 1. Understand the intent

The user provides a free-form description of what they need to do. If the description is too vague to produce a meaningful title (e.g. just a single ambiguous word), ask a clarifying question. Otherwise, proceed — do not ask the user to fill in structured fields.

### 2. Craft the title and description

From the user's input, produce:

- **Title** — a concise, action-oriented summary. Start with a verb (e.g. "Add …", "Implement …", "Update …", "Investigate …"). Keep it under 80 characters.
- **Description** — a short paragraph expanding on the task. Structure it as:
  - **Goal**: what the task achieves.
  - **Context**: why it matters or what triggered it (if apparent from the user's input).
  - **Scope**: any boundaries or constraints mentioned.

  Omit sections the user's input doesn't cover — don't invent details.

### 3. Create the work item

Follow the **create-work-item** shared instructions with:

- **workItemType**: `Task`
- **title**: the crafted title from step 2
- **typeFields**:

| Field | Value | Condition |
|-------|-------|-----------|
| `System.Description` | The crafted description (HTML format) | Always |
