---
name: add-agent-behavior
description: Picks the customisation type for a requested agent behavior from its trigger (always-on instruction, output style, skill, MCP server, subagent, hook), then creates or amends it once under home/file/agents/ for native deployment to every supported agent. Use when adding new agent behavior to the dotfiles repository.
disable-model-invocation: true
---

# Add Agent Behavior

Given a description of desired behavior, pick the customisation type from the trigger that prompted it, and determine whether the behavior belongs in an existing artifact or a new one. Then create or amend it following existing conventions.

This skill is designed for the dotfiles repository that manages personal agent artifacts. Every artifact is authored once, agent-neutrally, under `home/file/agents/` (or `home/shared.nix` for MCP servers). Nix renders it into the native format of each supported agent: Claude Code, Cursor, Gemini CLI, Antigravity and Codex. An agent that lacks the type gets the closest type it supports. [reference.md](reference.md) maps every type to each agent's target.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate-g** skill. Steps 1--5 are classification and design -- a read-only phase keeps the focus on discussion rather than premature file creation. The user will switch back to Agent mode for creation (step 6).

### 1. Understand the request

Ask the user (or infer from context) what behavior they want to add. Gather:

- **What it does** -- the core task or workflow.
- **What prompted it** -- the recurring situation behind the request (a repeated correction, a prompt typed again, a pasted playbook, copied data). Step 2 classifies from this.
- **When it triggers** -- on explicit invocation, automatically during other work, on every matching event, or as a delegated sub-task.
- **What tools or integrations it needs** -- MCP servers, shell commands, file operations, external APIs.

### 2. Classify the customisation type

Match the prompting situation to a trigger. The table adapts Claude Code's [Build your setup over time](https://code.claude.com/docs/en/features-overview#build-your-setup-over-time) to agent-neutral types. Consider the user's request, but always evaluate independently -- the user may have asked for the wrong type.

