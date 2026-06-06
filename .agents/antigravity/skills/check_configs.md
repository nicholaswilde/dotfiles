# /app check-configs

Scans the user's `~/.config/` directory, compares it with stowed packages in the dotfiles repository, and recommends configuration files/folders to back up.

## Description
This skill automates the detection of unstowed configuration files inside the user's `~/.config` folder. It lists the active configuration packages in the dotfiles repository, identifies which system configs are untracked, filters out transient/cache folders, and presents a prioritized list of backup recommendations (noting security/sensitive files to avoid committing to Git).

## Protocol

1. **Enumerate System Configurations:**
   - **Step:** List the first level of files and subdirectories under `~/.config/` on the host system.
   
2. **Identify Repo Stow Packages:**
   - **Step:** List the subdirectories at the root of the dotfiles repository.
   - **Step:** Exclude system, Git, and helper folders (e.g. `.git/`, `.github/`, `.agents/`, `conductor/`, `tests/`, `unstow.sh`). These represent your stowed package list.

3. **Compare and Analyze:**
   - **Step:** Cross-reference the system configurations found in `~/.config/` with the dotfiles packages.
   - **Step:** If a folder exists in `~/.config/<name>` but does not have a matching folder `<name>` (or folder containing `.config/<name>`) in the repository, flag it as untracked.

4. **Filter and Categorize Recommendations:**
   - **Step:** Filter out known telemetry, cache, or tool state directories (e.g. `go/telemetry`, `flutter/tool_state`, `configstore/`, `visidata/input_history.jsonl`).
   - **Step:** Categorize the remaining untracked items:
     - **High Priority:** Editor, shell, and system utility configurations (e.g., `nvim`, `btop`, `neofetch`).
     - **Medium Priority:** Custom user configurations for logs or applications (e.g., `lnav`, custom `fabric` prompt patterns).
     - **DO NOT BACKUP (Sensitive/State):** Files containing credentials, secrets, or device keys (e.g., `sops/age/keys.txt`, `Bitwarden CLI/data.json`, `fabric/.env`, `homelab-pull/password`).
   
5. **Present Findings:**
   - **Step:** Output a formatted markdown table or checklist summarizing the findings and priorities.
   - **Step:** Provide instructions on how the user can stow recommended configurations using the `/app add <path>` command.
