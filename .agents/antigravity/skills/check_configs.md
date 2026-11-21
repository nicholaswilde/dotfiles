# /app check-configs

Scans the user's `~/.config/` directory, compares it with tracked `enstow` packages in the dotfiles repository, and recommends configuration files/folders to back up.

## Description

This skill automates the detection of untracked configuration files inside the user's `~/.config` folder. It lists active packages configured in `.enstow.toml`, identifies which system configs are untracked, filters out transient/cache folders, and presents a prioritized list of backup recommendations.

## Protocol

1. **Enumerate System Configurations:**
   - **Step:** List the first level of files and subdirectories under `~/.config/` on the host system.

2. **Identify Repo Packages:**
   - **Step:** Read `packages` from `.enstow.toml` and inspect package directories at the root of the dotfiles repository.
   - **Step:** Exclude system, Git, and helper folders (e.g. `.git/`, `.github/`, `.agents/`, `scripts/`, `tests/`).

3. **Compare and Analyze:**
   - **Step:** Cross-reference system configurations in `~/.config/` with dotfiles packages.
   - **Step:** Flag `~/.config/<name>` entries that do not have a matching `<name>` package (or `.config/<name>` inside a package) as untracked.

4. **Filter and Categorize Recommendations:**
   - **Step:** Filter out telemetry, cache, or tool state directories (e.g. `go/telemetry`, `flutter/tool_state`, `configstore/`, `visidata/input_history.jsonl`).
   - **Step:** Categorize the remaining untracked items:
     - **High Priority:** Editor, shell, and system utility configurations (e.g. `nvim`, `btop`, `neofetch`).
     - **Medium Priority:** Custom user configurations for logs or applications.
     - **DO NOT BACKUP (Sensitive/State):** Files containing credentials, secrets, or device keys (e.g. `sops/age/keys.txt`, `Bitwarden CLI/data.json`, `fabric/.env`).

5. **Present Findings:**
   - **Step:** Output a formatted markdown table or checklist summarizing findings and priorities.
   - **Step:** Provide instructions on adding recommended configurations using `/app add <path>`.
