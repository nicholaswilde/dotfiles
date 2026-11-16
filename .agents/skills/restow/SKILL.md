---
name: restow
description: >-
  Restow dotfile packages via Taskfile, diagnose non-symlink/conflict blocks, back up targets, and verify symlinks.
  Trigger: /restow, /restow-and-fix, /app restow, "restow", "restow dotfiles", "restow and fix", "fix stow conflicts".
---

# Restow Dotfiles Skill

Safely restow GNU Stow packages, diagnose and resolve non-symlink conflict
blocks, safely back up modified targets, and verify symlink integrity.

## Inputs & Options

- `[packages...]` (Optional): Specific stow package names (e.g. `bash`, `ssh`).
  Defaults to all active packages in `.stow-packages`.
- `--dry-run` / `-n` (Optional): Check conflicts without modifying links.
- `--target <dir>` (Optional): Target home directory. Defaults to `$HOME`.

## Protocol

### 1. Pre-Restow Audit & Package Verification

Inspect active packages and repository status:

1. Read `.stow-packages` and confirm all package folders exist on disk.
2. Verify clean git status before restowing:

   ```bash
   rtk git status --short
   ```

### 2. Conflict Detection & Diagnosis

Run dry-run to identify conflicting paths before modifying filesystem links:

```bash
task test
```

Or dry-run via helper script:

```bash
./scripts/restow-and-fix.sh --dry-run
```

**Common Conflict Classes**:

- **Non-symlink file block**: Regular file exists in `$HOME` where a link is
  expected (`existing target is neither a link nor a directory: <path>`).
- **Dangling symlink**: Target link in `$HOME` points to a non-existent file.
- **Directory collision**: Existing directory in `$HOME` preventing parent tree
  folding.

### 3. Automated Conflict Resolution

Execute the restow helper to resolve conflicts automatically:

```bash
./scripts/restow-and-fix.sh "$@"
```

Or execute manual resolution steps:

1. **Non-symlink target handling**:
   - Compare `$HOME/<path>` against `<pkg>/<path>` (`diff -u`).
   - If files are identical: remove `$HOME/<path>` so GNU Stow can link cleanly.
   - If target has local modifications: back up `$HOME/<path>` to
     `~/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)/<path>`, then remove blocker.
2. **Dangling symlink cleanup**:
   - Remove stale links in `$HOME` pointing to deleted or renamed dotfiles.
3. **Ignore verification**:
   - Ensure package `.stow-local-ignore` ignores `README.*` and `\.enc$` files.
   - Generate missing ignore files via `task create-ignore -- <pkg>`.

### 4. Execute Restow

Restow all packages or selected targets:

```bash
task restow
```

Or via automated fixer:

```bash
task restow:fix
```

To prevent `--adopt` from leaving unwanted dirty changes in tracked files,
always restore package git trees post-restow:

```bash
for pkg in "${PACKAGES[@]}"; do git restore "$pkg" 2>/dev/null || true; done
```

### 5. Verification & Quality Gates

Run verification tests to confirm expected symlinks and secret integrity:

```bash
bash tests/verify.sh
task check-secrets
```

### 6. Terse Status Report

Output concise confirmation:

- Packages restowed: `<count>` packages (or package names)
- Conflicts resolved: `<count>` files (with backup directory if files backed up)
- Verification status: `Passed (tests/verify.sh)`
