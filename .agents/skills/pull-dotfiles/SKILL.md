---
name: pull-dotfiles
description: >-
  Pull upstream dotfiles changes, resolve merge/enstow conflicts, audit dangling symlinks, run verification tests, and fix any issues.
  Trigger: /pull-dotfiles, /pull-and-fix, "pull dotfiles", "git pull and fix", "pull and fix issues", "perform a git pull and fix any issues".
---

# Pull Dotfiles Skill

Safely pull upstream `dotfiles` commits, resolve git or `enstow` issues,
restow symlinks and `.age` secrets, verify tests, and fix any regressions.

## Options

- `--prefer-remote`: Prioritize remote incoming changes on dirty tracked files
  or conflicts (backs up local edits to stash first).
- `--prefer-local`: Prioritize local changes when resolving conflicts.
- `--rebase`: Rebase local commits onto remote instead of merging.

## Protocol

### 1. Pre-Pull Audit & Branch Check

Check local repository state before pulling:

1. Verify active branch (`BRANCH=$(git branch --show-current)`). If detached
   HEAD, stop and ask user which branch to check out.

2. Verify upstream tracking (`git rev-parse --abbrev-ref @{u} 2>/dev/null ||
   true`); set `origin/$BRANCH` if unset.

3. Test remote connectivity (`timeout 5 git fetch --dry-run origin`). If port
   22 times out, test port 443:

   ```bash
   ssh -T -p 443 -o ConnectTimeout=5 git@ssh.github.com 2>&1
   git config core.sshCommand "ssh -p 443 -o Hostname=ssh.github.com"
   ```

4. Run `rtk git status --short`. Never stage or commit plaintext secrets.

5. If tracked files are dirty:
   - Run `task check-secrets` first.
   - Default: `git stash push -m "autostash-before-pull-$(date +%s)"`
     (mark for Step 3 restore).
   - `--prefer-remote`: `git stash push -m "pull-backup-$(date +%s)"`
     (keep as backup; do not pop).

6. If an untracked file collides with an incoming tracked path, move it aside
   (`mv <file> <file>.bak`).

### 2. Fetch, Pull & Resolve Conflicts

1. Fetch remote: `git fetch origin "$BRANCH"`.

2. Check incoming commits: `git log --oneline "HEAD..origin/$BRANCH"`. If 0
   commits behind, skip to Step 4.

3. Pull based on divergence and flags:
   - 0 commits ahead: `git pull --ff-only origin "$BRANCH"`

   - Ahead + `--prefer-remote`: `git reset --hard "origin/$BRANCH"`

   - Ahead + `--rebase`: `git pull --rebase origin "$BRANCH"`

   - Ahead (default):

     ```bash
     git merge "origin/$BRANCH" -m "Merge branch 'origin/$BRANCH' into $BRANCH"
     ```

4. **If pull has merge/rebase conflicts**:
   - Inspect conflicted files: `git diff --name-only --diff-filter=U`.
   - `--prefer-remote`: `git checkout --theirs <files> && git add <files>`.
   - `--prefer-local`: `git checkout --ours <files> && git add <files>`.
   - Default (manual synthesis): inspect conflict markers, merge both sides
     cleanly, and stage explicitly (`git add <file>`). For `bash/.tokens.age`
     or `pvetui/.config/pvetui/config.yml.age`, pick the desired version or
     edit cleanly via `task edit`; never commit plaintext secrets.
   - Finalize: `git commit --no-edit` (merge) or `git rebase --continue`
     (rebase).

5. **Inspect pulled delta**:

   ```bash
   rtk git log --oneline ORIG_HEAD..HEAD
   rtk git diff ORIG_HEAD..HEAD --stat
   ```

### 3. Restore Stashed Changes

If stashed in Step 1 and `--prefer-remote` was not set:

1. Run `git stash pop`.

2. If pop conflicts, resolve markers cleanly preserving local edits on top of
   updated remote files; never stage plaintext secrets.

### 4. Restow Packages & Secrets

`enstow` automatically decrypts `.age` secrets in memory directly to `$HOME`
(`0600`) during `apply` / `restow`:

1. Preview with `task test` (`enstow apply --dry-run --force`).

2. Apply symlinks and decrypted secrets with `task restow`.

3. If unmanaged target collisions or legacy folded directory symlinks block
   apply, run `task restow:fix` (`enstow apply --backup`, see
   [`restow`](../restow/SKILL.md)).

### 5. Status & Health Audit

Inspect sync state and hygiene with `enstow`:

```bash
task status -- --check
task doctor
```

- Stale symlinks pointing to removed `dotfiles` targets are pruned automatically
  by `enstow apply` (`prune = true` in `.enstow.toml`); confirm with the user
  before removing unrelated links outside `dotfiles`.

### 6. Verification & Fix Loop

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

### 7. Terse Status Report

Summarize concisely:

- Pulled commit range / file count
- Conflicts resolved and stash status
- Issues encountered and fixes applied
- Verification pass/fail summary and `rtk git status`
- Note `source ~/.bashrc` if `bash/` configs changed
