# Agent Skills Catalog

This catalog documents the custom agent skills and commands available in this repository. These skills assist developers and AI agents in managing, stowing, verifying, and synchronizing dotfile configurations across environments.

## Table of Commands

| Command / Skill | Description | Link |
| --- | --- | --- |
| `/app add <path>` | Adds an application's configuration to the repository and configures GNU Stow. | [Details](#app-add-path) |
| `/app check-configs` | Scans `~/.config/` and recommends configuration directories to track and back up. | [Details](#app-check-configs) |
| `/app sync <app_name>` | Commits, pushes local changes, and pulls & restarts services on a Proxmox LXC container. | [Details](#app-sync-app_name) |
| `Add Path to Environment Variable` | Safe additions to `$PATH` variable in `bash/.bash_exports`. | [add_path_to_env.md](./antigravity/skills/add_path_to_env.md) |
| `Manage Bash Aliases` | Add, modify, or remove shell aliases in `bash/.bash_aliases`. | [manage_bash_aliases.md](./antigravity/skills/manage_bash_aliases.md) |
| `Manage Bash Functions` | Edit functions in `bash/.bash_functions` with required inline docstrings. | [manage_bash_functions.md](./antigravity/skills/manage_bash_functions.md) |
| `Verify Bash Configs` | Syntax validation, ShellCheck checks, and function comments check. | [verify_bash_configs.md](./antigravity/skills/verify_bash_configs.md) |

---

## Command Details

### `/app add <path>`

Adds the configuration files of a new application to this dotfiles repository and sets up Stow.

- **Syntax**: `/app add <path>`
- **Dependencies**: `stow`, `sops`, `git`
- **Behavior & Protocol**:
  1. **Resolve Input**: Verifies that the path exists. Calculates the relative path from the user's home directory (e.g. `/home/nicholas/.config/myapp/config.toml` -> `.config/myapp/config.toml`). Prompts the user for a Stow package name.
  2. **Replicate Structure**: Creates the directory structure under the new package directory and copies the configuration files. Appends the package name to the centralized `.stow-packages` file.
  3. **Manage Secrets**: Checks if the configuration contains sensitive data (e.g., API keys, passwords, tokens). If so, adds the unencrypted path to `.gitignore` and `.stow-local-ignore`, encrypts it using SOPS (`sops -e` producing a `.enc` file), and adds encryption/decryption tasks to `Taskfile.yaml`.
  4. **Verify & Stow**: Runs a dry-run simulation using `stow -n -v --adopt -t ~/ <package_name>`. Upon clean verification and user confirmation, runs the live stow command `stow -v --adopt -t ~/ <package_name>`.
  5. **Commit**: Commits the new package files to git using conventional commit format: `feat(<package_name>): Add configuration files and stow package`.

---

### `/app check-configs`

Scans the user's `~/.config/` directory, compares it with stowed packages in the dotfiles repository, and recommends configuration files/folders to back up.

- **Syntax**: `/app check-configs`
- **Dependencies**: `ls`, `find`, `git`
- **Behavior & Protocol**:
  1. **Enumerate System Configurations**: Scans the first level of directories under `~/.config/`.
  2. **Identify Tracked Packages**: Lists current subdirectories at the root of the repository, excluding helper directories (like `tests/`, `.agents/`, `conductor/`).
  3. **Cross-Reference & Filter**: Compares local config directories against the repository's packages. Filters out telemetry, temporary state, and cache directories (e.g., `go/telemetry/`, `configstore/`).
  4. **Prioritize Recommendations**:
     - **High Priority**: Core dev tools and editors (e.g., `nvim`, `btop`, `micro`).
     - **Medium Priority**: Less critical user preferences or applications.
     - **DO NOT BACKUP**: Directories containing credentials, SSH keys, or secrets (e.g., `sops/`, `Bitwarden CLI/`).
  5. **Present Output**: Generates a clean markdown table showing the priorities and gives instructions on stowing them using `/app add <path>`.

---

### `/app sync <app_name>`

Automates the process of committing local dotfile changes for a package, pushing them to the remote repository, pulling the changes inside a target Proxmox LXC container, and restarting the associated service.

- **Syntax**: `/app sync <app_name>`
- **Dependencies**: `git`, `ssh`, remote service manager (`systemctl`/`systemd` inside LXC)
- **Behavior & Protocol**:
  1. **Stage & Commit Local Changes**: Checks for modified files inside `<app_name>/` in the repository, stages them, and prompts for confirmation or automatically commits them.
  2. **Push to Remote**: Pushes local commits to the remote repository's main branch.
  3. **Remote Pull**: Connects to the target Proxmox LXC container via SSH, pulls the latest commits, and stows/restows the package if necessary.
  4. **Service Restart**: Restarts the remote service associated with the application (e.g., `systemctl restart <app_name>`) to apply the new configuration.
