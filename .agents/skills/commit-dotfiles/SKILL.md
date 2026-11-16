---
name: commit-dotfiles
description: >-
  Audit, secret-check, test, stage, commit with Conventional Commits, and push dotfiles changes.
  Trigger: /commit-dotfiles, /commit-push-dotfiles, "commit dotfiles", "commit and push dotfiles", "sync dotfiles".
---

# Commit Dotfiles Skill

Safely audit, secret-check, test, stage, commit using Conventional Commits,
push, and restow dotfiles packages.

## Protocol

### 1. Identify Changed and Untracked Files

Audit git status for modified or newly added package files:

- Run `rtk git status --short`.
- If working tree and index are clean, stop and report:
  `working tree clean; nothing to commit`.

### 2. Mandatory Secret & Sensitive Data Audit

Strictly enforce secret management guidelines before staging:

- **Scan candidate files**: Verify no plaintext API tokens, auth credentials,
  passwords, private keys (`*.pem`, `*.key`, `id_rsa`, `id_ed25519`), or `.env`
  files are included.
- **Run Secret Check**: Run `task check-secrets` (`./scripts/check-secrets.sh`).
- **Encrypted Env Vars**: If `bash/.tokens` was modified, ensure `task encrypt`
  has been executed so `bash/.tokens.enc` is updated. Never commit or stage
  plaintext `bash/.tokens`.
- **No Blanket Staging**: NEVER run `git add .` or `git add -A`. All targets
  must be staged explicitly by file path.

### 3. Formatting, Linting & Verification Gates

Ensure modified dotfile configs pass syntax and integration gates:

- **Stow Dry-Run**: Run `task test` to verify GNU Stow cleanly links packages
  without conflicts.
- **Bash Validation**: If bash configs were touched, validate syntax and lint:
  - `bash -n bash/.*`
  - `shuck check bash/.*`
- **Unit & Integration Checks**: Run repo tests:
  - `bash tests/verify.sh`
  - `bash tests/test_skills_catalog_links.sh`
  - `bash tests/test_check_secrets.sh`

### 4. Explicit Staging & Diff Review

Stage target files explicitly:

- Stage candidate paths: `rtk git add <file1> <file2> ...`
- Inspect staged files: `rtk git diff --staged --name-status`
- Review staged diff: `rtk git diff --staged` to confirm only intended changes
  are included.

### 5. Conventional Commit Generation

Generate a concise commit message adhering to Conventional Commits:

- **Format**: `<type>(<scope>): <imperative summary>`
- **Types**:
  - `feat`: new app package or configuration feature
  - `fix`: bug fix or correction in configs or scripts
  - `chore`: maintenance, package list update, secret encryption sync
  - `docs`: documentation or README updates
  - `style`: formatting or cosmetic tweaks
- **Scope**: Target stow package name or subsystem (e.g. `bash`, `ssh`, `git`,
  `mise`, `secrets`, `skills`).
- **Guidelines**:
  - Subject length <= 50 characters, lowercase imperative mood, no trailing
    period.
  - Reference issues if closing: `Fixes #<number>`.
- Execute commit: `rtk git commit -m "<message>"`

### 6. Push to Remote Upstream

Push committed changes to tracking branch:

- Verify upstream: `rtk git rev-parse --abbrev-ref @{u} 2>/dev/null`
- Push: `rtk git push origin main`

### 7. Post-Push Restow

Apply updated symlinks to user home directory:

- Run `task restow` (or `task install` for newly added packages).

### 8. Terse Status Report

Output concise confirmation:

- Staged and committed files
- Commit SHA and subject
- Remote push status
- Stow verification status
