---
name: enforce-automation
description: >-
  Check and execute predefined Taskfile tasks or scripts/ before running raw shell commands.
  Trigger: "enforce automation", "run task", "check tasks", "use taskfile".
---

# Enforce Taskfile and Scripts Automation

Behavioral constraint requiring agents to check for predefined tasks and
scripts before executing raw shell commands in `dotfiles`.

## Description

This skill establishes a strict execution hierarchy for dotfiles package
management, secret encryption, validation, and maintenance. Agents must never
default to raw multi-line shell executions, ad-hoc symlinks, or raw encryption
commands when an established automation pathway exists within `Taskfile.yaml`
or the `scripts/` directory.

## Execution Hierarchy

1. **Priority 1 (Taskfile Tasks)**:
   Always check `Taskfile.yaml` first (`task --list`). Use predefined tasks:
   - **Bootstrap & Apply**: `task bootstrap`, `task install`, `task restow`,
     `task restow:fix`, `task unstow` (`task delete`), `task scrub`
   - **Diagnostics & Testing**: `task test` (`enstow apply --dry-run`),
     `task status`, `task diff`, `task doctor`, `task test-integration`
   - **Secret Management**: `task edit`, `task encrypt`, `task decrypt`
   - **Secret Auditing**: `task check-secrets`, `task install-hooks`
   - **Package Setup**: `task create-ignore -- <package>`

2. **Priority 2 (Dedicated Scripts)**:
   If no task wraps the functionality, execute established repository scripts
   in `scripts/`:
   - `./scripts/check-secrets.sh`: Direct staged secret verification
   - `./scripts/restow-and-fix.sh`: Conflict-resolving restow with backup

3. **Priority 3 (Raw Shell Commands)**:
   Only execute raw shell commands (`enstow`, `ln -s`) if no task or
   script exists. When executing raw commands:
   - Always pass `-C .enstow.toml` and perform `--dry-run` first when modifying
     filesystem state.
   - Validate shell syntax before saving (`bash -n`, `shuck check`).

## Protocol

1. **Analyze Intent**: Identify requested operation (e.g. applying, restowing,
   secret encryption, testing, auditing).
2. **Audit Automation**: Scan `Taskfile.yaml` tasks matching the intent.
3. **Execute Task**: Prefer `task <name>` over raw CLI commands.
4. **Report Result**: Provide concise execution status.
