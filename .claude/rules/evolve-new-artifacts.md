---
paths: home/file/agents/skills/**/SKILL.md
---

# Evolve new artifacts

When creating or modifying a skill or subagent prompt in this repository:

- Add a final step that references the **continuous-improvement** skill, e.g.:

```
### N. Evolve

Follow the **continuous-improvement** skill.
```

- For workflow skills that delegate to a shared skill (like `create-work-item`), the shared skill carries the step -- don't duplicate it in the caller.

- Consider whether the artifact benefits from a specific interaction mode (read-only, debug, informational). If it does, add a Step 0 that requires the mode following the **mode-gate** skill.

- Apply the **agent-compatibility** skill to verify the artifact stays portable across agents. Check the portability checklist -- especially if the skill references agent-specific tools or paths.
