---
name: add-agent-behavior
description: Classifies and creates or amends agent artifacts (skills or subagent prompts) under home/file/agents/ from a behavior description. Use when adding new agent behavior to the dotfiles repository that deploys to ~/.agents/, ~/.cursor/, ~/.claude/, and ~/.gemini/.
disable-model-invocation: true
---

# Add Agent Behavior

Given a description of desired behavior, determine whether it belongs in an existing artifact or a new one. Then create or amend the appropriate artifact (skill or subagent prompt) under `home/file/agents/` following existing conventions.

This skill is designed for the dotfiles repository that manages personal agent artifacts. The artifacts it creates are deployed via Nix to multiple agent directories (`~/.agents/skills/`, `~/.cursor/skills/`, `~/.claude/skills/`, `~/.gemini/skills/`) and available across all repositories and all agents.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. Steps 1--4 are classification and design -- a read-only phase keeps the focus on discussion rather than premature file creation. The user will switch back to Agent mode for creation (step 5).

### 1. Understand the request

Ask the user (or infer from context) what behavior they want to add. Gather:

- **What it does** -- the core task or workflow.
- **When it triggers** -- on explicit invocation, automatically during other work, or as a delegated sub-task.
- **What tools or integrations it needs** -- MCP servers, shell commands, file operations, external APIs.

### 2. Classify the artifact type

Determine which artifact type fits best. Consider the user's request, but always evaluate independently -- the user may have asked for the wrong type.

| Type | When to use | Category directory | Location |
|------|-------------|-------------------|----------|
| **Workflow skill** | A discrete, user-invoked workflow with ordered steps (e.g. "review a PR", "create a work item", "plan a feature"). The user explicitly triggers it via `/skill-name`. Has `disable-model-invocation: true`. | `workflows/` | `home/file/agents/skills/workflows/<name>/SKILL.md` |
| **Knowledge skill** | Reusable knowledge or standards applied *within* other workflows. The agent decides when to load it based on context (e.g. "code review standards", "commit conventions", "external communications guidelines"). No `disable-model-invocation` flag. | `knowledge/` | `home/file/agents/skills/knowledge/<name>/SKILL.md` |
| **Shared skill** | A helper sub-workflow called programmatically by other skills. Has `disable-model-invocation: true`. Not meant for direct user invocation -- requires inputs from a calling skill. | `shared/` | `home/file/agents/skills/shared/<name>/SKILL.md` |
| **Subagent prompt** | A prompt template for a delegated sub-task that runs in a separate agent context. Use when the work is parallelizable, needs isolation, or benefits from a dedicated tool set. | -- | `home/file/agents/subagents/<name>.md` |

> **Note**: Agent-specific workspace rules (`.cursor/rules/*.mdc`, `.claude/rules/*.md`) are not managed by this skill. They are agent-specific artifacts that stay in their native directories. For workspace-level guidance that should reach all agents, use the repo-root `AGENTS.md` file. See the **workspace-rules** skill for the full trichotomy.

If the requested type doesn't match the best fit, explain the distinction and recommend the correct type. Present your reasoning and wait for the user to confirm before proceeding.

**Common misclassifications:**

