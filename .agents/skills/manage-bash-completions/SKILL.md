---
name: manage-bash-completions
description: Add, modify, or remove shell completions, hooks, and tool evals in bash/.bash_completions guarded by command_exists or file/dir checks. Trigger: "manage bash completions", "add completion", "remove completion", "update .bash_completions", "add hook".
---

# Manage Bash Completions Skill

Manages shell completions, hooks, and tool `eval` initializers in `bash/.bash_completions`.

## Protocol

1. **Check Existing Entries**:
   - Search `bash/.bash_completions` with `rtk rg` for tool name to avoid duplicates or locate entry to modify/remove.

2. **Guard Existence**:
   - Wrap every external binary completion, hook, or `eval` in `if command_exists <bin>; then ... fi` (or `[ -f ... ]` / `[ -s ... ]` when sourcing a script):

     ```bash
     if command_exists direnv; then
       eval "$(direnv hook bash)"
     fi

     if command_exists gopass; then
       source <(gopass completion bash)
     fi
     ```

   - When removing an entry, delete the full guarded block cleanly without leaving orphan comments or empty `if` blocks.

3. **Verify**:
   - Run `bash -n bash/.bash_completions` and `shuck check bash/.bash_completions`.
   - Confirm `bash/.tokens` / secrets are not referenced or hardcoded.

4. **Commit**:
   - Stage `bash/.bash_completions` explicitly and commit:

     ```bash
     rtk git commit -m "feat(bash): Add <tool> completion"
     ```
