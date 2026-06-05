# Product Definition

## Vision

To create a highly portable, consistent, and secure development environment across multiple machines (including homelab, personal devices, and Proxmox LXCs) by managing user configurations (dotfiles) through a unified repository. The configurations are modularly organized as packages and symlinked to the home directory using GNU Stow, with automated workflows managed by Taskfile and sensitive data securely encrypted using SOPS.

## Goals

- **Portability & Reproducibility:** Allow quick bootstrapping of a new machine or container environment to match the user's preferred setup.
- **Security:** Ensure all API keys, personal tokens, and sensitive settings are encrypted in transit and at rest in the repository using SOPS, without risk of accidental leakage.
- **Automation:** Simplify installation, restowing, backup, and encryption/decryption workflows through easy-to-use Taskfile commands.
- **Modularity:** Maintain distinct packages (e.g., `bash`, `tmux`, `nvim`, `antigravity-cli`) that can be stowed individually depending on the system's requirements.

## Target Audience

- **Primary:** Nicholas Wilde (Author/Developer).
- **Secondary:** Homelab hosts, LXC containers, and development environments that need rapid configuration sync.

## Core Features

- **GNU Stow Symlink Management:** Modular stow packages mapping repository directories (e.g. `bash/`, `tmux/`, `nvim/`) to `~/`.
- **SOPS Encrypted Secret Management:** Seamless encryption/decryption of files (e.g. `.tokens.enc`, `settings.json.enc`, `mcp_config.json.enc`) using Mozilla SOPS.
- **Task Runner Integration:** Automated tasks for bootstrapping, updating, decrypting, encrypting, installing, and testing configuration symlinks.
- **Antigravity CLI Configuration Sync:** First-class support for backing up and stowing Antigravity settings, MCP servers, and custom skills.

## Success Metrics

- Clean bootstrapping (`task bootstrap`) succeeds on a fresh environment.
- Plaintext secrets are never committed to Git (verified via `.stow-local-ignore` and `.gitignore`).
- Modular stow packages deploy without file conflicts.
