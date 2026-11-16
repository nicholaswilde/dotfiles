---
name: add-app
description: Add an application configuration to the dotfiles repository, configure GNU Stow, encrypt secrets with SOPS, and register in .stow-packages. Trigger: "/app add", "add app config", "stow new app".
---

# Add App Skill

Adds application configuration files to `dotfiles` and configures GNU Stow.

## Protocol

1. **Resolve Input**:
   - Verify `<path>` exists on disk.
   - Determine `$HOME`-relative target path (e.g., `~/.config/myapp/config.toml` -> `.config/myapp/config.toml`).
   - Confirm Stow package name `<package>`.

2. **Replicate Structure**:
   - Create `<package>/<relative_path>` and copy configuration files.
   - Append `<package>` to `.stow-packages`.

3. **Handle Secrets**:
   - If files contain secrets, add plaintext paths to `.gitignore` and create package ignore via `task create-ignore -- <package>` (adding plaintext filenames and `\.enc$`).
   - Add SOPS rules in `Taskfile.yaml` (`encrypt` / `decrypt` tasks) and encrypt with `task encrypt`. Never use `sops -i` or `--in-place`.

4. **Verify & Stow**:
   - Dry-run: `task test` or `stow -n -v --adopt -t ~/ <package>`.
   - Apply after confirmation: `task install` or `stow -v --adopt -t ~/ <package>`.
   - Run `task check-secrets` before staging.

5. **Commit**:
   - Stage files explicitly (`rtk git add <files>`).
   - Commit using Conventional Commits (include `Fixes #<number>` when resolving an issue):
     ```bash
     rtk git commit -m "feat(<package>): Add configuration files and stow package"
     ```
