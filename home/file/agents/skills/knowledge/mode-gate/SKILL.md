---
name: mode-gate
description: Enforces a required interaction mode before a workflow step proceeds. In agents that support mode switching (e.g. Cursor's SwitchMode), it switches, verifies, and stops on failure. In other agents, it states the constraint and proceeds without blocking. Use whenever a workflow step requires a specific mode.
---

# Mode Gate

When a workflow step requires a specific mode (e.g. read-only analysis before write actions), apply this skill to enforce it. The enforcement adapts to the agent's capabilities.

## Gate protocol

Follow these steps in order whenever a workflow requires a mode:

1. **Check for mode-switching support.** Determine whether the current agent provides a mode-switching tool (e.g. Cursor's `SwitchMode`). If the tool is available, proceed to the strict protocol. If not, proceed to the graceful protocol.

2. **Strict protocol** (agent supports mode switching):
   1. **Attempt the switch.** Call the mode-switching tool with the required mode. If the tool doesn't support the required mode as a target, tell the user which mode is needed and ask them to switch manually.
   2. **Verify.** After the switch attempt, confirm the mode is active. In Cursor, the system reminder at the top of the next turn states the active mode.
   3. **Stop if not active.** If the required mode is not confirmed, inform the user that the workflow cannot continue without it and **stop**. Do not execute any subsequent steps until the correct mode is active.

3. **Graceful protocol** (agent does not support mode switching):
   1. **State the constraint.** Inform the user of the expected behaviour for this phase (e.g. "This phase is read-only analysis -- no file modifications until the analysis is approved.").
   2. **Self-enforce.** Avoid actions that violate the mode's intent. For a read-only phase, do not write files; for a debug phase, focus on investigation before proposing fixes.
   3. **Proceed.** Continue to the next workflow step without blocking.

## Determining auto-switchability

In Cursor, a mode is auto-switchable when the `SwitchMode` tool lists it as an allowed value for `target_mode_id`. Check the tool's schema at invocation time rather than relying on a hard-coded list -- new switchable modes may be added in future releases.

In other agents, mode switching is not available. The graceful protocol applies.

## Mid-command transitions

Some workflows change mode partway through (e.g. moving from read-only analysis to implementation). At the transition point, apply the same protocol: strict if mode switching is available, graceful otherwise.
