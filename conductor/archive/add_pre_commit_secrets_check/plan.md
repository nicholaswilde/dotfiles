# Implementation Plan - Add Pre-Commit Hook for Secrets Verification

## Phase 1: Script & Task Implementation [checkpoint: 7a53441]
- [x] Task: Create script `scripts/check-secrets.sh` to check staged files. (62d9116)
- [x] Task: Integrate `check-secrets` command in `Taskfile.yaml`. (835d3be)

## Phase 2: Git Hook Setup & Testing [checkpoint: d422bbc]
- [x] Task: Create a task or document command to symlink/copy `scripts/check-secrets.sh` to `.git/hooks/pre-commit`. (2362233)
- [x] Task: Verify hook execution by staging a mock decrypted file (e.g. `settings.json`) and trying to commit it. (75a32ff)