- "I want a knowledge skill that reviews PRs" -> likely a **workflow skill** (it's an invoked workflow with steps, not passive knowledge).
- "I want a workflow skill for commit message format" -> likely a **knowledge skill** (it's reusable standards referenced by multiple skills, not a standalone workflow).
- "I want a skill to explore the codebase in parallel" -> likely a **subagent prompt** (it benefits from isolation and parallel execution).
- "I want a workflow skill for creating work items" -> check whether it's a **shared skill** if it requires inputs from a calling skill and isn't meant for direct user invocation.

### 3. Survey existing artifacts

Before creating, check whether an existing artifact could absorb the requested behavior:

- List existing skills in `home/file/agents/skills/` (check all three category directories: `workflows/`, `knowledge/`, `shared/`).
- List existing subagent prompts in `home/file/agents/subagents/` (if the directory exists).

For each existing artifact, consider whether the new behavior is a natural extension of it -- even when the names or descriptions don't obviously overlap. Prefer amending an existing artifact over creating a new one. If amendment is viable, recommend it and wait for the user to confirm before proceeding.

### 4. Design the artifact

#### For workflow skills

Follow the conventions observed in existing workflow skills:

- **Title**: `# <Skill Name>` -- imperative, action-oriented.
- **Description**: one paragraph explaining what the skill does.
- **Input section** (if applicable): describe accepted inputs and resolution priority.
- **Steps**: numbered `### N. <Step Name>` sections, imperative tone.
- **Delegation**: reference other skills by name in bold (e.g. "Apply the **code-review** skill").
- **Shared skills**: if the new skill shares steps with an existing workflow, extract the shared steps into a shared skill (like `create-work-item`) and reference it from both.
- **User approval**: require explicit approval before any external side effects.
- **Final step**: `### N. Evolve` -- "Follow the **continuous-improvement** skill."
- **Frontmatter**: must include `disable-model-invocation: true`.
- **Category directory**: place under `workflows/`.

#### For knowledge skills

Follow the **create-skill** skill for structure and best practices. Additionally, match these repository conventions:

- YAML frontmatter with `name` and `description` (no `disable-model-invocation` flag).
- `name`: lowercase, hyphens, max 64 characters.
- `description`: third-person, includes WHAT and WHEN, max 1024 characters.
- Body under 500 lines; use `reference.md` for detailed material.
- End with an Evolve section only if the skill describes a workflow with a terminal step.
- **Category directory**: place under `knowledge/`.

#### For shared skills

Follow the same conventions as workflow skills, but:

- Frame the instructions as steps that receive inputs from a calling skill.
- Include `disable-model-invocation: true` in frontmatter.
- **Category directory**: place under `shared/`.

#### For subagent prompts

Follow the conventions for commands (title, description, steps) but frame the instructions as a prompt for a delegated agent:

- Specify what context the subagent receives.
- Specify what the subagent must return.
- Specify any constraints (read-only, no external side effects, etc.).

#### Mode selection

Determine whether the artifact benefits from running in a specific mode. Not every artifact needs a mode directive -- knowledge skills are passive reference material applied within other workflows, and the calling workflow skill determines the mode.

| Mode | When to recommend | Mechanism |
|------|------------------|-----------|
| **Read-only / Plan** | The core work is read-only analysis, design, or review -- no writes until the user approves. | Add a Step 0 that requires the read-only mode following the **mode-gate** skill. Note when the user should switch back to the default mode for write actions. |
| **Debug** | The artifact investigates failures, bugs, or unexpected behaviour using runtime evidence. | Add a Step 0 that requires **Debug** mode following the **mode-gate** skill. |
| **Ask / Informational** | The artifact is purely informational -- it answers a question without any write actions. | Add a Step 0 that requires the informational mode following the **mode-gate** skill. |
| **Agent / Default** | The artifact creates, modifies, or deletes resources as a core part of its workflow. | No mode directive needed -- the default mode. |

If an artifact has distinct phases (e.g., analysis then implementation), use the restrictive mode for the analysis phase and note that the default mode is needed for the implementation phase. Apply the **mode-gate** skill at each transition point. The `plan` skill is a good example: it uses a read-only mode for steps 0--6, then the user switches to the default mode for step 7 (implementation).

#### Agent compatibility

Apply the **agent-compatibility** skill to verify the artifact will be portable. Key checks:

- Frontmatter uses base spec fields (`name`, `description`) plus accepted extensions (`disable-model-invocation`, `paths`).
- Body prose avoids hard-referencing agent-specific tools without a graceful degradation note.
- Cross-references to other skills use the portable `**skill-name**` bold pattern.
- If the skill references agent-specific tools, document what happens for agents that lack them.

#### Tooling enforcement

Apply the **tooling-enforcement** skill. If the target repository has testing or auditing tools (TypeScript compiler, linters, test frameworks, CI checks, pre-commit hooks), evaluate whether the convention the new artifact introduces can also be enforced mechanically -- and include or recommend the enforcement change alongside the artifact.

#### Architectural alignment

Apply the **architect-thinking** skill and the **decision-priorities** skill to evaluate whether the new artifact:

- Preserves options and avoids locking in decisions unnecessarily.
- Reduces friction and enables faster change (rate of change).
- Starts from a concrete use case (use before reuse).
- Includes feedback mechanisms (e.g. the Evolve step, validation steps).
- Makes the right path the easy path (governance through inception).

### 5. Create the artifact

Write the file immediately. Create the directory structure (`<category>/<name>/SKILL.md` and any supporting files) under `home/file/agents/skills/`.

### 6. Verify

- Confirm the file was created at the correct path under the right category directory.
- Verify the YAML frontmatter parses correctly.
- Check that all referenced skills exist.
- Apply the **agent-compatibility** skill -- verify frontmatter portability, check for hard agent-specific references, confirm the canonical source path is `home/file/agents/`.

### 7. Evolve

Follow the **continuous-improvement** skill.
