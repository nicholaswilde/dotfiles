---
name: manage-bash-aliases
description: Add, modify, or remove conditional shell aliases in bash/.bash_aliases guarded by command_exists, file_exists, or dir_exists. Trigger: "manage bash aliases", "add alias", "update .bash_aliases".
---

# Manage Bash Aliases Skill

Manages conditional shell aliases in `bash/.bash_aliases`.

## Protocol

1. **Verify Inputs**:
   - Check proposed alias name for collisions with reserved commands or functions in `bash/.bash_functions`.

2. **Guard Existence**:
   - Wrap aliases for optional tools/paths with `command_exists <cmd>`, `file_exists <file>`, `dir_exists <dir>`, or `test -d <dir>`:
     ```bash
     command_exists lazydocker && alias ld='lazydocker'

     if command_exists docker; then
       alias dc='docker-compose'
     fi
     ```

3. **Insert & Verify**:
   - Place under matching section in `bash/.bash_aliases`.
   - Validate with `bash -n bash/.bash_aliases` and `shuck bash/.bash_aliases`.

4. **Commit**:
   - Stage `bash/.bash_aliases` explicitly and commit (add `Fixes #<number>` if resolving an issue):
     ```bash
     rtk git commit -m "feat(bash): Add alias '<alias_name>'"
     ```
