# Add Cursor Behavior

Given a description of desired behavior, determine whether it belongs in an existing artifact or a new one. Then create or amend the appropriate artifact (command, skill, or subagent prompt) under `home/file/cursor/` following existing conventions.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. Steps 1--4 are classification and design -- Plan mode keeps the focus on discussion rather than premature file creation. The user will switch back to Agent mode for creation (step 5).

### 1. Understand the request

Ask the user (or infer from context) what behavior they want to add. Gather:

- **What it does** -- the core task or workflow.
- **When it triggers** -- on explicit invocation, automatically during other work, or as a delegated sub-task.
- **What tools or integrations it needs** -- MCP servers, shell commands, file operations, external APIs.

### 2. Classify the artifact type

Determine which artifact type fits best. Consider the user's request, but always evaluate independently -- the user may have asked for the wrong type.

| Type | When to use | Location |
|------|-------------|----------|
| **Command** | A discrete, user-invoked workflow with ordered steps (e.g. "review a PR", "create a work item", "plan a feature"). The user explicitly triggers it. | `home/file/cursor/commands/<name>.md` |
| **Skill** | Reusable knowledge or standards applied *within* other workflows. Not invoked directly -- referenced by commands and other skills (e.g. "code review standards", "commit conventions", "external communications guidelines"). | `home/file/cursor/skills/<name>/SKILL.md` |
| **Subagent prompt** | A prompt template for a delegated sub-task that runs in a separate agent context. Use when the work is parallelizable, needs isolation, or benefits from a dedicated tool set. | `home/file/cursor/subagents/<name>.md` |

> **Note**: Cursor rules (`.cursor/rules/*.mdc`) are not a supported artifact type. All agent behaviour is managed through commands, skills, and subagent prompts under `home/file/cursor/`.

If the requested type doesn't match the best fit, explain the distinction and recommend the correct type. Present your reasoning and wait for the user to confirm before proceeding.

**Common misclassifications:**

- "I want a skill that reviews PRs" → likely a **command** (it's an invoked workflow with steps, not passive knowledge).
- "I want a command for commit message format" → likely a **skill** (it's reusable standards referenced by multiple commands, not a standalone workflow).
- "I want a command to explore the codebase in parallel" → likely a **subagent prompt** (it benefits from isolation and parallel execution).

### 3. Survey existing artifacts

Before creating, check whether an existing artifact could absorb the requested behavior:

- List existing commands in `home/file/cursor/commands/`.
- List existing skills in `home/file/cursor/skills/`.
- List existing subagent prompts in `home/file/cursor/subagents/` (if the directory exists).

For each existing artifact, consider whether the new behavior is a natural extension of it -- even when the names or descriptions don't obviously overlap. Prefer amending an existing artifact over creating a new one. If amendment is viable, recommend it and wait for the user to confirm before proceeding.

### 4. Design the artifact

#### For commands

Follow the conventions observed in existing commands:

- **Title**: `# <Command Name>` -- imperative, action-oriented.
- **Description**: one paragraph explaining what the command does.
- **Input section** (if applicable): describe accepted inputs and resolution priority.
- **Steps**: numbered `### N. <Step Name>` sections, imperative tone.
- **Delegation**: reference skills by name in bold (e.g. "Apply the **code-review** skill").
- **Shared commands**: if the new command shares steps with an existing command, extract the shared steps into a separate file (like `create-work-item.md`) and reference it from both.
- **User approval**: require explicit approval before any external side effects.
- **Final step**: `### N. Evolve` -- "Follow the **continuous-improvement** skill."

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

#### Cursor mode selection

Determine whether the artifact benefits from running in a specific Cursor mode. Not every artifact needs a mode directive -- skills are passive reference material applied within other workflows, and the calling command determines the mode.

| Mode | When to recommend | Mechanism |
|------|------------------|-----------|
| **Plan** | The core work is read-only analysis, design, or review -- no writes until the user approves. | Add a Step 0 that requires **Plan** mode following the **mode-gate** skill. Note when the user should switch back to Agent mode for write actions. |
| **Debug** | The artifact investigates failures, bugs, or unexpected behaviour using runtime evidence. | Add a Step 0 that requires **Debug** mode following the **mode-gate** skill. |
| **Ask** | The artifact is purely informational -- it answers a question without any write actions. | Add a Step 0 that requires **Ask** mode following the **mode-gate** skill. |
| **Agent** | The artifact creates, modifies, or deletes resources as a core part of its workflow. | No mode directive needed -- Agent is the default. |

If an artifact has distinct phases (e.g., analysis then implementation), use the restrictive mode for the analysis phase and note that Agent mode is needed for the implementation phase. Apply the **mode-gate** skill at each transition point. The `plan` command is a good example: it uses Plan mode for steps 0--6, then the user switches to Agent mode for step 7 (implementation).

#### Architectural alignment

Apply the **architect-thinking** skill and the **decision-priorities** skill to evaluate whether the new artifact:

- Preserves options and avoids locking in decisions unnecessarily.
- Reduces friction and enables faster change (rate of change).
- Starts from a concrete use case (use before reuse).
- Includes feedback mechanisms (e.g. the Evolve step, validation steps).
- Makes the right path the easy path (governance through inception).

### 5. Create the artifact

Write the file immediately. If the artifact is a skill, create the directory structure (`<name>/SKILL.md` and any supporting files).

### 6. Verify

- Confirm the file was created at the correct path.
- If it's a skill, verify the YAML frontmatter parses correctly.
- Check that all referenced skills and commands exist.

### 7. Evolve

Follow the **continuous-improvement** skill.
