---
name: pull-dotfiles
description: >-
  Pull upstream dotfiles changes, resolve merge/enstow conflicts, audit dangling symlinks, run verification tests, and fix any issues.
  Trigger: /pull-dotfiles, /pull-and-fix, "pull dotfiles", "git pull and fix", "pull and fix issues", "perform a git pull and fix any issues".
---

# Pull Dotfiles Skill

Safely pull upstream `dotfiles` commits, resolve git or `enstow` issues,
restow symlinks and `.age` secrets, verify tests, and fix any regressions.

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
  - Resolve conflicts manually (for `bash/.tokens.age` or
    `pvetui/.config/pvetui/config.yml.age`, pick the desired version or edit
    cleanly via `task edit`; never commit plaintext secrets).
  - Stage explicitly (`rtk git add <file>`) and finish merge/rebase.
- **Inspect pulled delta**:

  ```bash
  rtk git log --oneline ORIG_HEAD..HEAD
  rtk git diff ORIG_HEAD..HEAD --stat
  ```

### 3. Restow Packages & Secrets

`enstow` automatically decrypts `.age` secrets in memory directly to `$HOME`
(`0600`) during `apply` / `restow`:

1. Preview with `task test` (`enstow -C .enstow.toml apply --dry-run --force`).
2. Apply symlinks and decrypted secrets with `task restow`.
3. If unmanaged target collisions or legacy folded directory symlinks block
   apply, run `task restow:fix` (see [`restow`](../restow/SKILL.md)).

### 4. Status & Health Audit

Inspect sync state and hygiene with `enstow`:

```bash
task status
task doctor
```

- Remove stale symlinks pointing to removed `dotfiles` targets; confirm with
  the user before removing unrelated links outside `dotfiles`.

### 5. Verification & Fix Loop

Run repository quality gates and fix any failures found:

1. **Symlink & secret verification**:

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
