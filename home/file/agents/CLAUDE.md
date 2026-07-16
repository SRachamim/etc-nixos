@~/.agents/AGENTS.md

## Available Skills

Skills are at `~/.claude/skills/`. Read the SKILL.md file before using a skill.

### Workflow skills (invoke with `/skill-name`)

| Command | Title | Path |
|---------|-------|------|
| `/activate-work-item` | Activate Work Item | `~/.claude/skills/workflows/activate-work-item/SKILL.md` |
| `/answer-slack` | Answer Slack | `~/.claude/skills/workflows/answer-slack/SKILL.md` |
| `/block-work-item` | Block Work Item | `~/.claude/skills/workflows/block-work-item/SKILL.md` |
| `/checkout-worktree` | Checkout Worktree | `~/.claude/skills/workflows/checkout-worktree/SKILL.md` |
| `/close-worktree` | Close Worktree | `~/.claude/skills/workflows/close-worktree/SKILL.md` |
| `/commit-and-push` | Commit and Push | `~/.claude/skills/workflows/commit-and-push/SKILL.md` |
| `/compare-approaches` | Compare Approaches | `~/.claude/skills/workflows/compare-approaches/SKILL.md` |
| `/create-bug` | Create Bug | `~/.claude/skills/workflows/create-bug/SKILL.md` |
| `/create-microservice` | Create Microservice | `~/.claude/skills/workflows/create-microservice/SKILL.md` |
| `/create-task` | Create Task | `~/.claude/skills/workflows/create-task/SKILL.md` |
| `/debug` | Debug | `~/.claude/skills/workflows/debug/SKILL.md` |
| `/defer-fix` | Defer Fix | `~/.claude/skills/workflows/defer-fix/SKILL.md` |
| `/design-microservice-system` | Design Microservice System | `~/.claude/skills/workflows/design-microservice-system/SKILL.md` |
| `/estimate-work-item` | Estimate Work Item | `~/.claude/skills/workflows/estimate-work-item/SKILL.md` |
| `/evolve-microservice-api` | Evolve Microservice API | `~/.claude/skills/workflows/evolve-microservice-api/SKILL.md` |
| `/extract-microservice` | Extract Microservice | `~/.claude/skills/workflows/extract-microservice/SKILL.md` |
| `/investigate-incident` | Investigate Incident | `~/.claude/skills/workflows/investigate-incident/SKILL.md` |
| `/list-closeable-worktrees` | List Closeable Worktrees | `~/.claude/skills/workflows/list-closeable-worktrees/SKILL.md` |
| `/plan` | Plan | `~/.claude/skills/workflows/plan/SKILL.md` |
| `/prd-intake` | PRD Intake | `~/.claude/skills/workflows/prd-intake/SKILL.md` |
| `/prune-merged` | Prune Merged Branches | `~/.claude/skills/workflows/prune-merged/SKILL.md` |
| `/reproduce-bug` | Reproduce Bug | `~/.claude/skills/workflows/reproduce-bug/SKILL.md` |
| `/request-environment-access` | Request Environment Access | `~/.claude/skills/workflows/request-environment-access/SKILL.md` |
| `/retrospective` | Retrospective | `~/.claude/skills/workflows/retrospective/SKILL.md` |
| `/review-microservice-architecture` | Review Microservice Architecture | `~/.claude/skills/workflows/review-microservice-architecture/SKILL.md` |
| `/review-plan` | Review Plan | `~/.claude/skills/workflows/review-plan/SKILL.md` |
| `/review-pr-fixes` | Review Fixes | `~/.claude/skills/workflows/review-pr-fixes/SKILL.md` |
| `/review-pr` | Review Pull Request | `~/.claude/skills/workflows/review-pr/SKILL.md` |
| `/set-igw` | Set IGW | `~/.claude/skills/workflows/set-igw/SKILL.md` |
| `/set-ports` | Set Ports | `~/.claude/skills/workflows/set-ports/SKILL.md` |
| `/submit-bypass-request` | Submit Bypass Request | `~/.claude/skills/workflows/submit-bypass-request/SKILL.md` |
| `/submit-feature` | Submit Feature for Review | `~/.claude/skills/workflows/submit-feature/SKILL.md` |
| `/trace-pr-comments` | Trace PR Comments | `~/.claude/skills/workflows/trace-pr-comments/SKILL.md` |
| `/triage-build` | Triage Build | `~/.claude/skills/workflows/triage-build/SKILL.md` |
| `/triage` | Triage | `~/.claude/skills/workflows/triage/SKILL.md` |

