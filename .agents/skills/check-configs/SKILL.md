---
name: check-configs
description: >-
  Scan ~/.config/ on the host, compare against tracked packages in .enstow.toml, filter caches/secrets, and recommend configs to manage with enstow.
  Trigger: "/app check-configs", "check untracked configs", "audit ~/.config".
---

# Check Configs Skill

Scans `~/.config/` and compares against tracked `enstow` packages in `dotfiles`.

## Protocol

1. **Enumerate System Configs**:
   - List top-level entries in `~/.config/`.

2. **Identify Tracked Packages**:
   - Read `packages` from `.enstow.toml` and inspect package `.config/` directories in repo root (excluding `.git/`, `.github/`, `.agents/`, `scripts/`, `tests/`).

3. **Cross-Reference & Filter**:
   - Flag `~/.config/<name>` entries without a matching `enstow` package.
   - Exclude transient telemetry, cache, and runtime state (`go/telemetry/`, `configstore/`, caches).

4. **Prioritize & Report**:
   - **High Priority**: Core editors, shells, CLI tools (`nvim`, `btop`, `micro`).
   - **Medium Priority**: User preferences and utilities.
   - **DO NOT BACKUP**: Credentials, age keys, tokens (`sops/`, `Bitwarden CLI/`).
   - Present Markdown summary table and recommend `/app add <path>` (`add-app` skill) for selected items.
