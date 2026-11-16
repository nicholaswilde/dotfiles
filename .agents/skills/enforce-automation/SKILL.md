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
default to raw multi-line shell executions, ad-hoc symlinks, or raw sops
commands when an established automation pathway exists within `Taskfile.yaml`
or the `scripts/` directory.

## Execution Hierarchy

1. **Priority 1 (Taskfile Tasks)**:
   Always check `Taskfile.yaml` first (`task --list`). Use predefined tasks:
   - **Bootstrap & Install**: `task bootstrap`, `task install`, `task restow`,
     `task delete`
   - **Testing & Verification**: `task test` (stow dry-run),
     `task test-integration`
   - **Secret Encryption**: `task encrypt`, `task decrypt` (never `sops -i`
     or `--in-place`)
   - **Secret Auditing**: `task check-secrets`, `task install-hooks`
   - **Package Setup**: `task create-ignore -- <package>`

2. **Priority 2 (Dedicated Scripts)**:
   If no task wraps the functionality, execute established repository scripts
   in `scripts/`:
   - `./scripts/check-secrets.sh`: Direct staged secret verification
   - `./scripts/install-hooks.sh`: Git pre-commit hook installation
   - `./scripts/unstow.sh`: Unstowing files from home directory

3. **Priority 3 (Raw Shell Commands)**:
   Only execute raw shell commands (`stow`, `sops`, `ln -s`) if no task or
   script exists. When executing raw commands:
   - Always perform dry-run first when modifying filesystem state (`stow -n`).
   - Validate syntax before saving (`bash -n`, `shuck check`).

## Protocol

1. **Analyze Intent**: Identify requested operation (e.g. stowing, secret
   encryption, testing, auditing).
2. **Audit Automation**: Scan `Taskfile.yaml` tasks matching the intent.
3. **Execute Task**: Prefer `task <name>` over raw CLI commands.
4. **Report Result**: Provide concise execution status.