### Knowledge skills (loaded by context)

| Skill | Title | Path |
|-------|-------|------|
| agent-compatibility | Agent Compatibility | `~/.claude/skills/knowledge/agent-compatibility/SKILL.md` |
| architect-thinking | Architect Thinking | `~/.claude/skills/knowledge/architect-thinking/SKILL.md` |
| artifact-discovery | Artifact Discovery | `~/.claude/skills/knowledge/artifact-discovery/SKILL.md` |
| browser-bug-reproduction | Browser Bug Reproduction | `~/.claude/skills/knowledge/browser-bug-reproduction/SKILL.md` |
| building-microservices | Building Microservices | `~/.claude/skills/knowledge/building-microservices/SKILL.md` |
| code-review | Code Review Standards | `~/.claude/skills/knowledge/code-review/SKILL.md` |
| commit-conventions | Commit Conventions | `~/.claude/skills/knowledge/commit-conventions/SKILL.md` |
| context-engineering | Context Engineering | `~/.claude/skills/knowledge/context-engineering/SKILL.md` |
| continuous-improvement | Continuous Improvement | `~/.claude/skills/knowledge/continuous-improvement/SKILL.md` |
| conversation-naming | Conversation Naming | `~/.claude/skills/knowledge/conversation-naming/SKILL.md` |
| decision-priorities | Decision Priorities | `~/.claude/skills/knowledge/decision-priorities/SKILL.md` |
| design-lenses | Design Lenses | `~/.claude/skills/knowledge/design-lenses/SKILL.md` |
| estimation | Estimation | `~/.claude/skills/knowledge/estimation/SKILL.md` |
| event-driven-automations | Event-Driven Automations | `~/.claude/skills/knowledge/event-driven-automations/SKILL.md` |
| external-communications | External Communications | `~/.claude/skills/knowledge/external-communications/SKILL.md` |
| fgrepo-artifact-precedence | fgrepo Artifact Precedence | `~/.claude/skills/knowledge/fgrepo-artifact-precedence/SKILL.md` |
| functional-typescript | Functional TypeScript Standards | `~/.claude/skills/knowledge/functional-typescript/SKILL.md` |
| gitflow-branching | Gitflow Branching | `~/.claude/skills/knowledge/gitflow-branching/SKILL.md` |
| incident-response | Incident Response | `~/.claude/skills/knowledge/incident-response/SKILL.md` |
| mode-gate | Mode Gate | `~/.claude/skills/knowledge/mode-gate/SKILL.md` |
| nix-shell-direnv | Nix Shell / direnv Awareness | `~/.claude/skills/knowledge/nix-shell-direnv/SKILL.md` |
| objective-communication | Objective Communication | `~/.claude/skills/knowledge/objective-communication/SKILL.md` |
| plan-execution | Plan Execution | `~/.claude/skills/knowledge/plan-execution/SKILL.md` |
| prior-art-research | Prior Art Research | `~/.claude/skills/knowledge/prior-art-research/SKILL.md` |
| refactoring | Refactoring | `~/.claude/skills/knowledge/refactoring/SKILL.md` |
| test-driven-development | Test-Driven Development | `~/.claude/skills/knowledge/test-driven-development/SKILL.md` |
| tooling-enforcement | Tooling Enforcement | `~/.claude/skills/knowledge/tooling-enforcement/SKILL.md` |
| work-item-context | Work Item Context | `~/.claude/skills/knowledge/work-item-context/SKILL.md` |
| workspace-rules | Workspace Rules | `~/.claude/skills/knowledge/workspace-rules/SKILL.md` |
| worktree-layout | Worktree Layout | `~/.claude/skills/knowledge/worktree-layout/SKILL.md` |
| writing-style | Writing Style | `~/.claude/skills/knowledge/writing-style/SKILL.md` |
