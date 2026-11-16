---
name: add-path-to-env
description: Safely append or prepend directory paths to $PATH in bash/.bash_exports with test -d guards and duplicate checks. Trigger: "add path to env", "add to PATH", "update bash_exports".
---

# Add Path to Environment Variable Skill

Safely adds directories to `$PATH` in `bash/.bash_exports`.

## Protocol

1. **Resolve Inputs**:
   - Verify directory path exists (unless using runtime env vars like `${HOME}`).
   - Decide append (default) or prepend precedence.

2. **Check Duplicates**:
   - Search `bash/.bash_exports` via `rtk rg` to confirm path is not already added.

3. **Format & Insert**:
   - Under `# PATH` in `bash/.bash_exports`, guard with `test -d`:
     ```bash
     # Append
     test -d "${HOME}/.local/bin" && export PATH="${PATH}:${HOME}/.local/bin"
     # Prepend
     test -d "/home/linuxbrew/.linuxbrew/bin" && export PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
     ```

4. **Verify & Commit**:
   - Run `bash -n bash/.bash_exports` and `shuck bash/.bash_exports`.
   - Stage explicitly and commit (add `Fixes #<number>` if resolving an issue):
     ```bash
     rtk git commit -m "feat(bash): Add <path> to PATH"
     ```
