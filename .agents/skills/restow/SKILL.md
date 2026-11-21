---
name: restow
description: >-
  Restow dotfile packages via Taskfile and enstow, diagnose conflicts/legacy folded links, back up targets, and verify symlinks and secrets.
  Trigger: /restow, /restow-and-fix, /app restow, "restow", "restow dotfiles", "restow and fix", "fix stow conflicts", "fix enstow conflicts".
---

# Restow Dotfiles Skill

Safely restow `enstow` packages, clean legacy GNU Stow folded directory
symlinks or non-symlink conflict blocks, back up modified unmanaged targets,
and verify symlink and secret integrity.

## Inputs & Options

- `[packages...]` (Optional): Specific package names (e.g. `bash`, `ssh`).
  Defaults to all active packages in `.enstow.toml`.
- `--dry-run` / `-n` (Optional): Preview conflicts and actions without disk changes.
- `--target <dir>` (Optional): Target home directory. Defaults to `$HOME`.

## Protocol

### 1. Pre-Restow Audit & Package Verification

Inspect active packages and repository status:

1. Check `packages` in `.enstow.toml` and confirm package folders exist on disk.
2. Verify git status before restowing:

   ```bash
   rtk git status --short
   ```

### 2. Conflict Detection & Diagnosis

Run dry-run or status to identify conflicting paths before modifying links:

```bash
task status
task test
```

Or dry-run via helper script:

```bash
./scripts/restow-and-fix.sh --dry-run
```

**Common Conflict Classes**:

- **Unmanaged target file**: Regular file exists in `$HOME` where a symlink or
  decrypted secret is expected.
- **Legacy folded directory symlink**: Directory symlink left over from GNU
  Stow pointing into the repo (must be unlinked before `enstow` links files).
- **Dangling symlink**: Target link in `$HOME` pointing to a deleted file.
- **Secret drift (`MODIFIED`)**: Decrypted target differs from `.age` source
  (inspect with `task diff`).

### 3. Automated Conflict Resolution

Execute the restow helper to clean legacy folded/dangling links, back up
colliding unmanaged targets to `~/.dotfiles_backup/<timestamp>`, and restow:

```bash
task restow:fix
```

Or pass specific packages:

```bash
task restow:fix -- bash ssh
```

### 4. Standard Restow

Restow all packages or selected targets directly via `enstow`:

```bash
task restow
# Or specific package:
task restow -- bash
```

### 5. Verification & Quality Gates

Run verification tests to confirm expected symlinks, `0600` decrypted secrets,
and secret guard status:

```bash
bash tests/verify.sh
task doctor
task check-secrets
```

### 6. Terse Status Report

Output concise confirmation:

- Packages restowed: `<count>` packages (or package names)
- Legacy links/conflicts resolved (with backup directory if files backed up)
- Verification status: `Passed (tests/verify.sh)`
