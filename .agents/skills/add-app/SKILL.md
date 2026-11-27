---
name: add-app
description: >-
  Add an application configuration to the dotfiles repository, configure enstow, encrypt secrets with age, and register in .enstow.toml.
  Trigger: "/app add", "add app config", "stow new app", "enstow new app".
---

# Add App Skill

Adds application configuration files to `dotfiles` and configures `enstow`.

## Protocol

1. **Resolve Input**:
   - Verify `<path>` exists on disk.
   - Determine `$HOME`-relative target path (e.g., `~/.config/myapp/config.toml` -> `.config/myapp/config.toml`).
   - Confirm package name `<package>`.

2. **Replicate Structure (or Ingest via `enstow add`)**:
   - Use `enstow add <path> -p <package>` (add `--encrypt` for secret files), OR create `<package>/<relative_path>` and copy configuration files.
   - Add `"<package>"` to `packages` in `.enstow.toml`.

3. **Handle Secrets**:
   - If files contain secrets, encrypt as `.age` with `enstow encrypt <file> -o <package>/<relative_path>.age` (or `enstow add <path> -p <package> --encrypt`).
   - Add plaintext paths to `.gitignore` (verified automatically by `enstow doctor` and `enstow doctor --staged`), and create `<package>/.enstowignore` (Git-style ignore syntax) via `task create-ignore -- <package>` for any ignored files (e.g., `README.md`, `*.swp`).
   - Never leave plaintext secret files in the repository working tree.

4. **Verify & Apply**:
   - Dry-run: `task test` or `enstow apply --dry-run <package>`.
   - Apply after confirmation: `task install` or `enstow apply --force <package>`.
   - Run `task status -- --check <package>`, `task doctor`, and `task check-secrets` before staging.

5. **Commit**:
   - Stage files explicitly (`rtk git add <files>`).
   - Commit using Conventional Commits (include `Fixes #<number>` when resolving an issue):

     ```bash
     rtk git commit -m "feat(<package>): Add configuration files and enstow package"
     ```
