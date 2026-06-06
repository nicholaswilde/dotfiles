# Implementation Plan - Add Pre-Commit Hook for Secrets Verification

## Phase 1: Script & Task Implementation
- [ ] Task: Create script `scripts/check-secrets.sh` to check staged files.
- [ ] Task: Integrate `check-secrets` command in `Taskfile.yaml`.

## Phase 2: Git Hook Setup & Testing
- [ ] Task: Create a task or document command to symlink/copy `scripts/check-secrets.sh` to `.git/hooks/pre-commit`.
- [ ] Task: Verify hook execution by staging a mock decrypted file (e.g. `settings.json`) and trying to commit it.
