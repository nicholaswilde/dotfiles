---
name: manage-bash-exports
description: Add, modify, or remove environment variables and tool exports in bash/.bash_exports (plus bash/.bashrc and bash/.profile init entries) with binary/path guards and secret routing to bash/.tokens. Trigger: "manage bash exports", "add env var", "remove env var", "update .bash_exports", "update .bashrc".
---

# Manage Bash Exports Skill

Manages environment variables, tool configurations, and sourced init entries in `bash/.bash_exports` (and shell init blocks in `bash/.bashrc` / `bash/.profile`).

## Routing

- **`$PATH` entries**: Use [`add-path-to-env`](../add-path-to-env/SKILL.md).
- **Aliases / Functions / Completions**: Use `manage-bash-aliases`, `manage-bash-functions`, or `manage-bash-completions`.
- **Secrets (tokens, API keys, passwords)**: NEVER place in `bash/.bash_exports`, `bash/.bashrc`, or `bash/.profile`. Place in `bash/.tokens` (`export VAR="..."`) and encrypt with `task encrypt` (see [`check-secrets`](../check-secrets/SKILL.md)).

## Protocol

1. **Check Existing Entries**:
   - Search `bash/.bash_exports` (and `bash/.bashrc`, `bash/.profile`) with `rtk rg` to detect duplicates or locate target entry for update/removal.

2. **Guard External Tools & Paths**:
   - Wrap tool-specific exports in `if command_exists <bin>; then ... fi` and path-dependent exports in `test -d` / `test -f`:

     ```bash
     if command_exists restic; then
       export RESTIC_REPOSITORY="/srv/restic-repo"
     fi

     [[ -f "$HOME/.config/ripgrep/ripgrep.conf" ]] && export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgrep.conf"
     ```

   - When removing an entry, remove any surrounding guard block or section comment made unused.

3. **Verify**:
   - Run `bash -n <file>` and `shuck check <file>`.
   - Run `task check-secrets` before staging.

4. **Commit**:
   - Stage modified files explicitly and commit:

     ```bash
     rtk git commit -m "feat(bash): Update <var> export"
     ```
