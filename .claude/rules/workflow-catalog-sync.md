---
description: Keep the workflow catalog and follow-up-map-g in sync when workflow skills change
globs:
  - home/file/agents/skills/**/SKILL.md
---

# Workflow catalog sync

When a workflow skill (`home/file/agents/skills/workflows/`) is added, removed, or renamed, verify these artifacts stay consistent:

1. **`home/file/agents/skills/knowledge/workflow-catalog-g/SKILL.md`** -- the canonical workflow catalog.
   - New workflow skill? Add it to the appropriate workflow section or create a new workflow.
   - Renamed skill? Update all references (mermaid diagrams, step lists, appendix tables).
   - Changed a skill's follow-up chain or prerequisites? Verify the relevant workflow diagram still holds.

2. **`home/file/agents/skills/knowledge/follow-up-map-g/SKILL.md`** -- the follow-up relationship map.
   - New workflow skill? Add a row mapping it to its logical follow-ups (derive from the workflow catalog).
   - Renamed skill? Update the row key and all references in other rows' follow-up lists.
   - Removed skill? Remove its row and references from other rows.

3. **`home/file/agents/CLAUDE.md`** -- the skill catalog table.
   - Already covered by `claude-skill-catalog-sync` rule, but verify the new skill appears in the correct section (Workflow vs Knowledge).

Apply all sync changes in the same commit as the skill change.
