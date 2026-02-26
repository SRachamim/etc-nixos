# Add Cursor Artifact

Given a description of desired behavior, determine the correct artifact type (command, skill, or subagent prompt), then create it under `home/file/cursor/` following existing conventions.

## Steps

### 1. Understand the request

Ask the user (or infer from context) what behavior they want to add. Gather:

- **What it does** — the core task or workflow.
- **When it triggers** — on explicit invocation, automatically during other work, or as a delegated sub-task.
- **What tools or integrations it needs** — MCP servers, shell commands, file operations, external APIs.

### 2. Classify the artifact type

Determine which artifact type fits best. Consider the user's request, but always evaluate independently — the user may have asked for the wrong type.

| Type | When to use | Location |
|------|-------------|----------|
| **Command** | A discrete, user-invoked workflow with ordered steps (e.g. "review a PR", "create a work item", "plan a feature"). The user explicitly triggers it. | `home/file/cursor/commands/<name>.md` |
| **Skill** | Reusable knowledge or standards applied *within* other workflows. Not invoked directly — referenced by commands and other skills (e.g. "code review standards", "commit conventions", "external communications guidelines"). | `home/file/cursor/skills/<name>/SKILL.md` |
| **Subagent prompt** | A prompt template for a delegated sub-task that runs in a separate agent context. Use when the work is parallelizable, needs isolation, or benefits from a dedicated tool set. | `home/file/cursor/subagents/<name>.md` |

If the requested type doesn't match the best fit, explain the distinction and recommend the correct type. Present your reasoning and wait for the user to confirm before proceeding.

**Common misclassifications:**

- "I want a skill that reviews PRs" → likely a **command** (it's an invoked workflow with steps, not passive knowledge).
- "I want a command for commit message format" → likely a **skill** (it's reusable standards referenced by multiple commands, not a standalone workflow).
- "I want a command to explore the codebase in parallel" → likely a **subagent prompt** (it benefits from isolation and parallel execution).

### 3. Survey existing artifacts

Before creating, check for overlap:

- List existing commands in `home/file/cursor/commands/`.
- List existing skills in `home/file/cursor/skills/`.
- List existing subagent prompts in `home/file/cursor/subagents/` (if the directory exists).

If the new artifact overlaps with an existing one, suggest extending or modifying the existing artifact instead of creating a duplicate.

### 4. Design the artifact

#### For commands

Follow the conventions observed in existing commands:

- **Title**: `# <Command Name>` — imperative, action-oriented.
- **Description**: one paragraph explaining what the command does.
- **Input section** (if applicable): describe accepted inputs and resolution priority.
- **Steps**: numbered `### N. <Step Name>` sections, imperative tone.
- **Delegation**: reference skills by name in bold (e.g. "Apply the **code-review** skill").
- **Shared commands**: if the new command shares steps with an existing command, extract the shared steps into a separate file (like `create-work-item.md`) and reference it from both.
- **User approval**: require explicit approval before any external side effects.
- **Final step**: `### N. Evolve` — "Follow the **continuous-improvement** skill."

#### For skills

Follow the **create-skill** skill for structure and best practices. Additionally, match these repository conventions:

- YAML frontmatter with `name` and `description`.
- `name`: lowercase, hyphens, max 64 characters.
- `description`: third-person, includes WHAT and WHEN, max 1024 characters.
- Body under 500 lines; use `reference.md` for detailed material.
- End with an Evolve section only if the skill describes a workflow with a terminal step.

#### For subagent prompts

Follow the conventions for commands (title, description, steps) but frame the instructions as a prompt for a delegated agent:

- Specify what context the subagent receives.
- Specify what the subagent must return.
- Specify any constraints (read-only, no external side effects, etc.).

### 5. Create the artifact

Write the file immediately. If the artifact is a skill, create the directory structure (`<name>/SKILL.md` and any supporting files).

### 6. Verify

- Confirm the file was created at the correct path.
- If it's a skill, verify the YAML frontmatter parses correctly.
- Check that all referenced skills and commands exist.

### 7. Evolve

Follow the **continuous-improvement** skill.
