---
name: audit-eget
description: >-
  Audit ~/.local/bin/ against eget/.eget.toml, detect brew/uv duplicates, verify GitHub release assets, and update .eget.toml.
  Trigger: /audit-eget, /check-eget, "audit ~/.local/bin", "audit .eget.toml", "check local bin".
---

# Audit `~/.local/bin/` & `.eget.toml` Skill

Scans `~/.local/bin/`, compares standalone binaries against `eget/.eget.toml`
and `brew`/`uv` installs, and keeps `eget` configuration clean and non-interactive.

## Protocol

### 1. Enumerate `~/.local/bin/` & Cross-Reference Managers

1. List standalone regular binaries (`-f` and `! -L`) vs symlinks
   (`uv`, `pipx`, `stow`, installers) in `~/.local/bin/`.
2. Check existing entries in `eget/.eget.toml` and verify `~/.eget.toml`
   symlink points to `eget/.eget.toml`.
3. Detect overlaps with Homebrew (`/home/linuxbrew/.linuxbrew/bin/<name>`,
   `brew list --formula`) and `uv tool list`.

### 2. Classify Findings

- **Add to `eget/.eget.toml`**: Standalone GitHub-release binaries not managed
  by `brew`/`uv`/`pipx`/stow.
- **Duplicates**: Binaries present in both `~/.local/bin/` and `brew`.
  Confirm with user which copy to keep before deleting local files or running
  `brew uninstall <formula>`. After `brew uninstall`, run `hash -r` in shell
  and remind user to run `hash -r` in open interactive terminals.
- **Skip**: Symlink-managed tools (`uv`, `pipx`, `stow`), non-GitHub-release
  binaries, and source builds without GitHub releases.

### 3. Verify Release Assets Before Editing

For each candidate `<owner/repo>`, inspect release assets first:

```bash
rtk gh release view --repo <owner/repo> --json tagName,assets \
  --jq '.tagName, (.assets[].name)' | cat
```

Add disambiguation keys in `eget/.eget.toml` when needed so `eget -D` never
prompts interactively:

- `asset_filters = [...]` when multiple OS/arch/libc archives match
- `file = "<bin>"` when archive includes extra matching files (e.g. `LICENSE`)
- `all = true` when tarball ships multiple binaries (e.g. `uv` + `uvx`)

### 4. Format, Test & Restow

1. Format and lint TOML:

   ```bash
   rtk taplo fmt eget/.eget.toml
   rtk taplo lint eget/.eget.toml
   ```

2. Test non-interactive install/update (loading `EGET_GITHUB_TOKEN` if present):

   ```bash
   test -f ~/.tokens && source ~/.tokens
   eget -D < /dev/null
   ```

3. Restow `eget` package and check secrets:

   ```bash
   task restow:fix -- eget
   task check-secrets
   ```

### 5. Terse Status Report

Summarize:

- Standalone binaries audited vs symlink-managed skipped
- Entries added/updated in `eget/.eget.toml` and duplicates resolved
- `taplo`, `eget -D < /dev/null`, and `task restow:fix -- eget` results
