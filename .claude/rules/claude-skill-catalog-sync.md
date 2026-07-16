---
globs: home/file/agents/skills/**/SKILL.md, home/file/agents/CLAUDE.md
---

When adding, removing, or renaming a skill under `home/file/agents/skills/`, update the skill catalog table in `home/file/agents/CLAUDE.md` to match. Each workflow skill needs a row in the "Workflow skills" table with its `/command`, title (from the `# Title` heading in SKILL.md), and path. Each knowledge skill needs a row in the "Knowledge skills" table. Apply the catalog update in the same commit as the skill change.
