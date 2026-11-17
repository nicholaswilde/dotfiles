---
name: pull-dotfiles
description: >-
  Pull upstream dotfiles changes, resolve merge/stow conflicts, decrypt secrets, audit dangling symlinks, run verification tests, and fix any issues.
  Trigger: /pull-dotfiles, /pull-and-fix, "pull dotfiles", "git pull and fix", "pull and fix issues", "perform a git pull and fix any issues".
---

# Pull Dotfiles Skill

Safely pull upstream `dotfiles` commits, resolve git or GNU Stow issues,
decrypt SOPS tokens, verify symlinks and tests, and fix any regressions.

## Protocol

### 1. Pre-Pull Audit

Check local repository state before pulling:

1. Run `rtk git status --short`.
2. If working tree has local edits, run `task check-secrets` first, then
   stash (`rtk git stash push -m "pre-pull"`) or commit/discard as intended.

### 2. Pull Upstream Changes

Pull from upstream tracking branch:

```bash
rtk git pull
```

- **If pull has merge/rebase conflicts**:
  - Inspect conflicted files with `rtk git status --short`.
  - Resolve conflicts manually (for `bash/.tokens.enc`, resolve encrypted
    file cleanly or re-encrypt from decrypted `bash/.tokens` via
    `task encrypt`; never commit plaintext secrets).
  - Stage explicitly (`rtk git add <file>`) and finish merge/rebase.
- **Inspect pulled delta**:

  ```bash
  rtk git log --oneline ORIG_HEAD..HEAD
  rtk git diff ORIG_HEAD..HEAD --stat
  ```

### 3. Decrypt Secrets & Restow Packages

1. **Decrypt SOPS tokens** if `bash/.tokens` is missing, empty, or
   `bash/.tokens.enc` changed (do not print token contents):

   ```bash
   task decrypt
   ```

2. **Dry-run & restow packages**:
   - Check for conflicts with `task test`.
   - Apply symlinks with `task restow`.
   - If non-symlink file conflicts block stow (`existing target is neither a
     link nor a directory`), run `task restow:fix` (see
     [`restow`](../restow/SKILL.md)).

### 4. Dangling Symlink Check

Scan `$HOME` (maxdepth 4) for broken symlinks referencing `dotfiles`:

- Identify stale symlinks left behind by renamed, deleted, or legacy
  dotfile directories.
- Remove stale symlinks belonging to removed `dotfiles` targets; confirm
  with the user before removing links pointing to separate/legacy trees
  unless asked.

### 5. Verification & Fix Loop

Run repository quality gates and fix any failures found:

1. **Symlink & token verification**:

   ```bash
   bash tests/verify.sh
   ```

2. **Secret & hook checks**:

   ```bash
   task check-secrets
   ```

   If `.git/hooks/pre-commit` is missing or broken, run `task install-hooks`.

3. **Targeted syntax & lint checks** (based on pulled files):
   - Shell files (`bash/.*`, `scripts/*.sh`): `bash -n <file>` and
     `shuck check <file>`.
   - TOML configs: `rtk taplo lint`.
   - Markdown/skills: `rtk rumdl check <changed_md_files>`.
   - Unit test scripts: run `tests/test_*.sh` (e.g.
     `bash tests/test_skills_catalog_links.sh`,
     `bash tests/test_check_secrets.sh`).

4. **Fix any issues**:
   - Repair broken syntax, lint errors, missing skill catalog entries, or
     failing tests introduced by pulled changes or local state.
   - Re-run failing checks until all relevant gates pass.

### 6. Terse Status Report

Summarize concisely:

- Pulled commit range / file count
- Issues encountered and fixes applied
- Verification pass/fail summary and `rtk git status`
- Note `source ~/.bashrc` if `bash/` configs changed (and `git stash pop`
  if changes were stashed in Step 1)