| Trigger | Type | Generic source |
|---------|------|----------------|
| The agent gets a convention or command wrong twice | **Always-on instruction** | `home/file/agents/AGENTS.md` for every repo; the repo's `AGENTS.md` plus scoped workspace rules (**workspace-rules-g**) for one repo |
| The user keeps asking for shorter answers, more explanation, or the same format | **Output style** | `home/file/agents/output-styles/<name>.md` |
| The user keeps typing the same prompt to start a task | **Workflow skill** | `home/file/agents/skills/workflows/<name>/SKILL.md` |
| The user pastes the same playbook or procedure for the third time | **Knowledge skill**, or **shared skill** when other skills call it with inputs | `home/file/agents/skills/{knowledge,shared}/<name>/SKILL.md` |
| The user keeps copying data from a system the agent can't see | **MCP server** | `mcpServers` in `home/shared.nix` |
| A side task floods the conversation with output nobody references again | **Subagent** | `home/file/agents/subagents/<name>.md` |
| Something must happen every time, without asking | **Hook** | `home/file/agents/hooks/<name>/` |
| The agent reads many files to find where a symbol is defined or used | **Code intelligence** | See [reference.md](reference.md#code-intelligence-and-plugins); no generic pipeline |
| A second repository needs the same setup | Already covered: user-level `-g` artifacts reach every repository. Package a **plugin** only to distribute to other people | -- |

The same triggers tell you when to amend what exists: a repeated mistake is an instruction edit, and a workflow the user keeps tweaking by hand is a skill revision.

For the skill rows, pick the category:

| Type | When to use | Category directory | Location |
|------|-------------|-------------------|----------|
| **Workflow skill** | A discrete, user-invoked workflow with ordered steps (e.g. "review a PR", "create a work item", "plan a feature"). The user explicitly triggers it via `/skill-name`. Has `disable-model-invocation: true`. | `workflows/` | `home/file/agents/skills/workflows/<name>/SKILL.md` |
| **Knowledge skill** | Reusable knowledge or standards applied *within* other workflows. The agent decides when to load it based on context (e.g. "code review standards", "commit conventions", "external communications guidelines"). No `disable-model-invocation` flag. | `knowledge/` | `home/file/agents/skills/knowledge/<name>/SKILL.md` |
| **Shared skill** | A helper sub-workflow called programmatically by other skills. Has `disable-model-invocation: true`. Not meant for direct user invocation -- requires inputs from a calling skill. | `shared/` | `home/file/agents/skills/shared/<name>/SKILL.md` |

> **Note**: Agent-specific workspace rules (`.cursor/rules/*.mdc`, `.claude/rules/*.md`) are not managed by this skill. They are agent-specific artifacts that stay in their native directories. For workspace-level guidance that should reach all agents, use the repo-root `AGENTS.md` file. See the **workspace-rules-g** skill for the full trichotomy.

If the requested type doesn't match the best fit, explain the distinction and recommend the correct type. Present your reasoning and wait for the user to confirm before proceeding.

**Common misclassifications:**

- "I want a knowledge skill that reviews PRs" -> likely a **workflow skill** (it's an invoked workflow with steps, not passive knowledge).
- "I want a workflow skill for commit message format" -> likely a **knowledge skill** (it's reusable standards referenced by multiple skills, not a standalone workflow).
- "I want a skill to explore the codebase in parallel" -> likely a **subagent** (it benefits from isolation and parallel execution).
- "Add a rule to AGENTS.md to never edit `.env`" or "always run the formatter after edits" -> likely a **hook** (an instruction is a request; a hook is enforcement). Keep the instruction only as the hook's `fallback`.
- "Add to AGENTS.md: answer concisely" -> likely an **output style** when the user may want it off again; an always-on instruction only if it holds in every session.
- "Write a skill that queries our database" -> likely an **MCP server** for the connection, plus a knowledge skill only if the agent also needs the schema or query conventions.
- "I want a workflow skill for creating work items" -> check whether it's a **shared skill** if it requires inputs from a calling skill and isn't meant for direct user invocation.

### 3. Research prior art

Apply the **prior-art-research-g** skill. Search for established patterns and approaches for the behavior being added -- how agent frameworks, prompt engineering literature, and AI tooling ecosystems structure similar capabilities. Summarize relevant findings that should inform the artifact's design in step 5.

### 4. Survey existing artifacts

Before creating, check whether an existing artifact could absorb the requested behavior:

- List existing skills in `home/file/agents/skills/` (check all three category directories: `workflows/`, `knowledge/`, `shared/`).
- List existing subagents in `home/file/agents/subagents/`, hooks in `home/file/agents/hooks/`, and output styles in `home/file/agents/output-styles/`.
- Read `home/file/agents/AGENTS.md` and the `mcpServers` set in `home/shared.nix` for always-on instructions and MCP servers.

For each existing artifact, consider whether the new behavior is a natural extension of it -- even when the names or descriptions don't obviously overlap. Prefer amending an existing artifact over creating a new one. If amendment is viable, recommend it and wait for the user to confirm before proceeding.

### 5. Design the artifact

Apply the **artifact-naming-g** skill to choose the name.

#### For workflow skills

Follow the conventions observed in existing workflow skills:

- **Title**: `# <Skill Name>` -- imperative, action-oriented.
- **Description**: one paragraph explaining what the skill does.
- **Input section** (if applicable): describe accepted inputs and resolution priority.
- **Steps**: numbered `### N. <Step Name>` sections, imperative tone.
- **Delegation**: reference other skills by name in bold (e.g. "Apply the **code-review-g** skill").
- **Shared skills**: if the new skill shares steps with an existing workflow, extract the shared steps into a shared skill (like `create-work-item`) and reference it from both.
- **User approval**: require explicit approval before any external side effects.
- **Final step**: `### N. Evolve` -- "Follow the **capture-improvement-g** skill."
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

#### For subagents

Follow `home/file/agents/subagents/README.md`. Frame the body as the system prompt of a delegated agent:

- Frontmatter: `name`, `description` (what it does and when to delegate to it), `tier` (`volume`, `standard` or `frontier`, per the Model Routing table) and `readonly`.
- Specify what context the subagent receives.
- Specify what the subagent must return.
- Specify any constraints (read-only, no external side effects, etc.).
- When the subagent runs an existing skill (as `researcher` runs **work-item-context-g**), put the delegation rule in that skill -- "run this in the **<subagent>** subagent when subagents are available; otherwise, or when you are that subagent, follow the steps directly" -- rather than in each caller. Callers stay unchanged and the skill remains the single source.

#### For always-on instructions

- Add the line to the section of `AGENTS.md` it belongs to. Keep it to a rule the agent needs in every session; move reference material to a knowledge skill.
- For one repository, follow the **workspace-rules-g** skill: portable content in the repo's `AGENTS.md`, file-scoped content in each agent's rule directory.

#### For output styles

Follow `home/file/agents/output-styles/README.md`. The body defines the response itself (role, tone, length, format), not facts about the work.

#### For MCP servers

Add an entry to `mcpServers` in `home/shared.nix`, wrapping the server with `writeShellApplication` as the existing entries do. Secrets come from `~/.secrets`, never the Nix store. The set fans out to every agent's MCP config. Add a knowledge skill only when the agent also needs conventions for using the server.

#### For hooks

Follow `home/file/agents/hooks/README.md`: a `hook.json` with a generic `event`, `matcher` and `fallback`, and a `run.sh` that exits 2 to block. Check the event and tool-class rows in [reference.md](reference.md#hooks) to see which agents will get the `fallback` instead of the hook, and write the `fallback` as a standing instruction that approximates the hook.

#### Mode selection

Determine whether the artifact benefits from running in a specific mode. Not every artifact needs a mode directive -- knowledge skills are passive reference material applied within other workflows, and the calling workflow skill determines the mode.

| Mode | When to recommend | Mechanism |
|------|------------------|-----------|
| **Read-only / Plan** | The core work is read-only analysis, design, or review -- no writes until the user approves. | Add a Step 0 that requires the read-only mode following the **mode-gate-g** skill. Note when the user should switch back to the default mode for write actions. |
| **Debug** | The artifact investigates failures, bugs, or unexpected behaviour using runtime evidence. | Add a Step 0 that requires **Debug** mode following the **mode-gate-g** skill. |
| **Ask / Informational** | The artifact is purely informational -- it answers a question without any write actions. | Add a Step 0 that requires the informational mode following the **mode-gate-g** skill. |
| **Agent / Default** | The artifact creates, modifies, or deletes resources as a core part of its workflow. | No mode directive needed -- the default mode. |

If an artifact has distinct phases (e.g., analysis then implementation), use the restrictive mode for the analysis phase and note that the default mode is needed for the implementation phase. Apply the **mode-gate-g** skill at each transition point. The `plan` skill is a good example: it uses a read-only mode for steps 0--6, then the user switches to the default mode for step 7 (implementation).

#### Agent compatibility

Apply the **agent-compatibility-g** skill to verify the artifact will be portable. Key checks:

- Frontmatter uses base spec fields (`name`, `description`) plus accepted extensions (`disable-model-invocation`, `paths`).
- Body prose avoids hard-referencing agent-specific tools without a graceful degradation note.
- Cross-references to other skills use the portable `**skill-name**` bold pattern.
- If the skill references agent-specific tools, document what happens for agents that lack them.

#### Tooling enforcement

Apply the **tooling-enforcement-g** skill. If the target repository has testing or auditing tools (TypeScript compiler, linters, test frameworks, CI checks, pre-commit hooks), evaluate whether the convention the new artifact introduces can also be enforced mechanically -- and include or recommend the enforcement change alongside the artifact.

#### Architectural alignment

Apply the **architect-thinking-g** skill and the **decision-priorities-g** skill to evaluate whether the new artifact:

- Preserves options and avoids locking in decisions unnecessarily.
- Reduces friction and enables faster change (rate of change).
- Starts from a concrete use case (use before reuse).
- Includes feedback mechanisms (e.g. the Evolve step, validation steps).
- Makes the right path the easy path (governance through inception).

### 6. Create the artifact

Write the files immediately at the generic source path from step 2 (for skills: `<category>/<name>/SKILL.md` and any supporting files under `home/file/agents/skills/`).

If the type has no generic pipeline yet, build one in `home/programs/agents/default.nix` in the same change, and add its row to [reference.md](reference.md):

- Author the source agent-neutrally under `home/file/agents/<type>/`, with a README describing the format.
- Render it into the native format of every agent that supports the type.
- For every agent that doesn't, render the **closest type it does support** (for example, an always-on instruction for a hook, a user-invoked skill for an output style). When no reachable type exists, emit a Home Manager `warnings` entry naming the dropped artifact.

### 7. Verify

- Confirm the file was created at the correct path under the right category directory.
- Verify the YAML frontmatter parses correctly.
- For any type other than a skill, build the Home Manager files and inspect each agent's target from [reference.md](reference.md), including fallbacks:

  ```sh
  nix build --no-link --print-out-paths '.#darwinConfigurations.macbook.config.home-manager.users."sahar.rachamim".home-files'
  nix eval --json '.#darwinConfigurations.macbook.config.home-manager.users."sahar.rachamim".warnings'
  ```

  For a hook, also pipe sample event JSON into the rendered command and check the exit code and output.

  Before handing over, check that no newly managed target already exists as an unmanaged file, which makes `switch` stop with "would be clobbered". This happens when a tool wrote the file itself, e.g. `workmux setup --hooks` writing `~/.codex/hooks.json`:

  ```sh
  cd <home-files-path> && find . \( -type l -o -type f \) | sed 's|^\./||' |
    while read -r f; do [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ] && echo "unmanaged: $f"; done
  ```

  For each hit, read the file. Declare its content in Nix (merging with other contributors through an option, as `agents.codex.hooks` does) and set `force = true` for the takeover, or ask the user when the content is not reproducible. Then tell the user to run `switch`, and to approve new or changed Codex hooks with `/hooks`.
- Check that all referenced skills exist.
- Apply the **agent-compatibility-g** skill -- verify frontmatter portability, check for hard agent-specific references, confirm the canonical source path is `home/file/agents/`.

### 8. Evolve

Follow the **capture-improvement-g** skill.
