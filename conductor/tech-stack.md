# Tech Stack

## Core Technologies

- **GNU Stow:** The core symlink manager used to link configurations from modular package folders in the repository to the user's home directory.
- **Bash / Shell Scripts:** The shell environment and scripting language used for interactive helpers, aliases, functions, and boot scripts.

## Automation and Secrets

- **Go Task (Taskfile):** The primary task runner utilized to automate local development tasks (install, restow, test, decrypt, encrypt).
- **Mozilla SOPS:** Used to encrypt and decrypt sensitive files containing API keys, OAuth tokens, and secret configurations.
- **Git:** Version control system for tracking configurations and changes.

## Supported Configured Applications

- **Neovim (nvim):** Advanced text editor config.
- **tmux:** Terminal multiplexer configuration.
- **micro:** Terminal-based text editor configuration.
- **lazygit / lazydocker:** Terminal UIs for git and docker.
- **mise:** Polyglot tool manager.
- **gh CLI:** GitHub command line tool.
- **ripgrep:** Fast text search utility configuration.
