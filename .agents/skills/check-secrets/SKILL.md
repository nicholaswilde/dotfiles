---
name: check-secrets
description: Audit staged files and enstow age-encrypted secrets across dotfiles using enstow doctor --staged, task check-secrets, task doctor, and task edit/encrypt/decrypt. Trigger: "check secrets", "audit secrets", "verify secrets", "verify age", "install git hooks".
---

# Check Secrets Skill

Prevents unencrypted secrets from being committed and verifies `enstow` `.age` encryption and permission integrity.

## Protocol

1. **Check Staged Files**:
   - Run `task check-secrets` (executes `enstow doctor --staged -s .`).
   - Automatically blocks plaintext counterparts of any `.age` / `.sops.*` file, unencrypted `.env` / `.env.*` files (excluding `.env.example`/`.sample`/`.template`/`.dist`), and staged credential leaks (SSH/PGP/age private keys, GitHub/GitLab/Slack tokens).
   - Run `task doctor` (`enstow doctor`) to verify `0600` secret target permissions, decryption keys, `.gitignore` coverage, and leak scans.

2. **Install Pre-Commit Hook**:
   - Ensure hook is installed: `task install-hooks` (writes executable `.git/hooks/pre-commit` invoking `exec enstow doctor --staged -s .`).

3. **Encrypt / Decrypt / Edit / Keygen Workflow**:
   - Generate a new age key (if needed): `enstow keygen` (writes `~/.config/sops/age/keys.txt` with `0600` permissions).
   - Edit encrypted secrets in memory and immediately re-deploy (`0600`): `task edit` (defaults to `bash/.tokens.age` via `enstow edit --apply`) or `task edit -- <file.age>`.
   - Encrypt `~/.tokens` -> `bash/.tokens.age`: `task encrypt` (or `task encrypt -- <src> -o <dest.age>`).
   - Decrypt `bash/.tokens.age` -> `~/.tokens` (`0600`): `task decrypt` (or `task decrypt -- <file.age> -o <dest>`).
   - Never leave plaintext secret files inside the repository working tree.

4. **Verify Tests**:
   - Run secret guard unit tests:

     ```bash
     bash tests/test_check_secrets.sh
     bash tests/test_taskfile_check_secrets.sh
     bash tests/test_install_hooks.sh
     bash tests/test_pre_commit_hook.sh
     ```
