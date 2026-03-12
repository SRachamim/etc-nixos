---
name: mode-gate
description: Enforces a required Cursor mode before a command proceeds. Handles auto-switchable and manual-only modes, verifies the switch took effect, and stops execution if the mode is not active. Use whenever a command step requires a specific Cursor mode.
---

# Mode Gate

When a command step requires a specific Cursor mode, apply this skill to switch (or recommend switching), verify the mode is active, and halt if it is not.

## Gate protocol

Follow these steps in order whenever a command requires a mode:

1. **Attempt the switch.** Check whether `SwitchMode` supports the required mode (see the table below). If it does, call `SwitchMode` with the appropriate `target_mode_id`. Otherwise, tell the user which mode is needed and ask them to switch manually.
2. **Verify.** After the switch attempt (or recommendation), confirm the mode is active. The system reminder at the top of the next turn states the active mode.
3. **Stop if not active.** If the required mode is not confirmed, inform the user that the command cannot continue without it and **stop**. Do not execute any subsequent steps until the correct mode is active.

## Determining auto-switchability

A mode is auto-switchable when the `SwitchMode` tool lists it as an allowed value for `target_mode_id`. Check the tool's schema at invocation time rather than relying on a hard-coded list -- Cursor may add new switchable modes in future releases.

## Mid-command transitions

Some commands change mode partway through (e.g. moving from Debug to Plan after an investigation phase). Apply the same three-step protocol at the transition point -- attempt, verify, stop if not active -- before proceeding to the next phase.
