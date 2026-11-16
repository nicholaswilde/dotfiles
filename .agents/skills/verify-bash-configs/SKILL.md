---
name: verify-bash-configs
description: Validate syntax, shuck lint rules, inline ## function docstrings, and stow symlinks for bash/ dotfiles. Trigger: "verify bash configs", "lint bash", "check bash dotfiles".
---

# Verify Bash Configs Skill

Validates syntax and quality standards for `bash/` dotfiles.

## Protocol

1. **Syntax Check**:
   - Run `bash -n` on `bash/.bashrc`, `bash/.bash_aliases`, `bash/.bash_completions`, `bash/.bash_exports`, `bash/.bash_functions`, and `bash/.profile`.

2. **Linter Check (`shuck`)**:
   - Run `shuck check bash/.bashrc bash/.bash_aliases bash/.bash_completions bash/.bash_exports bash/.bash_functions` and fix warnings/errors.

3. **Docstring & Guard Audit**:
   - Verify every function in `bash/.bash_functions` includes an inline `##` docstring on its opening `{` line.
   - Verify new aliases, functions, completions, hooks, and tool evals are guarded with `command_exists` (or `file_exists` / `dir_exists` / `test -d`).

4. **Stow Verification**:
   - Dry-run `task test` (`stow -n`) or run `bash tests/verify.sh` when stowed.
