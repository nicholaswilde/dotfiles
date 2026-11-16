---
name: check-secrets
description: Audit staged files and SOPS-encrypted secrets across dotfiles using check-secrets.sh, task check-secrets, and task encrypt/decrypt. Trigger: "check secrets", "audit secrets", "verify sops", "install git hooks".
---

# Check Secrets Skill

Prevents unencrypted secrets from being committed and verifies SOPS encryption integrity.

## Protocol

1. **Check Staged Files**:
   - Run `task check-secrets` (executes `./scripts/check-secrets.sh`).
   - Blocked patterns include `bash/.tokens`, `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa`, `id_ed25519`.

2. **Install Pre-Commit Hook**:
   - Ensure hook is linked: `task install-hooks` (links `.git/hooks/pre-commit` -> `../../scripts/check-secrets.sh`).

3. **Encrypt / Decrypt Workflow**:
   - Encrypt local plaintext files: `task encrypt`.
   - Decrypt `.enc` files locally: `task decrypt`.
   - Adding/updating secret or token env vars: run `task decrypt` (if `bash/.tokens` missing), update `bash/.tokens` (`export VAR="..."`), then immediately run `task encrypt` so `bash/.tokens.enc` remains up to date and encrypted.
   - Never use `sops -i` or `--in-place`.

4. **Verify Tests**:
   - Run secret guard unit tests:
     ```bash
     bash tests/test_check_secrets.sh
     bash tests/test_taskfile_check_secrets.sh
     bash tests/test_pre_commit_hook.sh
     ```
