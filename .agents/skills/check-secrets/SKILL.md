---
name: check-secrets
description: Audit staged files and enstow age-encrypted secrets across dotfiles using check-secrets.sh, task check-secrets, task doctor, and task edit/encrypt/decrypt. Trigger: "check secrets", "audit secrets", "verify secrets", "verify age", "install git hooks".
---

# Check Secrets Skill

Prevents unencrypted secrets from being committed and verifies `enstow` `.age` encryption and permission integrity.

## Protocol

1. **Check Staged Files**:
   - Run `task check-secrets` (executes `./scripts/check-secrets.sh`).
   - Blocked patterns include `bash/.tokens`, `pvetui/.config/pvetui/config.yml`, `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa`, `id_ed25519`.
   - Run `task doctor` (`enstow -C .enstow.toml doctor`) to verify `0600` secret target permissions, decryption keys, and leak scans.

2. **Install Pre-Commit Hook**:
   - Ensure hook is linked: `task install-hooks` (links `.git/hooks/pre-commit` -> `../../scripts/check-secrets.sh`).

3. **Encrypt / Decrypt / Edit Workflow**:
   - Edit encrypted secrets in memory: `task edit` (defaults to `bash/.tokens.age`) or `task edit -- <file.age>`, then re-apply via `task restow` (or `task decrypt`).
   - Encrypt `~/.tokens` -> `bash/.tokens.age`: `task encrypt` (or `task encrypt -- <src> -o <dest.age>`).
   - Decrypt `bash/.tokens.age` -> `~/.tokens` (`0600`): `task decrypt` (or `task decrypt -- <file.age> -o <dest>`).
   - Never leave plaintext secret files inside the repository working tree.

4. **Verify Tests**:
   - Run secret guard unit tests:

     ```bash
     bash tests/test_check_secrets.sh
     bash tests/test_taskfile_check_secrets.sh
     bash tests/test_pre_commit_hook.sh
     ```
